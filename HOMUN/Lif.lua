local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'
---@type OwnerNode
local ownerCondition = require 'AI.USER_AI.BT.nodes.owner'

local executeHeal = skillNodes.executeSkill('myOwner', { skillType = 'object' })
---@type Condition
local isHealCastable = function(bb)
  return skillNodes.isSkillCastable(HLIF_HEAL)(bb) and LifCanHeal
end

local healOwner = Condition(
  Parallel {
    executeHeal,
    homunNodes.runToSaveOwner,
  },
  isHealCastable
)

local executeAvoid = skillNodes.executeSkill('myOwner', { skillType = 'object' })
local isAvoidCastable = skillNodes.isSkillCastable(HLIF_AVOID)
local executeChange = skillNodes.executeSkill('myId', { skillType = 'object' })
local isChangeCastable = skillNodes.isSkillCastable(HLIF_CHANGE)

local combat = Selector {
  Condition(healOwner, ownerCondition.isDying),
  Condition(executeAvoid, isAvoidCastable),
  Condition(executeChange, isChangeCastable),
  homunNodes.attackAndChase,
}

return root(combat)
