local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local holder = parent:WaitForChild("Holder")
local updateSetting = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("UpdateSetting")
local click = SoundService:WaitForChild("SFX"):WaitForChild("Click")
local UIController = require(ReplicatedStorage2:WaitForChild("UIController"))
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.fromRGB(255, 45, 45)

-- equivalent calls inferred from this helper; original call sites unknown
local function Round(p: number)
	return (math.clamp(math.floor(p * 100 + 0.5) / 100, 0, 1))
end

local function MakePadHint(parent2, p: string)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = p .. "PadHint"
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = p == "Left" and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
	imageLabel.Position = p == "Left" and UDim2.new(0, -6, 0.5, 0) or UDim2.new(1, 6, 0.5, 0)
	imageLabel.Size = UDim2.new(1, 0, 1.6, 0)
	imageLabel.ZIndex = 12
	imageLabel.Visible = false
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.AspectRatio = 1
	uIAspectRatioConstraint.Parent = imageLabel
	imageLabel.Parent = parent2
	return imageLabel
end

local function SetupSlider(instance, p: string)
	local slider = instance:WaitForChild("Slider")
	local progress = slider:WaitForChild("Progress")
	local handle = slider:WaitForChild("Handle")
	slider.Active = true
	slider.Selectable = true
	local v = false

	local function Paint(p2: number)
		progress.Size = UDim2.new(p2, 0, 1, 0)
		handle.Position = UDim2.new(
			(1 - handle.Size.X.Scale) * p2,
			0,
			handle.Position.Y.Scale,
			handle.Position.Y.Offset
		)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ValueAt(X: number)
		local X2 = slider.AbsolutePosition.X
		local X3 = slider.AbsoluteSize.X

		if X3 <= 0 then
			return 0
		end

		return (math.clamp(math.floor(math.clamp((X - X2) / X3, 0, 1) * 100 + 0.5) / 100, 0, 1))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Commit(p2: number)
		Paint(p2)
		updateSetting:FireServer(p, p2)
	end

	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v = true
			local valueAt = ValueAt(input.Position.X) -- equivalent call inferred; original call site unknown
			Commit(valueAt) -- equivalent call inferred; original call site unknown
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not v then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local valueAt = ValueAt(input.Position.X) -- equivalent call inferred; original call site unknown
			Commit(valueAt) -- equivalent call inferred; original call site unknown
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v = false
		end
	end)
	slider.InputBegan:Connect(function(input)
		local v2 = (input.KeyCode == Enum.KeyCode.DPadLeft or input.KeyCode == Enum.KeyCode.Left) and -0.1 or (input.KeyCode == Enum.KeyCode.DPadRight or input.KeyCode == Enum.KeyCode.Right) and 0.1 or 0

		if v2 ~= 0 then
			local round = Round(progress.Size.X.Scale + v2) -- equivalent call inferred; original call site unknown
			Commit(round) -- equivalent call inferred; original call site unknown
		end
	end)
	return {
		Row = instance,
		Paint = Paint,
		Nudge = function(p2: number)
			local round = Round(progress.Size.X.Scale + p2) -- equivalent call inferred; original call site unknown
			Commit(round) -- equivalent call inferred; original call site unknown
		end,
		Hints = { MakePadHint(slider, "Left"), (MakePadHint(slider, "Right")) }
	}
end

local function SetupSwitch(instance, p: string)
	local switch = instance:WaitForChild("Switch")
	local flick = switch:WaitForChild("Flick")
	local v = nil

	for _, label in instance:GetChildren() do
		if not label:IsA("TextLabel") then
			continue
		end

		local v3 = string.upper(string.gsub(label.Text, "%s", ""))

		if not (v3 == "ON" or v3 == "OFF") then
			continue
		end

		v = label
		break
	end

	if not v then
		warn(string.format("[Settings] %s has no ON/OFF label - status text won't update", instance.Name))
	end

	local scale = flick.Position.X.Scale
	local v3 = math.max(0, 1 - scale - flick.Size.X.Scale)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Paint(flag: boolean)
		flick.Position = UDim2.new(flag and scale or v3, 0, flick.Position.Y.Scale, flick.Position.Y.Offset)
		flick.BackgroundColor3 = flag and color or color2

		if v then
			v.Text = flag and "ON" or "OFF"
		end
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "Toggle"
	textButton.Text = ""
	textButton.BackgroundTransparency = 1
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.ZIndex = flick.ZIndex + 1
	textButton.Selectable = true
	textButton.Parent = switch
	local v4 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Apply(flag: boolean)
		if flag == v4 then
			return
		end

		click:Play()
		Paint(flag) -- equivalent call inferred; original call site unknown
		updateSetting:FireServer(p, flag)
	end

	textButton.Activated:Connect(function()
		Apply(not v4) -- equivalent call inferred; original call site unknown
	end)
	return {
		Row = instance,
		Set = function(flag: boolean)
			v4 = flag
			Paint(flag) -- equivalent call inferred; original call site unknown
		end,
		Nudge = function(p2: number)
			Apply(p2 > 0) -- equivalent call inferred; original call site unknown
		end,
		Hints = { MakePadHint(switch, "Left"), (MakePadHint(switch, "Right")) }
	}
