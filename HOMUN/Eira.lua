local root = require('AI.USER_AI.UTIL.Homun')
---@type EnemyCondition
local enemyConditions = require('AI.USER_AI.BT.conditions.enemy')
---@type OwnerCondition
local ownerConditions = require('AI.USER_AI.BT.conditions.owner')
---@type HomunNode
local homunNodes = require('AI.USER_AI.BT.nodes.homun')
---@type SkillNode
local skillNodes = require('AI.USER_AI.BT.nodes.skill')
---@type SkillCondition
local skillConditions = require('AI.USER_AI.BT.conditions.skill')

local tryReviveOwner = Parallel({
  Condition(
    skillNodes.enqueueSkill(MH_LIGHT_OF_REGENE, 'myOwner', { keepRunning = false }),
    skillConditions.isSkillCastable(MH_LIGHT_OF_REGENE)
  ),
  homunNodes.runToSaveOwner,
})
local castOverBoost = Condition(
  skillNodes.enqueueSkill(MH_OVERED_BOOST, 'myId', { skillType = 'object' }),
  skillConditions.isSkillCastable(MH_OVERED_BOOST)
)

local cutterAttack = Condition(
  Parallel({
    skillNodes.enqueueSkill(MH_ERASER_CUTTER, 'myEnemy', { skillType = 'object' }),
    homunNodes.chaseEnemy,
  }),
  skillConditions.isSkillCastable(MH_ERASER_CUTTER)
)
local xenoAttack = Unless(
  Parallel({
    skillNodes.enqueueSkill(MH_XENO_SLASHER, 'myEnemy', { keepRunning = false, skillType = 'area' }),
    homunNodes.chaseEnemy,
  }),
  enemyConditions.isWindType
)
local combat = Condition(
  Selector({
    Condition(skillNodes.executeSkill, skillNodes.hasSkillsToCast),
    Condition(castOverBoost, enemyConditions.isMVP),
    Condition(cutterAttack, enemyConditions.isWindType),
    Condition(xenoAttack, enemyConditions.hasEnemyGroup),
    Condition(tryReviveOwner, ownerConditions.isDead),
    Condition(castOverBoost, ownerConditions.isDying),
    cutterAttack,
    Unless(homunNodes.attackAndChase, skillNodes.hasSkillsToCast),
  }),
  enemyConditions.isAlive
)
return root(combat)
