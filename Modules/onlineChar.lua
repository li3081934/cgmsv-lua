---ģ����
---@class Online:ModuleBase|ModuleType
local Online = ModuleBase:createModule('onlineChar')
local onLineChar = {};
--- ����ģ�鹳��
function online:onLoad()
  
  self:logInfo('load')
  self:regCallback('LoginEvent', Func.bind(self.onLoginEvent, self));
  self:regCallback('LogoutEvent', Func.bind(self.onLogoutEvent, self));
end

function Online:onLoginEvent (charIndex)
  onLineChar[charIndex] = { charIndex = charIndex, charName = Char.GetData(charIndex, CONST.����_����)}
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
--- ж��ģ�鹳��
function Online:onUnload()
  self:logInfo('unload')
end

return Welcome;
