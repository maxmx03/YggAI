---@class Cooldown
local MyCooldown = {
  [MH_VOLCANIC_ASH] = 0,
  [MH_LAVA_SLIDE] = 0,
  [MH_GRANITIC_ARMOR] = 0,
  [MH_MAGMA_FLOW] = 0,
  [MH_PYROCLASTIC] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [MH_VOLCANIC_ASH] = {
    sp = function(level)
      return math.max(1, 55 + level * 5)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, (10 + (level * 2)) / 3)
    end,
    level_requirement = 102,
    level = 5,
  },
  ---@type Skill
  [MH_LAVA_SLIDE] = {
    sp = function(level)
      return math.max(1, 35 + level * 5)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 5 + level
    end,
    level_requirement = 109,
    level = 10,
  },
  [MH_GRANITIC_ARMOR] = {
    sp = function(level)
      return math.max(1, 50 + level * 4)
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 60
    end,
    level_requirement = 116,
    level = 5,
  },
  [MH_MAGMA_FLOW] = {
    sp = function(level)
      return math.max(1, 30 + level * 4)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 15 + level * 5)
    end,
    level_requirement = 122,
    level = 5,
  },
  [MH_PYROCLASTIC] = {
    sp = function(level)
      return math.max(1, 12 * level * 8)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 300 + level * 30)
    end,
    level_requirement = 131,
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

local volcanic = {}
function volcanic.CheckCanCastSkill()
  return check(MH_VOLCANIC_ASH)
end
function volcanic.CastSkill()
  return castGround(MH_VOLCANIC_ASH, MyEnemy)
end

local lava = {}
function lava.CheckCanCastSkill()
  return check(MH_LAVA_SLIDE)
end
function lava.CastSkill()
  return castGround(MH_LAVA_SLIDE, MyEnemy)
end

local granitic = {}
function granitic.CheckCanCastSkill()
  return check(MH_GRANITIC_ARMOR)
end
function granitic.CastSkill()
  return cast(MH_GRANITIC_ARMOR, MyID)
end

local magma = {}
function magma.CheckCanCastSkill()
  return check(MH_MAGMA_FLOW)
end
function magma.CastSkill()
  return cast(MH_MAGMA_FLOW, MyID)
end

local pyroclastic = {}
function pyroclastic.CheckCanCastSkill()
  return check(MH_PYROCLASTIC)
end
function pyroclastic.CastSkill()
  return cast(MH_PYROCLASTIC, MyID)
end

local combatNode = Parallel({
  ChaseEnemyNode,
  CheckEnemyIsAlive,
  CheckEnemyIsOutOfSight,
  Condition(BasicAttackNode, function()
    if check(MH_LAVA_SLIDE) == STATUS.SUCCESS then
      return false
    end
    return true
  end),
  CheckOwnerToofar,
})

return Selector({
  Sequence({
    CheckOwnerIsDying,
    granitic.CheckCanCastSkill,
    granitic.CastSkill,
  }),
  Sequence({
    CheckOwnerToofar,
    CheckIfHasEnemy,
    Selector({
      Sequence({
        CheckOwnerToofar,
        lava.CheckCanCastSkill,
        Parallel({
          CheckEnemyIsAlive,
          CheckEnemyIsOutOfSight,
          ChaseEnemyNode,
          lava.CastSkill,
        }),
      }),
      Sequence({
        CheckOwnerToofar,
        Reverse(lava.CheckCanCastSkill),
        volcanic.CheckCanCastSkill,
        Parallel({
          CheckEnemyIsAlive,
          CheckEnemyIsOutOfSight,
          ChaseEnemyNode,
          volcanic.CastSkill,
        }),
      }),
      combatNode,
      Sequence({
        magma.CheckCanCastSkill,
        magma.CastSkill,
      }),
      Sequence({
        pyroclastic.CheckCanCastSkill,
        pyroclastic.CastSkill,
      }),
    }),
  }),
})
