---@class EleanorNode
---@field executeSkill fun(target: "myEnemy" | "myOwner" | "myId", opts: SkillOpts): Node
---@field enqueueSkill fun(skillId: number, target: "myEnemy" | "myOwner" | "myId", opts: SkillOpts): Node
---@field isSkillCastable fun(skillId: number): Condition
---@field executeQueuedSkill  Node
---@field hasSkillsToCast Condition
---@field chaseEnemy Node
---@field basicAttack Node
---@field attackAndChase Node
---@field hasAllSpheres Condition
---@field isBattleMode Condition
---@field isClawMode Condition

---@type EleanorNode
local M = {}

function M.executeSkill(target, opts)
  ---@type Node
  return function(bb)
    if bb.stopCasting then
      bb.mySkill = bb.resetMySkill()
      bb.stopCasting = false
      return STATUS.SUCCESS
    end
    bb.eleanorSpBeforeCast = bb.mySp
    local myTarget = bb[target]
    if opts.skillType == 'area' then
      SkillGround(bb.myId, bb.mySkill.level, bb.mySkill.id, GetV(V_POSITION, myTarget))
    else
      SkillObject(bb.myId, bb.mySkill.level, bb.mySkill.id, myTarget)
    end
    bb.eleanorTriedCastSkill = true
    bb.mySpheres = math.max(0, bb.mySpheres - bb.mySkills[bb.mySkill.id].sphere_cost)
    if opts.keepRunning then
      return STATUS.RUNNING
    end
    bb.myCooldowns[bb.mySkill.id] = GetTick() + bb.mySkills[bb.mySkill.id].cooldown
    bb.mySkill = bb.resetMySkill()
    return STATUS.SUCCESS
  end
end

---@return Condition
function M.isSkillCastable(skillId)
  return function(bb)
    ---@type Skill
    local skill = bb.mySkills[skillId]
    local cooldown = bb.myCooldowns[skillId]
    local canCast = false

    bb.mySkill = bb.resetMySkill()
    bb.stopCasting = false

    if bb.userConfig.homunLevel >= skill.required_level then
      local mySp = GetV(V_SP, bb.myId)
      if mySp >= skill.sp and bb.mySpheres >= skill.sphere_cost then
        local currentTime = GetTick()
        if currentTime < cooldown then
          canCast = false
        else
          bb.mySkill.id = skill.id
          bb.mySkill.level = skill.level
          canCast = true
        end
      end
    end
    return canCast
  end
end

function M.enqueueSkill(skillId, target, opts)
  ---@type Node
  return function(bb)
    local skill = bb.mySkills[skillId]
    ---@class SkillData
    local skillData = {
      id = skillId,
      level = skill.level,
      target = target,
      opts = opts,
    }
    table.insert(bb.skillQueue, skillData)
    return STATUS.SUCCESS
  end
end

function M.executeQueuedSkill(bb)
  local MINIMUM_GCD = 500

  if GetTick() < bb.castUntilTick then
    return STATUS.RUNNING
  end

  ---@type SkillData
  local skillData = table.remove(bb.skillQueue, 1)
  if skillData == nil then
    return STATUS.FAILURE
  end
  local skillId = skillData.id
  local skillLevel = skillData.level
  local myTarget = bb[skillData.target]
  bb.mySkill.id = skillId
  bb.mySkill.level = skillLevel
  bb.eleanorSpBeforeCast = bb.mySp
  if skillData.opts.skillType == 'area' then
    SkillGround(bb.myId, skillLevel, skillId, GetV(V_POSITION, myTarget))
  else
    SkillObject(bb.myId, skillLevel, skillId, myTarget)
  end
  bb.eleanorTriedCastSkill = true
  bb.mySpheres = math.max(0, bb.mySpheres - bb.mySkills[skillId].sphere_cost)
  if skillData.opts.keepRunning then
    return STATUS.RUNNING
  end
  bb.myCooldowns[skillId] = GetTick() + bb.mySkills[skillId].cooldown
  bb.mySkill = bb.resetMySkill()
  bb.castUntilTick = GetTick() + MINIMUM_GCD
  return STATUS.SUCCESS
end

function M.hasSkillsToCast(bb)
  return #bb.skillQueue > 0
end

function M.chaseEnemy(bb)
  if not IsInAttackSight(bb.myId, bb.myEnemy, bb) then
    local enemyX, enemyY = GetV(V_POSITION, bb.myEnemy)
    Move(bb.myId, enemyX, enemyY)
    return STATUS.RUNNING
  end
  return STATUS.SUCCESS
end

function M.basicAttack(bb)
  if bb.myEnemy == 0 then
    return STATUS.FAILURE
  elseif bb.myEnemy ~= 0 then
    Attack(bb.myId, bb.myEnemy)
    if GetV(V_HOMUNTYPE, bb.myId) == ELEANOR then
      local limitSpheres = 5
      if bb.mySpheres < limitSpheres then
        if ChanceDoOrGainSomething(70) then
          bb.mySpheres = math.min(limitSpheres, bb.mySpheres + 1)
        end
        return STATUS.RUNNING
      end
    end
    return STATUS.SUCCESS
  end
  return STATUS.FAILURE
end

M.attackAndChase = Parallel {
  M.basicAttack,
  M.chaseEnemy,
}

function M.hasAllSpheres(bb)
  local maxSpheres = 5
  if bb.mySpheres < maxSpheres then
    return false
  end
  return true
end

function M.isBattleMode(bb)
  return bb.battleMode.BATTLE == bb.battleMode.CURRENT
end

function M.isClawMode(bb)
  return bb.battleMode.CLAW == bb.battleMode.CURRENT
end

return M
