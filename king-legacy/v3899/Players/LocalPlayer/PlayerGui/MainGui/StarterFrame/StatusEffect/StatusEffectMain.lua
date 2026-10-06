local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local characterPassives = character:WaitForChild("CharacterPassives", 12)

while not localPlayer:FindFirstChild("DataLoaded") do
	task.wait(1)
end

local playerStats = localPlayer:WaitForChild("PlayerStats")
local raceTbl = playerStats:WaitForChild("RaceTbl")
local parent = script.Parent
local raceV3 = parent:WaitForChild("RaceV3")
local shipSkillButton = parent:WaitForChild("ShipSkillButton")
local v = {}
local TweenService = game:GetService("TweenService")
local PassiveList = require(ReplicatedStorage.Chest.Modules.PassiveList)
local SpecialStatusList = require(ReplicatedStorage.Chest.Modules.SpecialStatusList)
require(ReplicatedStorage.Chest.Modules.MaterialList)
local ShipList = require(ReplicatedStorage.Chest.Modules.ShipList)
local passiveInfoFrame = parent.Parent.Parent.StarterFrame.PassiveInfoFrame

function ConvertTimeText(p)
	local v2 = tostring((math.floor(p))) .. "s"

	if not p then
		return v2
	end

	if p >= 10 and p < 60 then
		return tostring((math.floor(p))) .. "s"
	end

	if p >= 60 then
		return math.floor(p / 60) .. "m"
	end

	return tostring(math.floor(p * 10) / 10) .. "s"
end

task.spawn(function()
	local uIGradient = passiveInfoFrame.IconLabel.ImageLabel.UIStroke.UIGradient
	local uIGradient2 = passiveInfoFrame.BG.UIStroke.UIGradient

	while true do
		if passiveInfoFrame.Visible then
			local v2 = task.wait() * 60
			uIGradient.Rotation = (uIGradient.Rotation + v2 * 2) % 360
			uIGradient2.Rotation = (uIGradient2.Rotation + v2 * 2) % 360
		else
			task.wait()
			passiveInfoFrame:GetPropertyChangedSignal("Visible"):Wait()
		end
	end
end)
local v2 = {
	Fatigued = {
		Duration = 10,
		Image = "rbxassetid://103597235795549"
	},
	Burning = {
		Duration = 6,
		Image = "http://www.roblox.com/asset/?id=15585702455"
	},
	AntiHeal = {
		Duration = 10,
		Image = "http://www.roblox.com/asset/?id=15600647902"
	},
	Freezing = {
		Duration = 6,
		Image = "http://www.roblox.com/asset/?id=15585703642"
	},
	Dizzy = {
		Image = "http://www.roblox.com/asset/?id=15585707349"
	},
	Gale = {
		Duration = 8,
		Image = "http://www.roblox.com/asset/?id=15585708843"
	},
	Teleport = {
		Duration = 15,
		Image = "rbxassetid://133483690086684"
	},
	Conqueror = {
		Duration = _G.ConquerorCDClient,
		Image = "rbxassetid://140455427567400"
	},
	Danger = {
		Duration = _G.DangerTimeClient,
		Image = "rbxassetid://120040794294848"
	},
	PvPDisabled = {
		Image = "rbxassetid://132761955296366"
	},
	BuddhaOrb = {
		Duration = 30,
		Image = "rbxassetid://16741874300"
	},
	SlowRegen = {
		Image = "rbxassetid://16857445493"
	},
	SpeedBoost = {
		Image = "rbxassetid://111162213392334"
	},
	Sprinter = {
		Image = "rbxassetid://115095379415535"
	},
	HyperArmor = {
		Image = "rbxassetid://16857448955"
	},
	["Last Stand"] = {
		Image = "rbxassetid://16857452268"
	},
	Dazzle = {
		Image = "rbxassetid://16857430900"
	},
	Weak = {
		Image = "rbxassetid://16857435849"
	}
}

function FixStatusName(p)
	if p == "SlowRegen" then
		return "Healing Havoc"
	elseif p == "SpeedBoost" then
		return "Swift"
	elseif p == "Weak" then
		return "Debility"
	elseif p == "HyperArmor" then
		return "Hyper Armor"
	end

	return p == "BuddhaOrb" and "Buddha Orb" or p
end

