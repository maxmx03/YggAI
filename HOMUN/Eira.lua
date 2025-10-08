local root = require('AI.USER_AI.UTIL.Homun')
---@type EnemyCondition
local enemyConditions = require('AI.USER_AI.BT.conditions.enemy')
---@type OwnerCondition
local ownerConditions = require('AI.USER_AI.BT.conditions.owner')
---@type HomunNode
local homunNodes = require('AI.USER_AI.BT.nodes.homun')
---@type HomunCondition
local homunConditions = require('AI.USER_AI.BT.conditions.homun')
---@type SkillNode
local skillNodes = require('AI.USER_AI.BT.nodes.skill')
---@type SkillCondition
local skillConditions = require('AI.USER_AI.BT.conditions.skill')

local tryReviveOwner = Parallel({
  Condition(
    skillNodes.castSkill(MH_LIGHT_OF_REGENE, 'owner', { keepRunning = false }),
    skillConditions.isSkillCastable(MH_LIGHT_OF_REGENE)
  ),
  homunNodes.runToSaveOwner,
})
local castOverBoost = Condition(
  skillNodes.castSkill(MH_OVERED_BOOST, 'self', { keepRunning = false }),
  skillConditions.isSkillCastable(MH_OVERED_BOOST)
)

local cutterAttack = Condition(
  Parallel({
    skillNodes.castSkill(MH_ERASER_CUTTER, 'enemy', { keepRunning = false }),
    homunNodes.chaseEnemy,
  }),
  skillConditions.isSkillCastable(MH_ERASER_CUTTER)
)
local xenoAttack = Unless(
  Parallel({
    skillNodes.castAOESkill(MH_XENO_SLASHER, nil, { keepRunning = true }),
    homunNodes.chaseEnemy,
  }),
  enemyConditions.isWindType
)
local combat = Condition(
  Selector({
    Condition(tryReviveOwner, ownerConditions.isDead),
    Condition(castOverBoost, enemyConditions.isMVP),
    Condition(castOverBoost, ownerConditions.isDying),
    Unless(cutterAttack, enemyConditions.hasEnemyGroup),
    Condition(cutterAttack, enemyConditions.isWindType),
    Condition(xenoAttack, enemyConditions.hasEnemyGroup),
    Unless(homunNodes.attackAndChase, skillConditions.isSkillCastable(MH_ERASER_CUTTER)),
  }),
  enemyConditions.isAlive
)
return Condition(root(combat), homunConditions.isEira)
