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
      if not HasEnoughSp(skill.sp) then
        return false
      end
      local currentTime = GetTick()
      if currentTime < cooldown then
        return false
      end
      return true
    end
    return false
  end

  ---@param skillId number
  ---@param target number
  ---@param opts SkillOpts
  ---@return Status
  local function castSkill(skillId, target, opts)
    MySkill = skillId
    ---@type Skill
    local skill = MySkills[skillId]
    local isGroundCast = opts.targetType == 'ground'
    if isGroundCast then
      local x, y = GetV(V_POSITION, target)
      if 0 == SkillGround(MyID, skill.level, skill.id, x, y) then
        MyCooldown[skillId] = GetTick() + 3000
        return STATUS.FAILURE
      end
    else
      if 0 == SkillObject(MyID, skill.level, skill.id, target) then
        MyCooldown[skillId] = GetTick() + 3000
        return STATUS.FAILURE
      end
    end

    if GetV(V_HOMUNTYPE, MyID) == ELEANOR then
      if MySpheres > 0 then
        MySpheres = math.max(0, MySpheres - MySkills[skillId].sphere_cost)
      end
      local currentSp = GetV(V_SP, MyID)
      if currentSp <= MySP then
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
    MyCooldown[skillId] = GetTick() + skill.cast_time + skill.cooldown
    MySkill = 0
    return STATUS.SUCCESS
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
