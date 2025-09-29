---@class Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [MH_NEEDLE_OF_PARALYZE] = 0,
  [MH_POISON_MIST] = 0,
  [MH_PAIN_KILLER] = 0,
  [MH_SUMMON_LEGION] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_NEEDLE_OF_PARALYZE] = {
    id = MH_NEEDLE_OF_PARALYZE,
    sp = 96,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.2
    end,
    level = 10,
    required_level = 105,
  },
  ---@type Skill
  [MH_POISON_MIST] = {
    id = MH_POISON_MIST,
    sp = 105,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 15
    end,
    level = 5,
    required_level = 116,
  },
  ---@type Skill
  [MH_PAIN_KILLER] = {
    id = MH_PAIN_KILLER,
    sp = 64,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 600
    end,
    level = 10,
    required_level = 123,
  },
  ---@type Skill
  [MH_SUMMON_LEGION] = {
    id = MH_SUMMON_LEGION,
    sp = 140,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 30
    end,
    level = 5,
    required_level = 132,
  },
}

---@type Homun
local sera = Homun(MySkills, MyCooldown)

local paralyze = {}
function paralyze.isSkillCastable()
  if math.random(1, 100) <= 40 then
    return sera.isSkillCastable(MH_NEEDLE_OF_PARALYZE)
  end
  return false
end
function paralyze.isSkillCastableMoreOften()
  if math.random(1, 100) <= 80 then
    return sera.isSkillCastable(MH_NEEDLE_OF_PARALYZE)
  end
  return false
end
function paralyze.castSkill()
  return sera.castSkill(MH_NEEDLE_OF_PARALYZE, MyEnemy, { targetType = 'target', keepRunning = true })
end
local poison = {}
function poison.isSkillCastable()
  return sera.isSkillCastable(MH_POISON_MIST)
end
function poison.castSkill()
  return sera.castSkill(MH_POISON_MIST, MyEnemy, { targetType = 'ground', keepRunning = false })
end

local pain = {}
function pain.isSkillCastable()
  return sera.isSkillCastable(MH_PAIN_KILLER)
end
function pain.castSkill()
  return sera.castSkill(MH_PAIN_KILLER, MyID, { targetType = 'target', keepRunning = false })
end
local legion = {}
function legion.isSkillCastable()
  return sera.isSkillCastable(MH_SUMMON_LEGION)
end
function legion.castSkill()
  return sera.castSkill(MH_SUMMON_LEGION, MyEnemy, { targetType = 'target', keepRunning = false })
end

local castPoisonMist = Condition(
  Parallel({
    poison.castSkill,
    node.chaseEnemy,
  }),
  poison.isSkillCastable
)
local castParalyze = Parallel({
  paralyze.castSkill,
  node.chaseEnemy,
})
local tryParalizeEnemy = Condition(castParalyze, paralyze.isSkillCastable)
local tryParalizeEnemyMoreOften = Condition(castParalyze, paralyze.isSkillCastableMoreOften)
local invokeLegion = Condition(
  Parallel({
    legion.castSkill,
    node.chaseEnemy,
  }),
  legion.isSkillCastable
)

local isMVP = Condition(
  Selector({
    invokeLegion,
    tryParalizeEnemyMoreOften,
  }),
  condition.isMVP
)

local combat = Selector({
  Condition(pain.castSkill, pain.isSkillCastable),
  castPoisonMist,
  Condition(node.attackAndChase, Inversion(paralyze.isSkillCastable)),
  isMVP,
  Condition(tryParalizeEnemy, Inversion(poison.isSkillCastable)),
})
return Condition(sera.root(combat), IsSera)
