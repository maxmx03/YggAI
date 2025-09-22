---@class Condition
local M = {}

local EnemyList = List.new()
local lastEnemySearchTime = 0
local ENEMY_SEARCH_INTERVAL = 0.3
local MAX_ENEMIES_IN_LIST = 8

local function cleanEnemyList()
  local cleanList = List.new()
  local removed = 0

  for i = EnemyList.first, EnemyList.last do
    local enemyId = EnemyList[i]
    if enemyId and enemyId ~= 0 and enemyId ~= -1 then
      if not IsOutOfSight(MyID, enemyId) then
        local motion = GetV(V_MOTION, enemyId)
        if motion ~= MOTION_DEAD then
          List.pushright(cleanList, enemyId)
        else
          removed = removed + 1
          TraceAI('Removido inimigo morto: ' .. enemyId)
        end
      else
        removed = removed + 1
        TraceAI('Removido inimigo fora de vista: ' .. enemyId)
      end
    else
      removed = removed + 1
      TraceAI('Removido ID inválido: ' .. tostring(enemyId))
    end
  end

  if removed > 0 then
    TraceAI('Removidos ' .. removed .. ' inimigos da lista')
  end
  EnemyList = cleanList
end

local function addEnemyToList(enemyId)
  if enemyId == 0 or enemyId == -1 or not enemyId then
    TraceAI('ID inválido rejeitado: ' .. tostring(enemyId))
    return false
  end

  if IsOutOfSight(MyID, enemyId) then
    TraceAI('Inimigo fora de vista rejeitado: ' .. enemyId)
    return false
  end

  local motion = GetV(V_MOTION, enemyId)
  if motion == MOTION_DEAD then
    TraceAI('Inimigo morto rejeitado: ' .. enemyId)
    return false
  end

  for i = EnemyList.first, EnemyList.last do
    if EnemyList[i] == enemyId then
      return false
    end
  end

  if List.size(EnemyList) < MAX_ENEMIES_IN_LIST then
    List.pushright(EnemyList, enemyId)
    TraceAI('Adicionado inimigo ' .. enemyId .. ' à lista. Total: ' .. List.size(EnemyList))
    return true
  end
  return false
end

local AttackTimeout = 0
local AttackTimeLimit = 3000
local lastEnemyPosition = { x = 0, y = 0 }
local pathfindingAttempts = 0

local function checkPathfinding()
  if MyEnemy == 0 then
    return true
  end

  local currentTime = GetTick()
  local enemyX, enemyY = GetV(V_POSITION, MyEnemy)
  local myMotion = GetV(V_MOTION, MyID)

  if myMotion == MOTION_MOVE then
    AttackTimeout = currentTime + AttackTimeLimit
    pathfindingAttempts = 0
    return true
  end

  if enemyX ~= lastEnemyPosition.x or enemyY ~= lastEnemyPosition.y then
    lastEnemyPosition.x = enemyX
    lastEnemyPosition.y = enemyY
    AttackTimeout = currentTime + AttackTimeLimit
    pathfindingAttempts = 0
    return true
  end

  local inAttackRange = IsInAttackSight(MyID, MyEnemy)

  if inAttackRange then
    AttackTimeout = currentTime + AttackTimeLimit
    pathfindingAttempts = 0
    return true
  end

  if currentTime > AttackTimeout then
    pathfindingAttempts = pathfindingAttempts + 1
    TraceAI('Timeout tentando alcançar inimigo: ' .. MyEnemy .. ' (tentativa: ' .. pathfindingAttempts .. ')')

    if pathfindingAttempts >= 2 then
      TraceAI('Abandonando alvo inacessível: ' .. MyEnemy)
      MyEnemy = 0
      pathfindingAttempts = 0
      return false
    end

    AttackTimeout = currentTime + AttackTimeLimit
  end

  return true
end

