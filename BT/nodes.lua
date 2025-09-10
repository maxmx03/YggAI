---@return Status
function CheckIfHasEnemy()
  MyEnemy = GetMyEnemy(MyID)
  if MyEnemy ~= 0 then
    return STATUS.SUCCESS
  end
  MyEnemy = 0
  return STATUS.FAILURE
end

---@return Status
function CheckEnemyIsOutOfSight()
  if IsOutOfSight(MyID, MyEnemy) then
    MyEnemy = 0
    return STATUS.FAILURE
  end
  return STATUS.SUCCESS
end

---@return Status
function CheckEnemyIsDead()
  if GetV(V_MOTION, MyEnemy) == MOTION_DEAD then
    MyEnemy = 0
    return STATUS.SUCCESS
  elseif GetV(V_MOTION, MyEnemy) ~= MOTION_DEAD then
    return STATUS.RUNNING
  end
  MyEnemy = 0
  return STATUS.FAILURE
end

---@return Status
function CheckOwnerDistance()
  if GetDistanceFromOwner(MyID) > 3 then
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end

---@return Status
function CheckOwnerToofar()
  if GetDistanceFromOwner(MyID) >= 10 then
    return STATUS.FAILURE
  end
  return STATUS.SUCCESS
end

---@return Status
function CheckOwnerIsSitting()
  if GetV(V_MOTION, MyOwner) ~= MOTION_SIT then
    return STATUS.FAILURE
  end
  return STATUS.SUCCESS
end

---@return Status
function CheckOwnerOutOfSight()
  if IsOutOfSight(MyID, MyOwner) then
    return STATUS.FAILURE
  end
  return STATUS.SUCCESS
end

---@return Status
function ChaseEnemyNode()
  if MyEnemy == 0 then
    TraceAI('ChaseEnemyNode -> FAILURE')
    return STATUS.FAILURE
  end
  if not IsInAttackSight(MyID, MyEnemy) then
    local enemyX, enemyY = GetV(V_POSITION, MyEnemy)
    Move(MyID, enemyX, enemyY)
    TraceAI('ChaseEnemyNode -> RUNNING')
    return STATUS.RUNNING
  elseif IsInAttackSight(MyID, MyEnemy) then
    TraceAI('ChaseEnemyNode -> SUCCESS')
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end

---@return Status
function BasicAttackNode()
  if MyEnemy == 0 then
    return STATUS.FAILURE
  elseif MyEnemy ~= 0 then
    TraceAI('BasicAttackNode -> Attack')
    Attack(MyID, MyEnemy)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function PatrolNode()
  local cooldown = math.random(10) -- x seconds
  if (CurrentTime - LastTimePatrol) > cooldown then
    local destX, destY = GetV(V_POSITION, MyOwner)
    local randomX = math.random(-10, 10)
    local randomY = math.random(-10, 10)
    destX = destX + randomX
    destY = destY + randomY
    Move(MyID, destX, destY)
    LastTimePatrol = CurrentTime
    return STATUS.SUCCESS
  end
  return STATUS.RUNNING
end

function FollowNode()
  MoveToOwner(MyID)
  local motion = GetV(V_MOTION, MyOwner)
  if motion == MOTION_MOVE then
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

---@param sp number
---@param lastTime number
---@param cooldown number
function CheckCanCastSkill(sp, lastTime, cooldown)
  if not HasEnoughSp(sp) then
    MySkill = 0
    return STATUS.FAILURE
  end
  if not CanUseSkill(CurrentTime, lastTime, cooldown) then
    MySkill = 0
    return STATUS.FAILURE
  end
  return STATUS.SUCCESS
end

---@return Status
function CheckOwnerIsDying()
  local ownerHp = GetHp(MyOwner)
  local ownerMaxHp = GetMaxHp(MyOwner)
  local ownerDying = ownerHp <= ownerMaxHp * 0.3
  if ownerDying then
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end
