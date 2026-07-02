function initTemplateFeature() {
    console.log("データベース連動版起動");

    // htmlからテンプレートと種目名のプルダウンをゲットしてくる。
    const templateSelect = document.getElementById("template_select");
    const menuSelect = document.getElementById("workout_form_menu_type");

    // もしそれらがなかったら処理を終了。
    if (!templateSelect || !menuSelect) return;

    // 古い見張り番をremoveしてから見張りをスタート。プルダウンの中身がchangeされたら、handleTemplateChange関数を実行。
    templateSelect.removeEventListener("change", handleTemplateChange);
    templateSelect.addEventListener("change", handleTemplateChange);
}

// 起きたイベント（クリックされた、など）の中身の情報が必要な時は、イベント (e) を受け取る必要がある。
// 逆に、「何が起きたかのデータはどうでもいいから、とにかくイベントが起きたらこの処理をして！」という、合図だけで完結する時は () で良い。
// 今回は「ユーザーが今、何番目の選択肢を選んだか」という【中身の情報】が必要。
function handleTemplateChange(e) {
    // htmlから選ばれたテンプレートを取得。menuSelectは種目名。
    const templateSelect = document.getElementById("template_select");
    const menuSelect = document.getElementById("workout_form_menu_type");

    // hiddenフィールドとチェックボックスのラッパーを取得
    const templateIdField = document.getElementById("workout_form_template_id");
    const updateCheckboxWrapper = document.getElementById("update-template-checkbox-wrapper");
    const updateCheckbox = document.getElementById("update_template_checkbox");

    // テンプレートの選択肢（optionタグ）のリストから、何番のoptionを選んだか取得
    const selectedOption = templateSelect.options[templateSelect.selectedIndex];
    // そのoptionの中身（ID番号）を取得
    const selectedId = selectedOption.value;

    // もし選んだテンプレートのIDが空（ーーテンプレートを選択ーー　のところ）だったら、
    if (!selectedId) {
        // 種目名も一番上の「種目を選択（IndexID=0）」に戻し、
        menuSelect.selectedIndex = 0;
        // dispatchEventで手動イベントを発生させることで、他のセット入力欄を消すプログラムなどが同時に発動できるよう、通知を飛ばす。
        // また、{ bubbles: true } を設定することでhtml全体にイベントが届くようになり、他のセット入力欄を消すプログラムなどと連動できる。
        menuSelect.dispatchEvent(new Event('change', { bubbles: true }));
        // テンプレート未選択に戻したら、hiddenをクリアしてチェックボックスも隠す
        if (templateIdField) templateIdField.value = "";
        if (updateCheckboxWrapper) updateCheckboxWrapper.classList.add("hidden");
        if (updateCheckbox) updateCheckbox.checked = false;
        return;
    }

    // テンプレートを選んだら、IDをhiddenに入れてチェックボックスを表示
    if (templateIdField) templateIdField.value = selectedId;
    if (updateCheckboxWrapper) updateCheckboxWrapper.classList.remove("hidden");

    // 選んだテンプレート（HTMLの「data-sets」）に埋め込まれているデータを取得。
    const rawSetsData = selectedOption.dataset.sets;
    // バグ防止。data-setsが空や、壊れている場合はここで処理終了。
    if (!rawSetsData) return;

    // ただの文字データだったrawSetsDataを、JavaScriptがすぐ使える「配列とオブジェクト（ハッシュ）」の形に変換。
    const sets = JSON.parse(rawSetsData);
    // 名前だけ入っていて、セットが1個もないデータがあれば弾く。
    if (sets.length === 0) {
        console.log("このテンプレートにはセットが登録されていません");
        return;
    }

    // 【1】種目名の切り替え

    // さっき作った配列setsの0番目のデータのmenu（種目名（menu_type）を取得する。
    const targetMenuName = sets[0].menu;

    // まず、見つけたい番号を覚えておくための箱（targetIndex）を 0 で用意する。
    let targetIndex = 0;
    // for文で種目名プルダウンの中身を1個ずつ確認し、さっき取り出した種目名（targetMenuName）と完全に一致する選択肢を見つけ出す。番号はそのままtargetIndexで保管。
    for (let i = 0; i < menuSelect.options.length; i++) {
        if (menuSelect.options[i].value === targetMenuName) {
            targetIndex = i;
            // 見つかったらbreakで処理終了。
            break;
        }
    }
    // プルダウンの種目名を、今取ってきた番号（targetIndex）で取得。これでブラウザの種目名の表示が切り替わる。
    menuSelect.selectedIndex = targetIndex;
    // さっきと同様に手動イベントを発生させ、他のセット数表示などのプログラムと連動させる。
    menuSelect.dispatchEvent(new Event('change', { bubbles: true }));

    // 【2】セット数の切り替え

    // セット追加ボタンをhtmlから取ってくる。
    const addSetBtn = document.getElementById("add-set-btn");
    // さっき取ってきたセット数（sets）を目標に設定。
    const targetSetCount = sets.length;
    // 今画面にあるセット数（set-row）を数えて取得する。
    let currentSetRows = document.querySelectorAll("#sets-container .set-row");

    // 今のセット数の表示が目標の数になるまで、セット追加ボタンをクリックする。
    // if addSetBtnで「追加ボタンが存在する時」という条件を追加しているのは、追加ボタンの存在しない別のページに遷移した時に、このプログラムが実行されてバグるのを防ぐため。
    // 普通じゃあり得ないタイミングでボタンが一瞬だけ「画面から消える（見つからない）」というバグが、Railsの開発ではよく起きる。
    if (addSetBtn) {
        while (currentSetRows.length < targetSetCount) {
            addSetBtn.click();
            currentSetRows = document.querySelectorAll("#sets-container .set-row");
        }
    }

    // 今のセット数の表示が目標の数になるまで、削除ボタンをクリックする。こちらはbreakの処理が必要なため、whileの中にif文を書いている。
    while (currentSetRows.length > targetSetCount) {
        // 一番最後のセットを取得
        const lastRow = currentSetRows[currentSetRows.length - 1];
        // 特定した最後のセットの削除ボタンを取得
        const deleteBtn = lastRow.querySelector(".delete-set-btn");
        // 1セット目には削除ボタンがないので、ない場合の処理も書いてバグ回避。
        if (deleteBtn) {
            deleteBtn.click();
        } else {
            break;
        }
        currentSetRows = document.querySelectorAll("#sets-container .set-row");
    }

    // 【3】重量・repsなどのデータを流し込む
    function fillFormSets() {
        // セット数の最後の行を取得。
        const finalSetRows = document.querySelectorAll("#sets-container .set-row");

        // まだ目標のセット数（targetSetCount）に届いてない場合、0.01秒だけ待つ（htmlの画面工事が終わるまで）。
        if (finalSetRows.length !== targetSetCount) {
            setTimeout(fillFormSets, 10);
            return;
        }

        // 取得した重量・repsをforEachループ（データの数だけループ）で流し込む
        // setData=中身。重量・repsのデータ。　引数の2番目に書かれた文字（index）には、自動で番号が入る。1周目は0、2周目は1といった感じで。
        sets.forEach((setData, index) => {
            const row = finalSetRows[index];
            // ここも本来であればforEachなのでデータ（row）がないのにループが回っているということはありえないが、htmlの工事が遅れていた時のバグ回避。
            if (row) {
                // その行（row）の中にある「すべてのinputタグ」を集める。
                const inputs = row.querySelectorAll("input");

                // 1番目の入力欄（[0]番目）が重量、2番目の入力欄（[1]番目）がreps（回数）
                const weightInput = inputs[0];
                const repsInput = inputs[1];

                // 画面の重量・repsをその値に変える。
                if (weightInput) weightInput.value = setData.weight;
                if (repsInput) repsInput.value = setData.reps;
            }
        });
        console.log("データベースの値を自動入力しました");
    }

    // 追加ボタンを自動連打して枠を増やした直後は、ブラウザが画面に新しい入力欄（HTML）を描き終えるまでに、ほんのわずかな時間差（ミリ秒）が発生する。
    // そのため、0.03秒のウェイト（待ち時間）を入れて、ブラウザの画面工事がちゃんと終わったのを見計らってからデータを流し込む。
    setTimeout(fillFormSets, 30);
}

