--!strict
--[=[                                 
                                                       
▄█▀▀▀▀█ █████▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄ ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
█  █▀▄  ██▄▄██ ██▄█▄ ██▄▄  ██▄▄    ▄█▀ ██ ███▄▄   ██   
█▄ ▀▀ █ ██▄▄█▀ ██ ██ ██▄▄▄ ██▄▄▄ ▄██▄▄ ██ ▄▄██▀   ██   
 ▀▀▀▀▀                                                 
	@name cacheService.luau
	@author Breezist
	@date July 28th, 2026
	@description The purpose of this module is to cache Roblox service providers.
]=]
local cacheService = {};
local robloxServiceAliases = {
	rs = `ReplicatedStorage`, sss = `ServerScriptService`,
	ss = `ServerStorage`, ts = `TweenService`,
	http = `HttpService`, data = `DataStoreService`, uis = `UserInputService`,
	cas = `ContextActionService`, rf = `ReplicatedFirst`, sg = `StarterGui`, sp = `StarterPack`,
	plr = `Players`, l = `Lighting`, run = `RunService`
}

--[=[
	@name get
	@within cacheService
	@description Retrieves multiple Roblox services
	@param service (... : string) -- The services to retrieve
	@return (...ServiceProvider?) -- If successful, returns the retrieved services
]=]
function cacheService:get(... : string) : (...ServiceProvider?)
	local index = select(`#`, ...);
	if index == 1 then return self[(...)] end
	
	local output = table.create(index);
	for i = 1, index do 
		output[i] = self[select(i, ...)];
	end
	
	return table.unpack(output, 1, index) :: ServiceProvider
end

setmetatable(cacheService, {
	__index = function(self, key : string) : ({}, ServiceProvider?)
		local cached : ServiceProvider = rawget(self, key);
		if cached then return cached end;
		
		local serviceName = robloxServiceAliases[string.lower(tostring(key))] or key;
		local success, service : ServiceProvider = xpcall(function()
			return game:GetService(serviceName) :: ServiceProvider
		end, function()
			warn(debug.traceback(`{script.Name} could not fetch Roblox service {serviceName}.`))
		end)
		
		if success and service then
			rawset(self, key, service);
			rawset(self, serviceName, service);
			return service;
		end
	end,
	
	
	__call = function(self, ...) : ({}, ...ServiceProvider)
		return self:get(...);
	end,
})

return cacheService;