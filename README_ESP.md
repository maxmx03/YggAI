# Ragnarok Online - YggAI

> [!CAUTION]
> ROLATAM tiene un error que duplica al homúnculo cuando el dueño pasa por un portal.  
> Esto ocurre porque el homúnculo ataca a un monstruo al mismo tiempo que el dueño intenta cruzar.  
> Por eso, mi script hace que el homúnculo sea agresivo solo contra monstruos de instancia, ilusorios, jefes y MVPs. Además, solo usará buffs si el dueño está en combate, evitando que el homúnculo use habilidades dentro de la ciudad. [Ver](https://youtu.be/A_NnJk_ZBRQ?si=M3BAxdLwUaw-pCib)

### Introducción

Este es un proyecto de IA para el juego Ragnarok Online, desarrollado en Lua.

### Arquitectura

La IA de este proyecto está construida usando [Árboles de Comportamiento](https://dev.epicgames.com/documentation/en-us/unreal-engine/behavior-tree-in-unreal-engine---overview).  
Este enfoque organiza la lógica de decisión en una estructura jerárquica, permitiendo un comportamiento adaptable y fácil de gestionar para los personajes controlados por IA.

### Cómo usar

#### Archivo zip

Haz clic en **Code > Download ZIP**, extrae el archivo y copia el contenido de la carpeta YggAI en `C:\Gravity\Ragnarok\AI\USER_AI`.  
Luego, entra al juego y escribe `/hoai` para activar YggAI. Para volver al script original, escribe el mismo comando otra vez.

#### Control de versiones

Si usas una herramienta de control de versiones como [Git](https://git-scm.com/downloads), puedes clonar el repositorio usando la terminal:

```bash
git clone https://github.com/maxmx03/YggAI.git C:\Gravity\Ragnarok\AI\USER_AI
cd C:\Gravity\Ragnarok\AI\USER_AI
git pull # busca actualizaciones
```

Si no quieres usar la terminal, puedes usar [Github Desktop](https://desktop.github.com).

### Config.lua

Abre el archivo `config.lua` y actualiza las variables según sea necesario.  
Puedes usar cualquier editor de texto disponible en tu sistema:

- [Notepad](https://apps.microsoft.com/detail/9msmlrh6lzf3?hl=es-ES&gl=ES)
- [Notepad++](https://notepad-plus-plus.org)
- [Vscode](https://code.visualstudio.com)

| Variable                             | Descripción                                     |
| ------------------------------------ | ----------------------------------------------- |
| `MyLevel`                            | Nivel de tu homúnculo, actualízalo              |
| `LifCanHeal`                         | ¿LIF puede curar?                               |
| `ShouldPreventHomunculusDuplication` | ¿Debería prevenir la duplicación del homúnculo? |

#### Ejemplo

```lua
MyLevel = 50 -- nivel de tu homúnculo, actualízalo siempre
LifCanHeal = true -- ¿LIF puede curar? true o false (requiere poción condensada)
```

### Contribuir

Puedes contribuir reportando errores, sugiriendo nuevas funciones o corrigiendo problemas.  
Para reportar un error, crea un nuevo tema en [Issues](https://github.com/maxmx03/USER_AI/issues).

Si quieres contribuir de otra forma, envía un Rodex en el juego a `Freya/Pelunia (BIO)` o `Freya/Millianor (AB)`, enviando zenys o Semilla de la Vida.

### TODO

- [x] Homúnculo
  - [x] Lif
  - [x] Vanilmirth
  - [x] Amistr
  - [x] Filir
- [ ] Homúnculo S
  - [ ] Bayeri
  - [x] Dieter
  - [x] Eira
  - [ ] Sera
  - [x] Eleanor
- [ ] PVP
- [ ] WOE
- [x] PVM
- [x] Detectar MVP
- [x] Evitar Plant
- [x] Habilidades y Cooldown
- [x] Prevención del Bug de Duplicación de Homúnculo
- [ ] Comandos de usuario

### Proyectos Alternativos

> [!CAUTION]
> Usuarios de AzzyAI: desactiven cualquier autobuff u otra función que pueda causar el error de duplicación.

- [AzzyAI](https://github.com/SpenceKonde/AzzyAI)
