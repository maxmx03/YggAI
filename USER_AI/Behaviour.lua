---@class Skills
HOMUNCULU_SKILLS = {
  [HAMI_CASTLE] = {
    cooldown = 10000,
    lastTime = 0,
    level = 5,
  },
  [HAMI_DEFENCE] = {
    cooldown = 20000, -- SKILL DURATION
    lastTime = 0,
    level = 5,
  },
  [HAMI_BLOODLUST] = {
    cooldown = 300000, -- SKILL DURATION
    lastTime = 0,
    level = 3,
  },
}

local function cast_hamidefence()
  local skill = HOMUNCULU_SKILLS[HAMI_DEFENCE]
  local ok = UseSkill {
    myid = MyID,
    skillId = HAMI_DEFENCE,
    lastSkillTime = skill.lastTime,
    cooldown = skill.cooldown,
    target = MyID,
    level = 1,
  }
  if ok then
    HOMUNCULU_SKILLS[HAMI_DEFENCE].lastTime = CurrentTime
  else
    TraceAI 'FAILED TO CAST HAMI_DEFENCE'
    MyState = FOLLOW_ST
    TraceAI 'IDLE_ST -> FOLLOW_ST'
  end
end

function OnIDLE_ST()
  TraceAI 'IDLE_ST'
  local distance = GetDistanceFromOwner(MyID)
  if distance > 2 or distance == -1 then
    MyState = FOLLOW_ST
    TraceAI 'IDLE_ST -> FOLLOW_ST'
    return
  end
  local object = GetEnemy(MyID)
  if object ~= 0 then
    MyState = CHASE_ST
    MyEnemy = object
    TraceAI 'IDLE_ST -> CHASE_ST'
    return
  end
  local owner = GetV(V_OWNER, MyID)
  local OwnerMotion = GetV(V_MOTION, owner)
  if OwnerMotion == MOTION_SIT then
    local cooldown = math.random(10) * 1000
    if CurrentTime - LastTime > cooldown then
      if IsOutOfSight(MyID, owner) then
        MoveToOwner(MyID)
        return
      end
      local destX, destY = GetV(V_POSITION, owner)
      local randomX = math.random(-10, 10)
      local randomY = math.random(-10, 10)
      destX = destX + randomX
      destY = destY + randomY
      Move(MyID, destX, destY)
      LastTime = CurrentTime
    end
  end
end

function OnCHASE_ST()
  TraceAI 'OnCHASE_ST'
  local OwnerTooFar = GetDistanceFromOwner(MyID) > 10

  if IsOutOfSight(MyID, MyEnemy) or OwnerTooFar then
    MyState = IDLE_ST
    MyEnemy = 0
    MyDestX, MyDestY = 0, 0
    TraceAI 'CHASE_ST -> IDLE_ST : ENEMY_OUTSIGHT_IN'
    return
  end

  if IsInAttackSight(MyID, MyEnemy) then
    if IsAmistr(MyID) then
      TraceAI 'CHASE_ST -> HAMI_DEFENCE'
      cast_hamidefence()
    end
    MyState = ATTACK_ST
    TraceAI 'CHASE_ST -> ATTACK_ST : ENEMY_INATTACKSIGHT_IN'
    return
  end
  local x, y = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
  if MyDestX ~= x or MyDestY ~= y then -- DESTCHANGED_IN
    MyDestX, MyDestY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
    Move(MyID, MyDestX, MyDestY)
    TraceAI 'CHASE_ST -> CHASE_ST : DESTCHANGED_IN'
    return
  end
end

function OnATTACK_ST()
  TraceAI 'OnATTACK_ST'
  local OwnerTooFar = GetDistanceFromOwner(MyID) > 10

  if IsOutOfSight(MyID, MyEnemy) or OwnerTooFar then -- ENEMY_OUTSIGHT_IN
    MyState = IDLE_ST
    TraceAI 'ATTACK_ST -> IDLE_ST'
    return
  end

  if MOTION_DEAD == GetV(V_MOTION, MyEnemy) then -- ENEMY_DEAD_IN
    MyState = IDLE_ST
    TraceAI 'ATTACK_ST -> IDLE_ST'
    return
  end

  if not IsInAttackSight(MyID, MyEnemy) then -- ENEMY_OUTATTACKSIGHT_IN
    MyState = CHASE_ST
    MyDestX, MyDestY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, MyEnemy, MySkill, MySkillLevel)
    Move(MyID, MyDestX, MyDestY)
    TraceAI 'ATTACK_ST -> CHASE_ST  : ENEMY_OUTATTACKSIGHT_IN'
    return
  end

  if MySkill == 0 then
    Attack(MyID, MyEnemy)
  else
    if IsAmistr(MyID) then
      TraceAI 'CHASE_ST -> HAMI_DEFENCE'
      cast_hamidefence()
    end
  end
  TraceAI 'ATTACK_ST -> ATTACK_ST  : ENERGY_RECHARGED_IN'
end

function OnFOLLOW_ST()
  TraceAI 'OnFOLLOW_ST'
  if GetDistanceFromOwner(MyID) <= 3 then
    MyState = IDLE_ST
    TraceAI 'FOLLOW_ST -> IDLE_ST'
    return
  elseif GetV(V_MOTION, MyID) == MOTION_STAND then
    MoveToOwner(MyID)
    TraceAI 'FOLLOW_ST -> FOLLOW_ST'
    return
  end
end
