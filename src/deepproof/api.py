from fastapi import FastAPI

from .models import AnalysisResult, MediaFeatures
from .service import AuthenticityService

app = FastAPI(
    title="DeepProof AI Reference API",
    version="0.1.0",
    description="Explainable fusion layer for audiovisual authenticity signals.",
)
service = AuthenticityService()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "pipeline": service.PIPELINE_VERSION}


@app.post("/v1/analyze", response_model=AnalysisResult)
def analyze(features: MediaFeatures) -> AnalysisResult:
    return service.analyze(features)
