const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();

/**
 * Triggers when a new job is created in the 'jobs' collection.
 * Sends a notification to all technicians.
 */
exports.sendJobNotification = onDocumentCreated({
  document: "jobs/{jobId}",
  region: "asia-south1",
}, async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    logger.error("No data associated with the event");
    return;
  }

  const jobData = snapshot.data();
  const jobTitle = jobData.title || "New Job";

  const message = {
    notification: {
      title: "RightTouch",
      body: `You got a new job: ${jobTitle}`,
    },
    topic: "technicians",
    data: {
      jobId: event.params.jobId,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
  };

  try {
    const response = await admin.messaging().send(message);
    logger.info("Successfully sent message:", response);
  } catch (error) {
    logger.error("Error sending message:", error);
  }
});
