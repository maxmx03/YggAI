require 'AI.USER_AI.Const'
require 'AI.USER_AI.Util'

-----------------------------
-- STATE
-----------------------------
IDLE_ST = 0
FOLLOW_ST = 1
CHASE_ST = 2
ATTACK_ST = 3
----------------------------

-------------- state process  --------------------
function OnIDLE_ST()
  TraceAI 'OnIDLE_ST'

  local cmd = List.popleft(ResCmdList)
  if cmd ~= nil then
    ProcessCommand(cmd)
    return
  end

  local object = GetOwnerEnemy(MyID)
  if object ~= 0 then
    MyState = CHASE_ST
    MyEnemy = object
    TraceAI 'IDLE_ST -> CHASE_ST : MYOWNER_ATTACKED_IN'
    return
  end

  object = GetMyEnemy(MyID)
  if object ~= 0 then -- ATTACKED_IN
    MyState = CHASE_ST
    MyEnemy = object
    TraceAI 'IDLE_ST -> CHASE_ST : ATTACKED_IN'
    return
  end

  local distance = GetDistanceFromOwner(MyID)
  if distance > 3 or distance == -1 then
    MyState = FOLLOW_ST
    TraceAI 'IDLE_ST -> FOLLOW_ST'
    return
  end
end

function OnFOLLOW_ST()
  TraceAI 'OnFOLLOW_ST'

  if GetDistanceFromOwner(MyID) <= 3 then
    MyState = IDLE_ST
    TraceAI 'FOLLOW_ST -> IDLW_ST'
    return
  elseif GetV(V_MOTION, MyID) == MOTION_STAND then
    MoveToOwner(MyID)
    TraceAI 'FOLLOW_ST -> FOLLOW_ST'
    return
  end
end

function OnCHASE_ST()
  TraceAI 'OnCHASE_ST'

  if true == IsOutOfSight(MyID, MyEnemy) then
    MyState = IDLE_ST
    MyEnemy = 0
    MyDestX, MyDestY = 0, 0
    TraceAI 'CHASE_ST -> IDLE_ST : ENEMY_OUTSIGHT_IN'
    return
  end
  if true == IsInAttackSight(MyID, MyEnemy) then
    MyState = ATTACK_ST
    TraceAI 'CHASE_ST -> ATTACK_ST : ENEMY_INATTACKSIGHT_IN'
    return
  end

  local x, y = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
  if MyDestX ~= x or MyDestY ~= y then
    MyDestX, MyDestY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
    Move(MyID, MyDestX, MyDestY)
    TraceAI 'CHASE_ST -> CHASE_ST : DESTCHANGED_IN'
    return
  end
end

function OnATTACK_ST()
  TraceAI 'OnATTACK_ST'

  if true == IsOutOfSight(MyID, MyEnemy) then
    MyState = IDLE_ST
    TraceAI 'ATTACK_ST -> IDLE_ST'
    return
  end

  if MOTION_DEAD == GetV(V_MOTION, MyEnemy) then
    MyState = IDLE_ST
    TraceAI 'ATTACK_ST -> IDLE_ST'
    return
  end

  if false == IsInAttackSight(MyID, MyEnemy) then
    MyState = CHASE_ST
    MyDestX, MyDestY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
    Move(MyID, MyDestX, MyDestY)
    TraceAI 'ATTACK_ST -> CHASE_ST  : ENEMY_OUTATTACKSIGHT_IN'
    return
  end

  local humun = GetV(V_HOMUNTYPE, MyID)

  if humun == AMISTR or humun == AMISTR_H or humun == AMISTR2 or humun == AMISTR_H2 then
    MySkill = HAMI_BLOODLUST
    MySkillLevel = 3
  elseif humun == FILIR or humun == FILIR_H or humun == FILIR2 or humun == FILIR_H2 then
    MySkill = HFLI_FLEET
    MySkillLevel = 5
  elseif humun == VANILMIRTH or humun == VANILMIRTH_H or humun == VANILMIRTH2 or humun == VANILMIRTH_H2 then
    MySkill = HVAN_CAPRICE
    MySkillLevel = 5
  end

  if MySkill == 0 then
    Attack(MyID, MyEnemy)
  else
    if CanUseSkill(CurrentTime, MyCooldown[MySkill].lastTime, MyCooldown[MySkill].cd(MySkillLevel)) then
      if 1 == SkillObject(MyID, MySkillLevel, MySkill, MyEnemy) then
        MyEnemy = 0
        MyCooldown[MySkill].lastTime = CurrentTime
      end
      MySkill = 0
      MySkillLevel = 0
    end
  end
  TraceAI 'ATTACK_ST -> ATTACK_ST  : ENERGY_RECHARGED_IN'
