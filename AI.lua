require('AI.USER_AI.config')
require('AI.USER_AI.UTIL.Const')
require('AI.USER_AI.UTIL')
require('AI.USER_AI.BT')
local eira = require('AI.USER_AI.HOMUN.Eira')
local root = Selector({
  eira,
})
---@type Commands
ResCmdList = List.new()
function AI(myid)
  ---@type Commands
  local msg = GetMsg(myid)
  ---@type Commands
  local rmsg = GetResMsg(myid)
  local NONE = 0
  if msg[1] == NONE then
    if rmsg[1] ~= NONE then
      if List.size(ResCmdList) < 10 then
        List.pushright(ResCmdList, rmsg)
      end
    end
  else
    List.pushleft(ResCmdList, msg)
  end
  YggAI({
    root,
  }, myid)
end
