---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

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
    required_level = 106,
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
    required_level = 114,
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
    required_level = 121,
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
    required_level = 128,
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
    required_level = 137,
  },
}

---@type Homun
local eira = Homun(MySkills, MyCooldown)
local cutter = {}
function cutter.isSkillCastable()
  return eira.isSkillCastable(MH_ERASER_CUTTER)
end
function cutter.castSkill()
  return eira.castSkill(MH_ERASER_CUTTER, MyEnemy, { targetType = 'target', keepRunning = true })
end

local overed = {}
function overed.isSkillCastable()
  return eira.isSkillCastable(MH_OVERED_BOOST)
end
function overed.castSkill()
  return eira.castSkill(MH_OVERED_BOOST, MyID, { targetType = 'target', keepRunning = false })
end

local xeno = {}
function xeno.isSkillCastable()
  return eira.isSkillCastable(MH_XENO_SLASHER)
end
function xeno.castSkill()
  return eira.castSkill(MH_XENO_SLASHER, MyEnemy, { targetType = 'ground', keepRunning = true })
end

local light = {}
function light.isSkillCastable()
  return eira.isSkillCastable(MH_LIGHT_OF_REGENE)
end
function light.castSkill()
  return eira.castSkill(MH_LIGHT_OF_REGENE, MyOwner, { targetType = 'target', keepRunning = false })
end
local cutterAttack = Condition(
  Parallel({
    cutter.castSkill,
    node.chaseEnemy,
  }),
  cutter.isSkillCastable
)
local xenoAttack = Parallel({
  xeno.castSkill,
  node.chaseEnemy,
})
local tryReviveOwner = Parallel({
  Conditions(light.castSkill, light.isSkillCastable),
  node.runToSaveOwner,
})
local xenoAttackIfAvailable = Condition(
  Selector({
    Condition(xenoAttack, condition.isWaterMonster),
    Condition(xenoAttack, condition.isPoisonMonster),
    Condition(xenoAttack, Inversion(condition.isWindMonster)),
  }),
  xeno.isSkillCastable
)

local combat = Condition(
  Selector({
    Condition(tryReviveOwner, condition.ownerIsDead),
    Conditions(overed.castSkill, overed.isSkillCastable, condition.isMVP),
    Conditions(overed.castSkill, overed.isSkillCastable, condition.ownerIsDying),
    xenoAttackIfAvailable,
    cutterAttack,
    Condition(node.attackAndChase, Inversion(cutter.isSkillCastable)),
  }),
  condition.enemyIsAlive
)
return Condition(eira.root(combat), IsEira)
