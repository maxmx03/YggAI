---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

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
    sp = function(level)
      return math.max(1, 36 + level * 6)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 10
    end,
    level_requirement = 105,
    level = 10,
  },
  ---@type Skill
  [MH_POISON_MIST] = {
    sp = function(level)
      return math.max(1, 55 + level * 10)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 15
    end,
    level_requirement = 116,
    level = 5,
  },
  ---@type Skill
  [MH_PAIN_KILLER] = {
    sp = function(level)
      return math.max(1, 44 + level * 4)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 300 + level * 30)
    end,
    level_requirement = 123,
    level = 10,
  },
  ---@type Skill
  [MH_SUMMON_LEGION] = {
    sp = function(level)
      return math.max(1, 10 + level * 10)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      if MyEnemy ~= 0 and IsMVP(MyEnemy) then
        return 15
      elseif MyEnemy ~= 0 and IsBoss(MyEnemy) then
        return 30
      end
      return 60
    end,
    level_requirement = 132,
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

---@param mySkill number
---@param target number
---@return Status
local castGround = function(mySkill, target)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local lastTime = MyCooldown[MySkill]
  local cd = s.cooldown(s.level, lastTime)
  local sk = { level = s.level, id = MySkill, cooldown = cd, lastTime = lastTime, currentTime = CurrentTime }
  local x, y = GetV(V_POSITION, target)
  local casted = CastSkillGround(MyID, { x = x, y = y }, sk)
  if casted then
    MyCooldown[MySkill] = CurrentTime
    return STATUS.RUNNING
  end
  MySkill = 0
  return STATUS.FAILURE
end

local paralyse = {}
function paralyse.CheckCanCastSkill()
  return check(MH_NEEDLE_OF_PARALYZE)
end
function paralyse.CastSkill()
  return cast(MH_NEEDLE_OF_PARALYZE, MyOwner)
end

local poisonMist = {}
function poisonMist.CheckCanCastSkill()
  return check(MH_POISON_MIST)
end
function poisonMist.CastSkill()
  return castGround(MH_POISON_MIST, MyEnemy)
end

local painKiller = {}
function painKiller.CheckCanCastSkill()
  return check(MH_PAIN_KILLER)
end
function painKiller.CastSkill()
  return cast(MH_PAIN_KILLER, MyID)
end

local summonLegion = {}
function summonLegion.CheckCanCastSkill()
  return check(MH_SUMMON_LEGION)
end
function summonLegion.CastSkill()
  return cast(MH_SUMMON_LEGION, MyEnemy)
end

---@return boolean
function condition.skillsInCooldown()
  if
    poisonMist.CheckCanCastSkill() == STATUS.SUCCESS
    or painKiller.CheckCanCastSkill() == STATUS.SUCCESS
    or summonLegion.CheckCanCastSkill() == STATUS.SUCCESS
    or paralyse.CheckCanCastSkill() == STATUS.SUCCESS
  then
    return false
  end
  return true
end

local basicAttack = Parallel({
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
  Condition(Condition(BasicAttackNode, condition.skillsInCooldown), condition.enemyIsAlive),
})
local poisonMistSequence = Sequence({
  poisonMist.CheckCanCastSkill,
  poisonMist.CastSkill,
})
local painKillerSequence = Sequence({
  painKiller.CheckCanCastSkill,
  painKiller.CastSkill,
})
local paralyseSequence = Sequence({
  paralyse.CheckCanCastSkill,
  paralyse.CastSkill,
})
local summonLegionSequence = Sequence({
  summonLegion.CheckCanCastSkill,
  summonLegion.CastSkill,
})
local summonLegionParallel = Parallel({
  Condition(summonLegionSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local poisonMistParallel = Parallel({
  Condition(poisonMistSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local paralyseParallel = Parallel({
  Condition(paralyseSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local mvpSelector = Selector({
  Condition(painKillerSequence, condition.ownerIsNotTooFar),
  Condition(summonLegionParallel, condition.ownerIsNotTooFar),
  Condition(paralyseParallel, condition.ownerIsNotTooFar),
  Condition(poisonMistParallel, condition.ownerIsNotTooFar),
})
local battleNode = Selector({
  Condition(mvpSelector, condition.isMVP),
  Condition(poisonMistParallel, condition.ownerIsNotTooFar),
  Condition(painKillerSequence, condition.ownerIsNotTooFar),
  Condition(basicAttack, condition.ownerIsNotTooFar),
})
local patrolNodeSequence = Sequence({
  Reverse(CheckIfHasEnemy),
  PatrolNode,
})
local sera = Selector({
  Condition(FollowNode, condition.ownerMoving),
  Condition(patrolNodeSequence, condition.ownerIsSitting),
  Condition(battleNode, condition.hasEnemy),
})
return Condition(sera, IsSera)
