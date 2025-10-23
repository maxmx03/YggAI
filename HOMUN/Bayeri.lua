local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'
---@type OwnerNode
local ownerNodes = require 'AI.USER_AI.BT.nodes.owner'
---@type EnemyNode
local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'

local executeSkills = Condition(
  Parallel {
    skillNodes.executeQueuedSkill,
    homunNodes.chaseEnemy,
  },
  skillNodes.hasSkillsToCast
)

local enqueueStahlHorn = Condition(
  skillNodes.enqueueSkill(MH_STAHL_HORN, 'myEnemy', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_STAHL_HORN)
)

local enqueueHeiligeStange = Condition(
  skillNodes.enqueueSkill(MH_HEILIGE_STANGE, 'myEnemy', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_HEILIGE_STANGE)
)

local enqueueGoldeneFerse = Condition(
  skillNodes.enqueueSkill(MH_GOLDENE_FERSE, 'myEnemy', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_GOLDENE_FERSE)
)

local enqueueSteinWand = Condition(
  skillNodes.enqueueSkill(MH_STEINWAND, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_STEINWAND)
)

local enqueueAngriffsModus = Condition(
  skillNodes.enqueueSkill(MH_ANGRIFFS_MODUS, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_ANGRIFFS_MODUS)
)

local enqueueGlanzenSpies = Condition(
  skillNodes.enqueueSkill(MH_GLANZEN_SPIES, 'myEnemy', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_GLANZEN_SPIES)
)

local enqueueHeiligePferd = Condition(
  skillNodes.enqueueSkill(MH_HEILIGE_PFERD, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_HEILIGE_PFERD)
)

local enqueueGoldeneTone = Condition(
  skillNodes.enqueueSkill(MH_GOLDENE_TONE, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_GOLDENE_TONE)
)

local combat = Selector {
  executeSkills,
  enqueueGoldeneTone,
  Condition(Unless(enqueueHeiligePferd, enemyNodes.isHolyType), enemyNodes.hasEnemyGroup(5, 3)),
  Condition(Unless(enqueueHeiligeStange, enemyNodes.isHolyType), enemyNodes.hasEnemyGroup(2, 5)),
  Condition(enqueueHeiligePferd, enemyNodes.isMVP),
  Condition(enqueueSteinWand, enemyNodes.isMVP),
  Condition(enqueueSteinWand, ownerNodes.isDying),
  Condition(enqueueAngriffsModus, ownerNodes.isDying),
  Condition(enqueueSteinWand, ownerNodes.isTakingDamage),
  Unless(enqueueGlanzenSpies, enemyNodes.isHolyType),
  Unless(enqueueGoldeneFerse, enemyNodes.isHolyType),
  Unless(enqueueStahlHorn, enemyNodes.isGhostType),
  Unless(homunNodes.attackAndChase, skillNodes.hasSkillsToCast),
}
return root(combat)
