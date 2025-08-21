require 'AI.USER_AI.Source.Util'
require 'AI.USER_AI.Source.Const'
local Skill = require 'AI.USER_AI.Source.Skill'

---@class Humun
---@field public id number
---@field public enemy number
---@field public skills table
---@field public skillLevel number
---@field public state 'watch' | 'idle' | 'follow' | 'chase' | 'attack' | 'humun_fighting' | 'owner_damaged' | 'owner_health' | 'owner_dying' | 'owner_dead' | "owner_siting"
local Humun = {
  id = 0,
  skills = {},
  skill = 0,
  skillLevel = 5,
  state = 'idle',
}

---@class Owner
---@field public id number
local Owner = {
  id = 0,
}

---@class Enemy
---@field public id number
local Enemy = {
  id = 0,
}

CurrentTime = 0
LastTime = 0
local Command = {
  ResCmdList = List.new(),
  [NONE_CMD] = function()
    TraceAI 'NONE_CMD'
    Humun.state = 'idle'
    Enemy.id = 0
  end,
  [MOVE_CMD] = function(x, y)
    TraceAI 'MOVE_CMD'
    Move(Humun.id, x, y)
    Humun.state = 'idle'
    Enemy.id = 0
  end,
  [STOP_CMD] = function()
    TraceAI 'STOP_CMD'

    if GetV(V_MOTION, Humun.id) ~= MOTION_STAND then
      local y, x = GetV(V_POSITION, Humun.id)
      Move(Humun.id, x, y)
    end
    Humun.state = 'idle'
    Enemy.id = 0
  end,
  [ATTACK_OBJECT_CMD] = function(id)
    TraceAI 'ATTACK_OBJECT_CMD'

    Enemy.id = id
    Humun.state = 'chase'
  end,
  [ATTACK_AREA_CMD] = function(x, y)
    TraceAI 'ATTACK_AREA_CMD'
    Move(Humun.id, x, y)
    Humun.state = 'chase'
  end,
  [PATROL_CMD] = function(x, y)
    TraceAI 'PATROL_CMD'
    Move(Humun.id, x, y)
    Enemy.id = GetOwnerEnemy(Humun.id)

    if Enemy.id == 0 then
      Enemy.id = GetMyEnemy(Humun.id)
    end

    if Enemy.id ~= 0 then
      Humun.state = 'chase'
      TraceAI 'PATROL_CMD -> CHASE'
    end
  end,
  [HOLD_CMD] = function()
    -- FIXME: GRAVITY DEVELOPERS NEED TO FIX THIS BUG, NOT ME.
    -- HOLD_CMD IS NOT BEING CALLED, THIS FUNCTION SHOULD BE CALLED WHEN THE OWNER
    -- MARK A TARGET.
  end,
  [SKILL_OBJECT_CMD] = function(level, skill, id)
    TraceAI 'SKILL_OBJECT_CMD'
    Enemy.id = id
    Humun.skill = skill
    Humun.skillLevel = level
    Humun.state = 'chase'
    TraceAI 'SKILL_OBJECT_CMD -> CHASE'
  end,
  [SKILL_AREA_CMD] = function(level, skill, x, y)
    TraceAI 'SKILL_AREA_CMD'
    Move(Humun.id, x, y)

    local destX, destY = GetV(V_POSITION, Humun.id)
    ---@diagnostic disable-next-line: redundant-parameter
    if GetDistance(x, y, destX, destY) <= GetV(V_SKILLATTACKRANGE_LEVEL, Humun.id, skill, level) then
      SkillGround(Humun.id, level, skill, destX, destY)
      Humun.state = 'idle'
      Humun.skill = 0
    end
  end,
  [FOLLOW_CMD] = function()
    TraceAI 'FOLLOW_CMD'
    Humun.state = 'follow'
    TraceAI 'FOLLOW_CMD -> FOLLOW'
  end,
}

---@param msg string
local function ProcessCommand(msg)
  local cmd = Command[msg[1]]

  if type(cmd) == 'function' then
    cmd(msg[2], msg[3], msg[4], msg[5])
  end
end

