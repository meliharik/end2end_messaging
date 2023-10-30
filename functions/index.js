const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp(functions.config().firebase);

exports.sendMessageNotification = functions.firestore
    .document("chats/{aliciId}/messageTo/{gonderenId}/messages/{message}")
    .onCreate((snap, context) => {
      console.log("----------------start message function--------------------");

      const doc = snap.data();
      console.log(doc);

      const idFrom = doc.senderId;
      const idTo = doc.receiverId;
      const contentMessage = "You have a new message.";

      // const badgeNumber = 1

      const okundu = doc.isRead;
      if (okundu) {
        return null;
      }
      const sendNotification = doc.sendNotification;
      if (!sendNotification) {
        return null;
      }

      // get total unread message count for badge
      // admin
      //   .firestore()
      //   .collection('mesajlar')
      //   .doc(idTo)
      //   .collection('kullanicininMesajlari')
      //   .doc(idFrom)
      //   .collection('mesajlar')
      //   .where('okundu', '==', false)
      //   .get()
      //   .then(querySnapshot => {
      //     const countUnreadMessage = querySnapshot.size
      //     console.log(`Unread message count: ${countUnreadMessage}`)
      //     badgeNumber = countUnreadMessage

      //   })

      // Get push token user to (receive)
      admin
          .firestore()
          .collection("users")
          .where("id", "==", idTo)
          .get()
          .then((querySnapshot) => {
            querySnapshot.forEach((userTo) => {
              console.log(`Found user to: ${userTo.data().adSoyad}`);
              console.log(`Token: ${userTo.data().token}`);
              if (userTo.data().token) {
                // if (userTo.data().token && userTo.data().chattingWith
                // !== idFrom) {

                // Get info user from (sent)
                admin
                    .firestore()
                    .collection("users")
                    .where("id", "==", idFrom)
                    .get()
                    .then((querySnapshot2) => {
                      querySnapshot2.forEach((userFrom) => {
                        console.log(`Found user from: 
                           ${userFrom.data().displayName}`);
                        const payload = {
                          notification: {
                            title: `${userFrom.data().displayName}`,
                            body: contentMessage,
                            // image: userFrom.data().fotoUrl,
                            badge: "1",
                            sound: "default",
                          },
                        };
                        // Let push to the target device
                        admin
                            .messaging()
                            .sendToDevice(userTo.data().token, payload)
                            .then((response) => {
                              console.log("Successfully sent message:",
                                  response);
                            })
                            .catch((error) => {
                              console.log("Error sending message:", error);
                            });
                      });
                    });
              } else {
                console.log("Can not find pushToken target user");
              }
            });
          });
      return null;
    });
