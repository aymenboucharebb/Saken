# Déploiement Saken sur Render (Docker + PostgreSQL)

Ce guide prépare un **premier déploiement temporaire**. Aucune migration ni seeder n’est exécuté automatiquement au démarrage du conteneur.

## Compatibilité PostgreSQL

Les migrations Eloquent du projet sont **compatibles PostgreSQL**.

- Types standards (`string`, `text`, `decimal`, `foreignId`, `timestamps`) : OK.
- `->after('date')` sur `receipt_path` : **ignoré** par le driver PostgreSQL (sans impact schéma).
- Pas de syntaxe SQLite-only dans les migrations applicatives.
- Extensions PHP requises dans l’image : `pdo_pgsql`, `pgsql`.

La base **SQLite locale** (`database/database.sqlite`) n’est pas utilisée sur Render et n’est pas modifiée par ce déploiement.

## Architecture image

| Élément | Détail |
|--------|--------|
| Runtime | PHP **8.3-FPM** + **Nginx** + Supervisor |
| Build | Multi-stage : Node 22 (Vite) → PHP |
| Document root | `/var/www/html/public` uniquement |
| Port | Variable Render `PORT` (défaut 8080) |
| Reçus | Disque **privé** `storage/app/private/receipts/payments` |
| Accès reçus | Routes authentifiées (pas d’URL publique `/storage/...`) |

Fichiers : `Dockerfile`, `docker/nginx.conf`, `docker/entrypoint.sh`, `docker/supervisord.conf`, `docker/php.ini`, `.dockerignore`.

## Variables d’environnement Render

Renseigner dans le dashboard Render (ne jamais committer de secrets) :

| Variable | Valeur attendue |
|----------|-----------------|
| `APP_NAME` | `Saken` |
| `APP_ENV` | `production` |
| `APP_KEY` | `php artisan key:generate --show` → longueur **51** (vérifier `$k.Length` en PowerShell) |
| `APP_DEBUG` | **`false`** |
| `APP_URL` | `https://<service>.onrender.com` (https obligatoire — sinon CSS/JS bloqués) |
| `APP_LOCALE` | `fr` |
| `LOG_LEVEL` | `error` |
| `DB_CONNECTION` | `pgsql` |
| `DB_HOST` | hôte PostgreSQL Render |
| `DB_PORT` | `5432` |
| `DB_DATABASE` | nom de la base |
| `DB_USERNAME` | utilisateur |
| `DB_PASSWORD` | mot de passe |
| `DB_URL` | optionnel (Internal Database URL Render — Laravel lit `DB_URL`, pas `DATABASE_URL`) |
| `ADMIN_EMAIL` | email admin (1er boot) |
| `ADMIN_PASSWORD` | mot de passe admin (retirer après 1er login) |
| `ADMIN_NAME` | optionnel (`Admin`) |
| `SETUP_TOKEN` | secret pour `/api/setup/migrate` (retirer après setup) |
| `SESSION_DRIVER` | `database` |
| `CACHE_STORE` | `database` |
| `QUEUE_CONNECTION` | `database` ou `sync` |
| `FILESYSTEM_DISK` | `local` |

## Étapes manuelles restantes sur Render

1. Créer un **PostgreSQL** managé Render et noter les credentials internes.
2. Créer un **Web Service** type **Docker** pointant vers ce dépôt (racine Laravel).
3. Attacher un **Persistent Disk** monté sur `/var/www/html/storage` (sinon les reçus disparaissent au redeploy).
4. Configurer les variables d’environnement ci-dessus (`APP_DEBUG=false`).
5. (Recommandé 1er login / free sans Shell) ajouter :
   - `ADMIN_EMAIL` = votre email admin
   - `ADMIN_PASSWORD` = mot de passe fort
   - `ADMIN_NAME` = `Admin` (optionnel)
   - `SETUP_TOKEN` = une longue chaîne aléatoire (ex. `openssl rand -hex 16`)
