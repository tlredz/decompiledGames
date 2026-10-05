local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FireSourceModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
local v = {}
FireSourceModule.TimerShowing = false
local mainFire = nil

function secondsToTime(p)
	local v2 = math.floor(p / 60)
	local v3 = p % 60
	return string.format("%d:%02d", v2, v3)
end

local v2 = true
local v3 = true
local v4 = false
local v5 = false
local v6 = nil
local v7 = {
	{
		{ 1.19, 3.94 },
		{ 0.81, 2.8 }
	},
	{
		{ 1.19, 3.94 },
		{ 0.81, 2.8 }
	},
	{
		{ 1.19, 4.32 },
		{ 0.81, 3 }
	},
	{
		{ 1.19, 4.32 },
		{ 0.81, 3 }
	},
	{
		{ 1.19, 5.83 },
		{ 0.81, 3.4 }
	},
	{
		{ 1.19, 9.26 },
		{ 0.81, 5.2 }
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function brightInterpolateColor(value)
	local v8 = 0 + 140 * math.clamp(value, 0, 1)
	return Color3.fromHSV(v8 / 360, 1, 1)
end

function DarkenColor(color: Color3, p: number)
	local HSV, v8, v9 = color:ToHSV()
	local v10 = math.clamp(v9 * (1 - p), 0, 1)
	return Color3.fromHSV(HSV, v8, v10)
end

local v8 = 0

function ChangeTimerDisplay(p, p2)
	local billboardGui = mainFire and mainFire.PrimaryPart and mainFire.PrimaryPart:FindFirstChild("BillboardGui")

	if billboardGui then
		if workspace:GetAttribute("Progress") == 6 then
			billboardGui.Frame.TextLabel.Text = " "
			billboardGui.Frame.RealTimer.Text = " "
		else
			billboardGui.Frame.TextLabel.Text = "level " .. workspace:GetAttribute("Progress") .. ` progress: <font face="Kalam">{math.floor(p / p2 * 100)}/100</font>`
		end

		billboardGui.Frame.RealTimer.Text = secondsToTime(p)
	end
end

function ChangeBarSize(_, _, value, p)
	local v9 = math.clamp(value, 0, 1)

	if mainFire and mainFire.PrimaryPart then
		local fill = mainFire.PrimaryPart.BillboardGui.Frame.Background.Fill
		local newFill = fill.Parent.NewFill
		fill.Size = UDim2.new(v9, 0, 1, 0)
		local v10 = math.clamp(p - 0.2, 0, 1)
		fill.BackgroundColor3 = brightInterpolateColor(v10)
		newFill.BackgroundColor3 = DarkenColor(fill.BackgroundColor3, 0.3)

		if v10 < 0.33 then
			local imageLabel = mainFire.PrimaryPart.FarAway:WaitForChild("ImageLabel")
			imageLabel.Image = "rbxassetid://124255419152100"
		elseif v10 < 0.66 then
			mainFire.PrimaryPart.FarAway.ImageLabel.Image = "rbxassetid://99153679349707"
		else
			mainFire.PrimaryPart.FarAway.ImageLabel.Image = "rbxassetid://102941548238667"
		end

		if v9 - v8 > 0 then
			newFill.Size = UDim2.new(v9 - v8, 0, 1, 0)
			newFill.Position = UDim2.new(v8, 0, 1, 0)
			task.spawn(function()
				wait(1)

				if v9 == v9 then
					newFill.Size = UDim2.new(0, 0, 1, 0)
				end
			end)
		elseif newFill.Size.X.Scale > 0 then
			newFill.Size = UDim2.new(fill.Size.X.Scale - newFill.Position.X.Scale, 0, 1, 0)
		end

		v8 = v9
	end
end

local v9 = {
	25,
	35,
	45,
	50,
	55,
	60
}
local v10 = {
	{ 0.3, 1.1 },
	{ 0.3, 1.1 },
	{ 0.3, 1 },
	{ 0.2, 1.1 },
	{ 0.15, 1.15 },
	{ 1, 1.7 }
}
Client.Events.FireUpgradeEquipped:Connect(function()
	local fireUpgrade = mainFire:WaitForChild("FireUpgrade", 10)

	if not fireUpgrade then
		return
	end

	if mainFire:GetAttribute("FuelRemaining") > 0 then
		for _, emitter in pairs(fireUpgrade:GetDescendants()) do
			if not (string.sub(emitter.Name, 1, 7) == "Ambient" and emitter:IsA("ParticleEmitter")) then
				continue
			end

			emitter.Enabled = true
		end
	end
end)

function RescaleFireSize(p)
	local fireUpgrade = mainFire:FindFirstChild("FireUpgrade")

	if not fireUpgrade then
		return false
	end

	local v11 = v10[workspace:GetAttribute("Progress")][1]
	fireUpgrade:ScaleTo(v11 + (v10[workspace:GetAttribute("Progress")][2] - v11) * p)
end

function ChangeParticleSize(p)
	if not (mainFire and mainFire.PrimaryPart) then
		return
	end

	local fire = mainFire.PrimaryPart.FireAttach.Fire

	if not fire then
		return
	end

	mainFire.PrimaryPart.FireLight.Range = v9[workspace:GetAttribute("Progress")]
	local fireUpgrade = mainFire:FindFirstChild("FireUpgrade")

	if fireUpgrade then
		v6 = fireUpgrade
	else
		v6 = nil
	end

	if v6 and RescaleFireSize(p) then
		fire.Enabled = false
	elseif fire then
		local v11 = v7[workspace:GetAttribute("Progress")] or v7[1]
		local v12 = v11[1][1]
		local v13 = v12 + (v11[1][2] - v12) * p
		local v14 = v11[2][1]
		local v15 = v14 + (v11[2][2] - v14) * p
		local numberSequence = NumberSequence.new({
			NumberSequenceKeypoint.new(0, v13, 0),
			NumberSequenceKeypoint.new(0.21, v15, 0),
			NumberSequenceKeypoint.new(1, 0, 0)
		})
		mainFire.PrimaryPart.FireAttach.Fire.Size = numberSequence
	end
end

function LowFireWarnings(p)
	if mainFire:GetAttribute("FuelRemaining") <= 30 and workspace:GetAttribute("Progress") >= 2 then
		if p <= 0 then
			if v3 and workspace:GetAttribute("Progress") >= 2 then
				v2 = false
				Client.PopUpUI.AddPopUp("The Fire has gone out. You are no longer Safe", "note", 10.5)
				task.spawn(function()
					wait(45)
					v3 = true
				end)
			end
		elseif v2 and workspace:GetAttribute("Progress") >= 2 then
			v2 = false

			if workspace:GetAttribute("ChristmasSafezone") then
				Client.PopUpUI.AddPopUp(
					"the campfire is almost out. the north pole won't be safe anymore",
					"warning",
					10.5
				)
			else
				Client.PopUpUI.AddPopUp("the campfire is almost out", "warning", 10.5)
			end

			task.spawn(function()
				wait(45)
				v2 = true
			end)
		end

		task.spawn(function()
			for _ = 1, 3 do
				if mainFire:GetAttribute("FuelRemaining") <= 30 then
					mainFire.PrimaryPart.BillboardGui.Frame.TextLabel.Visible = false
					mainFire.PrimaryPart.FarAway.ImageLabel.Visible = false
				end

				wait(0.15)

				if mainFire.PrimaryPart.BillboardGui.Frame.FireHolder.Visible then
					mainFire.PrimaryPart.BillboardGui.Frame.TextLabel.Visible = false
				else
					mainFire.PrimaryPart.BillboardGui.Frame.TextLabel.Visible = true
				end

				mainFire.PrimaryPart.FarAway.ImageLabel.Visible = true
				wait(0.15)
			end
		end)
		mainFire.PrimaryPart.BillboardGui.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	else
		mainFire.PrimaryPart.BillboardGui.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

		if mainFire.PrimaryPart.BillboardGui.Frame.FireHolder.Visible then
			mainFire.PrimaryPart.BillboardGui.Frame.TextLabel.Visible = false
		else
			mainFire.PrimaryPart.BillboardGui.Frame.TextLabel.Visible = true
		end

		mainFire.PrimaryPart.FarAway.ImageLabel.Visible = true
	end
end

task.spawn(function()
	mainFire = workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire")
	mainFire:GetAttributeChangedSignal("FuelRemaining"):Connect(function()
		if FireSourceModule.FirePaused then
			return
		end

		local fuelRemaining = mainFire:GetAttribute("FuelRemaining")
		local fuelTarget = mainFire:GetAttribute("FuelTarget")
		ChangeTimerDisplay(fuelRemaining, fuelTarget)
		local v11 = fuelRemaining / fuelTarget
		local v12 = math.min(fuelRemaining, 300) / math.min(fuelTarget, 300)
		ChangeBarSize(fuelRemaining, fuelTarget, v11, v12)
		ChangeParticleSize(v12)
		LowFireWarnings(fuelRemaining)
	end)
end)

function FireSourceModule.CultistWarning(p)
	local IMAGE_ID = "rbxassetid://120199897069200"
	v5 = p

	if p then
		local frame = workspace.Map.Campground.MainFire.PrimaryPart.BillboardGui.Frame
		frame.Warning1.Visible = true
		frame.Warning2.Visible = true
		frame.Warning1.Image = IMAGE_ID
		frame.Warning2.Image = IMAGE_ID
		frame.Parent.Parent.FarAway.Warning1.Image = IMAGE_ID
		frame.Warning1.ImageColor3 = Color3.fromRGB(255, 255, 255)
		frame.Warning2.ImageColor3 = Color3.fromRGB(255, 255, 255)
		frame.Parent.Parent.FarAway.Warning1.ImageColor3 = Color3.fromRGB(255, 255, 255)
		frame.Parent.Parent.FarAway.Warning1.Visible = true
	else
		if v4 then
			FireSourceModule.RainWarning(true)
			return
		end

		print("off")
		local frame = workspace.Map.Campground.MainFire.PrimaryPart.BillboardGui.Frame
		frame.Warning1.Visible = false
		frame.Warning2.Visible = false
		frame.Parent.Parent.FarAway.Warning1.Visible = false
	end
end

function FireSourceModule.RainWarning(p)
	v4 = p

	if v5 then
		return
	end

	task.spawn(function()
		local IMAGE_ID = "rbxassetid://126427682455996"

		if p then
			local frame = workspace.Map.Campground:WaitForChild("MainFire").PrimaryPart.BillboardGui.Frame
			frame.Warning1.Visible = true
			frame.Warning2.Visible = true
			frame.Warning1.Image = IMAGE_ID
			frame.Warning2.Image = IMAGE_ID
			frame.Parent.Parent.FarAway.Warning1.Image = IMAGE_ID
			frame.Warning1.ImageColor3 = Color3.fromRGB(0, 213, 255)
			frame.Warning2.ImageColor3 = Color3.fromRGB(0, 213, 255)
			frame.Parent.Parent.FarAway.Warning1.ImageColor3 = Color3.fromRGB(0, 213, 255)
			frame.Parent.Parent.FarAway.Warning1.Visible = true
		else
			local frame = workspace.Map.Campground.MainFire.PrimaryPart.BillboardGui.Frame
			frame.Warning1.Visible = false
			frame.Warning2.Visible = false
			frame.Parent.Parent.FarAway.Warning1.Visible = false
		end
	end)
end

Client.Events.WarningUpdate:Connect(function(p, p2)
	if p == "Rain" then
		FireSourceModule.RainWarning(p2)
	else
		FireSourceModule.CultistWarning(p2)
	end
end)
Client.Events.FireUpgradeVisuals:Connect(function(p)
	FireSourceModule.FirePaused = true
	local billboardGui = workspace.Map.Campground:WaitForChild("MainFire").PrimaryPart.BillboardGui

	if p == 6 then
		billboardGui.Frame.TextLabel.Text = "FIRE FULLY UPGRADED. MAP FULLY REVEALED"
	else
		billboardGui.Frame.TextLabel.Text = `FIRE LEVEL {p}. MAP EXPANDED`
	end

	billboardGui.Frame.Warning1.Visible = false
	billboardGui.Frame.Warning2.Visible = false
	billboardGui.Frame.Background.Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	billboardGui.Frame.Background.Fill.Size = UDim2.new(1, 0, 1, 0)
	billboardGui.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	billboardGui.Frame.Background.NewFill.Visible = false
	billboardGui.Enabled = true

	for _ = 1, 3 do
		billboardGui.Enabled = false
		wait(0.3)
		billboardGui.Enabled = true
		wait(0.7)
	end

	wait(5)
	task.spawn(function()
		wait(2)

		if Client.WeatherEffectModule.GetWeather() ~= "Clear" then
			billboardGui.Frame.Warning1.Visible = true
			billboardGui.Frame.Warning2.Visible = true
		end
	end)
	FireSourceModule.FirePaused = false
	billboardGui.Enabled = true
	billboardGui.Frame.Background.NewFill.Size = UDim2.new(0, 0, 1, 0)
	billboardGui.Frame.Background.NewFill.Visible = true
end)

function EmitFire(p)
	if p then
		if not mainFire:FindFirstChild("FireUpgrade") then
			mainFire.PrimaryPart.FireAttach.FireFlareSmall:Emit(5)
			return
		end

		for _, emitter in pairs(mainFire:GetDescendants()) do
			if not (string.sub(emitter.Name, 1, 8) == "FlareBig" and emitter:IsA("ParticleEmitter")) then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	else
		if not mainFire:FindFirstChild("FireUpgrade") then
			mainFire.PrimaryPart.FireAttach.FireFlareLarge:Emit(5)
			return
		end

		for _, emitter in pairs(mainFire.FireUpgrade:GetDescendants()) do
			if not (string.sub(emitter.Name, 1, 8) == "FlareBig" and emitter:IsA("ParticleEmitter")) then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end

function BurnItem(instance, instance2)
	if v[instance2] then
		return
	end

	v[instance2] = true
	task.delay(5, function()
		v[instance2] = nil
	end)

	if instance2.PrimaryPart == nil then
		instance2:Destroy()
		return
	end

	local position = instance2:GetPivot().Position
	local assemblyLinearVelocity = instance2.PrimaryPart.AssemblyLinearVelocity
	local v11 = instance:GetPivot().Position + createVector(0, 2, 0)
	local _ = (v11 - instance2:GetPivot().Position) * 5 + assemblyLinearVelocity * 0.2
	instance2:Destroy()

	if (v11 - position).Magnitude <= 15 and instance:FindFirstChild("Center") and instance.Center:FindFirstChild("FireAttach") then
		if instance2.Name == "Fuel Canister" or instance2.Name == "Oil Barrel" then
			EmitFire(false)
		else
			EmitFire(true)
		end
	end

	local clone = instance.PrimaryPart.FuelAdded:Clone()
	clone.Parent = instance.PrimaryPart
	clone:Play()
	task.spawn(function()
		wait(4)
		clone:Destroy()
	end)
end

Client.Events.BurnItemInFire:Connect(BurnItem)

function FireLit(instance)
	local touchingParts = instance:WaitForChild("InnerTouchZone"):GetTouchingParts()
	local v11 = {}

	for _, touchingPart in pairs(touchingParts) do
		local parent = touchingPart.Parent

		if v11[parent.Parent] ~= nil then
			continue
		end

		v11[parent.Parent] = true
		CheckInnerTouch(instance, parent)
	end

	CheckOuterZone(instance)
end

function CheckOuterZone(instance)
	local touchingParts = instance:WaitForChild("OuterTouchZone"):GetTouchingParts()
	local v11 = {}

	for _, touchingPart in pairs(touchingParts) do
		local parent = touchingPart.Parent

		if v11[parent.Parent] ~= nil then
			continue
		end

		v11[parent.Parent] = true
		CheckOuterTouch(instance, parent)
	end
end

local v11 = {}

function CheckInnerTouch(instance, instance2)
	if instance2 and instance2.Parent and instance2:GetAttribute("BurnFuel") then
		if (instance2:GetAttribute("Wet") or 0) < 1 then
			local owner = instance2:GetAttribute("Owner")

			if owner == nil or owner == localPlayer.UserId then
				Client.SpecialFireClient.StartRemovingBbg()
				Client.Events.RequestBurnItem:FireServer(instance, instance2)
				BurnItem(instance, instance2)
			end
		else
			local lastWetNotice = instance2:GetAttribute("LastWetNotice") or 0

			if time() - lastWetNotice > 5 then
				if instance2:GetAttribute("LastOwner") then
					local playerByUserId = game.Players:GetPlayerByUserId(instance2:GetAttribute("LastOwner"))

					if playerByUserId == localPlayer and not v11[playerByUserId] and playerByUserId.Character and playerByUserId.Character.PrimaryPart and instance2.PrimaryPart and (playerByUserId.Character.PrimaryPart.Position - instance2.PrimaryPart.Position).Magnitude < 25 then
						v11[playerByUserId] = true
						Client.PopUpUI.AddPopUp("can't add wood to fire it's too wet", "warning")
						task.spawn(function()
							wait(10)
							v11[playerByUserId] = false
						end)
					end
				end

				instance2:SetAttribute("LastWetNotice", time())
			end
		end
	elseif instance2 and instance2.Parent and instance2:GetAttribute("SpecialFlame") then
		local owner = instance2:GetAttribute("Owner")

		if owner == nil or owner == localPlayer.UserId then
			Client.SpecialFireClient.StartRemovingBbg()
			Client.Events.RequestBurnItem:FireServer(instance, instance2)
			BurnItem(instance, instance2)
		end
	elseif instance2 and instance2.Parent and instance2:GetAttribute("Cookable") then
		if (instance:GetAttribute("FuelRemaining") or 0) <= 0 then
			return
		end

		local owner = instance2:GetAttribute("Owner")

		if owner == nil or owner == localPlayer.UserId then
			Client.SpecialFireClient.StartRemovingBbg()
			Client.Events.RequestCookItem:FireServer(instance, instance2)
		end
	end
end

function CheckOuterTouch(_, _) end

function AddFireSource(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local fuelRemaining = instance:GetAttribute("FuelRemaining") or 0
	instance:GetAttributeChangedSignal("FuelRemaining"):Connect(function()
		local fuelRemaining2 = instance:GetAttribute("FuelRemaining")

		if fuelRemaining2 > 0 and fuelRemaining == 0 then
			FireLit(instance)
		end

		fuelRemaining = fuelRemaining2
	end)
	local innerTouchZone = instance:WaitForChild("InnerTouchZone")
	local fireInnerZoneSize = Client.GlobalSettings.FireInnerZoneSize
	innerTouchZone.Size = Vector3.new(fireInnerZoneSize, fireInnerZoneSize, fireInnerZoneSize)
	innerTouchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent
		CheckInnerTouch(instance, parent)
	end)
	local campground = workspace:WaitForChild("Map"):WaitForChild("Campground")
	local outerTouchZone = instance:WaitForChild("OuterTouchZone")
	local outerZoneSize = campground:GetAttribute("OuterZoneSize") or Client.GlobalSettings.FireOuterZoneSize
	Client.GlobalSettings.FireOuterZoneSize = outerZoneSize
	outerTouchZone.Size = Vector3.new(outerZoneSize, outerZoneSize, outerZoneSize)
	outerTouchZone.Touched:Connect(function(otherPart)
		if (instance:GetAttribute("FuelRemaining") or 0) <= 0 then
			return
		end

		local parent = otherPart.Parent
		CheckOuterTouch(instance, parent)
	end)

	if instance.Name == "MainFire" then
		localPlayer.CharacterRemoving:Connect(function()
			if localPlayer.Character == nil then
				while localPlayer.Character == nil do
					wait(0.5)
					CheckOuterZone(instance)
				end
			end
		end)
	end
end

function AddSpecialFlame(parent)
	if not Client.Databases.RewardsDatabase.FireUpgrades[parent.Name] then
		return
	end

	local clone = ReplicatedStorage.Assets.Billboards.SpecialFlameBbg:Clone()

	if Client.Databases.RewardsDatabase.FireUpgrades[parent.Name].Image then
		clone.ImageLabel.Image = Client.Databases.RewardsDatabase.FireUpgrades[parent.Name].Image
	else
		clone.ImageLabel.Image = "rbxassetid://88700655810389"
		clone.ImageLabel.ImageColor3 = Client.Databases.RewardsDatabase.FireUpgrades[parent.Name].Colour or Color3.fromRGB(
			255,
			115,
			0
		)
	end

	parent.Name = string.gsub(parent.Name, "[Ff][Ll][Aa][Mm][Ee]", "Offering")
	clone.Parent = parent
end

function FireSourceModule.Init()
	task.spawn(function()
		local outerTouchZone = workspace.Map.Campground:WaitForChild("MainFire").OuterTouchZone
		local innerTouchZone = workspace.Map.Campground:WaitForChild("MainFire").InnerTouchZone

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateCircleSize()
			local v12 = outerTouchZone.Size.X * 0.14
			innerTouchZone.Size = Vector3.new(v12, v12, v12)
		end

		outerTouchZone:GetPropertyChangedSignal("Size"):Connect(function()
			updateCircleSize() -- equivalent call inferred; original call site unknown
		end)
		updateCircleSize() -- equivalent call inferred; original call site unknown
		Client.Utility.ForAllTagged("SpecialFlame", AddSpecialFlame)
	end)
end

Client.Utility.ForAllTagged("FireSource", AddFireSource)
return FireSourceModule