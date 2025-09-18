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
      return 1.5
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
      return 1.5
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
      return 0.5
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
      return 0.3
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
      return 0.3
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
local cast = function(mySkill, target)
  local spBeforeCast = GetSp(MyID)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local lastTime = MyCooldown[MySkill]
  local cd = s.cooldown(s.level, lastTime)
  local sk = { level = s.level, id = MySkill, cooldown = cd, lastTime = lastTime, currentTime = CurrentTime }
  local casted = CastSkill(MyID, target, sk)
  if casted then
    local spAfterCast = GetSp(MyID)
    if spAfterCast == spBeforeCast and spBeforeCast > 0 then
      if BATTLE_MODE.CURRENT == BATTLE_MODE.BATTLE then
        BATTLE_MODE.CURRENT = BATTLE_MODE.CLAW
      else
        BATTLE_MODE.CURRENT = BATTLE_MODE.BATTLE
      end
      return STATUS.FAILURE
    end
    MyCooldown[MySkill] = CurrentTime
    if MySpheres > 0 then
      MySpheres = MySpheres - s.sphere_cost
    end
    return STATUS.RUNNING
  end
  MySkill = 0
  return STATUS.FAILURE
end

local switch = {}
function switch.CheckCanCastSkill()
  return check(MH_STYLE_CHANGE)
end
function switch.CastSkill()
  if math.random(4) == 1 then
    return cast(MH_STYLE_CHANGE, MyID)
  end
  return STATUS.FAILURE
end

local sonic = {}
function sonic.CheckCanCastSkill()
  if BATTLE_MODE.CURRENT ~= BATTLE_MODE.BATTLE then
    return STATUS.FAILURE
  end
  return check(MH_SONIC_CRAW)
end
function sonic.CastSkill()
  return cast(MH_SONIC_CRAW, MyEnemy)
end

local silver = {}
function silver.CheckCanCastSkill()
  if BATTLE_MODE.CURRENT ~= BATTLE_MODE.BATTLE then
    return STATUS.FAILURE
  end
  return check(MH_SILVERVEIN_RUSH)
end
function silver.CastSkill()
  return cast(MH_SILVERVEIN_RUSH, MyEnemy)
end

local midnight = {}
function midnight.CheckCanCastSkill()
  if BATTLE_MODE.CURRENT ~= BATTLE_MODE.BATTLE then
    return STATUS.FAILURE
  end
  return check(MH_MIDNIGHT_FRENZY)
end
function midnight.CastSkill()
  return cast(MH_MIDNIGHT_FRENZY, MyEnemy)
end

local tinder = {}
function tinder.CheckCanCastSkill()
  if BATTLE_MODE.CURRENT ~= BATTLE_MODE.CLAW then
    return STATUS.FAILURE
  end
  return check(MH_TINDER_BREAKER)
end
function tinder.CastSkill()
  return cast(MH_TINDER_BREAKER, MyEnemy)
end

local cbc = {}
function cbc.CheckCanCastSkill()
  if BATTLE_MODE.CURRENT ~= BATTLE_MODE.CLAW then
    return STATUS.FAILURE
  end
  return check(MH_CBC)
end
function cbc.CastSkill()
  return cast(MH_CBC, MyEnemy)
end

local eqc = {}
function eqc.CheckCanCastSkill()
  if BATTLE_MODE.CURRENT ~= BATTLE_MODE.CLAW then
    return STATUS.FAILURE
  end
  return check(MH_EQC)
end
function eqc.CastSkill()
  return cast(MH_EQC, MyEnemy)
end

---@return boolean
function condition.skillsInCooldown()
  local maxSpheres = 5
  if MySpheres < maxSpheres then
    if math.random(2) == 1 then
      MySpheres = MySpheres + 1
    end
  else
    local sonicStatus = sonic.CheckCanCastSkill()
    local tinderStatus = tinder.CheckCanCastSkill()
    if sonicStatus == STATUS.SUCCESS and tinderStatus == STATUS.SUCCESS then
      return false
    end
  end
  return true
end

local switchSequence = Sequence({
  switch.CheckCanCastSkill,
  switch.CastSkill,
})

local sonicSequence = Sequence({
  sonic.CheckCanCastSkill,
  sonic.CastSkill,
})

local silverSequence = Sequence({
  silver.CheckCanCastSkill,
  silver.CastSkill,
})

local midnightSequence = Sequence({
  midnight.CheckCanCastSkill,
  midnight.CastSkill,
})

local tinderSequence = Sequence({
  tinder.CheckCanCastSkill,
  tinder.CastSkill,
})

local cbcSequence = Sequence({
  cbc.CheckCanCastSkill,
  cbc.CastSkill,
})

local eqcSequence = Sequence({
  eqc.CheckCanCastSkill,
  eqc.CastSkill,
})

local battleComboSequence = Sequence({
  sonic.CheckCanCastSkill,
  sonic.CastSkill,
  Sequence({
    silver.CheckCanCastSkill,
    silver.CastSkill,
    Sequence({
      midnight.CheckCanCastSkill,
      midnight.CastSkill,
    }),
  }),
})

local clawComboSequence = Sequence({
  tinder.CheckCanCastSkill,
  tinder.CastSkill,
  Sequence({
    cbc.CheckCanCastSkill,
    cbc.CastSkill,
    Sequence({
      eqc.CheckCanCastSkill,
      eqc.CastSkill,
    }),
  }),
})

local battleModeSequence = Selector({
  battleComboSequence,
  sonicSequence,
  silverSequence,
  midnightSequence,
})

local clawModeSequence = Selector({
  clawComboSequence,
  tinderSequence,
  cbcSequence,
  eqcSequence,
})

local skillAttackSequence = Selector({
  battleModeSequence,
  clawModeSequence,
  switchSequence,
})

local basicAttack = Parallel({
  Condition(ChaseEnemyNode, condition.enemyIsNotOutOfSight),
  Condition(
    Condition(Condition(BasicAttackNode, condition.skillsInCooldown), condition.enemyIsAlive),
    condition.ownerIsNotTooFar
  ),
})

local battleNode = Selector({
  Condition(Condition(skillAttackSequence, condition.enemyIsAlive), condition.ownerIsNotTooFar),
  Condition(basicAttack, condition.ownerIsNotTooFar),
})

local patrolNodeSequence = Sequence({
  Reverse(CheckIfHasEnemy),
  PatrolNode,
})

local eleanor = Selector({
  Condition(FollowNode, condition.ownerMoving),
  Condition(patrolNodeSequence, condition.ownerIsSitting),
  Condition(battleNode, condition.hasEnemy),
})

return Condition(eleanor, IsEleanor)
