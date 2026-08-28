// 存储列表数据
const listData = {
    additional_diagnoses: [], // design doc：Additional diagnoses as a list of ICD-10 codes
    medication_history: [] // design doc：Medication history as a list of strings
};

let currentOrderId = null;

function addListItem(type) {
    const input = document.getElementById(`${type}_input`);
    const value = input.value.trim();
    if (value) {
        listData[type].push(value);
        renderList(type);
        input.value = '';
    }
}

function removeListItem(type, index) {
    listData[type].splice(index, 1);
    renderList(type);
}

function renderList(type) {
    const container = document.getElementById(`${type}_list`);
    container.innerHTML = listData[type].map((item, i) =>
        `<span class="list-item">${item}<button type="button" data-type="${type}" data-index="${i}">×</button></span>`
    ).join('');

    // 绑定删除按钮事件
    container.querySelectorAll('button[data-type]').forEach(btn => {
        btn.addEventListener('click', () => {
            removeListItem(btn.dataset.type, parseInt(btn.dataset.index));
        });
    });
}

function downloadCarePlan() {
    if (currentOrderId) {
        window.location.href = `/api/orders/${currentOrderId}/download`;
    }
}

document.addEventListener('DOMContentLoaded', function() {
    // 绑定"Add"按钮
    document.querySelectorAll('.list-input .btn').forEach(btn => {
        btn.addEventListener('click', function() {
            addListItem(this.dataset.add);
        });
    });

    // 绑定下载按钮
    document.getElementById('downloadBtn').addEventListener('click', downloadCarePlan);

    // 绑定表单提交
    document.getElementById('orderForm').addEventListener('submit', async function(e) {
        e.preventDefault();

        const submitBtn = document.getElementById('submitBtn');
        const loading = document.getElementById('loading');
        const result = document.getElementById('carePlanResult');
        const downloadBtn = document.getElementById('downloadBtn');

        // 禁用按钮，显示加载状态
        submitBtn.disabled = true;
        loading.style.display = 'block';
        result.style.display = 'none';
        downloadBtn.style.display = 'none';

        const orderData = {
            patient_first_name: document.getElementById('patient_first_name').value,
            patient_last_name: document.getElementById('patient_last_name').value,
            provider_name: document.getElementById('provider_name').value,
            provider_npi: document.getElementById('provider_npi').value,
            patient_mrn: document.getElementById('patient_mrn').value,
            primary_diagnosis: document.getElementById('primary_diagnosis').value,
            medication_name: document.getElementById('medication_name').value,
            additional_diagnoses: listData.additional_diagnoses,
            medication_history: listData.medication_history,
            patient_records: document.getElementById('patient_records').value
        };

        try {
            const response = await fetch('/api/orders', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(orderData)
            });

            if (!response.ok) {
                throw new Error('Failed to generate care plan');
            }

            const data = await response.json();
            currentOrderId = data.order_id;

            // 显示结果
            result.textContent = data.care_plan;
            result.style.display = 'block';
            downloadBtn.style.display = 'inline-block';

        } catch (error) {
            alert('Error generating care plan: ' + error.message);
        } finally {
            submitBtn.disabled = false;
            loading.style.display = 'none';
        }
    });
});
