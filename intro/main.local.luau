local init = game:GetService(`ReplicatedStorage`):WaitForChild(`gameReplication`):FindFirstChild(`initializer`)
local app = require(init)()

local tween : () -> Tween = app.functions.tween;

local replicatedFirst = game:GetService(`ReplicatedFirst`);
replicatedFirst:RemoveDefaultLoadingScreen()

local intro = script.Parent;
local player = game:GetService(`Players`).LocalPlayer;
local playerGui = player:WaitForChild(`PlayerGui`);
local mouse = player:GetMouse()

intro.Parent = playerGui;

local loading = intro:FindFirstChild(`loading`);
local menu = intro:FindFirstChild(`menu`);
local container = menu:FindFirstChild(`container`);
local buttons = container:FindFirstChild(`buttons`);

local transition = intro:FindFirstChild(`transition`);

local loadingFrame = loading:FindFirstChild(`loading`);

local text = script:FindFirstChild(`loadedText`)
local lastLoaded : number = tick()
game:GetService(`ContentProvider`):PreloadAsync({game}, function(assetId : string, fetched : Enum.AssetFetchStatus)
	local clone = text:Clone()	
	clone.Parent = loadingFrame:FindFirstChild(`main`):FindFirstChild(`assetsLoaded`);
	clone.Text = `{fetched == Enum.AssetFetchStatus.Success and `Loaded {assetId}` or `Failed to load {assetId}`}`
	lastLoaded = tick()
end)

while tick() - lastLoaded < 3 do
	task.wait()
end

local tween : () -> Tween = app.functions.tween;
tween(loadingFrame, 1, {Position = UDim2.fromScale(0, 1)}):Play()

local introCams = workspace:FindFirstChild(`introCams`)
local transition = menu:FindFirstChild(`transition`);

local sound = Instance.new(`Sound`, script);
sound.SoundId = `rbxassetid://129338574094673`
sound.Looped = true
sound:Play()

local cFrame = Instance.new(`CFrameValue`); local yCFrame = Instance.new(`CFrameValue`);
task.spawn(function()
	while task.wait() do
		for _, introCam in pairs(introCams:GetChildren()) do
			workspace.CurrentCamera.FieldOfView = 70;
			
			yCFrame.Value = CFrame.Angles(math.rad(45), 0, 0)
			local start = introCam;
			cFrame.Value = start.CFrame;
			tween(yCFrame, 2, {Value = CFrame.Angles(0,0,0)}, Enum.EasingStyle.Elastic):Play()
			tween(transition, 0.5, {BackgroundTransparency = 1}):Play()

			for _, obj in next, introCam:GetChildren() do
				if obj:IsA(`Attachment`) then
					tween(cFrame, 10, {Value = obj.WorldCFrame}, Enum.EasingStyle.Linear):Play()
					task.wait(10)
				end
			end
			tween(workspace.CurrentCamera, 1, {FieldOfView = 40}):Play()
			task.wait(0.8)
			tween(transition, 0.5, {BackgroundTransparency = 0}):Play()
			task.wait(0.5)
		end
	end
end)

local sensitivity = 0.0001
local smoothedX, smoothedY = 0, 0
local smoothing = 0.1

local runService : RunService = app.services.cacheService(`run`);
local connection : RBXScriptConnection = runService.PreRender:Connect(function()
	local baseCF : CFrame = cFrame.Value

	local viewport = workspace.CurrentCamera.ViewportSize
	local xOffset = (mouse.X - viewport.X/2) * sensitivity
	local yOffset = (mouse.Y - viewport.Y/2) * sensitivity

	smoothedX = smoothedX + (xOffset - smoothedX) * smoothing
	smoothedY = smoothedY + (yOffset - smoothedY) * smoothing
	
	local lookCF = CFrame.Angles(0, -smoothedX, 0) * CFrame.Angles(-smoothedY, 0, 0)
	local target = baseCF * lookCF * yCFrame.Value
	workspace.CurrentCamera.CFrame = target
end)

local frames = menu:FindFirstChild(`frames`);
local main = frames:FindFirstChild(`main`);
local credits, rules, updateLogs = main:FindFirstChild(`credits`), main:FindFirstChild(`rules`), main:FindFirstChild(`updateLogs`);
local closeFrame = main:FindFirstChild(`closeButton`);
local closeButton = closeFrame:FindFirstChild(`button`);

