--[=[                                 
                                                       
▄█▀▀▀▀█ █████▄ ▄▄▄▄  ▄▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄▄ ▄▄  ▄▄▄▄ ▄▄▄▄▄▄ 
█  █▀▄  ██▄▄██ ██▄█▄ ██▄▄  ██▄▄    ▄█▀ ██ ███▄▄   ██   
█▄ ▀▀ █ ██▄▄█▀ ██ ██ ██▄▄▄ ██▄▄▄ ▄██▄▄ ██ ▄▄██▀   ██   
 ▀▀▀▀▀                                                 
	@name main.local.luau
	@author Breezist
	@description This code is for a topbar that automatically populates and animates.
]=]
local init = game:GetService(`ReplicatedStorage`):WaitForChild(`gameReplication`):FindFirstChild(`initializer`)
local app = require(init)()

local tween : () -> Tween = app.functions.tween;

local buttonTemplate = script:FindFirstChild(`buttonTemplate`);
local ui = script.Parent;
local container = ui:FindFirstChild(`container`);

local frames = ui:FindFirstChild(`frames`);

local buttonsOpened = {};
local toChange = Instance.new(`BoolValue`);
local blur = Instance.new(`BlurEffect`, game:GetService(`Lighting`))
blur.Size = 0

toChange.Changed:Connect(function(value)
	tween(workspace.CurrentCamera, 1, {FieldOfView = value and 40 or 70}):Play()
	tween(blur, 1, {Size = value and 12 or 0}):Play()
	print(`Changed`)
end)

function handleButton(buttonFrame : Frame, isVisible : boolean)
	if isVisible then
		table.insert(buttonsOpened, buttonFrame)
	else table.remove(buttonsOpened, table.find(buttonsOpened, buttonFrame)); end

	tween(buttonFrame, 1, {Size = isVisible and UDim2.fromScale(0.6, 0.6) or UDim2.fromScale(0, 0)}, Enum.EasingStyle.Elastic):Play()
end

local buttons = {
	[`Roles`] = {
		image = `rbxassetid://139922581430953`,
		execution = handleButton,
		frame = frames:FindFirstChild(`roles`),
	},
	[`Ranks`] = {
		image = `rbxassetid://75882091290487`,
		execution = handleButton,
		frame = frames:FindFirstChild(`ranks`);
	},
	[`Myth Database`] = {
		image = `rbxassetid://72999457420013`,
		execution = handleButton,
		frame = frames:FindFirstChild(`database`);
	},

	[`Settings`] = {
		image = `rbxassetid://121280621257421`,
		execution = handleButton,
		iconEffects = function(button : ImageButton)
			task.spawn(function()
				while task.wait() do
					if button then
						button.Rotation = 0;
						tween(button, 5, {Rotation = 360 * 5}):Play()
						task.wait(10)
					end
				end
			end)
		end,
		frame = frames:FindFirstChild(`settings`);
	}
}

local i = 1;
for name : string, data : {image : string, execution : () -> (), iconEffects : (ImageButton) -> ()?, frame : Frame?} in pairs(buttons) do
	local newButton = buttonTemplate:Clone();
	
	newButton.ZIndex = #buttons - i;
	i += 1;
	
	local textFrame : Frame = newButton:FindFirstChild(`text`);
	local text : TextLabel = textFrame:FindFirstChild(`text`);
	local button : ImageButton = newButton:FindFirstChild(`button`);
	button.Image = data.image or ``;
	
	text.Text = name;
	newButton.MouseEnter:Connect(function()
		textFrame.Visible = true;
		tween(newButton, 0.2, {Size = UDim2.fromScale(0.6, 0.6)}):Play()
		tween(textFrame, 0.1, {Size = UDim2.fromScale(2, 0.5)}):Play()
		tween(text:FindFirstChildWhichIsA(`UIGradient`), 0.2, {Offset = Vector2.new(1, 0)}):Play()
	end)
	
	newButton.MouseLeave:Connect(function()
		tween(newButton, 0.2, {Size = UDim2.fromScale(0.4, 0.4)}):Play()
		tween(text:FindFirstChildWhichIsA(`UIGradient`), 0.2, {Offset = Vector2.new(-1, 0)}):Play()	
		local t = tween(textFrame, 0.1, {Size = UDim2.fromScale(0, 0.5)})
		t.Completed:Once(function()
			textFrame.Visible = false;
		end)
		t:Play()
	end)
	
	local isVisible = false;
	button.Activated:Connect(function()

		isVisible = not isVisible
		local sound = Instance.new(`Sound`, script);
		sound.PlayOnRemove = true
		sound.SoundId = `rbxassetid://139658322785649`
		sound:Destroy()
		
		pcall(data.execution, data.frame, isVisible);
		tween(newButton, 0.1, {Size = UDim2.fromScale(0.5, 0.5)}, nil, true):Play()
	end)
	newButton.Parent = container;
	
	if data.iconEffects then
		pcall(data.iconEffects, button)
	end
end

task.spawn(function()
	while task.wait() do
		toChange.Value = #buttonsOpened > 0
	end
end)
