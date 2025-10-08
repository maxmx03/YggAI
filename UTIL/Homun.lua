local function root(combat)
  ---@type EnemyCondition
  local enemyConditions = require('AI.USER_AI.BT.conditions.enemy')
  ---@type OwnerCondition
  local ownerConditions = require('AI.USER_AI.BT.conditions.owner')
  ---@type HomunNode
  local homunNodes = require('AI.USER_AI.BT.nodes.homun')
  ---@type EnemyNode
  local enemyNodes = require('AI.USER_AI.BT.nodes.enemy')

  local patrolWhenOwnerIsSitting = Condition(
    Parallel({
      homunNodes.patrol,
      Delay(enemyNodes.searchForEnemies, 300),
    }),
    ownerConditions.isSitting
  )
  local goBackToUser = Condition(
    Parallel({
      homunNodes.follow,
      Delay(enemyNodes.searchForEnemies, 300),
    }),
    ownerConditions.isNotMoving
  )

  local combatWhenHasEnemy = Condition(
    Parallel({
      combat,
      Delay(homunNodes.checkHomunStuck, 1000),
      Delay(enemyNodes.checkIsAttackingOwner, 300),
      Delay(enemyNodes.searchForEnemies, 300),
    }),
    enemyConditions.hasEnemy
  )
  local combatUnlessOwnerIsMovingAway = Unless(combatWhenHasEnemy, ownerConditions.isMovingAway)

  return Selector({
    combatUnlessOwnerIsMovingAway,
    Condition(
      Parallel({
        homunNodes.follow,
        Delay(enemyNodes.searchForEnemies, 300),
      }),
      ownerConditions.isMoving
    ),
    Unless(
      Selector({
        patrolWhenOwnerIsSitting,
        goBackToUser,
      }),
      enemyConditions.hasEnemy
    ),
  })
end

return root
