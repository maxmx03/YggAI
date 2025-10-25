---@class Blackboard
local blackboard = {
  myEnemy = 0,
  myEnemySet = Set.new(),
  myEnemies = {},
  ignoredEnemies = {},
  destX = 0,
  destY = 0,
  patrolX = 0,
  patrolY = 0,
  myId = 0,
  myOwner = 0,
  ownerBeingTarget = false,
  mySp = 0,
  mySpList = {},
  mySpheres = 0,
  mySkill = {
    id = 0,
    level = 0,
    coordinates = {
      x = 0,
      y = 0,
    },
  },
  skillQueue = {},
  castUntilTick = 0,
  resetMySkill = function()
    return {
      id = 0,
      level = 0,
      coordinates = {
        x = 0,
        y = 0,
      },
    }
  end,
  stopCasting = true,
  ---@enum BattleMode
  battleMode = {
    BATTLE = 1,
    CLAW = 2,
    CURRENT = 1,
  },
  eleanorSpBeforeCast = 0,
  eleanorTriedCastSkill = false,
  ---@type UserConfig
  userConfig = require 'AI.USER_AI.config',
  myCooldowns = {
    -- AMISTR
    [HAMI_CASTLE] = 0,
    [HAMI_DEFENCE] = 0,
    [HAMI_BLOODLUST] = 0,
    -- BAYERI
    [MH_STAHL_HORN] = 0,
    [MH_GOLDENE_FERSE] = 0,
    [MH_STEINWAND] = 0,
    [MH_ANGRIFFS_MODUS] = 0,
    [MH_HEILIGE_STANGE] = 0,
    [MH_GLANZEN_SPIES] = 0,
    [MH_HEILIGE_PFERD] = 0,
    [MH_GOLDENE_TONE] = 0,
    -- DIETER
    [MH_VOLCANIC_ASH] = 0,
    [MH_LAVA_SLIDE] = 0,
    [MH_GRANITIC_ARMOR] = 0,
    [MH_MAGMA_FLOW] = 0,
    [MH_PYROCLASTIC] = 0,
    [MH_BLAST_FORGE] = 0,
    [MH_TEMPERING] = 0,
    -- EIRA
    [MH_ERASER_CUTTER] = 0,
    [MH_OVERED_BOOST] = 0,
    [MH_XENO_SLASHER] = 0,
    [MH_LIGHT_OF_REGENE] = 0,
    [MH_SILENT_BREEZE] = 0,
    [MH_TWISTER_CUTTER] = 0,
    [MH_ABSOLUTE_ZEPHYR] = 0,
    -- ELEANOR
    [MH_STYLE_CHANGE] = 0,
    [MH_SONIC_CRAW] = 0,
    [MH_SILVERVEIN_RUSH] = 0,
    [MH_MIDNIGHT_FRENZY] = 0,
    [MH_TINDER_BREAKER] = 0,
    [MH_CBC] = 0,
    [MH_EQC] = 0,
    [MH_BLAZING_AND_FURIOUS] = 0,
    [MH_THE_ONE_FIGHTER_RISES] = 0,
    -- FILIR
    [HFLI_MOON] = 0,
    [HFLI_FLEET] = 0,
    [HFLI_SPEED] = 0,
    -- LIF
    [HLIF_HEAL] = 0,
    [HLIF_AVOID] = 0,
    [HLIF_CHANGE] = 0,
    -- SERA
    [MH_NEEDLE_OF_PARALYZE] = 0,
    [MH_POISON_MIST] = 0,
    [MH_PAIN_KILLER] = 0,
    [MH_SUMMON_LEGION] = 0,
    [MH_TOXIN_OF_MANDARA] = 0,
    [MH_NEEDLE_STINGER] = 0,
    -- VANIL
    [HVAN_CAPRICE] = 0,
    [HVAN_CHAOTIC] = 0,
  },
  mySkills = {
    -- AMISTR
    ---@type Skill
    [HAMI_CASTLE] = {
      id = HAMI_CASTLE,
      sp = 10,
      cooldown = 20000,
      level = 5,
      required_level = 15,
    },
    ---@type Skill
    [HAMI_DEFENCE] = {
      id = HAMI_DEFENCE,
      sp = 40,
      cooldown = 30000,
      level = 5,
      required_level = 25,
    },
    ---@type Skill
    [HAMI_BLOODLUST] = {
      id = HAMI_BLOODLUST,
      sp = 120,
      cooldown = 60000,
      level = 3,
      required_level = 80,
    },
    -- BAYERI
    ---@type Skill
    [MH_STAHL_HORN] = {
      id = MH_STAHL_HORN,
      sp = 70,
      cooldown = 700,
      level = 10,
      required_level = 105,
    },
    ---@type Skill
    [MH_GOLDENE_FERSE] = {
      id = MH_GOLDENE_FERSE,
      sp = 80,
      cooldown = 90000,
      level = 5,
      required_level = 112,
    },
    ---@type Skill
    [MH_STEINWAND] = {
      id = MH_STEINWAND,
      sp = 120,
      cooldown = 2000,
      level = 5,
      required_level = 121,
    },
    ---@type Skill
    [MH_ANGRIFFS_MODUS] = {
      id = MH_ANGRIFFS_MODUS,
      sp = 80,
      cooldown = 30000,
      level = 5,
      required_level = 130,
    },
    ---@type Skill
    [MH_HEILIGE_STANGE] = {
      id = MH_HEILIGE_STANGE,
      sp = 100,
      cooldown = 5000,
      level = 10,
      required_level = 138,
    },
    [MH_GLANZEN_SPIES] = {
      id = MH_GLANZEN_SPIES,
      sp = 105,
      cooldown = 250,
      level = 10,
      required_level = 215,
    },
    [MH_HEILIGE_PFERD] = {
      id = MH_HEILIGE_PFERD,
      sp = 185,
      cooldown = 500,
      level = 10,
      required_level = 230,
    },
    [MH_GOLDENE_TONE] = {
      id = MH_GOLDENE_TONE,
      sp = 205,
      cooldown = 120000,
      level = 10,
      required_level = 230,
    },
    -- DIETER
    ---@type Skill
    [MH_VOLCANIC_ASH] = {
      id = MH_VOLCANIC_ASH,
      sp = 80,
      cooldown = 13000,
      level = 5,
      required_level = 102,
    },
    ---@type Skill
    [MH_LAVA_SLIDE] = {
      id = MH_LAVA_SLIDE,
      sp = 85,
      cooldown = 6000,
      level = 10,
      required_level = 109,
    },
    ---@type Skill
    [MH_GRANITIC_ARMOR] = {
      id = MH_GRANITIC_ARMOR,
      sp = 70,
      cooldown = 60000,
      level = 5,
      required_level = 116,
    },
    ---@type Skill
    [MH_MAGMA_FLOW] = {
      id = MH_MAGMA_FLOW,
      sp = 50,
      cooldown = 90000,
      level = 5,
      required_level = 122,
    },
    ---@type Skill
    [MH_PYROCLASTIC] = {
      id = MH_PYROCLASTIC,
      sp = 70,
      cooldown = 600000,
      level = 10,
      required_level = 131,
    },
    ---@type Skill
    [MH_BLAST_FORGE] = {
      id = MH_BLAST_FORGE,
      sp = 115,
      cooldown = 5000,
      level = 10,
      required_level = 215,
    },
    [MH_TEMPERING] = {
      id = MH_TEMPERING,
      sp = 155,
      cooldown = 120000,
      level = 10,
      required_level = 230,
    },
    -- EIRA
    ---@type Skill
    [MH_ERASER_CUTTER] = {
      id = MH_ERASER_CUTTER,
      sp = 70,
      cooldown = 300,
      level = 10,
      required_level = 106,
    },
    ---@type Skill
    [MH_OVERED_BOOST] = {
      id = MH_OVERED_BOOST,
      sp = 150,
      cooldown = 30000,
      level = 5,
      required_level = 114,
    },
    ---@type Skill
    [MH_XENO_SLASHER] = {
      id = MH_XENO_SLASHER,
      sp = 180,
      cooldown = 300,
      level = 10,
      required_level = 121,
    },
    ---@type Skill
    [MH_LIGHT_OF_REGENE] = {
      id = MH_LIGHT_OF_REGENE,
      sp = 40,
      cooldown = 300000,
      level = 5,
      required_level = 128,
    },
    ---@type Skill
    [MH_SILENT_BREEZE] = {
      id = MH_SILENT_BREEZE,
      sp = 160,
      cooldown = 1500,
      level = 5,
      required_level = 137,
    },
    [MH_TWISTER_CUTTER] = {
      id = MH_TWISTER_CUTTER,
      sp = 160,
      cooldown = 200,
      level = 10,
      required_level = 215,
    },
    [MH_ABSOLUTE_ZEPHYR] = {
      id = MH_ABSOLUTE_ZEPHYR,
      sp = 185,
      cooldown = 300,
      level = 10,
      required_level = 230,
    },
    -- ELEANOR
    ---@type Skill
    [MH_STYLE_CHANGE] = {
      id = MH_STYLE_CHANGE,
      cooldown = 1000,
      sp = 35,
      level = 5,
      sphere_cost = 0,
      required_level = 100,
    },
    ---@type Skill
    [MH_SONIC_CRAW] = {
      id = MH_SONIC_CRAW,
      sp = 40,
      cooldown = 500,
      level = 5,
      sphere_cost = 1,
      required_level = 100,
    },
    ---@type Skill
    [MH_SILVERVEIN_RUSH] = {
      id = MH_SILVERVEIN_RUSH,
      sp = 35,
      cooldown = 1500,
      level = 10,
      sphere_cost = 1,
      required_level = 114,
    },
    ---@type Skill
    [MH_MIDNIGHT_FRENZY] = {
      id = MH_MIDNIGHT_FRENZY,
      sp = 45,
      cooldown = 1500,
      level = 10,
      sphere_cost = 1,
      required_level = 128,
    },
    ---@type Skill
    [MH_TINDER_BREAKER] = {
      id = MH_TINDER_BREAKER,
      sp = 40,
      cooldown = 500,
      level = 5,
      sphere_cost = 1,
      required_level = 100,
    },
    ---@type Skill
    [MH_CBC] = {
      id = MH_CBC,
      sp = 50,
      cooldown = 300,
      level = 5,
      sphere_cost = 2,
      required_level = 112,
    },
    ---@type Skill
    [MH_EQC] = {
      id = MH_EQC,
      sp = 40,
      cooldown = 300,
      level = 5,
      sphere_cost = 2,
      required_level = 133,
    },
    [MH_BLAZING_AND_FURIOUS] = {
      id = MH_BLAZING_AND_FURIOUS,
      sp = 148,
      cooldown = 1000,
      level = 10,
      sphere_cost = 5,
      required_level = 215,
    },
    [MH_THE_ONE_FIGHTER_RISES] = {
      id = MH_THE_ONE_FIGHTER_RISES,
      sp = 154,
      cooldown = 2000,
      level = 10,
      sphere_cost = 0,
      required_level = 230,
    },
    -- FILIR
    ---@type Skill
    [HFLI_MOON] = {
      id = HFLI_MOON,
      sp = 20,
      cooldown = 2000,
      level = 5,
      required_level = 15,
    },
    ---@type Skill
    [HFLI_FLEET] = {
      id = HFLI_FLEET,
      sp = 70,
      cooldown = 120000,
      level = 5,
      required_level = 25,
    },
    ---@type Skill
    [HFLI_SPEED] = {
      id = HFLI_SPEED,
      sp = 70,
      cooldown = 120000,
      level = 5,
      required_level = 40,
    },
    -- LIF
    ---@type Skill
    [HLIF_HEAL] = {
      id = HLIF_HEAL,
      sp = 25,
      cooldown = 20000,
      level = 5,
      required_level = 15,
    },
    ---@type Skill
    [HLIF_AVOID] = {
      id = HLIF_AVOID,
      sp = 40,
      cooldown = 35000,
      level = 5,
      required_level = 25,
    },
    ---@type Skill
    [HLIF_CHANGE] = {
      id = HLIF_CHANGE,
      sp = 100,
      cooldown = 300000,
      level = 3,
      required_level = 40,
    },
    -- SERA
    ---@type Skill
    [MH_NEEDLE_OF_PARALYZE] = {
      id = MH_NEEDLE_OF_PARALYZE,
      sp = 96,
      cooldown = 200,
      level = 10,
      required_level = 105,
    },
    ---@type Skill
    [MH_POISON_MIST] = {
      id = MH_POISON_MIST,
      sp = 105,
      cooldown = 15000,
      level = 5,
      required_level = 116,
    },
    ---@type Skill
    [MH_PAIN_KILLER] = {
      id = MH_PAIN_KILLER,
      sp = 64,
      cooldown = 600000,
      level = 10,
      required_level = 123,
    },
    ---@type Skill
    [MH_SUMMON_LEGION] = {
      id = MH_SUMMON_LEGION,
      sp = 140,
      cooldown = 30000,
      level = 5,
      required_level = 132,
    },
    ---@type Skill
    [MH_TOXIN_OF_MANDARA] = {
      id = MH_TOXIN_OF_MANDARA,
      sp = 105,
      cooldown = 7000,
      cast_time = 700,
      level = 10,
      required_level = 215,
    },
    ---@type Skill
    [MH_NEEDLE_STINGER] = {
      id = MH_NEEDLE_STINGER,
      sp = 146,
      level = 10,
      cooldown = 250,
      cast_time = 300,
      required_level = 230,
    },
    -- VANIL
    ---@type Skill
    [HVAN_CAPRICE] = {
      id = HVAN_CAPRICE,
      sp = 30,
      cooldown = 3000,
      level = 5,
      required_level = 15,
    },
    ---@type Skill
    [HVAN_CHAOTIC] = {
      id = HVAN_CHAOTIC,
      sp = 40,
      cooldown = 3000,
      level = 5,
      required_level = 25,
    },
  },
}

