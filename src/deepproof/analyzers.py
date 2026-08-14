from typing import Protocol

from .models import Evidence, MediaFeatures


class Analyzer(Protocol):
    def analyze(self, features: MediaFeatures) -> Evidence: ...


class MetadataAnalyzer:
    weight = 0.20

    def analyze(self, features: MediaFeatures) -> Evidence:
        anomalies: list[str] = []
        expected = {"mp4": {"video/mp4"}, "webm": {"video/webm"}, "mov": {"video/quicktime"}}
        if features.declared_mime not in expected.get(features.container.lower(), set()):
            anomalies.append("container and MIME type disagree")
        if not features.has_creation_timestamp:
            anomalies.append("creation timestamp is missing")
        if features.encoder and any(term in features.encoder.lower() for term in ("synthetic", "generated")):
            anomalies.append("encoder identifies a synthetic pipeline")

        score = min(1.0, len(anomalies) / 3)
        return Evidence(
            detector="metadata-consistency",
            score=score,
            weight=self.weight,
            explanation="; ".join(anomalies) if anomalies else "No metadata inconsistency detected",
        )


class TemporalAnalyzer:
    weight = 0.30

    def analyze(self, features: MediaFeatures) -> Evidence:
        score = clamp(0.65 * features.duplicate_frame_ratio + 0.35 * features.timestamp_jitter)
        return Evidence(
            detector="temporal-consistency",
            score=score,
            weight=self.weight,
            explanation=(
                f"duplicate frames={features.duplicate_frame_ratio:.2f}; "
                f"timestamp jitter={features.timestamp_jitter:.2f}"
            ),
        )


class VisualArtifactAnalyzer:
    weight = 0.50

    def analyze(self, features: MediaFeatures) -> Evidence:
        score = clamp(
            0.6 * features.face_boundary_artifact_score
            + 0.4 * features.frequency_anomaly_score
        )
        return Evidence(
            detector="visual-artifacts",
            score=score,
            weight=self.weight,
            explanation=(
                f"face-boundary artifacts={features.face_boundary_artifact_score:.2f}; "
                f"frequency anomalies={features.frequency_anomaly_score:.2f}"
            ),
        )


def clamp(value: float) -> float:
    return max(0.0, min(1.0, value))
