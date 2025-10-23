local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'
---@type EnemyNode
local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'
---@type OwnerNode
local ownerNodes = require 'AI.USER_AI.BT.nodes.owner'

local tryReviveOwner = Parallel {
  Condition(
    skillNodes.executeSkill('myOwner', { keepRunning = false }),
    skillNodes.isSkillCastable(MH_LIGHT_OF_REGENE)
  ),
  homunNodes.runToSaveOwner,
}
local castOverBoost =
  Condition(skillNodes.executeSkill('myId', { skillType = 'object' }), skillNodes.isSkillCastable(MH_OVERED_BOOST))

local cutterAttack = Condition(
  Sequence {
    homunNodes.chaseEnemy,
    skillNodes.executeSkill('myEnemy', { skillType = 'object', keepRunning = false }),
  },
  skillNodes.isSkillCastable(MH_ERASER_CUTTER)
)
local xenoAttack = Unless(
  Condition(
    Parallel {
      homunNodes.chaseEnemy,
      skillNodes.executeSkill('myEnemy', { skillType = 'area', keepRunning = true }),
    },
    skillNodes.isSkillCastable(MH_XENO_SLASHER)
  ),
  enemyNodes.isWindType
)

local combat = Selector {
  Condition(castOverBoost, enemyNodes.isMVP),
  Condition(castOverBoost, ownerNodes.isDying),
  Condition(cutterAttack, enemyNodes.isWindType),
  Condition(xenoAttack, enemyNodes.isGhostType),
  Condition(xenoAttack, enemyNodes.hasEnemyGroup(2, 7)),
  Unless(cutterAttack, enemyNodes.isGhostType),
  homunNodes.attackAndChase,
  Condition(tryReviveOwner, ownerNodes.isDead),
}

return root(combat)
