---@class Node
local M = {
  lastTimePatrol = 0,
}

---@return Status
function M.chaseEnemy()
  if not IsInAttackSight(MyID, MyEnemy) then
    local enemyX, enemyY = GetV(V_POSITION, MyEnemy)
    Move(MyID, enemyX, enemyY)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function M.runToSaveOwner()
  if not IsInAttackSight(MyID, MyOwner) then
    local ownerX, ownerY = GetV(V_POSITION, MyOwner)
    Move(MyID, ownerX, ownerY)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

---@return Status
function M.basicAttack()
  if MyEnemy == 0 then
    return STATUS.FAILURE
  elseif MyEnemy ~= 0 then
    Attack(MyID, MyEnemy)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

M.attackAndChase = Parallel({
  M.basicAttack,
  M.chaseEnemy,
})

---@return Status
function M.patrol()
  local cooldown = math.random(3) * 1000
  if (GetTick() - M.lastTimePatrol) > cooldown then
    local destX, destY = GetV(V_POSITION, MyOwner)
    local randomX = math.random(-10, 10)
    local randomY = math.random(-10, 10)
    destX = destX + randomX
    destY = destY + randomY
    if GetDistanceFromOwner(MyID) > 10 then
      M.lastTimePatrol = GetTick()
      MoveToOwner(MyID)
      return STATUS.SUCCESS
    end
    Move(MyID, destX, destY)
    M.lastTimePatrol = GetTick()
    return STATUS.SUCCESS
  end
  return STATUS.RUNNING
end

---@return Status
function M.follow()
  if GetDistanceFromOwner(MyID) > 3 then
    MoveToOwner(MyID)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function M.EleanorBasicAttack()
  if MySpheres < 5 then
    if math.random(100) < 70 then
      MySpheres = MySpheres + 1
    end
  end
  return M.basicAttack()
end

return M
