const form = document.querySelector("#care-plan-form");
const submitButton = document.querySelector("#submit-button");
const result = document.querySelector("#result");
const carePlanText = document.querySelector("#care-plan-text");

function setText(selector, value) {
  document.querySelector(selector).textContent = value;
}

form.addEventListener("submit", async (event) => {
  event.preventDefault();

  submitButton.disabled = true;
  submitButton.textContent = "Generating...";

  const formData = new FormData(form);
  const payload = Object.fromEntries(formData.entries());

  const response = await fetch("/api/careplans", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const order = await response.json();

  setText("#result-patient", `${order.patient_first_name} ${order.patient_last_name}`);
  setText("#result-mrn", order.patient_mrn);
  setText("#result-provider", order.provider_name);
  setText("#result-medication", order.medication_name);
  setText("#result-diagnosis", order.primary_diagnosis);
  carePlanText.textContent = order.care_plan;

  result.classList.remove("hidden");
  submitButton.disabled = false;
  submitButton.textContent = "Generate care plan";
});
