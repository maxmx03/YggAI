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

---@class CommandState
local CommandState = {
  IDLE = 0,
  MOVE = 1,
  ATTACK_OBJECT = 2,
  ATTACK_AREA = 3,
  PATROL = 4,
  STOP = 5,
  SKILL_OBJECT = 6,
  SKILL_AREA = 7,
  FOLLOW = 8,
  HOLD = 9,
}

---@class ComandType
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

---@class CommandData
local CommandData = {
  state = CommandState.IDLE,
  lastCommand = {},
  isStopped = false,
  destX = 0,
  destY = 0,
  patrolX = 0,
  patrolY = 0,
  targetId = 0,
  skillId = 0,
  skillLevel = 0,
}

local NoCommand = { CommandType.NONE }

---@alias Commands table<number>

---@param bb Blackboard
function M.processUserCommands(bb)
  local msg = List.popleft(ResCmdList)
  if msg == nil then
    return STATUS.SUCCESS
  end
  CommandData.state = msg[1]
  if CommandData.state == nil then
    return STATUS.FAILURE
  end
  if CommandData.state == CommandType.NONE then
    List.clear(ResCmdList)
    CommandData.lastCommand = {}
    return STATUS.SUCCESS
  end
  CommandData.lastCommand = msg
  if CommandData.state == CommandType.MOVE then
    CommandData.state = CommandState.MOVE
    CommandData.isStopped = false
    CommandData.destX = msg[2]
    CommandData.destY = msg[3]
  elseif CommandData.state == CommandType.STOP then
    CommandData.isStopped = msg[2]
    CommandData.state = CommandState.STOP
  elseif CommandData.state == CommandType.ATTACK_OBJECT then
    CommandData.state = CommandState.ATTACK_OBJECT
    CommandData.targetId = msg[2]
  elseif CommandData.state == CommandType.ATTACK_AREA then
    CommandData.state = CommandState.ATTACK_AREA
    CommandData.destX = msg[2]
    CommandData.destY = msg[3]
  elseif CommandData.state == CommandType.PATROL then
    CommandData.state = CommandState.PATROL
    CommandData.patrolX = msg[2]
    CommandData.patrolY = msg[3]
  elseif CommandData.state == CommandType.HOLD then
    CommandData.state = CommandState.HOLD
  elseif CommandData.state == CommandType.SKILL_OBJECT then
    CommandData.state = CommandState.SKILL_OBJECT
    CommandData.skillLevel = msg[2]
    CommandData.skillId = msg[3]
    CommandData.targetId = msg[4]
    bb.myEnemy = msg[4]
  elseif CommandData.state == CommandType.SKILL_AREA then
    CommandData.state = CommandState.SKILL_AREA
    CommandData.skillLevel = msg[2]
    CommandData.skillId = msg[3]
    CommandData.destX = msg[4]
    CommandData.destY = msg[5]
  elseif CommandData.state == CommandType.FOLLOW then
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
  if bb.myEnemy ~= 0 then
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  SearchForEnemies(bb.myId, 8, function(enemy)
    if IsEnemyAlive(bb.myId, enemy) then
      table.insert(bb.myEnemies, enemy)
    end
  end)
  if #bb.myEnemies > 0 then
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  bb.destX = 0
  bb.destY = 0
  bb.myEnemy = 0
  bb.myEnemies = {}
  return STATUS.FAILURE
end

function M.executeMove(bb)
  local x = CommandData.destX
  local y = CommandData.destY
  bb.destX, bb.destY = GetV(V_POSITION, bb.myId)
  if x == bb.destX and y == bb.destY then
    List.pushleft(ResCmdList, { CommandType.STOP, true })
    bb.destX = 0
    bb.destY = 0
    return STATUS.SUCCESS
  end
  Move(bb.myId, x, y)
  List.pushleft(ResCmdList, CommandData.lastCommand)
  return STATUS.RUNNING
end

