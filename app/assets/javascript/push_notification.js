const initPushNotification = () => {
  const pushBtn = document.getElementById('push-btn');
  
  if (!pushBtn) {
    console.log("画面の中に 'push-btn' というIDのボタンが見つかりません。");
    return;
  }

  console.log("ボタンを発見したため、クリックイベントを設定しました。");

  const urlBase64ToUint8Array = (base64String) => {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/');
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  };

  pushBtn.addEventListener('click', async () => {
    console.log("プッシュ通知のJSが実行されました。");

    try {
      // 新しく作った service-worker.js をブラウザに登録
      await navigator.serviceWorker.register('/service-worker.js');
      const registration = await navigator.serviceWorker.ready;
      
      const vapidPublicKey = document.querySelector('meta[name="vapid-public-key"]').content;
      const convertedVapidKey = urlBase64ToUint8Array(vapidPublicKey);

      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: convertedVapidKey
      });

      await fetch('/notification_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify(subscription.toJSON())
      });

      alert("通知の設定が完了しました。");
    } catch (error) {
      console.error("通知の設定に失敗しました:", error);
      alert("通知の許可がブロックされているか、エラーが発生しました。");
    }
  });
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initPushNotification);
} else {
  initPushNotification();
}
document.addEventListener("turbo:load", initPushNotification);