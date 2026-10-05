# Comptes et sauvegardes du calendrier

## Fichiers a envoyer sur GitHub

- `index.html` : application, comptes et historique.
- `supabase.sql` : configuration de la base de donnees.
- `.github/workflows/supabase-health.yml` : verification quotidienne de la base.
- `SETUP.md` : ce guide.

Le site reste sur GitHub Pages. Aucun serveur web supplementaire a deployer.
Le fichier HTML fonctionne toujours en mode local sans configuration. Les comptes
necessitent Internet et chargent la bibliotheque officielle Supabase depuis un CDN.

## 1. Supabase

1. Creer un projet Supabase et attendre qu'il soit disponible.
2. Ouvrir SQL Editor, creer une requete, coller le contenu de `supabase.sql`
   et executer UNE FOIS. Les tables calendars et calendar_versions sont privees
   et accessibles uniquement a leur proprietaire. Les ecritures passent par une
   fonction qui verifie la version du calendrier.
3. Dans les parametres du projet, recuperer Project URL et la cle publique
   Publishable (ou l'ancienne cle anon). Ne jamais utiliser secret ou service_role.
4. Dans `index.html`, rechercher `const SUPABASE_URL` et renseigner :

```js
const SUPABASE_URL = "https://VOTRE-PROJET.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "VOTRE-CLE-PUBLIQUE";
```

5. Authentication > Providers : activer Email et la confirmation du courriel.
   Configurer une longueur minimale de mot de passe de 8 caracteres ou plus.
6. Authentication > URL Configuration : Site URL = l'adresse exacte du calendrier
   sur GitHub Pages, par exemple `https://utilisateur.github.io/cal/`.
   Ajouter cette adresse et `https://utilisateur.github.io/cal/index.html`
   dans Redirect URLs. Si vous utilisez un domaine personnalise, ajouter ses
   adresses equivalentes. Le lien de retour utilise l'adresse ouverte par l'usager.
7. Configurer un fournisseur SMTP dans Authentication > SMTP Settings (Brevo,
   Resend ou autre fournisseur SMTP). Sans SMTP personnalise, le service email
   de test Supabase ne livre qu'aux adresses des membres de votre equipe projet.
   Configurer l'expediteur et faire les verifications de domaine demandees par
   votre fournisseur. Traduire les modeles Confirmation et Reset Password dans
   Authentication > Email Templates; conserver leur lien de confirmation.

Inscription : nom d'utilisateur, courriel, mot de passe. Connexion : courriel et
mot de passe. Le nom d'utilisateur est un nom d'affichage, pas un identifiant unique.
Le mot de passe est gere par Supabase, jamais par la base de calendrier.

## 2. GitHub Pages et verification automatique

1. Envoyer les quatre fichiers ci-dessus dans votre depot. Garder le mode de
   publication GitHub Pages actuel.
2. Settings > Secrets and variables > Actions > New repository secret :
   - `SUPABASE_URL` : la meme URL que dans le HTML.
   - `SUPABASE_PUBLISHABLE_KEY` : la meme cle PUBLIQUE que dans le HTML.
3. Autoriser GitHub Actions dans le depot si necessaire.
4. Le workflow doit etre sur la branche par defaut pour sa planification.
   Actions > Supabase database health > Run workflow : lancer un test manuel.
   Le resultat attendu est une reponse contenant le record id 1.

Le workflow effectue trois petites lectures par jour sur une table de controle
sans donnees personnelles. Il peut aider a eviter les pauses pour faible activite,
mais ne les garantit pas. GitHub peut retarder les executions et desactive les
workflows planifies des depots publics apres 60 jours sans activite dans le depot.
Verifier periodiquement Actions et les emails Supabase. En cas de pause, reprendre
le projet depuis Supabase. Un plan Supabase payant garantit l'absence de pause pour
inactivite. Aucun secret administratif n'est necessaire pour ce workflow.

## 3. Verification apres configuration

1. Ouvrir GitHub Pages, cliquer Se connecter et creer un compte.
2. Confirmer le courriel puis se connecter. Si le compte est vide, l'application
   propose de copier le calendrier local existant. Une copie locale reste intacte.
3. Modifier un calendrier et attendre Enregistre en ligne (environ 1,5 seconde
   apres la derniere modification). Tester sur un deuxieme navigateur/appareil.
4. Ouvrir Sauvegardes precedentes, afficher un apercu et restaurer une version.
5. Tester Mot de passe oublie et le lien recu par email.
6. Tester la deconnexion et un deuxieme compte : les calendriers doivent rester
   separes. Le mode local hors connexion au compte reste disponible.
7. Tester l'impression d'un mois et de plusieurs mois en 11 x 17 paysage.
8. Sur deux appareils, modifier le meme calendrier sans recharger : le deuxieme
   enregistrement doit signaler un conflit. Exporter ses changements avant de
   choisir Mon compte > Synchroniser pour charger la version en ligne.

## Sauvegardes et limites

Chaque sauvegarde en ligne cree une version. Les 50 dernieres sont conservees;
ce ne sont pas 50 jours et les modifications frequentes peuvent les remplacer
rapidement. Une restauration cree une nouvelle version et sauvegarde d'abord les
changements actuels. Exporter reste utile pour garder des archives a long terme.

Les changements hors ligne sont conserves sur l'appareil du compte et retentes
au retour du reseau. Ne pas effacer les donnees du navigateur avant synchronisation.
En cas de conflit, aucun remplacement automatique n'est fait. Exporter permet de
conserver la copie locale, puis Synchroniser charge la copie du serveur. Il n'y a
pas encore de fusion automatique ou de collaboration en direct.

## Commit suggere

Titre : `Add Supabase accounts, calendar sync and save history`

Description : `Add email/password accounts, isolated per-account storage,
automatic sync with conflict protection, and the last 50 restorable save versions.
Include Supabase SQL setup, deployment instructions and scheduled health checks.`

## Documentation officielle

- https://supabase.com/docs/guides/auth/passwords
- https://supabase.com/docs/guides/auth/auth-smtp
- https://supabase.com/docs/guides/platform/free-project-pausing
- https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows
