--[[
C BUILTIN FUNCTIONS

function	TraceAI (string) end
function	MoveToOwner (id) end
function 	Move (id,x,y) end
function	Attack (id,id) end
function 	GetV (V_,id) end
function	GetActors () end
function	GetTick () end
function	GetMsg (id) end
function	GetResMsg (id) end
function	SkillObject (id,level,skill,target) end
function	SkillGround (id,level,skill,x,y) end
function	IsMonster (id) end --yes -> 1 no -> 0
--]]

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

--------------------------------------------
-- Mercenary type
--------------------------------------------
ARCHER01 = 1
ARCHER02 = 2
ARCHER03 = 3
ARCHER04 = 4
ARCHER05 = 5
ARCHER06 = 6
ARCHER07 = 7
ARCHER08 = 8
ARCHER09 = 9
ARCHER10 = 10
LANCER01 = 11
LANCER02 = 12
LANCER03 = 13
LANCER04 = 14
LANCER05 = 15
LANCER06 = 16
LANCER07 = 17
LANCER08 = 18
LANCER09 = 19
LANCER10 = 20
SWORDMAN01 = 21
SWORDMAN02 = 22
SWORDMAN03 = 23
SWORDMAN04 = 24
SWORDMAN05 = 25
SWORDMAN06 = 26
SWORDMAN07 = 27
SWORDMAN08 = 28
SWORDMAN09 = 29
SWORDMAN10 = 30
--------------------------------------------

--------------------------
MOTION_STAND = 0 -- Standing
MOTION_MOVE = 1 -- Movement
MOTION_ATTACK = 2 -- Attack
MOTION_DEAD = 3 -- Dead
MOTION_BENDDOWN = 5 -- Pick up item, set trap
MOTION_SIT = 6 -- Sitting down
MOTION_ATTACK2 = 9 -- Attack
--------------------------

--------------------------
-- command
--------------------------
NONE_CMD = 0
MOVE_CMD = 1
STOP_CMD = 2
ATTACK_OBJECT_CMD = 3
ATTACK_AREA_CMD = 4
PATROL_CMD = 5
HOLD_CMD = 6
SKILL_OBJECT_CMD = 7
SKILL_AREA_CMD = 8
FOLLOW_CMD = 9
--------------------------
