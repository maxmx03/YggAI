---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
---@type Enemy
local enemy = require('AI.USER_AI.BT.enemy')
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [MH_ERASER_CUTTER] = 0,
  [MH_OVERED_BOOST] = 0,
  [MH_XENO_SLASHER] = 0,
  [MH_LIGHT_OF_REGENE] = 0,
  [MH_SILENT_BREEZE] = 0,
  -- [MH_TWISTER_CUTTER] = 0,
  -- [MH_ABSOLUTE_ZEPHYR] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_ERASER_CUTTER] = {
    id = MH_ERASER_CUTTER,
    sp = 70,
    cooldown = 300,
    level = 10,
    required_level = 106,
  },
  ---@type Skill
  [MH_OVERED_BOOST] = {
    id = MH_OVERED_BOOST,
    sp = 150,
    cooldown = 30000,
    level = 5,
    required_level = 114,
  },
  ---@type Skill
  [MH_XENO_SLASHER] = {
    id = MH_XENO_SLASHER,
    sp = 180,
    cooldown = 300,
    level = 10,
    required_level = 121,
  },
  ---@type Skill
  [MH_LIGHT_OF_REGENE] = {
    id = MH_LIGHT_OF_REGENE,
    sp = 40,
    cooldown = 300000,
    level = 5,
    required_level = 128,
  },
  ---@type Skill
  [MH_SILENT_BREEZE] = {
    id = MH_SILENT_BREEZE,
    sp = 160,
    cooldown = 1500,
    level = 5,
    required_level = 137,
  },
  -- [MH_TWISTER_CUTTER] = {
  --   id = MH_TWISTER_CUTTER,
  --   sp = 160,
  --   cooldown = 200,
  --   level = 10,
  --   required_level = 215,
  -- },
  -- [MH_ABSOLUTE_ZEPHYR] = {
  --   id = MH_ABSOLUTE_ZEPHYR,
  --   sp = 185,
  --   cooldown = 300,
  --   level = 10,
  --   required_level = 230,
  -- },
}

---@type Homun
local eira = Homun(MySkills, MyCooldown)
local cutter = {}
function cutter.isSkillCastable()
  return eira.isSkillCastable(MH_ERASER_CUTTER)
end
function cutter.castSkill()
  return eira.castSkill(MH_ERASER_CUTTER, MyEnemy, { targetType = 'target', keepRunning = false })
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
  return eira.castAOESkill(MH_XENO_SLASHER, { keepRunning = true, targetType = 'ground' })
end

local light = {}
function light.isSkillCastable()
  return eira.isSkillCastable(MH_LIGHT_OF_REGENE)
end
function light.castSkill()
  return eira.castSkill(MH_LIGHT_OF_REGENE, MyOwner, { targetType = 'target', keepRunning = false })
end

-- local twister = {}
-- function twister.isSkillCastable()
--   return eira.isSkillCastable(MH_TWISTER_CUTTER)
-- end
-- function twister.castSkill()
--   return eira.castSkill(MH_TWISTER_CUTTER, MyEnemy, { keepRunning = true, targetType = 'target' })
-- end

-- local zephyr = {}
-- function zephyr.isSkillCastable()
--   return eira.isSkillCastable(MH_XENO_SLASHER)
-- end
-- function zephyr.castSkill()
--   return eira.castSkill(MH_ABSOLUTE_ZEPHYR, MyEnemy, { keepRunning = true, targetType = 'target' })
-- end

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
-- local zephyrAttack = Parallel({
--   zephyr.castSkill,
--   node.chaseEnemy,
-- })
-- local twisterAttack = Parallel({
--   twister.castSkill,
--   node.chaseEnemy,
-- })
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
-- local twisterAttackIfAvailable = Condition(
--   Selector({
--     Condition(twisterAttack, condition.isWaterMonster),
--     Condition(twisterAttack, condition.isPoisonMonster),
--     Condition(twisterAttack, Inversion(condition.isWindMonster)),
--   }),
--   twister.isSkillCastable
-- )
-- local zephyrAttackIfAvailable = Condition(
--   Selector({
--     Condition(zephyrAttack, condition.isWaterMonster),
--     Condition(zephyrAttack, condition.isPoisonMonster),
--     Condition(zephyrAttack, Inversion(condition.isWindMonster)),
--   }),
--   twister.isSkillCastable
-- )

local combat = Condition(
  Selector({
    Condition(tryReviveOwner, condition.ownerIsDead),
    Conditions(overed.castSkill, overed.isSkillCastable, condition.isMVP),
    Conditions(overed.castSkill, overed.isSkillCastable, condition.ownerIsDying),
    -- Condition(zephyrAttackIfAvailable, enemy.hasEnemyGroup),
    Condition(xenoAttackIfAvailable, enemy.hasEnemyGroup),
    -- Condition(twisterAttackIfAvailable, Inversion(enemy.hasEnemyGroup)),
    Condition(cutterAttack, Inversion(enemy.hasEnemyGroup)),
    Condition(cutterAttack, condition.isWindMonster),
    Condition(node.attackAndChase, Inversion(cutter.isSkillCastable)),
  }),
  condition.enemyIsAlive
)
return Condition(eira.root(combat), IsEira)
