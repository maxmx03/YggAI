---@class SkillNode
---@field enqueueSkill fun(skillId: number, target: "myEnemy" | "myOwner" | "myId", opts: SkillOpts): Node
---@field castSkill fun(skillId: number, target: "myEnemy" | "myOwner" | "myId", opts: SkillOpts): Node
---@field executeSkill Node
---@field hasSkillsToCast Condition

---@type SkillNode
local M = {}

-- if GetV(V_HOMUNTYPE, bb.myId) == ELEANOR then
--   if MySpheres > 0 then
--     MySpheres = math.max(0, MySpheres - bb.mySkills[skillId].sphere_cost)
--   end
--   local currentSp = GetV(V_SP, bb.myId)
--   if currentSp <= bb.mySp then
--     if BATTLE_MODE.isBattleMode() then
--       BATTLE_MODE.CURRENT = BATTLE_MODE.CLAW
--     else
--       BATTLE_MODE.CURRENT = BATTLE_MODE.BATTLE
--     end
--   end
-- end

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
    bb.mySkill.id = skillId
    bb.mySkill.level = skill.level
    table.insert(bb.skillQueue, skillData)
    return STATUS.SUCCESS
  end
end

function M.castSkill(skillId, target, opts)
  return function(bb)
    ---@type Skill
    local skillData = bb.mySkills[skillId]
    local skill = skillData.id
    local skillLevel = skillData.level
    local myTarget = bb[target]

    local skillCommandSuccess = true
    if bb.mySkill.coordinates.x ~= 0 or bb.mySkill.coordinates.y ~= 0 then
      local x = bb.mySkill.coordinates.x
      local y = bb.mySkill.coordinates.y
      SkillGround(bb.myId, skillLevel, skill, x, y)
    else
      if opts.skillType == 'area' then
        SkillGround(bb.myId, skillLevel, skill, GetV(V_POSITION, myTarget))
      else
        if SkillObject(bb.myId, skillLevel, skill, myTarget) == 0 then
          skillCommandSuccess = false
        end
      end
    end

    if skillCommandSuccess then
      if opts.keepRunning then
        return STATUS.RUNNING
      end
      bb.myCooldowns[skill] = GetTick() + bb.mySkills[skill].cooldown
      bb.mySkill = bb.resetMySkill()
      bb.mySkill.coordinates.x = 0
      bb.mySkill.coordinates.y = 0
      return STATUS.SUCCESS
    else
      bb.myCooldowns[skill] = GetTick() + 1000
      bb.mySkill.coordinates.x = 0
      bb.mySkill.coordinates.y = 0
      return STATUS.FAILURE
    end
  end
end

function M.executeSkill(bb)
  ---@type SkillData
  local skillData = table.remove(bb.skillQueue, 1)
  if skillData == nil then
    return STATUS.FAILURE
  end

  local skillId = skillData.id
  local skillLevel = skillData.level
  local myTarget = bb[skillData.target]

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
