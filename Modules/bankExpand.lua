---模块类
local BankExpand = ModuleBase:createModule('bankExpand')

--- 加载模块钩子
function BankExpand:onLoad()
  self:logInfo('load')
  self:regCallback('ProtocolOnRecv', Func.bind(self.onProtoHook, self), 'rh');
end

--- 卸载模块钩子
function BankExpand:onUnload()
  self:logInfo('unload')
end

function BankExpand:onProtoHook(fd, head, data)
  --self:logDebug(fd, head, data, data[1]);
  data = tonumber(data[1]);
  local charIndex = Protocol.GetCharIndexFromFd(fd);
  local bIndex = Char.GetExtData(charIndex, "bank-index") or 1;
  if bIndex == data then
    return ;
  end
  Char.SetExtData(charIndex, "bank-index", data);
  --self:setData(charIndex, "index", data);
  for i = 0, 19 do
    local itemIndex = Char.GetPoolItem(charIndex, i);
    if itemIndex >= 0 then
      Char.SetExtData(charIndex, string.format("bank-%d-%d", bIndex, i), self:readItemData(itemIndex));
      Char.RemovePoolItem(charIndex, i);
    else
      Char.SetExtData(charIndex, string.format("bank-%d-%d", bIndex, i), nil);
    end
    local itemData = Char.GetExtData(charIndex, string.format("bank-%d-%d", data, i));
    pcall(function()
      if itemData then
        itemData = JSON.decode(itemData);
      end
    end)
    Char.SetExtData(charIndex, string.format("bank-%d-%d", data, i), nil);
    if type(itemData) == 'table' then
      local itemId = itemData['0'];
      if itemId <= 0 then
        itemId = 0;
      end
      itemIndex = Item.MakeItem(0);
      if itemIndex >= 0 then
        self:setItemData(itemIndex, itemData);
        local ret = Char.SetPoolItem(charIndex, i, itemIndex);
        if ret < 0 then
          self:logError('Char.SetPoolItem error: ', charIndex, i, itemIndex, ret);
        end
      end
    end
  end
  NLG.OpenBank(charIndex, charIndex);
end

local itemFields = { }
for i = 0, 0x4b do
  table.insert(itemFields, i);
end
for i = 0, 0xd do
  table.insert(itemFields, i + 2000);
end

function BankExpand:readItemData(itemIndex)
  local itemData = {}
  if itemIndex >= 0 then
    itemData = {};
    for _, v in pairs(itemFields) do
      itemData[tostring(v)] = Item.GetData(itemIndex, v);
    end
  else
    itemData = 0;
  end
  return itemData;
end

function BankExpand:setItemData(itemIndex, itemData)
  if itemIndex >= 0 then
    for _, v in pairs(itemFields) do
      if type(itemData[tostring(v)]) ~= 'nil' then
        Item.SetData(itemIndex, v, itemData[tostring(v)]);
      end
    end
  end
end

return BankExpand;
