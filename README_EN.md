# Ragnarok Online - YggAI

> [!CAUTION]  
> ROLATAM has a bug that duplicates the homunculus when the owner goes through a portal.  
> This happens because the homunculus attacks a monster at the same time the owner tries to cross.  
> Because of this, my script makes the homunculus aggressive only against instance monsters, illusion monsters, bosses, and MVPs. It will only use buffs if the owner is in combat, preventing the homunculus from using skills inside the city. [See](https://youtu.be/A_NnJk_ZBRQ?si=M3BAxdLwUaw-pCib)

### Introduction

This is an AI project for the game Ragnarok Online, developed in Lua.

### Architecture

The AI of this project is built using [Behavior Trees](https://dev.epicgames.com/documentation/en-us/unreal-engine/behavior-tree-in-unreal-engine---overview).  
This approach organizes decision-making logic into a hierarchical structure, allowing adaptive and easy-to-manage behavior for AI-controlled characters.

### How to Use

#### Zip file

Click on **Code > Download ZIP**, extract the zip file, and copy the contents of the YggAI folder into `C:\Gravity\Ragnarok\AI\USER_AI`.  
Then, enter the game and type `/hoai` to activate YggAI. To return to the original script, type the same command again.

#### Version control

If you use a versioning tool like [Git](https://git-scm.com/downloads), you can clone the repository using the terminal:

```bash
git clone https://github.com/maxmx03/YggAI.git C:\Gravity\Ragnarok\AI\USER_AI
cd C:\Gravity\Ragnarok\AI\USER_AI
git pull # fetches updates
```

If you don’t want to use the terminal, you can use [Github Desktop](https://desktop.github.com).

### Config.lua

Open the `config.lua` file and update the variables as needed.  
You can use any text editor available on your system:

- [Notepad](https://apps.microsoft.com/detail/9msmlrh6lzf3?hl=en-US&gl=US)
- [Notepad++](https://notepad-plus-plus.org)
- [Vscode](https://code.visualstudio.com)

| Variable                           | Description                            |
| ---------------------------------- | -------------------------------------- |
| MyLevel                            | Your homunculus level, update it       |
| LifCanHeal                         | Can LIF heal?                          |
| ShouldPreventHomunculusDuplication | Should prevent homunculus duplication? |

#### Example

```lua
LifCanHeal = true -- can LIF heal? true or false (requires condensed potion)
```

## Homunculus Behavior in YggAI

### Eira

<img width="300" height="417" alt="Eira_Card_Art" src="https://github.com/user-attachments/assets/00bfdb88-ba6e-4f5f-aa4c-181d99f8ac16" align="left" />

Eira is an agile combat homunculus, focused on dealing damage and maintaining pressure on the enemy. Her strategy is based on continuous use of attack skills, with the **Eraser Cutter** skill being her primary form of damage.

- **Combat Behavior**: Prioritizes using **Xeno Slasher** against Water 💧 or Poison ☣️ type monsters, or when the enemy is not Wind type. Her main offensive skill, **Eraser Cutter**, is used repeatedly.
- **Special Abilities**:
  - **Overed Boost**: Used against MVPs (boss monsters) to increase her attack power.
  - **Light of Regene**: A crucial support skill, activated to revive the owner if they are incapacitated.

<div style="clear: both;"></div>

---

### Dieter

<img width="300" height="417" alt="Dieter_Card_Art" src="https://github.com/user-attachments/assets/6f9187c8-fb27-4843-b692-7bef1ba3b3af" align="right" />

Dieter is a robust and strategic homunculus, specialized in area attacks and survival. His behavior is adaptable to the type of monster he faces, using different skills to maximize damage.

- **Combat Behavior**: He uses the **Lava Slide** skill for area attacks against most enemies, except Fire 🔥 type monsters. Against Water 💧 or Plant 🌿 type monsters, he prefers the **Volcanic Ash** skill.
- **Special Abilities**:
  - **Granitic Armor**: Activated in emergency situations to increase his defense and protection when the owner is near death.
  - **Magma Flow**: A powerful area damage skill, used against enemies that are not Fire type.
  - **Pyroclastic**: His ultimate skill, activated in combat against any type of enemy.

<div style="clear: both;"></div>

---

### Eleanor

<img width="300" height="417" alt="Eleanor_Card_Art" src="https://github.com/user-attachments/assets/5a92ad5b-940d-4cfd-8bb7-80e70f4a7e15" align="left" />

Eleanor is a fast and precise attacker, who uses a sequence of skills to inflict great damage on the enemy. Her focus is on executing an efficient attack combo, but she also knows how to adapt.

- **Combat Behavior**: Her main objective is to execute a devastating combo that starts with **Sonic Craw**, followed by **Silvervein Rush** and, finally, **Midnight Frenzy**. The combo is triggered whenever the skills are available and the enemy is within range.
- **Special Abilities**:
  - **Basic Attack**: When main skills are on cooldown, Eleanor continues to basic attack the enemy to accumulate spheres, which are necessary for her skills.

<div style="clear: both;"></div>

---

### Sera

<img width="300" height="417" alt="Sera_Card_Art" src="https://github.com/user-attachments/assets/f31a2812-425e-4c13-ba53-f9f2d16916e2" align="right" />

Sera is a support and control homunculus, specialized in incapacitating enemies and assisting the owner in combat. Her strategy focuses on using skills that harm the opponent and buff herself or her owner.

- **Combat Behavior**: Sera attempts to use **Poison Mist** to deal area damage. She also focuses on applying the damage and paralysis skill **Needle of Paralyze** on the enemy to aid the owner.
- **Special Abilities**:
  - **Summon Legion**: Used specifically against MVPs to summon aid.
  - **Pain Killer**: A support skill activated when in combat to protect the owner.

<div style="clear: both;"></div>

---

### Bayeri

<img width="300" height="417" alt="Bayeri_Card_Art" src="https://github.com/user-attachments/assets/b219099c-5ac1-4ea0-8d21-fa3b45f20e31" align="left" />

Bayeri is a direct combat homunculus, focused on dealing massive damage and strengthening himself. He adapts his attack style to the type of monster he faces, prioritizing damage against specific enemies.

- **Combat Behavior**: He uses skills like **Stahl Horn** and **Goldene Ferse** to attack. Against Undead 🧟 or Dark 🦇 type monsters, he prioritizes the skill **Heilige Stange**.
- **Special Abilities**:
  - **Steinwand**: A support skill activated to protect the owner, especially if they are low on health.
  - **Angriffs Modus**: Used to strengthen Bayeri himself in combat.

<div style="clear: both;"></div>

### Contributing

You can contribute by reporting bugs, suggesting new features, or fixing issues.  
To report a bug, create a new topic in [Issues](https://github.com/maxmx03/USER_AI/issues).

If you want to contribute in another way, send a Rodex in-game to `Freya/Pelunia (BIO)` or `Freya/Millianor (AB)`, sending zeny or Seed of Life.
