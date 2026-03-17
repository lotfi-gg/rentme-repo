const { setGlobalOptions } = require("firebase-functions/v2");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Limite de conteneurs pour éviter les coûts excessifs
setGlobalOptions({ maxInstances: 10 });

/**
 * Fonction planifiée : vérifie toutes les minutes
 * si une voiture louée est arrivée à sa date de fin.
 */
exports.checkExpiredRentals = onSchedule("every 1 minutes", async () => {
  const now = admin.firestore.Timestamp.now();

  try {
    // Récupérer toutes les voitures louées
    const snapshot = await db.collection("cars").where("status", "==", "Rented").get();

    // ⚠️ Utiliser for...of pour bien gérer async/await
    for (const doc of snapshot.docs) {
      const car = doc.data();

      // Vérifier si endTime est dépassé
      if (car.endTime && car.endTime.toMillis() <= now.toMillis()) {
        // Mise à jour dans la collection globale
        await doc.ref.update({
          status: "Available",
          rentedAt: null,
          endTime: null,
        });

        // ✅ Mise à jour aussi dans la sous-collection utilisateur
        if (car.ownerId) {
          await db.collection("users")
            .doc(car.ownerId) // Assure-toi que chaque voiture stocke bien l’uid du propriétaire
            .collection("cars")
            .doc(doc.id)
            .update({
              status: "Available",
              rentedAt: null,
              endTime: null,
            });
            // 🔔 Envoi de notification
const userDoc = await db.collection("users").doc(car.ownerId).get();
const userData = userDoc.data();

if (userData && userData.fcmToken) {
  await admin.messaging().send({
    token: userData.fcmToken,
    notification: {
      title: "Car Available",
      body: `Your car ${car.vehiclefullname} is now available.`,
    },
  });
  console.log(`Notification sent to ${car.ownerId}`);
}

        }

        console.log(`Car ${doc.id} marked as Available`);
      }
    }
  } catch (error) {
    console.error("Error checking expired rentals:", error);
  }
});
