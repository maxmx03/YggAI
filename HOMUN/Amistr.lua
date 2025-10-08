local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'
---@type OwnerNode
local ownerNodes = require 'AI.USER_AI.BT.nodes.owner'
local swapWithOwner =
  Condition(skillNodes.executeSkill('myId', { skillType = 'object' }), skillNodes.isSkillCastable(HAMI_CASTLE))
local combat = Selector {
  Condition(swapWithOwner, ownerNodes.isDying),
  Condition(skillNodes.executeSkill('myId', { skillType = 'object' }), skillNodes.isSkillCastable(HAMI_DEFENCE)),
  Condition(skillNodes.executeSkill('myId', { skillType = 'object' }), skillNodes.isSkillCastable(HAMI_BLOODLUST)),
  homunNodes.attackAndChase,
}
return root(combat)
