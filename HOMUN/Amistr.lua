---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [HAMI_CASTLE] = 0,
  [HAMI_DEFENCE] = 0,
  [HAMI_BLOODLUST] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HAMI_CASTLE] = {
    id = HAMI_CASTLE,
    sp = 10,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 20
    end,
    level = 5,
  },
  ---@type Skill
  [HAMI_DEFENCE] = {
    id = HAMI_DEFENCE,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 30
    end,
    level = 5,
  },
  ---@type Skill
  [HAMI_BLOODLUST] = {
    id = HAMI_BLOODLUST,
    sp = 120,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 60
    end,
    level = 3,
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

local castle = {}
function castle.condition()
  return isSkillCastable(HAMI_CASTLE)
end
function castle.cast()
  return cast(HAMI_CASTLE, MyID, { targetType = 'target', keepRunning = false })
end

local defense = {}
function defense.condition()
  return isSkillCastable(HAMI_DEFENCE)
end
function defense.cast()
  return cast(HAMI_DEFENCE, MyID, { targetType = 'target', keepRunning = false })
end

local bloodlust = {}
function bloodlust.condition()
  return isSkillCastable(HAMI_BLOODLUST)
end
function bloodlust.cast()
  return cast(HAMI_BLOODLUST, MyID, { targetType = 'target', keepRunning = false })
end

local AttackAndChase = Parallel({
  Condition(node.basicAttack, Inversion(bloodlust.condition)),
  node.chaseEnemy,
})

local combat = Selector({
  Condition(castle.cast, castle.condition, condition.ownerIsDying),
  Condition(defense.cast, defense.condition, condition.enemyIsAlive),
  Condition(bloodlust.cast, bloodlust.condition, condition.enemyIsAlive),
  Condition(AttackAndChase, condition.enemyIsAlive),
})

local amistr = Selector({
  Condition(combat, condition.hasEnemyOrInList, condition.ownerIsNotTooFar),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemy)),
})

return Condition(amistr, IsAmistr)
