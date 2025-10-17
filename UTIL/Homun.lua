local function root(combat)
  ---@type HomunNode
  local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
  ---@type CommandNode
  local commandNodes = require 'AI.USER_AI.BT.nodes.commands'
  ---@type EnemyNode
  local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'
  ---@type OwnerNode
  local ownerNodes = require 'AI.USER_AI.BT.nodes.owner'

  local normalCombat = Condition(
    Parallel {
      Delay(enemyNodes.sortEnemiesByDistance, 500),
      Condition(combat, enemyNodes.isAlive),
      Delay(enemyNodes.checkIsAttackingOwner, 300),
      Delay(homunNodes.checkHomunStuck, 3000),
      Delay(enemyNodes.searchForEnemies, 300),
      Delay(enemyNodes.clearDeadEnemies, 500),
    },
    enemyNodes.hasEnemy
  )

  local patrolWhenOwnerIsSitting = Condition(
    Parallel {
      homunNodes.patrol,
      Delay(enemyNodes.searchForEnemies, 300),
    },
    ownerNodes.isSitting
  )

  local goBackToUser = Condition(
    Parallel {
      homunNodes.follow,
      Delay(enemyNodes.searchForEnemies, 300),
    },
    ownerNodes.isNotMoving
  )

  local combatUnlessOwnerIsMovingAway = Unless(normalCombat, ownerNodes.isMovingAway)

  local userCommands = Selector {
    Condition(commandNodes.executeHold, commandNodes.isHoldMode),
    Condition(commandNodes.executeFollow, commandNodes.isFollowMode),
    Condition(commandNodes.executeMove, commandNodes.isMoveMode),
    Condition(commandNodes.executeStop, commandNodes.isStopMode),
    Condition(commandNodes.executePatrol, commandNodes.isPatrolMode),
    Condition(commandNodes.executeAttackObject, commandNodes.isAttackObject),
    Condition(commandNodes.executeAttackArea, commandNodes.isAttackArea),
    Condition(commandNodes.executeSkillObject, commandNodes.isSkillObject),
    Condition(commandNodes.executeSkillGround, commandNodes.isSkillGround),
  }

  local auto = Selector {
    combatUnlessOwnerIsMovingAway,
    Condition(
      Parallel {
        homunNodes.follow,
        Delay(enemyNodes.searchForEnemies, 300),
      },
      ownerNodes.isMoving
    ),
    Unless(
      Selector {
        patrolWhenOwnerIsSitting,
        goBackToUser,
      },
      enemyNodes.hasEnemy
    ),
  }

  return Selector {
    Condition(
      Sequence {
        commandNodes.processUserCommands,
        userCommands,
      },
      commandNodes.hasCommands
    ),
    Unless(auto, commandNodes.hasCommands),
  }
end

return root
