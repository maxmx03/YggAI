-------------------------------------------------
-- constants
-------------------------------------------------

--------------------------------
V_OWNER = 0 -- Returns the Homunculus owner’s ID
V_POSITION = 1 -- Returns the current location’s x,y coordinates
V_TYPE = 2 -- Defines an object (Not implemented yet)
V_MOTION = 3 -- Returns the current action
V_ATTACKRANGE = 4 -- Returns the attack range (Not implemented yet; temporarily set as 1 cell)
V_TARGET = 5 -- Returns the target of an attack or skill
V_SKILLATTACKRANGE = 6 -- Returns the skill attack range (Not implemented yet)
V_HOMUNTYPE = 7 -- Returns the type of Homunculus
V_HP = 8 -- Current HP amount of a Homunculus or its owner
V_SP = 9 -- Current SP amount of a Homunculus or its owner
V_MAXHP = 10 -- The maximum HP of a Homunculus or its owner
V_MAXSP = 11 -- The maximum SP of a Homunculus or its owner
V_MERTYPE = 12 -- Mercenary type
V_POSITION_APPLY_SKILLATTACKRANGE = 13
V_SKILLATTACKRANGE_LEVEL = 14
---------------------------------

--------------------------------------------
-- HUMUNCULUS TYPE
--------------------------------------------
LIF = 1
AMISTR = 2
FILIR = 3
VANILMIRTH = 4
LIF2 = 5
AMISTR2 = 6
FILIR2 = 7
VANILMIRTH2 = 8
LIF_H = 9 -- Advanced Lif
AMISTR_H = 10 -- Advanced Amistr
FILIR_H = 11 -- Advanced Filir
VANILMIRTH_H = 12 --  Advanced Vanilmirth
LIF_H2 = 13
AMISTR_H2 = 14
FILIR_H2 = 15
VANILMIRTH_H2 = 16
EIRA = 48
BAYERI = 49
SERA = 50
DIETER = 51
ELEANOR = 52
--------------------------------------------

--------------------------
MOTION_STAND = 0 -- Standing
MOTION_MOVE = 1 -- Movement
MOTION_ATTACK = 2 -- Attack
MOTION_DAMAGE = 4 -- Taking damage
MOTION_DEAD = 3 -- Dead
MOTION_BENDDOWN = 5 -- Pick up item, set trap
MOTION_SIT = 6 -- Sitting down
MOTION_SKILL = 7 -- Used a skill
MOTION_CASTING = 8 -- Casting a skill
MOTION_ATTACK2 = 9 -- Attack
MOTION_TOSS = 12 -- Toss something (spear boomerang / aid potion)
MOTION_COUNTER = 13 -- Counter-attack
MOTION_PERFORM = 17 -- Performance
MOTION_JUMP_UP = 19 -- TaeKwon Kid Leap -- rising
MOTION_JUMP_FALL = 20 -- TaeKwon Kid Leap -- falling
MOTION_SOULLINK = 23 -- Soul linker using a link skill
MOTION_TUMBLE = 25 -- Tumbling / TK Kid Leap Landing
MOTION_BIGTOSS = 28 -- A heavier toss (slim potions / acid demonstration)
MOTION_DESPERADO = 38 -- Desperado
MOTION_XXXXXX = 39 -- ??(????????/????)
MOTION_FULLBLAST = 42 -- Full Blast
--------------------------

-- LIF
HLIF_HEAL = 8001
HLIF_AVOID = 8002
HLIF_CHANGE = 8004

-- AMISTR
HAMI_CASTLE = 8005
HAMI_DEFENCE = 8006
HAMI_BLOODLUST = 8008

-- FILIR
HFLI_MOON = 8009
HFLI_FLEET = 8010
HFLI_SPEED = 8011
HFLI_SBR44 = 8012

-- VANILMIRTH
HVAN_CAPRICE = 8013
HVAN_CHAOTIC = 8014
HVAN_SELFDESTRUCT = 8016

-- SERA
MH_SUMMON_LEGION = 8018
MH_NEEDLE_OF_PARALYZE = 8019
MH_POISON_MIST = 8020
MH_PAIN_KILLER = 8021
MH_POLISHING_NEEDLE = 8052
MH_TOXIN_OF_MANDARA = 8053
MH_NEEDLE_STINGER = 8054

-- EIRA
MH_LIGHT_OF_REGENE = 8022
MH_OVERED_BOOST = 8023
MH_ERASER_CUTTER = 8024
MH_XENO_SLASHER = 8025
MH_SILENT_BREEZE = 8026
MH_TWISTER_CUTTER = 8047
MH_ABSOLUTE_ZEPHYR = 8048

-- ELEANOR
MH_STYLE_CHANGE = 8027
MH_SONIC_CRAW = 8028
MH_SILVERVEIN_RUSH = 8029
MH_MIDNIGHT_FRENZY = 8030
MH_TINDER_BREAKER = 8036
MH_CBC = 8037
MH_EQC = 8038
MH_BRUSHUP_CLAW = 8049
MH_BLAZING_AND_FURIOUS = 8050
MH_THE_ONE_FIGHTER_RISES = 8051

-- Bayeri
MH_STAHL_HORN = 8031
MH_GOLDENE_FERSE = 8032
MH_STEINWAND = 8033
MH_HEILIGE_STANGE = 8034
MH_ANGRIFFS_MODUS = 8035
MH_LICHT_GEHORN = 8055
MH_GLANZEN_SPIES = 8056
MH_HEILIGE_PFERD = 8057
MH_GOLDENE_TONE = 8058

-- DIETER
MH_MAGMA_FLOW = 8039
MH_GRANITIC_ARMOR = 8040
MH_LAVA_SLIDE = 8041
MH_PYROCLASTIC = 8042
MH_VOLCANIC_ASH = 8043
MH_BLAZING_LAVA = 8059
MH_BLAST_FORGE = 8044
MH_TEMPERING = 8045
