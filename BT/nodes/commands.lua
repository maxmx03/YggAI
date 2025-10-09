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
---@field hasCommands Condition

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

local CommandData = {
  state = CommandState.IDLE,
  destX = 0,
  destY = 0,
  patrolX = 0,
  patrolY = 0,
  targetId = 0,
  skillId = 0,
  skillLevel = 0,
}

---@alias Commands table<number>

---@param bb Blackboard
function M.processUserCommands(bb)
  local msg = List.popleft(ResCmdList)
  if msg == nil then
    TraceAI('[processUserCommands] -> STATUS.SUCCESS')
    return STATUS.SUCCESS
  end
  if msg[1] == CommandType.MOVE then
    CommandData.state = CommandState.MOVE
    CommandData.destX = msg[2]
    CommandData.destY = msg[3]
    TraceAI('MOVE')
  elseif msg[1] == CommandType.STOP then
    CommandData.state = CommandState.STOP
    TraceAI('STOP')
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
  elseif msg[1] == CommandType.FOLLOW then
    CommandData.state = CommandState.FOLLOW
  end
  return STATUS.SUCCESS
end

function M.hasCommands()
  return List.size(ResCmdList) > 0
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
  TraceAI('HOLD')
  if bb.myEnemy ~= 0 then
    CommandData.state = CommandState.IDLE
    TraceAI('HOLD -> STATUS.SUCCESS')
    return STATUS.SUCCESS
  end
  SearchForEnemies(bb.myId, 8, function(enemy)
    if IsEnemyAlive(bb.myId, enemy) then
      table.insert(bb.myEnemies, enemy)
    end
  end)
  if #bb.myEnemies > 0 then
    CommandData.state = CommandState.IDLE
    TraceAI('HOLD -> STATUS.SUCCESS')
    return STATUS.SUCCESS
  end
  bb.destX = 0
  bb.destY = 0
  bb.myEnemy = 0
  bb.myEnemies = {}
  TraceAI('HOLD -> STATUS.FAILURE')
  return STATUS.FAILURE
end

function M.executeMove(bb)
  local x = CommandData.destX
  local y = CommandData.destY
  if x == bb.destX and y == bb.destY then
    TraceAI('MOVE -> STATUS.SUCCESS -> IDLE')
    CommandData.state = CommandState.IDLE
    return STATUS.SUCCESS
  end
  local curX, curY = GetV(V_POSITION, bb.myId)
  if math.abs(x - curX) + math.abs(y - curY) > 15 then
    List.pushleft(ResCmdList, { CommandType.MOVE, x, y })
    x = math.floor((x + curX) / 2)
    y = math.floor((y + curY) / 2)
  end
  Move(bb.myId, x, y)
  CommandData.state = CommandState.MOVE
  bb.destX, bb.destY = GetV(V_POSITION, bb.myId)
  TraceAI('MOVE -> STATUS.RUNNING')
  return STATUS.RUNNING
end

function M.executePatrol(bb)
  bb.patrolX, bb.patrolY = GetV(V_POSITION, bb.myId)
  bb.destX = CommandData.destX
  bb.destY = CommandData.destY
  if bb.destX ~= bb.patrolX and bb.patrolY ~= bb.destY then
    Move(bb.myId, bb.destX, bb.destY)
    return STATUS.RUNNING
  end
  SearchForEnemies(bb.myId, 8, function(enemy)
    if IsEnemyAlive(bb.myId, enemy) then
      table.insert(bb.myEnemies, enemy)
    end
  end)

  if #bb.myEnemies > 0 then
    CommandData.state = CommandState.IDLE
    return STATUS.SUCCESS
  end

  local x, y = GetV(V_POSITION, bb.myId)
  if x == bb.destX and y == bb.destY then
    bb.destX = bb.patrolX
    bb.destY = bb.patrolY
    bb.patrolX = x
    bb.patrolY = y
    Move(bb.myId, bb.destX, bb.destY)
  end

  return STATUS.RUNNING
end

function M.executeFollow(bb)
  TraceAI('FOLLOW')
  if GetDistanceFromOwner(bb.myId) > 3 then
    MoveToOwner(bb.myId)
    TraceAI('FOLLOW -> STATUS.RUNNING')
    return STATUS.RUNNING
  end
  CommandData.state = CommandState.FOLLOW
  TraceAI('FOLLOW -> STATUS.SUCCESS')
  return STATUS.SUCCESS
end

function M.executeStop(bb)
  if GetV(V_MOTION, bb.myId) ~= MOTION_STAND then
    Move(bb.myId, GetV(V_POSITION, bb.myId))
    TraceAI('STOP -> STATUS.RUNNING')
    return STATUS.RUNNING
  end
  CommandData.state = CommandState.IDLE
  bb.destX = 0
  bb.destY = 0
  bb.myEnemy = 0
  bb.myEnemies = {}
  TraceAI('STOP -> STATUS.SUCCESS')
  return STATUS.SUCCESS
end

function M.executeAttackObject(bb)
  bb.mySkill = bb.resetMySkill()
  bb.myEnemy = CommandData.targetId
  CommandData.state = CommandState.IDLE
  TraceAI('ATTACK_OBJECT -> STATUS.SUCCESS')
  return STATUS.SUCCESS
end

function M.executeAttackArea(bb)
  local x = CommandData.destX
  local y = CommandData.destY
  if x ~= bb.destX or y ~= bb.destY or MOTION_MOVE ~= GetV(V_MOTION, bb.myId) then
    Move(bb.myId, x, y)
    bb.destX = x
    bb.destY = y
    return STATUS.RUNNING
  end
  SearchForEnemies(bb.myId, 8, function(enemy)
    if IsEnemyAlive(bb.myId, enemy) then
      table.insert(bb.myEnemies, enemy)
    end
  end)
  if #bb.myEnemies > 0 then
    CommandData.state = CommandState.IDLE
    return STATUS.SUCCESS
  end
  local myX, myY = GetV(V_POSITION, bb.myId)
  if myX == bb.destX and myY == bb.destY then
    CommandData.state = CommandState.IDLE
    return STATUS.SUCCESS
  end
  return STATUS.SUCCESS
end

function M.executeSkillObject(bb)
  if IsInAttackSight(bb.myId, bb.myEnemy, bb) then
    if 0 == SkillObject(bb.myId, CommandData.skillLevel, CommandData.skillId, CommandData.targetId) then
      return STATUS.FAILURE
    end
  else
    local x, y = GetV(V_POSITION, bb.myEnemy)
    Move(bb.myId, x, y)
    return STATUS.RUNNING
  end
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

function M.executeSkillGround(bb)
  local x, y = GetV(V_POSITION, bb.myId)
  if x ~= CommandData.destX and y ~= CommandData.destY then
    if 0 == SkillGround(bb.myId, CommandData.skillLevel, CommandData.skillId, CommandData.destX, CommandData.destY) then
      return STATUS.FAILURE
    end
  else
    Move(bb.myId, CommandData.destX, CommandData.destY)
    return STATUS.RUNNING
  end
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

function M.resetToIdle()
  CommandData.state = CommandState.IDLE
  return STATUS.SUCCESS
end

return M