---@enum Status
STATUS = {
  RUNNING = 1,
  SUCCESS = 2,
  FAILURE = 3,
}

---@param nodes Nodes
function Sequence(nodes)
  local index = 1
  return function()
    while index <= #nodes do
      ---@type Node
      local node = nodes[index]
      local status = node(blackboard)
      if status == STATUS.SUCCESS then
        index = index + 1
      elseif status == STATUS.RUNNING then
        return STATUS.RUNNING
      else
        index = 1
        return STATUS.FAILURE
      end
    end
    index = 1
    return STATUS.SUCCESS
  end
end

---@param nodes Nodes
function Selector(nodes)
  local index = 1
  return function()
    while index <= #nodes do
      local node = nodes[index]
      local status = node(blackboard)
      if status == STATUS.SUCCESS then
        index = 1
        return STATUS.SUCCESS
      elseif status == STATUS.RUNNING then
        index = index
        return STATUS.RUNNING
      else
        index = index + 1
      end
    end
    index = 1
    return STATUS.FAILURE
  end
end

---@param nodes Nodes
function Parallel(nodes)
  return function()
    local allSuccess = true
    local hasRunning = false

    for _, node in ipairs(nodes) do
      local status = node(blackboard)

      if status == STATUS.FAILURE then
        return STATUS.FAILURE
      elseif status == STATUS.RUNNING then
        hasRunning = true
        allSuccess = false
      elseif status ~= STATUS.SUCCESS then
        allSuccess = false
      end
    end

    if allSuccess then
      return STATUS.SUCCESS
    elseif hasRunning then
      return STATUS.RUNNING
    else
      return STATUS.FAILURE
    end
  end
