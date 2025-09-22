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
| LifCanHeal                         | Can LIF heal?                          |
| ShouldPreventHomunculusDuplication | Should prevent homunculus duplication? |

#### Example

```lua
LifCanHeal = true -- can LIF heal? true or false (requires condensed potion)
```

### Contributing

You can contribute by reporting bugs, suggesting new features, or fixing issues.  
To report a bug, create a new topic in [Issues](https://github.com/maxmx03/USER_AI/issues).

If you want to contribute in another way, send a Rodex in-game to `Freya/Pelunia (BIO)` or `Freya/Millianor (AB)`, sending zeny or Seed of Life.
