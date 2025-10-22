local function root(combat)
  ---@type HomunNode
  local homunNodes = require 'AI.USER_AI.BT.nodes.homun'
  ---@type CommandNode
  local commandNodes = require 'AI.USER_AI.BT.nodes.commands'
  ---@type EnemyNode
  local enemyNodes = require 'AI.USER_AI.BT.nodes.enemy'
  ---@type OwnerNode
  local ownerNodes = require 'AI.USER_AI.BT.nodes.owner'

  local fightEnemy = Condition(
    Parallel {
      Condition(combat, enemyNodes.isAlive),
      Delay(homunNodes.checkHomunStuck, 500),
    },
    enemyNodes.hasEnemy
  )

  local patrolWhenOwnerIsSitting = Condition(homunNodes.patrol, ownerNodes.isSitting)

  local stayBesideOwner = Condition(homunNodes.follow, ownerNodes.isNotMoving)

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
    Unless(fightEnemy, ownerNodes.isMovingAway),
    Condition(homunNodes.follow, ownerNodes.isMoving),
    Unless(
      Selector {
        patrolWhenOwnerIsSitting,
        stayBesideOwner,
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
