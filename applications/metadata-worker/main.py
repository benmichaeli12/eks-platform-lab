import hashlib
import json
import logging
import os
import sys
from datetime import datetime, timezone

import boto3
import psycopg

logging.basicConfig(
    level=logging.INFO,
    format='{"time":"%(asctime)s","level":"%(levelname)s","message":"%(message)s"}',
)
log = logging.getLogger("metadata-worker")

QUEUE_URL = os.environ["JOBS_QUEUE_URL"]
BUCKET = os.environ["DOCUMENTS_BUCKET"]
DATABASE_URL = os.environ["DATABASE_URL"]
BATCH_SIZE = int(os.environ.get("BATCH_SIZE", 10))
MAX_BATCHES = int(os.environ.get("MAX_BATCHES", 20))

sqs = boto3.client("sqs")
s3 = boto3.client("s3")

SCHEMA = """
CREATE TABLE IF NOT EXISTS documents (
    document_id   UUID PRIMARY KEY,
    filename      TEXT,
    content_type  TEXT,
    size_bytes    BIGINT NOT NULL,
    sha256        TEXT NOT NULL,
    submitted_at  TIMESTAMPTZ,
    processed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
"""

UPSERT = """
INSERT INTO documents
    (document_id, filename, content_type, size_bytes, sha256, submitted_at)
VALUES
    (%(document_id)s, %(filename)s, %(content_type)s, %(size_bytes)s, %(sha256)s, %(submitted_at)s)
ON CONFLICT (document_id) DO UPDATE SET
    size_bytes   = EXCLUDED.size_bytes,
    sha256       = EXCLUDED.sha256,
    processed_at = now();
"""


def process(message, conn):
    job = json.loads(message["Body"])
    obj = s3.get_object(Bucket=BUCKET, Key=job["s3_key"])
    body = obj["Body"].read()

    with conn.cursor() as cur:
        cur.execute(UPSERT, {
            "document_id": job["document_id"],
            "filename": job.get("filename"),
            "content_type": job.get("content_type"),
            "size_bytes": len(body),
            "sha256": hashlib.sha256(body).hexdigest(),
            "submitted_at": job.get("submitted_at"),
        })
    conn.commit()
    log.info("processed document %s", job["document_id"])


def main():
    with psycopg.connect(DATABASE_URL) as conn:
        with conn.cursor() as cur:
            cur.execute(SCHEMA)
        conn.commit()

        for _ in range(MAX_BATCHES):
            response = sqs.receive_message(
                QueueUrl=QUEUE_URL,
                MaxNumberOfMessages=BATCH_SIZE,
                WaitTimeSeconds=20,
            )
            messages = response.get("Messages", [])

            if not messages:
                log.info("queue empty, exiting")
                return

            for message in messages:
                try:
                    process(message, conn)
                    sqs.delete_message(
                        QueueUrl=QUEUE_URL,
                        ReceiptHandle=message["ReceiptHandle"],
                    )
                except Exception:
                    log.exception("failed to process message, leaving for retry")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        log.exception("worker failed")
        sys.exit(1)