---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

local MyCooldown = {
  [MH_STAHL_HORN] = 0,
  [MH_GOLDENE_FERSE] = 0,
  [MH_STEINWAND] = 0,
  [MH_ANGRIFFS_MODUS] = 0,
  [MH_HEILIGE_STANGE] = 0,
}

local MySkills = {
  ---@type Skill
  [MH_STAHL_HORN] = {
    sp = function(level)
      return math.max(1, 40 + level * 3)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.5
    end,
    level_requirement = 105,
    level = 10,
  },
  ---@type Skill
  [MH_GOLDENE_FERSE] = {
    sp = function(level)
      return math.max(1, 55 + level * 5)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 0.8 + level * 0.2)
    end,
    level_requirement = 112,
    level = 5,
  },
  ---@type Skill
  [MH_STEINWAND] = {
    sp = function(level)
      return math.max(1, 70 + level * 10)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 1 + level * 0.2)
    end,
    level_requirement = 121,
    level = 5,
  },
  ---@type Skill
  [MH_ANGRIFFS_MODUS] = {
    sp = function(level)
      return math.max(1, 55 + level * 5)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 2.2 - level * 0.2)
    end,
    level_requirement = 130,
    level = 5,
  },
  ---@type Skill
  [MH_HEILIGE_STANGE] = {
    sp = function(level)
      return math.max(1, 42 + level * 6)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 2.2 - level * 0.2)
    end,
    level_requirement = 138,
    level = 10,
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

local stahl = {}
function stahl.CheckCanCastSkill()
  return check(MH_STAHL_HORN)
end
function stahl.CastSkill()
  return cast(MH_STAHL_HORN, MyEnemy)
end

local gold = {}
function gold.CheckCanCastSkill()
  return check(MH_GOLDENE_FERSE)
end
function gold.CastSkill()
  return cast(MH_GOLDENE_FERSE, MyEnemy)
end

local stein = {}
function stein.CheckCanCastSkill()
  return check(MH_STEINWAND)
end
function stein.CastSkill()
  return cast(MH_STEINWAND, MyOwner)
end

local ang = {}
function ang.CheckCanCastSkill()
  return check(MH_ANGRIFFS_MODUS)
end
function ang.CastSkill()
  return cast(MH_ANGRIFFS_MODUS, MyOwner)
end

local heil = {}
function heil.CheckCanCastSkill()
  return check(MH_HEILIGE_STANGE)
end
function heil.CastSkill()
  return cast(MH_HEILIGE_STANGE, MyEnemy)
end

---@return boolean
function condition.skillsInCooldown()
  if
    stein.CheckCanCastSkill() == STATUS.SUCCESS
    or stahl.CheckCanCastSkill() == STATUS.SUCCESS
    or heil.CheckCanCastSkill() == STATUS.SUCCESS
  then
    return false
  end
  return true
end

local basicAttack = Parallel({
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
  Condition(Condition(BasicAttackNode, condition.skillsInCooldown), condition.enemyIsAlive),
})
local stahlSequence = Sequence({
  stahl.CheckCanCastSkill,
  stahl.CastSkill,
})
local stahlParallel = Parallel({
  Condition(stahlSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local goldSequence = Sequence({
  gold.CheckCanCastSkill,
  gold.CastSkill,
})
local steinSequence = Sequence({
  stein.CheckCanCastSkill,
  stein.CastSkill,
})
local angSequence = Sequence({
  ang.CheckCanCastSkill,
  ang.CastSkill,
})
local heilSequence = Sequence({
  heil.CheckCanCastSkill,
  heil.CastSkill,
})
local heilParallel = Parallel({
  Condition(heilSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local battleNode = Selector({
  Condition(steinSequence, condition.ownerIsNotTooFar),
  Condition(stahlParallel, condition.ownerIsNotTooFar),
  Condition(goldSequence, condition.ownerIsNotTooFar),
  Condition(angSequence, condition.ownerIsNotTooFar),
  Condition(heilParallel, condition.ownerIsNotTooFar),
  Condition(basicAttack, condition.ownerIsNotTooFar),
})
local patrolNodeSequence = Sequence({
  Reverse(CheckIfHasEnemy),
  PatrolNode,
})
local bayeri = Selector({
  Condition(FollowNode, condition.ownerMoving),
  Condition(patrolNodeSequence, condition.ownerIsSitting),
  Condition(steinSequence, condition.ownerIsDying),
  Condition(battleNode, condition.hasEnemy),
})
return Condition(bayeri, IsBayeri)
