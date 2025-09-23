---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

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
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 3
    end,
    level = 5,
  },
  ---@type Skill
  [HVAN_CHAOTIC] = {
    id = HVAN_CHAOTIC,
    sp = 40,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 3
    end,
    level = 5,
  },
}

---@param mySkill number
local isSkillCastable = function(mySkill)
  MySkill = mySkill
  ---@type Skill
  local skill = MySkills[MySkill]
  local cooldown = MyCooldown[MySkill]
  return condition.isSkillCastable(skill, cooldown)
end

---@param skill number
---@param target number
---@param opts SkillOpts
---@return Status
local cast = function(skill, target, opts)
  local casted = node.castSkill(MySkills[skill], MyCooldown[skill], target, opts)
  if casted == STATUS.RUNNING then
    MyCooldown[skill] = GetTickInSeconds()
    return STATUS.RUNNING
  elseif casted == STATUS.SUCCESS then
    MyCooldown[skill] = GetTickInSeconds()
    MySkill = 0
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end

local caprice = {}

function caprice.condition()
  return isSkillCastable(HVAN_CAPRICE)
end
function caprice.cast()
  return cast(HVAN_CAPRICE, MyEnemy, { targetType = 'target', keepRunning = false })
end

-- local chaotic = {}
-- function chaotic.condition()
--   return isSkillCastable(HVAN_CHAOTIC)
-- end
-- function chaotic.cast()
--   return cast(HVAN_CHAOTIC, MyOwner, { targetType = 'target', keepRunning = false })
-- end

local basicAttack = Parallel({
  Condition(node.basicAttack, Inversion(caprice.condition)),
  node.chaseEnemy,
})
local capriceParallel = Parallel({
  Condition(caprice.cast, caprice.condition),
  node.chaseEnemy,
})
local combat = Selector({
  Condition(capriceParallel, caprice.condition, condition.enemyIsAlive),
  Condition(basicAttack, condition.enemyIsAlive, Inversion(caprice.condition)),
})
local vanil = Selector({
  Condition(combat, condition.hasEnemyOrInList, condition.ownerIsNotTooFar),
  Condition(node.follow, condition.ownerMoving),
  Condition(node.patrol, condition.ownerIsSitting, Inversion(condition.hasEnemyOrInList)),
})
return Condition(vanil, IsVanilmirth)
