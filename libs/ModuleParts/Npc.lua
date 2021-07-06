---@module NPCPart:ModuleBase
---@field npcList number[]
local Part = ModuleBase:createPart('NpcPart');

local function fillShopSellType(tb)
  local all = tb == 'all';
  local ret = {}
  for i = 1, 48 do
    if all or tb[i - 1] then
      table.insert(ret, '1');
    else
      table.insert(ret, '0');
    end
  end
  return ret;
end

---@param name string
---@param image number
---@param positionInfo {x:number,y:number,map:number,mapType:number,direction:number}
---@param shopBaseInfo {buyRate:number,sellRate:number,shopType:number,msgBuySell:number,msgBuy:number,msgMoneyNotEnough:number,msgBagFull:number,msgSell:number,msgAfterSell:number,sellTypes:table|'all'}
function Part:NPC_createShop(name, image, positionInfo, shopBaseInfo, items)
  local shopNpcPrefix = table.join({
    shopBaseInfo.buyRate or 100,
    shopBaseInfo.sellRate or 100,
    shopBaseInfo.shopType or CONST.SHOP_TYPE_BOTH,
    shopBaseInfo.msgBuySell or '10146',
    shopBaseInfo.msgBuy or '10147',
    shopBaseInfo.msgMoneyNotEnough or '10148',
    shopBaseInfo.msgBagFull or '10149',
    shopBaseInfo.msgSell or '10150',
    shopBaseInfo.msgAfterSell or '10151',
    table.unpack(fillShopSellType(shopBaseInfo.sellTypes or {})),
  }, '|');
  local ret = NL.CreateArgNpc("Itemshop2", shopNpcPrefix .. '|' .. table.join(items or {}, '|'), name, image, positionInfo.mapType, positionInfo.map, positionInfo.x, positionInfo.y, positionInfo.direction);
  if ret >= 0 then
    table.insert(self.npcList, ret);
  end
  return ret;
end

---@param name string
---@param image number
---@param positionInfo {x:number,y:number,map:number,mapType:number,direction:number}
---@param initCallback function
function Part:NPC_createNormal(name, image, positionInfo, initCallback)
  local initFn = self:regCallback(initCallback or function()
    return true
  end)
  local npc = NL.CreateNpc(nil, initFn);
  if npc < 0 then
    return -1;
  end
  table.insert(self.npcList, npc);
  Char.SetData(npc, CONST.CHAR_形象, image);
  Char.SetData(npc, CONST.CHAR_原形, image);
  Char.SetData(npc, CONST.CHAR_X, positionInfo.x);
  Char.SetData(npc, CONST.CHAR_Y, positionInfo.y);
  Char.SetData(npc, CONST.CHAR_地图, positionInfo.map);
  Char.SetData(npc, CONST.CHAR_方向, positionInfo.direction);
  Char.SetData(npc, CONST.CHAR_名字, name);
  Char.SetData(npc, CONST.CHAR_地图类型, positionInfo.mapType);
  NLG.UpChar(npc);
  return npc
end

function Part:NPC_regTalkedEvent(npc, fn)
  local talkedFn, lastIndex, fnIndex = self:regCallback(fn)
  Char.SetTalkedEvent(nil, talkedFn, npc);
  return talkedFn, lastIndex, fnIndex
end

function Part:NPC_regWindowTalkedEvent(npc, fn)
  local talkedFn, lastIndex, fnIndex = self:regCallback(fn)
  Char.SetWindowTalkedEvent(nil, talkedFn, npc);
  return talkedFn, lastIndex, fnIndex
end

function Part:NPC_buildSelectionText(title, options)
  local msg = '1\\n' .. title .. '\\n'
  for i = 1, 8 do
    if options[i] == nil then
      return msg;
    end
    msg = msg .. options[i] .. '\\n'
  end
  return msg;
end

function Part:onLoad()
  self.npcList = {};
end

function Part:onUnload()
  for i, v in pairs(self.npcList) do
    NL.DelNpc(v);
  end
end

return Part;
