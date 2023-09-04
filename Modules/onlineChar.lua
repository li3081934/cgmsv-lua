---模块类
---@class Online:ModuleBase|ModuleType
local Online = ModuleBase:createModule('onlineChar')
local onLineChar = {};
--- 加载模块钩子
function online:onLoad()
  
  self:logInfo('load')
  self:regCallback('LoginEvent', Func.bind(self.onLoginEvent, self));
  self:regCallback('LogoutEvent', Func.bind(self.onLogoutEvent, self));
end

function Online:onLoginEvent (charIndex)
  onLineChar[charIndex] = { charIndex = charIndex, charName = Char.GetData(charIndex, CONST.对象_名字)}
end

function Online:onLogoutEvent (charIndex)
  table[charIndex] = nil
end

function Online:getOnLineChar()
  local res = {};
  for key, value in pairs(onLineChar) do
    table.insert(res, value)
  end
  return res;
end
--- 卸载模块钩子
function Online:onUnload()
  self:logInfo('unload')
end

return Welcome;
