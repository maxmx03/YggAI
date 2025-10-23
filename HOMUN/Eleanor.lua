local root = require 'AI.USER_AI.UTIL.Homun'

---@type EleanorNode
local eleanorNodes = require 'AI.USER_AI.BT.nodes.eleanor'
---@type EnemyNode
local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'

local sonicCraw =
  Condition(eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }), eleanorNodes.isSkillCastable(MH_SONIC_CRAW))

local silverRush = Condition(
  Delay(eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }), 2),
  eleanorNodes.isSkillCastable(MH_SILVERVEIN_RUSH)
)

local midnightFrenzy = Condition(
  Delay(eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }), 2),
  eleanorNodes.isSkillCastable(MH_MIDNIGHT_FRENZY)
)

local BattleComboSequence = Unless(
  Sequence {
    sonicCraw,
    silverRush,
    midnightFrenzy,
  },
  enemyNodes.isNotInAttackSight
)

local tinderBreaker = Condition(
  eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }),
  eleanorNodes.isSkillCastable(MH_TINDER_BREAKER)
)

local cbc = Condition(
  Delay(eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }), 2),
  eleanorNodes.isSkillCastable(MH_CBC)
)

local eqc = Condition(
  Delay(eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }), 2),
  eleanorNodes.isSkillCastable(MH_EQC)
)

local ClawComboSequence = Unless(
  Sequence {
    tinderBreaker,
    cbc,
    eqc,
  },
  enemyNodes.isNotInAttackSight
)

local BattleComboMode = Sequence {
  eleanorNodes.chaseEnemy,
  BattleComboSequence,
}
local ClawComboMode = Sequence {
  eleanorNodes.chaseEnemy,
  ClawComboSequence,
}

local BlazingAndFurious = Condition(
  eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }),
  eleanorNodes.isSkillCastable(MH_BLAZING_AND_FURIOUS)
)

local TheOneFighterRises = Condition(
  eleanorNodes.executeSkill('myEnemy', { skillType = 'object' }),
  eleanorNodes.isSkillCastable(MH_THE_ONE_FIGHTER_RISES)
)

local combat = Selector {
  Condition(BlazingAndFurious, enemyNodes.hasEnemyGroup(2, 7)),
  Condition(TheOneFighterRises, enemyNodes.hasEnemyGroup(2, 7)),
  Condition(BattleComboMode, eleanorNodes.isBattleMode),
  Condition(ClawComboMode, eleanorNodes.isClawMode),
  Unless(eleanorNodes.attackAndChase, eleanorNodes.hasAllSpheres),
  eleanorNodes.attackAndChase,
}

return root(combat)
