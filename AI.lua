require('AI.USER_AI.config')
require('AI.USER_AI.UTIL.Const')
require('AI.USER_AI.UTIL')
require('AI.USER_AI.BT')
local eira = require('AI.USER_AI.HOMUN.Eira')
local root = Selector({
  eira,
})

function AI(myid)
  YggAI({
    root,
  }, myid)
end