end

---@param node Node
---@param delay number
function Delay(node, delay)
  local lastExec = 0
  return function()
    local now = GetTick()
    if now - lastExec >= delay then
      lastExec = now
      return node(blackboard)
    else
      return STATUS.RUNNING
    end
  end
end

---@param node Node
---@return fun(): Status
function Reverse(node)
  return function()
    local status = node(blackboard)
    if status == STATUS.SUCCESS then
      return STATUS.FAILURE
    elseif status == STATUS.FAILURE then
      return STATUS.SUCCESS
    else
      return status
    end
  end
end

---@param node Node
---@param ... fun():boolean
---@return fun():Status
function Conditions(node, ...)
  local conditions = { ... }
  return function()
    for _, condition in ipairs(conditions) do
      if not condition() then
        return STATUS.FAILURE
      end
    end
    return node(blackboard)
  end
end

---@alias condition fun(blackboard: Blackboard)> boolean

---@param node Node
---@param condition condition
---@return Node
function Condition(node, condition)
  return function()
    if not condition(blackboard) then
      return STATUS.FAILURE
    end
    return node(blackboard)
  end
end

---@param node Node
---@param condition condition
---@return Node
function Unless(node, condition)
  return function()
    if condition(blackboard) then
      return STATUS.FAILURE
    end
    return node(blackboard)
  end
