---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [HFLI_MOON] = 0,
  [HFLI_FLEET] = 0,
  [HFLI_SPEED] = 0,
}

---@class Skills
local MySkills = {
  ---@type Skill
  [HFLI_MOON] = {
    id = HFLI_MOON,
    sp = 20,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 2
    end,
    level = 5,
    required_level = 15,
  },
  ---@type Skill
  [HFLI_FLEET] = {
    id = HFLI_FLEET,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 120
    end,
    level = 5,
    required_level = 25,
  },
  ---@type Skill
  [HFLI_SPEED] = {
    id = HFLI_SPEED,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 120
    end,
    level = 5,
    required_level = 40,
  },
}

---@type Homun
local filir = Homun(MySkills, MyCooldown)

local moon = {}
function moon.isSkillCastable()
  return filir.isSkillCastable(HFLI_MOON)
end
function moon.castSkill()
  return filir.castSkill(HFLI_MOON, MyEnemy, { targetType = 'target', keepRunning = false })
end
local fleet = {}
function fleet.isSkillCastable()
  return filir.isSkillCastable(HFLI_FLEET)
end
function fleet.castSkill()
  return filir.castSkill(HFLI_FLEET, MyID, { targetType = 'target', keepRunning = false })
end
local speed = {}
function speed.isSkillCastable()
  return filir.isSkillCastable(HFLI_SPEED)
end
function speed.castSkill()
  return filir.castSkill(HFLI_SPEED, MyID, { targetType = 'target', keepRunning = false })
end
local moonLightAttack = Condition(
  Parallel({
    moon.castSkill,
    node.chaseEnemy,
  }),
  moon.isSkillCastable
)
local combat = Selector({
  Condition(speed.castSkill, speed.isSkillCastable),
  Condition(fleet.castSkill, fleet.isSkillCastable),
  moonLightAttack,
  Condition(node.attackAndChase, Inversion(moon.isSkillCastable)),
})
return Condition(filir.root(combat), IsFilir)
