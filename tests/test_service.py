from deepproof.models import MediaFeatures
from deepproof.service import AuthenticityService


def sample(**overrides: object) -> MediaFeatures:
    values = {
        "media_id": "video-1",
        "declared_mime": "video/mp4",
        "container": "mp4",
        "codec": "h264",
        "has_creation_timestamp": True,
        "duplicate_frame_ratio": 0.05,
        "timestamp_jitter": 0.04,
        "face_boundary_artifact_score": 0.08,
        "frequency_anomaly_score": 0.06,
    }
    values.update(overrides)
    return MediaFeatures.model_validate(values)


def test_low_risk_media_keeps_explanations() -> None:
    result = AuthenticityService().analyze(sample())
    assert result.risk_band == "low"
    assert len(result.evidence) == 3
    assert result.confidence > 0.7


def test_multiple_anomalies_produce_high_risk() -> None:
    result = AuthenticityService().analyze(sample(
        declared_mime="video/webm",
        has_creation_timestamp=False,
        encoder="synthetic generator",
        duplicate_frame_ratio=0.9,
        timestamp_jitter=0.8,
        face_boundary_artifact_score=0.95,
        frequency_anomaly_score=0.9,
    ))
    assert result.risk_band == "high"
    assert result.manipulation_risk > 0.85
    assert "not a forensic conclusion" in result.disclaimer
