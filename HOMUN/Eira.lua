---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [MH_ERASER_CUTTER] = 0,
  [MH_OVERED_BOOST] = 0,
  [MH_XENO_SLASHER] = 0,
  [MH_LIGHT_OF_REGENE] = 0,
  [MH_SILENT_BREEZE] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_ERASER_CUTTER] = {
    id = MH_ERASER_CUTTER,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.3
    end,
    level = 10,
  },
  ---@type Skill
  [MH_OVERED_BOOST] = {
    id = MH_OVERED_BOOST,
    sp = 150,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 30
    end,
    level = 5,
  },
  ---@type Skill
  [MH_XENO_SLASHER] = {
    id = MH_XENO_SLASHER,
    sp = 180,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.3
    end,
    level = 10,
  },
  ---@type Skill
  [MH_LIGHT_OF_REGENE] = {
    id = MH_LIGHT_OF_REGENE,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 300
    end,
    level = 5,
  },
  ---@type Skill
  [MH_SILENT_BREEZE] = {
    id = MH_SILENT_BREEZE,
    sp = 160,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 1.5
    end,
    level = 5,
  },
}

local isSkillCastable = function(mySkill)
  MySkill = mySkill
  local s = MySkills[mySkill]
  local lastTime = MyCooldown[mySkill]
  return condition.isSkillCastable(s, lastTime)
end

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
  MySkill = 0
  return STATUS.FAILURE
end

local cutter = {}
function cutter.condition()
  return isSkillCastable(MH_ERASER_CUTTER)
end
function cutter.cast()
  return cast(MH_ERASER_CUTTER, MyEnemy, { targetType = 'target', keepRunning = true })
end

local overed = {}
function overed.condition()
  return isSkillCastable(MH_OVERED_BOOST)
end
function overed.cast()
  return cast(MH_OVERED_BOOST, MyID, { targetType = 'target', keepRunning = false })
end

local xeno = {}
function xeno.condition()
  return isSkillCastable(MH_XENO_SLASHER)
end
function xeno.cast()
  return cast(MH_XENO_SLASHER, MyEnemy, { targetType = 'ground', keepRunning = true })
end

local light = {}
function light.condition()
  return isSkillCastable(MH_LIGHT_OF_REGENE)
end
function light.cast()
  return cast(MH_LIGHT_OF_REGENE, MyOwner, { targetType = 'target', keepRunning = false })
end
local AttackAndChase = Parallel({
  Condition(node.basicAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, Inversion(cutter.condition)),
  Condition(node.chaseEnemy, condition.enemyIsNotInAttackSight, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local cutterAttack = Parallel({
  Condition(cutter.cast, cutter.condition, condition.ownerIsNotTooFar, condition.enemyIsAlive),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local xenoAttack = Parallel({
  Condition(xeno.cast, xeno.condition, condition.ownerIsNotTooFar, condition.enemyIsAlive),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local combat = Selector({
  Condition(overed.cast, condition.isMVP, overed.condition),
  Condition(xenoAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, condition.isWaterMonster),
  Condition(xenoAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, condition.isPoisonMonster),
  Condition(xenoAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, Inversion(condition.isWindMonster)),
  Condition(cutterAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive),
  Condition(AttackAndChase, condition.ownerIsNotTooFar, condition.enemyIsAlive, Inversion(cutter.condition)),
})
local eira = Selector({
  Condition(combat, condition.hasEnemyOrInList),
  Condition(light.cast, condition.ownerIsDead, light.condition),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemyOrInList)),
})
return Condition(eira, IsEira)
