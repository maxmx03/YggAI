---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [MH_VOLCANIC_ASH] = 0,
  [MH_LAVA_SLIDE] = 0,
  [MH_GRANITIC_ARMOR] = 0,
  [MH_MAGMA_FLOW] = 0,
  [MH_PYROCLASTIC] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_VOLCANIC_ASH] = {
    id = MH_VOLCANIC_ASH,
    sp = 80,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 10
    end,
    level = 5,
  },
  ---@type Skill
  [MH_LAVA_SLIDE] = {
    id = MH_LAVA_SLIDE,
    sp = 85,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 15
    end,
    level = 10,
  },
  ---@type Skill
  [MH_GRANITIC_ARMOR] = {
    id = MH_GRANITIC_ARMOR,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 60
    end,
    level = 5,
  },
  ---@type Skill
  [MH_MAGMA_FLOW] = {
    id = MH_MAGMA_FLOW,
    sp = 50,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 90
    end,
    level = 5,
  },
  ---@type Skill
  [MH_PYROCLASTIC] = {
    id = MH_PYROCLASTIC,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 600
    end,
    level = 10,
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

local volcanic = {}
function volcanic.cast()
  return cast(MH_VOLCANIC_ASH, MyEnemy, { targetType = 'ground', keepRunning = false })
end
function volcanic.condition()
  return isSkillCastable(MH_VOLCANIC_ASH)
end
local lava = {}
function lava.cast()
  return cast(MH_LAVA_SLIDE, MyEnemy, { targetType = 'ground', keepRunning = false })
end
function lava.condition()
  return isSkillCastable(MH_LAVA_SLIDE)
end
local granitic = {}
function granitic.cast()
  return cast(MH_GRANITIC_ARMOR, MyID, { targetType = 'target', keepRunning = false })
end
function granitic.condition()
  return isSkillCastable(MH_GRANITIC_ARMOR)
end
local magma = {}
function magma.cast()
  return cast(MH_MAGMA_FLOW, MyID, { targetType = 'target', keepRunning = false })
end
function magma.condition()
  return isSkillCastable(MH_MAGMA_FLOW)
end
local pyroclastic = {}
function pyroclastic.cast()
  return cast(MH_PYROCLASTIC, MyID, { targetType = 'target', keepRunning = false })
end
function pyroclastic.condition()
  return isSkillCastable(MH_PYROCLASTIC)
end

local AttackAndChase = Parallel({
  Condition(node.basicAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local AttackAndChaseLava = Parallel({
  Condition(node.basicAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, Inversion(lava.condition)),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})
local lavaAttack = Parallel({
  Condition(lava.cast, lava.condition, condition.ownerIsNotTooFar, condition.enemyIsAlive),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})

local volcanicAttack = Parallel({
  Condition(volcanic.cast, volcanic.condition, condition.ownerIsNotTooFar, condition.enemyIsAlive),
  Condition(node.chaseEnemy, condition.ownerIsNotTooFar, condition.enemyIsAlive),
})

local combat = Selector({
  Condition(granitic.cast, granitic.condition, condition.ownerIsDying, condition.enemyIsAlive),
  Condition(lavaAttack, condition.ownerIsNotTooFar, condition.enemyIsAlive, Inversion(condition.isFireMonster)),
  Condition(
    magma.cast,
    magma.condition,
    condition.ownerIsNotTooFar,
    condition.enemyIsAlive,
    Inversion(condition.isFireMonster)
  ),
  Condition(volcanicAttack, condition.isWaterMonster),
  Condition(volcanicAttack, condition.isPlantMonster),
  Condition(pyroclastic.cast, pyroclastic.condition, condition.enemyIsAlive),
  Condition(AttackAndChaseLava, Inversion(lava.condition), condition.enemyIsAlive, Inversion(condition.isFireMonster)),
  Condition(AttackAndChase, condition.ownerIsNotTooFar, condition.enemyIsAlive, condition.isFireMonster),
})
local dieter = Selector({
  Condition(combat, condition.hasEnemyOrInList),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemy)),
})
return Condition(dieter, IsDieter)
