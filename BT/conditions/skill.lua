---@class SkillCondition
---@field isSkillCastable fun(skillId: number): Condition

---@type SkillCondition
local M = {}

---@return Condition
function M.isSkillCastable(skillId)
  return function(bb)
    ---@type Skill
    local skill = bb.mySkills[skillId]
    local cooldown = bb.myCooldowns[skillId]
    if MyLevel >= skill.required_level then
      local mySp = GetV(V_SP, bb.myId)
      if mySp >= skill.sp then
        local currentTime = GetTick()
        if currentTime < cooldown then
          return false
        end
        return true
      end
    end
    return false
  end
end

return M
