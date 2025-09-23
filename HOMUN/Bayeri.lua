---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [MH_STAHL_HORN] = 0,
  [MH_GOLDENE_FERSE] = 0,
  [MH_STEINWAND] = 0,
  [MH_ANGRIFFS_MODUS] = 0,
  [MH_HEILIGE_STANGE] = 0,
}

---@class Skills
local MySkills = {
  [MH_STAHL_HORN] = {
    id = MH_STAHL_HORN,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.7
    end,
    level = 10,
  },
  [MH_GOLDENE_FERSE] = {
    id = MH_GOLDENE_FERSE,
    sp = 80,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 2
    end,
    level = 5,
  },
  [MH_STEINWAND] = {
    id = MH_STEINWAND,
    sp = 120,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 2
    end,
    level = 5,
  },
  [MH_ANGRIFFS_MODUS] = {
    id = MH_ANGRIFFS_MODUS,
    sp = 80,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 30
    end,
    level = 5,
  },
  [MH_HEILIGE_STANGE] = {
    id = MH_HEILIGE_STANGE,
    sp = 100,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 5
    end,
    level = 10,
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

-- skills
local stahl = {}
function stahl.condition()
  return isSkillCastable(MH_STAHL_HORN)
end
function stahl.cast()
  return cast(MH_STAHL_HORN, MyEnemy, { targetType = 'target', keepRunning = false })
end

local gold = {}
function gold.condition()
  return isSkillCastable(MH_GOLDENE_FERSE)
end
function gold.cast()
  return cast(MH_GOLDENE_FERSE, MyEnemy, { targetType = 'target', keepRunning = false })
end

local stein = {}
function stein.condition()
  return isSkillCastable(MH_STEINWAND)
end
function stein.cast()
  return cast(MH_STEINWAND, MyOwner, { targetType = 'target', keepRunning = false })
end

local ang = {}
function ang.condition()
  return isSkillCastable(MH_ANGRIFFS_MODUS)
end
function ang.cast()
  return cast(MH_ANGRIFFS_MODUS, MyOwner, { targetType = 'target', keepRunning = false })
end

local heil = {}
function heil.condition()
  return isSkillCastable(MH_HEILIGE_STANGE)
end
function heil.cast()
  return cast(MH_HEILIGE_STANGE, MyEnemy, { targetType = 'target', keepRunning = false })
end

local AttackAndChase = Parallel({
  Condition(node.basicAttack, Inversion(stahl.condition)),
  node.chaseEnemy,
})

local stahlAttack = Parallel({
  Condition(stahl.cast, stahl.condition),
  node.chaseEnemy,
})

local darkOrUndeadMonster = function()
  return condition.isDarkMonster() or condition.isUndeadMonster()
end

local combat = Selector({
  Condition(stein.cast, condition.ownerIsDying, stein.condition),
  Condition(stein.cast, stein.condition),
  Condition(stahlAttack, condition.enemyIsAlive, stahl.condition),
  Condition(gold.cast, condition.enemyIsAlive, gold.condition, darkOrUndeadMonster),
  Condition(heil.cast, condition.enemyIsAlive, heil.condition, darkOrUndeadMonster),
  Condition(ang.cast, ang.condition),
  Condition(
    heil.cast,
    condition.ownerIsNotTooFar,
    condition.enemyIsAlive,
    heil.condition,
    Inversion(condition.isHolyMonster)
  ),
  Condition(AttackAndChase, condition.enemyIsAlive),
})

local bayeri = Selector({
  Condition(combat, condition.hasEnemyOrInList, condition.ownerIsNotTooFar),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemy)),
})

return Condition(bayeri, IsBayeri)
