---@class CommandNode
---@field processUserCommands Node
---@field executeHold Node
---@field executeMove Node
---@field executePatrol Node
---@field executeFollow Node
---@field executeStop Node
---@field executeAttackObject Node
---@field executeAttackArea Node
---@field executeSkillObject Node
---@field executeSkillGround Node
---@field resetToIdle Node
---@field isHoldMode Condition
---@field isFollowMode Condition
---@field isStopMode Condition
---@field isMoveMode Condition
---@field isIdleMode Condition
---@field isAttackObject Condition
---@field isAttackArea Condition
---@field isPatrolMode Condition
---@field isSkillObject Condition
---@field isSkillGround Condition

---@type CommandNode
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
  isStopped = false,
}

function M.processUserCommands(bb)
  local msg = GetMsg(bb.myId)

  if msg[1] == CommandType.NONE and not CommandData.isStopped then
    return STATUS.SUCCESS
  end
  CommandData.isStopped = false

  if msg[1] == CommandType.MOVE then
    CommandData.state = CommandState.MOVE
    CommandData.destX = msg[2]
    CommandData.destY = msg[3]
    Move(bb.myId, msg[2], msg[3])
  elseif msg[1] == CommandType.STOP then
    CommandData.state = CommandState.STOP
    CommandData.isStopped = true
  elseif msg[1] == CommandType.ATTACK_OBJECT then
    CommandData.state = CommandState.ATTACK_OBJECT
    CommandData.targetId = msg[2]
  elseif msg[1] == CommandType.ATTACK_AREA then
    CommandData.state = CommandState.ATTACK_AREA
    CommandData.destX = msg[2]
    CommandData.destY = msg[3]
  elseif msg[1] == CommandType.PATROL then
    CommandData.state = CommandState.PATROL
    CommandData.patrolX = msg[2]
    CommandData.patrolY = msg[3]
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

function M.isHoldMode()
  return CommandData.state == CommandState.HOLD
end

function M.isFollowMode()
  return CommandData.state == CommandState.FOLLOW
end

function M.isMoveMode()
  return CommandData.state == CommandState.MOVE
end

function M.isStopMode()
  return CommandData.state == CommandState.STOP
end

function M.isPatrolMode()
  return CommandData.state == CommandState.PATROL
end

function M.isIdleMode()
  return CommandData.state == CommandState.IDLE
end

function M.isAttackObject()
  return CommandData.state == CommandState.ATTACK_OBJECT
end

function M.isAttackArea()
  return CommandData.state == CommandState.ATTACK_AREA
end

function M.isSkillObject()
  return CommandData.state == CommandState.SKILL_OBJECT
end

function M.isSkillGround()
  return CommandData.state == CommandState.SKILL_AREA
end

---@return Node
function M.executeHold(bb)
  bb.myEnemy = 0
  bb.myEnemies = {}
  bb.mySkill = bb.resetMySkill()
  return STATUS.SUCCESS
end

function M.executeMove(bb)
  local x, y = GetV(V_POSITION, bb.myId)
  if x == CommandData.destX and y == CommandData.destY then
    CommandData.state = CommandState.IDLE
    return STATUS.SUCCESS
  end
  Move(bb.myId, CommandData.destX, CommandData.destY)
  return STATUS.RUNNING
end

function M.executePatrol(bb)
  if #bb.myEnemies < 30 then
    SearchForEnemies(bb.myId, 30, function(enemy)
      table.insert(bb.myEnemies, enemy)
    end)
  end

  if #bb.myEnemies > 0 then
    return STATUS.SUCCESS
  end

  local x, y = GetV(V_POSITION, bb.myId)
  if x == CommandData.patrolX and y == CommandData.patrolY and GetV(V_MOTION, bb.myId) ~= MOTION_MOVE then
    CommandData.destX = CommandData.patrolX
    CommandData.destY = CommandData.patrolY
    CommandData.patrolX = x
    CommandData.patrolY = y
    Move(bb.myId, CommandData.destX, CommandData.destY)
  end
  return STATUS.RUNNING
end

function M.executeFollow(bb)
  if GetDistanceFromOwner(bb.myId) > 3 then
    if GetV(V_MOTION, bb.myId) ~= MOTION_MOVE then
      MoveToOwner(bb.myId)
    end
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function M.executeStop(bb)
  if CommandData.isStopped then
    if GetV(V_MOTION, bb.myId) ~= MOTION_STAND then
      Move(bb.myId, GetV(V_POSITION, bb.myId))
    end
    return STATUS.RUNNING
  else
    CommandData.state = CommandState.IDLE
    bb.myEnemy = 0
    bb.myEnemies = {}
    CommandData.destX = 0
    CommandData.destY = 0
    return STATUS.SUCCESS
  end
end

function M.executeAttackObject(bb)
  bb.myEnemy = CommandData.targetId
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

function M.executeAttackArea(bb)
  local x, y = GetV(V_POSITION, bb.myId)
  if x ~= CommandData.destX or y ~= CommandData.destY then
    Move(bb.myId, CommandData.destX, CommandData.destY)
  end
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

function M.executeSkillObject(bb)
  if IsInAttackSight(bb.myId, bb.myEnemy, bb) then
    if 0 == SkillObject(bb.myId, CommandData.skillLevel, CommandData.skillId, CommandData.targetId) then
      return STATUS.FAILURE
    end
  end
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

function M.executeSkillGround(bb)
  if IsInAttackSight(bb.myId, bb.myEnemy, bb) then
    if 0 == SkillGround(bb.myId, CommandData.skillLevel, CommandData.skillId, CommandData.destX, CommandData.destY) then
      return STATUS.FAILURE
    end
  end
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

function M.resetToIdle()
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

return M
