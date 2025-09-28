---@param mySkills Skills
---@param myCooldown Cooldown
---@return Homun
local function Homun(mySkills, myCooldown)
  ---@type Condition
  local condition = require('AI.USER_AI.BT.conditions')
  ---@type Node
  local node = require('AI.USER_AI.BT.nodes')
  local MySkills = mySkills
  local MyCooldown = myCooldown

  ---@param mySkill number
  ---@return boolean
  local function isSkillCastable(mySkill)
    ---@type Skill
    local skill = MySkills[mySkill]
    local cooldown = MyCooldown[mySkill]
    if MyLevel >= skill.required_level then
      return condition.isSkillCastable(skill, cooldown)
    end
    return false
  end

  ---@param skill number
  ---@param target number
  ---@param opts SkillOpts
  ---@return Status
  local function castSkill(skill, target, opts)
    local casted = node.castSkill(MySkills[skill], MyCooldown[skill], target, opts)
    if casted == STATUS.RUNNING then
      MyCooldown[skill] = GetTickInSeconds()
      return STATUS.RUNNING
    elseif casted == STATUS.SUCCESS then
      MyCooldown[skill] = GetTickInSeconds()
      MySkill = 0
      return STATUS.SUCCESS
    end
    MySkill = 0
    return STATUS.FAILURE
  end

  ---@param combat fun():Status
  ---@return fun():Status
  local function root(combat)
    return Selector({
      Conditions(combat, condition.hasEnemyOrInList, condition.ownerIsNotTooFar),
      Condition(node.follow, condition.ownerMoving),
      Condition(
        Selector({
          Condition(node.patrol, condition.ownerIsSitting),
          Condition(node.follow, condition.ownerNotMoving),
        }),
        Inversion(condition.hasEnemyOrInList)
      ),
    })
  end

  return {
    isSkillCastable = isSkillCastable,
    castSkill = castSkill,
    root = root,
  }
end

return Homun
