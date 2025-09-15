---@class Cooldown
local MyCooldown = {
  [HVAN_CAPRICE] = 0,
  [HVAN_CHAOTIC] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HVAN_CAPRICE] = {
    sp = function(level)
      return math.max(1, 20 + level * 2)
    end,
    cooldown = function(level, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return math.max(1, 2 + level * 0.2)
    end,
    level_requirement = 15,
    level = 5,
  },
  ---@type Skill
  [HVAN_CHAOTIC] = {
    sp = function(_)
      return 40
    end,
    cooldown = function(_, previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 3
    end,
    level_requirement = 40,
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

local caprice = {}

function caprice.CheckCanCastSkill()
  return check(HVAN_CAPRICE)
end

function caprice.CastSkill()
  return cast(HVAN_CAPRICE, MyEnemy)
end

local chaotic = {}
function chaotic.CheckCanCastSkill()
  return check(HVAN_CHAOTIC)
end
function chaotic.CastSkill()
  return cast(HVAN_CHAOTIC, MyOwner)
end

return Selector({
  Sequence({
    CheckOwnerIsDying,
    Sequence({
      chaotic.CheckCanCastSkill,
      Parallel({
        CheckOwnerIsDying,
        chaotic.CastSkill,
      }),
    }),
  }),
  Sequence({
    CheckIfHasEnemy,
    Selector({
      Sequence({
        CheckOwnerToofar,
        caprice.CheckCanCastSkill,
        Parallel({
          CheckOwnerToofar,
          Condition(ChaseEnemyNode, function()
            if CheckEnemyIsAlive() == STATUS.SUCCESS and CheckEnemyIsOutOfSight() == STATUS.SUCCESS then
              return true
            end
            return false
          end),
          Condition(caprice.CastSkill, function()
            if caprice.CheckCanCastSkill() == STATUS.SUCCESS then
              return true
            end
            return false
          end),
        }),
      }),
      Parallel({
        CheckOwnerToofar,
        ChaseEnemyNode,
        Condition(BasicAttackNode, function()
          if caprice.CheckCanCastSkill() == STATUS.SUCCESS then
            return false
          end
          return true
        end),
        CheckEnemyIsAlive,
        CheckEnemyIsOutOfSight,
      }),
    }),
  }),
})
