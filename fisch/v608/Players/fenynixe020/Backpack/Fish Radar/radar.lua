local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local parent = script.Parent
local localPlayer = game.Players.LocalPlayer
local GeneralUIModule = require(ReplicatedStorage.shared.modules.GeneralUIModule)
local fx = require(ReplicatedStorage.shared.modules.fx)
local debris = require(ReplicatedStorage.shared.modules.fx.debris)
local v = nil
local v2 = false
local radarToggleEvent = ReplicatedStorage:WaitForChild("RadarToggleEvent")

local function applyRadarState(radarEnabled)
	for _, instance in pairs(CollectionService:GetTagged("radarTag")) do
		if instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
			instance.Enabled = radarEnabled
		end

		if not (instance:FindFirstChild("abundanceName") and instance:FindFirstChild("abundanceName").Text == "Ancient Depth Serpent") then
			continue
		end

		instance.Enabled = false
	end
end

local function showToggleFeedback(p)
	local clone = script:WaitForChild("ui"):Clone()
	clone.Text = p and "[Radar Enabled]" or "[Radar Disabled]"
	clone.Parent = localPlayer.PlayerGui.hud
	clone.Visible = true
	local TweenService = game:GetService("TweenService")
	TweenService:Create(clone.UIStroke, TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(clone.shine, TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	debris:AddItem(clone, 2)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Saturation = -1
	colorCorrectionEffect.TintColor = Color3.fromRGB(209, 255, 199)
	colorCorrectionEffect.Parent = game:GetService("Lighting")
	local TweenService3 = game:GetService("TweenService")
	TweenService3:Create(colorCorrectionEffect, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		Saturation = 0,
		TintColor = Color3.fromRGB(255, 255, 255)
	}):Play()
	debris:AddItem(colorCorrectionEffect, 2)
end

localPlayer:GetAttributeChangedSignal("RadarEnabled"):Connect(function()
	local radarEnabled = localPlayer:GetAttribute("RadarEnabled") or false
	applyRadarState(radarEnabled)
end)
radarToggleEvent.OnClientEvent:Connect(function(p, p2)
	if p == "userToggled" then
		if p2 then
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.item.RadarOn, script.Parent:WaitForChild("handle"))
		else
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.item.RadarOff, script.Parent:WaitForChild("handle"))
		end

		showToggleFeedback(p2)
	end
end)

local function ToTime(p: number)
	local v3 = math.floor(p / 60 / 60)
	local v4 = os.date("%M", p)
	local v5 = os.date("%S", p)
	return (tonumber(v3) or 0) >= 1 and `{v3}:{v4}:{v5}` or `{v4}:{v5}`
end

if not parent:IsA("Tool") then
	return
end

parent.Equipped:Connect(function()
	if v then
		v:Remove()
	end

	v = GeneralUIModule:GiveToolTip(
		localPlayer,
		"[Interact to toggle '<b><font color = '#9eff80'>Fish Abundance Radar</font></b>']"
	)
	local radarEnabled = localPlayer:GetAttribute("RadarEnabled") or false
	applyRadarState(radarEnabled)
end)
parent.Unequipped:Connect(function()
	if v then
		v:Remove()
	end

	v = nil
end)
parent.Activated:Connect(function()
	if v2 == false then
		v2 = true
		radarToggleEvent:FireServer("toggle", not localPlayer:GetAttribute("RadarEnabled"))
		task.wait(2)
		v2 = false
	end
end)
task.spawn(function()
	while true do
		if (localPlayer:GetAttribute("RadarEnabled") or false) == true then
			local serverTimeNow = workspace:GetServerTimeNow()

			for _, v3 in CollectionService:GetTagged("radarTagWithTimer") do
				local parent2 = v3.Parent

				if not parent2 then
					continue
				end

				local text = parent2:GetAttribute("Text")

				if not text then
					continue
				end

				local endClock = parent2:GetAttribute("EndClock")

				if not endClock then
					continue
				end

				local v4 = math.clamp(endClock - serverTimeNow, 0, 1e999)

				if v4 <= 0 then
					v3.abundanceName.Text = "Disappearing Soon"
				else
					v3.abundanceName.Text = string.format(text, (ToTime(v4)))
				end
			end
		end

		task.wait(1)
	end
end)
CollectionService:GetInstanceAddedSignal("radarTag"):Connect(function(instance)
	if instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
		instance.Enabled = localPlayer:GetAttribute("RadarEnabled") or false

		if instance:FindFirstChild("abundanceName") and instance:FindFirstChild("abundanceName").Text == "Ancient Depth Serpent" then
			instance.Enabled = false
		end
	end
end)
CollectionService:GetInstanceAddedSignal("radarTagWithTimer"):Connect(function(instance)
	if instance:IsA("BillboardGui") or instance:IsA("SurfaceGui") then
		instance.Enabled = localPlayer:GetAttribute("RadarEnabled") or false
	end
end)
applyRadarState(localPlayer:GetAttribute("RadarEnabled") or false)