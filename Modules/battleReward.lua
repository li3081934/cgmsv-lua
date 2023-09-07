---ģ����
local Module = ModuleBase:createModule('battleReward')

-- local frameItemOdds = {
--   [1] = 80000,
--   [2] = 80001,
--   [5] = 80002
-- }

local battleEnemyCache = {};

local rewardPool = {
  -- ������Ʒ
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
    -- 2��װ���� 20 - 29�����˵���
    dropFilter = function (enemyAvgLevel)
      return  enemyAvgLevel >= 20 and enemyAvgLevel < 29
    end,
    reward = {
      -- Bװ �� �� ǹ �� �� С�� ������ ͷ�� ñ�� ���� �·� ���� ѥ�� Ь�� ����
      [10] = { 811, 18, 1613, 2017, 2418, 3213, 2815, 3607, 4010, 4411, 4813, 5211, 5612, 6011, 6412},
      -- Aװ
      [20] = { 812, 16, 1619, 2010, 2413, 3212, 2812, 3611, 4011, 4410, 4812, 5212, 5612, 6010, 6410},
    }
  }
}

local missedReward = {}
--- ����ģ�鹳��
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
      enemyTable.totalLevel = enemyTable.totalLevel + Char.GetData(enemyIndex, CONST.����_�ȼ�)
    end
  end
  battleEnemyCache[battleIndex] = enemyTable;
end

function Module:battleOver(battleIndex)
  if Battle.GetType(battleIndex) ~= CONST.ս��_��ͨ then
    battleEnemyCache[battleIndex] = nil;
    self:logDebug('ս�����Ͳ�����ͨ')
    return
  end
  if Battle.GetWinSide(battleIndex) ~= 0 then
    battleEnemyCache[battleIndex] = nil;
    self:logDebug('��ͨս��ûʤ��')
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
    NLG.SystemMessage(charIndex, "[ϵͳ] �������� ����ʧ������Ա�һ�ս��������");
    return;
  end
  local itemIndex = Char.GiveItem(charIndex, itemId, 1)
  if itemIndex >= 0 then
    -- NLG.SystemMessage(charIndex, "[ϵͳ] �������������" .. Item.GetData(itemIndex, CONST.����_�Ѽ�����));
  end
  
  
end
--- ж��ģ�鹳��
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
