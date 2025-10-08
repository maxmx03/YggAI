local function root(combat)
  local enemyConditions = require('AI.USER_AI.BT.conditions.enemy')
  local ownerConditions = require('AI.USER_AI.BT.conditions.owner')
  local homunNodes = require('AI.USER_AI.BT.nodes.homun')
  local enemyNodes = require('AI.USER_AI.BT.nodes.enemy')
  local commandNodes = require('AI.USER_AI.BT.nodes.commands')

  local normalCombat = Condition(
    Parallel({
      combat,
      Delay(homunNodes.checkHomunStuck, 1000),
      Delay(enemyNodes.checkIsAttackingOwner, 300),
      Delay(enemyNodes.searchForEnemies, 300),
    }),
    enemyConditions.hasEnemy
  )

  local combatUnlessOwnerIsMovingAway = Unless(normalCombat, ownerConditions.isMovingAway)

  return Sequence({
    commandNodes.processUserCommands(),

    Selector({
      Condition(commandNodes.executeHold(), commandNodes.isHoldMode),
      Condition(commandNodes.executeFollow(), commandNodes.isFollowMode),
      Condition(commandNodes.executeMove(), commandNodes.isMoveMode),
      Condition(
        Parallel({
          commandNodes.executePatrol(),
          Delay(enemyNodes.searchForEnemies, 300),
        }),
        commandNodes.isPatrolMode
      ),
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
          Condition(homunNodes.patrol, ownerConditions.isSitting),
          homunNodes.follow,
        }),
        enemyConditions.hasEnemy
      ),
    }),
  })
end

return root
