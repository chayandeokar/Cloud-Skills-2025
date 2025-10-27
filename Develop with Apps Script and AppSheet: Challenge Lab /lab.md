## 📋 **Overview**

This lab walks you through creating an **AppSheet** app, adding automation, and building a **Google Chat bot** using **Apps Script**. You will:

- Create and customize an AppSheet app.
- Add an automation feature to the app.
- Build and publish a Google Chat bot using Apps Script.

---

## 🌟 **Task 1: Create and Customize an App**

1. **Log in** to **AppSheet**.
2. Open the [ATM Maintenance App](https://www.appsheet.com/template/AppDef?appName=ATMMaintenance-925818016) in the same **Incognito tab**.
3. From the left navigation menu, click **Copy app**.
4. In the **Copy app** form:
   - Set the **App name** to:
     ```
     ATM Maintenance Tracker
     ```
   - Leave all other settings as their defaults.
5. Click **Copy app**.

---

## ⚙️ **Task 2: Add Automation to an AppSheet App**

1. Navigate to **My Drive** from [here](https://drive.google.com/drive/my-drive).
2. Download the required file from [this link](https://github.com/Itsabhishek7py/GoogleCloudSkillsboost/blob/main/Develop%20with%20Apps%20Script%20and%20AppSheet%3A%20Challenge%20Lab/drabhishek.xlsx)

---

## 💬 **Task 3: Create and Publish an Apps Script Chat Bot**

1. Create a new **Apps Script Chat App** from [here](https://script.google.com/home/projects/create?template=hangoutsChat).
---
| Property | Value |
| :---: | :----: |
| **Project name** | Helper Bot |
---
2. Replace the following code in **Code.gs**:

```javascript
/**
 * Responds to a MESSAGE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onMessage(event) {
  var name = "";

  if (event.space.type == "DM") {
    name = "You";
  } else {
    name = event.user.displayName;
  }
  var message = name + " said \"" + event.message.text + "\"";

  return { "text": message };
}

/**
 * Responds to an ADDED_TO_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onAddToSpace(event) {
  var message = "";

  if (event.space.singleUserBotDm) {
    message = "Thank you for adding me to a DM, " + event.user.displayName + "!";
  } else {
    message = "Thank you for adding me to " +
        (event.space.displayName ? event.space.displayName : "this chat");
  }

  if (event.message) {
    message = message + " and you said: \"" + event.message.text + "\"";
  }
  console.log('Helper Bot added in ', event.space.name);
  return { "text": message };
}

/**
 * Responds to a REMOVED_FROM_SPACE event in Google Chat.
 *
 * @param {Object} event the event object from Google Chat
 */
function onRemoveFromSpace(event) {
  console.info("Bot removed from ",
      (event.space.name ? event.space.name : "this chat"));
}
```

---

## 🔐 **Set Up OAuth Consent Screen**

1. Go to the **OAuth consent screen** from [here](https://console.cloud.google.com/apis/credentials/consent).
2. Fill in the following fields:

| Field | Value |
| :---: | :----: |
| **App name** | Helper Bot |
| **User support email** | Select your email ID from the dropdown |
| **Developer contact information** | Your email address |

---

## 🛠️ **Google Chat API Configuration**

1. Go to the **Google Chat API Configuration** from [here](https://console.cloud.google.com/apis/api/chat.googleapis.com/hangouts-chat).
2. Fill in the following fields:

| Field | Value |
| :---: | :----: |
| **App name** | Helper Bot |
| **Avatar URL** | https://goo.gl/kv2ENA |
| **Description** | Helper chat bot |
| **Functionality** | Select **Receive 1:1 messages and Join spaces and group conversations** |
| **Connection settings** | Check **Apps Script project** and paste the **Head Deployment ID** into the Deployment ID field |
| **Visibility** | Your email address |
| **App Status** | LIVE – Available to users |

---

## 💡 **Testing the Helper Bot**

You can test your **Helper Bot** [here](https://mail.google.com/chat/u/0/#chat/home).

---

## 🎉 **Congratulations**

You have successfully completed the lab and demonstrated your skills in AppSheet and Apps Script!

---
