local module = require(`@game/ReplicatedStorage/interlope`);

return {
	name = `interlope`,
	description = `Causes an umbrella man to chase a player!`,
	arguments = {`player`},
	aliases = {},
	permissionLevel = 100,
	execution = function(player : Player, args : {})
		local player : string = args[1];
		
		local function getPlayerByString(str : string) : Player
			local player : Player;
			for _, playerObj in game:GetService(`Players`):GetPlayers() do
				if playerObj.Name:lower():sub(1, #str) == str:lower() then
					player = playerObj;
					break;
				elseif playerObj.DisplayName:lower():sub(1, #str) == str:lower() then
					player = playerObj;
					break;
				end
			end
			return player;
		end
		
		local p = getPlayerByString(player);
		if p then
			module:chasePlayer(p)
		end;
	end,
}