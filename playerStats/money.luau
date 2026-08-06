local init = game:GetService(`ReplicatedStorage`):WaitForChild(`gameReplication`):FindFirstChild(`initializer`)
local app = require(init)()

return {
	name = `Money`,
	leaderstat = false,
 	instance = Instance.new(`NumberValue`),
	datastore = `money`,
	onPlayer = function(player : Player, instance)
			
	end,
}