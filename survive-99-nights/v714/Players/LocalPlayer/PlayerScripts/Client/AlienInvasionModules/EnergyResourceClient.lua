local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EnergyResourceClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local UtilityAlec = require(ReplicatedStorage.Modules.UtilityAlec)
local energyAmmo = 100
local flag = false
local overheatDuration = Client.GlobalSettings.OverheatDuration
local energyReturnPerSecond = Client.GlobalSettings.EnergyReturnPerSecond
local v = 0
local v2 = energyAmmo
local alienBar = nil
local images = {}
local isStudio = RunService:IsStudio()
local flag2 = false
local count = 0
local v3 = nil
local v4 = nil
Client.Events.RegainEnergyAmmo:Connect(function(p)
	if flag then
		return
	end

	EnergyRegainedEffect()
	energyAmmo = math.clamp(energyAmmo + p, 0, 100)
	UpdateEnergyBar()
end)
local v5 = false
local highlight = nil
local v6 = nil
local count2 = 0

function EnergyRegainedEffect()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function DestroyHighlight()
		if highlight then
			highlight.Parent = nil
			highlight.Adornee = nil
			highlight:Destroy()
		end
	end

	if v5 or flag or not (localPlayer.Character and localPlayer.Character:FindFirstChild("TorsoArmour")) then
		return
	end

	v5 = true
	task.spawn(function()
		wait(0.15)
		v5 = false
	end)
	local bar = alienBar.Bar
	local v7 = true
	local torsoArmour = localPlayer.Character:FindFirstChild("TorsoArmour")
	count2 += 1
	local v8 = count2

	if highlight and highlight.Parent then
		highlight.Parent = torsoArmour

		if v6 then
			v6:Cancel()
		end

		highlight.FillTransparency = 0
	else
		v7 = false
		highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(0, 234, 255)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = torsoArmour
	end

	if not v7 then
		v6 = TweenService:Create(highlight, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FillTransparency = 0.25
		})
		v6:Play()
	end

	TweenService:Create(bar, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		BackgroundColor3 = Color3.fromRGB(55, 255, 0)
	}):Play()
	task.spawn(function()
		wait(0.3)

		if flag then
			DestroyHighlight() -- equivalent call inferred; original call site unknown
			bar.BackgroundColor3 = Color3.fromRGB(255, 0, 6)
		else
			TweenService:Create(bar, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				BackgroundColor3 = Color3.fromRGB(0, 234, 255)
			}):Play()
			v6 = TweenService:Create(
				highlight,
				TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					FillTransparency = 1
				}
			)
			v6:Play()
			task.spawn(function()
				wait(0.451)

				if flag then
					DestroyHighlight() -- equivalent call inferred; original call site unknown
					bar.BackgroundColor3 = Color3.fromRGB(255, 0, 6)
				end

				if v8 == count2 and highlight then
					highlight.Parent = nil
					highlight.Adornee = nil
					highlight:Destroy()
				end
			end)
		end
	end)
end

function EnergyResourceClient.ConsumeEnergy(p)
	if game.ReplicatedStorage:GetAttribute("UnlimitedEnergy") and isStudio then
		return
	end

	EnergyResourceClient.GetCurrentEnergy()
	energyAmmo = math.clamp(energyAmmo - p, 0, 100)
	v = time()
	UpdateEnergyBar()

	if energyAmmo <= 0 then
		OverheatEnergyBar()
	end
end

function EnergyResourceClient.CanUseEnergy(p)
	local v7 = math.min(EnergyResourceClient.GetCurrentEnergy(), localPlayer:GetAttribute("EnergyAmmo"))

	if v7 == 0 or p >= 35 and v7 < p * 0.75 or flag then
		return false
	end

	if localPlayer:GetAttribute("EnergyOverheat") then
		return
	else
		return true
	end
end

function EnergyResourceClient.IsOverheating()
	return flag
end

function EnergyResourceClient.GetCurrentEnergy()
	return energyAmmo
end

function EnergyResourceClient.ShowEnergyBar(p)
	UpdateEnergyBar()

	if p then
		for k, v7 in pairs(images) do
			if k == p then
				v7.Visible = true
			end
		end
	end

	Client.Interface.StatBars.ExtraBars.AlienBar.Visible = true
end

function EnergyResourceClient.HideEnergyBar()
	Client.Interface.StatBars.ExtraBars.AlienBar.Visible = false
end

function UpdateEnergyBar()
	if flag then
		return
	end

	local currentEnergy = EnergyResourceClient.GetCurrentEnergy()
	local v7 = currentEnergy / 100
	Client.Interface.StatBars.ExtraBars.AlienBar.Bar.Size = UDim2.new(v7, 0, 1, 0)

	if currentEnergy ~= v2 then
		Client.Events.EnergyChanged:Fire(currentEnergy)
	end

	v2 = currentEnergy
end

function OverheatEnergyBar()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		wait(1)

		if not localPlayer:GetAttribute("EnergyOverheat") then
			EndEnergyOverheating()
		end
	end)
	OverheatEnergyBarEffect()
end

function EndEnergyOverheating()
	energyAmmo = localPlayer:GetAttribute("EnergyAmmo")
	flag = false
	OverheatEndedEnergyBarEffect()
	UpdateEnergyBar()