---@class State
local State = {
  [HUMUNCULU_FIGHTING] = function()
    TraceAI 'HUMUNCULU_FIGHTING'
    for index, skill in ipairs(Humun.skills) do
      if
        skill.id == HLIF_CHANGE
        or skill.id == HAMI_BLOODLUST
        or skill.id == HFLI_FLEET
        or skill.id == HFLI_SPEED
        or skill.id == MH_GOLDENE_FERSE
        or skill.id == MH_ANGRIFFS_MODUS
        or skill.id == MH_MAGMA_FLOW
      then
        local ok = UseSkill(Humun.id, skill, skill.cooldown, Owner.id)
        if ok then
          Humun.skills[index].lastSkillTime = CurrentTime
        end
      end
    end
    Humun.state = 'idle'
  end,
  [OWNER_DAMAGED] = function()
    TraceAI 'OWNER_DAMAGED'
    for index, skill in ipairs(Humun.skills) do
      if skill.id == HLIF_AVOID or skill.id == HAMI_DEFENCE or skill.id == MH_PAIN_KILLER then
        local ok = UseSkill(Humun.id, skill, skill.cooldown, Owner.id)
        if ok then
          Humun.skills[index].lastSkillTime = CurrentTime
        end
      end
    end
    Humun.state = 'idle'
  end,
  [OWNER_LOST_HEALTH] = function()
    TraceAI 'OWNER_LOST_HEALTH'
    for index, skill in ipairs(Humun.skills) do
      if skill.id == HLIF_HEAL or skill.id == HVAN_CHAOTIC then
        local ok = UseSkill(Humun.id, skill, skill.cooldown, Owner.id)
        if ok then
          Humun.skills[index].lastSkillTime = CurrentTime
        end
      end
    end
    Humun.state = 'idle'
  end,
  [OWNER_DYING] = function()
    TraceAI 'OWNER_DYING'
    for index, skill in ipairs(Humun.skills) do
      if
        skill.id == HLIF_AVOID
        or skill.id == HAMI_CASTLE
        or skill.id == MH_STEINWAND
        or skill.id == HVAN_CHAOTIC
        or skill.id == MH_GRANITIC_ARMOR
        or skill.id == MH_OVERED_BOOST
        or skill.id == MH_SILENT_BREEZE
      then
        local ok = UseSkill(Humun.id, skill, skill.cooldown, Owner.id)
        if ok then
          Humun.skills[index].lastSkillTime = CurrentTime
        end
      end
    end
    Humun.state = 'idle'
  end,
  [OWNER_DEAD] = function()
    TraceAI 'OWNER_DEAD'
    for index, skill in ipairs(Humun.skills) do
      if skill.id == MH_LIGHT_OF_REGENE then
        local ok = UseSkill(Humun.id, skill, skill.cooldown, Owner.id)
        if ok then
          Humun.skills[index].lastSkillTime = CurrentTime
        end
      end
    end
    Humun.state = 'idle'
  end,
  [WATCH] = function()
    TraceAI 'WATCH'
    local enoughSp = GetSp(Humun.id) > GetMaxSp(Humun.id) * 0.1

    if not enoughSp then
      Humun.state = 'idle'
      return
    end

    local ownerMotion = GetV(V_MOTION, Owner.id)
    local ownerIsDead = ownerMotion == MOTION_DEAD

    if ownerIsDead then
      Humun.state = 'owner_dying'
      return
    end

    local ownerHp = GetHp(Owner.id)
    local ownerMaxHp = GetMaxHp(Owner.id)
    local ownerDying = ownerHp <= ownerMaxHp * 0.3

    if ownerDying then
      TraceAI 'WATCH -> OWNER_DYING'
      Humun.state = 'owner_dying'
      return
    end

    local ownerLosingHealth = ownerHp <= ownerMaxHp * 0.7

    if ownerLosingHealth then
      TraceAI 'WATCH -> OWNER_LOST_HEALTH'
      Humun.state = 'owner_health'
      return
    end

    local ownerMotion = GetV(V_MOTION, Owner.id)
    local ownerBeingDamaged = ownerMotion == MOTION_DAMAGE
    local enemy = GetOwnerEnemy(Humun.id)
    if ownerBeingDamaged or enemy ~= 0 then
      TraceAI 'WATCH -> OWNER_DAMAGED'
      Humun.state = 'owner_damaged'
      return
    end

    local humunculuMotion = GetV(V_MOTION, Humun.id)
    local humunculusIsFighting = humunculuMotion == MOTION_ATTACK or humunculuMotion == MOTION_ATTACK2
    if humunculusIsFighting then
      TraceAI 'WATCH -> FIGHTING'
      Humun.state = 'humun_fighting'
      return
    end

    Humun.state = 'idle'
  end,
  [OWNER_SITTING] = function()
    TraceAI 'OWNER_SITTING'
    local OwnerMotion = GetV(V_MOTION, Owner.id)
    local OwnerSitting = OwnerMotion == MOTION_SIT

    if not OwnerSitting then
      Humun.state = 'idle'
      TraceAI 'OWNER_SITTING -> IDLE'
      return
    end

    local cooldown = math.random(10) * 1000

    if CurrentTime - LastTime > cooldown then
      if IsOutOfSight(Humun.id, Owner.id) then
        MoveToOwner(Humun.id)
        return
      end

      local destX, destY = GetV(V_POSITION, Owner.id)
      local randomX = math.random(-10, 10)
      local randomY = math.random(-10, 10)
      destX = destX + randomX
      destY = destY + randomY
      Move(Humun.id, destX, destY)

      LastTime = CurrentTime
    end
  end,
  [IDLE] = function()
    TraceAI 'IDLE'

    local OwnerMotion = GetV(V_MOTION, Owner.id)
    local OwnerSitting = OwnerMotion == MOTION_SIT

    if OwnerSitting then
      Humun.state = 'owner_siting'
      TraceAI 'IDLE -> SITTING'
      return
    end

    local distance = GetDistanceFromOwner(Humun.id)

    local cmd = List.popleft(Command.ResCmdList)
    if cmd ~= nil then
      ProcessCommand(cmd)
    end

    if distance > 3 or distance < -1 then
      Humun.state = 'follow'
      TraceAI 'IDLE -> FOLLOW'
      return
    end

    local enemy = GetOwnerEnemy(Humun.id)
    local OwnerIsFighthing = OwnerMotion == MOTION_ATTACK or OwnerMotion == MOTION_ATTACK2

    if enemy ~= 0 or OwnerIsFighthing then
      Enemy.id = enemy
      Humun.state = 'watch'
      TraceAI 'IDLE -> WATCH'
      return
    end

    Humun.state = 'watch'
    TraceAI 'IDLE -> WATCH'
  end,
  [FOLLOW] = function()
    TraceAI 'FOLLOW'

    local OwnerMotion = GetV(V_MOTION, Owner.id)
    local OwnerNotMoving = OwnerMotion == MOTION_SIT or OwnerMotion == MOTION_STAND or OwnerMotion == MOTION_DEAD
    local OwnerTooClose = GetDistanceFromOwner(Humun.id) <= 3

    if OwnerNotMoving or OwnerTooClose then
      Humun.state = 'idle'
      MoveToOwner(Humun.id)
      TraceAI 'FOLLOW -> IDLE : OWNER_NOT_MOVING | OWNER_TOO_CLOSE'
    else
      MoveToOwner(Humun.id)
      TraceAI 'FOLLOW -> FOLLOW'
    end
  end,
  [CHASE] = function()
    TraceAI 'CHASE'
    local OwnerTooFar = GetDistanceFromOwner(Humun.id) > 10

    if IsOutOfSight(Humun.id, Enemy.id) or OwnerTooFar then
      Humun.state = 'follow'
      Enemy.id = 0
      TraceAI 'CHASE -> FOLLOW : ENEMY_OUTSIGHT_IN | OWNER_TOO_FAR'
      return
    end

    if IsInAttackSight(Humun.id, Enemy.id, Humun) then
      Humun.state = 'attack'
      TraceAI 'CHASE -> ATTACK : ENEMY_INATTACKSIGHT_IN'
      return
    end

    ---@diagnostic disable-next-line: redundant-parameter
    local x, y = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, Enemy.id, Humun.skill, Humun.skillLevel)
    local destX, destY = GetV(V_POSITION, Humun.id)
    if destX ~= x or destY ~= y then
      ---@diagnostic disable-next-line: redundant-parameter
      destX, destY = GetV(V_POSITION_APPLY_SKILLATTACKRANGE, Enemy.id, Humun.skill, Humun.skillLevel)
      ---@diagnostic disable-next-line: param-type-mismatch
      Move(Humun.id, destX, destY)
      TraceAI 'CHASE -> CHASE : DESTCHANGED_IN'
      return
    end
  end,
  [ATTACK] = function()
    TraceAI 'ATTACK'

    local EnemyIsDead = GetV(V_MOTION, Enemy.id) == MOTION_DEAD
    if IsOutOfSight(Humun.id, Enemy.id) or EnemyIsDead then
      Humun.state = 'idle'
      TraceAI 'ATTACK -> IDLE'
      return
    end

    if not IsInAttackSight(Humun.id, Enemy.id, Humun) then
      Humun.state = 'chase'
      Humun.destX, Humun.destY = GetV(V_POSITION, Enemy.id)
      Move(Humun.id, Humun.destX, Humun.destY)
      TraceAI 'ATTACK -> CHASE'
      return
    end

    ---TODO: ATTACK AN ENEMY WITH A SKILL
    Attack(Humun.id, Enemy.id)
    TraceAI 'ATTACK -> ATTACK : BASIC ATTACK'
  end,
}

local gotSkill = false

function AI(myid)
  Humun.id = myid
  Owner.id = GetV(V_OWNER, myid)
  CurrentTime = GetTick()
  if not gotSkill then
    Humun.skills = Skill.getSkills(Humun)
    gotSkill = true
  end

  local msg = GetMsg(myid)
  local rmsg = GetResMsg(myid)

  if msg[1] == NONE_CMD then
    if rmsg[1] ~= NONE_CMD then
      if List.size(Command.ResCmdList) < 10 then
        List.pushright(Command.ResCmdList, rmsg)
      end
    end
  else
    List.clear(Command.ResCmdList)
    ProcessCommand(msg)
  end

  local action = State[Humun.state]

  if action and type(action) == 'function' then
    action()
  end
end
