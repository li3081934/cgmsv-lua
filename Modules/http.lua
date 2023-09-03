---http模块
local Module = ModuleBase:createModule('http')

---@alias ParamType {string:string}
---@alias HttpApiFn {string:fun(params:ParamType, body:string):string}
---@alias HttpMethods 'get'|'post'|'put'|'delete'|'patch'

--- 加载模块钩子
function Module:onLoad()
    self:logInfo('load')
    local status = Http.GetStatus();
    self:logInfo('Http.GetStatus', status);

    if status == 0 then
        Http.Init();
        self:logInfo('Http.Init');
        Http.AddMountPoint("/", "./lua/www/")
        self:logInfo('Http.AddMountPoint');
        status = 1;
    end
    if status == 1 then
        Http.Start("0.0.0.0", 10086);
        self:logInfo('Http.Start');
    end
    self._Apis = {} --[[@type {string: HttpApiFn}]];
    self:regCallback('HttpRequestEvent', Func.bind(self.onHttpRequest, self));
    self:regApi('post', "register", Func.bind(self.ApiRegister, self));
    self:regApi('post', "doLua", Func.bind(self.doLua, self));
    self:regApi('post', "reloadModule", Func.bind(self.reloadModule, self));
    self:regApi('post', "getAllLoadedModules", Func.bind(self.getAllLoadedModules, self));
    self:regApi('post', "getAutoBattleChar", Func.bind(self.getAutoBattleChar, self));
    self:regApi('post', "getCharSkills", Func.bind(self.getCharSkills, self));
    self:regApi('post', "setCharStrategy", Func.bind(self.setCharStrategy, self));
    self:regApi('post', "getCharStrategy", Func.bind(self.getCharStrategy, self));
    self:regApi('post', "autoBattleStop", Func.bind(self.autoBattleStop, self));
    -- for key, value in pairs(self) do
    --     if (string.find(key, 'get') == 1 or string.find(key, 'set') == 1) then
    --         self:regApi('post', key, Func.bind(value, self));
    --     end
    -- end
end

---http://127.0.0.1:10086/api/doLua
---@param params ParamType
---@param body string
---@return string
function Module:doLua(params, body)
    self:logInfo("doLua", params['lua']);
    local r, ret = pcall(dofile, params['lua']);
    self:logDebug('result', r, ret);
    return "true"
end

---http://127.0.0.1:10086/api/reloadModule
---@param params ParamType
---@param body string
---@return string
function Module:reloadModule(params, body)
    self:logInfo("reloadModule", params['module']);
    reloadModule(params['module']);
    return 'true';
end

---http://127.0.0.1:10086/api/getAllLoadedModules
---@param params ParamType
---@param body string
---@return string[]
function Module:getAllLoadedModules(params, body)
    self:logInfo("getAllLoadedModules");
    local modules = getAllLoadedModules();
    local nameArr = {};
    
    for index, value in pairs(modules) do
        table.insert(nameArr, index)
    end
    local b, ret = pcall(JSON.encode, nameArr);
    if not b then
        return ''
    else 
        return ret;
    end
end

---http://127.0.0.1:10086/api/getAutoBattleChar
---@param params ParamType
---@param body string
---@return string[]
function Module:getAutoBattleChar(params, body)
    local autoModule = getModule('charAutoBattle')--[[@as CharAutoBattle]]
    local data = autoModule:getAutoBattleChars();
    local resData = {};
    for key, value in pairs(data) do
        table.insert(resData, value)
    end
    local res = self:response(true, resData)
    return res
end

---http://127.0.0.1:10086/api/setCharStrategy
---@param params ParamType
---@param body string
---@return string[]
function Module:setCharStrategy(params, body)
    local b, ret = pcall(JSON.decode, body);
    if b ~= true or ret == nil then
        return self:response(false);
    end
    local autoModule = getModule('charAutoBattle')--[[@as CharAutoBattle]]
    autoModule:setCharStrategy(ret.charIndex, ret.strategy);
    return self:response(true);