end

local function Wire(childName: string, callback, ...)
	local child = holder:FindFirstChild(childName)

	if child then
		return callback(child, ...)
	end

	warn(string.format("[Settings] no %s row in the panel - skipping it", childName))
	return nil
end

local wire = Wire("Music", SetupSlider, "MusicVolume")
local wire2 = Wire("SFX", SetupSlider, "SFXVolume")
local wire3 = Wire("ViewOtherPets", SetupSwitch, "ViewOtherPets")
local wire4 = Wire("ViewYourPets", SetupSwitch, "ViewYourPets")
local wire5 = Wire("LuckMultiplier", SetupSwitch, "LuckMultiplier")
local paint = wire and wire.Paint
local paint2 = wire2 and wire2.Paint
local set = wire3 and wire3.Set
local set2 = wire4 and wire4.Set
local set3 = wire5 and wire5.Set
local v6 = {}

for _, v7 in {
	wire,
	wire2,
	wire3,
	wire4,
	wire5
} do
	if v7 then
		table.insert(v6, v7)
	end
end

local v7 = 1
local v8 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function GamepadIsLast()
	return string.find(UserInputService:GetLastInputType().Name, "Gamepad") ~= nil
end

local function RefreshPadHints()
	for k, v9 in v6 do
		local visible = v8 and parent.Visible and k == v7

		for _, hint in v9.Hints do
			if visible then
				hint.Image = UserInputService:GetImageForKeyCode(hint.Name == "LeftPadHint" and Enum.KeyCode.ButtonL1 or Enum.KeyCode.ButtonR1)
			end

			hint.Visible = visible
		end

		local uIStroke = v9.Row:FindFirstChildOfClass("UIStroke")

		if not uIStroke then
			continue
		end

		if v9.StrokeColour == nil then
			v9.StrokeColour = uIStroke.Color
		end

		uIStroke.Color = visible and Color3.fromRGB(255, 255, 255) or v9.StrokeColour
	end
end

