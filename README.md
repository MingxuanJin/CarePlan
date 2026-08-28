# Care Plan Generator

面向专科药房的护理计划（Care Plan）自动生成工具。医疗工作人员录入患者、医生、诊断和用药信息，系统调用 LLM 自动生成包含问题清单、治疗目标、药师干预和监测计划的护理计划。

本项目当前是一个**最小可行产品（MVP）**，用于学习和逐步迭代，刻意保持技术简单。

## 技术栈

| 类别 | 技术 | 版本 | 用途 |
|------|------|------|------|
| 后端框架 | [FastAPI](https://fastapi.tiangolo.com/) | 0.109.0 | Web API |
| ASGI 服务器 | [Uvicorn](https://www.uvicorn.org/) | 0.27.0 | 运行 FastAPI 应用 |
| LLM | [Google Gemini](https://ai.google.dev/) (`google-generativeai`) | 0.3.2 | 生成护理计划 |
| 数据校验 | [Pydantic](https://docs.pydantic.dev/) | 2.6.1 | 请求体模型校验 |
| 前端 | 原生 HTML5 / CSS3 / JavaScript (ES6+) | — | 无框架，无构建工具 |
| 运行环境 | Python | 3.11 | 后端语言 |
| 部署 | [Docker](https://www.docker.com/) + Docker Compose | — | 容器化部署 |

## 项目结构

```
careplan-generator/
├── main.py              # FastAPI 后端（单文件，无分层）
├── static/
│   ├── index.html       # 前端页面结构
│   ├── styles.css       # 前端样式
│   └── app.js           # 前端交互逻辑
├── requirements.txt     # Python 依赖
├── Dockerfile           # Docker 镜像定义
├── docker-compose.yml   # Docker 编排
├── .env                 # 环境变量（本地密钥，不入库）
├── .gitignore
└── design-doc.md        # 设计文档
```

## 快速开始

### 方式一：Docker（推荐）

1. 配置环境变量

   复制 `.env` 文件并填入你的 Gemini API Key：

   ```
   GEMINI_API_KEY=你的_API_Key
   GEMINI_MODEL=gemini-3.6-flash
   ```

2. 启动容器

   ```bash
   docker-compose up --build
   ```

3. 访问应用

   浏览器打开 http://localhost:8000

### 方式二：本地运行

1. 创建虚拟环境并安装依赖

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. 加载环境变量并启动

   ```bash
   export $(cat .env | xargs)
   uvicorn main:app --reload --port 8000
   ```

3. 访问应用

   浏览器打开 http://localhost:8000

## API 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| `GET` | `/` | 前端页面 |
| `POST` | `/api/orders` | 提交患者/医生/用药信息，同步生成护理计划 |
| `GET` | `/api/orders` | 列出所有订单 |
| `GET` | `/api/orders/{order_id}` | 查看订单详情和生成的护理计划 |
| `GET` | `/api/orders/{order_id}/download` | 下载护理计划为 `.txt` 文件 |
| `GET` | `/api/reports/export` | 导出报告数据 |

## 当前 MVP 特性与限制

**已实现：**

- 录入患者、医生、诊断、用药信息
- 调用 LLM 同步生成护理计划（问题清单、治疗目标、药师干预、监测计划）
- 下载护理计划为文本文件
- 前端表单提交并展示结果

**刻意保持简单（后续迭代再加）：**

- 数据存储在内存（Python 字典），无数据库
- 同步请求，无队列、无 worker、无 WebSocket
- 无认证、无角色权限控制
- 无输入校验（NPI 格式、MRN 唯一性、ICD-10 格式等）
- 无重复患者/订单检测
- 无错误处理、无告警提示
- 无测试用例

> 以上限制是**有意为之**，用于在学习过程中逐步体验真实痛点（如 LLM 超时、模型版本下线、数据重启丢失等）后，再逐项引入对应解决方案。

## 设计文档

完整的需求、数据模型和规则说明见 [design-doc.md](design-doc.md)。
