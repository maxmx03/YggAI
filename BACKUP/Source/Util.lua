---@diagnostic disable: redundant-parameter
require 'AI.USER_AI.Source.Const'

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
  --[[
	if List.size(list) == 0 then
		return
	end
	local first = list.first
	local last  = list.last
	for i=first, last do
		list[i] = nil
	end
--]]
  list.first = 0
  list.last = -1
end

function List.size(list)
  local size = list.last - list.first + 1
  return size
end

-------------------------------------------------

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
  if d > 20 then
    return true
  else
    return false
  end
end

function IsInAttackSight(id1, id2, Humun)
  local x1, y1 = GetV(V_POSITION, id1)
  local x2, y2 = GetV(V_POSITION, id2)
  if x1 == -1 or x2 == -1 then
    return false
  end
  local d = GetDistance(x1, y1, x2, y2)
  local a = 0
  if MySkill == 0 then
    a = GetV(V_ATTACKRANGE, id1)
  else
    a = GetV(V_SKILLATTACKRANGE_LEVEL, id1, Humun.skill, Humun.skillLevel)
  end

  if a >= d then
    return true
  else
    return false
  end
end

function GetHp(id)
  return GetV(V_HP, id)
end

function GetMaxHp(id)
  return GetV(V_MAXHP, id)
end

function GetSp(id)
  return GetV(V_SP, id)
end

function GetMaxSp(id)
  return GetV(V_MAXSP, id)
end

---@param currentTime number
---@param lastTime number
---@param cooldown number
local function CanUseSkill(currentTime, lastTime, cooldown)
  if currentTime - lastTime > cooldown then
    return true
  end
  return false
end

---@param id number
---@param skill table
---@param cooldown number
---@param target number
---@return boolean
function UseSkill(id, skill, cooldown, target)
  local level = 5
  if CanUseSkill(CurrentTime, skill.lastSkillTime, cooldown) then
    SkillObject(id, level, skill.id, target)
    TraceAI('AUTO_CAST -> USE_SKILL: ' .. skill.id)
    return true
  else
    TraceAI('SKILL_IN_COOLDOWN' .. skill.id)
    return false
  end
end

function GetOwnerEnemy(myid)
  local result = 0
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  local target
  for i, v in ipairs(actors) do
    if v ~= owner and v ~= myid then
      target = GetV(V_TARGET, v)
      if target == owner then
        if IsMonster(v) == 1 then
          enemys[index] = v
          index = index + 1
        else
          local motion = GetV(V_MOTION, i)
          if motion == MOTION_ATTACK or motion == MOTION_ATTACK2 then
            enemys[index] = v
            index = index + 1
          end
        end
      end
    end
  end

  local min_dis = 100
  local dis
  for i, v in ipairs(enemys) do
    dis = GetDistance2(myid, v)
    if dis < min_dis then
      result = v
      min_dis = dis
    end
  end

  return result
end

function GetMyEnemy(myid)
  return GetMyEnemyB(myid)
end

-------------------------------------------
--  ANY MOB IS ATTACKING IS MY ENEMY
-------------------------------------------
function GetMyEnemyA(myid)
  local result = 0
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  local target
  for i, v in ipairs(actors) do
    if v ~= owner and v ~= myid then
      target = GetV(V_TARGET, v)
      if target == myid then
        enemys[index] = v
        index = index + 1
      end
    end
  end

  local min_dis = 100
  local dis
  for i, v in ipairs(enemys) do
    dis = GetDistance2(myid, v)
    if dis < min_dis then
      result = v
      min_dis = dis
    end
  end

  return result
end

-------------------------------------------
--  ANY MOBE IS MyEnemy
-------------------------------------------
function GetMyEnemyB(myid)
  local result = 0
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  for _, v in ipairs(actors) do
    local isNotMoving = GetV(V_MOTION, v) == MOTION_SIT or GetV(V_MOTION, v) == MOTION_STAND
    if v ~= owner and v ~= myid then
      if 1 == IsMonster(v) and not isNotMoving then
        enemys[index] = v
        index = index + 1
      end
    end
  end

  local min_dis = 100
  local dis
  for i, v in ipairs(enemys) do
    dis = GetDistance2(myid, v)
    if dis < min_dis then
      result = v
      min_dis = dis
    end
  end

  return result
end
