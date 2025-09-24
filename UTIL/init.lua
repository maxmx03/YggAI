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
  local h = GetV(V_HOMUNTYPE, MyID)
  return h == LIF or h == LIF2 or h == LIF_H or h == LIF_H2
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
function IsFireMonster(myEnemy)
  local fireMonsters = require('AI.USER_AI.MONSTER_DATA.fire')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return fireMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsPlantMonster(myEnemy)
  local plantMonsters = require('AI.USER_AI.MONSTER_DATA.plant')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return plantMonsters[id]
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
function IsHolyMonster(myEnemy)
  local holyMonsters = require('AI.USER_AI.MONSTER_DATA.holy')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return holyMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsDarkMonster(myEnemy)
  local darkMonsters = require('AI.USER_AI.MONSTER_DATA.dark')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return darkMonsters[id]
end

---@param myEnemy number
---@return boolean
function IsUndeadMonster(myEnemy)
  local undeadMonsters = require('AI.USER_AI.MONSTER_DATA.undead')
  local id = GetV(V_HOMUNTYPE, myEnemy)
  return undeadMonsters[id]
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

---@return number
function GetTickInSeconds()
  return GetTick() / 1000
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

---@param target number
---@param sk sk
---@return boolean
function CastSkill(target, sk)
  if CanUseSkill(sk.currentTime, sk.lastTime, sk.cooldown) then
    local status = SkillObject(MyID, sk.level, sk.id, target)
    if status == nil or status == 1 then
      return true
    end
  end
  return false
end

---@class Position
---@field x number
---@field y number

---@param position Position
---@param sk sk
---@return boolean
function CastSkillGround(position, sk)
  if CanUseSkill(sk.currentTime, sk.lastTime, sk.cooldown) then
    local status = SkillGround(MyID, sk.level, sk.id, position.x, position.y)
    if status == nil or status == 1 then
      return true
    end
  end
  return false
end

---@param sp number
---@return boolean
function HasEnoughSp(sp)
  local enoughSp = GetSp(MyID) > sp
  return enoughSp
end

---@param myid number
---@param callback function
function SearchForEnemies(myid, callback)
  local owner = GetV(V_OWNER, myid)
  local priority = {}
  local others = {}
  local actors = GetActors()
  for _, actorId in ipairs(actors) do
    if actorId ~= owner and actorId ~= myid then
      local target = GetV(V_TARGET, actorId)
      local owner_target = GetV(V_TARGET, owner)
      if not IsOutOfSight(myid, actorId) then
        if IsMonster(actorId) == 1 then
          if owner_target == actorId then
            table.insert(priority, actorId)
          elseif IsMVP(actorId) or IsBoss(actorId) then
            table.insert(priority, actorId)
          elseif (target == myid or target == owner) and IsEnemyAllowed(actorId) then
            table.insert(priority, actorId)
          else
            if IsEnemyAllowed(actorId) then
              table.insert(others, actorId)
            end
          end
        elseif target == myid or target == owner or owner_target == actorId then
          table.insert(priority, actorId)
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
