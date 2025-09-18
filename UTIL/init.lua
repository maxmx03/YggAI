require('AI.USER_AI.UTIL.Const')

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

-------------------------------------------------
---@return boolean
function IsAmistr()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == AMISTR or humntype == AMISTR_H or humntype == AMISTR2 or humntype == AMISTR_H2
end

---@return boolean
function IsFilir()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == FILIR or humntype == FILIR_H or humntype == FILIR2 or humntype == FILIR_H2
end

---@return boolean
function IsVanilmirth()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == VANILMIRTH or humntype == VANILMIRTH_H or humntype == VANILMIRTH2 or humntype == VANILMIRTH_H2
end

---@return boolean
function IsLif()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == LIF or humntype == LIF_H or humntype == LIF2 or type == LIF_H2
end

---@return boolean
function IsEira()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == EIRA
end

---@return boolean
function IsBayeri()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == BAYERI
end

---@return boolean
function IsSera()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == SERA
end

---@return boolean
function IsDieter()
  local humntype = GetV(V_HOMUNTYPE, MyID)
  return humntype == DIETER
end

---@return boolean
function IsEleanor()
  local humntype = GetV(V_HOMUNTYPE, MyID)
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

---@param myEnemy number
---@return boolean
function IsWaterMonster(myEnemy)
  local waterMonsters = require('AI.USER_AI.MONSTER_DATA.water')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return waterMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsWindMonster(myEnemy)
  local windMonsters = require('AI.USER_AI.MONSTER_DATA.wind')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return windMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsMVP(myEnemy)
  local mvpMonsters = require('AI.USER_AI.MONSTER_DATA.mvp')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return mvpMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsBoss(myEnemy)
  local bosses = require('AI.USER_AI.MONSTER_DATA.boss')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return bosses[id]
end

---@param myEnemy number
---@return boolean
function IsPoisonMonster(myEnemy)
  local poisonMonsters = require('AI.USER_AI.MONSTER_DATA.poison')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return poisonMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsIllusionalMonster(myEnemy)
  local illusionalMonsters = require('AI.USER_AI.MONSTER_DATA.illusion')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return illusionalMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsInstanceMonster(myEnemy)
  local instanceMonsters = require('AI.USER_AI.MONSTER_DATA.instance')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return instanceMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsBioLabMonsters(myEnemy)
  local biolabMonsters = require('AI.USER_AI.MONSTER_DATA.bio')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return biolabMonsters[id]
end

---@param myEnemy number
---@return boolean
function MustAvoidMonster(myEnemy)
  local monstersToAvoid = require('AI.USER_AI.MONSTER_DATA.avoid')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return monstersToAvoid[id]
end

---@return boolean
function OwnerInDanger()
  local ownerHp = GetHp(MyOwner)
  local ownerMaxHp = GetMaxHp(MyOwner)
  local ownerDying = ownerHp <= ownerMaxHp * 0.3
  if ownerDying then
    return true
  end
  return false
end

---@param myEnemy number
---@return boolean
function IsEnemyAllowed(myEnemy)
  if MustAvoidMonster(myEnemy) then
    return false
  end
  if not ShouldPreventHomunculusDuplication then
    return true
  end
  return IsIllusionalMonster(myEnemy) or IsBioLabMonsters(myEnemy) or IsInstanceMonster(myEnemy) or OwnerInDanger()
end

---@param myId number
---@return number
function GetMyEnemy(myId)
  local result = GetMyEnemyC(myId) -- MVP
  if result == 0 or result == -1 then
    result = GetMyEnemyA(myId) -- Defensive
    if result == 0 or result == -1 then
      result = GetOwnerEnemy(myId)
    end
    if result == 0 or result == -1 then
      result = GetMyEnemyB(myId) -- Aggressive
    end
  end
  return result
end

---@param myId number
---@return number
function GetOwnerEnemy(myId)
  local result = 0
  local owner = GetV(V_OWNER, myId)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  for _, v in ipairs(actors) do
    if v ~= owner and v ~= myId then
      local owner_target = GetV(V_TARGET, owner)
      if owner_target == v then
        enemys[index] = v
        index = index + 1
      end
    end
  end

  local min_dis = 100
  local dis
  for _, v in ipairs(enemys) do
    dis = GetDistance2(myId, v)
    if dis < min_dis then
      result = v
      min_dis = dis
    end
  end

  return result
end

-------------------------------------------
--  GetMyEnemy - Defensive
-------------------------------------------
---@param myId number
---@return number
function GetMyEnemyA(myId)
  local result = 0
  local owner = GetV(V_OWNER, myId)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  for _, v in ipairs(actors) do
    if v ~= owner and v ~= myId then
      local target = GetV(V_TARGET, v)
      if (target == myId or target == owner) and IsMonster(v) == 1 and IsEnemyAllowed(v) then
        enemys[index] = v
        index = index + 1
      elseif (target == myId or target == owner) and IsMonster(v) ~= 1 then -- pvp
        enemys[index] = v
        index = index + 1
      end
    end
  end

  local min_dis = 100
  local dis
  for _, v in ipairs(enemys) do
    dis = GetDistance2(myId, v)
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
  for _, v in ipairs(actors) do
    if v ~= owner and v ~= myid then
      if 1 == IsMonster(v) and IsEnemyAllowed(v) then
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
--  GetMyEnemy - MVP/BOSS
-------------------------------------------
function GetMyEnemyC(myid)
  local result = 0
  local owner = GetV(V_OWNER, myid)
  local actors = GetActors()
  local enemys = {}
  local index = 1
  for _, v in ipairs(actors) do
    if v ~= owner and v ~= myid then
      if 1 == IsMonster(v) and IsMVP(v) then
        enemys[index] = v
        index = index + 1
      elseif 1 == IsMonster(v) and IsBoss(v) then
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
function CanUseSkill(currentTime, lastTime, cooldown)
  if not currentTime or not lastTime or not cooldown then
    return false
  end
  if (currentTime - lastTime) >= cooldown then
    return true
  end
  return false
end

---@class sk
---@field lastTime number
---@field cooldown number
---@field currentTime number
---@field level number
---@field id number

---@param myid number
---@param target number
---@param sk sk
---@return boolean
function CastSkill(myid, target, sk)
  if CanUseSkill(sk.currentTime, sk.lastTime, sk.cooldown) then
    SkillObject(myid, sk.level, sk.id, target)
    return true
  else
    return false
  end
end

---@class Position
---@field x number
---@field y number

---@param myid number
---@param position Position
---@param sk sk
---@return boolean
function CastSkillGround(myid, position, sk)
  if CanUseSkill(sk.currentTime, sk.lastTime, sk.cooldown) then
    SkillGround(myid, sk.level, sk.id, position.x, position.y)
    return true
  else
    return false
  end
end

---@param sp number
---@return boolean
function HasEnoughSp(sp)
  local enoughSp = GetSp(MyID) > sp
  return enoughSp
end
