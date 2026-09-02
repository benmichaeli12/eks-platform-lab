import json
import os
import uuid
from datetime import datetime, timezone

import boto3
from fastapi import FastAPI, HTTPException, UploadFile, File, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

BUCKET = os.environ["DOCUMENTS_BUCKET"]
QUEUE_URL = os.environ["JOBS_QUEUE_URL"]
MAX_BYTES = int(os.environ.get("MAX_UPLOAD_BYTES", 5 * 1024 * 1024))

app = FastAPI(title="ingest-api")
s3 = boto3.client("s3")
sqs = boto3.client("sqs")

documents_received = Counter(
    "ingest_documents_received_total", "Documents accepted for processing"
)
documents_rejected = Counter(
    "ingest_documents_rejected_total", "Documents rejected", ["reason"]
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.post("/documents", status_code=202)
async def ingest(file: UploadFile = File(...)):
    contents = await file.read()

    if len(contents) > MAX_BYTES:
        documents_rejected.labels(reason="too_large").inc()
        raise HTTPException(status_code=413, detail="file too large")

    if not contents:
        documents_rejected.labels(reason="empty").inc()
        raise HTTPException(status_code=400, detail="file is empty")

    document_id = str(uuid.uuid4())
    key = f"documents/{document_id}"

    s3.put_object(
        Bucket=BUCKET,
        Key=key,
        Body=contents,
        ContentType=file.content_type or "application/octet-stream",
    )

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps({
            "document_id": document_id,
            "s3_key": key,
            "filename": file.filename,
            "content_type": file.content_type,
            "submitted_at": datetime.now(timezone.utc).isoformat(),
        }),
    )

    documents_received.inc()
    return {"document_id": document_id, "status": "accepted"}