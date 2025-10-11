local root = require('AI.USER_AI.UTIL.Homun')
---@type OwnerCondition
local ownerConditions = require('AI.USER_AI.BT.conditions.owner')
---@type HomunNode
local homunNodes = require('AI.USER_AI.BT.nodes.homun')
---@type SkillNode
local skillNodes = require('AI.USER_AI.BT.nodes.skill')
---@type SkillCondition
local skillConditions = require('AI.USER_AI.BT.conditions.skill')

local caprice = Condition(
  Parallel({
    skillNodes.castSkill(HVAN_CAPRICE, 'enemy', { keepRunning = false }),
    homunNodes.chaseEnemy,
  }),
  skillConditions.isSkillCastable(HVAN_CAPRICE)
)
local chaoticHealing = Condition(
  Parallel({
    skillNodes.castSkill(HVAN_CHAOTIC, 'self', { keepRunning = false }),
    homunNodes.runToSaveOwner,
  }),
  skillConditions.isSkillCastable(HVAN_CHAOTIC)
)
local combat = Selector({
  Condition(chaoticHealing, ownerConditions.isDying),
  caprice,
  FailRandomly(homunNodes.attackAndChase, 30),
})
return root(combat)
