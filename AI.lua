require 'AI.USER_AI.HOMUN.Const'
require 'AI.USER_AI.HOMUN.Util'
ResCmdList = List.new() -- List of queued commands
require 'AI.USER_AI.HOMUN.CMD'
require 'AI.USER_AI.HOMUN.ST'

function AI(myid)
  CurrentTime = GetTick()
  MyID = myid
  MyOwner = GetV(V_OWNER, myid)
  local msg = GetMsg(myid) -- command
  local rmsg = GetResMsg(myid) -- reserved command

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
  elseif MyState == ATTACK_ST then
    OnATTACK_ST()
  elseif MyState == FOLLOW_ST then
    OnFOLLOW_ST()
  elseif MyState == PATROL_ST then
    OnPATROL_ST()
  elseif MyState == MOVE_CMD_ST then
    OnMOVE_CMD_ST()
  elseif MyState == STOP_CMD_ST then
    OnSTOP_CMD_ST()
  elseif MyState == ATTACK_OBJECT_CMD_ST then
    OnATTACK_OBJECT_CMD_ST()
  elseif MyState == ATTACK_AREA_CMD_ST then
    OnATTACK_AREA_CMD_ST()
  elseif MyState == PATROL_CMD_ST then
    OnPATROL_CMD_ST()
  elseif MyState == HOLD_CMD_ST then
    OnHOLD_CMD_ST()
  elseif MyState == SKILL_OBJECT_CMD_ST then
    OnSKILL_OBJECT_CMD_ST()
  elseif MyState == SKILL_AREA_CMD_ST then
    OnSKILL_AREA_CMD_ST()
  elseif MyState == FOLLOW_CMD_ST then
    OnFOLLOW_CMD_ST()
  else
    OnIDLE_ST()
  end
end
