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

local lavaSlide = Condition(
  Parallel({
    skillNodes.enqueueSkill(MH_LAVA_SLIDE, 'myEnemy', { skillType = 'area' }),
    homunNodes.chaseEnemy,
  }),
  skillConditions.isSkillCastable(MH_LAVA_SLIDE)
)

local magmaFlow = Condition(
  skillNodes.enqueueSkill(MH_MAGMA_FLOW, 'myId', { skillType = 'object' }),
  skillConditions.isSkillCastable(MH_MAGMA_FLOW)
)

local volcanicAsh = Condition(
  Parallel({
    skillNodes.enqueueSkill(MH_VOLCANIC_ASH, 'myEnemy', { skillType = 'area' }),
    homunNodes.chaseEnemy,
  }),
  skillConditions.isSkillCastable(MH_VOLCANIC_ASH)
)

local blastForge = Unless(
  Condition(
    Parallel({
      skillNodes.enqueueSkill(MH_BLAST_FORGE, 'myEnemy', { skillType = 'area' }),
      homunNodes.chaseEnemy,
    }),
    skillConditions.isSkillCastable(MH_BLAST_FORGE)
  ),
  enemyConditions.isFireType
)

local pyroclastic = Condition(
  skillNodes.enqueueSkill(MH_PYROCLASTIC, 'myId', { skillType = 'object' }),
  skillConditions.isSkillCastable(MH_PYROCLASTIC)
)

local combat = Condition(
  Selector({
    Condition(skillNodes.executeSkill, skillNodes.hasSkillsToCast),
    pyroclastic,
    Unless(lavaSlide, enemyConditions.isFireType),
    Unless(magmaFlow, enemyConditions.isFireType),
    Condition(blastForge, enemyConditions.hasEnemyGroup),
    Condition(volcanicAsh, enemyConditions.isMVP),
    Condition(volcanicAsh, enemyConditions.isPlantType),
    Condition(volcanicAsh, enemyConditions.isWaterType),
    Unless(homunNodes.attackAndChase, skillNodes.hasSkillsToCast),
  }),
  enemyConditions.isAlive
)
return root(combat)
