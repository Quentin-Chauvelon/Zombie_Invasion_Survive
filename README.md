[![en](https://img.shields.io/badge/lang-fr-blue.svg)](README.fr.md)


<details>
  <summary>Table of contents</summary>

1. [Zombie Invasion: Survive](#zombie-invasion-survive)
2. [Status](#status)
3. [Project](#project)
4. [Inspiration](#inspiration)
5. [Encountered difficulties](#encountered-difficulties)
6. [Contact](#contact)
</details>
<br>


# Zombie Invasion: Survive

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=2C2D72&labelColor=grey)
![Lua](https://img.shields.io/badge/Roblox%20Studio-00A2FF?style=flat&logo=roblox-studio&logoColor=00A2FF&labelColor=grey)

Source code of [Zombie Invasion: Survive](https://www.roblox.com/games/9574923822).

Zombie Invasion: Survive is a Roblox survival game.

It has been developed in Lua using the Roblox Studio game engine.

The goal of this game is to survive zombies waves. To do that, each player starts with a simple pistol. Once you kill a zombie, you earn coins. These coins will allow us to unlock new zones where we can buy better weapons, armors, refill ammos and many other machines which will let us get various advantages/perks (speed, special effects for bullets, revive the team...)
At the start of the game, each player selects a role (tank, sniper...) giving abilities to use strategically.

Waves have a rising difficulty with more and more ennemies getting stronger and stonger. Thus, players have to be strategic to survive.

The game can be played only or with other players thanks to a cross-server party system.

The game has a low poly/cartoony visual style which is pretty appealing (with bright colors and simple geometry) while improving performance (less polygones to render). 


# Status

The project has reached a stable state but is not being actively developed anymore.


# Project

I worked on this as a side project for about 3 months. I learnt Lua by myself by working on other projects before this one.

As a solo developer on the project, I had to work on all aspects of the game: coding, UI designing, 3D modeling, testing, fixing bugs... which allowed me to learn and improve a lot.

I then worked on another project in Lua which you can find [here](https://github.com/Quentin-Chauvelon/Social_Media_Simulator) (I think this one is better both in terms of quality of code and results).


# Inspiration

This game was inspired by a mini-game called Zombies developed by the [Minecraft](https://www.minecraft.net/en-us) server [Hypixel](https://hypixel.net/).

![Hypixel Zombies](https://hypixel.net/attachments/unknown5-png.2795779/)  
*Image by [gladius22](https://hypixel.net/members/gladius22.3004338/) on the [Hypixel forum](https://hypixel.net/threads/guide-my-de-zombies-strategy-guide.4637320/post-33474789)*

![Zombie](https://hypixel.net/attachments/upload_2018-7-9_18-25-5-png.954191/)  
*Image by [LittlePhilip](https://hypixel.net/members/littlephilip.145858/) on the [Hypixel forum](https://hypixel.net/threads/guide-almost-everything-about-hypixel-zombies.1210823/)*


# Encountered difficulties

The game is unfortunately not as interesting as I wanted it to be. This is primarly because of issues related to pathfinding and also the distribution of the number of zombies per wave.

Regarding the problems related to pathfinding, shortly before the release, I realized that the zombies movements were not smooth when there were too many of them. Indeed, the way the pathfinding algorithm works is that the zombie calcultes a path to the player, then cuts this path into waypoints and moves to the next waypoint. With few zombies, they can always calculate a new path before reaching the next waypoint and thus move continuously towards the player. However, when there are too many zombies, they reach the waypoint and have to wait for all other zombies to calculate their path before recalculating their own path (because each path calculation is done sequentally in an infinite loop). This way, when there were too many zombies, they would move a little bit, then stop for a multiple seconds making the game unplayable as zombies are one of the core mechanic of the game.

To fix this, I implemented multiple solutions:
- To reduce the number of path calculations made, I made sure that if the player has a direct view on the zombie (no obstacle between them), then the zombie would simply move in a straight line towards the player at a certain speed
- Originally, the server would handle and move the entire zombie model (head, arms, legs...) and replicate these movements to each players, which required lots of ressources from the server. So, I replaced the zombie model with a simple square on the server and it was up to each client to render the zombie model in the right place and animate it (walking, jumping...)
- Each time the path was calculated, zombies would look for the closest player to target him, I modified this behavior so that it would only do it when the zombie took damage, which prevented the server from having to search the closest player each loop.

After adding those various improvements, ce game could run fine with hundred of zombies. Nevertheless, the zombies always ended up "synchronizing" and following themselves which made the game less interesting. Waves also became too hard too quickly and the distribution of the number of zombies per wave needs to be reviewed.

Although the game might not be as interesting as I imagined it, I still think it has potential and I might try to work on it again in the future, with more experience this time.


# Contact

Email: [quentin.chauvelon@gmail.com](mailto:quentin.chauvelon@gmail.com)

Linkedin: [Quentin Chauvelon](https://www.linkedin.com/in/quentin-chauvelon/)