function SetDefaultEffectButton(data, p)
	local image = p.Image
	local attribute = p.Attribute
	local text = FixStatusName(attribute)
	local flag = nil
	v[data] = data.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag = true
		_G.ClickFrameEffect({
			Sound = true,
			Sound2 = true
		})
		passiveInfoFrame.IconLabel.ImageLabel.Image = image

		if image == "Legacy Fruit" then
			passiveInfoFrame.IconLabel.ImageLabel.Image = data.Frame.ImageLabel.Image
		end

		passiveInfoFrame.NameLabel.Text = text
		data.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(
			data.Frame.ImageLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
			{
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			}
		):Play()

		if PassiveList[text] then
			passiveInfoFrame.InfoLabel.Text = PassiveList[text].Info

			if localPlayer.PlayerStats.Language.Value == "TH" then
				passiveInfoFrame.InfoLabel.Text = PassiveList[text].InfoTH
			end
		elseif SpecialStatusList[text] then
			passiveInfoFrame.InfoLabel.Text = SpecialStatusList[text].Info

			if localPlayer.PlayerStats.Language.Value == "TH" then
				passiveInfoFrame.InfoLabel.Text = SpecialStatusList[text].InfoTH
			end
		else
			passiveInfoFrame.InfoLabel.Text = "N/A"
		end

		passiveInfoFrame.Size = UDim2.new(0, 0, 0, 0)
		passiveInfoFrame.Visible = true
		TweenService:Create(passiveInfoFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
			Size = UDim2.new(0.323, 0, 0.222, 0)
		}):Play()
		task.delay(0.02, function()
			flag = nil
		end)
	end)
	data.MouseEnter:Connect(function()
		data.Frame.TextLabel.Text = text
		data.Frame.TextLabel.Visible = true
	end)
	data.MouseLeave:Connect(function()
		data.Frame.TextLabel.Visible = false
	end)
end

local thread = nil
local thread2 = nil
local tweens = {}
local left = shipSkillButton.Frame.CanvasGroup.Left
local right = shipSkillButton.Frame.CanvasGroup.Right

function UpdateShipSkillVisible()
	wait()
	local visible = nil
	local cooldown = nil
	local seatPart = humanoid.SeatPart

	if seatPart and seatPart:IsA("VehicleSeat") and seatPart.Parent then
		local shipType = seatPart.Parent:GetAttribute("ShipType")

		if shipType and ShipList[shipType] and ShipList[shipType].Skill and _G.CheckAwakeClient(
			localPlayer,
			shipType .. " Ability"
		) then
			cooldown = seatPart.Parent:GetAttribute("Cooldown")
			visible = true
		end
	end

	shipSkillButton.Visible = visible

	if visible and cooldown then
		BeginShipCooldown(60, cooldown)
	end
end

function ResetShipRadial()
	right.Visible = true
	left.Visible = true
	left.UIGradient.Rotation = 0
	right.UIGradient.Rotation = 0
end

function BeginShipCooldown(max: number, p: number)
	if thread2 then
		task.cancel(thread2)
		thread2 = nil
	end

	if thread then
		task.cancel(thread)
		thread = nil
	end

	for _, v3 in pairs(tweens) do
		v3:Pause()
	end

	table.clear(tweens)
	ResetShipRadial()
	local now = os.time()
	local v3 = max - (not p and 0 or math.clamp(now - p, 0, max))
	local v4 = math.max(v3, max / 2)
	local v5 = math.clamp(v3, 0, max / 2)
	local rotation = (1 - v4 / max) * 180 * 2
	local rotation2 = (1 - v5 / (max / 2)) * 180
	right.UIGradient.Rotation = rotation
	left.UIGradient.Rotation = rotation2
	local v8 = math.max(v4 - max / 2, 0)
	local v9 = math.max(v5, 0)
	local TweenService2 = game:GetService("TweenService")
	local tween = TweenService2:Create(right.UIGradient, TweenInfo.new(v8, Enum.EasingStyle.Linear), {
		Rotation = 180
	})
	local TweenService3 = game:GetService("TweenService")
	local tween2 = TweenService3:Create(left.UIGradient, TweenInfo.new(v9, Enum.EasingStyle.Linear), {
		Rotation = 180
	})
	thread = task.spawn(function()
		if v8 > 0 then
			tween:Play()
			tween.Completed:Wait()
		end

		if v9 > 0 then
			tween2:Play()
			tween2.Completed:Wait()
		end
	end)
	table.insert(tweens, tween)
	table.insert(tweens, tween2)
	shipSkillButton.Frame.TextLabel.Visible = true
	local v10 = p or os.time()
	thread2 = task.spawn(function()
		while true do
			local v11 = os.time() - v10

			if max <= v11 or not shipSkillButton.Visible then
				break
			end

			shipSkillButton.Frame.TextLabel.Text = math.max(max - math.floor(v11), 0)
			task.wait(0.5)
		end

		shipSkillButton.Frame.TextLabel.Visible = false
		right.Visible = false
		left.Visible = false
	end)
