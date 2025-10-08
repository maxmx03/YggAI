---@class SkillNode
---@field castSkill fun(skillId: number, target: "enemy" | "owner" | "self", opts: SkillOpts): Node
---@field castAOESkill fun(skillId: number, target: "enemy" | "owner" | "self" | nil, opts: SkillOpts): Node

---@type SkillNode
local M = {}

---@return Node
function M.castSkill(skillId, target, opts)
  return function(bb)
    ---@type Skill
    local skill = bb.mySkills[skillId]
    local myTarget = 0
    bb.mySkill.id = skill.id
    bb.mySkill.level = skill.level

    if target == 'enemy' then
      myTarget = bb.myEnemy
    elseif target == 'owner' then
      myTarget = bb.myOwner
    else
      myTarget = bb.myId
    end

    if 0 == SkillObject(bb.myId, bb.mySkill.level, bb.mySkill.id, myTarget) then
      bb.myCooldowns[skillId] = GetTick() + 3000
      return STATUS.FAILURE
    end
    if GetV(V_HOMUNTYPE, bb.myId) == ELEANOR then
      if MySpheres > 0 then
        MySpheres = math.max(0, MySpheres - bb.mySkills[skillId].sphere_cost)
      end
      local currentSp = GetV(V_SP, bb.myId)
      if currentSp <= bb.mySp then
        if BATTLE_MODE.isBattleMode() then
          BATTLE_MODE.CURRENT = BATTLE_MODE.CLAW
        else
          BATTLE_MODE.CURRENT = BATTLE_MODE.BATTLE
        end
      end
    end
    if opts.keepRunning then
      return STATUS.RUNNING
    end
    bb.myCooldowns[skillId] = GetTick() + skill.cooldown
    bb.resetMySkill()
    return STATUS.SUCCESS
  end
end

function M.castAOESkill(skillId, target, opts)
  return function(bb)
    ---@type Skill
    local skill = bb.mySkills[skillId]
    local myTarget = 0
    bb.mySkill.id = skill.id
    bb.mySkill.level = skill.level
    if target == 'enemy' then
      myTarget = bb.myEnemy
    elseif target == 'owner' then
      myTarget = bb.myOwner
    else
      myTarget = bb.myId
    end
    if target ~= nil then
      local x, y = GetV(V_POSITION, myTarget)
      if 0 == SkillGround(bb.myId, bb.mySkill.level, bb.mySkill.id, x, y) then
        bb.myCooldowns[skillId] = GetTick() + 1000
        return STATUS.FAILURE
      end
      if opts.keepRunning then
        return STATUS.RUNNING
      end
      return STATUS.SUCCESS
    end

    if
      0
      == SkillGround(bb.myId, bb.mySkill.level, bb.mySkill.id, bb.mySkill.coordinates.x, bb.mySkill.coordinates.y)
    then
      bb.myCooldowns[skillId] = GetTick() + 1000
      return STATUS.FAILURE
    end
    if opts.keepRunning then
      return STATUS.RUNNING
    end
    bb.myCooldowns[skillId] = GetTick() + skill.cooldown
    bb.mySkill = bb.resetMySkill()
    return STATUS.SUCCESS
  end
end

return M
