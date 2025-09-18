require('AI.USER_AI.config')
require('AI.USER_AI.UTIL.Const')
require('AI.USER_AI.UTIL')
require('AI.USER_AI.BT')
require('AI.USER_AI.BT.nodes')
local userCommands = require('AI.USER_AI.cmd')
local lif = require('AI.USER_AI.HOMUN.Lif')
local sera = require('AI.USER_AI.HOMUN.Sera')
local dieter = require('AI.USER_AI.HOMUN.Dieter')
local filir = require('AI.USER_AI.HOMUN.Filir')
local amistr = require('AI.USER_AI.HOMUN.Amistr')
local eira = require('AI.USER_AI.HOMUN.Eira')
local vanil = require('AI.USER_AI.HOMUN.Vanil')
local bayeri = require('AI.USER_AI.HOMUN.Bayeri')
local eleanor = require('AI.USER_AI.HOMUN.Eleanor')
local root = Selector({
  sera,
  dieter,
  eira,
  eleanor,
  bayeri,
  vanil,
  amistr,
  lif,
  filir,
})
function AI(myid)
  CurrentTime = GetTick() / 1000
  math.randomseed(CurrentTime)
  MyID = myid
  MyOwner = GetV(V_OWNER, myid)
  userCommands(root)
end
