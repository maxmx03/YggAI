require('AI.USER_AI.config')
require('AI.USER_AI.UTIL.Const')
require('AI.USER_AI.UTIL')
require('AI.USER_AI.BT')
require('AI.USER_AI.BT.nodes')
local vanilmirth = require('AI.USER_AI.HOMUN.Vanil')
local amistr = require('AI.USER_AI.HOMUN.Amistr')
local eleanor = require('AI.USER_AI.HOMUN.Eleanor')
local lif = require('AI.USER_AI.HOMUN.Lif')
local filir = require('AI.USER_AI.HOMUN.Filir')
local dieter = require('AI.USER_AI.HOMUN.Dieter')
local eira = require('AI.USER_AI.HOMUN.Eira')
local root = nil
local idle = Selector({
  Sequence({
    CheckOwnerDistance,
    CheckOwnerOutOfSight,
    FollowNode,
  }),
  Sequence({
    Reverse(CheckIfHasEnemy),
    CheckOwnerToofar,
    CheckOwnerIsSitting,
    PatrolNode,
  }),
})
root = Selector({
  Sequence({
    CheckIsDieter,
    Selector({
      dieter,
      idle,
    }),
  }),
  Sequence({
    CheckIsEira,
    Selector({
      eira,
      idle,
    }),
  }),
  Sequence({
    CheckIsEleanor,
    Selector({
      eleanor,
      idle,
    }),
  }),
  Sequence({
    CheckIsVanilmirth,
    Selector({
      vanilmirth,
      idle,
    }),
  }),
  Sequence({
    CheckIsAmistr,
    Selector({
      amistr,
      idle,
    }),
  }),
  Sequence({
    CheckIsLif,
    Selector({
      lif,
      idle,
    }),
  }),
  Sequence({
    CheckIsFilir,
    Selector({
      filir,
      idle,
    }),
  }),
})

function AI(myid)
  CurrentTime = GetTick() / 1000
  math.randomseed(CurrentTime)
  MyID = myid
  MyOwner = GetV(V_OWNER, myid)
  root()
end
