---ģ����
local Module = ModuleBase:createModule('framItem')
local frameItems = {
  [80000] = { value = 1000 },
  [80001] = { value = 500 },
  [80002] = { value = 200 },
}
local frameItemOdds = {
  [1] = 80000,
  [2] = 80001,
  [5] = 80002
}
--- ����ģ�鹳��
function Module:onLoad()
  onLineChar = {};
  self:logInfo('load')
  self:regCallback('ItemString', Func.bind(self.itemUse, self), 'LUA_useBT');
  self:regCallback('BattleOverEvent', Func.bind(self.battleOver, self))
end

function Module:itemUse(charIndex, toIndex, slot)
  local itemIndex = Char.GetItemIndex(charIndex, slot);
	local itemId = Item.GetData(itemIndex, CONST.����_��);
  local itemValue = frameItems[itemId].value;
  Char.SetData(charIndex, CONST.CHAR_����, Char.GetData(charIndex, CONST.����_����) + itemValue);
  Char.DelItem(charIndex, Item.GetData(itemIndex, CONST.����_ID), 1);
  NLG.SystemMessage(charIndex, "[ϵͳ] ������������" .. itemValue);
end

function Module:battleOver(battleIndex)
  for i=0, 9 do
		local charIndex = Battle.GetPlayer(battleIndex, i);
		if(charIndex >= 0) then
			if Char.IsPlayer(charIndex) then
        local rand = NLG.Rand(1, 100)
        for key, value in pairs(frameItemOdds) do
          if rand <= key then
              giveItem(charIndex, value);
            break
          end
        end
			end
		end
	end
end

function giveItem(charIndex, itemId)
  local leftSolt = Char.ItemSlot(charIndex);
  if leftSolt <= 0 then
    NLG.SystemMessage(charIndex, "[ϵͳ] �������� �޷�����������ߣ�");
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
