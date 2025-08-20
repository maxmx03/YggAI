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

---Every monster in the screen is an enemy, passive or agressive.
---@param myid number
---@return number
function GetEnemy(myid)
  local result = 0
  local owner_id = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  for i, actor in ipairs(actors) do
    if actor ~= owner_id and actor ~= myid then
      local target = GetV(V_TARGET, actor)
      if target == myid or target == owner_id then
        if IsMonster(actor) == 1 then
          enemys[index] = actor
          index = index + 1
        else
          local motion = GetV(V_MOTION, i)
          if motion == MOTION_ATTACK or motion == MOTION_ATTACK2 then
            enemys[index] = actor
            index = index + 1
          end
        end
      end
    end
  end
  local min_distance = 100
  for _, enemy in ipairs(enemys) do
    local enemy_distance = GetDistance2(myid, enemy)
    if enemy_distance < min_distance then
      result = enemy
      min_distance = enemy_distance
    end
  end
  return result
end
