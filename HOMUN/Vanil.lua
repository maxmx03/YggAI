---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [HVAN_CAPRICE] = 0,
  [HVAN_CHAOTIC] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HVAN_CAPRICE] = {
    id = HVAN_CAPRICE,
    sp = 30,
    cooldown = 3000,
    level = 5,
    required_level = 15,
  },
  ---@type Skill
  [HVAN_CHAOTIC] = {
    id = HVAN_CHAOTIC,
    sp = 40,
    cooldown = 3000,
    level = 5,
    required_level = 25,
  },
}

---@type Homun
local vanil = Homun(MySkills, MyCooldown)
local caprice = {}
function caprice.isSkillCastable()
  return vanil.isSkillCastable(HVAN_CAPRICE)
end
function caprice.castSkill()
  return vanil.castSkill(HVAN_CAPRICE, MyEnemy, { targetType = 'target', keepRunning = false })
end
local chaotic = {}
function chaotic.isSkillCastable()
  if math.random(100) <= 30 then
    return vanil.isSkillCastable(HVAN_CHAOTIC)
  end
  return false
end
function chaotic.castSkill()
  return vanil.castSkill(HVAN_CHAOTIC, MyOwner, { targetType = 'target', keepRunning = false })
end

local magickAttack = Condition(
  Parallel({
    caprice.castSkill,
    node.chaseEnemy,
  }),
  caprice.isSkillCastable
)
local chaoticHealing = Condition(
  Parallel({
    chaotic.castSkill,
    node.runToSaveOwner,
  }),
  chaotic.isSkillCastable
)
local combat = Selector({
  Condition(chaoticHealing, condition.ownerIsDying),
  magickAttack,
  Condition(node.attackAndChase, Inversion(caprice.isSkillCastable)),
})
return Condition(vanil.root(combat), IsVanilmirth)
