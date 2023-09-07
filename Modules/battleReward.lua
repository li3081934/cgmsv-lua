---模块类
local Module = ModuleBase:createModule('battleReward')

-- local frameItemOdds = {
--   [1] = 80000,
--   [2] = 80001,
--   [5] = 80002
-- }

local battleEnemyCache = {};

local rewardPool = {
  -- 声望物品
  {
    dropFilter = function (enemyAvgLevel)
      return true 
    end,
    reward = {
      [10] = { 80000 },
      [20] = { 80001 },
      [50] = { 80002 }
    }
  },
  {
    -- 2级装备池 20 - 29级敌人掉落
    dropFilter = function (enemyAvgLevel)
      return  enemyAvgLevel >= 20 and enemyAvgLevel < 29
    end,
    reward = {
      -- B装 斧 剑 枪 弓 杖 小刀 回旋镖 头盔 帽子 铠甲 衣服 长袍 靴子 鞋子 盾牌
      [10] = { 811, 18, 1613, 2017, 2418, 3213, 2815, 3607, 4010, 4411, 4813, 5211, 5612, 6011, 6412},
      -- A装
      [20] = { 812, 16, 1619, 2010, 2413, 3212, 2812, 3611, 4011, 4410, 4812, 5212, 5612, 6010, 6410},
    }
  }
}

local missedReward = {}
--- 加载模块钩子
function Module:onLoad()
  self:logInfo('load')
  self:regCallback('BattleOverEvent', Func.bind(self.battleOver, self))
  self:regCallback('BattleStartEvent', Func.bind(self.battleStart, self))
end


function Module:battleStart(battleIndex)
  local enemyTable = {
    indexArr = {},
    totalLevel = 0
  };
  for i = 10, 19 do
    local enemyIndex = Battle.GetPlayer(battleIndex, i);
    if(enemyIndex >= 0) then
      table.insert(enemyTable.indexArr, enemyIndex)
      enemyTable.totalLevel = enemyTable.totalLevel + Char.GetData(enemyIndex, CONST.对象_等级)
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
  
  local enemyData = battleEnemyCache[battleIndex]
  for i=0, 9 do
		local charIndex = Battle.GetPlayer(battleIndex, i);
		if(charIndex >= 0) then
			if Char.IsPlayer(charIndex) then
        local pickedItems = self:pickItem(math.ceil(enemyData.totalLevel / #enemyData.indexArr));
        for key, value in pairs(pickedItems) do
          self:giveItem(charIndex, value)
        end
			end
		end
	end
  battleEnemyCache[battleIndex] = nil;
end

function Module:pickItem(enemyAvgLevel)
  local picked = {};
  for i, pool in pairs(rewardPool) do
    if pool.dropFilter(enemyAvgLevel) then
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
    local charMissedItems = missedReward[charIndex];
    if charMissedItems then
      table.insert(charMissedItems, itemId)
    else
      missedReward[charIndex] = { itemId }
    end
    NLG.SystemMessage(charIndex, "[系统] 背包已满 请找失物招领员找回战斗奖励！");
    return;
  end
  local itemIndex = Char.GiveItem(charIndex, itemId, 1)
  if itemIndex >= 0 then
    -- NLG.SystemMessage(charIndex, "[系统] 获得了声望道具" .. Item.GetData(itemIndex, CONST.道具_已鉴定名));
  end
  
  
end
--- 卸载模块钩子
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
