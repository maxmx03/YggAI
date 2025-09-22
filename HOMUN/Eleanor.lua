---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

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
  },
}

---@enum BattleMode
BATTLE_MODE = {
  BATTLE = 1,
  CLAW = 2,
  CURRENT = 1,
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
  if casted == STATUS.RUNNING then
    MyCooldown[skill] = GetTickInSeconds()
    return STATUS.RUNNING
  elseif casted == STATUS.SUCCESS then
    MyCooldown[skill] = GetTickInSeconds()
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
  return isSkillCastable(MH_SONIC_CRAW, { targetType = 'target', keepRunning = false })
end
function sonic.cast()
  if not silver.condition() and not midnight.condition() then
    return cast(MH_SONIC_CRAW, MyEnemy, { targetType = 'target', keepRunning = true })
  end
  return cast(MH_SONIC_CRAW, MyEnemy, { targetType = 'target', keepRunning = false })
end
local battleComboSequence = Sequence({
  Condition(sonic.cast, condition.ownerIsNotTooFar, sonic.condition),
  Condition(Delay(silver.cast, 2.0), condition.ownerIsNotTooFar, silver.condition),
  Condition(Delay(midnight.cast, 2.0), condition.ownerIsNotTooFar, midnight.condition),
})
local battleComboMode = Parallel({
  Condition(Condition(battleComboSequence, condition.enemyIsAlive), condition.ownerIsNotTooFar),
  Condition(node.chaseEnemy, condition.enemyIsNotOutOfSight),
})
local AttackAndChase = Parallel({
  Condition(node.basicAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, Inversion(sonic.condition)),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local AttackAndChaseGainSpheres = Parallel({
  Condition(
    node.EleanorBasicAttack,
    condition.ownerIsNotTooFar,
    condition.enemyIsAlive,
    Inversion(condition.hasAllSpheres)
  ),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local combat = Selector({
  Condition(Condition(battleComboMode, condition.enemyIsAlive), condition.ownerIsNotTooFar),
  Condition(AttackAndChaseGainSpheres, condition.ownerIsNotTooFar, Inversion(condition.hasAllSpheres)),
  Condition(AttackAndChase, condition.ownerIsNotTooFar, Inversion(sonic.condition)),
})
local eleanor = Selector({
  Condition(combat, condition.hasEnemyOrInList),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemyOrInList)),
})

return Condition(eleanor, IsEleanor)
