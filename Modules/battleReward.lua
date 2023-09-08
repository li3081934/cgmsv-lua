---ģ����
local Module = ModuleBase:createModule('battleReward')
local battleEnemyCache = {};
local rewardPool = {
  -- ������Ʒ
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
    -- 2��װ���� 20 - 29�����˵���
    dropFilter = function (enemy)
      return  enemy.level >= 20 and enemy.level < 29
    end,
    reward = {
      -- Bװ �� �� ǹ �� �� С�� ������ ͷ�� ñ�� ���� �·� ���� ѥ�� Ь�� ����
      [10] = { 811, 18, 1613, 2017, 2418, 3213, 2815, 3607, 4010, 4411, 4813, 5211, 5612, 6011, 6412},
      -- Aװ
      [20] = { 812, 16, 1619, 2010, 2413, 3212, 2812, 3611, 4011, 4410, 4812, 5212, 5612, 6010, 6410},
    }
  },
  {
    -- 2��װ���� 20 - 29������ҩƷ
    dropFilter = function (enemy)
      return  enemy.level >= 20 and enemy.level < 29
    end,
    reward = {
      [10] = { 15202, 15203, 15304, 15607, 18757 },
    }
  },
  {
    -- 3��װ���� 30 - 39�����˵���װ��
    dropFilter = function (enemy)
      return  enemy.level >= 30 and enemy.level < 39
    end,
    reward = {
      [10] = { 22, 28, 820, 826, 1625, 1629, 2022, 2023, 2434, 2435, 2820, 2823, 3222, 3229, 3620, 3622, 4020, 4022, 4420, 4421, 4821, 4823, 5223, 5224, 5620, 5621, 6022, 6025, 6425, 6427
    },
    }
  }, 
   {
    -- 3��װ���� 30 - 39�����˵���ҩƷ
    dropFilter = function (enemy)
      return  enemy.level >= 30 and enemy.level < 39
    end,
    reward = {
      [10] = { 15204, 15206, 15608},
    }
  },
  {
    -- 4��װ���� 40 - 49�����˵���װ��
    dropFilter = function (enemy)
      return  enemy.level >= 40 and enemy.level < 49
    end,
    reward = {
      [10] = { 37, 39, 830, 838, 1634, 1635, 2035, 2038, 2446, 2447, 2832, 2834, 3230, 3235, 3632, 3635, 4031, 4032, 4430, 4434, 4833, 4834, 5231, 5233, 5630, 5631, 6031, 6033, 6434, 6437, 18803
    },
    }
  },
  {
    -- 4��װ���� 40 - 49�����˵���ҩƷ
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
--- ����ģ�鹳��
function Module:onLoad()
  self:logInfo('load')
  self:regCallback('BattleOverEvent', Func.bind(self.battleOver, self))
  self:regCallback('BattleStartEvent', Func.bind(self.battleStart, self))
  self.restoreNpc = self:NPC_createNormal('ʧ������Ա', 98972, { x = 240, y = 83, mapType = 0, map = 1000, direction = 6 });
  self:NPC_regTalkedEvent(self.restoreNpc, function(npc, player)
    if (NLG.CanTalk(npc, player)) then
      local cdk = Char.GetData(player, CONST.����_CDK)
      local missed = missedRewardTable[cdk]
      local msg = "\\n@c��ʧ�����졿\\n\\n";
      if missed then
        msg = msg .. '����' .. #missed .. '����ʧ��Ʒ���Ƿ���ȡ��'
      else
        msg = msg .. '��û����ʧ��Ʒ'
      end
      local btn = CONST.��ť_�ر�;
      if missed then
        btn = CONST.��ť_�Ƿ�
      end
      NLG.ShowWindowTalked(player, self.restoreNpc, CONST.����_��Ϣ��, btn, 1, msg);
    end
  end)

  self:NPC_regWindowTalkedEvent(self.restoreNpc, function(npc, charIndex, _seqno, _select, _data)
    local seqno = tonumber(_seqno)
    local selected = tonumber(_select)
    if seqno ~= 1 then
      return
    end
    if (selected == CONST.��ť_��) then
      local cdk = Char.GetData(charIndex, CONST.����_CDK);
      local missed = missedRewardTable[cdk];
      local res = self:giveItem(charIndex, missed[1])
      if res then
        table.remove(missed, 1)
        if #missed == 0 then
          missedRewardTable[cdk] = nil
        end
      else
        NLG.SystemMessage(charIndex, "[ϵͳ] �������� ��������");
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
        level = Char.GetData(enemyIndex, CONST.����_�ȼ�)
      })
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
        NLG.SystemMessage(targetChar, "[ϵͳ] �������� ����ʧ������Ա�һ�ս��������");
        local cdk = Char.GetData(targetChar, CONST.����_CDK)
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
--- ж��ģ�鹳��
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