end

function CanUseShipSkill()
	local seatPart = humanoid.SeatPart

	if not (seatPart and seatPart.Parent and seatPart:IsA("VehicleSeat")) then
		return
	end

	local shipType = seatPart.Parent:GetAttribute("ShipType")

	if not (shipType and ShipList[shipType] and ShipList[shipType].Skill) then
		return
	end

	if _G.CheckAwakeClient(localPlayer, shipType .. " Ability") then
		return true
	end
end

shipSkillButton.MouseButton1Click:Connect(function()
	wait()

	if not CanUseShipSkill() then
		return
	end

	if ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SHIP") then
		BeginShipCooldown(60)
	end
end)
local v3 = nil
local v4 = {}

function UpdateSize()
	local uIGridLayout = parent.UIGridLayout
	uIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	uIGridLayout.CellSize = UDim2.new(0, (parent.AbsoluteSize.X - 0) / 3, 0, (parent.AbsoluteSize.Y - 0) / 4)
end

UpdateSize()
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateSize()
end)

function AttributeChanged(name)
	if not v2[name] then
		return
	end

	UpdateSize()

	if character:GetAttribute(name) == nil then
		if parent:FindFirstChild(name) then
			v4[name] = nil
			parent[name]:Destroy()
		end
	else
		if v4[name] then
			return
		end

		v4[name] = true
		local clone = parent:FindFirstChild(name)

		if not clone then
			clone = script.EffectButton:Clone()
			clone.Name = name
			clone.Visible = true
		end

		local duration = v2[name].Duration
		local image = v2[name].Image
		SetDefaultEffectButton(clone, {
			Image = image,
			Attribute = name
		})
		clone.Frame.ImageLabel.Image = image

		if duration then
			if name == "Teleport" and _G.RaceClient == "Human" and _G.CheckAwakeClient(localPlayer, "HumanV2") then
				duration /= 2
			end

			if character:GetAttribute("Teleport") then
				duration = character:GetAttribute("Teleport")
			end

			clone.Frame.TimeValue.Value = duration
			local v5 = character
			local timeLabel = clone.Frame.TimeLabel
			local timeValue = clone.Frame.TimeValue

			if name == "Danger" then
				v3 = TweenService:Create(timeValue, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Value = 0
				})
				v3:Play()
			else
				TweenService:Create(timeValue, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
					Value = 0
				}):Play()
			end

			local valueChangedConnection = nil
			valueChangedConnection = timeValue:GetPropertyChangedSignal("Value"):Connect(function()
				wait()
				timeLabel.Text = ConvertTimeText(timeValue.Value)

				if (timeValue.Value <= 0.05 or v5 ~= character) and valueChangedConnection and valueChangedConnection.Connected then
					valueChangedConnection:Disconnect()

					if v[clone] and v[clone].Connected then
						v[clone]:Disconnect()
						v[clone] = nil
					end

					clone:Destroy()
					v4[name] = nil
				end
			end)
		else
			v4[name] = nil
		end

		clone.Parent = parent
	end
end

function UpdateAddedPassives(instance)
	wait()
	local v5 = v2[instance.Name]

	if not v5 or instance:GetAttribute("Hide") then
		return
	end

	local duration = v5.Duration or instance:GetAttribute("Duration") or 5
	local clone = script.EffectButton:Clone()
	clone.Name = instance.Name
	clone.Visible = true
	clone.Frame.ImageLabel.Image = v5.Image
	SetDefaultEffectButton(clone, {
		Image = v5.Image,
		Attribute = instance.Name
	})

	if duration then
		clone.Frame.TimeValue.Value = duration
		local v6 = character
		local timeLabel = clone.Frame.TimeLabel
		local timeValue = clone.Frame.TimeValue
		TweenService:Create(timeValue, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Value = 0
		}):Play()
		local valueChangedConnection = nil
		valueChangedConnection = timeValue:GetPropertyChangedSignal("Value"):Connect(function()
			wait()
			timeLabel.Text = ConvertTimeText(timeValue.Value)

			if (timeValue.Value <= 0.05 or v6 ~= character) and valueChangedConnection and valueChangedConnection.Connected then
				valueChangedConnection:Disconnect()

				if v[clone] and v[clone].Connected then
					v[clone]:Disconnect()
					v[clone] = nil
				end

				clone:Destroy()
			end
		end)
		task.spawn(function()
			task.wait(duration)

			if valueChangedConnection and valueChangedConnection.Connected then
				valueChangedConnection:Disconnect()
			end
		end)
	end

	clone.Parent = parent
	_G.PU:Dust(clone, duration)
