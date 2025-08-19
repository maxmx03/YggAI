require 'AI.USER_AI.Functions'
require 'AI.USER_AI.Skills'

function OnIDLE_ST()
  TraceAI 'IDLE_ST'
  local object = GetEnemy(MyID)
  if object ~= 0 then
    MyState = CHASE_ST
    MyEnemy = object
    TraceAI 'IDLE_ST -> CHASE_ST'
    return
  end
  local distance = GetDistanceFromOwner(MyID)
  if distance > 3 or distance == -1 then
    MyState = FOLLOW_ST
    TraceAI 'IDLE_ST -> FOLLOW_ST'
    return
  end
end

function OnCHASE_ST()
  TraceAI 'OnCHASE_ST'
  UseSkill {
    myid = MyID,
    skillId = HAMI_DEFENCE,
    lastSkillTime = GetTick(),
    cooldown = 20000,
    target = MyID,
  }
  if IsOutOfSight(MyID, MyEnemy) then -- ENEMY_OUTSIGHT_IN
    MyState = IDLE_ST
    MyEnemy = 0
    MyDestX, MyDestY = 0, 0
    TraceAI 'CHASE_ST -> IDLE_ST : ENEMY_OUTSIGHT_IN'
    return
  end
  if IsInAttackSight(MyID, MyEnemy) then
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
