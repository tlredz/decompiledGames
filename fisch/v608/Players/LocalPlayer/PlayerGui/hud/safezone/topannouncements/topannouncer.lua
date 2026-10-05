local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.library.fish)
require(ReplicatedStorage.shared.modules.library.rods)
require(ReplicatedStorage.shared.modules.GeneralUIModule)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local fx = require(ReplicatedStorage.shared.modules:WaitForChild("fx"))
local debris = require(ReplicatedStorage.shared.modules:WaitForChild("fx"):WaitForChild("debris"))

function toHex(color: Color3)
	return "#" .. color:ToHex()
end

ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_top").OnClientEvent:Connect(function(text, image, p, p2)
	if game.Players.LocalPlayer:GetAttribute("StopTopAnnounces") or not SettingsController:GetSettingValue("announcesTop") then
		return
	end

	local v = p == nil and 0 or p
	local clone = script:WaitForChild("ui"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)

	if image ~= nil then
		clone.Icon.Image = image
		clone.Icon.ImageTransparency = 1
		clone.Icon.Visible = true
	end

	clone.Main.Text = text
	clone.Parent = script.Parent
	clone.Visible = true
	local topnotify = ReplicatedStorage.resources.sounds.sfx.ui.topnotify
	local SoundService = game:GetService("SoundService")
	fx:PlaySound(topnotify, SoundService, p2 or false)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}):Play()
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}):Play()
	local TweenService3 = game:GetService("TweenService")
	TweenService3:Create(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}):Play()
	task.wait(9 + v)
	local TweenService4 = game:GetService("TweenService")
	TweenService4:Create(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}):Play()
	local TweenService5 = game:GetService("TweenService")
	TweenService5:Create(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	local TweenService6 = game:GetService("TweenService")
	TweenService6:Create(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	debris:AddItem(clone, 1)
end)
ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_serverEvent").OnClientEvent:Connect(function(text, image, p, p2)
	if game.Players.LocalPlayer:GetAttribute("StopTopAnnounces") or not SettingsController:GetSettingValue("announcesTop") then
		return
	end

	local v = p == nil and 0 or p
	local clone = script:WaitForChild("event"):Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)

	if image ~= nil then
		clone.Icon.Image = image
		clone.Icon.ImageTransparency = 1
		clone.Icon.Visible = true
	end

	clone.Main.Text = text
	clone.Parent = script.Parent
	clone.Visible = true
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.topnotify, nil, false)

	if p2 then
		fx:PlaySound(p2, script.Parent, false)
	end

	local TweenService = game:GetService("TweenService")
	TweenService:Create(clone.Icon, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}):Play()
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(clone.Main, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}):Play()
	local TweenService3 = game:GetService("TweenService")
	TweenService3:Create(clone.Shine, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}):Play()
	task.wait(9 + v)
	local TweenService4 = game:GetService("TweenService")
	TweenService4:Create(clone.Main, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = UDim2.new(0.5, 0, -0.3, 0),
		TextStrokeTransparency = 1
	}):Play()
	local TweenService5 = game:GetService("TweenService")
	TweenService5:Create(clone.Shine, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	local TweenService6 = game:GetService("TweenService")
	TweenService6:Create(clone.Icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	debris:AddItem(clone, 1)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScale(settingValue)
	script.Parent.UIScale.Scale = settingValue
end

SettingsController:GetSettingChangedSignal("announcesTopScale"):Connect(updateScale)
updateScale(SettingsController:GetSettingValue("announcesTopScale")) -- equivalent call inferred; original call site unknown