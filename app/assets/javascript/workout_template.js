function initTemplateFeature() {
  console.log("データベース連動版起動"); 

  const templateSelect = document.getElementById("template_select");
  const menuSelect = document.getElementById("workout_form_menu_type");

  if (!templateSelect || !menuSelect) return;

  templateSelect.removeEventListener("change", handleTemplateChange);
  templateSelect.addEventListener("change", handleTemplateChange);
}

function handleTemplateChange(e) {
  const templateSelect = document.getElementById("template_select");
  const menuSelect = document.getElementById("workout_form_menu_type");
  
  // 選ばれた選択肢（optionタグ）のそのものをピンポイントで取得
  const selectedOption = templateSelect.options[templateSelect.selectedIndex];
  const selectedId = selectedOption.value;

  if (!selectedId) {
    menuSelect.selectedIndex = 0;
    menuSelect.dispatchEvent(new Event('change', { bubbles: true }));
    return;
  }

  // HTMLの「data-sets」に埋め込まれとる本物のデータを解凍して取得する
  const rawSetsData = selectedOption.dataset.sets;
  if (!rawSetsData) return;

  // JSONの文字を、JavaScriptがすぐ使える「配列とオブジェクト」に変換
  const sets = JSON.parse(rawSetsData);
  if (sets.length === 0) {
    console.log("このテンプレートにはセットが登録されていません");
    return;
  }

  // 1セット目のデータから、種目名（menu_type）を取得する
  const targetMenuName = sets[0].menu;

  // 【1】種目名を強制切り替え
  let targetIndex = 0;
  for (let i = 0; i < menuSelect.options.length; i++) {
    if (menuSelect.options[i].value === targetMenuName) {
      targetIndex = i;
      break;
    }
  }
  menuSelect.selectedIndex = targetIndex;
  menuSelect.dispatchEvent(new Event('change', { bubbles: true }));

  // 【2】枠の数を本物のセット数と完全に一致させる
  const addSetBtn = document.getElementById("add-set-btn");
  const targetSetCount = sets.length; // 本物のセット数（3セットだったり2セットだったり）

  let currentSetRows = document.querySelectorAll("#sets-container .set-row");

  // 足りなければ増やす
  while (currentSetRows.length < targetSetCount && addSetBtn) {
    addSetBtn.click();
    currentSetRows = document.querySelectorAll("#sets-container .set-row");
  }

  // 多すぎれば減らす
  while (currentSetRows.length > targetSetCount) {
    const lastRow = currentSetRows[currentSetRows.length - 1];
    const deleteBtn = lastRow.querySelector(".delete-set-btn");
    if (deleteBtn) {
      deleteBtn.click();
    } else {
      break;
    }
    currentSetRows = document.querySelectorAll("#sets-container .set-row");
  }

  // 【3】本物のデータを流し込む
  function fillFormSets() {
    const finalSetRows = document.querySelectorAll("#sets-container .set-row");
    
    if (finalSetRows.length !== targetSetCount) {
      setTimeout(fillFormSets, 10);
      return;
    }

    // データベースから降ってきた本物の重量と回数をループで流し込む
    sets.forEach((setData, index) => {
      const row = finalSetRows[index];
      if (row) {
        const weightInput = row.querySelector(`input[name*="[sets_attributes][${index}][weight]"]`) || row.querySelector('input[name*="[weight]"]');
        const repsInput = row.querySelector(`input[name*="[sets_attributes][${index}][reps]"]`) || row.querySelector('input[name*="[reps]"]');

        if (weightInput) weightInput.value = setData.weight;
        if (repsInput) repsInput.value = setData.reps;
      }
    });
    console.log("データベースの値を自動入力しました");
  }

  setTimeout(fillFormSets, 30);
}

document.addEventListener("turbo:load", initTemplateFeature);
document.addEventListener("turbo:render", initTemplateFeature);
document.addEventListener("DOMContentLoaded", initTemplateFeature);
initTemplateFeature();



function initNewTemplateFeature() {
  const addBtn = document.getElementById("add-template-set-btn");
  const container = document.getElementById("template-sets-container");

  if (!addBtn || !container) return;

  console.log("テンプレート作成用JS・起動！");

  addBtn.removeEventListener("click", handleAddTemplateSet);
  addBtn.addEventListener("click", handleAddTemplateSet);

  container.removeEventListener("click", handleDeleteTemplateSet);
  container.addEventListener("click", handleDeleteTemplateSet);
}

function handleAddTemplateSet() {
  const container = document.getElementById("template-sets-container");
  const rows = container.querySelectorAll(".template-set-row");
  const nextIndex = rows.length;

  const newRow = rows[0].cloneNode(true);
  newRow.setAttribute("data-set-index", nextIndex);
  
  const label = newRow.querySelector(".template-set-label");
  if (label) label.textContent = `${nextIndex + 1}セット目`;

  const inputs = newRow.querySelectorAll("input");
  inputs.forEach(input => {
    if (input.name) {
      input.name = input.name.replace(/\[\d+\]/, `[${nextIndex}]`);
    }
    if (input.classList.contains("template-step-input")) {
      input.value = nextIndex + 1;
    } else {
      input.value = "";
    }
  });

  const deleteBtn = newRow.querySelector(".delete-template-set-btn");
  if (deleteBtn) deleteBtn.classList.remove("hidden");

  container.appendChild(newRow);
}

function handleDeleteTemplateSet(e) {
  if (!e.target.classList.contains("delete-template-set-btn")) return;

  const row = e.target.closest(".template-set-row");
  if (row) {
    row.remove();
    reindexTemplateSets();
  }
}

function reindexTemplateSets() {
  const container = document.getElementById("template-sets-container");
  const rows = container.querySelectorAll(".template-set-row");

  rows.forEach((row, index) => {
    row.setAttribute("data-set-index", index);
    const label = row.querySelector(".template-set-label");
    if (label) label.textContent = `${index + 1}セット目`;

    const inputs = row.querySelectorAll("input");
    inputs.forEach(input => {
      if (input.name) {
        input.name = input.name.replace(/\[\d+\]/, `[${index}]`);
      }
      if (input.classList.contains("template-step-input")) {
        input.value = index + 1;
      }
    });
  });
}

// 元々あるイベントリスナーの中に、今回の関数も一緒に入れておく
document.addEventListener("turbo:load", () => {
  initTemplateFeature();    // 元々の自動入力用
  initNewTemplateFeature(); // 今回の作成画面用
});
document.addEventListener("turbo:render", () => {
  initTemplateFeature();
  initNewTemplateFeature(); // ここにも追加
});
document.addEventListener("DOMContentLoaded", () => {
  initTemplateFeature();
  initNewTemplateFeature(); // ここにも追加
});