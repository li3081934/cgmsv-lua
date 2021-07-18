---@class ItemExt:ModuleBase
local ItemExt = ModuleBase:createModule('itemExt')
local MAX_CACHE_SIZE = 1000;

ItemExt:addMigration(1, 'add item_LuaData', function()
  SQL.querySQL([[create table if not exists lua_itemData
(
    id varchar(50) not null
        primary key,
    data text null
) engine innodb;
]])
end);
ItemExt:addMigration(2, 'add item_LuaData_create_time', function()
  SQL.querySQL([[alter table lua_itemData add create_time int default 0 not null;]])
end);

---@param itemIndex number
---@param value table
function ItemExt:setItemData(itemIndex, value)
  local type = Item.GetData(itemIndex, CONST.����_����)
  local field = CONST.����_���ò���;
  if type >= 0 and type <= 21 then
    field = CONST.����_���ò���;
  else
    field = CONST.����_Func_AttachFunc;
  end
  local args = Item.GetData(itemIndex, field) or ''
  if not string.match(args, '^luaData_') then
    local t = string.formatNumber(os.time(), 36) .. string.formatNumber(math.random(1, 36 * 36 * 36), 36);
    args = 'luaData_' .. t;
    Item.SetData(itemIndex, field, args);
  end
  local sql = 'replace into lua_itemData (id, data, create_time) VALUES ('
    .. SQL.sqlValue(args) .. ','
    .. SQL.sqlValue(JSON.encode(value)) .. ','
    .. SQL.sqlValue(os.time()) .. ')';
  local r = SQL.querySQL(sql)
  --print(r, sql);
  self.cache.set(args, value);
end

---@return table
function ItemExt:getItemData(itemIndex)
  local args = Item.GetData(itemIndex, CONST.����_���ò���)
  if string.match(args, '^luaData_') then
    local data = self.cache.get(args)
    if not data then
      data = SQL.querySQL('select data from lua_itemdata where id = ' .. SQL.sqlValue(args))
      if type(data) == 'table' and data[1] then
        data = data[1][1]
        data = JSON.decode(data)
        self.cache.set(args, data);
        return data;
      end
    end
  end
  return { };
end
--- ����ģ�鹳��
function ItemExt:onLoad()
  self:logInfo('load')
  self.cache = LRU.new(MAX_CACHE_SIZE);
end

--- ж��ģ�鹳��
function ItemExt:onUnload()
  self:logInfo('unload')
end

return ItemExt;