end

_G.UpdateRaceIcon({
	LocalPlayer = localPlayer,
	RaceTbl = raceTbl,
	RaceButtonImages = _G.RaceButtonImages,
	RaceV3Button = raceV3,
	StatusFrame = parent
})
humanoid:GetPropertyChangedSignal("SeatPart"):Connect(UpdateShipSkillVisible)
raceTbl.Changed:Connect(function()
	wait()
	_G.UpdateRaceIcon({
		LocalPlayer = localPlayer,
		RaceTbl = raceTbl,
		RaceButtonImages = _G.RaceButtonImages,
		RaceV3Button = raceV3,
		StatusFrame = parent
	})
end)
playerStats.Misc.Changed:Connect(function()
	wait()
	_G.UpdateRaceIcon({
		LocalPlayer = localPlayer,
		RaceTbl = raceTbl,
		RaceButtonImages = _G.RaceButtonImages,
		RaceV3Button = raceV3,
		StatusFrame = parent
	})
end)

function SetupCharacter(p)
	character = p
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	characterPassives = character:WaitForChild("CharacterPassives", 12)
	character.AttributeChanged:Connect(AttributeChanged)
	character.ChildAdded:Connect(UpdateAddedPassives)
	humanoid:GetPropertyChangedSignal("SeatPart"):Connect(UpdateShipSkillVisible)
	AttributeChanged("Teleport")

	if localPlayer:FindFirstChild("DataLoaded") and localPlayer:FindFirstChild("PlayerStats") and localPlayer.PlayerStats.HAOHAKI.Value == "HAOYOUHAVEIT" or localPlayer.PlayerStats.haogamepass.Value == "HAOYOUHAVEIT" then
		AttributeChanged("Conqueror")
	end
end

