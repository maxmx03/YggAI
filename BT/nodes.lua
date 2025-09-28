---@class Node
local M = {
  lastTimePatrol = 0,
}

---@return Status
function M.chaseEnemy()
  if not IsInAttackSight(MyID, MyEnemy) then
    local enemyX, enemyY = GetV(V_POSITION, MyEnemy)
    Move(MyID, enemyX, enemyY)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

---@return Status
function M.basicAttack()
  if MyEnemy == 0 then
    return STATUS.FAILURE
  elseif MyEnemy ~= 0 then
    Attack(MyID, MyEnemy)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

---@return Status
function M.patrol()
  local cooldown = math.random(3)
  if (GetTickInSeconds() - M.lastTimePatrol) > cooldown then
    local destX, destY = GetV(V_POSITION, MyOwner)
    local randomX = math.random(-10, 10)
    local randomY = math.random(-10, 10)
    destX = destX + randomX
    destY = destY + randomY
    if GetDistanceFromOwner(MyID) > 10 then
      M.lastTimePatrol = GetTickInSeconds()
      MoveToOwner(MyID)
      return STATUS.SUCCESS
    end
    Move(MyID, destX, destY)
    M.lastTimePatrol = GetTickInSeconds()
    return STATUS.SUCCESS
  end
  return STATUS.RUNNING
end

---@return Status
function M.follow()
  if GetDistanceFromOwner(MyID) > 3 then
    MoveToOwner(MyID)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

---@class SkillOpts
---@field keepRunning boolean
---@field targetType "ground" | "target"

---@param skill Skill
---@param cooldown number
---@param target number
---@param opts SkillOpts
---@return Status
function M.castSkill(skill, cooldown, target, opts)
  ---@type Skill
  local s = skill
  local lastTime = cooldown
  local cd = s.cooldown(lastTime)
  local sk = { level = s.level, id = skill.id, cooldown = cd, lastTime = lastTime, currentTime = GetTickInSeconds() }
  local casted = false
  if opts.targetType == 'ground' then
    local x, y = GetV(V_POSITION, target)
    casted = CastSkillGround({ x = x, y = y }, sk)
  else
    casted = CastSkill(target, sk)
  end
  if casted then
    if opts.keepRunning then
      return STATUS.RUNNING
    end
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end

function M.EleanorBasicAttack()
  if MySpheres < 5 then
    if math.random(100) < 70 then
      MySpheres = MySpheres + 1
    end
  end
  return M.basicAttack()
end

return M