end

localPlayer:GetAttributeChangedSignal("EnergyOverheat"):Connect(function()
	if localPlayer:GetAttribute("EnergyOverheat") then
		OverheatEnergyBar()
	else
		EndEnergyOverheating()
	end
end)
local tweens = {}

function OverheatEnergyBarEffect()
	if not (localPlayer.Character and localPlayer.Character:FindFirstChild("Head")) then
		return
	end

	Client.Sound.Play("Alien_NoEnergy", {
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.4
		}
	})

	if v3 then
		v3:Destroy()
	end

	ReplicatedStorage.Core.Sounds.Alien_EnergyWarning:Play()
	task.spawn(function()
		local bar = alienBar.Bar
		bar.BackgroundColor3 = Color3.fromRGB(255, 0, 6)
		local tween = TweenService:Create(bar, TweenInfo.new(overheatDuration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(1, 0, 1, 0)
		})
		tween:Play()
		table.insert(tweens, tween)

		while flag do
			local v7 = alienBar
			v7.BackgroundColor3 = Color3.fromRGB(35, 0, 1)
			local tween2 = TweenService:Create(
				v7,
				TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundColor3 = Color3.fromRGB(106, 27, 29)
				}
			)
			tween2:Play()
			table.insert(tweens, tween2)
			wait(0.75)

			if not flag then
				continue
			end

			local tween3 = TweenService:Create(
				v7,
				TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					BackgroundColor3 = Color3.fromRGB(35, 0, 1)
				}
			)
			tween3:Play()
			table.insert(tweens, tween3)
			wait(0.75)
		end
	end)
end

function OverheatEndedEnergyBarEffect()
	for _, v7 in pairs(tweens) do
		v7:Cancel()
	end

	ReplicatedStorage.Core.Sounds.Alien_EnergyWarning:Stop()
	alienBar.BackgroundColor3 = Color3.fromRGB(0, 10, 104)
	local bar = alienBar.Bar
	bar.BackgroundColor3 = Color3.fromRGB(0, 234, 255)
	bar.Size = UDim2.new(1, 0, 1, 0)
end

function EnergyResourceClient.EnergyTooLowIndicator(p, cost)
	if flag or flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		wait(0.1)
		flag2 = false
	end)
	local _ = alienBar.Bar
	local clone = alienBar.WarningBar:Clone()
	local v7 = p / 100

	if cost > 35 then
		cost *= 0.75
	end

	local v8 = cost / 100 - v7
	count += 1
	local v9 = count
	local v10 = false

	if v3 then
		v10 = true
		clone = v3

		if v4 then
			v4:Cancel()
		end

		clone.BackgroundTransparency = 0.35
	else
		clone.Parent = alienBar
		clone.BackgroundTransparency = 1
	end

	clone.Position = UDim2.new(v7, 0, 0, 0)
	clone.Size = UDim2.new(v8, 0, 1, 0)
	clone.Visible = true
	clone:SetAttribute("Cost", cost)
	v3 = clone

	if not v10 then
		TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			BackgroundTransparency = 0.35
		}):Play()
	end

	task.spawn(function()
		wait(0.15)

		if count == v9 then
			v4 = TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 1
			})
			v4:Play()
		end
	end)
	task.spawn(function()
		wait(0.46)

		if clone and count == v9 then
			clone:Destroy()
			v3 = nil
		end
	end)
end

function EnergyResourceClient.Init()
	task.spawn(function()
		alienBar = Client.Interface.StatBars.ExtraBars.AlienBar

		while true do
			local v7 = task.wait(0.25)

			if not (energyAmmo < 100) then
				continue
			end

			if not flag then
				local v8 = energyReturnPerSecond * v7

				if localPlayer:GetAttribute("Class") == "Alien" then
					v8 *= Client.GlobalSettings.AlienClassEnergyRechargeMultiplier
				end

				if localPlayer:GetAttribute("AlienEssencePct") then
					local v9 = math.clamp(localPlayer:GetAttribute("AlienEssencePct") / 100, 0, 1)
					v8 *= 1 + Client.GlobalSettings.AlienScientistClassEnergyRechargeMultiplier * v9
				end

				energyAmmo = math.clamp(energyAmmo + v8, 0, 100)
			end

			UpdateEnergyBar()
		end
	end)
	task.spawn(function()
		UtilityAlec.preload({ "rbxassetid://100242403593887" })
	end)

	for _, image in pairs(Client.Interface.StatBars.ExtraBars.AlienBar.IconHolder:GetChildren()) do
		if not (image:IsA("ImageLabel") and image.Name:sub(1, 4) == "Icon") then
			continue
		end

		image.Visible = false
		images[image.Name:sub(5)] = image
	end

	Client.Events.EnergyChanged:Connect(function(p)
		if v3 then
			local v7 = v3
			local cost = v7:GetAttribute("Cost")

			if not cost then
				return
			end

			local v8 = p / 100
			local v9 = cost / 100 - v8
			v7.Position = UDim2.new(v8, 0, 0, 0)
			v7.Size = UDim2.new(v9, 0, 1, 0)
		end

		if p == 100 and alienBar.Visible then
			Client.Sound.Play("Alien_EnergyBack", {
				Duplicate = true
			})
		end
	end)
end

return EnergyResourceClient