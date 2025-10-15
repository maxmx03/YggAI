---@class EnemyNode
---@field maxEnemies number
---@field searchForEnemies Node
---@field checkIsAttackingOwner Node
---@field hasEnemy Condition
---@field hasEnemies Condition
---@field hasEnemyGroup Condition
---@field isAlive Condition
---@field isNotInAttackSight Condition
---@field isMVP Condition
---@field isPoisonType Condition
---@field isWindType Condition
---@field isWaterType Condition
---@field isFireType Condition
---@field isPlantType Condition
---@field isHolyType Condition
---@field isEarthType Condition
---@field isGhostType Condition
---@field clearDeadEnemies Node
---@field sortEnemiesByDistance Node

---@type EnemyNode
local M = {
  maxEnemies = MaxEnemies or 8,
}

function M.searchForEnemies(bb)
  if #bb.myEnemies >= M.maxEnemies then
    return STATUS.SUCCESS
  end

  local currentTick = GetTick()
  for enemyId, expireTime in pairs(bb.ignoredEnemies) do
    if currentTick > expireTime then
      bb.ignoredEnemies[enemyId] = nil
    end
  end

  SearchForEnemies(bb.myId, M.maxEnemies - #bb.myEnemies, function(enemyId)
    if
      not Set.contains(bb.myEnemySet, enemyId)
      and IsEnemyAlive(bb.myId, enemyId)
      and not bb.ignoredEnemies[enemyId]
    then
      table.insert(bb.myEnemies, enemyId)
      Set.add(bb.myEnemySet, enemyId)
    end
  end)
  if #bb.myEnemies > 0 then
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end

function M.clearDeadEnemies(bb)
  for i = #bb.myEnemies, 1, -1 do
    local enemyId = bb.myEnemies[i]
    if not IsEnemyAlive(bb.myId, enemyId) then
      table.remove(bb.myEnemies, i)
      Set.remove(bb.myEnemySet, enemyId)
    end
  end
  return STATUS.SUCCESS
end

function M.sortEnemiesByDistance(bb)
  if #bb.myEnemies > 1 then
    table.sort(bb.myEnemies, function(a, b)
      return GetDistance2(bb.myId, a) < GetDistance2(bb.myId, b)
    end)
  end
  return STATUS.SUCCESS
end

function M.checkIsAttackingOwner(bb)
  if GetV(V_TARGET, bb.myEnemy) == bb.myOwner or IsMonsterType(bb.myEnemy, 'mvp') then
    return STATUS.SUCCESS
  end
  for pos, enemy in ipairs(bb.myEnemies) do
    if IsEnemyAlive(bb.myId, bb.myEnemy) then
      if GetV(V_TARGET, enemy) == bb.myOwner then
        bb.myEnemy = table.remove(bb.myEnemies, pos)
        Set.remove(bb.myEnemySet, bb.myEnemy)
        return STATUS.SUCCESS
      end
    end
  end
  return STATUS.SUCCESS
end

function M.hasEnemy(bb)
  if IsEnemyAlive(bb.myId, bb.myEnemy) then
    return true
  end
  while #bb.myEnemies > 0 do
    local enemy = table.remove(bb.myEnemies, 1)
    Set.remove(bb.myEnemySet, enemy)
    if IsEnemyAlive(bb.myId, enemy) then
      bb.myEnemy = enemy
      return true
    end
  end
  bb.myEnemy = 0
  return false
end

function M.hasEnemyGroup(bb)
  local minEnemies = 2
  local maxDistance = 7
  local resetedCoordinates = { x = 0, y = 0 }
  if #bb.myEnemies < minEnemies then
    bb.mySkill.coordinates = resetedCoordinates
    return false
  end
  local groupEnemies = { bb.myEnemy }
  local myEnemyX, myEnemyY = GetV(V_POSITION, bb.myEnemy)
  local sumX, sumY = myEnemyX, myEnemyY
  for _, enemy in ipairs(bb.myEnemies) do
    if enemy ~= bb.myEnemy and IsEnemyAlive(bb.myId, bb.myEnemy) then
      local enemyX, enemyY = GetV(V_POSITION, enemy)
      if enemyX ~= -1 then
        local distance = GetDistance(myEnemyX, myEnemyY, enemyX, enemyY)
        if distance <= maxDistance then
          table.insert(groupEnemies, enemy)
          sumX = sumX + enemyX
          sumY = sumY + enemyY
        end
      end
    end
  end
  if #groupEnemies >= minEnemies then
    bb.mySkill.coordinates.x = math.floor(sumX / #groupEnemies)
    bb.mySkill.coordinates.y = math.floor(sumY / #groupEnemies)
    return true
  end
  bb.mySkill.coordinates = resetedCoordinates
  return false
end

function M.isAlive(bb)
  if bb.myEnemy == 0 then
    return false
  end
  if GetV(V_MOTION, bb.myEnemy) == MOTION_DEAD then
    bb.myEnemy = 0
    return false
  end
  return true
end

function M.isNotInAttackSight(bb)
  if IsInAttackSight(bb.myId, bb.myEnemy, bb) then
    return false
  end
  return true
end

function M.isMVP(bb)
  return IsMonsterType(bb.myEnemy, 'mvp')
end

function M.isPoisonType(bb)
  return IsMonsterType(bb.myEnemy, 'poison')
end

function M.isWindType(bb)
  return IsMonsterType(bb.myEnemy, 'wind')
end

function M.isWaterType(bb)
  return IsMonsterType(bb.myEnemy, 'water')
end

function M.isFireType(bb)
  return IsMonsterType(bb.myEnemy, 'fire')
end

function M.isPlantType(bb)
  return IsMonsterType(bb.myEnemy, 'plant')
end

function M.isHolyType(bb)
  return IsMonsterType(bb.myEnemy, 'holy')
end

function M.isEarthType(bb)
  return IsMonsterType(bb.myEnemy, 'earth')
end

function M.isGhostType(bb)
  return IsMonsterType(bb.myEnemy, 'ghost')
end

return M
