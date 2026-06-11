// document ＝ 画面（設計図）全体のこと。公式オブジェクト名。
// addEventListener ＝ 「〜というイベントが起きたら、教えてね」という、公式の合言葉
// DOMContentLoaded ＝ 「HTMLが全部無事に読み込み終わったぞ！」という、公式の合言葉
// javascriptがどこに書かれていても絶対にhtmlより先に読み込まないように、この一行を書いておく。（htmlより先に読み込まれるとバグる）
document.addEventListener("DOMContentLoaded", () => {

  // htmlから筋トレセット入力欄を探してくる
  const setsContainer = document.getElementById("sets-container");

  // htmlから筋トレセット追加ボタンを探してくる
  const addSetBtn = document.getElementById("add-set-btn");

  const timerBox = document.getElementById("interval-timer-box");
  const timerDisplay = document.getElementById("timer-display");

  // htmlからストップボタンを探してくる
  const stopButton = document.getElementById("stop-timer-btn");

  // htmlからtimer-sub-message（次のセットまでしっかり休もう！）を探してくる
  const timerSubMessage = document.getElementById("timer-sub-message");

  // htmlから休憩時間を入力する「分・秒」の欄を探してくる
  const timerMinInput = document.getElementById("timer-min");
  const timerSecInput = document.getElementById("timer-sec");

  // 1秒ごと時間を減らすメソッドの識別変数。中身がnullの時のみ動かすようにしないと、例えば2回スタートを押した場合、1秒で2秒も進んでしまうタイマーになってしまう。
  let countdown = null;
  // 残り時間。
  let timeLeft = 0;

  // 秒を『分：秒』に計算して表示するメソッド。Stringは文字に変換。Math.floorは小数点切り捨て。
  // padStart(2, "0") ＝ 2桁ないなら0で桁を埋める（1:05を、01:05に）。Start（頭）に0をpad（埋める）
  const formatTime = (seconds) => {
    const min = String(Math.floor(seconds / 60)).padStart(2, "0");
    const sec = String(seconds % 60).padStart(2, "0");
    return `${min}:${sec}`;
  };

  // 入力欄（Input）から秒数を計算して取得。
  // 画面から持ってきた時点では、数字の「5」じゃなくて、ただの文字としての「"5"」。
  // だから、parseInt（パースイント）で『計算ができる整数の数字』に変換させる。parseIntは公式のメソッド。
  // 「|| 0」は、もし中身が空っぽだったら代わりに「0」にするエラー防止。||の左が無効なら、||の右を使ってくれる。
  const getSecondsFromInput = () => {
    const min = parseInt(timerMinInput.value) || 0;
    const sec = parseInt(timerSecInput.value) || 0;
    return (min * 60) + sec;
  };

  // ページが開いた瞬間に、入力欄（Input）から秒数を取得し、隠れている裏タイマーのデータと表示に同期させる
  // これをしないと、タイマーが出現したその一瞬（0.001秒）だけ、画面に 05:00 っていう文字がチラッと見えてから、慌てて 02:00 にパチッと切り替わるというような、「表示のチラつきバグ」が起きる。
  timeLeft = getSecondsFromInput();
  // timerディスプレイの中身（content）を、上で作ったformatTimeメソッドで秒数にして取得。
  timerDisplay.textContent = formatTime(timeLeft);

  // タイマーを途中で強制終了させて、画面から隠す。
  const stopTimer = () => {
    // clearInterval（公式メソッド）で、動いているタイマーを強制停止
    clearInterval(countdown);
    // タイマーが「自然に0秒で終わったとき」のリセット。停止してもまだ時間のデータは残っているので、nullで空っぽに戻す。
    countdown = null;
    // HTMLのクラスに、「hidden（隠すという名前のTailwind CSSのクラス）を新しく追加（add）
    timerBox.classList.add("hidden");
    // タイマーが止まったのでストップボタンも隠す
    stopButton.classList.add("hidden");
  };
  // stopButtonに対して、clickしたら、上で作ったstopTimerメソッドを発動
  stopButton.addEventListener("click", stopTimer);

  // ユーザーがタイマーの数字を書き換えたら、リアルタイムでタイマーの見た目に反映する
  const updateDisplayFromInput = () => {
    if (!countdown) { //もしcountdownに中身がなかった場合（null）=タイマーが止まっている時のみ、表示を変更する
      timeLeft = getSecondsFromInput(); //Inputから残り時間を取得
      // 画面の中身を、上で作ったformatTimeメソッドで『分：秒』にして表示する。
      timerDisplay.textContent = formatTime(timeLeft);
    }
  };
  // イベントリスナー（見張り番）。「分・秒」の欄が書き換えられたら（inputされたら）、上のメソッドが発動し、画面の表示が変わる（NEXT SETの画面のとき）
  timerMinInput.addEventListener("input", updateDisplayFromInput);
  timerSecInput.addEventListener("input", updateDisplayFromInput);

  const startInterval = (button) => {
    // 押された「完了」ボタンをグレーから鮮やかな緑色に変えて、文字を「✓ セット完了」に書き換え
    button.classList.remove("bg-slate-600", "hover:bg-blue-600");
    button.classList.add("bg-green-600");
    button.textContent = "✓ セット完了";

    // タイマーが「まだ動いている最中に、次のボタンを押されたとき」の強制リセット。
    if (countdown) clearInterval(countdown);

    // 上で作ったメソッドで入力欄から合計の秒数を計算し、残り時間に設定
    timeLeft = getSecondsFromInput();

    // もし残り秒数が0以下なら
    if (timeLeft <= 0) {
        // 画面の表示を書き換える
        timerDisplay.textContent = "インターバルは1秒以上で設定してね！";

        // 隠れているタイマーボックス（hidden）を出現させる
        timerBox.classList.remove("hidden");

        // 次のセットまでしっかり休もう！を消す
        timerSubMessage.classList.add("hidden");

        // ボックスの色をダークレッド（bg-rose-900）に変えて、警告として目立たせる
        timerBox.classList.remove("bg-slate-900", "border-blue-500");
        timerBox.classList.add("bg-rose-900", "border-rose-500");

        const errorAudio = new Audio('/sounds/error.mp3');
        errorAudio.volume = 1.0; // 音量MAX
        errorAudio.play().catch(error => {
          console.log("ブラウザの制限で警告音がブロックされました:", error);
        });

      return; // ここより下に進ませない
    }

    // タイマー開始時に、ボックスの色を通常のネイビー（bg-slate-900）に戻しておく
    timerBox.classList.remove("bg-rose-900", "border-rose-500");
    timerBox.classList.add("bg-slate-900", "border-blue-500");

    // 次のセットまでしっかり休もう！を復活！
    timerSubMessage.classList.remove("hidden");

    // 画面の中身を残り時間に
    timerDisplay.textContent = formatTime(timeLeft);
    // タイマーとストップボタンを表示
    timerBox.classList.remove("hidden");
    stopButton.classList.remove("hidden");

    // タイマーのボタンを押す ▶ setIntervalがその場で識別番号を決めて吐き出す ▶ countdownに出てきた番号を、そのまま書き留める ▶ countdownがnullでなくなるのでタイマーが動く
    countdown = setInterval(() => {
      timeLeft--; // 1秒ずつ減らす
      timerDisplay.textContent = formatTime(timeLeft);

      // もし0秒になったら
      if (timeLeft <= 0) {
        clearInterval(countdown); // タイマーを止めて
        countdown = null; // カウントダウンに入っていた識別番号をnullに戻す（nullでないと再び動かせない）

        // 1.0秒になった瞬間に音を鳴らす（alertがいないので確実に鳴る）
        const audio = new Audio('/sounds/alarm.mp3');
        audio.volume = 1.0;
        audio.play().catch(error => {
          console.log("ブラウザの制限で音がブロックされました:", error);
        });

        // 文字を大きく「NEXT SET!」に変える
        timerDisplay.textContent = "🔥 NEXT SET!";

        // ボックスの色をエメラルドグリーンに変える
        timerBox.classList.remove("bg-slate-900", "border-blue-500", "bg-rose-900", "border-rose-500");
        timerBox.classList.add("bg-emerald-600", "border-emerald-400");

        // タイマーが止まったのでストップボタンを消す
        stopButton.classList.add("hidden");
      }
    }, 1000);
  };

  setsContainer.addEventListener("click", (e) => {
    if (e.target.classList.contains("set-done-btn")) {
      startInterval(e.target);
    }
  });

  addSetBtn.addEventListener("click", () => {
    const currentSets = setsContainer.querySelectorAll(".set-row").length;
    const newSetHtml = `
        <div class="set-row flex flex-col bg-slate-50 p-3 rounded border border-slate-200 space-y-2" data-set-index="${currentSets}">
          <div class="flex items-center space-x-3">
            <span class="set-label font-bold text-slate-500 w-16">${currentSets + 1}セット</span>
            <div class="flex-1 flex items-center space-x-2">
              <input type="number" name="workout_form[sets_attributes][${currentSets}][weight]" step="0.1" placeholder="重量(kg)" class="border border-slate-300 rounded px-3 py-2 font-bold focus:outline-none focus:ring-2 focus:ring-blue-500 w-full bg-white text-center">
              <span class="text-slate-400 text-sm">kg</span>
              <input type="number" name="workout_form[sets_attributes][${currentSets}][reps]" placeholder="回数" class="border border-slate-300 rounded px-3 py-2 font-bold focus:outline-none focus:ring-2 focus:ring-blue-500 w-full bg-white text-center">
              <span class="text-slate-400 text-sm">回</span>
            </div>
          </div>
          <div class="text-right">
            <button type="button" class="set-done-btn bg-slate-600 hover:bg-blue-600 text-white text-xs font-bold py-1 px-3 rounded transition-colors duration-200">
              完了（インターバル開始）
            </button>
          </div>
        </div>
      `;
    setsContainer.insertAdjacentHTML("beforeend", newSetHtml);
  });
});