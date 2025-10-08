---@class EnemyNode
---@field maxEnemies number
---@field searchForEnemies Node
---@field checkIsAttackingOwner Node

---@type EnemyNode
local M = {
  maxEnemies = 30,
}

function M.searchForEnemies(bb)
  if #bb.myEnemies < M.maxEnemies then
    SearchForEnemies(bb.myId, M.maxEnemies, function(enemyId)
      if IsEnemyAlive(bb.myId, enemyId) then
        table.insert(bb.myEnemies, enemyId)
      end
    end)
  end
  if #bb.myEnemies == 0 then
    return STATUS.RUNNING
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
        return STATUS.SUCCESS
      end
    end
  end
  return STATUS.SUCCESS
end

return M
