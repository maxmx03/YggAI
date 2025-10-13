local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'
---@type OwnerNode
local ownerNodes = require 'AI.USER_AI.BT.nodes.owner'

local caprice = Parallel {
  skillNodes.executeSkill('myEnemy', { skillType = 'object' }),
  homunNodes.chaseEnemy,
}
local chaoticHealing = FailRandomly(
  Condition(
    Parallel {
      skillNodes.executeSkill('myId', { skillType = 'object' }),
      homunNodes.runToSaveOwner,
    },
    skillNodes.isSkillCastable(HVAN_CHAOTIC)
  ),
  70
)

local combat = Selector {
  Condition(chaoticHealing, ownerNodes.isDying),
  Condition(caprice, skillNodes.isSkillCastable(HVAN_CAPRICE)),
  homunNodes.attackAndChase,
}
return root(combat)
