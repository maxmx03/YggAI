require('AI.USER_AI.config')
require('AI.USER_AI.UTIL.Const')
require('AI.USER_AI.UTIL')
require('AI.USER_AI.BT')
require('AI.USER_AI.BT.nodes')
local vanilmirth = require('AI.USER_AI.HOMUN.Vanil')
local amistr = require('AI.USER_AI.HOMUN.Amistr')
local eleanor = require('AI.USER_AI.HOMUN.Eleanor')

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
    CheckEnemyIsDead,
    CheckOwnerToofar,
  }),
})

function AI(myid)
  CurrentTime = GetTick() / 1000
  MyID = myid
  MyOwner = GetV(V_OWNER, myid)
  if IsVanilmirth(myid) then
    root = Selector({
      vanilmirth,
      idle,
    })
  elseif IsAmistr(myid) then
    root = Selector({
      amistr,
      idle,
    })
  elseif IsEleaner(myid) then
    root = Selector({
      eleanor,
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
