--!strict
--[=[                                 
                                                       
▄█▀▀▀▀█ █████▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄ ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
█  █▀▄  ██▄▄██ ██▄█▄ ██▄▄  ██▄▄    ▄█▀ ██ ███▄▄   ██   
█▄ ▀▀ █ ██▄▄█▀ ██ ██ ██▄▄▄ ██▄▄▄ ▄██▄▄ ██ ▄▄██▀   ██   
 ▀▀▀▀▀                                                 
	@name dataService.luau
	@author Breezist
	@date July 28th, 2026
	@description A service for managing playerdata.
]=]
local cacheService = require(`@self/../cacheService`);
local datastoreService : DataStoreService = cacheService(`data`) :: DataStoreService;

local dataService = {};
dataService.__index = dataService;

--[=[
	@name new
	@within dataService
	@description Creates a new dataService object.
	@param datastoreName string -- The name of the datastore to use.
	@usage
		local datastore = dataService.new(`datastoreName`);
		local value = datastore:get(`key`);
		print(value);
		datastore:set(`key`, `newValue`);
		print(datastore:get(`key`))
]=]
function dataService.new(datastoreName : string, list : boolean?)
	local datastore = (list and datastoreService:GetOrderedDataStore(datastoreName)) or datastoreService:GetDataStore(datastoreName);
	return setmetatable({
		_datastore = datastore,
	}, dataService)
end

--[=[
	@name get
	@within dataService
	@description Gets a value from the datastore.
	@param key string -- The key to get the value from.
	@return (any?) -- The value of the key.
]=]
function dataService:get(key : string) : any?
	local cached = rawget(self, key)
	if cached ~= nil then return cached end
	local success, result = pcall(function()
		return self._datastore:GetAsync(key)
	end)
	if success then
		rawset(self, key, result); return result;
	end
	return nil
end

--[=[
	@name set
	@within dataService	
	@description Sets a value in the datastore.
	@param key string -- The key to set the value in.
	@param value any -- The value to set.
	@param callback (boolean, any?) -> nil -- A callback function to call after the value is set.
	@return (boolean, any?) -- The result of the operation.
]=]
function dataService:set(key : string, value : any, callback : ((boolean, any) -> nil)?)
	local success, result = pcall(function() 
		return self._datastore:SetAsync(key, value)
	end)
	if success then rawset(self, key, value) end;
	if callback then 
		pcall(callback, success, result) 
	end
	return success, result
end

--[=[
	@name remove
	@within dataService	
	@description Removes a value from the datastore.
	@param key string -- The key to remove.
	@return (boolean, any?) -- The result of the operation.
]=]
function dataService:remove(key : string) : (boolean, any?)
	rawset(self, key, nil)
	return pcall(function()
		self._datastore:RemoveAsync(key)
	end)
end

--[=[
	@name list
	@within dataService	
	@description Lists all keys in the datastore.
	@param pageSize number -- The number of keys to return.
	@param ascending boolean -- Whether the page is ascending or not
	@return (boolean, {}?) -- The result of the operation.
]=]
function dataService:list(pageSize : number, ascending : boolean?) : (boolean, {}?)
	local cached = rawget(self, `list`)
	if cached ~= nil then return cached end
	local success, result = pcall(function()
		local pages : DataStorePages = self._datastore:GetSortedAsync(ascending or false, pageSize or 10)
		local list : {} = pages:GetCurrentPage()
		return list;
	end)
	return success, result
end

return dataService;