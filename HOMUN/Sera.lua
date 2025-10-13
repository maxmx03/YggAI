local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'
---@type EnemyNode
local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'

local castPainKiller = Condition(
  skillNodes.enqueueSkill(MH_PAIN_KILLER, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_PAIN_KILLER)
)
local invokeLegion = Condition(
  skillNodes.enqueueSkill(MH_SUMMON_LEGION, 'myEnemy', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_SUMMON_LEGION)
)
local castPoisonMist = Condition(
  Parallel {
    skillNodes.enqueueSkill(MH_POISON_MIST, 'myEnemy', { skillType = 'area' }),
    homunNodes.chaseEnemy,
  },
  skillNodes.isSkillCastable(MH_POISON_MIST)
)

local castToxinOfMandara = Condition(
  Parallel {
    skillNodes.enqueueSkill(MH_TOXIN_OF_MANDARA, 'myEnemy', { skillType = 'object' }),
    homunNodes.chaseEnemy,
  },
  skillNodes.isSkillCastable(MH_TOXIN_OF_MANDARA)
)

local paralyzeEnqueuer = skillNodes.enqueueSkill(MH_NEEDLE_OF_PARALYZE, 'myEnemy', { skillType = 'object' })
local needleStingerEnqueuer = Condition(
  skillNodes.enqueueSkill(MH_NEEDLE_STINGER, 'myEnemy', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_NEEDLE_STINGER)
)
local isParalyzeCastable = skillNodes.isSkillCastable(MH_NEEDLE_OF_PARALYZE)
local tryParalyzeEnemy = Condition(paralyzeEnqueuer, isParalyzeCastable)

local combat = Selector {
  Parallel {
    homunNodes.chaseEnemy,
    Condition(skillNodes.executeQueuedSkill, skillNodes.hasSkillsToCast),
  },
  castPainKiller,
  Condition(invokeLegion, enemyNodes.isMVP),
  Condition(Unless(castToxinOfMandara, enemyNodes.isPoisonType), enemyNodes.isMVP),
  Condition(Unless(castPoisonMist, enemyNodes.isPoisonType), enemyNodes.isMVP),
  Condition(Unless(castPoisonMist, enemyNodes.isPoisonType), enemyNodes.hasEnemyGroup),
  Condition(Unless(castToxinOfMandara, enemyNodes.isPoisonType), enemyNodes.hasEnemyGroup),
  Condition(invokeLegion, enemyNodes.isPoisonType),
  Condition(FailRandomly(tryParalyzeEnemy, 30), enemyNodes.isMVP),
  FailRandomly(tryParalyzeEnemy, 70),
  Unless(needleStingerEnqueuer, enemyNodes.isPoisonType),
  Unless(homunNodes.attackAndChase, skillNodes.hasSkillsToCast),
}

return root(combat)
