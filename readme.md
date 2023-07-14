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

#### Installation du plugin sshfs

Lancer la commande suivante pour installer le plugin Docker vieux/sshfs :

```shell
$ sh ./install_sshfs.sh
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



## Fonctionnement

#### Persistences

La configuration et les sauvegardes sont persistées sur le serveur Docker de manière à permettre de mettre à jour l'ensemble de la stack sans risque de perte de données.

##### Persistence de la configuration

La configuration est persistée dans le dossier ``/appConfig``. Le dossier est créé automatiquement à la racine du répertoire au 1er lancement de la stack Docker.

##### Emplacement des fichiers de sauvegarde

Les sauvegardes sont persistées dans le dossier ``/appData``. Là aussi, le dossier est créé automatiquement à la racine du répertoire au 1er lancement de la stack Docker.

#### Gestion des volumes dans Duplicati

- **Les sauvegardes**, en utilisation locale, sont à déposer dans le dossier ``Computer > Backups`` qui correspond au dossier local ``appData/backups`` dans Docker.

- **Les volumes distants** sont montés dans Duplicati sous l'arborescence ``Computer > source``.