# Docly — Application Mobile

> Application mobile de prise de rendez-vous médicaux en Tunisie.
> Développée avec Flutter pour montrer ma polyvalence technique.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-43853D?style=flat&logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=flat&logo=mongodb&logoColor=white)

## Aperçu

Docly est une application complète de gestion de rendez-vous médicaux
pensée pour le marché tunisien. Elle propose deux interfaces distinctes :
une pour les patients et une pour les médecins.

## Stack technique

- **Mobile** : Flutter + Dart
- **State management** : Provider
- **Navigation** : Go Router
- **HTTP** : Dio
- **Stockage local** : Shared Preferences
- **Backend** : Node.js + Express + MongoDB Atlas
- **Notifications** : Firebase Cloud Messaging

## Fonctionnalités

### Côté Patient
- Inscription et connexion sécurisée
- Recherche de médecins par spécialité ou ville
- Consultation des fiches médecins avec avis
- Réservation de créneaux en temps réel
- Gestion de ses rendez-vous (confirmer, annuler)
- Système d'avis avec étoiles et commentaires
- Notifications push pour les rappels

### Côté Médecin
- Dashboard avec statistiques du jour
- Gestion du planning sur 14 jours
- Confirmation ou annulation des rendez-vous
- Réception de notifications pour chaque réservation

## Installation
```bash
git clone https://github.com/TON_USERNAME/docly-mobile.git
cd docly-mobile
flutter pub get
flutter run
```

Configure l'URL du backend dans `lib/services/api_service.dart` :
```dart
static const String baseUrl = 'https://docly-backend.onrender.com/api';
```

## Structure du projet
```
lib/
├── main.dart
├── theme/          # Thème et couleurs
├── models/         # User, Doctor, Appointment, Review
├── services/       # API, Auth, Storage
├── screens/
│   ├── auth/       # Login, Register
│   ├── patient/    # Home, Doctors, Detail, RDV, Review
│   └── doctor/     # Dashboard, Planning
└── widgets/        # Composants réutilisables
```

## Backend

Repo backend : [docly-backend](https://github.com/TON_USERNAME/docly-backend)

---

Développé par **Rania** — Développeuse React Native • Flutter • Node.js

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://linkedin.com/in/TON_PROFIL)