6. Déployer l’image (build Docker automatique).  
   Au boot : attend la DB, `migrate --force` (soft-fail), admin optionnel, puis caches.  
   **Si la table `users` manque encore**, ouvrez **une fois** (avant `/login`) :
   `https://<service>.onrender.com/api/setup/migrate?token=VOTRE_SETUP_TOKEN`  
   Vous devez voir `"ok": true`, `"users_table": true`.  
   **Ne PAS** lancer `db:seed`. Après succès : retirez `ADMIN_PASSWORD` et `SETUP_TOKEN`.
7. Vérifier :

```bash
curl -sS https://<service>.onrender.com/up
curl -sS -X POST https://<service>.onrender.com/api/login \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"email":"...","password":"...","device_name":"test"}'
```

8. CMS : ouvrir `https://<service>.onrender.com/login`.
9. Flutter (plus tard, hors APK pour l’instant) :

```bash
flutter run --dart-define=API_BASE_URL=https://<service>.onrender.com/api
```

## Ce que le conteneur fait / ne fait pas au démarrage

**Fait :**
- Injecte `PORT` dans Nginx
- Crée les dossiers `storage` / `bootstrap/cache` + permissions
- Vérifie que `APP_KEY` est présent et valide (32 octets décodés)
- `config:clear` puis `config:cache` / `route:cache` / `view:cache` (**échoue le boot si cache KO**)
- Attend Postgres (retry), puis `php artisan migrate --force` (soft-fail + fallback HTTP)
- Crée/maj un admin si `ADMIN_EMAIL` + `ADMIN_PASSWORD` sont définis
- PHP-FPM avec `clear_env = no` (les variables Render sont visibles par les workers)
- Démarre php-fpm + nginx
- Fallback : `GET /api/setup/migrate?token=$SETUP_TOKEN` (sans session)

**Ne fait pas :**
- `db:seed` (pas de comptes démo)
- `storage:link` (inutile pour les reçus privés)

### Erreur `Unsupported cipher or incorrect key length` / `MissingAppKeyException`

1. Générez une clé : `php artisan key:generate --show`
2. **Vérifiez la longueur avant de coller sur Render** (obligatoire) :

```powershell
$k = "base64:...."   # collez la clé générée entre les guillemets
$k.Length            # DOIT afficher 51 — jamais 52
```

   - Longueur attendue : **51** (`base64:` + 44 caractères)
   - Si ce n’est pas `51`, régénérez — ne collez pas une clé à 52 caractères
3. Collez **exactement** la valeur dans Render → Environment → `APP_KEY` (sans guillemets, sans espace).
4. Évitez si possible le caractère `+` (régénérez jusqu’à en avoir une sans `+`).
5. Après changement d’env : **Manual Deploy** (restart obligatoire).
6. Les logs de boot doivent montrer `APP_KEY OK` **et** `Cached config app.key OK`.  
   Si vous voyez `ERROR: APP_KEY invalid` / `string_len=52`, le deploy doit **échouer** (plus de faux positif).

## Reçus privés — comportement

| Avant | Après |
|-------|--------|
| `Storage::disk('public')` | `Storage::disk('local')` (`storage/app/private/...`) |
| URL publique `/storage/...` | `GET /api/payments/{id}/receipt` (Sanctum) |
| | `GET /payments/{id}/receipt` (session admin) |

Validation inchangée : image JPEG/PNG/WebP, max 5 Mo (`StorePaymentRequest` + contrôles `PaymentService`).

Les anciens fichiers encore sur le disque `public` restent lisibles en fallback temporaire.

## Checklist post-déploiement

- [ ] `APP_DEBUG=false`
- [ ] `/up` répond 200
- [ ] Page `/login` charge le CSS (pas de logo Laravel géant) — vérifier dans le HTML que les `/build/assets/*` sont en `https://`
- [ ] Login CMS OK
- [ ] Login API OK
- [ ] Upload reçu → visible uniquement connecté (403/401 sans token)
- [ ] Persistent Disk monté
- [ ] Aucun seeder démo exécuté
- [ ] Flutter pointe vers l’URL HTTPS via `--dart-define=API_BASE_URL=...`
