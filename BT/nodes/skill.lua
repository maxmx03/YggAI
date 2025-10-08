---@class SkillNode
---@field executeSkill fun(target: "myEnemy" | "myOwner" | "myId", opts: SkillOpts): Node
---@field enqueueSkill fun(skillId: number, target: "myEnemy" | "myOwner" | "myId", opts: SkillOpts): Node
---@field isSkillCastable fun(skillId: number): Condition
---@field executeQueuedSkill  Node
---@field hasSkillsToCast Condition

---@type SkillNode
local M = {}

function M.executeSkill(target, opts)
  ---@type Node
  return function(bb)
    if bb.stopCasting then
      bb.mySkill = bb.resetMySkill()
      bb.mySkill.coordinates.x = 0
      bb.mySkill.coordinates.y = 0
      bb.stopCasting = false
      return STATUS.SUCCESS
    end

    local myTarget = bb[target]

    local skillCommandSuccess = true
    if bb.mySkill.coordinates.x ~= 0 or bb.mySkill.coordinates.y ~= 0 then
      local x = bb.mySkill.coordinates.x
      local y = bb.mySkill.coordinates.y
      SkillGround(bb.myId, bb.mySkill.level, bb.mySkill.id, x, y)
    else
      if opts.skillType == 'area' then
        SkillGround(bb.myId, bb.mySkill.level, bb.mySkill.id, GetV(V_POSITION, myTarget))
      else
        if SkillObject(bb.myId, bb.mySkill.level, bb.mySkill.id, myTarget) == 0 then
          skillCommandSuccess = false
        end
      end
    end

    if skillCommandSuccess then
      if opts.keepRunning then
        return STATUS.RUNNING
      end
      bb.myCooldowns[bb.mySkill.id] = GetTick() + bb.mySkills[bb.mySkill.id].cooldown
      bb.mySkill = bb.resetMySkill()
      bb.mySkill.coordinates.x = 0
      bb.mySkill.coordinates.y = 0
      return STATUS.SUCCESS
    else
      bb.myCooldowns[bb.mySkill.id] = GetTick() + 1000
      bb.mySkill = bb.resetMySkill()
      bb.mySkill.coordinates.x = 0
      bb.mySkill.coordinates.y = 0
      return STATUS.FAILURE
    end
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

    if MyLevel >= skill.required_level then
      local mySp = GetV(V_SP, bb.myId)
      if mySp >= skill.sp then
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

  local skillCommandSuccess = true
  if bb.mySkill.coordinates.x ~= 0 or bb.mySkill.coordinates.y ~= 0 then
    local x = bb.mySkill.coordinates.x
    local y = bb.mySkill.coordinates.y
    SkillGround(bb.myId, skillLevel, skillId, x, y)
  else
    if skillData.opts.skillType == 'area' then
      SkillGround(bb.myId, skillLevel, skillId, GetV(V_POSITION, myTarget))
    else
      if SkillObject(bb.myId, skillLevel, skillId, myTarget) == 0 then
        skillCommandSuccess = false
      end
    end
  end
  if skillCommandSuccess then
    if skillData.opts.keepRunning then
      return STATUS.RUNNING
    end
    bb.myCooldowns[skillId] = GetTick() + bb.mySkills[skillId].cooldown
    bb.mySkill = bb.resetMySkill()
    bb.castUntilTick = GetTick() + MINIMUM_GCD
    bb.mySkill.coordinates.x = 0
    bb.mySkill.coordinates.y = 0
    return STATUS.SUCCESS
  else
    bb.myCooldowns[skillId] = GetTick() + 1000
    table.insert(bb.skillQueue, skillData)
    bb.mySkill.coordinates.x = 0
    bb.mySkill.coordinates.y = 0
    return STATUS.FAILURE
  end
end

function M.hasSkillsToCast(bb)
  return #bb.skillQueue > 0
end

return M
