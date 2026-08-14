from collections.abc import Sequence

from .analyzers import Analyzer, MetadataAnalyzer, TemporalAnalyzer, VisualArtifactAnalyzer
from .models import AnalysisResult, MediaFeatures


class AuthenticityService:
    """Public reference fusion service using illustrative, non-research weights."""

    PIPELINE_VERSION = "public-reference-0.1"

    def __init__(self, analyzers: Sequence[Analyzer] | None = None) -> None:
        self._analyzers = list(analyzers or [
            MetadataAnalyzer(),
            TemporalAnalyzer(),
            VisualArtifactAnalyzer(),
        ])

    def analyze(self, features: MediaFeatures) -> AnalysisResult:
        evidence = [analyzer.analyze(features) for analyzer in self._analyzers]
        total_weight = sum(item.weight for item in evidence)
        risk = sum(item.score * item.weight for item in evidence) / total_weight
        disagreement = max((item.score for item in evidence), default=0) - min(
            (item.score for item in evidence), default=0
        )
        confidence = min(0.95, 0.55 + 0.12 * len(evidence) - 0.25 * disagreement)

        return AnalysisResult(
            media_id=features.media_id,
            manipulation_risk=round(risk, 4),
            risk_band=risk_band(risk),
            confidence=round(max(0, confidence), 4),
            evidence=evidence,
            pipeline_version=self.PIPELINE_VERSION,
            disclaimer=(
                "Probabilistic engineering indicator for review; "
                "not a forensic conclusion or proof of manipulation."
            ),
        )


def risk_band(risk: float) -> str:
    if risk >= 0.7:
        return "high"
    if risk >= 0.35:
        return "medium"
    return "low"
