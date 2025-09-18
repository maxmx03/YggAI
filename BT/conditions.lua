---@class Condition
local M = {}

---@return boolean
function M.hasEnemy()
  MyEnemy = GetMyEnemy(MyID)
  if MyEnemy ~= 0 and MyEnemy ~= -1 then
    return true
  end
  MyEnemy = 0
  return false
end

---@return boolean
function M.enemyIsNotOutOfSight()
  if IsOutOfSight(MyID, MyEnemy) then
    MyEnemy = 0
    return false
  end
  return true
end

---@return boolean
function M.enemyIsAlive()
  if GetV(V_MOTION, MyEnemy) == MOTION_DEAD then
    MyEnemy = 0
    return false
  end
  return true
end

---@return boolean
function M.ownerMoving()
  if GetDistanceFromOwner(MyID) > 3 then
    return true
  end
  return false
end

---@return boolean
function M.ownerIsNotTooFar()
  if GetDistanceFromOwner(MyID) > 7 and GetV(V_MOTION, MyOwner) == MOTION_MOVE then
    return false
  end
  return true
end

---@return boolean
function M.ownerIsSitting()
  if GetV(V_MOTION, MyOwner) ~= MOTION_SIT then
    return false
  end
  return true
end

---@return boolean
function M.ownerIsOutOfSight()
  if IsOutOfSight(MyID, MyOwner) then
    return false
  end
  return true
end

---@return boolean
function M.ownerIsDying()
  local ownerHp = GetHp(MyOwner)
  local ownerMaxHp = GetMaxHp(MyOwner)
  local ownerDying = ownerHp <= ownerMaxHp * 0.3
  if ownerDying then
    return true
  end
  return false
end

---@return boolean
function M.ownerIsDead()
  local ownerDead = GetV(V_MOTION, MyOwner) == MOTION_DEAD
  if ownerDead then
    return true
  end
  return false
end

---@return boolean
function M.canCastSkill()
  local ownerDead = GetV(V_MOTION, MyOwner) == MOTION_DEAD
  if ownerDead then
    return true
  end
  return false
end

---@return boolean
function M.isMVP()
  if IsMVP(MyEnemy) then
    return true
  end
  return false
end

function M.isPoisonMonster()
  if IsPoisonMonster(MyEnemy) then
    return true
  end
  return false
end

function M.isWindMonster()
  if IsWindMonster(MyEnemy) then
    return true
  end
  return false
end

function M.isWaterMonster()
  if IsWaterMonster(MyEnemy) then
    return true
  end
  return false
end

return M