local function SelectRow(value: number)
	v7 = math.clamp(value, 1, #v6)
	RefreshPadHints()
end

GamepadUI.Watch(parent, function()
	UIController.close(parent)
end, nil, 0, {
	[Enum.KeyCode.DPadDown] = true,
	[Enum.KeyCode.ButtonL1] = true,
	[Enum.KeyCode.ButtonR1] = true
})

local function OnPad(_, p, p2)
	if p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	v8 = true

	if p2.KeyCode == Enum.KeyCode.DPadUp then
		v7 = math.clamp(v7 - 1, 1, #v6)
	elseif p2.KeyCode == Enum.KeyCode.DPadDown then
		v7 = math.clamp(v7 + 1, 1, #v6)
	elseif p2.KeyCode == Enum.KeyCode.ButtonL1 then
		v6[v7].Nudge(-0.1)
	else
		if p2.KeyCode ~= Enum.KeyCode.ButtonR1 then
			return Enum.ContextActionResult.Pass
		end

		v6[v7].Nudge(0.1)
	end

	RefreshPadHints()
	return Enum.ContextActionResult.Sink
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		v8 = GamepadIsLast()
		v7 = 1
		ContextActionService:BindActionAtPriority(
			"SettingsPadNav",
			OnPad,
			false,
			Enum.ContextActionPriority.High.Value,
			Enum.KeyCode.DPadUp,
			Enum.KeyCode.DPadDown,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1
		)
	else
		ContextActionService:UnbindAction("SettingsPadNav")
	end

	RefreshPadHints()
end)
UserInputService.LastInputTypeChanged:Connect(function()
	local v10 = v8
	v8 = GamepadIsLast()

	if v10 ~= v8 then
		RefreshPadHints()
	end
end)

local function Adopt(folder)
	for _, sound in folder:GetDescendants() do
		if sound:IsA("Sound") and sound.SoundGroup == nil then
			sound.SoundGroup = folder
		end
	end

	folder.DescendantAdded:Connect(function(sound)
		if sound:IsA("Sound") and sound.SoundGroup == nil then
			sound.SoundGroup = folder
		end
	end)
end

local music = SoundService:FindFirstChild("Music")
local SFX = SoundService:FindFirstChild("SFX")
local animals = SoundService:FindFirstChild("Animals")

for _, soundGroup in { music, SFX, animals } do
	if soundGroup and soundGroup:IsA("SoundGroup") then
		Adopt(soundGroup)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyMusic(setting_MusicVolume: number)
	if music then
		music.Volume = setting_MusicVolume
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplySFX(setting_SFXVolume: number)
	if SFX then
		SFX.Volume = setting_SFXVolume
	end

	if animals then
		animals.Volume = setting_SFXVolume
	end
end

local function ReadNumber(p: string, p2: number)
	return tonumber(localPlayer:GetAttribute("Setting_" .. p)) or p2
end

local function ReadBoolean(p: string, flag: boolean)
	local attribute = localPlayer:GetAttribute("Setting_" .. p)

	if type(attribute) == "boolean" then
		return attribute
	end

	return flag
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PullMusic()
	local setting_MusicVolume = tonumber(localPlayer:GetAttribute("Setting_MusicVolume")) or 0.5

	if paint then
		paint(setting_MusicVolume)
	end

	ApplyMusic(setting_MusicVolume) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PullSFX()
	local setting_SFXVolume = tonumber(localPlayer:GetAttribute("Setting_SFXVolume")) or 0.5

	if paint2 then
		paint2(setting_SFXVolume)
	end

	ApplySFX(setting_SFXVolume) -- equivalent call inferred; original call site unknown
end

local function PullOthers()
	if set then
		local setting_ViewOtherPets = localPlayer:GetAttribute("Setting_ViewOtherPets")
		set(type(setting_ViewOtherPets) ~= "boolean" or setting_ViewOtherPets)
	end
end

local function PullYours()
	if set2 then
		local setting_ViewYourPets = localPlayer:GetAttribute("Setting_ViewYourPets")
		set2(type(setting_ViewYourPets) ~= "boolean" or setting_ViewYourPets)
	end
end

localPlayer:GetAttributeChangedSignal("Setting_MusicVolume"):Connect(PullMusic)
localPlayer:GetAttributeChangedSignal("Setting_SFXVolume"):Connect(PullSFX)
localPlayer:GetAttributeChangedSignal("Setting_ViewOtherPets"):Connect(PullOthers)
localPlayer:GetAttributeChangedSignal("Setting_ViewYourPets"):Connect(PullYours)
PullMusic() -- equivalent call inferred; original call site unknown
PullSFX() -- equivalent call inferred; original call site unknown

if set then
	local setting_ViewOtherPets = localPlayer:GetAttribute("Setting_ViewOtherPets")
	set(type(setting_ViewOtherPets) ~= "boolean" or setting_ViewOtherPets)
end

if set2 then
	local setting_ViewYourPets = localPlayer:GetAttribute("Setting_ViewYourPets")
	set2(type(setting_ViewYourPets) ~= "boolean" or setting_ViewYourPets)
end

local function PullLuck()
	if set3 then
		local setting_LuckMultiplier = localPlayer:GetAttribute("Setting_LuckMultiplier")
		set3(type(setting_LuckMultiplier) ~= "boolean" or setting_LuckMultiplier)
	end
end

localPlayer:GetAttributeChangedSignal("Setting_LuckMultiplier"):Connect(PullLuck)

if set3 then
	local setting_LuckMultiplier = localPlayer:GetAttribute("Setting_LuckMultiplier")
	set3(type(setting_LuckMultiplier) ~= "boolean" or setting_LuckMultiplier)
end

local clone = nil
local viewOtherPets = holder:FindFirstChild("ViewOtherPets") or holder:FindFirstChild("Music")

if viewOtherPets then
	clone = viewOtherPets:Clone()
	clone.Name = "Commands"

	for _, child in clone:GetChildren() do
		if child:IsA("TextLabel") then
			local v10 = string.upper(string.gsub(child.Text, "%s", ""))

			if v10 == "ON" or v10 == "OFF" then
				child:Destroy()
			end
		elseif child.Name == "Switch" or child.Name == "Slider" or child:IsA("LuaSourceContainer") then
			child:Destroy()
		end
	end

	local textLabel = clone:FindFirstChildWhichIsA("TextLabel")

	if textLabel then
		textLabel.Text = "Commands"
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.Size = UDim2.fromScale(0.8, textLabel.Size.Y.Scale)
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
	end

	local v10 = 0

	for _, guiObject in holder:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Name ~= "LastItem" then
			v10 = math.max(v10, guiObject.LayoutOrder)
		end
	end

	clone.LayoutOrder = v10 + 1
	local lastItem = holder:FindFirstChild("LastItem")

	if lastItem and lastItem.LayoutOrder <= clone.LayoutOrder then
		lastItem.LayoutOrder = clone.LayoutOrder + 1
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "Open"
	textButton.Text = ""
	textButton.BackgroundTransparency = 1
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.ZIndex = 10
	textButton.Selectable = true
	textButton.Parent = clone
	textButton.Activated:Connect(function()
		click:Play()
		UIController.close(parent)
		task.spawn(function()
			local success, result = pcall(function()
				return require(ReplicatedStorage2:WaitForChild("CmdrClient", 10))
			end)

			if success and result then
				result:Show()
			else
				warn("[Settings] Cmdr client not available: " .. tostring(result))
			end
		end)
	end)
	clone.Visible = false
	clone.Parent = holder
else
	warn("[Settings] no row to base the Commands button on - skipping it")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PullAdmin()
	if clone then
		clone.Visible = localPlayer:GetAttribute("CmdrAdmin") == true
	end
end

localPlayer:GetAttributeChangedSignal("CmdrAdmin"):Connect(PullAdmin)
PullAdmin() -- equivalent call inferred; original call site unknown