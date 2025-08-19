-------------------------------------------------
-- BUILTIN.FUNCTIONS
--------------------------------------------------
--[[
function TraceAI (string) end
function MoveToOwner (id) end
function Move (id,x,y) end
function Attack (id,id) end
function GetV (V_,id) end
function GetActors () end
function GetTick () end
function GetMsg (id) end
function GetResMsg (id) end
function SkillObject (id,level,skill,target) end
function SkillGround (id,level,skill,x,y) end
function IsMonster (id) end -- id yes -> 1 no -> 0
--]]
---

-------------------------------------------------
-- GETV CONSTANT
-------------------------------------------------

--------------------------------
V_OWNER = 0
V_POSITION = 1
V_TYPE = 2
V_MOTION = 3
V_ATTACKRANGE = 4
V_TARGET = 5
V_SKILLATTACKRANGE = 6
V_HOMUNTYPE = 7
V_HP = 8
V_SP = 9
V_MAXHP = 10
V_MAXSP = 11
V_MERTYPE = 12
V_POSITION_APPLY_SKILLATTACKRANGE = 13
V_SKILLATTACKRANGE_LEVEL = 14
---------------------------------

--------------------------------------------
-- È£¹®Å¬·ç½º Á¾·ù
--------------------------------------------
LIF = 1
AMISTR = 2
FILIR = 3
VANILMIRTH = 4
LIF2 = 5
AMISTR2 = 6
FILIR2 = 7
VANILMIRTH2 = 8
LIF_H = 9
AMISTR_H = 10
FILIR_H = 11
VANILMIRTH_H = 12
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
-- ¿ëº´ Á¾·ù
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
MOTION_STAND = 0      -- Standing still
MOTION_MOVE = 1       -- Moving
MOTION_ATTACK = 2     -- Attacking
MOTION_DEAD = 3       -- Laying dead
MOTION_DAMAGE = 4     -- Taking damage
MOTION_BENDDOWN = 5   -- Pick up item, set trap
MOTION_SIT = 6        -- Sitting down
MOTION_SKILL = 7      -- Used a skill
MOTION_CASTING = 8    -- Casting a skill
MOTION_ATTACK2 = 9    -- Attacking (other motion)
MOTION_TOSS = 12      -- Toss something (spear boomerang / aid potion)
MOTION_COUNTER = 13   -- Counter-attack
MOTION_PERFORM = 17   -- Performance
MOTION_JUMP_UP = 19   -- TaeKwon Kid Leap -- rising
MOTION_JUMP_FALL = 20 -- TaeKwon Kid Leap -- falling
MOTION_SOULLINK = 23  -- Soul linker using a link skill
MOTION_TUMBLE = 25    -- Tumbling / TK Kid Leap Landing
MOTION_BIGTOSS = 28   -- A heavier toss (slim potions / acid demonstration)
MOTION_DESPERADO = 38 -- Desperado
MOTION_XXXXXX = 39    -- ??(????????/????)
MOTION_FULLBLAST = 42 -- Full Blast
--------------------------

--------------------------
-- COMMAND
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

--------------------------
-- STATE
--------------------------
WATCH = 'watch'
IDLE = 'idle'
FOLLOW = 'follow'
CHASE = 'chase'
ATTACK = 'attack'
HUMUNCULU_FIGHTING = 'humun_fighting'
OWNER_DAMAGED = 'owner_damaged'
OWNER_LOST_HEALTH = 'owner_health'
OWNER_DYING = 'owner_dying'
OWNER_DEAD = 'owner_dead'
OWNER_SITTING = 'owner_siting'
--------------------------

--------------------------
-- SUPPORT SKILLS
--------------------------
HLIF_HEAL = 8001
HLIF_AVOID = 8002
HLIF_CHANGE = 8004
HAMI_CASTLE = 8005
HAMI_DEFENCE = 8006
HAMI_BLOODLUST = 8008
HFLI_FLEET = 8010
HFLI_SPEED = 8011
HVAN_CHAOTIC = 8014
MH_GOLDENE_FERSE = 8032
MH_STEINWAND = 8033
MH_ANGRIFFS_MODUS = 8035
MH_GRANITIC_ARMOR = 8040
MH_MAGMA_FLOW = 8039
MH_OVERED_BOOST = 8023
MH_LIGHT_OF_REGENE = 8022
MH_SILENT_BREEZE = 8026
MH_PAIN_KILLER = 8021
--------------------------
