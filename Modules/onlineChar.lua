---ģ����
---@class OnlineCharModule:ModuleBase|ModuleType
local Module = ModuleBase:createModule('onlineChar')
local onLineChar = {};
--- ����ģ�鹳��
function Module:onLoad()
  onLineChar = {};
  self:logInfo('load')
  self:regCallback('LoginEvent', Func.bind(self.onLoginEvent, self));
  self:regCallback('LogoutEvent', Func.bind(self.onLogoutEvent, self));
end

function Module:onLoginEvent (charIndex)
  onLineChar[charIndex] = { charIndex = charIndex, charName = Char.GetData(charIndex, CONST.����_����)}
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
--- ж��ģ�鹳��
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
