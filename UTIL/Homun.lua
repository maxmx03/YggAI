local function root(combat)
  ---@type EnemyCondition
  local enemyConditions = require('AI.USER_AI.BT.conditions.enemy')
  ---@type OwnerCondition
  local ownerConditions = require('AI.USER_AI.BT.conditions.owner')
  ---@type HomunNode
  local homunNodes = require('AI.USER_AI.BT.nodes.homun')
  ---@type EnemyNode
  local enemyNodes = require('AI.USER_AI.BT.nodes.enemy')
  ---@type CommandNode
  local commandNodes = require('AI.USER_AI.BT.nodes.commands')

  local normalCombat = Condition(
    Parallel({
      combat,
      Delay(homunNodes.checkHomunStuck, 2000),
      Delay(enemyNodes.checkIsAttackingOwner, 300),
      Delay(enemyNodes.searchForEnemies, 300),
    }),
    enemyConditions.hasEnemy
  )

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

  local combatUnlessOwnerIsMovingAway = Unless(normalCombat, ownerConditions.isMovingAway)

  local userCommands = Selector({
    Condition(commandNodes.executeHold, commandNodes.isHoldMode),
    Condition(commandNodes.executeFollow, commandNodes.isFollowMode),
    Condition(commandNodes.executeMove, commandNodes.isMoveMode),
    Condition(commandNodes.executeStop, commandNodes.isStopMode),
    Condition(commandNodes.executePatrol, commandNodes.isPatrolMode),
    Condition(commandNodes.executeAttackObject, commandNodes.isAttackObject),
    Condition(commandNodes.executeAttackArea, commandNodes.isAttackArea),
    Condition(commandNodes.executeSkillObject, commandNodes.isSkillObject),
    Condition(commandNodes.executeSkillGround, commandNodes.isSkillGround),
  })

  local auto = Selector({
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

  return Sequence({
    commandNodes.processUserCommands,
    Selector({
      Unless(userCommands, commandNodes.hasCommands),
      Condition(auto, commandNodes.isIdleMode),
    }),
  })
end

return root
