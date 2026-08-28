-- =============================================================
-- Care Plan Generator — Mock 数据
-- 使用合成（虚构）数据，仅用于本地开发与测试
-- =============================================================

-- 清空旧数据并重置自增主键，保证可重复执行
TRUNCATE care_plans, orders, patients, providers RESTART IDENTITY CASCADE;

-- ---------- 医生（NPI 10 位数字） ----------
INSERT INTO providers (id, name, npi) VALUES
    (1, 'Dr. Sarah Chen',       '1234567890'),
    (2, 'Dr. Michael Rodriguez','2345678901'),
    (3, 'Dr. Emily Park',       '3456789012'),
    (4, 'Dr. James Wilson',     '4567890123'),
    (5, 'Dr. Priya Patel',      '5678901234');

-- ---------- 患者（MRN 6 位数字） ----------
INSERT INTO patients (id, first_name, last_name, mrn, dob) VALUES
    (1, 'John',   'Smith',    '100001', '1958-03-14'),
    (2, 'Maria',  'Garcia',   '100002', '1965-07-22'),
    (3, 'Robert', 'Johnson',  '100003', '1949-11-02'),
    (4, 'Linda',  'Brown',    '100004', '1972-01-30'),
    (5, 'David',  'Lee',      '100005', '1980-09-17'),
    (6, 'Susan',  'Martinez', '100006', '1960-05-08');

-- ---------- 订单 ----------
INSERT INTO orders (
    id, patient_id, provider_id, medication_name, primary_diagnosis,
    additional_diagnoses, medication_history, patient_records, created_at
) VALUES
    (1, 1, 1, 'Metformin',       'E11.9',
     '["E78.5"]'::jsonb,
     '["Glipizide 5mg", "Metformin 500mg"]'::jsonb,
     'Diagnosed T2DM 2015. Recent HbA1c 8.4%. Reports occasional GI upset on metformin.',
     '2026-08-18 09:30:00+00'),

    (2, 1, 1, 'Lisinopril',      'I10',
     '[]'::jsonb,
     '[]'::jsonb,
     'Newly diagnosed hypertension. Average home BP 152/94 mmHg.',
     '2026-08-18 10:15:00+00'),

    (3, 2, 2, 'Atorvastatin',    'E78.5',
     '["E11.9"]'::jsonb,
     '["Atorvastatin 10mg"]'::jsonb,
     'LDL 142 mg/dL. Also manages T2DM with metformin.',
     '2026-08-20 14:00:00+00'),

    (4, 3, 3, 'Albuterol',       'J45.909',
     '[]'::jsonb,
     '["Albuterol HFA inhaler"]'::jsonb,
     'Moderate persistent asthma. Using rescue inhaler 3-4x/week.',
     '2026-08-22 11:45:00+00'),

    (5, 4, 4, 'Insulin glargine','E11.9',
     '["E11.65", "Z79.4"]'::jsonb,
     '["Metformin 1000mg", "Insulin glargine"]'::jsonb,
     'Long-standing T2DM with neuropathy. HbA1c 9.1%, transitioning to basal insulin.',
     '2026-08-24 16:20:00+00'),

    (6, 5, 5, 'Metformin',       'E11.9',
     '["I10"]'::jsonb,
     '[]'::jsonb,
     'New T2DM diagnosis. HbA1c 7.9%. Also hypertensive on amlodipine.',
     '2026-08-26 09:00:00+00'),

    (7, 6, 1, 'Amlodipine',      'I10',
     '["E78.5"]'::jsonb,
     '["Lisinopril 20mg"]'::jsonb,
     'Uncontrolled hypertension despite lisinopril. Adding amlodipine.',
     '2026-08-27 13:30:00+00'),

    (8, 2, 2, 'Lisinopril',      'I10',
     '[]'::jsonb,
     '["Lisinopril 10mg"]'::jsonb,
     'Refill request. BP well controlled on current dose.',
     '2026-08-27 15:00:00+00');

-- ---------- 护理计划（每个订单一份） ----------
INSERT INTO care_plans (id, order_id, content) VALUES
    (1, 1,
     E'Problem List:\n1. Type 2 diabetes mellitus (E11.9), HbA1c 8.4%\n2. Hyperlipidemia (E78.5)\n\nGoals:\n- Reduce HbA1c to < 7.0% within 6 months\n- Maintain LDL < 100 mg/dL\n\nPharmacist Interventions:\n- Reinforce metformin adherence and counsel on GI side effects\n- Recommend diet and exercise modification\n- Review statin therapy for lipid control\n\nMonitoring Plan:\n- HbA1c every 3 months\n- Fasting lipid panel every 6 months\n- Renal function and B12 annually'),

    (2, 2,
     E'Problem List:\n1. Essential hypertension (I10), average BP 152/94\n\nGoals:\n- Achieve home BP < 130/80 mmHg\n\nPharmacist Interventions:\n- Initiate lisinopril and educate on adherence\n- Counsel on low-sodium diet\n\nMonitoring Plan:\n- Home BP log review every 2 weeks\n- Serum potassium and creatinine at 1 month'),

    (3, 3,
     E'Problem List:\n1. Hyperlipidemia (E78.5), LDL 142\n2. Type 2 diabetes mellitus (E11.9)\n\nGoals:\n- Reduce LDL to < 100 mg/dL\n\nPharmacist Interventions:\n- Continue atorvastatin and optimize dose\n- Counsel on lifestyle and medication timing\n\nMonitoring Plan:\n- Lipid panel every 6 months\n- LFTs at baseline and 12 weeks'),

    (4, 4,
     E'Problem List:\n1. Moderate persistent asthma (J45.909)\n\nGoals:\n- Reduce rescue inhaler use to < 2x/week\n\nPharmacist Interventions:\n- Assess inhaler technique\n- Discuss controller therapy escalation\n\nMonitoring Plan:\n- Symptom diary review monthly\n- Assess control at 3 months'),

    (5, 5,
     E'Problem List:\n1. Type 2 diabetes mellitus with neuropathy (E11.9, E11.65)\n2. Long-term insulin use (Z79.4)\n\nGoals:\n- Reduce HbA1c to < 7.5%\n- Avoid hypoglycemic episodes\n\nPharmacist Interventions:\n- Educate on basal insulin administration and storage\n- Reinforce hypoglycemia recognition and treatment\n\nMonitoring Plan:\n- HbA1c every 3 months\n- Blood glucose log review weekly during titration\n- Foot exam annually'),

    (6, 6,
     E'Problem List:\n1. New-onset type 2 diabetes (E11.9)\n2. Essential hypertension (I10)\n\nGoals:\n- Achieve HbA1c < 7.0%\n\nPharmacist Interventions:\n- Initiate metformin with gradual titration\n- Counsel on GI side effects and adherence\n\nMonitoring Plan:\n- HbA1c every 3 months\n- Renal function at baseline and annually'),

    (7, 7,
     E'Problem List:\n1. Uncontrolled hypertension (I10)\n2. Hyperlipidemia (E78.5)\n\nGoals:\n- Achieve BP < 130/80 mmHg\n\nPharmacist Interventions:\n- Add amlodipine to existing lisinopril\n- Monitor for peripheral edema\n\nMonitoring Plan:\n- BP check every 2 weeks\n- Renal function at 1 month'),

    (8, 8,
     E'Problem List:\n1. Essential hypertension (I10), controlled\n\nGoals:\n- Maintain BP < 130/80 mmHg\n\nPharmacist Interventions:\n- Continue current lisinopril dose\n- Reinforce adherence and lifestyle\n\nMonitoring Plan:\n- BP check every 3 months\n- Annual renal function');
