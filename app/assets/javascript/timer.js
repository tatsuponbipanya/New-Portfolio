  // document ＝ 画面（設計図）全体のこと。公式オブジェクト名。
  // addEventListener ＝ 「〜というイベントが起きたら、教えてね」という、公式の合言葉
  // DOMContentLoaded ＝ 「HTMLが全部無事に読み込み終わったぞ！」という、公式の合言葉
  // スクリプトがどこに書かれていても絶対にhtmlより先に読み込まないように、この一行を書いておく。（htmlより先に読み込まれるとバグる）
  document.addEventListener("DOMContentLoaded", () => {

    // セット入力欄を探してくる
    const setsContainer = document.getElementById("sets-container");

    // セット追加ボタンを探してくる
    const addSetBtn = document.getElementById("add-set-btn");

    const timerBox = document.getElementById("interval-timer-box");
    const timerDisplay = document.getElementById("timer-display");

    // ストップボタンを探してくる
    const stopButton = document.getElementById("stop-timer-btn");
    
    // 休憩時間を入力する「分・秒」の欄を探してくる
    const timerMinInput = document.getElementById("timer-min");
    const timerSecInput = document.getElementById("timer-sec");

    let countdown = null;
    let timeLeft = 0;

    const formatTime = (seconds) => {
      const min = String(Math.floor(seconds / 60)).padStart(2, "0");
      const sec = String(seconds % 60).padStart(2, "0");
      return `${min}:${sec}`;
    };

    const getSecondsFromInput = () => {
      const min = parseInt(timerMinInput.value) || 0;
      const sec = parseInt(timerSecInput.value) || 0;
      return (min * 60) + sec;
    };

    // ページが開いた瞬間に、設定した初期時間（5分）を裏データと表示に同期
    timeLeft = getSecondsFromInput();
    timerDisplay.textContent = formatTime(timeLeft);

    const stopTimer = () => {
      clearInterval(countdown);
      countdown = null;
      timerBox.classList.add("hidden");
    };
    stopButton.addEventListener("click", stopTimer);

    // ユーザーが数字を書き換えたら、リアルタイムでタイマーの見た目に反映する
    const updateDisplayFromInput = () => {
      if (!countdown) {
        timeLeft = getSecondsFromInput();
        timerDisplay.textContent = formatTime(timeLeft);
      }
    };
    timerMinInput.addEventListener("input", updateDisplayFromInput);
    timerSecInput.addEventListener("input", updateDisplayFromInput);

const startInterval = (button) => {
      button.classList.remove("bg-slate-600", "hover:bg-blue-600");
      button.classList.add("bg-green-600");
      button.textContent = "✓ セット完了";

      if (countdown) clearInterval(countdown);

      timeLeft = getSecondsFromInput(); 

      if (timeLeft <= 0) {
        // ここも普通の文字表示とかに変えると親切
        alert("休憩時間が0秒になっています");
        return;
      }

      // タイマー開始時に、ボックスの色を通常のネイビー（bg-slate-900）に戻しておく
      timerBox.classList.remove("bg-rose-900", "border-rose-500");
      timerBox.classList.add("bg-slate-900", "border-blue-500");

      timerDisplay.textContent = formatTime(timeLeft);
      timerBox.classList.remove("hidden");

      countdown = setInterval(() => {
        timeLeft--;
        timerDisplay.textContent = formatTime(timeLeft);

        if (timeLeft <= 0) {
          clearInterval(countdown);
          
          // 1. 0秒になった瞬間に音を鳴らす（alertがいないので確実に鳴る）
          const audio = new Audio('/sounds/alarm.mp3');
          audio.volume = 1.0;
          audio.play().catch(error => {
            console.log("ブラウザの制限で音がブロックされました:", error);
          });

          // 2. alertの代わりに、画面の見た目をハデに変えて通知する
          // 文字を大きく「NEXT SET!」に変える
          timerDisplay.textContent = "🔥 NEXT SET!"; 
          
          // ボックスの色をダークレッド（bg-rose-900）に変えて、終了したことを目立たせる
          timerBox.classList.remove("bg-slate-900", "border-blue-500");
          timerBox.classList.add("bg-rose-900", "border-rose-500");
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