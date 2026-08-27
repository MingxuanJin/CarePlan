import os
import uuid

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from google import genai
from pydantic import BaseModel


load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
) # 在后端进行验证

ORDERS = {}


class CarePlanRequest(BaseModel): # 待查询干嘛的
    patient_first_name: str = ""
    patient_last_name: str = ""
    patient_mrn: str = ""
    provider_name: str = ""
    provider_npi: str = ""
    primary_diagnosis: str = ""
    additional_diagnoses: str = ""
    medication_name: str = ""
    medication_history: str = ""
    patient_records: str = ""


@app.post("/api/careplans")
def create_care_plan(order_input: CarePlanRequest):
    order_id = str(uuid.uuid4())
    order = order_input.model_dump() # 查一下
    order["id"] = order_id

    prompt = f"""
Create a pharmacy care plan in plain English for this medication order.

Patient:
- Name: {order["patient_first_name"]} {order["patient_last_name"]}
- MRN: {order["patient_mrn"]}

Provider:
- Name: {order["provider_name"]}
- NPI: {order["provider_npi"]}

Clinical information:
- Primary diagnosis: {order["primary_diagnosis"]}
- Additional diagnoses: {order["additional_diagnoses"]}
- Medication: {order["medication_name"]}
- Medication history: {order["medication_history"]}
- Patient records: {order["patient_records"]}

Include these sections:
1. Problem list
2. Goals
3. Pharmacist interventions
4. Monitoring plan
"""

    client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
    response = client.models.generate_content(
        model=os.getenv("GEMINI_MODEL", "gemini-3.7-flash"),
        contents=prompt,
    )

    order["care_plan"] = response.text
    ORDERS[order_id] = order

    return order


@app.get("/api/careplans/{order_id}")
def get_care_plan(order_id: str):
    return ORDERS.get(order_id, {})


app.mount("/", StaticFiles(directory="static", html=True), name="static")
