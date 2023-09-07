---模块类
local Module = ModuleBase:createModule('framItem')
local frameItems = {
  [80000] = { value = 500 },
  [80001] = { value = 200 },
  [80002] = { value = 100 },
}
--- 加载模块钩子
function Module:onLoad()
  self:logInfo('load')
  self:regCallback('ItemString', Func.bind(self.itemUse, self), 'LUA_useFramItem');
end

function Module:itemUse(charIndex, toIndex, slot)
  local itemIndex = Char.GetItemIndex(charIndex, slot);
	local itemId = Item.GetData(itemIndex, CONST.道具_序);
  local itemValue = frameItems[itemId].value;
  Char.SetData(charIndex, CONST.CHAR_声望, Char.GetData(charIndex, CONST.对象_声望) + itemValue);
  Char.DelItem(charIndex, Item.GetData(itemIndex, CONST.道具_ID), 1);
  NLG.SystemMessage(charIndex, "[系统] 您声望增加了" .. itemValue);
end

--- 卸载模块钩子
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
