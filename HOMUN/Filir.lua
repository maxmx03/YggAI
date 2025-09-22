---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [HFLI_MOON] = 0,
  [HFLI_FLEET] = 0,
  [HFLI_SPEED] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HFLI_MOON] = {
    id = HFLI_MOON,
    sp = 20,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 2
    end,
    level = 5,
  },
  ---@type Skill
  [HFLI_FLEET] = {
    id = HFLI_FLEET,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 120
    end,
    level = 5,
  },
  ---@type Skill
  [HFLI_SPEED] = {
    id = HFLI_SPEED,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 120
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

local moon = {}
function moon.condition()
  return isSkillCastable(HFLI_MOON)
end
function moon.cast()
  return cast(HFLI_MOON, MyEnemy, { targetType = 'target', keepRunning = false })
end
local fleet = {}
function fleet.condition()
  return isSkillCastable(HFLI_FLEET)
end
function fleet.cast()
  return cast(HFLI_FLEET, MyID, { targetType = 'target', keepRunning = false })
end
local speed = {}
function speed.condition()
  return isSkillCastable(HFLI_SPEED)
end
function speed.cast()
  return cast(HFLI_SPEED, MyID, { targetType = 'target', keepRunning = false })
end
local AttackAndChase = Parallel({
  Condition(node.basicAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, Inversion(moon.condition)),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local moonParallel = Parallel({
  Condition(moon.cast, moon.condition, condition.enemyIsAlive),
  Condition(node.chaseEnemy, condition.enemyIsNotOutOfSight),
})
local combat = Selector({
  Condition(fleet.cast, fleet.condition, condition.ownerIsDying),
  Condition(moonParallel, condition.enemyIsAlive),
  Condition(speed.cast, speed.condition, condition.enemyIsAlive),
  Condition(fleet.cast, fleet.condition, condition.enemyIsAlive),
  Condition(AttackAndChase, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local filir = Selector({
  Condition(combat, condition.hasEnemyOrInList),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemyOrInList)),
})
return Condition(filir, IsFilir)
