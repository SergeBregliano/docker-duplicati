# Docker - Duplicati sshfs

[Duplicati](https://www.duplicati.com/) est un logiciel Open Source sous licence LGPL. Il permet de gérer des sauvegardes et de stocker les fichiers de manière chiffrée ou non sur des services distants comme sur la machine locale.
Cette stack utilise l'[image mise à disposition par linuxserver.io](https://hub.docker.com/r/linuxserver/duplicati).

Le plugin Docker [vieux/sshfs](vieux/sshfs) permet de connecter des espaces de fichiers en SFTP.

**Cette stack Docker Compose permet de monter des volumes distants au travers de SSH afin de les sauvegarder. La sécurité de connexion est gérée via des clefs SSH.**



## Prérequis

- Nécessite [Docker](https://www.docker.com) et [Docker Compose](https://docs.docker.com/compose/).
- Les volumes distants ne fonctionneront pas nativement avec un Docker en mode Rootless (cela reste tout à fait réalisable, mais non mis en place ici).
- L'installation du plugin sshfs nécessite les privilèges suivants :
  - network: [host]
  - mount: [/var/lib/docker/plugins/]
  - mount: []
  - device: [/dev/fuse]



## Installation

#### Variables d'environnement

Dupliquer le fichier ```sample.env``` en ```.env``` et ajuster la configuration.

Si vous utilisez des clefs SSH n'oubliez pas de personnaliser le chemin suivant :

```shell
SSHKEYS_PATH=/Users/user/.ssh/
```

##### Fixez la version du container

Par défaut, la version du container n'est pas fixée afin de tester les versions qui vous intéressent. N'hésitez pas à fixer la version en production.

```shell
DUPLICATI_VERSION=2.0.7
```

#### Installation du plugin sshfs

Lancer la commande suivante pour installer le plugin Docker vieux/sshfs :

```shell
$ sh ./install_sshfs.sh
```

#### Installation des clefs sur le serveur distant

La clef publique de l'utilisateur employé pour réaliser les sauvegardes doit être présente dans le dossier ``/home/utilisateurDeSauvegarde/.ssh`` où utilisateurDeSauvegarde est le nom de l'utilisateur employé pour réaliser la sauvegarde.

**Attention** : en cas d'erreur de clef, il faudra supprimer le volume précédemment créé avant de relancer Duplicati.

Erreur de clef typique :

```shell
VolumeDriver.Mount: sshfs command execute failed: exit status 1 (read: Connection reset by peer)
```

Commande de suppression du volume configuré ``sshfs-vol1`` :

```shell
docker volume rm duplicati_sshfs-vol1
```

#### Personnalisez vos volumes distants

L'installation de base fonctionne sans volumes distants. Afin d'ajouter la gestion des volumes distants, il faut dupliquez le fichier ```docker-compose.override-sample.yml``` en ```docker-compose.override.yml```.

Personnalisez ensuite les entrées pour chaque volume souhaité.

- ``sshfs-vol1`` : nom du volume souhaité, il doit être différent à chaque nouveau volume. Il doit être présent à la fois dans la définition des volumes du service duplicati et dans la définition des volumes.
- ``user@domain.ext`` : nom d'utilisateur [@] nom de domaine du serveur (ou adresse IP). La forme est la même que lors d'une connexion ssh sur le serveur.
- ``/path/to/connect`` : emplacement du dossier sur le serveur qui doit être monté en tant que volume dans Duplicati.

*Nota Bene*

- **Par défaut, les volumes sont montés en lecture seule** (``:ro``) pour plus de sécurité. Il suffit de retirer ``:ro`` dans les définition de volumes du service duplicati afin de permettre l'écriture sur les volumes distants.
  => Cela sera notamment nécessaire en cas de restauration à partir de Duplicati.
- les différents volumes sont montés par défaut dans /source/nomDuVolume sur le service duplicati.

#### Configuration des alertes e-mail

Afin d'envoyer un e-mail en cas d'erreur lors d'une sauvegarde, se rendre dans ``Paramètres > Options par défaut``, cliquer sur ``Éditer en tant que texte``, personnaliser puis coller les éléments suivants :

```shell
--send-mail-url=smtp://smtp.gmail.com:587/?starttls=when-available
--send-mail-any-operation=true
--send-mail-level=Warning,Error,Fatal
--send-mail-subject=Duplicati %PARSEDRESULT%, %OPERATIONNAME% report for %backup-name%
--send-mail-to=destination_email_address@whatever.com
--send-mail-username=your_sending_gmail_username@gmail.com
--send-mail-password=your_sending_gmail_password
--send-mail-from=This_computers_name backup <your_sending_gmail_username@gmail.com>
```

*Source : https://forum.duplicati.com/t/how-to-configure-automatic-email-notifications-via-gmail-for-every-backup-job/869*

## Fonctionnement

#### Persistences

La configuration et les sauvegardes sont persistées sur le serveur Docker de manière à permettre de mettre à jour l'ensemble de la stack sans risque de perte de données.

##### Persistence de la configuration

La configuration est persistée dans le dossier ``/appConfig``. Le dossier est créé automatiquement à la racine du répertoire au 1er lancement de la stack Docker.

##### Emplacement des fichiers de sauvegarde

Les sauvegardes sont persistées dans le dossier ``/appData``. Là aussi, le dossier est créé automatiquement à la racine du répertoire au 1er lancement de la stack Docker.

#### Gestion des volumes dans Duplicati

- **Les sauvegardes**, en utilisation locale, sont à déposer dans le dossier ``Computer > Backups`` qui correspond au dossier local ``appData/backups`` dans Docker. 
  **Attention :** Chaque nouvelle sauvegarde est à placer dans un sous-dossier. 
  Exemple : ``appData/backups/backup_1``

- **Les volumes distants** sont montés dans Duplicati sous l'arborescence ``Computer > source``.