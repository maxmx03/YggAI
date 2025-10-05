---@class Condition
local M = {}

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
  if MyEnemy == 0 then
    return false
  end
  if GetV(V_MOTION, MyEnemy) == MOTION_DEAD then
    MyEnemy = 0
    return false
  end
  return true
end

---@return boolean
function M.enemyIsNotInAttackSight()
  if IsInAttackSight(MyID, MyEnemy) then
    return false
  end
  return true
end

---@return boolean
function M.ownerMoving()
  if GetDistanceFromOwner(MyID) > 3 and GetV(V_MOTION, MyOwner) == MOTION_MOVE then
    return true
  end
  return false
end

---@return boolean
function M.ownerNotMoving()
  if GetV(V_MOTION, MyOwner) == MOTION_STAND then
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
function M.ownerTookDamage()
  if GetV(V_MOTION, MyOwner) == MOTION_DAMAGE then
    return true
  end
  return false
end

---@return boolean
function M.ownerIsOutOfSight()
  if IsOutOfSight(MyID, MyOwner) then
    return true
  end
  return false
end

---@return boolean
function M.ownerIsSitting()
  if GetV(V_MOTION, MyOwner) ~= MOTION_SIT then
    return false
  end
  return true
end

---@return boolean
function M.ownerIsDying()
  local ownerTakingDamage = GetV(V_MOTION, MyOwner) == MOTION_DAMAGE
  local ownerHp = GetHp(MyOwner)
  local ownerMaxHp = GetMaxHp(MyOwner)
  local ownerDying = ownerHp <= ownerMaxHp * 0.4
  if ownerDying and ownerTakingDamage then
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
function M.isMVP()
  if IsMVP(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isPoisonMonster()
  if IsPoisonMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isWindMonster()
  if IsWindMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isWaterMonster()
  if IsWaterMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isFireMonster()
  if IsFireMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isPlantMonster()
  if IsPlantMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isHolyMonster()
  if IsHolyMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isDarkMonster()
  if IsDarkMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isUndeadMonster()
  if IsUndeadMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.isEarthMonster()
  if IsEarthMonster(MyEnemy) then
    return true
  end
  return false
end

---@return boolean
function M.hasAllSpheres()
  local maxSpheres = 5
  if MySpheres < maxSpheres then
    return false
  end
  return true
end

return M
