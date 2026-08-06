local init = game:GetService(`ReplicatedStorage`):WaitForChild(`gameReplication`):FindFirstChild(`initializer`)
local app = require(init)()

return {
	name = `Time Played`,
	leaderstat = true,
 	instance = Instance.new(`NumberValue`),
	datastore = `timePlayed`,
	onPlayer = function(player : Player, instance)
		task.spawn(function()
			while task.wait(60) do
				instance.Value += 1
			end
		end)
	end,
}