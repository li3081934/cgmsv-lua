---模块类
---@class OnlineCharModule:ModuleBase|ModuleType
local Module = ModuleBase:createModule('onlineChar')
local onLineChar = {};
--- 加载模块钩子
function Module:onLoad()
  onLineChar = {};
  self:logInfo('load')
  self:regCallback('LoginEvent', Func.bind(self.onLoginEvent, self));
  self:regCallback('LogoutEvent', Func.bind(self.onLogoutEvent, self));
end

function Module:onLoginEvent (charIndex)
  onLineChar[charIndex] = { charIndex = charIndex, charName = Char.GetData(charIndex, CONST.对象_名字)}
end

function Module:onLogoutEvent (charIndex)
  onLineChar[charIndex] = nil
end

function Module:getOnLineChar()
  local res = {};
  for key, value in pairs(onLineChar) do
    table.insert(res, value)
    self:logDebug('onLineCharkey', key)
  end
  return res;
end
--- 卸载模块钩子
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