end

---@param node Node
---@param percentage number
---@return Node
function FailRandomly(node, percentage)
  return function()
    if ChanceDoOrGainSomething(percentage) then
      return STATUS.FAILURE
    end
    return node(blackboard)
  end
end

---@param nodes Nodes
---@return fun(): Status
function Random(nodes)
  return function()
    if #nodes == 0 then
      return STATUS.FAILURE
    end
    local index = math.random(1, #nodes)
    local node = nodes[index]
    local status = node(blackboard)
    if status == STATUS.SUCCESS then
      return STATUS.SUCCESS
    elseif status == STATUS.RUNNING then
      return STATUS.RUNNING
    else
      for i = 1, #nodes do
        if i ~= index then
          local s = nodes[i](blackboard)
          if s == STATUS.SUCCESS or s == STATUS.RUNNING then
            return s
          end
        end
      end
      return STATUS.FAILURE
    end
  end
end
local dieter = require 'AI.USER_AI.HOMUN.Dieter'
local sera = require 'AI.USER_AI.HOMUN.Sera'
local eira = require 'AI.USER_AI.HOMUN.Eira'
local bayeri = require 'AI.USER_AI.HOMUN.Bayeri'
local eleanor = require 'AI.USER_AI.HOMUN.Eleanor'
local vanil = require 'AI.USER_AI.HOMUN.Vanil'
local amistr = require 'AI.USER_AI.HOMUN.Amistr'
local lif = require 'AI.USER_AI.HOMUN.Lif'
local filir = require 'AI.USER_AI.HOMUN.Filir'
local services = require 'AI.USER_AI.BT.nodes.service'
---@type CommandNode
local commandNodes = require 'AI.USER_AI.BT.nodes.commands'
---@type HomunNode
local homun = require 'AI.USER_AI.BT.nodes.homun'
local tree = Parallel {
  Delay(services.searchForEnemies, 300),
  Delay(services.clearDeadEnemies, 1000),
  Delay(services.sortEnemiesByDistance, 1000),
  Delay(services.checkIsAttackingOwner, 500),
  Delay(commandNodes.processUserCommands, 300),
  Selector {
    Condition(dieter, homun.isDieter),
    Condition(sera, homun.isSera),
    Condition(eira, homun.isEira),
    Condition(bayeri, homun.isBayeri),
    Condition(eleanor, homun.isEleanor),
    Condition(vanil, homun.isVanilmirth),
    Condition(amistr, homun.isAmistr),
    Condition(lif, homun.isLif),
    Condition(filir, homun.isFilir),
  },
}
local timeout = 0

---@param bb Blackboard
local function checkCurrentBattleMode(bb)
  if not bb.eleanorTriedCastSkill then
    return
  end

  local currentTick = GetTick()

  if #bb.mySpList < 3 then
    if currentTick >= timeout then
      table.insert(bb.mySpList, bb.mySp)
      timeout = currentTick + 1000
    end
    return
  end

  local wrongBattleMode = true

  while #bb.mySpList > 0 do
    local currentSp = table.remove(bb.mySpList, 1)
    if currentSp < bb.eleanorSpBeforeCast then
      wrongBattleMode = false
      break
    end
  end
  if wrongBattleMode then
    if bb.battleMode.CURRENT == bb.battleMode.BATTLE then
      bb.battleMode.CURRENT = bb.battleMode.CLAW
    else
      bb.battleMode.CURRENT = bb.battleMode.BATTLE
    end
  end

  bb.eleanorTriedCastSkill = false
  bb.eleanorSpBeforeCast = 0
end

---@alias Position { x: number, y: number }

---@param myPosition Position
---@param ownerPosition Position
---@return boolean
local function ownerUseTeleport(myPosition, ownerPosition)
  return myPosition.x == ownerPosition.x and myPosition.y == ownerPosition.y
end

---@param myid number
function YggAI(myid)
  blackboard.myId = myid
  blackboard.myOwner = GetV(V_OWNER, myid)
  blackboard.mySp = GetV(V_SP, myid)
  local myX, myY = GetV(V_POSITION, blackboard.myId)
  local ownerX, ownerY = GetV(V_POSITION, blackboard.myOwner)
  if ownerUseTeleport({ x = myX, y = myY }, { x = ownerX, y = ownerY }) then
    MoveToOwner(blackboard.myId)
    return
  end
  if homun.isEleanor(blackboard) then
    checkCurrentBattleMode(blackboard)
  end
  if #blackboard.myEnemies == 0 then
    blackboard.stopCasting = true
    if #blackboard.skillQueue > 0 then
      blackboard.skillQueue = {}
    end
    if homun.isDieter(blackboard) then
      blackboard.myCooldowns[MH_LAVA_SLIDE] = 500
    end
  end
  tree()
end