function M.hasEnemy()
  if not checkPathfinding() then
    return false
  end

  if MyEnemy ~= 0 and MyEnemy ~= -1 and MyEnemy then
    if not IsOutOfSight(MyID, MyEnemy) then
      local motion = GetV(V_MOTION, MyEnemy)
      if motion ~= MOTION_DEAD then
        TraceAI('Mantendo inimigo atual: ' .. MyEnemy)
        return true
      else
        TraceAI('Inimigo atual morreu: ' .. MyEnemy)
      end
    else
      TraceAI('Inimigo atual saiu de vista: ' .. MyEnemy)
    end
  end

  cleanEnemyList()

  while List.size(EnemyList) > 0 do
    local nextEnemy = List.popleft(EnemyList)
    if nextEnemy and nextEnemy ~= 0 and nextEnemy ~= -1 then
      if not IsOutOfSight(MyID, nextEnemy) then
        local motion = GetV(V_MOTION, nextEnemy)
        if motion ~= MOTION_DEAD then
          MyEnemy = nextEnemy
          TraceAI('Novo inimigo da lista: ' .. MyEnemy)
          return true
        else
          TraceAI('Inimigo da lista morreu: ' .. nextEnemy)
        end
      else
        TraceAI('Inimigo da lista fora de vista: ' .. nextEnemy)
      end
    end
  end

  MyEnemy = 0
  TraceAI('Nenhum inimigo válido encontrado')
  return false
end

---@return boolean
function M.scanForEnemies()
  local currentTime = GetTick() / 1000

  if currentTime - lastEnemySearchTime < ENEMY_SEARCH_INTERVAL then
    return List.size(EnemyList) > 0
  end

  lastEnemySearchTime = currentTime
  cleanEnemyList()

  if List.size(EnemyList) >= MAX_ENEMIES_IN_LIST then
    return true
  end

  local foundCount = 0

  local function enemyCallback(enemyId)
    if List.size(EnemyList) >= MAX_ENEMIES_IN_LIST then
      return
    end
    if addEnemyToList(enemyId) then
      foundCount = foundCount + 1
    end
  end

  TraceAI('Iniciando scan de inimigos...')

  GetMyEnemyC(MyID, enemyCallback)
  TraceAI('MVPs encontrados: ' .. foundCount)

  local defensiveCount = foundCount
  GetMyEnemyA(MyID, enemyCallback)
  TraceAI('Inimigos defensivos: ' .. (foundCount - defensiveCount))

  local ownerCount = foundCount
  GetOwnerEnemy(MyID, enemyCallback)
  TraceAI('Inimigos do owner: ' .. (foundCount - ownerCount))

  local aggressiveCount = foundCount
  GetMyEnemyB(MyID, enemyCallback)
  TraceAI('Inimigos agressivos: ' .. (foundCount - aggressiveCount))

  TraceAI('Total encontrados: ' .. foundCount .. ' - Lista final: ' .. List.size(EnemyList))

  return List.size(EnemyList) > 0
end

---@return boolean
function M.hasEnemyOrInList()
  if M.hasEnemy() then
    return true
  end
  M.scanForEnemies()
  return M.hasEnemy()
end

-- function M.clearEnemySystem()
--   List.clear(EnemyList)
--   MyEnemy = 0
--   TraceAI('Sistema de inimigos limpo')
-- end

---@return boolean
function M.enemyIsNotOutOfSight()
  if IsOutOfSight(MyID, MyEnemy) then
    TraceAI('Inimigo saiu de vista: ' .. MyEnemy)
    MyEnemy = 0
    return false
  end
  return true
end

---@return boolean
function M.enemyIsAlive()
  if GetV(V_MOTION, MyEnemy) == MOTION_DEAD then
    TraceAI('Inimigo morreu: ' .. MyEnemy)
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
  if GetDistanceFromOwner(MyID) > 2 and GetV(V_MOTION, MyOwner) == MOTION_MOVE then
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

function M.isFireMonster()
  if IsFireMonster(MyEnemy) then
    return true
  end
  return false
end

function M.isPlantMonster()
  if IsPlantMonster(MyEnemy) then
    return true
  end
  return false
end

function M.isHolyMonster()
  if IsHolyMonster(MyEnemy) then
    return true
  end
  return false
end

function M.isDarkMonster()
  if IsDarkMonster(MyEnemy) then
    return true
  end
  return false
end

function M.isUndeadMonster()
  if IsUndeadMonster(MyEnemy) then
    return true
  end
  return false
end

---@param skill Skill
---@param lastTime number
---@return boolean
function M.isSkillCastable(skill, lastTime)
  if not HasEnoughSp(skill.sp) then
    MySkill = 0
    return false
  end
  if not CanUseSkill(GetTickInSeconds(), lastTime, skill.cooldown(lastTime)) then
    MySkill = 0
    return false
  end
  return true
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
