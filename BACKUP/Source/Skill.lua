require 'AI.USER_AI.Source.Const'

---@diagnostic disable: redundant-parameter
local Skill = {}

---@param Humunculu table
---@return table
function Skill.getSkills(id)
  local homun_type = GetV(V_HOMUNTYPE, Humunculu.id)
  if homun_type == LIF or homun_type == LIF2 or homun_type == LIF_H then
    return {
      {
        id = HLIF_HEAL,
        cooldown = 20000,
        lastSkillTime = 0,
      },
      {
        id = HLIF_AVOID,
        cooldown = 35000,
        lastSkillTime = 0,
      },
      {
        id = HLIF_CHANGE,
        cooldown = 1200000,
        lastSkillTime = 0,
      },
    }
  elseif homun_type == AMISTR or homun_type == AMISTR2 or homun_type == AMISTR_H then
    return {
      {
        id = HAMI_CASTLE,
        cooldown = 10000, -- ITS NOT THE REAL COOLDOWN
        lastSkillTime = 0,
      },
      {
        id = HAMI_DEFENCE,
        cooldown = 30000,
        lastSkillTime = 0,
      },
      {
        id = HAMI_BLOODLUST,
        cooldown = 900000,
        lastSkillTime = 0,
      },
    }
  elseif homun_type == FILIR or homun_type == FILIR2 or homun_type == FILIR_H then
    return {
      {
        id = HFLI_FLEET,
        cooldown = 120000,
        lastSkillTime = 0,
      },
      {
        id = HFLI_SPEED,
        cooldown = 120000,
        lastSkillTime = 0,
      },
    }
  elseif homun_type == VANILMIRTH or homun_type == VANILMIRTH2 or homun_type == VANILMIRTH_H then
    return {
      {
        id = HVAN_CHAOTIC,
        cooldown = 3000,
        lastSkillTime = 0,
      },
    }
  elseif homun_type == BAYERI then
    return {
      {
        id = MH_GOLDENE_FERSE,
        cooldown = 90000, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
      {
        id = MH_STEINWAND,
        cooldown = 10000, -- ITS NOT THE REAL COOLDOWN
        lastSkillTime = 0,
      },
      {
        id = MH_ANGRIFFS_MODUS,
        cooldown = 90000, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
    }
  elseif homun_type == DIETER then
    return {
      {
        id = MH_GRANITIC_ARMOR,
        cooldown = 60000, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
      {
        id = MH_MAGMA_FLOW,
        cooldown = 90000, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
    }
  elseif homun_type == EIRA then
    return {
      {
        id = MH_OVERED_BOOST,
        cooldown = 90000, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
      {
        id = MH_LIGHT_OF_REGENE,
        cooldown = 90000, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
      {
        id = MH_SILENT_BREEZE,
        cooldown = 21000, -- ITS SILENCE DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
    }
  elseif homun_type == SERA then
    return {
      {
        id = MH_PAIN_KILLER,
        cooldown = 120000, -- ITS SKILL DURATION, NOT COOLDOWN
        lastSkillTime = 0,
      },
    }
  end

  -- If the homunculus type is not recognized, return an empty table
  return {}
end

return Skill
