# Docly — Backend API

> API REST pour l'application mobile de prise de rendez-vous médicaux en Tunisie.

## Stack technique

- **Runtime** : Node.js + Express
- **Base de données** : MongoDB Atlas
- **Authentification** : JWT
- **Notifications** : Firebase Cloud Messaging
- **Hébergement** : Render.com

## Fonctionnalités

- Authentification double rôle (Patient / Médecin)
- Gestion des médecins et spécialités
- Réservation de rendez-vous en temps réel
- Système d'avis et notation
- Notifications push automatiques
- Rappels J-1 et H-1 par cron job

## Installation locale
```bash
git clone https://github.com/TON_USERNAME/docly-backend.git
cd docly-backend
npm install
```

Crée un fichier `.env` :
```env
PORT=5000
MONGO_URI=mongodb+srv://...
JWT_SECRET=ton_secret
```

Lance le serveur :
```bash
npm run dev
```

## Routes API

| Méthode | Route | Description |
|---------|-------|-------------|
| POST | /api/auth/register | Inscription |
| POST | /api/auth/login | Connexion |
| GET | /api/doctors | Liste médecins |
| GET | /api/doctors/:id | Fiche médecin |
| POST | /api/appointments | Réserver RDV |
| GET | /api/appointments/my | Mes RDV |
| POST | /api/reviews | Laisser un avis |

## Démo

API en ligne : `https://docly-backend.onrender.com`

---

Développé par **Rania** — Développeuse Mobile & Web
