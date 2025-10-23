local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'
---@type EnemyNode
local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'

local lavaSlide = Condition(
  skillNodes.enqueueSkill(MH_LAVA_SLIDE, 'myEnemy', { skillType = 'area' }),
  skillNodes.isSkillCastable(MH_LAVA_SLIDE)
)

local magmaFlow = Condition(
  skillNodes.enqueueSkill(MH_MAGMA_FLOW, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_MAGMA_FLOW)
)

local volcanicAsh = Condition(
  skillNodes.enqueueSkill(MH_VOLCANIC_ASH, 'myEnemy', { skillType = 'area' }),
  skillNodes.isSkillCastable(MH_VOLCANIC_ASH)
)

local blastForge = Unless(
  Condition(
    skillNodes.enqueueSkill(MH_BLAST_FORGE, 'myEnemy', { skillType = 'area' }),
    skillNodes.isSkillCastable(MH_BLAST_FORGE)
  ),
  enemyNodes.isFireType
)

local pyroclastic = Condition(
  skillNodes.enqueueSkill(MH_PYROCLASTIC, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_PYROCLASTIC)
)

local tempering = Condition(
  skillNodes.enqueueSkill(MH_TEMPERING, 'myId', { skillType = 'object' }),
  skillNodes.isSkillCastable(MH_TEMPERING)
)

local executeSkills = Condition(
  Parallel {
    homunNodes.chaseEnemy,
    skillNodes.executeQueuedSkill,
  },
  skillNodes.hasSkillsToCast
)

local hasWaterOrPlantTypeMonsters = Selector {
  Condition(volcanicAsh, enemyNodes.isPlantType),
  Condition(volcanicAsh, enemyNodes.isWaterType),
}

local combat = Selector {
  executeSkills,
  tempering,
  Unless(pyroclastic, enemyNodes.isFireType),
  Unless(lavaSlide, enemyNodes.isFireType),
  Unless(magmaFlow, enemyNodes.isFireType),
  Condition(blastForge, enemyNodes.hasEnemyGroup(2, 5)),
  Condition(blastForge, enemyNodes.isMVP),
  Condition(hasWaterOrPlantTypeMonsters, enemyNodes.hasEnemyGroup(5, 3)),
  Condition(volcanicAsh, enemyNodes.isMVP),
  Unless(homunNodes.attackAndChase, skillNodes.hasSkillsToCast),
}
return root(combat)
