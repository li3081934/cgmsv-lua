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
  CG.RegCallback('OnChatEvent', 'OnChatEventCallback');   --�Զ�ս�����
  CG.RegCallback('OnStartBattleTimerEvent', 'OnStartBattleTimerEventCallback'); --�Զ�ս�����
  CG.RegCallback('CanWatchBattleEvent', 'CanWatchBattleEventCallback'); --���ڹ�ս
  CG.DisplayEnemyInfo(); --������Ѫ�����֣�
  CG.SetGraphicSize(4360000); --Graphic����
  CG.SetBattleActionTime(240000); --240��ս��ʱ��
  CG.SetBankPage(9); --����ҳ��
  CG.SetBagPage(5); --����ҳ��
  CG.EnableTranslateLang(); --���廯
  CG.SetTribeName(0, "����ϵ");
  CG.SetTribeName(15, "��ħϵ");
elseif cg then
  cg.SetActionTime(10); --10% ����ʱ��
  cg.SetBattleActionTime(240000); --240��ս��ʱ��
  cg.SetAutoBattleDelayTime(100); --0.1���Զ�ս���ȴ�ʱ��
  cg.SetBossKey("PAUSE"); --����BossKeyΪPAUSE����֧��PAUSE, F1-F12, ESC, `
  cg.DisplayEnemyInfo(); --������Ѫ�����֣�
  cg.SetBankPage(9); --9ҳ����
end
-- CG.RegCallback("OnRecvEvent", "OnRecvEventCallback");

AutoBattle = 0;

function OnChatEventCallback(str, type)
  if str == '/autoBattle on' then
      AutoBattle = 1;
      CG.LocalMsg("�Զ�ս������", 0, 0);
      return 1;
  end
  if str == '/autoBattle off' then
      AutoBattle = 0;
      CG.LocalMsg("�Զ�ս���ر�", 0, 0);
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