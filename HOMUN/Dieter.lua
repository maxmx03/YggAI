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
      return 5
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
  node.basicAttack,
  node.chaseEnemy,
})
local AttackAndChaseLava = Parallel({
  Condition(node.basicAttack, Inversion(lava.condition)),
  node.chaseEnemy,
})
local AttackAndChaseVolcanic = Parallel({
  Condition(node.basicAttack, Inversion(volcanic.condition)),
  node.chaseEnemy,
})
local lavaAttack = Parallel({
  Condition(lava.cast, lava.condition),
  node.chaseEnemy,
})

local volcanicAttack = Parallel({
  Condition(volcanic.cast, volcanic.condition),
  node.chaseEnemy,
})

local combat = Selector({
  Condition(granitic.cast, granitic.condition, condition.ownerIsDying, condition.enemyIsAlive),
  Condition(
    Selector({
      Condition(magma.cast, magma.condition, condition.enemyIsAlive),
      Condition(pyroclastic.cast, pyroclastic.condition, condition.enemyIsAlive),
      Condition(volcanicAttack, condition.enemyIsAlive, Inversion(lava.condition)),
      Condition(AttackAndChaseVolcanic, Inversion(volcanic.condition), condition.enemyIsAlive),
      Condition(lavaAttack, condition.enemyIsAlive),
    }),
    condition.isMVP
  ),
  Condition(
    Selector({
      Condition(pyroclastic.cast, pyroclastic.condition, condition.enemyIsAlive),
      Condition(AttackAndChase, condition.enemyIsAlive),
    }),
    condition.isFireMonster
  ),
  Condition(lavaAttack, condition.enemyIsAlive),
  Condition(magma.cast, magma.condition, condition.enemyIsAlive),
  Condition(pyroclastic.cast, pyroclastic.condition, condition.enemyIsAlive),
  Condition(AttackAndChaseLava, Inversion(lava.condition), condition.enemyIsAlive),
})
local dieter = Selector({
  Condition(combat, condition.hasEnemyOrInList, condition.ownerIsNotTooFar),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemy)),
})
return Condition(dieter, IsDieter)
