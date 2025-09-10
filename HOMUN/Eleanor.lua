---@class Cooldown
MyCooldown = {
  [MH_STYLE_CHANGE] = 0,
  [MH_SONIC_CRAW] = 0,
  [MH_SILVERVEIN_RUSH] = 0,
  [MH_MIDNIGHT_FRENZY] = 0,
  [MH_TINDER_BREAKER] = 0,
  [MH_CBC] = 0,
  [MH_EQC] = 0,
}

---@class Skills
MySkills = {
  ---@type Skill
  [MH_STYLE_CHANGE] = {
    cooldown = function(_)
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
      return math.max(1, 15 - level * 5)
    end,
    cooldown = function(_)
      return 0.5
    end,
    level_requirement = 100,
    level = 5,
    sphere_cost = 0,
  },
  ---@type Skill
  [MH_SILVERVEIN_RUSH] = {
    sp = function(level)
      return math.max(1, 15 + level * 2)
    end,
    cooldown = function(_)
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
    cooldown = function(_)
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
    cooldown = function(_)
      return 0.5
    end,
    level_requirement = 100,
    level = 5,
    sphere_cost = 0,
  },
  ---@type Skill
  [MH_CBC] = {
    sp = function(level)
      return math.max(1, 10 + level * 50)
    end,
    cooldown = function()
      return 0.3
    end,
    level_requirement = 112,
    level = 5,
    sphere_cost = 2,
  },
  ---@type Skill
  [MH_EQC] = {
    sp = function(level)
      return math.max(1, 20 + level * 5)
    end,
    cooldown = function()
      return 0.3
    end,
    level_requirement = 133,
    level = 5,
    sphere_cost = 2,
  },
}

BATTLE_FAILED = false

---@param mySkill number
local check = function(mySkill)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local sp = s.sp(s.level)
  local cd = s.cooldown(s.level)
  local lastTime = MyCooldown[MySkill]
  if s.sphere_cost > MySpheres then
    MySkill = 0
    return STATUS.FAILURE
  end
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
  local cd = s.cooldown(s.level)
  local lastTime = MyCooldown[MySkill]
  local sk = { level = s.level, id = MySkill, cooldown = cd, lastTime = lastTime, currentTime = CurrentTime }
  local casted = CastSkill(MyID, target, sk)
  if casted then
    local spAfterCast = GetSp(MyID)
    if spAfterCast == spBeforeCast then
      BATTLE_FAILED = true
      return STATUS.FAILURE
    end
    MyCooldown[MySkill] = CurrentTime
    BATTLE_FAILED = false
    return STATUS.RUNNING
  end
  MySkill = 0
  return STATUS.FAILURE
end

local function BasicAttack()
  local status = BasicAttackNode()
  local maxSpheres = 5
  local minSp = 200
  if status == STATUS.RUNNING then
    if MySpheres < maxSpheres then
      if math.random(2) == 1 then
        MySpheres = MySpheres + 1
      end
    end
  end
  if MySpheres == maxSpheres and HasEnoughSp(minSp) then
    return STATUS.FAILURE
  end
  return status
end

local switch = {}
function switch.checkCanCastSkill()
  return check(MH_STYLE_CHANGE)
end
function switch.castSkill()
  if math.random(4) ~= 1 then
    return STATUS.FAILURE
  end
  return cast(MH_STYLE_CHANGE, MyEnemy)
end

local sonic = {}
function sonic.checkCanCastSkill()
  return check(MH_SONIC_CRAW)
end
function sonic.castSkill()
  return cast(MH_SONIC_CRAW, MyEnemy)
end

local silver = {}
function silver.checkCanCastSkill()
  return check(MH_SILVERVEIN_RUSH)
end
function silver.castSkill()
  return cast(MH_SILVERVEIN_RUSH, MyEnemy)
end

local midnight = {}
function midnight.checkCanCastSkill()
  return check(MH_MIDNIGHT_FRENZY)
end
function midnight.castSkill()
  return cast(MH_MIDNIGHT_FRENZY, MyEnemy)
end

local tinder = {}
function tinder.checkCanCastSkill()
  return check(MH_TINDER_BREAKER)
end
function tinder.castSkill()
  return cast(MH_TINDER_BREAKER, MyEnemy)
end

local cbc = {}
function cbc.checkCanCastSkill()
  return check(MH_CBC)
end
function cbc.castSkill()
  return cast(MH_CBC, MyEnemy)
end

local eqc = {}
function eqc.checkCanCastSkill()
  return check(MH_EQC)
end
function eqc.castSkill()
  return cast(MH_EQC, MyEnemy)
end

local BattleModeSequence = Sequence({
  sonic.checkCanCastSkill,
  sonic.castSkill,
  Sequence({
    silver.checkCanCastSkill,
    silver.castSkill,
    Sequence({
      midnight.checkCanCastSkill,
      midnight.castSkill,
    }),
  }),
})

local ClawModeSequence = Sequence({
  tinder.checkCanCastSkill,
  tinder.castSkill,
  Sequence({
    cbc.checkCanCastSkill,
    cbc.castSkill,
    Sequence({
      eqc.checkCanCastSkill,
      eqc.castSkill,
    }),
  }),
})

local SwitchBattleMode = Sequence({
  switch.checkCanCastSkill,
  switch.castSkill,
})

local SkillAttackSequence = Selector({
  BattleModeSequence,
  ClawModeSequence,
  SwitchBattleMode,
})

return Selector({
  Sequence({
    CheckIfHasEnemy,
    CheckOwnerToofar,
    Selector({
      Parallel({
        ChaseEnemyNode,
        SkillAttackSequence,
        CheckEnemyIsDead,
        CheckEnemyIsOutOfSight,
      }),
      Parallel({
        ChaseEnemyNode,
        BasicAttack,
        CheckEnemyIsDead,
        CheckEnemyIsOutOfSight,
      }),
    }),
  }),
})
