--!strict
--[=[                                 
                                                       
▄█▀▀▀▀█ █████▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄ ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
█  █▀▄  ██▄▄██ ██▄█▄ ██▄▄  ██▄▄    ▄█▀ ██ ███▄▄   ██   
█▄ ▀▀ █ ██▄▄█▀ ██ ██ ██▄▄▄ ██▄▄▄ ▄██▄▄ ██ ▄▄██▀   ██   
 ▀▀▀▀▀                                                 
	@name tableService.luau
	@author Breezist
	@date July 28th, 2026
	@description A service for filtering tables, basically.
]=]
local tableService = {};

--[=[
	@name filter
	@within tableService
	@description Filters a table for a value.
	@param (tbl : {any}, callback : (any) -> boolean) The table to filter and the callback to use.`
	@return (any?, any?) The key and value of the filtered value.
	@usage
		local tbl = {a = 1, b = 2, c = 3}
		local _, value = tableService:filter(tbl, function (value)
			return value == 2
		end)
		print(value) -- 2
]=]
function tableService:filter(tbl: {any}, callback: ((any) -> boolean)?): (any?, any?)
	if not callback then return nil, nil end
	for key, value in pairs(tbl) do
		local success, result = pcall(callback, value)
		if success and result then
			return key, value
		end
	end
	return nil, nil 
end

return tableService;