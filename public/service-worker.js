// Railsからプッシュ通知（電波）が届いた瞬間に勝手に動くイベント
self.addEventListener('push', (event) => {
  console.log('Railsからのプッシュ通知の電波をキャッチ');

  let data = { title: '通知だよ！', body: '中身が空っぽ' };

  // Railsから送られてきたJSONデータを解読する
  if (event.data) {
    try {
      data = event.data.json();
    } catch (e) {
      // もしJSONじゃなくて普通のテキストで届いた場合の安全弁
      data = { title: '通知だよ！', body: event.data.text() };
    }
  }

  // 画面に通知を表示する命令
  const options = {
    body: data.body,
    icon: '/icon.png', // もしアイコン画像があれば表示される
    badge: '/badge.png'
  };

  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});