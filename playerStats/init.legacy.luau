local init = game:GetService(`ReplicatedStorage`):WaitForChild(`gameReplication`):FindFirstChild(`initializer`)
local app = require(init)()

game.Players.PlayerAdded:Connect(function(player : Player)
	local leaderstats, stats = Instance.new(`Folder`, player), Instance.new(`Folder`, player);
	leaderstats.Name = `leaderstats`; stats.Name = `stats`;
	
	for _, obj : Instance in next, script:GetChildren() do
		if obj:IsA(`ModuleScript`) then
			local data : {
				name:  string?,
				leaderstat : boolean?,
				instance : ValueBase?,
				datastore : string?,
				onPlayer : (Player) -> ()?
			} = require(obj);
			
			if (data.instance) then
				local clone = data.instance:Clone()
				clone.Parent = data.leaderstat and leaderstats or stats;
				clone.Name = data.name or `Undefined`;
				
				if (data.onPlayer) then
					pcall(data.onPlayer, player, clone)
				end
				
				if (data.datastore) then
					local datastoreService = app.services.dataService.new(data.datastore);
					clone.Value = datastoreService:get(player.UserId) or 0;
					
					task.spawn(function()
						while task.wait(60) and clone do
							app.remotes.functions.saveIndicator:InvokeClient(player, true);
							datastoreService:set(player.UserId, clone.Value);
							task.delay(.1, function()
								app.remotes.functions.saveIndicator:InvokeClient(player, false);
							end)
						end
					end)
					
					local connection : RBXScriptConnection;
					connection = game.Players.PlayerRemoving:Connect(function(p : Player)
						if p == player then
							datastoreService:set(player.UserId, clone.Value);
							connection:Disconnect()
						end
					end)
				end
			end
			
		end
	end
end)