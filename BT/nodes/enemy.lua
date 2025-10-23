---@class EnemyNode
---@field hasEnemy Condition
---@field hasEnemyGroup fun(minEnemies: number, maxDistance: number): Condition
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

---@type EnemyNode
local M = {}

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

---@return Condition
function M.hasEnemyGroup(minEnemies, maxDistance)
  return function(bb)
    minEnemies = minEnemies or 2
    maxDistance = maxDistance or 5
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
