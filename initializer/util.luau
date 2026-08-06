--!strict
--[=[                                 
                                                       
▄█▀▀▀▀█ █████▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄ ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
█  █▀▄  ██▄▄██ ██▄█▄ ██▄▄  ██▄▄    ▄█▀ ██ ███▄▄   ██   
█▄ ▀▀ █ ██▄▄█▀ ██ ██ ██▄▄▄ ██▄▄▄ ▄██▄▄ ██ ▄▄██▀   ██   
 ▀▀▀▀▀                                                 
	@name util.luau
	@author Breezist
	@date July 28th, 2026
	@description The file used for utility functions.
]=]
local util = {}

local cache = {};

--[=[
	@name cacheRequire
	@within util
	@description Instead of requiring a module every time, we can store its result in a cache.
	@param (obj : ModuleScript) The module to cache.
	@return (any | nil) The result of requiring the module.
]=]
function util:cacheRequire(obj : ModuleScript) : any | nil
	local cached = rawget(cache, obj);
	if cached ~= nil then return cached end;

	local success, result = pcall(require, obj);
	if not success then
		warn(`Failed to require: {obj:GetFullName()} -`, result)
		return;
	end
	rawset(cache, obj, result)
	return result;
end


--[=[
	@name loadModules
	@within util
	@description Multi-requires modules inside of a directory.
	@param (dir : Instance) The directory to load modules from.
	@param (targetTable : any) The table to store the modules in.
]=]
function util:loadModules(dir : Instance, targetTable)
	for _, obj in ipairs(dir:GetChildren()) do
		if obj:IsA(`ModuleScript`) then
			if rawget(targetTable, obj.Name) ~= nil then continue end
			local loaded = util:cacheRequire(obj)
			if loaded then rawset(targetTable, obj.Name, loaded) end
		end
	end
	setmetatable(targetTable, {
		__index = function(self, key) : any | nil
			local value = rawget(self, key)
			if value ~= nil then
				return value
			else
				warn(`Invalid module: {key}!`)
				return nil
			end
		end,
	})
end

--[=[
	@name loadRemotes
	@within util
	@description Retrieves the remote instances inside of a directory and stores them in a table.
	@param (dir : Instance) The directory to load remotes from.
	@param (targetTable : any) The table to store the remotes in.
]=]
function util:loadRemotes(dir : Instance, targetTable)
	for _, obj : Instance in ipairs(dir:GetChildren()) do
		if rawget(targetTable, obj.Name) == nil then
			rawset(targetTable, obj.Name, obj)
		end
	end
	setmetatable(targetTable, {
		__index = function(self, key) : any | nil
			local value = rawget(self, key)
			if value ~= nil then
				return value
			else
				warn(`Invalid remote: {key}!`)
				return nil
			end
		end,
	})
end

--[=[
	@name initServices
	@within util
	@description For every service passed through the function, it is loaded.
	@param (services : {any}) The services to load. 
]=]
function util:initServices(services : {any})
	for name, service in pairs(services) do
		if type(service) == `table` then
			local init = rawget(service, `init`) :: (any) -> ()
			if init then
				local success, err = pcall(init, service)
				if not success then
					warn(`Service initalization failed for: {name} - {err}`)
				end
			end
		end
	end
end

--[=[
	@name startServices
	@within util
	@description Every service that has been previously loaded can now be started.
	@param (services : {any}) The services to start. 
	@note Must be called *after* the initalization of every service.
]=]
function util:startServices(services : {any})
	for name, service in pairs(services) do
		if type(service) == `table` then
			local start = rawget(service, `start`) :: (any) -> ()
			if start then
				local success, err = pcall(start, service)
				if not success then
					warn(`Starting services failed for: {name} - {err}`)
				end
			end
		end
	end
end

return util