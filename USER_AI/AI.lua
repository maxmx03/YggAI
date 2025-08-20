require 'AI.USER_AI.Values'
require 'AI.USER_AI.State'
require 'AI.USER_AI.Motion'
require 'AI.USER_AI.Homuntypes'
require 'AI.USER_AI.Functions'
require 'AI.USER_AI.Skills'
List = require 'AI.USER_AI.List'
ResCmdList = List.new()
MyState = IDLE_ST
MyEnemy = 0
MyDestX = 0
MyDestY = 0
MyPatrolX = 0
MyPatrolY = 0
MyID = 0
MySkill = 0
MySkillLevel = 0
CurrentTime = 0
LastTime = 0
require 'AI.USER_AI.Commands'
require 'AI.USER_AI.Behaviour'

---@param myid number
function AI(myid)
  MyID = myid
  CurrentTime = GetTick()
  local msg = GetMsg(myid)
  local rmsg = GetResMsg(myid)

  if msg[1] == NONE_CMD then
    if rmsg[1] ~= NONE_CMD then
      if List.size(ResCmdList) < 10 then
        List.pushright(ResCmdList, rmsg)
      end
    end
  else
    List.clear(ResCmdList)
    ProcessCommand(msg)
  end
  if MyState == IDLE_ST then
    OnIDLE_ST()
  elseif MyState == CHASE_ST then
    OnCHASE_ST()
  elseif MyState == FOLLOW_ST then
    OnFOLLOW_ST()
  elseif MyState == ATTACK_ST then
    OnATTACK_ST()
  end
end
