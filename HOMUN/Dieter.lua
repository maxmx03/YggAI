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
    cooldown = function(level)
      return math.max(1, 10 + level * 2)
    end,
    level_requirement = 102,
    level = 5,
  },
  ---@type Skill
  [MH_LAVA_SLIDE] = {
    sp = function(level)
      return math.max(1, 35 + level * 5)
    end,
    cooldown = function(level)
      return math.max(1, 5 + level)
    end,
    level_requirement = 109,
    level = 10,
  },
  [MH_GRANITIC_ARMOR] = {
    sp = function(level)
      return math.max(1, 50 + level * 4)
    end,
    cooldown = function(_)
      return 60
    end,
    level_requirement = 116,
    level = 5,
  },
  [MH_MAGMA_FLOW] = {
    sp = function(level)
      return math.max(1, 30 + level * 4)
    end,
    cooldown = function(level)
      return math.max(1, 15 + level * 5)
    end,
    level_requirement = 122,
    level = 5,
  },
  [MH_PYROCLASTIC] = {
    sp = function(level)
      return math.max(1, 12 * level * 8)
    end,
    cooldown = function(level)
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

local volcanic = {}
function volcanic.CheckCanCastSkill()
  return check(MH_VOLCANIC_ASH)
end
function volcanic.CastSkill()
  local target = GetV(V_TARGET, MyEnemy)
  local mySkill = MH_VOLCANIC_ASH
  if target == MyID then
    return castGround(mySkill, MyID)
  elseif target ~= MyOwner then
    return castGround(mySkill, MyOwner)
  end
  return castGround(mySkill, MyEnemy)
end

local lava = {}
function lava.CheckCanCastSkill()
  return check(MH_LAVA_SLIDE)
end
function lava.CastSkill()
  local target = GetV(V_TARGET, MyEnemy)
  local mySkill = MH_LAVA_SLIDE
  if target == MyID then
    return castGround(mySkill, MyID)
  elseif target ~= MyOwner then
    return castGround(mySkill, MyOwner)
  end
  return castGround(mySkill, MyEnemy)
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

local function basicAttack()
  local status = BasicAttackNode()
  if check(MH_LAVA_SLIDE) == STATUS.SUCCESS or check(MH_VOLCANIC_ASH) == STATUS.SUCCESS then
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
    CheckOwnerIsDying,
    granitic.CheckCanCastSkill,
    granitic.CastSkill,
  }),
  Sequence({
    CheckIfHasEnemy,
    Selector({
      Sequence({
        CheckEnemyIsAlive,
        lava.CheckCanCastSkill,
        Parallel({
          CheckOwnerToofar,
          ChaseEnemyNode,
          lava.CastSkill,
          CheckEnemyIsAlive,
          CheckEnemyIsOutOfSight,
        }),
      }),
      Sequence({
        CheckEnemyIsAlive,
        volcanic.CheckCanCastSkill,
        Parallel({
          ChaseEnemyNode,
          volcanic.CastSkill,
          CheckEnemyIsAlive,
          CheckEnemyIsOutOfSight,
        }),
      }),
      Sequence({
        magma.CheckCanCastSkill,
        magma.CastSkill,
      }),
      Sequence({
        pyroclastic.CheckCanCastSkill,
        pyroclastic.CastSkill,
      }),
      combatNode,
    }),
  }),
})
