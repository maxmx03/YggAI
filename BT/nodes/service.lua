---@class ServiceNode
---@field searchForEnemies Node
---@field checkIsAttackingOwner Node
---@field hasEnemy Condition
---@field hasEnemies Condition
---@field isNotInAttackSight Condition
---@field clearDeadEnemies Node
---@field sortEnemiesByDistance Node

---@type ServiceNode
local M = {}

function M.searchForEnemies(bb)
  if #bb.myEnemies >= bb.userConfig.maxEnemiesToSearch then
    return STATUS.SUCCESS
  end
  local currentTick = GetTick()
  for enemyId, expireTime in pairs(bb.ignoredEnemies) do
    if currentTick > expireTime then
      bb.ignoredEnemies[enemyId] = nil
    end
  end
  SearchForEnemies(bb, function(enemyId)
    if
      not Set.contains(bb.myEnemySet, enemyId)
      and IsEnemyAlive(bb.myId, enemyId)
      and not bb.ignoredEnemies[enemyId]
    then
      table.insert(bb.myEnemies, enemyId)
      Set.add(bb.myEnemySet, enemyId)
    end
  end)
  return STATUS.SUCCESS
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
  bb.ownerBeingTarget = false
  if GetV(V_TARGET, bb.myEnemy) == bb.myOwner or IsMonsterType(bb.myEnemy, 'mvp') then
    bb.ownerBeingTarget = true
    return STATUS.SUCCESS
  end
  for pos, enemy in ipairs(bb.myEnemies) do
    if IsEnemyAlive(bb.myId, bb.myEnemy) then
      if GetV(V_TARGET, enemy) == bb.myOwner then
        bb.ownerBeingTarget = true
        bb.myEnemy = table.remove(bb.myEnemies, pos)
        Set.remove(bb.myEnemySet, bb.myEnemy)
        return STATUS.SUCCESS
      end
    end
  end
  return STATUS.SUCCESS
end

return M
