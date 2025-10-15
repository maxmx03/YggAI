---@class HomunNode
---@field chaseEnemy Node
---@field runToSaveOwner Node
---@field basicAttack Node
---@field patrol Node
---@field attackAndChase Node
---@field follow Node
---@field checkHomunStuck Node
---@field lastTimePatrol number
---@field isAmistr Condition
---@field isFilir Condition
---@field isVanilmirth Condition
---@field isLif Condition
---@field isEira Condition
---@field isBayeri Condition
---@field isSera Condition
---@field isDieter Condition
---@field isEleanor Condition

---@type HomunNode
local M = {
  lastTimePatrol = 0,
  stuckCounter = 0,
}

function M.chaseEnemy(bb)
  if not IsInAttackSight(bb.myId, bb.myEnemy, bb) then
    local enemyX, enemyY = GetV(V_POSITION, bb.myEnemy)
    Move(bb.myId, enemyX, enemyY)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function M.runToSaveOwner(bb)
  if not IsInAttackSight(bb.myId, bb.myOwner, bb) then
    local ownerX, ownerY = GetV(V_POSITION, bb.myOwner)
    Move(bb.myId, ownerX, ownerY)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function M.basicAttack(bb)
  if bb.myEnemy == 0 then
    return STATUS.FAILURE
  elseif bb.myEnemy ~= 0 then
    Attack(bb.myId, bb.myEnemy)
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end

M.attackAndChase = Parallel {
  M.basicAttack,
  M.chaseEnemy,
}

function M.patrol(bb)
  local currentTick = GetTick()
  math.randomseed(currentTick)
  local cooldown = math.random(10) * 1000
  if (currentTick - M.lastTimePatrol) > cooldown then
    local destX, destY = GetV(V_POSITION, bb.myOwner)
    local randomX = math.random(-7, 7)
    local randomY = math.random(-7, 7)
    destX = destX + randomX
    destY = destY + randomY
    M.lastTimePatrol = currentTick
    if GetDistanceFromOwner(bb.myOwner) > 10 then
      MoveToOwner(bb.myId)
      return STATUS.SUCCESS
    end
    Move(bb.myId, destX, destY)
    return STATUS.SUCCESS
  end
  return STATUS.RUNNING
end

function M.follow(bb)
  if GetDistanceFromOwner(bb.myId) > 3 then
    MoveToOwner(bb.myId)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function M.checkHomunStuck(bb)
  local enemyTarget = GetV(V_TARGET, bb.myEnemy)
  local enemyMotion = GetV(V_MOTION, bb.myEnemy)
  local myMotion = GetV(V_MOTION, bb.myId)
  if
    IsInAttackSight(bb.myId, bb.myEnemy, bb)
    or enemyTarget == bb.myOwner
    or enemyTarget == bb.myId
    or (enemyMotion ~= MOTION_STAND and enemyMotion ~= MOTION_MOVE)
    or (myMotion ~= MOTION_STAND and myMotion ~= MOTION_DAMAGE)
  then
    M.stuckCounter = 0
    return STATUS.SUCCESS
  end
  if M.stuckCounter >= 3 then
    bb.ignoredEnemies[bb.myEnemy] = GetTick() + 1000
    M.stuckCounter = 0
    while #bb.myEnemies > 0 do
      local enemy = table.remove(bb.myEnemies, 1)
      Set.remove(bb.myEnemySet, enemy)
      if IsEnemyAlive(bb.myId, enemy) then
        bb.myEnemy = enemy
        return STATUS.SUCCESS
      end
    end
    return STATUS.FAILURE
  end
  M.stuckCounter = M.stuckCounter + 1
  return STATUS.RUNNING
end

function M.isAmistr(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == AMISTR or humntype == AMISTR_H or humntype == AMISTR2 or humntype == AMISTR_H2
end

function M.isFilir(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == FILIR or humntype == FILIR_H or humntype == FILIR2 or humntype == FILIR_H2
end

function M.isVanilmirth(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == VANILMIRTH or humntype == VANILMIRTH_H or humntype == VANILMIRTH2 or humntype == VANILMIRTH_H2
end

function M.isLif(bb)
  local h = GetV(V_HOMUNTYPE, bb.myId)
  return h == LIF or h == LIF2 or h == LIF_H or h == LIF_H2
end

function M.isEira(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == EIRA
end

function M.isBayeri(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == BAYERI
end

function M.isSera(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == SERA
end

function M.isDieter(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == DIETER
end

function M.isEleanor(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == ELEANOR
end

return M