if localPlayer.Character then
	SetupCharacter(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(SetupCharacter)
task.spawn(function()
	while task.wait(0.1) do
		for childName, v5 in pairs(PassiveList) do
			if characterPassives:FindFirstChild(childName) then
				if not parent:FindFirstChild(childName) and v5.AlwaysActive and (childName ~= "Last Breath" or character:GetAttribute("LastBreathable")) then
					local clone = script.EffectButton:Clone()
					clone.Name = childName
					clone.Frame.ImageLabel.Image = v5.Image
					clone.Parent = parent
					SetDefaultEffectButton(clone, {
						Image = v5.Image,
						Attribute = childName
					})
				end
			elseif parent:FindFirstChild(childName) then
				parent[childName]:Destroy()
			end
		end

		if localPlayer.PvpOffTime.Value > 0 then
			local value = localPlayer.PvpOffTime.Value
			local v5 = math.max(2400 - (os.time() - value), 0)

			if v5 > 0 then
				if not parent.PvPDisabled.Visible then
					parent.PvPDisabled.Visible = true
				end

				local text = math.floor(v5 / 60) .. "m"

				if v5 < 60 then
					text = math.floor(v5) .. "s"
				end

				parent.PvPDisabled.Frame.TimeLabel.Text = text
			else
				parent.PvPDisabled.Visible = false
			end
		elseif parent.PvPDisabled.Visible then
			parent.PvPDisabled.Visible = false
		end

		if localPlayer.Danger.Time.Value > 0 and localPlayer.Danger.Value ~= "Danger" and parent:FindFirstChild("Danger") then
			local v5 = math.floor(tick() - _G.LastUpdate)
			local v6 = math.max(v2.Danger.Duration - v5, 0)

			if not parent.Danger.Visible then
				parent.Danger.Visible = true
			end

			parent.Danger.Frame.TimeLabel.Text = ConvertTimeText(v6)

			if v6 <= 0 then
				parent.Danger.Visible = nil
			end
		elseif parent.Danger.Visible then
			parent.Danger.Visible = false
		end

		if humanoid.Health <= humanoid.MaxHealth * 50 / 100 then
			if characterPassives:FindFirstChild("Stylish Heal") and not parent:FindFirstChild("Stylish Heal") then
				local clone = script.EffectButton:Clone()
				clone.Name = "Stylish Heal"
				clone.Frame.ImageLabel.Image = "rbxassetid://16857487585"
				clone.Parent = parent
				SetDefaultEffectButton(clone, {
					Image = "rbxassetid://16857487585",
					Attribute = "Stylish Heal"
				})
			end
		elseif parent:FindFirstChild("Stylish Heal") then
			parent["Stylish Heal"]:Destroy()
		end

		if parent:FindFirstChild("Last Breath") and not character:GetAttribute("LastBreathable") then
			parent["Last Breath"]:Destroy()
		end

		if humanoid.Health <= humanoid.MaxHealth * 15 / 100 then
			if characterPassives:FindFirstChild("Sentinel") and not parent:FindFirstChild("Sentinel") then
				local clone = script.EffectButton:Clone()
				clone.Name = "Sentinel"
				clone.Frame.ImageLabel.Image = "rbxassetid://16857461303"
				clone.Parent = parent
				SetDefaultEffectButton(clone, {
					Image = "rbxassetid://16857461303",
					Attribute = "Sentinel"
				})
			end
		elseif parent:FindFirstChild("Sentinel") then
			parent.Sentinel:Destroy()
		end

		if humanoid.Health <= humanoid.MaxHealth * 15 / 100 then
			if characterPassives:FindFirstChild("Brawler") and not parent:FindFirstChild("Brawler") then
				local clone = script.EffectButton:Clone()
				clone.Name = "Brawler"
				clone.Frame.ImageLabel.Image = "rbxassetid://16857426894"
				clone.Parent = parent
				SetDefaultEffectButton(clone, {
					Image = "rbxassetid://16857426894",
					Attribute = "Brawler"
				})
			end

			if characterPassives:FindFirstChild("Ronin") and not parent:FindFirstChild("Ronin") then
				local clone = script.EffectButton:Clone()
				clone.Name = "Ronin"
				clone.Frame.ImageLabel.Image = "rbxassetid://16857457187"
				clone.Parent = parent
				SetDefaultEffectButton(clone, {
					Image = "rbxassetid://16857457187",
					Attribute = "Ronin"
				})
			end

			if characterPassives:FindFirstChild("Eternal") and not parent:FindFirstChild("Eternal") then
				local clone = script.EffectButton:Clone()
				clone.Name = "Eternal"
				clone.Frame.ImageLabel.Image = "rbxassetid://16857439514"
				clone.Parent = parent
				SetDefaultEffectButton(clone, {
					Image = "rbxassetid://16857439514",
					Attribute = "Eternal"
				})
			end
		else
			if parent:FindFirstChild("Brawler") then
				parent.Brawler:Destroy()
			end

			if parent:FindFirstChild("Ronin") then
				parent.Ronin:Destroy()
			end

			if parent:FindFirstChild("Eternal") then
				parent.Eternal:Destroy()
			end
		end

		if humanoid.Health <= humanoid.MaxHealth * 15 / 100 then
			if characterPassives:FindFirstChild("Last Stand") and not parent:FindFirstChild("Last Stand") then
				local clone = script.EffectButton:Clone()
				clone.Name = "Last Stand"
				clone.Frame.ImageLabel.Image = "rbxassetid://16857452268"
				clone.Parent = parent
				SetDefaultEffectButton(clone, {
					Image = "rbxassetid://16857452268",
					Attribute = "Last Stand"
				})
			end
		elseif parent:FindFirstChild("Last Stand") then
			parent["Last Stand"]:Destroy()
		end

		if character:FindFirstChild("NoJump") then
			if not parent.NoJump.Visible then
				parent.NoJump.Visible = true
			end
		elseif parent.NoJump.Visible then
			parent.NoJump.Visible = nil
		end
	end
end)
SetDefaultEffectButton(parent.SafeZone, {
	Image = "rbxassetid://130026275595392",
	Attribute = "Safe Zone"
})
SetDefaultEffectButton(parent.SuperSafeZone, {
	Image = "rbxassetid://93287918015766",
	Attribute = "Super Safe Zone"
})
SetDefaultEffectButton(parent.Danger, {
	Image = v2.Danger.Image,
	Attribute = "Danger"
})
SetDefaultEffectButton(parent.PvPDisabled, {
	Image = v2.PvPDisabled.Image,
	Attribute = "PvP Disabled"
})
SetDefaultEffectButton(parent.FruitDistance, {
	Image = "Legacy Fruit",
	Attribute = "Legacy Fruit"
})
SetDefaultEffectButton(parent.NoJump, {
	Image = "rbxassetid://95754744101495",
	Attribute = "Anti Jump"
})
local left2 = raceV3.Frame.CanvasGroup.Left
local right2 = raceV3.Frame.CanvasGroup.Right

function ResetRadial()
	right2.Visible = true
	left2.Visible = true
	left2.UIGradient.Rotation = 0
	right2.UIGradient.Rotation = 0
end

function BeginCooldown(p: number)
	ResetRadial()
	local TweenService2 = game:GetService("TweenService")
	local tween = TweenService2:Create(
		right2.UIGradient,
		TweenInfo.new(p / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Rotation = 180
		}
	)
	local TweenService3 = game:GetService("TweenService")
	local tween2 = TweenService3:Create(
		left2.UIGradient,
		TweenInfo.new(p / 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Rotation = 180
		}
	)
	task.spawn(function()
		tween:Play()
		tween.Completed:Wait()
		right2.Visible = nil
		tween2:Play()
		tween2.Completed:Wait()
		left2.Visible = nil
	end)
	local lastTime = tick()
	raceV3.Frame.TextLabel.Visible = true

	while task.wait(0.5) and not (p < tick() - lastTime) and _G.Cooldowns.RACEAWAKEN do
		raceV3.Frame.TextLabel.Text = math.max(p - math.floor(tick() - lastTime), 0)
	end

	raceV3.Frame.TextLabel.Visible = false
	right2.Visible = false
	left2.Visible = false
end

if UserInputService.GamepadEnabled then
	local success, result = pcall(function()
		raceV3.Frame.KeyText.Text = "LT + RT"
		raceV3.Frame.KeyText.Size = UDim2.fromScale(1, 0.4)
		raceV3.Frame.KeyText.Position = UDim2.fromScale(0.5, 0.2)
	end)

	if not success then
		warn(result)
	end
end

_G.StartCooldownRace = BeginCooldown

function ActivateRaceV3()
	if humanoid.Sit or _G.Cooldowns.RACEAWAKEN then
		return
	end

	_G.Cooldowns.RACEAWAKEN = true
	ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("RC")
	BeginCooldown(60)
	raceV3.Frame.TextLabel.Text = ""
	_G.Cooldowns.RACEAWAKEN = nil
end

raceV3.MouseButton1Click:Connect(function()
	ActivateRaceV3()
end)
local v5 = {}
UserInputService.InputChanged:Connect(function(input)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.ButtonL2 or keyCode == Enum.KeyCode.ButtonR2 then
		if input.Position.Z >= 0.6 then
			if v5[keyCode] then
				return
			end

			v5[keyCode] = true

			if v5[Enum.KeyCode.ButtonL2] and v5[Enum.KeyCode.ButtonR2] then
				local lastTime = tick()

				while v5[Enum.KeyCode.ButtonL2] and v5[Enum.KeyCode.ButtonR2] and not (tick() - lastTime > 1) do
					task.wait()
				end

				if v5[Enum.KeyCode.ButtonL2] and v5[Enum.KeyCode.ButtonR2] and tick() - lastTime > 1 then
					v5[Enum.KeyCode.ButtonR2] = nil
					v5[Enum.KeyCode.ButtonL2] = nil
					ActivateRaceV3()
				end
			end
		elseif v5[keyCode] then
			v5[keyCode] = nil
		end
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.Z or keyCode == Enum.KeyCode.ButtonX then
		if not CanUseShipSkill() then
			return
		end

		if ReplicatedStorage.Chest.Remotes.Functions.SkillAction:InvokeServer("SHIP") then
			BeginShipCooldown(60)
		end
	else
		if keyCode ~= Enum.KeyCode.R then
			return
		end

		ActivateRaceV3()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	local keyCode = input.KeyCode

	if keyCode == Enum.KeyCode.ButtonL2 or keyCode == Enum.KeyCode.ButtonR2 then
		v5[keyCode] = nil
	end
end)