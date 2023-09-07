---ģ����
local Module = ModuleBase:createModule('framItem')
local frameItems = {
  [80000] = { value = 500 },
  [80001] = { value = 200 },
  [80002] = { value = 100 },
}
--- ����ģ�鹳��
function Module:onLoad()
  self:logInfo('load')
  self:regCallback('ItemString', Func.bind(self.itemUse, self), 'LUA_useFramItem');
end

function Module:itemUse(charIndex, toIndex, slot)
  local itemIndex = Char.GetItemIndex(charIndex, slot);
	local itemId = Item.GetData(itemIndex, CONST.����_��);
  local itemValue = frameItems[itemId].value;
  Char.SetData(charIndex, CONST.CHAR_����, Char.GetData(charIndex, CONST.����_����) + itemValue);
  Char.DelItem(charIndex, Item.GetData(itemIndex, CONST.����_ID), 1);
  NLG.SystemMessage(charIndex, "[ϵͳ] ������������" .. itemValue);
end

--- ж��ģ�鹳��
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
