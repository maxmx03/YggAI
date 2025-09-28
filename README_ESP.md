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
LifCanHeal = true -- ¿LIF puede curar? true o false (requiere poción condensada)
```

## Comportamiento de los Homúnculos en YggAI

### Eira

<img width="300" height="417" alt="Eira_Card_Art" src="https://github.com/user-attachments/assets/00bfdb88-ba6e-4f5f-aa4c-181d99f8ac16" align="left" />

Eira es un homúnculo de combate ágil, enfocado en infligir daño y mantener la presión sobre el enemigo. Su estrategia se basa en el uso continuo de habilidades de ataque, siendo la habilidad **Eraser Cutter** su principal forma de daño.

- **Comportamiento de Combate**: Prioriza el uso de **Xeno Slasher** contra monstruos de tipo Agua 💧 o Veneno ☣️, o cuando el enemigo no es de tipo Viento. Su principal habilidad ofensiva, **Eraser Cutter**, se usa repetidamente.
- **Habilidades Especiales**:
  - **Overed Boost**: Se utiliza contra MVPs (monstruos jefes) para aumentar su poder de ataque.
  - **Light of Regene**: Una habilidad de apoyo crucial, activada para revivir al dueño.

<div style="clear: both;"></div>

---

### Dieter

<img width="300" height="417" alt="Dieter_Card_Art" src="https://github.com/user-attachments/assets/6f9187c8-fb27-4843-b692-7bef1ba3b3af" align="right" />

Dieter es un homúnculo robusto y estratégico, especializado en ataques de área y supervivencia. Su comportamiento es adaptable al tipo de monstruo al que se enfrenta, utilizando diferentes habilidades para maximizar el daño.

- **Comportamiento de Combate**: Utiliza la habilidad **Lava Slide** para ataques de área contra la mayoría de los enemigos, excepto monstruos de tipo Fuego 🔥. Contra monstruos de tipo Agua 💧 o Planta 🌿, prefiere la habilidad **Volcanic Ash**.
- **Habilidades Especiales**:
  - **Granitic Armor**: Activada en situaciones de emergencia para aumentar su defensa y protección, cuando el dueño está a punto de morir.
  - **Magma Flow**: Una poderosa habilidad de daño de área, utilizada contra enemigos que no son de tipo Fuego.
  - **Pyroclastic**: Su habilidad definitiva, activada en combate contra cualquier tipo de enemigo.

<div style="clear: both;"></div>

---

### Eleanor

<img width="300" height="417" alt="Eleanor_Card_Art" src="https://github.com/user-attachments/assets/5a92ad5b-940d-4cfd-8bb7-80e70f4a7e15" align="left" />

Eleanor es una atacante rápida y precisa, que utiliza una secuencia de habilidades para infligir un gran daño al enemigo. Su enfoque es ejecutar un combo de ataque eficiente, pero también sabe cómo adaptarse.

- **Comportamiento de Combate**: Su objetivo principal es ejecutar un combo devastador que comienza con **Sonic Craw**, seguido de **Silvervein Rush** y, finalmente, **Midnight Frenzy**. El combo se activa siempre que las habilidades están disponibles y el enemigo está dentro del alcance.
- **Habilidades Especiales**:
  - **Ataque Básico**: Cuando las habilidades principales están en tiempo de reutilización (cooldown), Eleanor continúa con el ataque básico al enemigo para acumular esferas, que son necesarias para sus habilidades.

<div style="clear: both;"></div>

---

### Sera

<img width="300" height="417" alt="Sera_Card_Art" src="https://github.com/user-attachments/assets/f31a2812-425e-4c13-ba53-f9f2d16916e2" align="right" />

Sera es una homúnculo de apoyo y control, especializada en incapacitar enemigos y ayudar al dueño en el combate. Su estrategia se centra en usar habilidades que perjudican al oponente y le dan ventajas a ella misma o a su dueño.

- **Comportamiento de Combate**: Sera intenta usar **Poison Mist** para causar daño de área. También se enfoca en aplicar la habilidad de daño y parálisis **Needle of Paralyze** sobre el enemigo para ayudar al dueño.
- **Habilidades Especiales**:
  - **Summon Legion**: Se utiliza específicamente contra MVPs para invocar ayuda.
  - **Pain Killer**: Una habilidad de apoyo activada en combate para proteger al dueño.

<div style="clear: both;"></div>

---

### Bayeri

<img width="300" height="417" alt="Bayeri_Card_Art" src="https://github.com/user-attachments/assets/b219099c-5ac1-4ea0-8d21-fa3b45f20e31" align="left" />

Bayeri es un homúnculo de combate directo, enfocado en infligir daño masivo y fortalecerse a sí mismo. Adapta su estilo de ataque al tipo de monstruo al que se enfrenta, priorizando el daño contra enemigos específicos.

- **Comportamiento de Combate**: Utiliza habilidades como **Stahl Horn** y **Goldene Ferse** para atacar. Contra monstruos de tipo No Muerto 🧟 o Oscuro 🦇, prioriza la habilidad **Heilige Stange**.
- **Habilidades Especiales**:
  - **Steinwand**: Una habilidad de apoyo activada para proteger al dueño, especialmente si tiene poca vida.
  - **Angriffs Modus**: Se utiliza para fortalecer al propio Bayeri en combate.

<div style="clear: both;"></div>

### Contribuir

Puedes contribuir reportando errores, sugiriendo nuevas funciones o corrigiendo problemas.  
Para reportar un error, crea un nuevo tema en [Issues](https://github.com/maxmx03/USER_AI/issues).

Si quieres contribuir de otra forma, envía un Rodex en el juego a `Freya/Pelunia (BIO)` o `Freya/Millianor (AB)`, enviando zenys o Semilla de la Vida.
