---@class UserConfig
local myConfig = {
  homunLevel = 999,
  lifUseHeal = false,
  maxEnemiesToSearch = 15,
  followDistance = 3,
  patrolDistance = 7,
  maxDistanceToOwner = 7,
  myEnemies = { -- Eden, Farm or Leveling
    -- Audumbla Grassland, Rachel
    -- [1782] = true, -- Roween
    -- [1106] = true, -- Desert Wolf
    -- [1627] = true, -- Anopheles
    -- [1259] = true, -- Gryphon
  },
  avoid = {
    [1080] = true, -- Green Plant
    [1081] = true, -- Yellow Plant
    [1078] = true, -- Red Plant
    [1079] = true, -- Blue Plant
    [1082] = true, -- White Plant
    [1083] = true, -- Shining Plant
    [1182] = true, -- Mushroom
    [1084] = true, -- Black Mushroom
    [1085] = true, -- Red Mushroom
    [3755] = true, -- Neon Mushroom
    [2331] = true, -- Seaweed
    [2329] = true, -- Buwaya Egg
    [2090] = true, -- Antler Scaraba Egg
    [2088] = true, -- Uni-horn Scaraba Egg
    [2089] = true, -- Horn Scaraba Egg
    [2091] = true, -- Rake Horn Scaraba Egg
    [2167] = true, -- Gold Horn Scaraba Egg
    [2169] = true, -- Gold Rake Horn Scaraba Egg
    [2168] = true, -- Gold Antler Scaraba Egg
    [2166] = true, -- Gold Uni-horn Scaraba Egg
    [2014] = true, -- Draco Egg
    [1721] = true, -- Dragon Egg
    [1789] = true, -- ICEICLE
    [1961] = true, -- Thorn of Purification
    [1960] = true, -- Thorn of Magic
    [1959] = true, -- Thorn of Recovery
    [1958] = true, -- Thorny Skeleton
    [2695] = true, -- E_GARLING (Halloween)
    [1926] = true, -- JAKK_H (Halloween)
    [2160] = true, -- S_LUCIOLA_VESPA (Sera)
    [2159] = true, -- S_GIANT_HORNET (Sera)
    [2158] = true, -- S_HORNET (Sera)
    [3028] = true, -- Sonia
    [3061] = true, -- E_ANGRY_MIMIC
    [3026] = true, -- FIREPIT
    [3159] = true, -- ILLEGAL_PROMOTION
    [3795] = true, -- ILL_ICEICLE
  },
}

return myConfig
