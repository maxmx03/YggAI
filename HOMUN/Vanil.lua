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
    sp = function(level)
      return math.max(1, 20 + level * 2)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 2 + level * 0.2)
    end,
    level_requirement = 15,
    level = 5,
  },
  ---@type Skill
  [HVAN_CHAOTIC] = {
    sp = function(_)
      return 40
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 3
    end,
    level_requirement = 40,
    level = 5,
  },
}

---@param mySkill number
local check = function(mySkill)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local sp = s.sp(s.level)
  local lastTime = MyCooldown[MySkill]
  local cd = s.cooldown(s.level, lastTime)
  if s.level_requirement > MyLevel then
    MySkill = 0
    return STATUS.FAILURE
  end
  return CheckCanCastSkill(sp, lastTime, cd)
end

---@param mySkill number
---@param target number
local cast = function(mySkill, target)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local lastTime = MyCooldown[MySkill]
  local cd = s.cooldown(s.level, lastTime)
  local sk = { level = s.level, id = MySkill, cooldown = cd, lastTime = lastTime, currentTime = CurrentTime }
  local casted = CastSkill(MyID, target, sk)
  if casted then
    MyCooldown[MySkill] = CurrentTime
    return STATUS.RUNNING
  end
  MySkill = 0
  return STATUS.FAILURE
end

local caprice = {}

function caprice.CheckCanCastSkill()
  return check(HVAN_CAPRICE)
end
function caprice.CastSkill()
  return cast(HVAN_CAPRICE, MyEnemy)
end

local chaotic = {}
function chaotic.CheckCanCastSkill()
  return check(HVAN_CHAOTIC)
end
function chaotic.CastSkill()
  return cast(HVAN_CHAOTIC, MyOwner)
end

---@return boolean
function condition.skillsInCooldown()
  if caprice.CheckCanCastSkill() == STATUS.SUCCESS then
    return false
  end
  return true
end

local basicAttack = Parallel({
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
  Condition(Condition(BasicAttackNode, condition.skillsInCooldown), condition.enemyIsAlive),
})
local capriceSequence = Sequence({
  caprice.CheckCanCastSkill,
  caprice.CastSkill,
})
local chaoticSequence = Sequence({
  chaotic.CheckCanCastSkill,
  chaotic.CastSkill,
})
local capriceParallel = Parallel({
  Condition(capriceSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local chaoticParallel = Parallel({
  Condition(chaoticSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local battleNode = Selector({
  Condition(capriceParallel, condition.ownerIsNotTooFar),
  Condition(basicAttack, condition.ownerIsNotTooFar),
})
local patrolNodeSequence = Sequence({
  Reverse(CheckIfHasEnemy),
  PatrolNode,
})
local vanil = Selector({
  Condition(FollowNode, condition.ownerMoving),
  Condition(Condition(chaoticParallel, condition.ownerIsDying), Inversion(condition.hasEnemy)),
  Condition(patrolNodeSequence, condition.ownerIsSitting),
  Condition(battleNode, condition.hasEnemy),
})
return Condition(vanil, IsVanilmirth)