function initNewTemplateFeature() {
    // セット追加ボタンとコンテナを取得。
    const addBtn = document.getElementById("add-template-set-btn");
    const container = document.getElementById("template-sets-container");

    // この画面にセット追加ボタンやコンテナがなければ、処理を終了。
    if (!addBtn || !container) return;

    // このJavaScriptファイルが、画面に読み込まれているかどうかのチェック用。ブラウザからの検証。
    console.log("テンプレート作成用JS・起動！");

    // セット追加ボタンがTurboのせいで残っていた時のために、一回リセットしてから追加する。こっちはコンテナ（枠）の外にあるし、1個しかないので、直接addBtnを指定する方が早いし処理も軽い。
    addBtn.removeEventListener("click", handleAddTemplateSet);
    addBtn.addEventListener("click", handleAddTemplateSet);
    // テンプレート削除ボタンがTurboのせいで残っていた時のために、一回リセットしてから追加する。こっちはコンテナ（枠）の中にあり、無限に増えるので、1つずつボタンを見張らせると重くなるため、コンテナ本体で見張らせる。
    container.removeEventListener("click", handleDeleteTemplateSet);
    container.addEventListener("click", handleDeleteTemplateSet);
}

function handleAddTemplateSet() {
    // テンプレートのコンテナ、行、行の数をhtmlから取得
    const container = document.getElementById("template-sets-container");
    const rows = container.querySelectorAll(".template-set-row");
    const nextIndex = rows.length;

    // 最初の行のhtmlをクローン（コピー）して、新しい列を作る。
    const newRow = rows[0].cloneNode(true);
    // ID（data-set-index）と、nextindex番目の行、という情報を付与。
    newRow.setAttribute("data-set-index", nextIndex);

    // ◯セット目　という表示を+1する。
    const label = newRow.querySelector(".template-set-label");
    if (label) label.textContent = `${nextIndex + 1}セット目`;

    // 入力欄（input）のデータを全て取得。
    const inputs = newRow.querySelectorAll("input");
    // forEachでデータの数だけ以下の処理を行う。その1個1個のデータをinputと呼ぶことにする。
    inputs.forEach(input => {
        // サーバーにおくる名前（例えば set[0][weight] とか）の数字の部分を、新しい番号（set[1][weight] とか）に置き換える。
        if (input.name) {
            // /\[\d+\]/ = 正規表現。　[◯] = ◯を探す。　\d+ = 1文字以上の数字（0から9）。　/◯/ = 範囲指定。
            // \ = あとに続く記号の特別な意味を無くして、ただの文字（デザイン）として扱う。　\[ = 命令じゃなくて、キーボードの「 [ という文字そのもの」。
            input.name = input.name.replace(/\[\d+\]/, `[${nextIndex}]`);
        }
        // ◯セット目　というデータだったら、+1する。
        if (input.classList.contains("template-step-input")) {
            input.value = nextIndex + 1;
        // 重量やrepsのデータだったら、空にする。
        } else {
            input.value = "";
        }
    });

    // 削除ボタンを取得し、hiddenを解除する。
    const deleteBtn = newRow.querySelector(".delete-template-set-btn");
    if (deleteBtn) deleteBtn.classList.remove("hidden");
    // テンプレートコンテナの最後に、新しい列をつなげる。appendChild（アップチャイルド）＝「指定した箱の一番最後に、新しい要素を追加する」
    container.appendChild(newRow);
}

