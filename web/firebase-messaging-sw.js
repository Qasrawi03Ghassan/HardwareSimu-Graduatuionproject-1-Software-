// Import scripts for firebase messaging
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('/web/firebase-messaging-custom.js');

// Initialize Firebase
firebase.initializeApp({
  apiKey: "AIzaSyDVAWEgpCgOIgbdCi8vovdeL0BV2LyE_uc",
      authDomain: "testfire-b75ce.firebaseapp.com",
      projectId: "testfire-b75ce",
      storageBucket: "testfire-b75ce.firebasestorage.app",
      messagingSenderId: "899180293396",
      appId: "1:899180293396:web:a8210d1fbab99c4bace601",
  vapidKey: "BHjYyLt2_KvhyROh8oWMjrLbH9JT2_qJ5lrjb6uk07FpY58a1WstanrSfFWFkKrac0VyGD8NGT6j7UrdqpbS5oo"
});

// Retrieve firebase messaging
const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    icon: '/icons/icon-192.png',
    body: payload.notification.body,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
