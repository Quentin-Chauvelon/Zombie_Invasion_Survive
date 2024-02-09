[![en](https://img.shields.io/badge/lang-en-red.svg)](README.md)


<details>
  <summary>Sommaire</summary>

1. [Zombie Invasion: Survive](#zombie-invasion-survive)
2. [Statut](#statut)
3. [Projet](#projet)
4. [Inspiration](#inspiration)
5. [Difficultés rencontrées](#difficultés-rencontrées)
6. [Contact](#contact)
</details>
<br>


# Zombie Invasion: Survive

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=2C2D72&labelColor=grey)
![Lua](https://img.shields.io/badge/Roblox%20Studio-00A2FF?style=flat&logo=roblox-studio&logoColor=00A2FF&labelColor=grey)

Code source du jeu [Zombie Invasion: Survive](https://www.roblox.com/games/9574923822).

Zombie Invasion: Survive est un jeu de survie sur Roblox.

Il a été développé en Lua avec le moteur de jeu Roblox Studio.

Le but de ce jeu est de survivre à des vagues de zombies. Pour cela chaque joueur commence avec un simple pistolet. Lorsque l'on tue un zombie, on gagne des pièces. Ces pièces vont nous permettre de débloquer de nouvelles zones où l'on peut y acheter de meilleures armes, armures, recharger ses munitions et bien d'autres machines permettant d'obtenir divers avantages (vitesse, effets spéciaux sur les balles, ressusciter son équipe...).
En début de partie, chaque joueur choisit aussi un rôle (tank, sniper...) offrant des capacités à utiliser stratégiquement.

Les vagues ont une difficulté croissante avec de plus en plus d'ennemis qui sont de plus en plus forts. Il faut donc être stratégique pour survivre.

Le jeu peut être joué seul ou à plusieurs grâce à un système de parties inter-serveurs.

Le jeu a un style visuel low-poly/cartoon qui est assez attirant (avec des couleurs vives et une géométrie simple) ce qui permet aussi d'améliorer les performances (moins de polygones à afficher).


# Statut

Le projet est terminé et a atteint un stade satisfaisant. Cependant, à ce jour, le développement du projet est terminé.


# Projet

J'ai travaillé sur ce projet en tant que projet personnel pendant environ 3 mois. J'ai appris le Lua par moi-même en travaillant sur d'autres projets avant celui-ci.

Travaillant seul sur ce projet, j'ai du m'occuper de tous les ascpects du jeu : développement, design du de l'interface graphique, modélisation 3D, tests, résolution de bugs... ce qui m'a permis d'apprendre et de m'améliorer dans de nombreux domaines.

J'ai par la suite travaillé sur un autre projet en Lua que vous pouvez trouver [ici](https://github.com/Quentin-Chauvelon/Social_Media_Simulator) (ce dernier est, je pense, plus intéressant, tant en termes de qualité de code que de résultats).


# Inspiration

Ce jeu est inspiré d'un mini-jeu appelé Zombies créé par le serveur [Hypixel](https://hypixel.net/) sur [Minecraft](https://www.minecraft.net/en-us).

![Hypixel Zombies](https://hypixel.net/attachments/unknown5-png.2795779/)
*Image par [gladius22](https://hypixel.net/members/gladius22.3004338/) sur le [forum Hypixel](https://hypixel.net/threads/guide-my-de-zombies-strategy-guide.4637320/post-33474789)*

![Zombie](https://hypixel.net/attachments/upload_2018-7-9_18-25-5-png.954191/)
*Image par [LittlePhilip](https://hypixel.net/members/littlephilip.145858/) sur le [forum Hypixel](https://hypixel.net/threads/guide-almost-everything-about-hypixel-zombies.1210823/)*


# Difficultés rencontrées

Le jeu n'est malheureusement pas aussi intéressant que je le souhaitais. Cela est principalement dû à des problèmes liés au pathfinding et à la répartition du nombre de zombies par vagues.

Concernant les problèmes liés au pathfinding, peu de temps avant la sortie, je me suis rendu compte que les mouvements des zombies n'étaient pas du tout fluides lorsqu'il y en avait trop. En effet, la manière dont l'algorithme de pathfinding fonctionne est que le zombie calcule un itinéraire jusqu'au joueur puis découpe cet itinéaire en étapes et il avance jusqu'à la prochaine étape. Avec peu de zombies, ces derniers peuvent systématiquement recalculer l'itinéraire avant d'arriver à la prochaine étape et avancent donc en continu vers le joueur. Cependant, lorsqu'il y a trop de zombies, ces derniers arrivent à la prochaine étape et doivent attendre que tous les autres zombies calculent leurs itinéraires avant de pouvoir recalculer la prochaine étape (puisque chaque calcul est réalisé séquentiellement dans une boucle infinie). Ainsi, avec beaucoup de zombies, ces derniers avancaient un petit peu puis s'arrêtaient pendant plusieurs secondes, rendant le jeu injouable puisque les zombies sont la mécanique principale du jeu.

Pour améliorer cela, j'ai implémenté plusieurs solutions :
- Afin de limiter le nombre de calculs d'itinéraires réalisés, j'ai fait en sorte que lorsque le joueur avait une vue directe sur le zombie (pas d'obstacles entre les deux), alors ce dernier avait simplement à se déplacer en ligne vers le joueur à une certaine vitesse
- De base, le serveur déplaçait le modèle entier du zombie (tête, bras, jambes...) et répliquait les mouvements à chaque joueur, ce qui demandait beaucoup de ressources au serveur. J'ai ainsi remplacé le modèle du zombie par un simple carré sur le serveur et c'était ensuite à chaque client de positionner le modèle du zombie au bon endroit et d'ajouter les animations (marche, saut...)
- A chaque calcul d'itinéraire, les zombies cherchaient le joueur le plus près pour le cibler, j'ai changé ce comportement pour que cela ne se fasse que lorsque le zombie prenait des dégâts, ce qui permettait d'éviter d'avoir à rechercher le joueur le plus proche à chaque tour de boucle

Après ces diverses améliorations, le jeu pouvait tourner sans problème avec plusieurs centaines de zombies. Cependant, les zombies finissaient toujours par se "synchroniser" et se suivaient, ce qui rendaient le jeu moins intéressant. Les vagues devenaient aussi trop durs trop vites et la répartition du nombre de zombies par vagues est aussi à revoir.

Même si le jeu n'était pas aussi intéressant que j'aurai voulu qu'il le soit, je pense tout de même qu'il y a du potentiel et j'essaierai potentiellement de l'améliorer dans le futur, avec plus d'expérience cette fois.


# Contact

Email: [quentin.chauvelon@gmail.com](mailto:quentin.chauvelon@gmail.com)

Linkedin: [Quentin Chauvelon](https://www.linkedin.com/in/quentin-chauvelon/)
