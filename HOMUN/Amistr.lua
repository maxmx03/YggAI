---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [HAMI_CASTLE] = 0,
  [HAMI_DEFENCE] = 0,
  [HAMI_BLOODLUST] = 0,
}

---@type Skills
local MySkills = {
  ---@type Skill
  [HAMI_CASTLE] = {
    id = HAMI_CASTLE,
    sp = 10,
    cooldown = 20000,
    level = 5,
    required_level = 15,
  },
  ---@type Skill
  [HAMI_DEFENCE] = {
    id = HAMI_DEFENCE,
    sp = 40,
    cooldown = 30000,
    level = 5,
    required_level = 25,
  },
  ---@type Skill
  [HAMI_BLOODLUST] = {
    id = HAMI_BLOODLUST,
    sp = 120,
    cooldown = 60000,
    level = 3,
    required_level = 80,
  },
}

---@type Homun
local amistr = Homun(MySkills, MyCooldown)
local castle = {}
function castle.isSkillCastable()
  return amistr.isSkillCastable(HAMI_CASTLE)
end
function castle.castSkill()
  return amistr.castSkill(HAMI_CASTLE, MyID, { targetType = 'target', keepRunning = false })
end
local defense = {}
function defense.isSkillCastable()
  return amistr.isSkillCastable(HAMI_DEFENCE)
end
function defense.castSkill()
  return amistr.castSkill(HAMI_DEFENCE, MyID, { targetType = 'target', keepRunning = false })
end
local bloodlust = {}
function bloodlust.isSkillCastable()
  return amistr.isSkillCastable(HAMI_BLOODLUST)
end
function bloodlust.castSkill()
  return amistr.castSkill(HAMI_BLOODLUST, MyID, { targetType = 'target', keepRunning = false })
end
local swapWithOwner = Condition(castle.castSkill, castle.isSkillCastable)
local combat = Condition(
  Selector({
    Condition(swapWithOwner, condition.ownerIsDying),
    Condition(defense.castSkill, defense.isSkillCastable),
    Condition(bloodlust.castSkill, bloodlust.isSkillCastable),
    Condition(node.attackAndChase, Inversion(castle.isSkillCastable)),
    node.attackAndChase,
  }),
  condition.enemyIsAlive
)
return Condition(amistr.root(combat), IsAmistr)