local openPos = UDim2.fromScale(0.6, 0.65);
local isVisible = false;
function checkMain()
	if not isVisible then
		isVisible = true;
		tween(main, 3, {Position = openPos}, Enum.EasingStyle.Elastic):Play()
	end
end

local buttonData = {
	[`Play`] = {
		execution = function()
			tween(transition, 1, {BackgroundTransparency = 0}):Play()
			loadingFrame.Visible = false;
			container.Visible = false;
			main.Visible = false;
			tween(sound, 1, {Volume = 0}):Play()
			task.wait(1)
			connection:Disconnect()

			local character = app.remotes.functions.loadCharacter:InvokeServer()
			repeat task.wait() until character or game.Players.LocalPlayer.Character;
			tween(transition, 1, {BackgroundTransparency = 1}):Play()
			task.delay(1, function()
				intro:Destroy()
			end)
		end,
		layout = -1;
		color = Color3.fromRGB(76, 73, 122),
	},
	[`Credits`] = {
		execution = function()
			for _, frame in {rules, updateLogs} do
				tween(frame, 0.1, {Position = UDim2.fromScale(-1.25, 0)}):Play()
			end
			tween(credits, 0.1, {Position = UDim2.fromScale(0, 0)}):Play()
			checkMain()
		end,
	},
	[`Update Logs`] = {
		execution = function()
			for _, frame in {rules, credits} do
				tween(frame, 0.1, {Position = UDim2.fromScale(-1.25, 0)}):Play()
			end
			tween(updateLogs, 0.1, {Position = UDim2.fromScale(0, 0)}):Play()
			checkMain()
		end,
	},
	[`Rules`] = {
		execution = function()
			for _, frame in {updateLogs, credits} do
				tween(frame, 0.1, {Position = UDim2.fromScale(-1.25, 0)}):Play()
			end
			tween(rules, 0.1, {Position = UDim2.fromScale(0, 0)}):Play()
			checkMain()
		end,
		layout = 0,
	}
}

closeButton.Activated:Connect(function()
	isVisible = false;
	tween(main, 1, {Position = UDim2.fromScale(1, 0.65)}, Enum.EasingStyle.Quad):Play()
	tween(closeFrame, .1, {Size = UDim2.fromScale(0.05, 0.05)}, nil, true):Play()

end)

closeFrame.MouseEnter:Connect(function()
	tween(closeFrame, .1, {Size = UDim2.fromScale(0.075, 0.075)}):Play()
end)

closeFrame.MouseLeave:Connect(function()
	tween(closeFrame, .1, {Size = UDim2.fromScale(0.1, 0.1)}):Play()
end)


for name, data in pairs(buttonData) do
	local clone = script:FindFirstChild(`buttonTemplate`):Clone()
	clone.BackgroundColor3 = data.color or Color3.fromRGB(15, 15, 15);
	local button = clone:FindFirstChild(`button`);
	button.Text = name;
	clone.Parent = buttons;
	
	local originalSize = clone.Size;

	button.Activated:Connect(function()
		local sound = Instance.new(`Sound`, script);
		sound.SoundId = `rbxassetid://100809160609628`;
		sound.PlayOnRemove = true;
		sound:Destroy()
		
		tween(clone, 0.1, {Size = UDim2.fromScale(originalSize.X.Scale * .8, originalSize.Y.Scale * .8)}, nil, true):Play()
		pcall(data.execution)
	end)
	clone.LayoutOrder = data.layout or 1;
		
	clone.MouseEnter:Connect(function()
		local sound = Instance.new(`Sound`, script);
		sound.SoundId = `rbxassetid://136108770017536`;
		sound.PlayOnRemove = true;
		sound:Destroy()
		
		tween(clone, 0.1, {Size = UDim2.fromScale(originalSize.X.Scale * 1.2, originalSize.Y.Scale * 1.2)}):Play()
		tween(clone:FindFirstChild(`left`), 0.1, {Size = UDim2.fromScale(0.01, 1)}):Play()
	end)
	clone.MouseLeave:Connect(function()
		tween(clone, 0.1, {Size = originalSize}):Play()
		tween(clone:FindFirstChild(`left`), 0.1, {Size = UDim2.fromScale(0.01, 0)}):Play()
	end)
end