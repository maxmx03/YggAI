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
---@param id number
function IsAmistr(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == AMISTR or humntype == AMISTR_H or humntype == AMISTR2 or humntype == AMISTR_H2
end

---@param id number
function IsFilir(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == FILIR or humntype == FILIR_H or humntype == FILIR2 or humntype == FILIR_H2
end

---@param id number
function IsVanilmirth(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == VANILMIRTH or humntype == VANILMIRTH_H or humntype == VANILMIRTH2 or humntype == VANILMIRTH_H2
end

---@param id number
function IsLif(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == LIF or humntype == LIF_H or humntype == LIF2 or type == LIF_H2
end

---@param id number
function IsEira(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == EIRA
end

---@param id number
function IsBayeri(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == BAYERI
end

---@param id number
function IsSera(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == SERA
end

---@param id number
function IsDieter(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == DIETER
end

---@param id number
function IsElaner(id)
  local humntype = GetV(V_HOMUNTYPE, id)
  return humntype == ELEANOR
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
  if d > 20 then
    return true
  else
    return false
  end
end

function IsInAttackSight(id1, id2)
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
    a = GetV(V_SKILLATTACKRANGE_LEVEL, id1, MySkill, MySkillLevel)
  end

  if a >= d then
    return true
  else
    return false
  end
end

function GetOwnerEnemy(myid)
  local result = 0
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  for i, v in ipairs(actors) do
    if v ~= owner and v ~= myid then
      local owner_target = GetV(V_TARGET, owner)
      local target = GetV(V_TARGET, v)
      if owner_target == v or target == owner then
        if IsMonster(v) == 1 then
          enemys[index] = v
          index = index + 1
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
  local result = GetMyEnemyA(myid)
  if result == 0 then
    result = GetMyEnemyB(myid)
  end
  return result
end

-------------------------------------------
--  GetMyEnemy - Defensive
-------------------------------------------
function GetMyEnemyA(myid)
  local result = 0
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  local target
  for _, v in ipairs(actors) do
    if v ~= owner and v ~= myid then
      target = GetV(V_TARGET, v)
      if target == myid or target == owner then
        enemys[index] = v
        index = index + 1
      end
    end
  end

  local min_dis = 100
  local dis
  for _, v in ipairs(enemys) do
    dis = GetDistance2(myid, v)
    if dis < min_dis then
      result = v
      min_dis = dis
    end
  end

  return result
end

-------------------------------------------
--  GetMyEnemy - Agressive
-------------------------------------------
function GetMyEnemyB(myid)
  local result = 0
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  local type
  for i, v in ipairs(actors) do
    if v ~= owner and v ~= myid then
      if 1 == IsMonster(v) then
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

---@param currentTime number
---@param lastTime number
---@param cooldown number
function CanUseSkill(currentTime, lastTime, cooldown)
  if (currentTime - lastTime) > cooldown then
    return true
  end
  return false
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
