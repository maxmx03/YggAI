---@class Cooldown
local MyCooldown = {
  [HLIF_HEAL] = 0,
  [HLIF_AVOID] = 0,
  [HLIF_CHANGE] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HLIF_HEAL] = {
    sp = function(level)
      return math.max(1, 10 + level * 3)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 20
    end,
    level_requirement = 15,
    level = 5,
  },
  ---@type Skill
  [HLIF_AVOID] = {
    sp = function(level)
      return math.max(1, 15 + level * 5)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 45 - level * 5)
    end,
    level_requirement = 40,
    level = 5,
  },
  [HLIF_CHANGE] = {
    sp = function()
      return 100
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
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

local heal = {}
function heal.CheckCanCastSkill()
  return check(HLIF_HEAL)
end
function heal.CastSkill()
  if LifCanHeal then
    return cast(HLIF_HEAL, MyOwner)
  end
  return STATUS.FAILURE
end

local avoid = {}
function avoid.CheckCanCastSkill()
  return check(HLIF_AVOID)
end
function avoid.CastSkill()
  return cast(HLIF_AVOID, MyOwner)
end

local change = {}
function change.CheckCanCastSkill()
  return check(HLIF_CHANGE)
end
function change.CastSkill()
  return cast(HLIF_CHANGE, MyID)
end

local combatNode = Parallel({
  ChaseEnemyNode,
  BasicAttackNode,
  CheckEnemyIsAlive,
  CheckEnemyIsOutOfSight,
})

return Selector({
  Sequence({
    heal.CheckCanCastSkill,
    CheckOwnerIsDying,
    heal.CastSkill,
  }),
  Sequence({
    CheckIfHasEnemy,
    CheckOwnerToofar,
    Selector({
      Sequence({
        avoid.CheckCanCastSkill,
        avoid.CastSkill,
        combatNode,
      }),
      Sequence({
        change.CheckCanCastSkill,
        change.CastSkill,
        combatNode,
      }),
      combatNode,
    }),
  }),
})
