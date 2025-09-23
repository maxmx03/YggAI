---@class Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [MH_NEEDLE_OF_PARALYZE] = 0,
  [MH_POISON_MIST] = 0,
  [MH_PAIN_KILLER] = 0,
  [MH_SUMMON_LEGION] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_NEEDLE_OF_PARALYZE] = {
    id = MH_NEEDLE_OF_PARALYZE,
    sp = 96,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.2
    end,
    level = 10,
  },
  ---@type Skill
  [MH_POISON_MIST] = {
    id = MH_POISON_MIST,
    sp = 105,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 15
    end,
    level = 5,
  },
  ---@type Skill
  [MH_PAIN_KILLER] = {
    id = MH_PAIN_KILLER,
    sp = 64,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 600
    end,
    level = 10,
  },
  ---@type Skill
  [MH_SUMMON_LEGION] = {
    id = MH_SUMMON_LEGION,
    sp = 140,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 30
    end,
    level = 5,
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

local paralyse = {}
function paralyse.condition()
  return isSkillCastable(MH_NEEDLE_OF_PARALYZE)
end
function paralyse.cast()
  return cast(MH_NEEDLE_OF_PARALYZE, MyEnemy, { targetType = 'target', keepRunning = true })
end
local poison = {}
function poison.condition()
  return isSkillCastable(MH_POISON_MIST)
end
function poison.cast()
  return cast(MH_POISON_MIST, MyEnemy, { targetType = 'ground', keepRunning = false })
end

local pain = {}
function pain.condition()
  return isSkillCastable(MH_PAIN_KILLER)
end
function pain.cast()
  return cast(MH_PAIN_KILLER, MyID, { targetType = 'target', keepRunning = false })
end
local legion = {}
function legion.condition()
  return isSkillCastable(MH_SUMMON_LEGION)
end
function legion.cast()
  return cast(MH_SUMMON_LEGION, MyEnemy, { targetType = 'target', keepRunning = false })
end
local AttackAndChaseParalyze = Parallel({
  Condition(node.basicAttack, Inversion(paralyse.condition)),
  node.chaseEnemy,
})
local tryParaliseEnemy = Parallel({
  Condition(paralyse.cast, paralyse.condition),
  node.chaseEnemy,
})
local invokeLegion = Parallel({
  Condition(legion.cast, legion.condition),
  node.chaseEnemy,
})
local combat = Selector({
  Condition(invokeLegion, condition.isMVP),
  Condition(tryParaliseEnemy, paralyse.condition, Inversion(poison.condition)),
  Condition(poison.cast, poison.condition, condition.enemyIsAlive),
  Condition(pain.cast, pain.condition, condition.enemyIsAlive),
  Condition(AttackAndChaseParalyze, Inversion(paralyse.condition), condition.enemyIsAlive),
})
local sera = Selector({
  Condition(combat, condition.hasEnemyOrInList, condition.ownerIsNotTooFar),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemyOrInList)),
})
return Condition(sera, IsSera)
