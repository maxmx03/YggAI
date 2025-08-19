---@param myid number
function IsLif(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == LIF or homun_type == LIF2 or homun_type == LIF_H
end

---@param myid number
function IsAmistr(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == AMISTR or homun_type == AMISTR2 or homun_type == AMISTR_H
end

---@param myid number
function IsFilir(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == FILIR or homun_type == FILIR2 or homun_type == FILIR_H
end

---@param myid number
function IsVanilmirth(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == VANILMIRTH or homun_type == VANILMIRTH2 or homun_type == VANILMIRTH_H
end

---@param myid number
function IsBayeri(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == BAYERI
end

---@param myid number
function IsDieter(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == DIETER
end

---@param myid number
function IsEira(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == EIRA
end

---@param myid number
function IsSera(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == SERA
end

---@param myid number
function IsEleanor(myid)
  local homun_type = GetV(V_HOMUNTYPE, myid)
  return homun_type == ELEANOR
end

---@param currentTime number
---@param lastTime number
---@param cooldown number
local function CanUseSkill(currentTime, lastTime, cooldown)
  if currentTime - lastTime > cooldown then
    return true
  end
  return false
end

---@class opts
---@field myid number
---@field skillId number
---@field lastSkillTime number
---@field cooldown number
---@field target number

---@param opts opts
---@return boolean
function UseSkill(opts)
  local level = 5
  if CanUseSkill(GetTick(), opts.lastSkillTime, opts.cooldown) then
    SkillObject(opts.myid, level, opts.skillId, opts.target)
    TraceAI('AUTO_CAST -> USE_SKILL: ' .. opts.skillId)
    return true
  else
    TraceAI('SKILL_IN_COOLDOWN' .. opts.skillId)
    return false
  end
end

---@param myid number
function GetHomunSkills(myid)
  if IsLif(myid) then
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
  elseif IsAmistr(myid) then
    return {
      {
        id = HAMI_CASTLE,
        cooldown = 10000,
        lastSkillTime = 0,
        level = 5,
      },
      {
        id = HAMI_DEFENCE,
        cooldown = 20000, -- SKILL DURATION
        lastSkillTime = 0,
        level = 5,
      },
      {
        id = HAMI_BLOODLUST,
        cooldown = 300000, -- SKILL DURATION
        lastSkillTime = 0,
        level = 3,
      },
    }
  elseif IsFilir(myid) then
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
  elseif IsVanilmirth(myid) then
    return {
      {
        id = HVAN_CHAOTIC,
        cooldown = 3000,
        lastSkillTime = 0,
      },
    }
  elseif IsBayeri(myid) then
    return {
      {
        id = MH_GOLDENE_FERSE,
        cooldown = 90000,
        lastSkillTime = 0,
      },
      {
        id = MH_STEINWAND,
        cooldown = 10000,
        lastSkillTime = 0,
      },
      {
        id = MH_ANGRIFFS_MODUS,
        cooldown = 90000,
        lastSkillTime = 0,
      },
    }
  elseif IsDieter(myid) then
    return {
      {
        id = MH_GRANITIC_ARMOR,
        cooldown = 60000,
        lastSkillTime = 0,
      },
      {
        id = MH_MAGMA_FLOW,
        cooldown = 90000,
        lastSkillTime = 0,
      },
    }
  elseif IsEira(myid) then
    return {
      {
        id = MH_OVERED_BOOST,
        cooldown = 90000,
        lastSkillTime = 0,
      },
      {
        id = MH_LIGHT_OF_REGENE,
        cooldown = 90000,
        lastSkillTime = 0,
      },
      {
        id = MH_SILENT_BREEZE,
        cooldown = 21000,
        lastSkillTime = 0,
      },
    }
  elseif IsSera(myid) then
    -- TODO: Add Sera skills
    return {
      {
        id = MH_SUMMON_LEGION,
        cooldown = 50010,
        lastSkillTime = 0,
        level = 5,
      },
      {
        id = MH_PAIN_KILLER,
        cooldown = 300300,
        lastSkillTime = 0,
        level = 10,
      },
    }
  end

  return {}
end
