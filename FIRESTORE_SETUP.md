# Firestore Database Setup

Your app is trying to use Firestore, but the database hasn't been created yet. Follow these steps to set it up:

## Steps to Create Firestore Database

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select your project: **masemanager-44c9b**

2. **Create Firestore Database**
   - In the left sidebar, click **"Firestore Database"** (or **"Build" → "Firestore Database"**)
   - Click **"Create database"**

3. **Choose Security Rules**
   - Select **"Start in test mode"** (for development)
   - Click **"Next"**

4. **Choose Location**
   - Select a location closest to your users (e.g., `us-central`, `europe-west`, `asia-southeast1`)
   - Click **"Enable"**

5. **Wait for Creation**
   - The database will be created (takes 1-2 minutes)

## After Setup

Once Firestore is created:
- ✅ User login data will be saved to `users` collection
- ✅ App items will be saved to `items` collection
- ✅ The error will disappear

## Security Rules (Recommended)

After creating the database, update the security rules in Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: users can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Items: authenticated users can read/write
    match /items/{itemId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Click **"Publish"** to save the rules.

## Quick Link

**Direct link to create database:**
https://console.cloud.google.com/datastore/setup?project=masemanager-44c9b

---

**Note:** The app will continue to work for authentication (Google Sign-In, Email/Password) even without Firestore. User data just won't be saved to Firestore until the database is created.
