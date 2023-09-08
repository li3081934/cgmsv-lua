---模块类
local Module = ModuleBase:createModule('battleReward')
local battleEnemyCache = {};
local rewardPool = {
  -- 声望物品
  {
    dropFilter = function (enemy)
      return true 
    end,
    reward = {
      [10] = { 80000 },
      [15] = { 80001 },
      [20] = { 80002 }
    }
  },
  {
    -- 2级装备池 20 - 29级敌人掉落
    dropFilter = function (enemy)
      return  enemy.level >= 20 and enemy.level < 29
    end,
    reward = {
      -- B装 斧 剑 枪 弓 杖 小刀 回旋镖 头盔 帽子 铠甲 衣服 长袍 靴子 鞋子 盾牌
      [10] = { 811, 18, 1613, 2017, 2418, 3213, 2815, 3607, 4010, 4411, 4813, 5211, 5612, 6011, 6412},
      -- A装
      [20] = { 812, 16, 1619, 2010, 2413, 3212, 2812, 3611, 4011, 4410, 4812, 5212, 5612, 6010, 6410},
    }
  },
  {
    -- 2级装备池 20 - 29级敌人药品
    dropFilter = function (enemy)
      return  enemy.level >= 20 and enemy.level < 29
    end,
    reward = {
      [10] = { 15202, 15203, 15304, 15607, 18757 },
    }
  },
  {
    -- 3级装备池 30 - 39级敌人掉落装备
    dropFilter = function (enemy)
      return  enemy.level >= 30 and enemy.level < 39
    end,
    reward = {
      [10] = { 22, 28, 820, 826, 1625, 1629, 2022, 2023, 2434, 2435, 2820, 2823, 3222, 3229, 3620, 3622, 4020, 4022, 4420, 4421, 4821, 4823, 5223, 5224, 5620, 5621, 6022, 6025, 6425, 6427
    },
    }
  }, 
   {
    -- 3级装备池 30 - 39级敌人掉落药品
    dropFilter = function (enemy)
      return  enemy.level >= 30 and enemy.level < 39
    end,
    reward = {
      [10] = { 15204, 15206, 15608},
    }
  },
  {
    -- 4级装备池 40 - 49级敌人掉落装备
    dropFilter = function (enemy)
      return  enemy.level >= 40 and enemy.level < 49
    end,
    reward = {
      [10] = { 37, 39, 830, 838, 1634, 1635, 2035, 2038, 2446, 2447, 2832, 2834, 3230, 3235, 3632, 3635, 4031, 4032, 4430, 4434, 4833, 4834, 5231, 5233, 5630, 5631, 6031, 6033, 6434, 6437, 18803
    },
    }
  },
  {
    -- 4级装备池 40 - 49级敌人掉落药品
    dropFilter = function (enemy)
      return  enemy.level >= 40 and enemy.level < 49
    end,
    reward = {
      [10] = { 15207, 15208, 15301, 15609, 18637, 18971 },
    }
  }
}
Module.restoreNpc = nil;
local missedRewardTable = {}
--- 加载模块钩子
function Module:onLoad()
  self:logInfo('load')
  self:regCallback('BattleOverEvent', Func.bind(self.battleOver, self))
  self:regCallback('BattleStartEvent', Func.bind(self.battleStart, self))
  self.restoreNpc = self:NPC_createNormal('失物招领员', 98972, { x = 240, y = 83, mapType = 0, map = 1000, direction = 6 });
  self:NPC_regTalkedEvent(self.restoreNpc, function(npc, player)
    if (NLG.CanTalk(npc, player)) then
      local cdk = Char.GetData(player, CONST.对象_CDK)
      local missed = missedRewardTable[cdk]
      local msg = "\\n@c【失物招领】\\n\\n";
      if missed then
        msg = msg .. '你有' .. #missed .. '个遗失物品，是否领取？'
      else
        msg = msg .. '你没有遗失物品'
      end
      local btn = CONST.按钮_关闭;
      if missed then
        btn = CONST.按钮_是否
      end
      NLG.ShowWindowTalked(player, self.restoreNpc, CONST.窗口_信息框, btn, 1, msg);
    end
  end)

  self:NPC_regWindowTalkedEvent(self.restoreNpc, function(npc, charIndex, _seqno, _select, _data)
    local seqno = tonumber(_seqno)
    local selected = tonumber(_select)
    if seqno ~= 1 then
      return
    end
    if (selected == CONST.按钮_是) then
      local cdk = Char.GetData(charIndex, CONST.对象_CDK);
      local missed = missedRewardTable[cdk];
      local res = self:giveItem(charIndex, missed[1])
      if res then
        table.remove(missed, 1)
        if #missed == 0 then
          missedRewardTable[cdk] = nil
        end
      else
        NLG.SystemMessage(charIndex, "[系统] 背包已满 请整理背包");
      end
    end
  end)
end


function Module:battleStart(battleIndex)
  local enemyTable = {};
  for i = 10, 19 do
    local enemyIndex = Battle.GetPlayer(battleIndex, i);
    if(enemyIndex >= 0) then
      table.insert(enemyTable, {
        Index = enemyIndex,
        level = Char.GetData(enemyIndex, CONST.对象_等级)
      })
    end
  end
  battleEnemyCache[battleIndex] = enemyTable;
end

function Module:battleOver(battleIndex)
  if Battle.GetType(battleIndex) ~= CONST.战斗_普通 then
    battleEnemyCache[battleIndex] = nil;
    self:logDebug('战斗类型不是普通')
    return
  end
  if Battle.GetWinSide(battleIndex) ~= 0 then
    battleEnemyCache[battleIndex] = nil;
    self:logDebug('普通战斗没胜利')
    return
  end
  local playerTable = {}
  for i=0, 9 do
  local charIndex = Battle.GetPlayer(battleIndex, i);
    if(charIndex >= 0) and Char.IsPlayer(charIndex) then
      table.insert(playerTable, charIndex)
    end
  end

  local enemyData = battleEnemyCache[battleIndex];
  for _, enemy in pairs(enemyData) do
    local rewards = self:pickItem(enemy);
    for _, itemId in pairs(rewards) do
      local randPlayerIndex = NLG.Rand(1, #playerTable);
      local targetChar = playerTable[randPlayerIndex]
      local res = self:giveItem(targetChar, itemId)
      if not res then
        NLG.SystemMessage(targetChar, "[系统] 背包已满 请找失物招领员找回战斗奖励！");
        local cdk = Char.GetData(targetChar, CONST.对象_CDK)
        local charMissedItems = missedRewardTable[cdk];
        if charMissedItems then
          table.insert(charMissedItems, itemId)
        else
          missedRewardTable[cdk] = { itemId }
        end
      end
    end
  end
  battleEnemyCache[battleIndex] = nil;
end

function Module:pickItem(enemy)
  local picked = {};
  for i, pool in pairs(rewardPool) do
    if pool.dropFilter(enemy) then
      local rand = NLG.Rand(1, 1000);
      for odds, items in pairs(pool.reward) do
        if rand <= odds then
          local randItemIndex = NLG.Rand(1, #items);
            table.insert(picked, items[randItemIndex])
          break
        end
      end
    end
  end
  return picked;
end


function Module:giveItem(charIndex, itemId)
  local leftSolt = Char.ItemSlot(charIndex);
  if leftSolt >= 20 then
    return false;
  end
  local itemIndex = Char.GiveItem(charIndex, itemId, 1)
  return itemIndex >= 0
end
--- 卸载模块钩子
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
