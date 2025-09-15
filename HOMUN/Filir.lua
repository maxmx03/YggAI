---@class Cooldown
local MyCooldown = {
  [HFLI_MOON] = 0,
  [HFLI_FLEET] = 0,
  [HFLI_SPEED] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HFLI_MOON] = {
    sp = function(level)
      return math.max(1, level * 4)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 2
    end,
    level_requirement = 15,
    level = 5,
  },
  ---@type Skill
  [HFLI_FLEET] = {
    sp = function(level)
      return math.max(1, 20 + level * 10)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 65 + level * 5)
    end,
    level_requirement = 40,
    level = 5,
  },
  [HFLI_SPEED] = {
    sp = function(level)
      return math.max(1, 20 + level * 10)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 65 + level * 5)
    end,
    level_requirement = 70,
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

local moon = {}

function moon.CheckCanCastSkill()
  return check(HFLI_MOON)
end

function moon.CastSkill()
  return cast(HFLI_MOON, MyEnemy)
end

local fleet = {}

function fleet.CheckCanCastSkill()
  return check(HFLI_FLEET)
end

function fleet.CastSkill()
  return cast(HFLI_FLEET, MyID)
end

local speed = {}

function speed.CheckCanCastSkill()
  return check(HFLI_SPEED)
end

function speed.CastSkill()
  return cast(HFLI_SPEED, MyID)
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
        fleet.CheckCanCastSkill,
        fleet.CastSkill,
      }),
      Sequence({
        speed.CheckCanCastSkill,
        speed.CastSkill,
      }),
      Sequence({
        moon.CheckCanCastSkill,
        Parallel({
          CheckOwnerToofar,
          ChaseEnemyNode,
          moon.CastSkill,
          CheckEnemyIsAlive,
          CheckEnemyIsOutOfSight,
        }),
      }),
      combatNode,
    }),
  }),
})
