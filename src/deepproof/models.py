from typing import Literal

from pydantic import BaseModel, Field


class MediaFeatures(BaseModel):
    media_id: str = Field(min_length=1)
    declared_mime: str
    container: str
    codec: str
    has_creation_timestamp: bool = True
    encoder: str | None = None
    duplicate_frame_ratio: float = Field(ge=0, le=1)
    timestamp_jitter: float = Field(ge=0, le=1)
    face_boundary_artifact_score: float = Field(ge=0, le=1)
    frequency_anomaly_score: float = Field(ge=0, le=1)


class Evidence(BaseModel):
    detector: str
    score: float = Field(ge=0, le=1)
    weight: float = Field(gt=0, le=1)
    explanation: str


class AnalysisResult(BaseModel):
    media_id: str
    manipulation_risk: float = Field(ge=0, le=1)
    risk_band: Literal["low", "medium", "high"]
    confidence: float = Field(ge=0, le=1)
    evidence: list[Evidence]
    pipeline_version: str
    disclaimer: str
