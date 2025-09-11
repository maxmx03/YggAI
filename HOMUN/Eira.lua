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
    cooldown = function(_)
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
    cooldown = function(level)
      return math.max(1, 15 + level * 5)
    end,
    level_requirement = 114,
    level = 5,
  },
  [MH_XENO_SLASHER] = {
    sp = function(level)
      return math.max(1, 80 + level * 10)
    end,
    cooldown = function(_)
      return 0.3
    end,
    level_requirement = 121,
    level = 10,
  },
  [MH_LIGHT_OF_REGENE] = {
    sp = function()
      return 40
    end,
    cooldown = function(level)
      return math.max(1, 300 + level * 60)
    end,
    level_requirement = 128,
    level = 5,
  },
  [MH_SILENT_BREEZE] = {
    sp = function(level)
      return math.max(1, 36 * level * 9)
    end,
    cooldown = function()
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
  local cd = s.cooldown(s.level)
  local lastTime = MyCooldown[MySkill]
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
  local cd = s.cooldown(s.level)
  local lastTime = MyCooldown[MySkill]
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
  local cd = s.cooldown(s.level)
  local lastTime = MyCooldown[MySkill]
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

-- local overed = {}
-- function overed.CheckCanCastSkill()
--   return check(MH_OVERED_BOOST)
-- end
-- function overed.CastSkill()
--   return cast(MH_OVERED_BOOST, MyID)
-- end

local xeno = {}
function xeno.CheckCanCastSkill()
  return check(MH_XENO_SLASHER)
end
function xeno.CastSkill()
  local target = GetV(V_TARGET, MyEnemy)
  local mySkill = MH_XENO_SLASHER
  if target == MyID then
    return castGround(mySkill, MyID)
  elseif target ~= MyOwner then
    return castGround(mySkill, MyOwner)
  end
  return castGround(mySkill, MyEnemy)
end

local light = {}
function light.CheckCanCastSkill()
  return check(MH_LIGHT_OF_REGENE)
end
function light.CastSkill()
  return cast(MH_LIGHT_OF_REGENE, MyOwner)
end

local function basicAttack()
  local status = BasicAttackNode()
  if check(MH_XENO_SLASHER) == STATUS.SUCCESS or check(MH_ERASER_CUTTER) == STATUS.SUCCESS then
    return STATUS.FAILURE
  end
  return status
end

local combatNode = Parallel({
  CheckOwnerToofar,
  ChaseEnemyNode,
  CheckEnemyIsAlive,
  CheckEnemyIsOutOfSight,
  basicAttack,
})

return Selector({
  Sequence({
    CheckOwnerIsDead,
    light.CheckCanCastSkill,
    light.CastSkill,
  }),
  Sequence({
    CheckIfHasEnemy,
    Selector({
      combatNode,
      Sequence({
        CheckEnemyIsAlive,
        xeno.CheckCanCastSkill,
        Parallel({
          ChaseEnemyNode,
          xeno.CastSkill,
          CheckEnemyIsAlive,
          CheckEnemyIsOutOfSight,
        }),
      }),
      Sequence({
        CheckEnemyIsAlive,
        cutter.CheckCanCastSkill,
        Parallel({
          CheckOwnerToofar,
          ChaseEnemyNode,
          cutter.CastSkill,
          CheckEnemyIsAlive,
          CheckEnemyIsOutOfSight,
        }),
      }),
    }),
  }),
})
