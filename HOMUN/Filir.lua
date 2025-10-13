local root = require 'AI.USER_AI.UTIL.Homun'
---@type HomunNode
local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
---@type SkillNode
local skillNodes = require 'AI.USER_AI.BT.nodes.skill'

local executeSpeed = skillNodes.executeSkill('myId', { keepRunning = false, skillType = 'object' })
local isSpeedCastable = skillNodes.isSkillCastable(HFLI_SPEED)
local executeFleet = skillNodes.executeSkill('myId', { keepRunning = false, skillType = 'object' })
local isFleetCastable = skillNodes.isSkillCastable(HFLI_FLEET)
local executeMoon = skillNodes.executeSkill('myEnemy', { keepRunning = false, skillType = 'object' })
local isMoonCastable = skillNodes.isSkillCastable(HFLI_MOON)

local moonLightAttack = Condition(
  Parallel {
    executeMoon,
    homunNodes.chaseEnemy,
  },
  isMoonCastable
)

local combat = Selector {
  Condition(executeSpeed, isSpeedCastable),
  Condition(executeFleet, isFleetCastable),
  moonLightAttack,
  homunNodes.attackAndChase,
}

return root(combat)
