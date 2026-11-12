# Contexte du Projet : Saken (Gestion de Résidence Unique)

## 1. Description Générale
Application de gestion des cotisations pour une SEULE résidence (pas de multi-tenant). 
Le projet contient un CMS (interface Web pour le responsable) intégré dans le backend, et expose une API REST pour une application mobile Flutter (utilisée par les résidents).

## 2. Stack Technique
*   **Framework :** Laravel (PHP)
*   **Base de données :** SQLite (pour la simplicité de l'environnement de développement)
*   **Authentification CMS (Web) :** Laravel Breeze (Blade/Tailwind)
*   **Authentification API (Mobile) :** Laravel Sanctum (Tokens)

## 3. Architecture & Standards de Code (Règles strictes)
Pour garder un code lisible, efficace et robuste sans sur-ingénierie :
*   **Séparation des couches :**
    *   **Endpoints (Controllers) :** Très fins. Ils reçoivent la requête HTTP, appellent le Service, et retournent la vue (Web) ou une API Resource JSON (API).
    *   **Services (Business Logic) :** Contiennent toute la logique métier (ex: calcul du reste à payer, enregistrement d'un paiement partiel).
    *   **Repositories (Data Access) :** Contiennent les requêtes Eloquent (Base de données). Le Service appelle le Repository. Pas de requêtes DB directes dans les Controllers.
*   **Simplicité :** Utiliser des classes PHP simples pour les Services et Repositories. Ne pas créer d'Interfaces complexes (Binding) sauf si strictement nécessaire. Utiliser les fonctionnalités natives de Laravel (Form Requests, API Resources, Eloquent Mutators).

## 4. Modèle de Données Simplifié (MVP)
*   **User :** Admin/Responsable (accès Web) et Résidents (accès Mobile via API).
*   **Apartment :** `id`, `number`, `resident_id` (FK vers User).
*   **Contribution :** `id`, `title`, `amount_per_apartment`, `status` (active, closed). (La cotisation globale).
*   **Payment :** `id`, `apartment_id`, `contribution_id`, `amount_paid`, `date`. (Les versements réels).

## 5. Logique Métier Clé
Le "reste à payer" par appartement pour une cotisation n'est pas stocké en dur, il est calculé dynamiquement par un Service en faisant : `Contribution->amount_per_apartment - SUM(Payments->amount_paid)`.
