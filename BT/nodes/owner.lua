---@class OwnerNode
---@field isMoving Condition
---@field isNotMoving Condition
---@field isNotTooFar Condition
---@field isMovingAway Condition
---@field isTakingDamage Condition
---@field isSitting Condition
---@field isDying Condition
---@field isDead Condition

---@type OwnerNode
local M = {}

function M.isMoving(bb)
  if GetDistanceFromOwner(bb.myId) > 3 and GetV(V_MOTION, bb.myOwner) == MOTION_MOVE then
    return true
  end
  return false
end

function M.isNotMoving(bb)
  local ownerMotion = GetV(V_MOTION, bb.myOwner)
  if ownerMotion == MOTION_STAND or ownerMotion == MOTION_DEAD then
    return true
  end
  return false
end

function M.isMovingAway(bb)
  return GetDistanceFromOwner(bb.myId) > bb.userConfig.maxDistanceToOwner and GetV(V_MOTION, bb.myOwner) == MOTION_MOVE
end

function M.isTakingDamage(bb)
  if GetV(V_MOTION, bb.myOwner) == MOTION_DAMAGE then
    return true
  end
  return false
end

function M.isSitting(bb)
  if GetV(V_MOTION, bb.myOwner) ~= MOTION_SIT then
    return false
  end
  return true
end

function M.isDying(bb)
  local ownerHp = GetV(V_HP, bb.myOwner)
  local ownerMaxHp = GetV(V_MAXHP, bb.myOwner)
  local ownerDying = ownerHp <= ownerMaxHp * 0.3
  if ownerDying and bb.myEnemy ~= 0 then
    return true
  end
  return false
end

function M.isDead(bb)
  local ownerDead = GetV(V_MOTION, bb.myOwner) == MOTION_DEAD
  if ownerDead then
    return true
  end
  return false
end

return M
