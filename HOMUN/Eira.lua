---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

---@class Cooldown
local MyCooldown = {
  [MH_ERASER_CUTTER] = 0,
  [MH_OVERED_BOOST] = 0,
  [MH_XENO_SLASHER] = 0,
  [MH_LIGHT_OF_REGENE] = 0,
  [MH_SILENT_BREEZE] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_ERASER_CUTTER] = {
    sp = function(level)
      return math.max(1, 20 + level * 5)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.3
    end,
    level_requirement = 106,
    level = 10,
  },
  ---@type Skill
  [MH_OVERED_BOOST] = {
    sp = function(level)
      return math.max(1, 50 + level * 20)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 15 + level * 5)
    end,
    level_requirement = 114,
    level = 5,
  },
  [MH_XENO_SLASHER] = {
    sp = function(level)
      return math.max(1, 80 + level * 10)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.3
    end,
    level_requirement = 121,
    level = 10,
  },
  [MH_LIGHT_OF_REGENE] = {
    sp = function()
      return 40
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 300 + level * 60)
    end,
    level_requirement = 128,
    level = 5,
  },
  [MH_SILENT_BREEZE] = {
    sp = function(level)
      return math.max(1, 36 * level * 9)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 1.5
    end,
    level_requirement = 137,
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
local castGround = function(mySkill)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local lastTime = MyCooldown[MySkill]
  local cd = s.cooldown(s.level, lastTime)
  local sk = { level = s.level, id = MySkill, cooldown = cd, lastTime = lastTime, currentTime = CurrentTime }
  local x, y = GetV(V_POSITION, MyEnemy)
  local casted = CastSkillGround(MyID, { x = x, y = y }, sk)
  if casted then
    MyCooldown[MySkill] = CurrentTime
    return STATUS.RUNNING
  end
  MySkill = 0
  return STATUS.FAILURE
end

local cutter = {}
function cutter.CheckCanCastSkill()
  return check(MH_ERASER_CUTTER)
end
function cutter.CastSkill()
  return cast(MH_ERASER_CUTTER, MyEnemy)
end

local overed = {}
function overed.CheckCanCastSkill()
  return check(MH_OVERED_BOOST)
end
function overed.CastSkill()
  return cast(MH_OVERED_BOOST, MyID)
end

local xeno = {}
function xeno.CheckCanCastSkill()
  return check(MH_XENO_SLASHER)
end
function xeno.CastSkill()
  return castGround(MH_XENO_SLASHER, MyEnemy)
end

local light = {}
function light.CheckCanCastSkill()
  return check(MH_LIGHT_OF_REGENE)
end
function light.CastSkill()
  return cast(MH_LIGHT_OF_REGENE, MyOwner)
end

---@return boolean
function condition.skillsInCooldown()
  if cutter.CheckCanCastSkill() == STATUS.SUCCESS or xeno.CheckCanCastSkill() == STATUS.SUCCESS then
    return false
  end
  return true
end

local basicAttack = Parallel({
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
  Condition(Condition(BasicAttackNode, condition.skillsInCooldown), condition.enemyIsAlive),
})
local cutterSequence = Sequence({
  cutter.CheckCanCastSkill,
  cutter.CastSkill,
})
local overedSequence = Sequence({
  overed.CheckCanCastSkill,
  overed.CastSkill,
})
local xenoSequence = Sequence({
  xeno.CheckCanCastSkill,
  xeno.CastSkill,
})
local lightSequence = Sequence({
  light.CheckCanCastSkill,
  light.CastSkill,
})
local cutterParallel = Parallel({
  Condition(cutterSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local xenoParallel = Parallel({
  Condition(xenoSequence, condition.enemyIsAlive),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})
local battleNode = Selector({
  Condition(overedSequence, condition.isMVP),
  Condition(Condition(xenoParallel, Inversion(condition.isWindMonster)), condition.ownerIsNotTooFar),
  Condition(Condition(xenoParallel, condition.isWaterMonster), condition.ownerIsNotTooFar),
  Condition(Condition(xenoParallel, condition.isPoisonMonster), condition.ownerIsNotTooFar),
  Condition(Condition(cutterParallel, Inversion(condition.isPoisonMonster)), condition.ownerIsNotTooFar),
  Condition(Condition(cutterParallel, Inversion(condition.isWaterMonster)), condition.ownerIsNotTooFar),
  Condition(Condition(cutterParallel, condition.isWindMonster), condition.ownerIsNotTooFar),
  Condition(basicAttack, condition.ownerIsNotTooFar),
})
local patrolNodeSequence = Sequence({
  Reverse(CheckIfHasEnemy),
  PatrolNode,
})
local eira = Selector({
  Condition(FollowNode, condition.ownerMoving),
  Condition(patrolNodeSequence, condition.ownerIsSitting),
  Condition(lightSequence, condition.ownerIsDead),
  Condition(battleNode, condition.hasEnemy),
})
return Condition(eira, IsEira)
