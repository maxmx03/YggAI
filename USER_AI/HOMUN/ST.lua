-------------- state process  --------------------
function OnWATCH_ST()
  local motion = GetV(V_MOTION, MyOwner)
  local object = 0
  if motion == MOTION_ATTACK or motion == MOTION_ATTACK2 then
    object = GetOwnerEnemy(MyID)
    if object ~= 0 then
      MyState = CHASE_ST
      MyEnemy = object
      TraceAI 'WATCH_ST -> CHASE_ST : MYOWNER_ATTACKED_IN'
      return
    end
  end

  object = GetMyEnemy(MyID)
  if object ~= 0 then -- ATTACKED_IN
    MyState = CHASE_ST
    MyEnemy = object
    TraceAI 'WATCH_ST -> CHASE_ST : ATTACKED_IN'
    return
  end

  if motion == MOTION_SIT then
    MyState = PATROL_ST
    TraceAI 'WATCH_ST -> PATROL_ST'
    return
  end

  if motion == MOTION_STAND then
    MyState = IDLE_ST
    TraceAI 'WATCH_ST -> IDLE_ST'
    return
  end

  MyState = IDLE_ST
end

function OnIDLE_ST()
  TraceAI 'OnIDLE_ST'
  local distance = GetDistanceFromOwner(MyID)
  if distance > 2 or distance == -1 then
    MyState = FOLLOW_ST
    TraceAI 'IDLE_ST -> FOLLOW_ST'
    return
  end

  local cmd = List.popleft(ResCmdList)
  if cmd ~= nil then
    ProcessCommand(cmd)
    return
  end
  MyState = WATCH_ST
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

LastTimePatrol = 0
function OnPATROL_ST()
  TraceAI 'OnPATROL_ST'
  local OwnerMotion = GetV(V_MOTION, MyOwner)
  local OwnerSitting = OwnerMotion == MOTION_SIT
  if not OwnerSitting then
    MyState = IDLE_ST
    TraceAI 'ONPATROL_ST -> IDLE_ST'
    return
  end
  local cooldown = math.random(10) * 1000
  if (CurrentTime - LastTimePatrol) > cooldown then
    local destX, destY = GetV(V_POSITION, MyOwner)
    local randomX = math.random(-10, 10)
    local randomY = math.random(-10, 10)
    destX = destX + randomX
    destY = destY + randomY
    Move(MyID, destX, destY)
    if IsOutOfSight(MyID, MyOwner) then
      MoveToOwner(MYID)
      return
    else
      MyState = WATCH_ST
      TraceAI 'ONPATROL_ST -> WATCH_ST'
    end
    LastTimePatrol = CurrentTime
  end
  TraceAI 'ONPATROL_ST -> ENERGY_RECHARGED_IN'
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

  if IsAmistr(MyID) then
    MySkill = HAMI_DEFENCE
    MySkillLevel = 5
  elseif IsFilir(MyID) then
    MySkill = HFLI_FLEET
    MySkillLevel = 5
  elseif IsVanilmirth(MyID) then
    MySkill = HVAN_CAPRICE
    MySkillLevel = 5
  end

  if not CanUseSkill(CurrentTime, MyCooldown[MySkill].lastTime, MyCooldown[MySkill].cd(MySkillLevel)) then
    MySkill = 0
    MySkillLevel = 0
  end

  if MySkill == 0 then
    Attack(MyID, MyEnemy)
  else
    if humun == AMISTR or humun == AMISTR_H or humun == AMISTR2 or humun == AMISTR_H2 then
      local MyOwner = GetV(V_OWNER, MyID)
      SkillObject(MyID, MySkillLevel, MySkill, MyOwner)
    else
      SkillObject(MyID, MySkillLevel, MySkill, MyEnemy)
    end
    MyEnemy = 0
    MyCooldown[MySkill].lastTime = CurrentTime
    MySkill = 0
    MySkillLevel = 0
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
