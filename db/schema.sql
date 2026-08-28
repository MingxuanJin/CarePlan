-- =============================================================
-- Care Plan Generator — PostgreSQL 表结构
-- 对应 design-doc.md 第 9 节：Patient / Provider / Order / CarePlan
-- =============================================================

-- 删除旧表（依赖顺序：先子表后父表），保证脚本可重复执行
DROP TABLE IF EXISTS care_plans CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS patients CASCADE;
DROP TABLE IF EXISTS providers CASCADE;

-- 患者表
CREATE TABLE patients (
    id          SERIAL PRIMARY KEY,
    first_name  TEXT        NOT NULL,
    last_name   TEXT        NOT NULL,
    mrn         VARCHAR(6)  NOT NULL UNIQUE,          -- 6 位数字，全局唯一
    dob         DATE,                                 -- 用于重复患者检测
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_patient_mrn CHECK (mrn ~ '^[0-9]{6}$')
);

-- 医生表（NPI 是唯一身份标识）
CREATE TABLE providers (
    id          SERIAL PRIMARY KEY,
    name        TEXT        NOT NULL,
    npi         VARCHAR(10) NOT NULL UNIQUE,          -- 10 位数字，唯一
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_provider_npi CHECK (npi ~ '^[0-9]{10}$')
);

-- 订单表（一个患者可有多个订单，一个医生可开多个订单）
CREATE TABLE orders (
    id                   SERIAL PRIMARY KEY,
    patient_id           INTEGER NOT NULL REFERENCES patients(id),
    provider_id          INTEGER NOT NULL REFERENCES providers(id),
    medication_name      TEXT    NOT NULL,
    primary_diagnosis    TEXT    NOT NULL,            -- ICD-10 码
    additional_diagnoses JSONB   NOT NULL DEFAULT '[]'::jsonb,  -- ICD-10 码列表
    medication_history   JSONB   NOT NULL DEFAULT '[]'::jsonb,  -- 字符串列表
    patient_records      TEXT    NOT NULL DEFAULT '',
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_primary_diagnosis
        CHECK (primary_diagnosis ~ '^[A-Z][0-9]{2}(\.[0-9A-Z]{1,4})?$')
);

-- 护理计划表（一个订单对应一个护理计划）
CREATE TABLE care_plans (
    id          SERIAL PRIMARY KEY,
    order_id    INTEGER NOT NULL UNIQUE REFERENCES orders(id),
    content     TEXT    NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
