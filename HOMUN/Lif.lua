---@class Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [HLIF_HEAL] = 0,
  [HLIF_AVOID] = 0,
  [HLIF_CHANGE] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HLIF_HEAL] = {
    id = HLIF_HEAL,
    sp = 25,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 20
    end,
    level = 5,
  },
  ---@type Skill
  [HLIF_AVOID] = {
    id = HLIF_AVOID,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 35
    end,
    level = 5,
  },
  [HLIF_CHANGE] = {
    id = HLIF_CHANGE,
    sp = 100,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 5 * 60
    end,
    level = 3,
  },
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

local heal = {}
function heal.condition()
  return isSkillCastable(HLIF_HEAL)
end
function heal.cast()
  if LifCanHeal then
    return cast(HLIF_HEAL, MyOwner, { keepRunning = false, targetType = 'target' })
  end
  return STATUS.FAILURE
end
local avoid = {}
function avoid.condition()
  return isSkillCastable(HLIF_AVOID)
end
function avoid.cast()
  return cast(HLIF_AVOID, MyOwner, { targetType = 'target', keepRunning = false })
end
local change = {}
function change.condition()
  return isSkillCastable(HLIF_CHANGE)
end
function change.cast()
  return cast(HLIF_CHANGE, MyID, { keepRunning = false, targetType = 'target' })
end
local AttackAndChase = Parallel({
  node.basicAttack,
  node.chaseEnemy,
})
local combat = Selector({
  Condition(heal.cast, heal.condition, condition.ownerIsDying),
  Condition(avoid.cast, avoid.condition, condition.enemyIsAlive),
  Condition(change.cast, change.condition, condition.enemyIsAlive),
  AttackAndChase,
})
local lif = Selector({
  Condition(combat, condition.hasEnemyOrInList, condition.ownerIsNotTooFar),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemyOrInList)),
})
return Condition(lif, IsLif)
