local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TemperatureClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local count = 0
local v = false
local total = 1
local flag = false

function PlayerInWarmZone()
	local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart

	if not primaryPart then
		return false
	end

	local touchingParts = primaryPart:GetTouchingParts()

	for _, touchingPart in pairs(touchingParts) do
		if touchingPart:HasTag("SnowBiomeWarmZone") then
			return true
		end
	end

	return false
end

function WarmZoneEntered()
	if flag then
		return
	end

	print("warm zone enter")
	flag = true
	Client.ColorCorrectionLightingClient.ToggleFire(true)
	task.spawn(function()
		repeat
			task.wait(0.25)
		until not PlayerInWarmZone()

		WarmZoneExited()
	end)
end

function WarmZoneExited()
	print("warm zone exit")
	Client.ColorCorrectionLightingClient.ToggleFire(false)
	flag = false
end

function WarmZoneAdded(p)
	p.Touched:Connect(function(otherPart)
		if localPlayer.Character and otherPart == localPlayer.Character.PrimaryPart then
			WarmZoneEntered()
		end
	end)
end

function TemperatureUpdated()
	local temperature = localPlayer:GetAttribute("Temperature") or 100
	local frame = Client.Interface.TemperatureFrame.Frame
	local fill = frame.Fill

	if temperature < 100 and temperature > 0 then
		frame.Parent.Visible = true
	elseif temperature <= 0 then
		v = true
		TemperatureClient.BarEmpty()
	else
		total += 1
	end

	if v and temperature > 0 then
		TemperatureClient.BarNotEmpty()
	end

	fill.Size = UDim2.new(temperature / 100, 0, 1, 0)
	task.spawn(function()
		if temperature >= 100 then
			count += 1
			local v2 = count
			wait(1)

			if count == v2 then
				frame.Parent.Visible = false
			end
		end
	end)
end

local flag2 = false

function ToggleParticles(player, p)
	if not (player.Character and player.Character:FindFirstChild("Torso")) then
		return
	end

	if p then
		for _, child in pairs(ReplicatedStorage.Assets.Particles.FrozenParticles.Torso:GetChildren()) do
			local clone = child:Clone()
			clone.Name = "FrozenAura"
			clone.Parent = player.Character.Torso
		end
	else
		for _, child in pairs(player.Character.Torso:GetChildren()) do
			if child.Name == "FrozenAura" then
				child:Destroy()
			end
		end
	end

	if player == localPlayer then
		Client.Events.ReplicateFrozenParticles:FireServer(p)
	end
end

Client.Events.ReplicateFrozenParticles:Connect(function(p, p2)
	if p ~= localPlayer then
		ToggleParticles(p, p2)
	end
end)

function TemperatureClient.FlashBar()
	local frame = Client.Interface.TemperatureFrame.Frame
	local _ = frame.Fill
	frame.BackgroundColor3 = Color3.fromRGB(255, 131, 133)
	total += 1
end

function TemperatureClient.BarNotEmpty()
	local frame = Client.Interface.TemperatureFrame.Frame
	local _ = frame.Fill
	flag2 = false
	total += 0
	frame.BackgroundColor3 = Color3.fromRGB(0, 195, 255)
	TweenService:Create(frame, TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		BackgroundColor3 = Color3.fromRGB(0, 195, 255)
	}):Play()
	Client.WalkspeedController.PlayerFrozen(false)
	local frozenWarning = Client.Interface.StatBars.HungerBar.FrozenWarning

	if frozenWarning.Visible then
		frozenWarning.Visible = false
		frozenWarning.Parent.SprintWarning.Visible = true
	end

	Client.Interface.border1.Visible = false
	frozenWarning.Parent.Bar.BackgroundColor3 = Color3.fromRGB(255, 123, 57)
	ToggleParticles(localPlayer, false)
end

local v2 = false

function TemperatureClient.BarEmpty()
	if flag2 then
		return
	end

	flag2 = true
	ToggleParticles(localPlayer, true)

	if not v2 then
		v2 = true
		Client.PopUpUI.AddPopUp("you are too cold to sprint", "blue")
		Client.Sound.Play("Frozen")
		task.spawn(function()
			wait(120)
			v2 = false
		end)
	end

	TemperatureClient.FlashBar()
	Client.WalkspeedController.PlayerFrozen(true)
	local sprintWarning = Client.Interface.StatBars.HungerBar.SprintWarning
	sprintWarning.Parent.Bar.BackgroundColor3 = Color3.fromRGB(102, 165, 247)

	if sprintWarning.Visible then
		sprintWarning.Visible = false
		sprintWarning.Parent.FrozenWarning.Visible = true
	end

	Client.Interface.border1.Visible = true
end

local count2 = 0

function TemperatureClient.FlashBarRed()
	local fill = Client.Interface.TemperatureFrame.Frame.Fill
	count2 += 1
	local v3 = count2
	TweenService:Create(fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		BackgroundColor3 = Color3.fromRGB(255, 128, 128)
	}):Play()
	task.spawn(function()
		wait(0.1)

		if v3 == count2 then
			TweenService:Create(fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end
	end)
end

Client.Events.FlashTemperatureBarRed:Connect(function()
	TemperatureClient.FlashBarRed()
end)

function TemperatureClient.Init()
	Client.Utility.ForAllTagged("SnowBiomeWarmZone", WarmZoneAdded)
	localPlayer:GetAttributeChangedSignal("Temperature"):Connect(TemperatureUpdated)
	TemperatureUpdated()
end

return TemperatureClient