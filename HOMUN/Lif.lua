---@class Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [HLIF_HEAL] = 0,
  [HLIF_AVOID] = 0,
  [HLIF_CHANGE] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HLIF_HEAL] = {
    id = HLIF_HEAL,
    sp = 25,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 20
    end,
    level = 5,
    required_level = 15,
  },
  ---@type Skill
  [HLIF_AVOID] = {
    id = HLIF_AVOID,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 35
    end,
    level = 5,
    required_level = 25,
  },
  [HLIF_CHANGE] = {
    id = HLIF_CHANGE,
    sp = 100,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 5 * 60
    end,
    level = 3,
    required_level = 40,
  },
}

---@type Homun
local lif = Homun(MySkills, MyCooldown)

local heal = {}
function heal.isSkillCastable()
  return lif.isSkillCastable(HLIF_HEAL)
end
function heal.castSkill()
  if LifCanHeal then
    return lif.castSkill(HLIF_HEAL, MyOwner, { keepRunning = false, targetType = 'target' })
  end
  return STATUS.FAILURE
end
local avoid = {}
function avoid.isSkillCastable()
  return lif.isSkillCastable(HLIF_AVOID)
end
function avoid.castSkill()
  return lif.castSkill(HLIF_AVOID, MyOwner, { targetType = 'target', keepRunning = false })
end
local change = {}
function change.isSkillCastable()
  return lif.isSkillCastable(HLIF_CHANGE)
end
function change.castSkill()
  return lif.castSkill(HLIF_CHANGE, MyID, { keepRunning = false, targetType = 'target' })
end
local healOwner = Condition(
  Parallel({
    heal.castSkill,
    node.runToSaveOwner,
  }),
  heal.isSkillCastable
)
local combat = Selector({
  Condition(healOwner, condition.ownerIsDying),
  Condition(avoid.castSkill, avoid.isSkillCastable),
  Condition(change.castSkill, change.isSkillCastable),
  node.attackAndChase,
})
return Condition(lif.root(combat), IsLif)
