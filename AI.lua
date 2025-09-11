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
    CheckOwnerToofar,
    CheckOwnerIsSitting,
    PatrolNode,
  }),
})
local defaultCombatNode = Sequence({
  CheckIfHasEnemy,
  Parallel({
    ChaseEnemyNode,
    BasicAttackNode,
    CheckEnemyIsOutOfSight,
    CheckEnemyIsAlive,
    CheckOwnerToofar,
  }),
})

function AI(myid)
  CurrentTime = GetTick() / 1000
  MyID = myid
  MyOwner = GetV(V_OWNER, myid)
  if IsDieter(myid) then
    root = Selector({
      dieter,
      idle,
    })
  elseif IsEira(myid) then
    root = Selector({
      eira,
      idle,
    })
  elseif IsEleanor(myid) then
    root = Selector({
      eleanor,
      idle,
    })
  elseif IsVanilmirth(myid) then
    root = Selector({
      vanilmirth,
      idle,
    })
  elseif IsAmistr(myid) then
    root = Selector({
      amistr,
      idle,
    })
  elseif IsLif(myid) then
    root = Selector({
      lif,
      idle,
    })
  elseif IsFilir(myid) then
    root = Selector({
      filir,
      idle,
    })
  else
    root = Selector({
      defaultCombatNode,
      idle,
    })
  end
  root()
end
