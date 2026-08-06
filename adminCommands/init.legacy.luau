local commands = script:FindFirstChild(`commands`);
local permissions = script:FindFirstChild(`permissions`);

local adminLevelCache = {
	groups = {},
	users = {},
};
local commandCache = {};
for _, module in commands:GetDescendants() do
	local success, data = pcall(require, module)
	if success then
		commandCache[module.Name] = data
	else warn(`[Admin Console] Failed to load {module:GetFullName()}:\n{data}`) end
end

for _, permission in permissions:GetChildren() do
	if permission.Name == "group" then
		local data = {
			groupId = permission:GetAttribute("groupId") or 0,
			ranks = {},
			globalLevel = permission:GetAttribute("adminLevel") or 0
		}

		for _, obj in pairs(permission:GetChildren()) do
			if obj:IsA("NumberValue") then
				table.insert(data.ranks, {
					rank = obj.Value,
					level = obj:GetAttribute("adminLevel") or data.globalLevel
				})
			end
		end

		table.insert(adminLevelCache.groups, data)
	elseif permission.Name == "user" then
		table.insert(adminLevelCache.users, {
			id = permission:GetAttribute("userId") or 0,
			level = permission:GetAttribute("adminLevel") or 0
		})
	end
end

function getCommands(command : string)
	local commandList = {}
	for _, data in pairs(commandCache) do
		local match = false
		if data.name:sub(1, #command):lower() == command:lower() then
			match = true
		else
			for _, alias in ipairs(data.aliases or {}) do
				if alias:sub(1, #command):lower() == command:lower() then
					match = true
					break
				end
			end
		end
		if match and not commandList[data] then
			commandList[data] = true
			table.insert(commandList, data)
		end
	end
	return commandList
end

function getAdminLevel(player : Player)
	local userId = player.UserId
	local highestLevel = 0

	for _, data in ipairs(adminLevelCache.users) do
		if data.id == userId then
			if data.level > highestLevel then
				highestLevel = data.level
			end
		end
	end

	for _, groupData in pairs(adminLevelCache.groups) do
		local groupId = groupData.groupId
		if groupId and groupId > 0 then
			local isInGroup = false
			local playerRank = 0
			local success, result = pcall(function()
				return player:GetRankInGroup(groupId)
			end)

			if success then
				playerRank = result
				isInGroup = playerRank > 0
			end

			if isInGroup then
				local appliedLevel = groupData.globalLevel or 0
				for _, rankData in ipairs(groupData.ranks) do
					if rankData.rank == playerRank then
						appliedLevel = rankData.level
						break
					end
				end

				if appliedLevel > highestLevel then
					highestLevel = appliedLevel
				end
			end
		end
	end
	
	print(highestLevel)
	print(adminLevelCache)

	return highestLevel
end

game.Players.PlayerAdded:Connect(function(player : Player)
	local playerGui : PlayerGui = player:WaitForChild(`PlayerGui`);
	local ui = script:FindFirstChild(`adminConsole`):Clone()
	ui.Parent = playerGui;
	
	local remote = Instance.new(`RemoteEvent`, ui);
	remote.Name = `adminConsoleEvent`;
	remote.OnServerEvent:Connect(function(plr : Player, ...)
		if plr ~= player then return end;
		local functions = {
			[`handleCommand`] = function(input : string)
				local command = input:match(`^%s*(%S+)`)
				local args = {}
				for arg in input:gmatch(`%S+`) do
					table.insert(args, arg)
				end
				table.remove(args, 1)
				
				for _, data : {name : string, execution : () -> (), permissionLevel : number} in pairs(commandCache) do
					if data.name:lower() == command:lower() then
						if getAdminLevel(plr) >= data.permissionLevel then
							local success, err = pcall(data.execution, player, args)
							if not success then
								warn(`[Admin Console]`, err)
							end
							break;
						else
							remote:FireClient(plr, `error`, `You do not have permission to run this command!`);
						end
					end
				end
			end,
			[`retrieveCommands`] = function(input : string)
				local command = input:match(`^%s*(%S+)`)
				local args = {}
				for arg in input:gmatch(`%S+`) do
					table.insert(args, arg)
				end
				table.remove(args, 1)
				remote:FireClient(plr, `retrievedCommands`, getCommands(command))
			end,
		}
		
		local args = {...};		
		if functions[args[1]] then
			pcall(functions[args[1]], table.unpack(args, 2))
		end
	end)
	
end)