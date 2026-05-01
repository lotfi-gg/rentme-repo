const { setGlobalOptions } = require("firebase-functions/v2");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({ maxInstances: 10 });

/**
 * Scheduled function: runs every minute
 * Checks if a rented car has expired.
 * 👉 Only sends a notification, does NOT change Firestore status.
 */
exports.checkExpiredRentals = onSchedule("every 1 minutes", async () => {
  const now = admin.firestore.Timestamp.now();

  try {
    const snapshot = await db.collection("cars").where("status", "==", "Rented").get();

    for (const doc of snapshot.docs) {
      const car = doc.data();

      if (car.endTime && car.endTime.toMillis() <= now.toMillis()) {
        // 🚫 Removed Firestore update
        // ✅ Only notify the owner

        if (car.ownerId) {
          const userDoc = await db.collection("users").doc(car.ownerId).get();
          const userData = userDoc.data();

          if (userData && userData.fcmToken) {
            await admin.messaging().send({
              token: userData.fcmToken,
              notification: {
                title: "Rental Expired",
                body: `Your car ${car.vehiclefullname} rental has expired.`,
              },
            });
            console.log(`Notification sent to ${car.ownerId}`);
          }
        }

        console.log(`Car ${doc.id} rental expired (status unchanged)`);
      }
    }
  } catch (error) {
    console.error("Error checking expired rentals:", error);
  }
});
