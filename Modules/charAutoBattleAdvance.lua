---模块类
local Module = ModuleBase:createModule('charAutoBattleAdvance')
local skillTable = {}
skillTable = {
	{sequence=1,jobId=10,attackType=CONST.BATTLE_COM.BATTLE_COM_P_SPIRACLESHOT,techId=200500,slot=0,isboss=0},
	{sequence=2,jobId=10,attackType=CONST.BATTLE_COM.BATTLE_COM_P_PARAMETER, techId = 300,slot=0,isboss=1},
	--{jobId=20,attackType=CONST.BATTLE_COM.BATTLE_COM_P_SPIRACLESHOT,techId=200514,slot=0,isboss=0},
	--{jobId=20,attackType=CONST.BATTLE_COM.BATTLE_COM_P_PARAMETER,techId=314,slot=0,isboss=1},
	--{jobId=30,attackType=CONST.BATTLE_COM.BATTLE_COM_P_SPIRACLESHOT,techId=200514,slot=0,isboss=0},
	--{jobId=30,attackType=CONST.BATTLE_COM.BATTLE_COM_P_PARAMETER,techId=314,slot=0,isboss=1},
	{sequence=3,jobId=40,attackType=CONST.BATTLE_COM.BATTLE_COM_P_RANDOMSHOT,techId=9500,slot=0,isboss=0},
	--{jobId=40,attackType=CONST.BATTLE_COM.BATTLE_COM_AXEBOMBER,techId=10500,slot=41,isboss=1},
	{sequence=4,jobId=60,attackType=CONST.BATTLE_COM.BATTLE_COM_P_LP_RECOVERY,techId=6600,slot=40,isboss=1},
	{sequence=5,jobId=60,attackType=CONST.BATTLE_COM.BATTLE_COM_P_STATUSRECOVER,techId=6700,slot=40,isboss=1},
	{sequence=6,jobId=60,attackType=CONST.BATTLE_COM.BATTLE_COM_P_HEAL,techId=6300,slot=40,isboss=1},	
	{sequence=7,jobId=70,attackType=CONST.BATTLE_COM.BATTLE_COM_P_MAGIC,techId=2700,slot=41,isboss=1},--7~10 index random use
	{sequence=8,jobId=70,attackType=CONST.BATTLE_COM.BATTLE_COM_P_MAGIC,techId=2800,slot=41,isboss=1},
	{sequence=9,jobId=70,attackType=CONST.BATTLE_COM.BATTLE_COM_P_MAGIC,techId=2900,slot=41,isboss=1},
	{sequence=10,jobId=70,attackType=CONST.BATTLE_COM.BATTLE_COM_P_MAGIC,techId=3000,slot=41,isboss=1},
	{sequence=11,jobId=90,attackType=CONST.BATTLE_COM.BATTLE_COM_BOOMERANG,techId=26600,slot=0,isboss=1},
	{sequence=12,jobId=120,attackType=CONST.BATTLE_COM.BATTLE_COM_P_STEAL,techId=7200,slot=0,isboss=1},
	{sequence=13,jobId=140,attackType=CONST.BATTLE_COM.BATTLE_COM_P_SPIRACLESHOT,techId=400,slot=0,isboss=1},
}

