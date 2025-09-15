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

local BasicCombatNode = Parallel({
  CheckOwnerToofar,
  ChaseEnemyNode,
  Condition(BasicAttackNode, function()
    if xeno.CheckCanCastSkill() == STATUS.SUCCESS or cutter.CheckCanCastSkill() == STATUS.SUCCESS then
      return false
    end
    return true
  end),
  CheckEnemyIsAlive,
  CheckEnemyIsOutOfSight,
})

local xenoNode = Sequence({
  Reverse(CheckIsWindMonster),
  xeno.CheckCanCastSkill,
  xeno.CastSkill,
})
local lightNode = Sequence({
  light.CheckCanCastSkill,
  light.CastSkill,
})
local cutterNode = Sequence({
  Reverse(CheckIsWaterMonster),
  Reverse(CheckIsPoisonMonster),
  cutter.CheckCanCastSkill,
  cutter.CastSkill,
})

return Selector({
  Sequence({
    CheckOwnerIsDead,
    lightNode,
  }),
  Sequence({
    CheckIfHasEnemy,
    Selector({
      Sequence({
        CheckIsMVP,
        overed.CheckCanCastSkill,
        overed.CastSkill,
      }),
      BasicCombatNode,
      Parallel({
        CheckOwnerToofar,
        ChaseEnemyNode,
        xenoNode,
        CheckEnemyIsAlive,
        CheckEnemyIsOutOfSight,
      }),
      Parallel({
        CheckOwnerToofar,
        ChaseEnemyNode,
        cutterNode,
        CheckEnemyIsAlive,
        CheckEnemyIsOutOfSight,
      }),
    }),
  }),
})
