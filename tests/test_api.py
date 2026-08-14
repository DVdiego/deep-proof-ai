from fastapi.testclient import TestClient

from deepproof.api import app


client = TestClient(app)


def test_health_exposes_pipeline_version() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["pipeline"] == "public-reference-0.1"


def test_invalid_feature_range_is_rejected() -> None:
    response = client.post("/v1/analyze", json={
        "media_id": "invalid",
        "declared_mime": "video/mp4",
        "container": "mp4",
        "codec": "h264",
        "duplicate_frame_ratio": 1.5,
        "timestamp_jitter": 0,
        "face_boundary_artifact_score": 0,
        "frequency_anomaly_score": 0,
    })
    assert response.status_code == 422
