---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

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
    required_level = 102,
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
    required_level = 109,
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
    required_level = 116,
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
    required_level = 122,
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
    required_level = 131,
  },
}

---@type Homun
local dieter = Homun(MySkills, MyCooldown)

local volcanic = {}
function volcanic.castSkill()
  return dieter.castSkill(MH_VOLCANIC_ASH, MyEnemy, { targetType = 'ground', keepRunning = false })
end
function volcanic.isSkillCastable()
  return dieter.isSkillCastable(MH_VOLCANIC_ASH)
end
local lava = {}
function lava.castSkill()
  return dieter.castSkill(MH_LAVA_SLIDE, MyEnemy, { targetType = 'ground', keepRunning = false })
end
function lava.isSkillCastable()
  return dieter.isSkillCastable(MH_LAVA_SLIDE)
end
local granitic = {}
function granitic.castSkill()
  return dieter.castSkill(MH_GRANITIC_ARMOR, MyID, { targetType = 'target', keepRunning = false })
end
function granitic.isSkillCastable()
  return dieter.isSkillCastable(MH_GRANITIC_ARMOR)
end
local magma = {}
function magma.castSkill()
  return dieter.castSkill(MH_MAGMA_FLOW, MyID, { targetType = 'target', keepRunning = false })
end
function magma.isSkillCastable()
  return dieter.isSkillCastable(MH_MAGMA_FLOW)
end
local pyroclastic = {}
function pyroclastic.castSkill()
  return dieter.castSkill(MH_PYROCLASTIC, MyID, { targetType = 'target', keepRunning = false })
end
function pyroclastic.isSkillCastable()
  return dieter.isSkillCastable(MH_PYROCLASTIC)
end

local lavaAttack = Condition(
  Parallel({
    lava.castSkill,
    node.chaseEnemy,
  }),
  lava.isSkillCastable
)
local volcanicAttack = Condition(
  Parallel({
    volcanic.castSkill,
    volcanic.isSkillCastable,
    node.chaseEnemy,
  }),
  volcanic.isSkillCastable
)

local enemyIsMVP = Condition(
  Selector({
    Condition(magma.castSkill, magma.isSkillCastable),
    Condition(pyroclastic.castSkill, pyroclastic.isSkillCastable),
    Condition(volcanicAttack, Inversion(lava.isSkillCastable)),
    Condition(node.attackAndChase, Inversion(volcanic.isSkillCastable)),
    lavaAttack,
  }),
  condition.isMVP
)

local enemyIsPlantMonster = Condition(
  Selector({
    Condition(magma.castSkill, magma.isSkillCastable),
    Condition(volcanicAttack, Inversion(lava.isSkillCastable)),
    Condition(node.attackAndChase, Inversion(volcanic.isSkillCastable)),
    lavaAttack,
  }),
  condition.isPlantMonster
)

local enemyIsWaterMonster = Condition(
  Selector({
    Condition(volcanicAttack, Inversion(lava.isSkillCastable)),
    Condition(node.attackAndChase, Inversion(volcanic.isSkillCastable)),
    lavaAttack,
  }),
  condition.isWaterMonster
)

local enemyIsFireMonster = Condition(
  Selector({
    Condition(pyroclastic.castSkill, pyroclastic.isSkillCastable),
    node.attackAndChase,
  }),
  condition.isFireMonster
)

local enemyIsEarthMonster = Condition(
  Selector({
    Condition(magma.castSkill, magma.isSkillCastable),
    Condition(node.attackAndChase, Inversion(lava.isSkillCastable)),
    Condition(pyroclastic.castSkill, pyroclastic.isSkillCastable),
    lavaAttack,
  }),
  condition.isEarthMonster
)

local graniticArmor = Condition(granitic.castSkill, granitic.isSkillCastable)
local combat = Condition(
  Selector({
    enemyIsMVP,
    enemyIsFireMonster,
    enemyIsWaterMonster,
    enemyIsPlantMonster,
    enemyIsEarthMonster,
    Condition(graniticArmor, condition.ownerIsDying),
    Condition(pyroclastic.castSkill, pyroclastic.isSkillCastable),
    Condition(node.attackAndChase, Inversion(lava.isSkillCastable)),
    lavaAttack,
  }),
  condition.enemyIsAlive
)
return Condition(dieter.root(combat), IsDieter)
