---模块类
---@class CharAutoBattle:ModuleBase|ModuleType
local Module = ModuleBase:createModule('charAutoBattle')
local autoBattleCharStore = {};
local allowSkillTable = {
  [3] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_PARAMETER },
  [5] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_GUARDBREAK },
  [19] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [20] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [21] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [22] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [23] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [24] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [25] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [26] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_MAGIC },
  [95] = { skillType = CONST.BATTLE_COM.BATTLE_COM_P_RANDOMSHOT },
}
local charBattleStrategy = {};
local techStore = {};
local skillStore = {};
local techFieldMap = {
  [1] = 'skillName',
  [4] = 'techId',
  [6] = 'skillId',
  [10] = 'manaCost'
}
--- 加载模块钩子
function Module:onLoad()
  self:logInfo('load')
  self:regCallback('TalkEvent', Func.bind(self.handleTalkEvent, self));
  self:regCallback('LogoutEvent', Func.bind(self.LogoutEvent, self));
  self:regCallback("ProtocolOnRecv", function(fd, head, list)
    -- self:logDebugF("AutoBattle %d %s", fd, head);
    local charIndex = tonumber(Protocol.GetCharIndexFromFd(fd));
    local autoBattleChar = autoBattleCharStore[charIndex];
    local strategy = charBattleStrategy[charIndex];

    -- self:logDebug('autoBattleChar', autoBattleChar)
    -- self:logDebug('strategy', strategy)
    if autoBattleChar == nil or strategy == nil then
      return;
    end
    local enemyslotTable = {};
    local battleIndex = Battle.GetCurrentBattle(charIndex);
    for i=10,19 do
      local enemyIndex = Battle.GetPlayer(battleIndex,i);
      if enemyIndex >= 0 then
        if Char.GetData(enemyIndex, CONST.对象_等级) == 1 and strategy.levelOneStop then
          NLG.SystemMessage(charIndex, "[系统] 遇到1级敌人 暂停");
          return
        end
        table.insert(enemyslotTable,i);
      end
    end
    Protocol.Send(charIndex, "AutoBattle");
    local com1, com2, com3 = self:getBattleActionCom(charIndex, strategy, enemyslotTable);
    if Battle.IsWaitingCommand(charIndex) then 
      Battle.ActionSelect(charIndex, com1, com2, com3);
    end
   



    local p = Battle.GetSlot(Battle.GetCurrentBattle(charIndex), charIndex);
    p = math.fmod(p + 5, 10);
    p = Battle.GetPlayer(Battle.GetCurrentBattle(charIndex), p) or -1;
    if p >= 0 then
      Battle.ActionSelect(p, CONST.BATTLE_COM.BATTLE_COM_ATTACK, CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0, -1);
    else
      Battle.ActionSelect(charIndex, CONST.BATTLE_COM.BATTLE_COM_ATTACK, CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0, -1);
    end
  end, "AutoBattle")
  self:readTechFile();
end

function Module:getBattleActionCom(charIndex, strategy, enemyslotTable)
    local com1 = CONST.BATTLE_COM.BATTLE_COM_ATTACK;
    local com2 = enemyslotTable[NLG.Rand(1,#enemyslotTable)];
    local com3 = -1;
    if skillStore.actionType == 'attack' then
      com1 = CONST.BATTLE_COM.BATTLE_COM_ATTACK;
      com3 = -1;
    end
    if strategy.actionType == 'skill' and strategy.skillId > 0 then
      local allowSkill = allowSkillTable[strategy.skillId];
      local targetTech = techStore[strategy.techId];
      local charMana = Char.GetData(charIndex, CONST.对象_魔);
      self:logDebug('mo', charMana);
      if charMana >= targetTech.manaCost then
        com1 = allowSkill.skillType;
        com3 = strategy.techId;
      end
    end
    return com1, com2, com3
end

function Module:readTechFile()
  file = io.open('data/tech.txt')
  for line in file:lines() do
    local techData = {}
    local index = 1
    for word in string.gmatch(line, "[^\t]+") do
      if techFieldMap[index] then
        local val = word;
        local numberVal = tonumber(word)
        if numberVal ~= nil then
          val = numberVal
        end
        techData[techFieldMap[index]] = val;
      end
      index = index + 1
    end
    
    if skillStore[techData.skillId] == nil then
      skillStore[techData.skillId] = techData.techId;
    end
    techStore[techData.techId] = techData;
    
  end

  -- for key, value in pairs(skillStore) do
  --   self:logDebug('key', key )
  --   self:logDebug('value', value )
  -- end
end

function Module:handleTalkEvent(charIndex, msg)
  if msg == '/ab on' then
    self:autoBattleStart(charIndex)
    NLG.SystemMessage(charIndex, "[系统] 自动战斗开启");
    return 0;
  end
  if msg == '/ab off' then
    self:autoBattleStop(charIndex)
    return 0;
  end
  return 1
end

function Module:getAutoBattleChars()
  return autoBattleCharStore;
end

function Module:getCharAllowSkill(charIndex)
  local slotCount = Char.GetData(charIndex, CONST.对象_技能栏)
  local res = {}
  
  for i = 0, slotCount, 1 do
    local skillId = Char.GetSkillID(charIndex, i);
    if skillId >= 0 and allowSkillTable[skillId] and skillStore[skillId] then
      local baseTechId = skillStore[skillId]
      local skillSlot = Char.HaveSkill(charIndex, skillId);
      local maxSkillLevel = Char.GetSkillLv(charIndex,skillSlot) - 1;
      for i = 0, maxSkillLevel, 1 do
        table.insert(res, techStore[baseTechId + i] )
      end
    end
  end
  return res
end

function ModuleBase:setCharStrategy(charIndex, strategyData) 
  charBattleStrategy[charIndex] = strategyData
  self:logDebug('战斗策略更新', charIndex, JSON.encode(strategyData));
end

function ModuleBase:getCharStrategy(charIndex, strategyData) 
  return charBattleStrategy[charIndex]
end

function  ModuleBase:LogoutEvent(charIndex) 
  self:autoBattleStop(charIndex)
  
end

function ModuleBase:autoBattleStart(charIndex)
  local charName = Char.GetData(charIndex, CONST.对象_名字);
  if autoBattleCharStore[charIndex] == nil and charBattleStrategy[charIndex] == nil then
    autoBattleCharStore[charIndex] = {charIndex = charIndex, charName = charName};
    charBattleStrategy[charIndex] = {
      actionType = 'attack',
      levelOneStop = true
    }
  end
end

function ModuleBase:autoBattleStop(charIndex)
  autoBattleCharStore[charIndex] = nil
  charBattleStrategy[charIndex] = nil
  NLG.SystemMessage(charIndex, "[系统] 自动战斗关闭");
end

--- 卸载模块钩子
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
