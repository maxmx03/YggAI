---@class HomunCondition
---@field hasAllSpheres Condition
---@field isAmistr Condition
---@field isFilir Condition
---@field isVanilmirth Condition
---@field isLif Condition
---@field isEira Condition
---@field isBayeri Condition
---@field isSera Condition
---@field isDieter Condition
---@field isEleanor Condition

---@type HomunCondition
local M = {}

function M.hasAllSpheres(bb)
  local maxSpheres = 5
  if bb.mySpheres < maxSpheres then
    return false
  end
  return true
end

function M.isAmistr(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == AMISTR or humntype == AMISTR_H or humntype == AMISTR2 or humntype == AMISTR_H2
end

function M.isFilir(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == FILIR or humntype == FILIR_H or humntype == FILIR2 or humntype == FILIR_H2
end

function M.isVanilmirth(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == VANILMIRTH or humntype == VANILMIRTH_H or humntype == VANILMIRTH2 or humntype == VANILMIRTH_H2
end

function M.isLif(bb)
  local h = GetV(V_HOMUNTYPE, bb.myId)
  return h == LIF or h == LIF2 or h == LIF_H or h == LIF_H2
end

function M.isEira(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == EIRA
end

function M.isBayeri(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == BAYERI
end

function M.isSera(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == SERA
end

function M.isDieter(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == DIETER
end

function M.isEleanor(bb)
  local humntype = GetV(V_HOMUNTYPE, bb.myId)
  return humntype == ELEANOR
end

return M
