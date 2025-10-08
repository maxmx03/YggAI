---@class CommandNode
local M = {}

local CommandState = {
  IDLE = 0,
  MOVE = 1,
  ATTACK_OBJECT = 2,
  ATTACK_AREA = 3,
  PATROL = 4,
  HOLD = 5,
  SKILL_OBJECT = 6,
  SKILL_AREA = 7,
  FOLLOW = 8,
}

local CommandType = {
  NONE = 0,
  MOVE = 1,
  STOP = 2,
  ATTACK_OBJECT = 3,
  ATTACK_AREA = 4,
  PATROL = 5,
  HOLD = 6,
  SKILL_OBJECT = 7,
  SKILL_AREA = 8,
  FOLLOW = 9,
}

CommandData = {
  state = CommandState.IDLE,
  destX = 0,
  destY = 0,
  patrolX = 0,
  patrolY = 0,
  targetId = 0,
  skillId = 0,
  skillLevel = 0,
}

---@return Node
function M.processUserCommands()
  return function(bb)
    local msg = GetMsg(bb.myId)

    if msg[1] == CommandType.NONE then
      return STATUS.SUCCESS
    end

    if msg[1] == CommandType.MOVE then
      CommandData.state = CommandState.MOVE
      CommandData.destX = msg[2]
      CommandData.destY = msg[3]
      Move(bb.myId, msg[2], msg[3])
    elseif msg[1] == CommandType.STOP then
      CommandData.state = CommandState.IDLE
      Move(bb.myId, GetV(V_POSITION, bb.myId))
      bb.myEnemy = 0
    elseif msg[1] == CommandType.ATTACK_OBJECT then
      CommandData.state = CommandState.ATTACK_OBJECT
      CommandData.targetId = msg[2]
      bb.myEnemy = msg[2]
    elseif msg[1] == CommandType.ATTACK_AREA then
      CommandData.state = CommandState.ATTACK_AREA
      CommandData.destX = msg[2]
      CommandData.destY = msg[3]
      Move(bb.myId, msg[2], msg[3])
    elseif msg[1] == CommandType.PATROL then
      CommandData.state = CommandState.PATROL
      CommandData.patrolX, CommandData.patrolY = GetV(V_POSITION, bb.myId)
      CommandData.destX = msg[2]
      CommandData.destY = msg[3]
      Move(bb.myId, msg[2], msg[3])
    elseif msg[1] == CommandType.HOLD then
      CommandData.state = CommandState.HOLD
      bb.myEnemy = 0
    elseif msg[1] == CommandType.SKILL_OBJECT then
      CommandData.state = CommandState.SKILL_OBJECT
      CommandData.skillLevel = msg[2]
      CommandData.skillId = msg[3]
      CommandData.targetId = msg[4]
      bb.myEnemy = msg[4]
    elseif msg[1] == CommandType.SKILL_AREA then
      CommandData.state = CommandState.SKILL_AREA
      CommandData.skillLevel = msg[2]
      CommandData.skillId = msg[3]
      CommandData.destX = msg[4]
      CommandData.destY = msg[5]
      Move(bb.myId, msg[4], msg[5])
    elseif msg[1] == CommandType.FOLLOW then
      if CommandData.state == CommandState.FOLLOW then
        CommandData.state = CommandState.IDLE
      else
        CommandData.state = CommandState.FOLLOW
        MoveToOwner(bb.myId)
      end
    end

    return STATUS.SUCCESS
  end
end

---@return boolean
function M.isHoldMode(bb)
  return CommandData.state == CommandState.HOLD
end

---@return boolean
function M.isFollowMode(bb)
  return CommandData.state == CommandState.FOLLOW
end

---@return boolean
function M.isMoveMode(bb)
  return CommandData.state == CommandState.MOVE
end

---@return boolean
function M.isPatrolMode(bb)
  return CommandData.state == CommandState.PATROL
end

---@return Node
function M.executeHold()
  return function(bb)
    if bb.myEnemy == 0 then
      for _, enemy in ipairs(bb.myEnemies) do
        local target = GetV(V_TARGET, enemy)
        if target == bb.myOwner or target == bb.myId then
          bb.myEnemy = enemy
          break
        end
      end
    end

    if bb.myEnemy ~= 0 and IsInAttackSight(bb.myId, bb.myEnemy, bb) then
      Attack(bb.myId, bb.myEnemy)
      return STATUS.RUNNING
    end

    return STATUS.SUCCESS
  end
end

---@return Node
function M.executeMove()
  return function(bb)
    local x, y = GetV(V_POSITION, bb.myId)
    if x == CommandData.destX and y == CommandData.destY then
      CommandData.state = CommandState.IDLE
      return STATUS.SUCCESS
    end
    return STATUS.RUNNING
  end
end

---@return Node
function M.executePatrol()
  return function(bb)
    local x, y = GetV(V_POSITION, bb.myId)
    if x == CommandData.destX and y == CommandData.destY then
      local tempX, tempY = CommandData.destX, CommandData.destY
      CommandData.destX = CommandData.patrolX
      CommandData.destY = CommandData.patrolY
      CommandData.patrolX = tempX
      CommandData.patrolY = tempY
      Move(bb.myId, CommandData.destX, CommandData.destY)
    end
    return STATUS.RUNNING
  end
end

---@return Node
function M.executeFollow()
  return function(bb)
    if GetDistanceFromOwner(bb.myId) > 3 then
      if GetV(V_MOTION, bb.myId) ~= MOTION_MOVE then
        MoveToOwner(bb.myId)
      end
      return STATUS.RUNNING
    end
    return STATUS.SUCCESS
  end
end

---@return Node
function M.resetToIdle()
  return function(bb)
    CommandData.state = CommandState.IDLE
    return STATUS.SUCCESS
  end
end

return M
