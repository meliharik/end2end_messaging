# end2end_messaging

**RSA-encrypted mobile messaging for privacy.** A Flutter chat app where messages are encrypted on the device before they ever touch the network, so the server only ever sees ciphertext.

## Features

- **End-to-end encryption.** RSA key pairs are generated on device. Messages are encrypted with the recipient's public key and can only be decrypted locally.
- **Phone-number auth.** Onboarding with number entry and SMS verification through Firebase Auth.
- **1:1 chats.** Realtime conversations backed by Cloud Firestore.
- **Profiles.** Create and edit a profile, browse people, start a chat.

## Project structure

```
lib/
├── screens/auth/     # onboarding, enter/verify number, profile setup
├── screens/          # chats list, chat screen, chat details, people
├── models/           # user, message
├── services/         # crypto + Firebase plumbing
└── helpers/          # UI utilities
```

## Getting started

```sh
flutter pub get
# add your own Firebase project (flutterfire configure)
flutter run
```

## Stack

Flutter · Firebase Auth · Cloud Firestore · RSA with on-device key generation
