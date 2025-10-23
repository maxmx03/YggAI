require 'AI.USER_AI.UTIL.Const'

--------------------------------------------
-- List utility
--------------------------------------------
List = {}

function List.new()
  return { first = 0, last = -1 }
end

function List.pushleft(list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end

function List.pushright(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function List.popleft(list)
  local first = list.first
  if first > list.last then
    return nil
  end
  local value = list[first]
  list[first] = nil -- to allow garbage collection
  list.first = first + 1
  return value
end

function List.popright(list)
  local last = list.last
  if list.first > last then
    return nil
  end
  local value = list[last]
  list[last] = nil
  list.last = last - 1
  return value
end

function List.clear(list)
  for i, v in ipairs(list) do
    list[i] = nil
  end
  list.first = 0
  list.last = -1
end

function List.size(list)
  local size = list.last - list.first + 1
  return size
end

--------------------------------------------
-- Set utility
--------------------------------------------
Set = {}

function Set.new()
  return {}
end

function Set.add(set, value)
  set[value] = true
end

function Set.remove(set, value)
  set[value] = nil
end

function Set.contains(set, value)
  return set[value] == true
end

function Set.clear(set)
  for k in pairs(set) do
    set[k] = nil
  end
end

function Set.size(set)
  local count = 0
  for _ in pairs(set) do
    count = count + 1
  end
  return count
end

function Set.toList(set)
  local list = {}
  for k in pairs(set) do
    table.insert(list, k)
  end
  return list
end

function Set.fromList(list)
  local set = Set.new()
  for _, v in ipairs(list) do
    Set.add(set, v)
  end
  return set
end

function Set.isEmpty(set)
  return next(set) == nil
end

function GetDistance(x1, y1, x2, y2)
  return math.floor(math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))
end

function GetDistance2(id1, id2)
  local x1, y1 = GetV(V_POSITION, id1)
  local x2, y2 = GetV(V_POSITION, id2)
  if x1 == -1 or x2 == -1 then
    return -1
  end
  return GetDistance(x1, y1, x2, y2)
end

function GetOwnerPosition(id)
  return GetV(V_POSITION, GetV(V_OWNER, id))
end

function GetDistanceFromOwner(id)
  local x1, y1 = GetOwnerPosition(id)
  local x2, y2 = GetV(V_POSITION, id)
  if x1 == -1 or x2 == -1 then
    return -1
  end
  return GetDistance(x1, y1, x2, y2)
end

function IsOutOfSight(id1, id2)
  local x1, y1 = GetV(V_POSITION, id1)
  local x2, y2 = GetV(V_POSITION, id2)
  if x1 == -1 or x2 == -1 then
    return true
  end
  local d = GetDistance(x1, y1, x2, y2)
  if d > 16 then -- default is 20
    return true
  else
    return false
  end
end

---@param id1 number
---@param id2 number
---@param bb Blackboard
---@return boolean
function IsInAttackSight(id1, id2, bb)
  local x1, y1 = GetV(V_POSITION, id1)
  local x2, y2 = GetV(V_POSITION, id2)
  if x1 == -1 or x2 == -1 then
    return false
  end
  local d = GetDistance(x1, y1, x2, y2)
  local a = 0
  if bb.mySkill.id == 0 then
    a = GetV(V_ATTACKRANGE, id1)
  else
    ---@diagnostic disable-next-line: redundant-parameter
    a = GetV(V_SKILLATTACKRANGE_LEVEL, id1, bb.mySkill.id, bb.mySkill.level)
  end

  if a >= d then
    return true
  else
    return false
  end
end

---@param myEnemy number
---@param monsterType string
---@return boolean
function IsMonsterType(myEnemy, monsterType)
  local monsters = require('AI.USER_AI.MONSTER_DATA.' .. monsterType)
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return monsters[id]
end

---@param myEnemy number
---@param bb Blackboard
---@return boolean
function MustAvoidMonster(myEnemy, bb)
  ---@type UserConfig
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return bb.userConfig.avoid[id]
end

---@param bb Blackboard
---@param callback function
function SearchForEnemies(bb, callback)
  local maxEnemiesToFind = math.max(0, bb.userConfig.maxEnemiesToSearch - #bb.myEnemies)
  if maxEnemiesToFind <= 0 then
    callback(0)
    return
  end
  local owner = bb.myOwner
  local myid = bb.myId
  local priority = {}
  local others = {}
  local actors = GetActors()

  for _, actorId in ipairs(actors) do
    if #priority + #others >= maxEnemiesToFind then
      break
    end
    if actorId ~= owner and actorId ~= myid and not IsOutOfSight(myid, actorId) then
      local actorTarget = GetV(V_TARGET, actorId)
      local actorMotion = GetV(V_MOTION, actorId)
      local ownerTarget = GetV(V_TARGET, owner)
      local ownerMotion = GetV(V_MOTION, owner)
      local myMotion = GetV(V_MOTION, myid)
      if IsPlayer(actorId) == 1 then
        if actorTarget == myid and myMotion == MOTION_DAMAGE then
          table.insert(priority, actorId)
        elseif actorTarget == owner and ownerMotion == MOTION_DAMAGE then
          table.insert(priority, actorId)
        elseif ownerTarget == actorId and actorMotion == MOTION_DAMAGE then
          table.insert(priority, actorId)
        end
      elseif IsMonster(actorId) == 1 then
        if IsMonsterType(actorId, 'mvp') then
          table.insert(priority, actorId)
        elseif ownerTarget == actorId then
          table.insert(priority, actorId)
        elseif actorTarget == owner or actorTarget == myid then
          if not MustAvoidMonster(actorId, bb) then
            table.insert(priority, actorId)
          end
        else
          if not Set.isEmpty(bb.userConfig.myEnemies) then
            local id = GetV(V_HOMUNTYPE, actorId)
            if bb.userConfig.myEnemies[id] then
              table.insert(others, actorId)
            end
          else
            if not MustAvoidMonster(actorId, bb) then
              table.insert(others, actorId)
            end
          end
        end
      end
    end
  end
  for _, actorId in ipairs(priority) do
    callback(actorId)
  end
  table.sort(others, function(a, b)
    return GetDistanceFromOwner(a) < GetDistanceFromOwner(b)
  end)
  for _, actorId in ipairs(others) do
    callback(actorId)
  end
end

---@param message string
---@param ... any
function Trace(message, ...)
  message = ' ' .. message
  TraceAI(string.format(message, ...))
end

---@param myid number
---@param enemyId number
---@return boolean
function IsEnemyAlive(myid, enemyId)
  if enemyId == 0 or enemyId == nil or enemyId == -1 then
    return false
  end
  local motion = GetV(V_MOTION, enemyId)
  return motion ~= MOTION_DEAD and not IsOutOfSight(myid, enemyId)
end

---@param percentage number
---@return boolean
function ChanceDoOrGainSomething(percentage)
  math.randomseed(GetTick())
  if math.random(100) <= percentage then
    return true
  end
  return false
end

---@param id number
---@return 0 | 1
function IsPlayer(id)
  local magicNumber = 100000
  if id > magicNumber then
    return 1
  end
  return 0
end
