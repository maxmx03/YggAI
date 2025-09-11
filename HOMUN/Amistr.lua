---@class Cooldown
local MyCooldown = {
  [HAMI_CASTLE] = 0,
  [HAMI_DEFENCE] = 0,
  [HAMI_BLOODLUST] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HAMI_CASTLE] = {
    sp = function(_)
      return 10
    end,
    cooldown = function(_)
      return 1
    end,
    level_requirement = 15,
    level = 5,
  },
  ---@type Skill
  [HAMI_DEFENCE] = {
    sp = function(level)
      return math.max(1, 15 + level * 5)
    end,
    cooldown = function(_)
      return 30
    end,
    level_requirement = 40,
    level = 5,
  },
  [HAMI_BLOODLUST] = {
    sp = function()
      return 120
    end,
    cooldown = function(level)
      return math.max(1, 60 - level * 120)
    end,
    level_requirement = 70,
    level = 3,
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
local cast = function(mySkill)
  MySkill = mySkill
  ---@type Skill
  local s = MySkills[MySkill]
  local cd = s.cooldown(s.level)
  local lastTime = MyCooldown[MySkill]
  local sk = { level = s.level, id = MySkill, cooldown = cd, lastTime = lastTime, currentTime = CurrentTime }
  local casted = CastSkill(MyID, MyID, sk)
  if casted then
    MyCooldown[MySkill] = CurrentTime
    return STATUS.RUNNING
  end
  MySkill = 0
  return STATUS.FAILURE
end

-- local castle = {}
-- function castle.CheckCanCastSkill()
--   return check(HAMI_CASTLE)
-- end
--
-- function castle.CastSkill()
--   return cast(HAMI_CASTLE)
-- end

local defense = {}
function defense.CheckCanCastSkill()
  return check(HAMI_DEFENCE)
end

function defense.CastSkill()
  return cast(HAMI_DEFENCE)
end

local bloodlust = {}

function bloodlust.CheckCanCastSkill()
  return check(HAMI_BLOODLUST)
end

function bloodlust.CastSkill()
  return cast(HAMI_BLOODLUST)
end

local combatNode = Parallel({
  CheckOwnerToofar,
  ChaseEnemyNode,
  BasicAttackNode,
  CheckEnemyIsAlive,
  CheckEnemyIsOutOfSight,
})

return Selector({
  Sequence({
    CheckIfHasEnemy,
    Selector({
      Sequence({
        defense.CheckCanCastSkill,
        defense.CastSkill,
        combatNode,
      }),
      Sequence({
        bloodlust.CheckCanCastSkill,
        bloodlust.CastSkill,
        combatNode,
      }),
      combatNode,
    }),
  }),
})
