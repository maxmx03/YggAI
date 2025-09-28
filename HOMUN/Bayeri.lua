---@type Node
local node = require('AI.USER_AI.BT.nodes')
---@type Condition
local condition = require('AI.USER_AI.BT.conditions')
local Homun = require('AI.USER_AI.UTIL.Homun')

---@class Cooldown
local MyCooldown = {
  [MH_STAHL_HORN] = 0,
  [MH_GOLDENE_FERSE] = 0,
  [MH_STEINWAND] = 0,
  [MH_ANGRIFFS_MODUS] = 0,
  [MH_HEILIGE_STANGE] = 0,
}

local MySkills = {
  ---@type Skill
  [MH_STAHL_HORN] = {
    id = MH_STAHL_HORN,
    sp = 70,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 0.7
    end,
    level = 10,
    required_level = 105,
  },
  [MH_GOLDENE_FERSE] = {
    id = MH_GOLDENE_FERSE,
    sp = 80,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 2
    end,
    level = 5,
    required_level = 112,
  },
  [MH_STEINWAND] = {
    id = MH_STEINWAND,
    sp = 120,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 2
    end,
    level = 5,
    required_level = 121,
  },
  [MH_ANGRIFFS_MODUS] = {
    id = MH_ANGRIFFS_MODUS,
    sp = 80,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 30
    end,
    level = 5,
    required_level = 130,
  },
  [MH_HEILIGE_STANGE] = {
    id = MH_HEILIGE_STANGE,
    sp = 100,
    cooldown = function(previousCooldown)
      if previousCooldown == 0 then
        return previousCooldown
      end
      return 5
    end,
    level = 10,
    required_level = 138,
  },
}

---@type Homun
local bayeri = Homun(MySkills, MyCooldown)

local stahl = {}
function stahl.isSkillCastable()
  return bayeri.isSkillCastable(MH_STAHL_HORN)
end
function stahl.castSkill()
  return bayeri.castSkill(MH_STAHL_HORN, MyEnemy, { targetType = 'target', keepRunning = false })
end

local gold = {}
function gold.isSkillCastable()
  return bayeri.isSkillCastable(MH_GOLDENE_FERSE)
end
function gold.castSkill()
  return bayeri.castSkill(MH_GOLDENE_FERSE, MyEnemy, { targetType = 'target', keepRunning = false })
end

local stein = {}
function stein.isSkillCastable()
  return bayeri.isSkillCastable(MH_STEINWAND)
end
function stein.castSkill()
  return bayeri.castSkill(MH_STEINWAND, MyOwner, { targetType = 'target', keepRunning = false })
end

local ang = {}
function ang.isSkillCastable()
  return bayeri.isSkillCastable(MH_ANGRIFFS_MODUS)
end
function ang.castSkill()
  return bayeri.castSkill(MH_ANGRIFFS_MODUS, MyOwner, { targetType = 'target', keepRunning = false })
end

local heil = {}
function heil.isSkillCastable()
  return bayeri.isSkillCastable(MH_HEILIGE_STANGE)
end
function heil.castSkill()
  return bayeri.castSkill(MH_HEILIGE_STANGE, MyEnemy, { targetType = 'target', keepRunning = false })
end

local magicShieldTrigger = Condition(
  Selector({
    Condition(stein.castSkill, condition.ownerIsDying),
    Condition(stein.castSkill, condition.ownerTookDamage),
  }),
  stein.isSkillCastable
)
local hornAttack = Condition(
  Parallel({
    stahl.castSkill,
    node.chaseEnemy,
  }),
  stahl.isSkillCastable
)
local illuminatusAtack = Condition(
  Parallel({
    heil.castSkill,
    node.chaseEnemy,
  }),
  heil.isSkillCastable
)
local attackWhileStahlNotAvailable = Condition(node.attackAndChase, Inversion(stahl.isSkillCastable))
local fightAgainsUnholyMonsters = Selector({
  Condition(gold.castSkill, gold.isSkillCastable),
  illuminatusAtack,
  hornAttack,
  attackWhileStahlNotAvailable,
})
local isUndeadMonster = Condition(fightAgainsUnholyMonsters, condition.isUndeadMonster)
local isDarkMonster = Condition(fightAgainsUnholyMonsters, condition.isDarkMonster)
local combat = Condition(
  Selector({
    magicShieldTrigger,
    isDarkMonster,
    isUndeadMonster,
    Condition(ang.castSkill, ang.isSkillCastable),
    hornAttack,
    attackWhileStahlNotAvailable,
  }),
  condition.enemyIsAlive
)
return Condition(bayeri.root(combat), IsBayeri)
