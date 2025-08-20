function OnMOVE_CMD(x, y)
  TraceAI 'OnMOVE_CMD'
  if x == MyDestX and y == MyDestY and MOTION_MOVE == GetV(V_MOTION, MyID) then
    return
  end
  local curX, curY = GetV(V_POSITION, MyID)
  if math.abs(x - curX) + math.abs(y - curY) > 15 then
    List.pushleft(ResCmdList, { MOVE_CMD, x, y })
    x = math.floor((x + curX) / 2)
    y = math.floor((y + curY) / 2)
  end
  Move(MyID, x, y)
  MyState = IDLE_ST
  MyDestX = x
  MyDestY = y
  MyEnemy = 0
  MySkill = 0
end

function OnSTOP_CMD()
  TraceAI 'OnSTOP_CMD'

  if GetV(V_MOTION, MyID) ~= MOTION_STAND then
    Move(MyID, GetV(V_POSITION, MyID))
  end
  MyState = IDLE_ST
  MyDestX = 0
  MyDestY = 0
  MyEnemy = 0
  MySkill = 0
end

function OnATTACK_OBJECT_CMD(id)
  TraceAI 'OnATTACK_OBJECT_CMD'
  MySkill = 0
  MyEnemy = id
  MyState = CHASE_ST
end

function OnATTACK_AREA_CMD(x, y)
  TraceAI 'OnATTACK_AREA_CMD'
  if x ~= MyDestX or y ~= MyDestY or MOTION_MOVE ~= GetV(V_MOTION, MyID) then
    Move(MyID, x, y)
  end
  MyDestX = x
  MyDestY = y
  MyEnemy = 0
  MyState = ATTACK_AREA_CMD_ST
end

function OnPATROL_CMD(x, y)
  TraceAI 'OnPATROL_CMD'
  MyPatrolX, MyPatrolY = GetV(V_POSITION, MyID)
  MyDestX = x
  MyDestY = y
  Move(MyID, x, y)
  MyState = PATROL_CMD_ST
end

function OnHOLD_CMD()
  TraceAI 'OnHOLD_CMD'
  MyDestX = 0
  MyDestY = 0
  MyEnemy = 0
  MyState = HOLD_CMD_ST
end

function OnSKILL_OBJECT_CMD(level, skill, id)
  TraceAI 'OnSKILL_OBJECT_CMD'
  MySkillLevel = level
  MySkill = skill
  MyEnemy = id
  MyState = CHASE_ST
end

function OnSKILL_AREA_CMD(level, skill, x, y)
  TraceAI 'OnSKILL_AREA_CMD'
  Move(MyID, x, y)
  MyDestX = x
  MyDestY = y
  MySkillLevel = level
  MySkill = skill
  MyState = SKILL_AREA_CMD_ST
end

function OnFOLLOW_CMD()
  if MyState ~= FOLLOW_CMD_ST then
    MoveToOwner(MyID)
    MyState = FOLLOW_CMD_ST
    MyDestX, MyDestY = GetV(V_POSITION, GetV(V_OWNER, MyID))
    MyEnemy = 0
    MySkill = 0
    TraceAI 'OnFOLLOW_CMD'
  else
    MyState = IDLE_ST
    MyEnemy = 0
    MySkill = 0
    TraceAI 'FOLLOW_CMD_ST --> IDLE_ST'
  end
end

NONE_CMD = 0
MOVE_CMD = 1
STOP_CMD = 2
ATTACK_OBJECT_CMD = 3
ATTACK_AREA_CMD = 4
PATROL_CMD = 5
HOLD_CMD = 6
SKILL_OBJECT_CMD = 7
SKILL_AREA_CMD = 8
FOLLOW_CMD = 9

function ProcessCommand(msg)
  if msg[1] == MOVE_CMD then
    OnMOVE_CMD(msg[2], msg[3])
    TraceAI 'MOVE_CMD'
  elseif msg[1] == STOP_CMD then
    OnSTOP_CMD()
    TraceAI 'STOP_CMD'
  elseif msg[1] == ATTACK_OBJECT_CMD then
    OnATTACK_OBJECT_CMD(msg[2])
    TraceAI 'ATTACK_OBJECT_CMD'
  elseif msg[1] == ATTACK_AREA_CMD then
    OnATTACK_AREA_CMD(msg[2], msg[3])
    TraceAI 'ATTACK_AREA_CMD'
  elseif msg[1] == PATROL_CMD then
    OnPATROL_CMD(msg[2], msg[3])
    TraceAI 'PATROL_CMD'
  elseif msg[1] == HOLD_CMD then
    OnHOLD_CMD()
    TraceAI 'HOLD_CMD'
  elseif msg[1] == SKILL_OBJECT_CMD then
    OnSKILL_OBJECT_CMD(msg[2], msg[3], msg[4], msg[5])
    TraceAI 'SKILL_OBJECT_CMD'
  elseif msg[1] == SKILL_AREA_CMD then
    OnSKILL_AREA_CMD(msg[2], msg[3], msg[4], msg[5])
    TraceAI 'SKILL_AREA_CMD'
  elseif msg[1] == FOLLOW_CMD then
    OnFOLLOW_CMD()
    TraceAI 'FOLLOW_CMD'
  end
end
