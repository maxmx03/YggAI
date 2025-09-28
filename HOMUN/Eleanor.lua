---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [MH_STYLE_CHANGE] = 0,
  [MH_SONIC_CRAW] = 0,
  [MH_SILVERVEIN_RUSH] = 0,
  [MH_MIDNIGHT_FRENZY] = 0,
  [MH_TINDER_BREAKER] = 0,
  [MH_CBC] = 0,
  [MH_EQC] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_STYLE_CHANGE] = {
    id = MH_STYLE_CHANGE,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 1
    end,
    sp = 35,
    level = 5,
    sphere_cost = 0,
    required_level = 100,
  },
  ---@type Skill
  [MH_SONIC_CRAW] = {
    id = MH_SONIC_CRAW,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.5
    end,
    level = 5,
    sphere_cost = 1,
    required_level = 100,
  },
  ---@type Skill
  [MH_SILVERVEIN_RUSH] = {
    id = MH_SILVERVEIN_RUSH,
    sp = 35,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 1.5
    end,
    level = 10,
    sphere_cost = 1,
    required_level = 114,
  },
  ---@type Skill
  [MH_MIDNIGHT_FRENZY] = {
    id = MH_MIDNIGHT_FRENZY,
    sp = 45,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 1.5
    end,
    level = 10,
    sphere_cost = 1,
    required_level = 128,
  },
  ---@type Skill
  [MH_TINDER_BREAKER] = {
    id = MH_TINDER_BREAKER,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.5
    end,
    level = 5,
    sphere_cost = 1,
    required_level = 100,
  },
  ---@type Skill
  [MH_CBC] = {
    id = MH_CBC,
    sp = 50,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.3
    end,
    level = 5,
    sphere_cost = 2,
    required_level = 112,
  },
  ---@type Skill
  [MH_EQC] = {
    id = MH_EQC,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.3
    end,
    level = 5,
    sphere_cost = 2,
    required_level = 133,
  },
}

---@enum BattleMode
BATTLE_MODE = {
  BATTLE = 1,
  CLAW = 2,
  CURRENT = 1,
  isBattleMode = function()
    return BATTLE_MODE.CURRENT == BATTLE_MODE.BATTLE
  end,
  isClawMode = function()
    return BATTLE_MODE.CURRENT == BATTLE_MODE.CLAW
  end,
}

---@param mySkill number
local isSkillCastable = function(mySkill)
  MySkill = mySkill
  ---@type Skill
  local skill = MySkills[MySkill]
  local cooldown = MyCooldown[MySkill]
  return condition.isSkillCastable(skill, cooldown)
end

---@param skill number
---@param target number
---@param opts SkillOpts
---@return Status
local cast = function(skill, target, opts)
  local casted = node.castSkill(MySkills[skill], MyCooldown[skill], target, opts)
  local spAfterCast = GetV(V_SP, MyID)
  if casted == STATUS.FAILURE or (spAfterCast >= EleanorSP and EleanorSP > 0) then
    if BATTLE_MODE.CURRENT == BATTLE_MODE.BATTLE then
      BATTLE_MODE.CURRENT = BATTLE_MODE.CLAW
    else
      BATTLE_MODE.CURRENT = BATTLE_MODE.BATTLE
    end
    MySkill = 0
  end
  if casted == STATUS.RUNNING then
    MyCooldown[skill] = GetTickInSeconds()
    if MySpheres > 0 then
      MySpheres = math.max(0, MySpheres - MySkills[skill].sphere_cost)
    end
    return STATUS.RUNNING
  elseif casted == STATUS.SUCCESS then
    MyCooldown[skill] = GetTickInSeconds()
    if MySpheres > 0 then
      MySpheres = math.max(0, MySpheres - MySkills[skill].sphere_cost)
    end
    MySkill = 0
    return STATUS.SUCCESS
  end

  return STATUS.FAILURE
end

local silver = {}
function silver.condition()
  return isSkillCastable(MH_SILVERVEIN_RUSH)
end
function silver.cast()
  return cast(MH_SILVERVEIN_RUSH, MyEnemy, { targetType = 'target', keepRunning = false })
end
local midnight = {}
function midnight.condition()
  return isSkillCastable(MH_MIDNIGHT_FRENZY)
end
function midnight.cast()
  return cast(MH_MIDNIGHT_FRENZY, MyEnemy, { targetType = 'target', keepRunning = false })
end
local sonic = {}
function sonic.condition()
  return isSkillCastable(MH_SONIC_CRAW)
end
function sonic.cast()
  if not silver.condition() or not midnight.condition() then
    return cast(MH_SONIC_CRAW, MyEnemy, { targetType = 'target', keepRunning = true })
  end
  return cast(MH_SONIC_CRAW, MyEnemy, { targetType = 'target', keepRunning = false })
end
local tinder = {}
function tinder.condition()
  return isSkillCastable(MH_TINDER_BREAKER)
end
function tinder.cast()
  return cast(MH_TINDER_BREAKER, MyEnemy, { targetType = 'target', keepRunning = false })
end
local cbc = {}
function cbc.condition()
  return isSkillCastable(MH_CBC)
end
function cbc.cast()
  return cast(MH_CBC, MyEnemy, { targetType = 'target', keepRunning = false })
end
local eqc = {}
function eqc.condition()
  return isSkillCastable(MH_EQC)
end
function eqc.cast()
  return cast(MH_EQC, MyEnemy, { targetType = 'target', keepRunning = false })
end

local BattleComboSequence = Condition(
  Sequence({
    Condition(sonic.cast, sonic.condition),
    Condition(Delay(silver.cast, 2.0), silver.condition),
    Condition(Delay(midnight.cast, 2.0), midnight.condition),
  }),
  Inversion(condition.enemyIsNotInAttackSight)
)
local ClawComboSequence = Condition(
  Sequence({
    Condition(tinder.cast, tinder.condition),
    Condition(Delay(cbc.cast, 2.0), cbc.condition),
    Condition(Delay(eqc.cast, 2.0), eqc.condition),
  }),
  Inversion(condition.enemyIsNotInAttackSight)
)
local BattleComboMode = Sequence({
  node.chaseEnemy,
  BattleComboSequence,
})
local ClawComboMode = Sequence({
  node.chaseEnemy,
  ClawComboSequence,
})
local AttackAndChaseGainSpheres = Parallel({
  Conditions(node.EleanorBasicAttack),
  node.chaseEnemy,
})
local combat = Selector({
  Condition(BattleComboMode, BATTLE_MODE.isBattleMode),
  Condition(ClawComboMode, BATTLE_MODE.isClawMode),
  Condition(AttackAndChaseGainSpheres, Inversion(condition.hasAllSpheres)),
  Condition(node.attackAndChase, Inversion(sonic.condition)),
})
---@type Homun
local eleanor = Homun(MySkills, MyCooldown)
return Condition(eleanor.root(combat), IsEleanor)
