from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, FileResponse
from pydantic import BaseModel
from typing import List, Optional
import os
from datetime import datetime
import google.generativeai as genai

app = FastAPI()

# 内存存储
orders_db = {}
counter = 0

# Gemini 客户端
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel(os.getenv("GEMINI_MODEL", "gemini-3.6-flash"))


class OrderInput(BaseModel):
    patient_first_name: str
    patient_last_name: str
    provider_name: str
    provider_npi: str
    patient_mrn: str
    primary_diagnosis: str
    medication_name: str
    additional_diagnoses: List[str] = []
    medication_history: List[str] = []
    patient_records: str = ""


@app.get("/", response_class=HTMLResponse)
async def index():
    with open("static/index.html", "r") as f:
        return f.read()


@app.get("/static/{file_path}")
async def serve_static(file_path: str):
    """提供静态文件"""
    filepath = f"static/{file_path}"
    if os.path.exists(filepath):
        return FileResponse(filepath)
    raise HTTPException(status_code=404, detail="File not found")


@app.post("/api/orders")
async def create_order(order: OrderInput):
    """提交患者信息并生成 care plan"""
    global counter
    counter += 1
    order_id = f"ORD-{counter}"

    # 调用 LLM 生成 care plan
    care_plan = generate_care_plan(order)

    # 存储到内存
    orders_db[order_id] = {
        "id": order_id,
        "created_at": datetime.now().isoformat(),
        "order": order.model_dump(),
        "care_plan": care_plan
    }

    return {"order_id": order_id, "care_plan": care_plan}


@app.get("/api/orders")
async def list_orders():
    """列出所有订单"""
    return list(orders_db.values())


@app.get("/api/orders/{order_id}")
async def get_order(order_id: str):
    """获取订单详情"""
    if order_id not in orders_db:
        raise HTTPException(status_code=404, detail="Order not found")
    return orders_db[order_id]


@app.get("/api/orders/{order_id}/download")
async def download_care_plan(order_id: str):
    """下载 care plan 为文本文件"""
    if order_id not in orders_db:
        raise HTTPException(status_code=404, detail="Order not found")
    
    order_data = orders_db[order_id]
    care_plan = order_data["care_plan"]
    
    # 创建临时文件用于下载
    filename = f"care_plan_{order_id}.txt"
    filepath = f"/tmp/{filename}"
    
    with open(filepath, "w") as f:
        f.write(care_plan)
    
    return FileResponse(filepath, filename=filename)


@app.get("/api/reports/export")
async def export_report():
    """导出报告数据"""
    return list(orders_db.values())


def generate_care_plan(order: OrderInput) -> str:
    """使用 LLM 生成 care plan"""
    prompt = f"""
为以下患者生成护理计划（Care Plan）：

患者信息:
- 姓名: {order.patient_first_name} {order.patient_last_name}
- MRN: {order.patient_mrn}
- 主治医生: {order.provider_name} (NPI: {order.provider_npi})

诊断信息:
- 主要诊断: {order.primary_diagnosis}
- 其他诊断: {', '.join(order.additional_diagnoses) if order.additional_diagnoses else '无'}

用药信息:
- 当前用药: {order.medication_name}
- 用药历史: {', '.join(order.medication_history) if order.medication_history else '无'}

患者记录:
{order.patient_records if order.patient_records else '无额外记录'}

请生成包含以下内容的护理计划：
1. 问题清单 (Problem List)
2. 治疗目标 (Goals)
3. 药师干预建议 (Pharmacist Interventions)
4. 监测计划 (Monitoring Plan)

请用英文生成，格式清晰。
"""

    try:
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        return f"生成 care plan 时出错: {str(e)}"


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
