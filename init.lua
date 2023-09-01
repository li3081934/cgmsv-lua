_HookVer = '0.2.31'
_HookFunc = false;
_GMVS_ = nil;
if NL.Version == nil or NL.Version() < 20230511 then
  if getHookVer == nil then
    error(string.format('[ERR]HOOK not load %s', _HookVer))
  end
  if getHookVer() ~= _HookVer then
    error(string.format('[ERR]HOOK not match require %s, but found %s', _HookVer, getHookVer()));
  end
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  print(string.format("[LUA]HOOK loaded %s, start load lua ........", _HookVer))
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  _HookFunc = true;
else
  _GMVS_ = NL.Version();
end
print("[LUA]Initial Lua System......")
collectgarbage()
collectgarbage('stop')
math.randomseed(os.time())
dofile('lua/Const.lua')
dofile('lua/Util.lua')
dofile('lua/libs/GmsvExtension.lua')
dofile('lua/libs/ModuleSystem.lua')
collectgarbage('restart')
collectgarbage()
print("[LUA]Initial Lua System done.")
dofile('lua/ModuleConfig.lua')
pcall(dofile, 'lua/Modules/Private/Config.lua')
if _HookFunc then
  NL.EmitInit()
end


if CG then
  CG.RegCallback('OnChatEvent', 'OnChatEventCallback');   --自动战斗相关
  CG.RegCallback('OnStartBattleTimerEvent', 'OnStartBattleTimerEventCallback'); --自动战斗相关
  CG.RegCallback('CanWatchBattleEvent', 'CanWatchBattleEventCallback'); --城内观战
  CG.DisplayEnemyInfo(); --怪物显血（文字）
  CG.SetGraphicSize(4360000); --Graphic数量
  CG.SetBattleActionTime(240000); --240秒战斗时间
  CG.SetBankPage(9); --银行页数
  CG.SetBagPage(5); --背包页数
  CG.EnableTranslateLang(); --简体化
  CG.SetTribeName(0, "人型系");
  CG.SetTribeName(15, "恶魔系");
elseif cg then
  cg.SetActionTime(10); --10% 制作时间
  cg.SetBattleActionTime(240000); --240秒战斗时间
  cg.SetAutoBattleDelayTime(100); --0.1秒自动战斗等待时间
  cg.SetBossKey("PAUSE"); --设置BossKey为PAUSE键，支持PAUSE, F1-F12, ESC, `
  cg.DisplayEnemyInfo(); --怪物显血（文字）
  cg.SetBankPage(9); --9页银行
end
-- CG.RegCallback("OnRecvEvent", "OnRecvEventCallback");

AutoBattle = 0;

function OnChatEventCallback(str, type)
  if str == '/autoBattle on' then
      AutoBattle = 1;
      CG.LocalMsg("自动战斗开启", 0, 0);
      return 1;
  end
  if str == '/autoBattle off' then
      AutoBattle = 0;
      CG.LocalMsg("自动战斗关闭", 0, 0);
      return 1;
  end
end

function OnStartBattleTimerEventCallback()
  if AutoBattle == 1 then
      CG.LocalMsg("AutoBattle", 0, 0);
      CG.SendProto("AutoBattle");
  end
end

function CanWatchBattleEventCallback(floor)
  return 1;
end

-- function OnRecvEventCallback(head, ...)
--     if head == 'test' then
--         CG.LocalMsg(string.format("%s %s %s %s", "Test Protocal", ...), 0, 0);
--         return 1;
--     end
--     return 0;
-- end