local petSkillTable = {
	{sequence=1,attackType=CONST.BATTLE_COM.BATTLE_COM_P_BODYGUARD,slot=-1,techId=26125},
	{sequence=2,attackType=CONST.BATTLE_COM.BATTLE_COM_P_SPIRACLESHOT,slot=CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0,techId=429},
	{sequence=3,attackType=CONST.BATTLE_COM.BATTLE_COM_ATTACK, slot=CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0, techId=-1}
}
--- 加载模块钩子
function Module:onLoad()
  self:logInfo('load')
  self:regCallback("ProtocolOnRecv", function(fd, head, list)
    --self:logDebugF("AutoBattle %d %s", fd, head);
    local charIndex = tonumber(Protocol.GetCharIndexFromFd(fd));
    Protocol.Send(charIndex, "AutoBattle");
    local p = Battle.GetSlot(Battle.GetCurrentBattle(charIndex), charIndex);
    p = math.fmod(p + 5, 10);
    p = Battle.GetPlayer(Battle.GetCurrentBattle(charIndex), p) or -1;
    --self:logDebugF("AutoBattle %d %s %s %s", fd, head, charIndex, p);
	local battleIndex = Battle.GetCurrentBattle(charIndex);
	if Battle.IsWaitingCommand(charIndex) then
		local charJobId = Char.GetData(charIndex,%对象_职类ID%);
		local skillChoose = skillSelect(charIndex,battleIndex,charJobId);		
		local skillSuccess = Battle.ActionSelect(charIndex, skillChoose[1], skillChoose[2], skillChoose[3]);
		if not skillSuccess then
			Battle.ActionSelect(charIndex, CONST.BATTLE_COM.BATTLE_COM_ATTACK, CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0, -1);
		end
	end
	local slotTable = {};
	local petSkill = 0;
    if p >= 0 then
		--[[for k, v in pairs(petSkillTable) do
			if v.sequence == 2 then
				for i=10,19 do
					local enemyIndex = Battle.GetPlayer(battleIndex,i);
					if enemyIndex >= 0 then
						table.insert(slotTable,i);
					end
				end	
				local randomSlot = slotTable[NLG.Rand(1,#slotTable)];
				petSkill = Battle.ActionSelect(p,v.attackType,randomSlot,v.techId);
			else
				petSkill = Battle.ActionSelect(p, v.attackType, v.slot, v.techId);
			end
			if petSkill == 1 then
				break;
			end
		end]]--
	  Battle.ActionSelect(p, CONST.BATTLE_COM.BATTLE_COM_ATTACK, CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0, -1);
    else
      Battle.ActionSelect(charIndex, CONST.BATTLE_COM.BATTLE_COM_ATTACK, CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0, -1);
    end
  end, "AutoBattle")
end

function skillSelect(charIndex,battleIndex,charJobId)
	local skillChosen = {CONST.BATTLE_COM.BATTLE_COM_ATTACK, CONST.BATTLE_COM_TARGETS.SINGLE.SIDE_1.POS_0, -1};
	local slotTable = {};
	local maxTech = 0;
	local count = 0;
	local bossCount = 0;
	for k, v in pairs(skillTable) do
		if charJobId >= 10 and charJobId <= 30 and v.sequence == 1 then	--sword,axe,spear
			for i=10,19 do
				local enemyIndex = Battle.GetPlayer(battleIndex,i);
				if enemyIndex >= 0 then
					table.insert(slotTable,i);
					count = count + 1;
				end
			end
			if count > 1 then
				if v.techId == 200500 then
					local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
					if skillSlot > -1 then
						maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
						skillChosen[1] = v.attackType;
						skillChosen[2] = slotTable[NLG.Rand(1,#slotTable)];
						skillChosen[3] = v.techId+maxTech;
						break;
					end
				end
			end
		elseif charJobId >= 10 and charJobId <= 30 and v.sequence == 2 then	--sword,axe,spear
			for i=10,19 do
				local enemyIndex = Battle.GetPlayer(battleIndex,i);
				if enemyIndex >= 0 then
					table.insert(slotTable,i);
				end
			end
			--print("v.techId :"..v.techId);
			if v.techId == 300 then
				--print("v.techId :"..v.techId)
				local skillSlot = Char.HaveSkill(charIndex,3);
				if skillSlot > -1 then
					maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
					skillChosen[1] = v.attackType;
					skillChosen[2] = slotTable[1];
					skillChosen[3] = v.techId+maxTech;
					--print("skillSlot maxTech skillChosen[1] skillChosen[2] skillChosen[3]"..skillSlot.." "..maxTech.." "..skillChosen[1].." "..skillChosen[2].." "..skillChosen[3]);
					break;
				end
			end
		elseif charJobId == 40 and v.jobId == 40 then--bow
			--if Battle.IsBossBattle(BattleIndex) == 0 then
				--if v.techId == 9500 then
			for i=10,19 do
				local enemyIndex = Battle.GetPlayer(battleIndex,i);
				if enemyIndex >= 0 then
					table.insert(slotTable,i);
				end
			end				
			local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
			if skillSlot > -1 then
				maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
				skillChosen[1] = v.attackType;
				skillChosen[2] = slotTable[NLG.Rand(1,#slotTable)];
				skillChosen[3] = v.techId+maxTech;
			end
			break;
				--if v.techId == 10500 then
		elseif charJobId == 60 and v.jobId == 60 and v.sequence == 4 then--cleric
			for i = 10, 19 do
				local enemyIndex = Battle.GetPlayer(battleIndex, i);
				if Char.GetData(enemyIndex, CONST.CHAR_EnemyBossFlg) == 1 then
					bossCount = bossCount + 1;
				end
			end
			if bossCount >= 1 then
				local turn = Battle.GetTurn(battleIndex);
				if turn == 0 and v.techId == 6600 then
					local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
					if skillSlot > -1 then
						maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
						skillChosen[1] = v.attackType;
						skillChosen[2] = v.slot;
						skillChosen[3] = v.techId+maxTech;
						break;
					end
				end
			end
		elseif charJobId == 60 and v.jobId == 60 and v.sequence == 5 then
			for i = 0, 9 do
				local charStatusIndex = Battle.GetPlayer(battleIndex, i) 
				if charStatusIndex>=0 then
					if (Char.GetData(charStatusIndex,CONST.CHAR_BattleModPoison)>1 or 
					Char.GetData(charStatusIndex,CONST.CHAR_BattleModSleep)>1 or 
					Char.GetData(charStatusIndex,CONST.CHAR_BattleModStone)>1 or 
					Char.GetData(charStatusIndex,CONST.CHAR_BattleModDrunk)>1 or 
					Char.GetData(charStatusIndex,CONST.CHAR_BattleModConfusion)>1 or 
					Char.GetData(charStatusIndex,CONST.CHAR_BattleModAmnesia)>1 )  then
						count = count + 1;
					end
				end
			end
			if count >= 1 then
				if v.techId == 6700 then
					local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
					if skillSlot > -1 then
						maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
						skillChosen[1] = v.attackType;
						skillChosen[2] = v.slot;
						skillChosen[3] = v.techId+maxTech;
						break;
					end
				end
			end
		elseif charJobId == 60 and v.jobId == 60 and v.sequence == 6 then
			if v.techId == 6300 then
				local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
				if skillSlot > -1 then
					maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
					skillChosen[1] = v.attackType;
					skillChosen[2] = v.slot;
					skillChosen[3] = v.techId+maxTech;
				end
			end
			break;
		elseif charJobId == 70 and v.jobId == 70 then--magic
			local k = NLG.Rand(7,10);
			print(skillTable[k].techId)
			local skillSlot = Char.HaveSkill(charIndex,skillTable[k].techId/100);
			if skillSlot > -1 then
				maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
				print(maxTech);
				skillChosen[1] = skillTable[k].attackType;
				skillChosen[2] = skillTable[k].slot;
				skillChosen[3] = skillTable[k].techId+maxTech;
			end
			break;
		elseif charJobId == 90 and v.jobId == 90 then--seal
			for i=10,19 do
				local enemyIndex = Battle.GetPlayer(battleIndex,i);
				if enemyIndex >= 0 then
					table.insert(slotTable,i);
				end
			end				
			local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
			if skillSlot > -1 then
				maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
				skillChosen[1] = v.attackType;
				skillChosen[2] = slotTable[NLG.Rand(1,#slotTable)];
				skillChosen[3] = v.techId+maxTech;
			end
			break;
		elseif charJobId == 120 and v.jobId == 120 then--thief
			for i=10,19 do
				local enemyIndex = Battle.GetPlayer(battleIndex,i);
				if enemyIndex >= 0 then
					table.insert(slotTable,i);
				end
			end				
			local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
			if skillSlot > -1 then
				maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
				skillChosen[1] = v.attackType;
				skillChosen[2] = slotTable[NLG.Rand(1,#slotTable)];
				skillChosen[3] = v.techId+maxTech;
			end
			break;
		elseif charJobId == 140 and v.jobId == 140 then--gyuk
			for i=10,19 do
				local enemyIndex = Battle.GetPlayer(battleIndex,i);
				if enemyIndex >= 0 then
					table.insert(slotTable,i);
				end
			end				
			local skillSlot = Char.HaveSkill(charIndex,v.techId/100);
			if skillSlot > -1 then
				maxTech = Char.GetSkillLv(charIndex,skillSlot)-1;
				skillChosen[1] = v.attackType;
				skillChosen[2] = slotTable[NLG.Rand(1,#slotTable)];
				skillChosen[3] = v.techId+maxTech;
			end
			break;
		end
	end
	return skillChosen;
end	

--- 卸载模块钩子
function Module:onUnload()
  self:logInfo('unload')
end

return Module;
