--!strict
--[=[                                 
                                                       
▄█▀▀▀▀█ █████▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄ ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
█  █▀▄  ██▄▄██ ██▄█▄ ██▄▄  ██▄▄    ▄█▀ ██ ███▄▄   ██   
█▄ ▀▀ █ ██▄▄█▀ ██ ██ ██▄▄▄ ██▄▄▄ ▄██▄▄ ██ ▄▄██▀   ██   
 ▀▀▀▀▀                                                 
	@name initializer.luau
	@author Breezist
	@date July 28th, 2026
	@description The entry-point file for game replication.
]=]
local module = {
	[`services`] = {},
	[`functions`] = {},
	[`remotes`] = {
		[`events`] = {},
		[`functions`] = {}
	}
}

export type module = {
	services : {[string] : () -> any},
	functions : {[string] : () -> any},
	remotes : {
		events : {[string] : RemoteEvent},
		functions : {[string] : RemoteFunction},
	}	
}

type scriptConfiguration = {
	[string]: any,
};

local configuration : scriptConfiguration = {
	[`name`] = `Initalizer`
};

local warnCache, printCache = warn, print;
local warn, print = function(... : any)
	warnCache(`[{configuration[`name`]}]`, ...);
end, function(... : any)
	printCache(`[{configuration[`name`]}]`, ...);
end;

local util = require(`@self/util`);

local initalized = 0;
return setmetatable(module, {
	__call = function(self, ...)
		local start = os.clock();
		initalized += 1;
		print(initalized <= 2 and `Initializing services, please wait!`);
		local modules : Folder = script:FindFirstChild(`modules`);
		local remotes : Folder = script:FindFirstChild(`remotes`);
		
		util:loadModules(modules:WaitForChild(`services`), self.services)
		util:loadModules(modules:WaitForChild(`functions`), self.functions)

		util:loadRemotes(remotes:WaitForChild(`events`), self.remotes.events)
		util:loadRemotes(remotes:WaitForChild(`functions`), self.remotes.functions)

		util:initServices(self.services)
		util:startServices(self.services)
		print(initalized <= 2 and `Initalized after {math.floor((os.clock() - start) * 1e5) / 1e5}ms`)
		return self
	end,
});