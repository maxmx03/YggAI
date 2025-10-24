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
---@field isNone Condition
---@field isAttackObject Condition
---@field isAttackArea Condition
---@field isPatrolMode Condition
---@field isSkillObject Condition
---@field isSkillGround Condition
---@field hasCommands Condition

---@type CommandNode
local M = {}

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
  state = CommandType.NONE,
  isStopped = false,
  toggleFollow = false,
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

---@param _ Blackboard
function M.processUserCommands(_)
  local msg = List.popleft(ResCmdList)
  if msg == nil then
    return STATUS.SUCCESS
  end
  CommandData.state = msg[1]
  if CommandData.state == CommandType.MOVE then
    CommandData.isStopped = false
    CommandData.destX = msg[2]
    CommandData.destY = msg[3]
  elseif CommandData.state == CommandType.STOP then
    CommandData.isStopped = true
  elseif CommandData.state == CommandType.FOLLOW then
    CommandData.toggleFollow = not CommandData.toggleFollow
  elseif CommandData.state == CommandType.ATTACK_OBJECT then
    CommandData.targetId = msg[2]
  elseif CommandData.state == CommandType.ATTACK_AREA then
    CommandData.destX = msg[2]
    CommandData.destY = msg[3]
  elseif CommandData.state == CommandType.PATROL then
    CommandData.patrolX = msg[2]
    CommandData.patrolY = msg[3]
  elseif CommandData.state == CommandType.SKILL_OBJECT then
    CommandData.skillLevel = msg[2]
    CommandData.skillId = msg[3]
    CommandData.targetId = msg[4]
  elseif CommandData.state == CommandType.SKILL_AREA then
    CommandData.skillLevel = msg[2]
    CommandData.skillId = msg[3]
    CommandData.destX = msg[4]
    CommandData.destY = msg[5]
  end
  return STATUS.SUCCESS
end

function M.isHoldMode()
  return CommandData.state == CommandType.HOLD
end

function M.isFollowMode()
  return CommandData.state == CommandType.FOLLOW
end

function M.isMoveMode()
  return CommandData.state == CommandType.MOVE
end

function M.isStopMode()
  return CommandData.state == CommandType.STOP
end

function M.isPatrolMode()
  return CommandData.state == CommandType.PATROL
end

function M.isNone()
  return CommandData.state == CommandType.NONE
end

function M.isAttackObject()
  return CommandData.state == CommandType.ATTACK_OBJECT
end

function M.isAttackArea()
  return CommandData.state == CommandType.ATTACK_AREA
end

function M.isSkillObject()
  return CommandData.state == CommandType.SKILL_OBJECT
end

function M.isSkillGround()
  return CommandData.state == CommandType.SKILL_AREA
end

---@return Node
function M.executeHold(bb)
  if bb.myEnemy ~= 0 then
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
  List.pushleft(ResCmdList, { CommandType.STOP })
  Move(bb.myId, CommandData.destX, CommandData.destY)
  return STATUS.SUCCESS
end

function M.executePatrol(bb)
  bb.patrolX, bb.patrolY = GetV(V_POSITION, bb.myId)
  bb.destX = CommandData.destX
  bb.destY = CommandData.destY
  if bb.destX ~= bb.patrolX and bb.patrolY ~= bb.destY then
    Move(bb.myId, bb.destX, bb.destY)
    return STATUS.RUNNING
  end
  if bb.myEnemy ~= 0 then
    return STATUS.SUCCESS
  end
  return STATUS.SUCCESS
end

function M.executeFollow(bb)
  if not CommandData.toggleFollow then
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  if GetDistanceFromOwner(bb.myId) > 3 then
    MoveToOwner(bb.myId)
  end
  return STATUS.RUNNING
end

function M.executeStop(bb)
  ---@type EnemyNode
  local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'
  if GetDistanceFromOwner(bb.myId) > bb.userConfig.maxDistanceToOwner and GetV(V_MOTION, bb.myOwner) == MOTION_MOVE then
    CommandData.isStopped = false
    List.pushleft(ResCmdList, NoCommand)
    return STATUS.SUCCESS
  end
  if enemyNodes.hasEnemy(bb) then
    List.pushleft(ResCmdList, NoCommand)
    CommandData.isStopped = false
    return STATUS.SUCCESS
  end
  if CommandData.isStopped then
    return STATUS.SUCCESS
  end
  List.pushleft(ResCmdList, NoCommand)
  CommandData.isStopped = false
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
    return STATUS.RUNNING
  end
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
  if IsInAttackSight(bb.myId, CommandData.targetId, bb) then
    if 0 == SkillObject(bb.myId, CommandData.skillLevel, CommandData.skillId, CommandData.targetId) then
      List.pushleft(ResCmdList, NoCommand)
      return STATUS.FAILURE
    end
  else
    local x, y = GetV(V_POSITION, CommandData.targetId)
    Move(bb.myId, x, y)
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
    return STATUS.RUNNING
  end
  List.pushleft(ResCmdList, NoCommand)
  return STATUS.SUCCESS
end

function M.hasCommands()
  return List.size(ResCmdList) > 0
end

return M