end

function OnMOVE_CMD_ST()
  TraceAI 'OnMOVE_CMD_ST'

  local x, y = GetV(V_POSITION, MyID)
  if x == MyDestX and y == MyDestY then
    MyState = IDLE_ST
  end
end

function OnSTOP_CMD_ST() end

function OnATTACK_OBJECT_CMD_ST() end

function OnATTACK_AREA_CMD_ST()
  TraceAI 'OnATTACK_AREA_CMD_ST'

  local object = GetOwnerEnemy(MyID)
  if object == 0 then
    object = GetMyEnemy(MyID)
  end

  if object ~= 0 then
    MyState = CHASE_ST
    MyEnemy = object
    return
  end

  local x, y = GetV(V_POSITION, MyID)
  if x == MyDestX and y == MyDestY then
    MyState = IDLE_ST
  end
end

function OnPATROL_CMD_ST()
  TraceAI 'OnPATROL_CMD_ST'

  local object = GetOwnerEnemy(MyID)
  if object == 0 then
    object = GetMyEnemy(MyID)
  end

  if object ~= 0 then
    MyState = CHASE_ST
    MyEnemy = object
    TraceAI 'PATROL_CMD_ST -> CHASE_ST : ATTACKED_IN'
    return
  end

  local x, y = GetV(V_POSITION, MyID)
  if x == MyDestX and y == MyDestY then
    MyDestX = MyPatrolX
    MyDestY = MyPatrolY
    MyPatrolX = x
    MyPatrolY = y
    Move(MyID, MyDestX, MyDestY)
  end
end

function OnHOLD_CMD_ST()
  TraceAI 'OnHOLD_CMD_ST'

  if MyEnemy ~= 0 then
    local d = GetDistance(MyEnemy, MyID)
    if d ~= -1 and d <= GetV(V_ATTACKRANGE, MyID) then
      Attack(MyID, MyEnemy)
    else
      MyEnemy = 0
    end
    return
  end

  local object = GetOwnerEnemy(MyID)
  if object == 0 then
    object = GetMyEnemy(MyID)
    if object == 0 then
      return
    end
  end

  MyEnemy = object
end

function OnSKILL_OBJECT_CMD_ST() end

function OnSKILL_AREA_CMD_ST()
  TraceAI 'OnSKILL_AREA_CMD_ST'

  local x, y = GetV(V_POSITION, MyID)
  if GetDistance(x, y, MyDestX, MyDestY) <= GetV(V_SKILLATTACKRANGE_LEVEL, MyID, MySkill, MySkillLevel) then
    SkillGround(MyID, MySkillLevel, MySkill, MyDestX, MyDestY)
    MyState = IDLE_ST
    MySkill = 0
  end
end

function OnFOLLOW_CMD_ST()
  TraceAI 'OnFOLLOW_CMD_ST'

  local ownerX, ownerY, myX, myY
  ownerX, ownerY = GetV(V_POSITION, GetV(V_OWNER, MyID))
  myX, myY = GetV(V_POSITION, MyID)

  local d = GetDistance(ownerX, ownerY, myX, myY)

  if d <= 3 then
    return
  end

  local motion = GetV(V_MOTION, MyID)
  if motion == MOTION_MOVE then
    d = GetDistance(ownerX, ownerY, MyDestX, MyDestY)
    if d > 3 then
      MoveToOwner(MyID)
      MyDestX = ownerX
      MyDestY = ownerY
      return
    end
  else
    MoveToOwner(MyID)
    MyDestX = ownerX
    MyDestY = ownerY
    return
  end
end
