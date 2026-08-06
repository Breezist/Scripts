--!strict
--[=[                                 
                                                       
▄█▀▀▀▀█ █████▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄ ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
█  █▀▄  ██▄▄██ ██▄█▄ ██▄▄  ██▄▄    ▄█▀ ██ ███▄▄   ██   
█▄ ▀▀ █ ██▄▄█▀ ██ ██ ██▄▄▄ ██▄▄▄ ▄██▄▄ ██ ▄▄██▀   ██   
 ▀▀▀▀▀                                                 
	@name tween.luau
	@author Breezist
	@date July 28th, 2026
	@description A function for tweening objects.
]=]
local cacheService = require(`@self/../../services/cacheService`);

local tween = {};
local tweens : {[any] : any} = {};
type tweenData = {
	object : Instance,
	properties: any,
	tween : Tween,
};

--[=[
	@name serializeProperties
	@within tween
	@description Converts the properties of an instance into a key-value string.
	@param (props : {[any] : any}) The properties to convert to a string.
	@param A string representation of the properties.
]=]
function tween:serializeProperties(props)
	local parts : {string} = {}
	for key, value in pairs(props) do
		table.insert(parts, `{key}={tostring(value)}`)
	end
	table.sort(parts)
	return table.concat(parts, `;`)
end

return setmetatable(tween, {
	__call = function (self, object : Instance, duration : number, properties : {any}, easingStyle : Enum.EasingStyle?, reverse : boolean?) : Tween?
		local tween;
		for _, data : tweenData in pairs(tweens) do
			if data.object == object and data.properties == self:serializeProperties(properties) then
				tween = data.tween;
				break;
			end
		end

		if not tween then
			local _, result : Tween? = pcall(function()
				return (cacheService(`ts`) :: TweenService):Create(object, TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, reverse or false), (properties :: {[string] : any}) )
			end)
			tween = result;
			table.insert(tweens, {object = object, properties = self:serializeProperties(properties), tween = tween})
		end;

		return tween;
	end
})