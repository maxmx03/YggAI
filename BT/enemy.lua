---@class Enemy
local M = {
  enemies = {},
}

---@return Status
function M.searchForEnemies()
  if #M.enemies == 0 then
    SearchForEnemies(MyID, function(actor)
      table.insert(M.enemies, actor)
    end)
  end
  if #M.enemies == 0 then
    return STATUS.FAILURE
  end
  return STATUS.SUCCESS
end

---@return boolean
local function isEnemyInvalid(id)
  if id == nil then
    return false
  end
  local motion = GetV(V_MOTION, id)
  return motion == MOTION_DEAD or id == 0 or IsOutOfSight(MyID, id)
end

---@return boolean
function M.hasEnemy()
  if not isEnemyInvalid(MyEnemy) then
    return true
  end
  while #M.enemies > 0 do
    local enemy = table.remove(M.enemies, 1)
    if not isEnemyInvalid(enemy) then
      MyEnemy = enemy
      return true
    end
  end
  M.enemies = {}
  MyEnemy = 0
  return false
end

---@return boolean
function M.homunIsStuck()
  local myEnemy = GetV(V_MOTION, MyEnemy)
  local myMotion = GetV(V_MOTION, MyID)
  if
    IsInAttackSight(MyID, MyEnemy)
    or myEnemy == MOTION_DAMAGE
    or myMotion == MOTION_ATTACK
    or MOTION_ATTACK2
    or MOTION_MOVE
  then
    return false
  end
  while #M.enemies > 0 do
    local enemy = table.remove(M.enemies, 1)
    if not isEnemyInvalid(enemy) then
      MyEnemy = enemy
      return true
    end
  end
  MyEnemy = 0
  M.enemies = {}
  return true
end

---@return boolean
function M.hasEnemyGroup()
  local minEnemies = 2
  local maxDistance = 7
  if #M.enemies < minEnemies then
    MySkillX = 0
    MySkillY = 0
    return false
  end
  local groupEnemies = { MyEnemy }
  local myEnemyX, myEnemyY = GetV(V_POSITION, MyEnemy)
  local sumX, sumY = myEnemyX, myEnemyY
  for _, enemy in ipairs(M.enemies) do
    if enemy ~= MyEnemy and not isEnemyInvalid(enemy) then
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
    MySkillX = math.floor(sumX / #groupEnemies)
    MySkillY = math.floor(sumY / #groupEnemies)
    return true
  end
  MySkillX = 0
  MySkillY = 0
  return false
end

return M