function M.executePatrol(bb)
  bb.patrolX, bb.patrolY = GetV(V_POSITION, bb.myId)
  bb.destX = CommandData.destX
  bb.destY = CommandData.destY
  if bb.destX ~= bb.patrolX and bb.patrolY ~= bb.destY then
    Move(bb.myId, bb.destX, bb.destY)
    List.pushleft(ResCmdList, CommandData.lastCommand)
    return STATUS.RUNNING
  end
  SearchForEnemies(bb.myId, 8, function(enemy)
    if IsEnemyAlive(bb.myId, enemy) then
      table.insert(bb.myEnemies, enemy)
    end
  end)
  if #bb.myEnemies > 0 then
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  List.pushleft(ResCmdList, NoCommand)
  return STATUS.SUCCESS
end

function M.executeFollow(bb)
  local ownerMotion = GetV(V_MOTION, bb.myOwner)
  if
    ownerMotion == MOTION_ATTACK
    or ownerMotion == MOTION_ATTACK2
    or ownerMotion == MOTION_SKILL
    or ownerMotion == MOTION_CASTING
  then
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  if GetDistanceFromOwner(bb.myId) > 3 then
    MoveToOwner(bb.myId)
    List.pushleft(ResCmdList, CommandData.lastCommand)
  end
  return STATUS.RUNNING
end

function M.executeStop(bb)
  if GetV(V_MOTION, bb.myId) ~= MOTION_STAND then
    Move(bb.myId, GetV(V_POSITION, bb.myId))
    List.pushleft(ResCmdList, CommandData.lastCommand)
    return STATUS.RUNNING
  end
  if CommandData.isStopped then
    List.pushleft(ResCmdList, { CommandState.STOP, true })
    return STATUS.SUCCESS
  end
  List.pushleft(ResCmdList, NoCommand)
  bb.destX = 0
  bb.destY = 0
  bb.myEnemy = 0
  bb.myEnemies = {}
  return STATUS.SUCCESS
end

function M.executeAttackObject(bb)
  bb.mySkill = bb.resetMySkill()
  bb.myEnemy = CommandData.targetId
  List.pushleft(ResCmdList, NoCommand)
  return STATUS.SUCCESS
end

function M.executeAttackArea(bb)
  local x = CommandData.destX
  local y = CommandData.destY
  if x ~= bb.destX or y ~= bb.destY or MOTION_MOVE ~= GetV(V_MOTION, bb.myId) then
    Move(bb.myId, x, y)
    bb.destX = x
    bb.destY = y
    List.pushleft(ResCmdList, CommandData.lastCommand)
    return STATUS.RUNNING
  end
  SearchForEnemies(bb.myId, 8, function(enemy)
    if IsEnemyAlive(bb.myId, enemy) then
      table.insert(bb.myEnemies, enemy)
    end
  end)
  if #bb.myEnemies > 0 then
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  local myX, myY = GetV(V_POSITION, bb.myId)
  if myX == bb.destX and myY == bb.destY then
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  return STATUS.SUCCESS
end

function M.executeSkillObject(bb)
  if IsInAttackSight(bb.myId, bb.myEnemy, bb) then
    if 0 == SkillObject(bb.myId, CommandData.skillLevel, CommandData.skillId, CommandData.targetId) then
      List.pushleft(ResCmdList, NoCommand)
      return STATUS.FAILURE
    end
  else
    local x, y = GetV(V_POSITION, bb.myEnemy)
    Move(bb.myId, x, y)
    List.pushleft(ResCmdList, CommandData.lastCommand)
    return STATUS.RUNNING
  end
  List.pushleft(ResCmdList, NoCommand)
  return STATUS.SUCCESS
end

function M.executeSkillGround(bb)
  local x, y = GetV(V_POSITION, bb.myId)
  if x ~= CommandData.destX and y ~= CommandData.destY then
    if 0 == SkillGround(bb.myId, CommandData.skillLevel, CommandData.skillId, CommandData.destX, CommandData.destY) then
      List.pushleft(ResCmdList, NoCommand)
      return STATUS.FAILURE
    end
  else
    Move(bb.myId, CommandData.destX, CommandData.destY)
    List.pushleft(ResCmdList, CommandData.lastCommand)
    return STATUS.RUNNING
  end
  List.pushleft(ResCmdList, NoCommand)
  return STATUS.SUCCESS
end

return M
