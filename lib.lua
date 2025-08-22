---@param msg string
function TraceAI(msg)
  print(msg)
end

---@param id number
function MoveToOwner(id)
  print(id)
end

---@param id number
---@param x number
---@param y number
function Move(id, x, y)
  print(id, x, y)
end

---@param myid number
---@param enemy_id number
function Attack(myid, enemy_id)
  print(myid, enemy_id)
end

---@param value any
---@param id number
---@return any,any
function GetV(value, id)
  print(value, id)
end

---@return number[]
function GetActors()
  return { 1, 2, 3, 4, 5 }
end

---@return number
function GetTick()
  return 1
end

---@param id number
---@return string
function GetMsg(id)
  print(id)
  return ''
end

---@param id number
---@return string
function GetResMsg(id)
  print(id)
  return ''
end

---@param id number
---@param level number
---@param skill number
---@param target number
function SkillObject(id, level, skill, target)
  print(id, level, skill, target)
end

---@param id number
---@param level number
---@param skill number
---@param x number
---@param y number
function SkillGround(id, level, skill, x, y)
  print(id, level, skill, x, y)
end

---@param id number
---@return string
function IsMonster(id)
  print(id)
  return ''
end