end
---http://127.0.0.1:10086/api/getCharStrategy
function Module:getCharStrategy(params, body)
    local b, ret = pcall(JSON.decode, body);
    if b ~= true or ret == nil then
        return self:response(false);
    end
    local autoModule = getModule('charAutoBattle')--[[@as CharAutoBattle]]
    local data = autoModule:getCharStrategy(ret.charIndex);
    return self:response(true, data)
end

---http://127.0.0.1:10086/api/getCharSkills
---@param params ParamType
---@param body string
---@return string[]
function Module:getCharSkills(params, body)
    local b, ret = pcall(JSON.decode, body);
    if b ~= true or ret == nil then
        return self:response(false);
    end
    local autoModule = getModule('charAutoBattle')--[[@as CharAutoBattle]]
    local data = autoModule:getCharAllowSkill(ret.charIndex);
    return self:response(true, data);
end

---http://127.0.0.1:10086/api/autoBattleStop
---@param params ParamType
---@param body string
---@return string[]
function Module:autoBattleStop(params, body)
    local b, ret = pcall(JSON.decode, body);
    if b ~= true or ret == nil then
        return self:response(false);
    end
    local autoModule = getModule('charAutoBattle')--[[@as CharAutoBattle]]
    autoModule:autoBattleStop(ret.charIndex);
    return self:response(true);
end


---注册新用户 http://127.0.0.1:10086/api/register
---@param params ParamType
---@param body string
---@return string
function Module:ApiRegister(params, body)
    local b, ret = pcall(JSON.decode, body);
    if b ~= true or ret == nil then
        return "false";
    end
    local account = ret.account;
    local password = ret.password;
    if (account or '') == '' or (password or '') == '' then
        return "false";
    end
    self:logInfo("Register", account, password);
    local user = SQL.QueryEx('select CdKey from tbl_user where CdKey = ?', account);
    if #user.rows == 0 then
        local seq = SQL.QueryEx('select max(SequenceNumber) + 1 as Max from tbl_user');
        local sql = 'insert into tbl_user (CdKey, SequenceNumber, AccountID, AccountPassWord, '
            .. ' EnableFlg, UseFlg, BadMsg, TrialFlg, DownFlg, ExpFlg) values ('
            .. SQL.sqlValue(account) .. ', ' .. SQL.sqlValue(seq.rows[1].Max) .. ', '
            .. SQL.sqlValue(account) .. ', '
            .. SQL.sqlValue(password) .. ',1,1,0,8,0,0);'
        local r = SQL.QueryEx(sql);
        if r.effectRows == 1 then
            return "true"
        end
        --print(r, sql);
    end

    return "false";
end

---http请求回调
---@param method string
---@param api string API名字
---@param params ParamType 参数
---@param body string body内容
---@return string body 返回内容
function Module:onHttpRequest(method, api, params, body)
    if self._Apis[string.lower(method .. api)] then
        self:logInfo(string.lower(method .. api), self._Apis[string.lower(method .. api)]);
        return self._Apis[string.lower(method .. api)](params, body);
    end
    return "";
end

---@param method HttpMethods
---@param api string 对应http://127.0.0.1:10086/api/******
---@param fn HttpApiFn
function Module:regApi(method, api, fn)
    self._Apis[string.lower(method .. api)] = fn;
end

---@param success boolean
---@param message any 
---@return string
function Module:response(success, message)
    local jsonData = { success = success, data = message }
    local b, ret = pcall(JSON.encode, jsonData);
    if not b then
        self:logError('jsonErr', ret)
        return '';
    else
        return ret
    end
    
end

--- 卸载模块钩子
function Module:onUnload()
    self:logInfo('unload')
    if Http.GetStatus() == 2 then
        Http.Stop();
    end
end

return Module
