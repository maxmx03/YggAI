---@type Condition
local condition = require('AI.USER_AI.BT.conditions')

local MyCooldown = {
  [MH_STYLE_CHANGE] = 0,
  [MH_SONIC_CRAW] = 0,
  [MH_SILVERVEIN_RUSH] = 0,
  [MH_MIDNIGHT_FRENZY] = 0,
  [MH_TINDER_BREAKER] = 0,
  [MH_CBC] = 0,
  [MH_EQC] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_STYLE_CHANGE] = {
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 1
    end,
    sp = function(_)
      return 35
    end,
    level_requirement = 100,
    level = 5,
    sphere_cost = 0,
  },
  ---@type Skill
  [MH_SONIC_CRAW] = {
    sp = function(level)
      return math.max(1, 15 + level * 5)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.5
    end,
    level_requirement = 100,
    level = 5,
    sphere_cost = 1,
  },
  ---@type Skill
  [MH_SILVERVEIN_RUSH] = {
    sp = function(level)
      return math.max(1, 15 + level * 2)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 3
    end,
    level_requirement = 114,
    level = 10,
    sphere_cost = 1,
  },
  ---@type Skill
  [MH_MIDNIGHT_FRENZY] = {
    sp = function(level)
      return math.max(1, 15 + level * 3)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 3
    end,
    level_requirement = 128,
    level = 10,
    sphere_cost = 1,
  },
  ---@type Skill
  [MH_TINDER_BREAKER] = {
    sp = function(level)
      return math.max(1, 15 + level * 5)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0
    end,
    level_requirement = 100,
    level = 5,
    sphere_cost = 1,
  },
  ---@type Skill
  [MH_CBC] = {
    sp = function(level)
      return math.max(1, 10 + level * 50)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0
    end,
    level_requirement = 112,
    level = 5,
    sphere_cost = 2,
  },
  ---@type Skill
  [MH_EQC] = {
    sp = function(level)
      return math.max(1, 20 + level * 4)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0
    end,
    level_requirement = 133,
    level = 5,
    sphere_cost = 2,
  },
}

---@enum BattleMode
BATTLE_MODE = {
  BATTLE = 1,
  CLAW = 2,
  CURRENT = 1,
}

---@param mySkill number
---@return Status
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
---@param continuous boolean?
local cast = function(mySkill, target, continuous)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local lastTime = MyCooldown[MySkill]
  local cd = s.cooldown(s.level, lastTime)
  local sk = { level = s.level, id = MySkill, cooldown = cd, lastTime = lastTime, currentTime = GetTick() / 1000 }
  local casted = CastSkill(MyID, target, sk)
  if casted then
    MyCooldown[MySkill] = GetTick() / 1000
    if MySpheres > 0 then
      MySpheres = math.max(0, MySpheres - s.sphere_cost)
    end
    if continuous then
      return STATUS.RUNNING
    end
    return STATUS.SUCCESS
  end
  MySkill = 0
  return STATUS.FAILURE
end

local silver = {}
function silver.CheckCanCastSkill()
  return check(MH_SILVERVEIN_RUSH)
end
function silver.CastSkill()
  return cast(MH_SILVERVEIN_RUSH, MyEnemy)
end
local midnight = {}
function midnight.CheckCanCastSkill()
  return check(MH_MIDNIGHT_FRENZY)
end
function midnight.CastSkill()
  return cast(MH_MIDNIGHT_FRENZY, MyEnemy)
end
local sonic = {}
function sonic.CheckCanCastSkill()
  return check(MH_SONIC_CRAW)
end
function sonic.CastSkill()
  if silver.CheckCanCastSkill() == STATUS.FAILURE and midnight.CheckCanCastSkill() == STATUS.FAILURE then
    return cast(MH_SONIC_CRAW, MyEnemy, true)
  end
  return cast(MH_SONIC_CRAW, MyEnemy)
end

---@return boolean
function condition.skillsInCooldown()
  math.randomseed(GetTick())
  local maxSpheres = 5
  if MySpheres < maxSpheres then
    MySpheres = MySpheres + 1
  else
    local sonicStatus = sonic.CheckCanCastSkill()
    if sonicStatus == STATUS.SUCCESS then
      return false
    end
  end
  return true
end

local sonicSequence = Sequence({
  sonic.CheckCanCastSkill,
  sonic.CastSkill,
})

local silverSequence = Sequence({
  silver.CheckCanCastSkill,
  Delay(silver.CastSkill, 2.0),
})

local midnightSequence = Sequence({
  midnight.CheckCanCastSkill,
  Delay(midnight.CastSkill, 2.0),
})

local battleComboSequence = Sequence({
  sonicSequence,
  silverSequence,
  midnightSequence,
})

local battleComboParallelSequence = Parallel({
  Condition(Condition(battleComboSequence, condition.enemyIsAlive), condition.ownerIsNotTooFar),
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
})

local basicAttack = Parallel({
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
  Condition(
    Condition(Condition(BasicAttackNode, condition.skillsInCooldown), condition.enemyIsAlive),
    condition.ownerIsNotTooFar
  ),
})

local battleNode = Selector({
  Condition(Condition(battleComboParallelSequence, condition.enemyIsAlive), condition.ownerIsNotTooFar),
  Condition(basicAttack, condition.ownerIsNotTooFar),
})
local eleanor = Selector({
  Condition(FollowNode, condition.ownerMoving),
  Condition(Condition(PatrolNode, condition.ownerIsSitting), Inversion(condition.hasEnemy)),
  Condition(battleNode, condition.hasEnemy),
})

return Condition(eleanor, IsEleanor)