// initNewTemplateFeature関数内で発動。クリックされたボタンがどれなのか（e.target）という【中身の情報】を使うため、e（イベント引数）を受け取る必要がある。
function handleDeleteTemplateSet(e) {
    // クリックされた要素（e.target）が削除ボタンでなければ、無視。
    if (!e.target.classList.contains("delete-template-set-btn")) return;

    // クリックされた削除ボタンの、一番近い（closest）セットの行を取得。
    const row = e.target.closest(".template-set-row");
    // ifはhtmlの工事遅れなど、バグ防止用。セットの行を削除し、reindexTemplateSets関数を発動（セット数の表記を正しい数字に直す）。
    if (row) {
        row.remove();
        reindexTemplateSets();
    }
}

function reindexTemplateSets() {
    // 今あるセットのコンテナと行を取得。
    const container = document.getElementById("template-sets-container");
    const rows = container.querySelectorAll(".template-set-row");

    // 行とセット数を、順番に数え直して正しい数字にする。
    rows.forEach((row, index) => {
        row.setAttribute("data-set-index", index);
        const label = row.querySelector(".template-set-label");
        if (label) label.textContent = `${index + 1}セット目`;

        // 入力欄の名前と数字も、正しい数字に直す。
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

// 以下はどんな形で画面が表示されても、全ての場合で絶対にテンプレート作成のJavaScriptを起動させますよという意図。
// 【1】Turboの画面切り替え時
document.addEventListener("turbo:load", () => {
    initTemplateFeature();
    initNewTemplateFeature();
});
// 【2】Turboが画面を書き換えた直後
document.addEventListener("turbo:render", () => {
    initTemplateFeature();
    initNewTemplateFeature();
});
// 【3】普通の最初の読み込み時
document.addEventListener("DOMContentLoaded", () => {
    initTemplateFeature();
    initNewTemplateFeature();
});
// 【4】ファイルが読み込まれた瞬間、即実行するダメ押し用
initTemplateFeature();
initNewTemplateFeature();