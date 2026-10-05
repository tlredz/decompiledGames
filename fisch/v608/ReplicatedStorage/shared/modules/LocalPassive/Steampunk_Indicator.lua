local SteampunkIndicator = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local StatusEffectsController = require(ReplicatedStorage.client.legacyControllers.StatusEffectsController)
local remoteFunction = Net:RemoteFunction("Steampunk/ActivateBurst")
local _ = Players.LocalPlayer
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 206, 61)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 120, 40))
})
local color = Color3.fromRGB(255, 206, 61)

local function spawnSpark(reel_bar, fishPosition: number)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "SteampunkSpark"
	imageLabel.Image = "rbxassetid://81840515253894"
	imageLabel.ImageColor3 = color
	imageLabel.BackgroundTransparency = 1
	imageLabel.ImageTransparency = 0
	imageLabel.Size = UDim2.fromOffset(22, 6)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.ZIndex = 14
	imageLabel.Position = UDim2.new(fishPosition, 0, 0.3, 0)
	imageLabel.Parent = reel_bar
	local v = math.random() * 3.141592653589793
	local v2 = 280 + math.random() * 280
	local lifetime = 0.4 + math.random() * 0.29999999999999993
	return {
		instance = imageLabel,
		x = 0,
		y = 0,
		vx = math.cos(v) * v2,
		vy = -math.sin(v) * v2,
		age = 0,
		lifetime = lifetime,
		fishPos = fishPosition
	}
end

local function updateSpark(state, p: number)
	state.age += p

	if state.age >= state.lifetime then
		return false
	end

	state.vy += p * 1800
	state.x += state.vx * p
	state.y += state.vy * p
	state.instance.Position = UDim2.new(state.fishPos, state.x, 0.3, state.y)
	state.instance.Rotation = math.deg((math.atan2(state.vy, state.vx)))
	local v = state.lifetime * 0.75

	if v < state.age then
		state.instance.ImageTransparency = (state.age - v) / (state.lifetime - v)
	end

	return true
end

local function createGrind(reel_bar)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "SteampunkGearLeft"
	imageLabel.Image = "rbxassetid://77215890862281"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromOffset(60, 60)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.ZIndex = 15
	imageLabel.Parent = reel_bar
	local clone = imageLabel:Clone()
	clone.Name = "SteampunkGearRight"
	clone.Parent = reel_bar
	return {
		startTime = tick(),
		leftGear = imageLabel,
		rightGear = clone,
		sparkAccum = 0,
		gearsDestroyed = false
	}
end

function SteampunkIndicator.Morph(p, _, object)
	local config = p.config
	local random = object:GetRandom(73)
	local hasStatusOfType = StatusEffectsController:HasStatusOfType("KineticRelease")
	task.spawn(function()
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local frame = Instance.new("Frame")
		frame.Name = "SteampunkEnergyIndicator"
		frame.Size = UDim2.fromScale(0.18, 0.4)
		frame.Position = UDim2.fromScale(0, -1.2)
		frame.AnchorPoint = Vector2.new(0, 0)
		frame.BackgroundTransparency = 1
		frame.ZIndex = 10
		frame.Parent = reel_bar
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 1.5
		uIScale.Parent = frame
		local UI = ReplicatedStorage.client.legacyControllers:WaitForChild("Rods"):WaitForChild("SpiritPassiveController"):WaitForChild("UI")
		local clone = UI.spiritStats:Clone()
		clone.Size = UDim2.fromScale(1, 1)
		clone.Parent = frame
		local clone2 = UI.spiritSample:Clone()
		clone2.Name = "SteampunkEnergy"
		clone2.Size = UDim2.fromScale(1, 1)
		clone2.Icon.Image = "rbxassetid://77215890862281"
		clone2.Bar.Fill.Size = UDim2.fromScale(0, 1)

		for _, uIStroke in clone2:GetDescendants() do
			if not uIStroke:IsA("UIStroke") then
				continue
			end

			uIStroke.Thickness = 1
			uIStroke.LineJoinMode = Enum.LineJoinMode.Round
		end

		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = colorSequence
		uIGradient.Parent = clone2.Bar.Fill
		clone2.Parent = clone.Container
		local v = {}
		local v2 = {}
		local v3 = playerDataReplicator:TryIndex({ "SteampunkEnergy" }) or 0
		p.reelTrove:Add(playerDataReplicator:Observe({ "SteampunkEnergy" }, function(p2)
			v3 = p2 or v3
		end))
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active then
				return
			end

			local v4 = v3 or 0
			clone2.Icon.Rotation = (clone2.Icon.Rotation + 90 * p2) % 360
			clone2.Bar.Fill.Size = UDim2.fromScale(math.clamp(v4, 0, 1), 1)
			local fishPosition = object.fishPosition or 0.5

			for i = #v, 1, -1 do
				local v5 = v[i]
				local v6 = tick() - v5.startTime

				if v6 >= 4 then
					if not v5.gearsDestroyed then
						v5.gearsDestroyed = true

						if v5.leftGear.Parent then
							v5.leftGear:Destroy()
						end

						if v5.rightGear.Parent then
							v5.rightGear:Destroy()
						end
					end

					if v6 >= 4.7 then
						table.remove(v, i)
					end
				else
					local rotation = v6 * 720
					v5.leftGear.Rotation = -rotation
					v5.rightGear.Rotation = rotation
					v5.leftGear.Position = UDim2.new(fishPosition, -35, 0.3, 0)
					v5.rightGear.Position = UDim2.new(fishPosition, 35, 0.3, 0)
					v5.sparkAccum += p2

					while v5.sparkAccum >= 0.03 do
						v5.sparkAccum -= 0.03
						table.insert(v2, (spawnSpark(reel_bar, fishPosition)))
						table.insert(v2, (spawnSpark(reel_bar, fishPosition)))
					end
				end
			end

			for i = #v2, 1, -1 do
				local v5 = v2[i]

				if updateSpark(v5, p2) then
					continue
				end

				if v5.instance.Parent then
					v5.instance:Destroy()
				end

				table.remove(v2, i)
			end
		end))
		p.reelTrove:Add(frame)
		object:WaitUntilReady()
		local v4 = false
		local v5 = false
		local now = 0

		local function tryActivate()
			if v4 and v5 and tick() - now > 0.5 and not hasStatusOfType then
				now = tick()
				local v6 = remoteFunction:InvokeServer()

				if v6 and object.active then
					local modifier = object:CreateModifier("progressefficiency", "add")
					modifier.Value = p.config.ProgressEfficiency
					local modifier2 = object:CreateModifier("progressefficiency", "force_add")
					modifier2.Value = p.config.ForcedProgressEfficiency
					local modifier3 = object:CreateModifier("resilience", "add")
					modifier3.Value = p.config.Resilience
					p.reelTrove:Add(object:DelayLogic(p.config.MaxDuration * v6, function()
						if not object.active then
							return
						end

						modifier:Destroy()
						modifier2:Destroy()
						modifier3:Destroy()
					end))
				end
			end
		end

		p.reelTrove:Add(UserInputService.InputBegan:Connect(function(input)
			local v6 = object.reel.AbsoluteSize.X / 2

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonL2 or input.UserInputType == Enum.UserInputType.Touch and input.Position.X < v6 then
				v4 = true
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonR2 or input.UserInputType == Enum.UserInputType.Touch and v6 < input.Position.X then
				v5 = true
			end

			tryActivate()
		end))
		p.reelTrove:Add(UserInputService.InputEnded:Connect(function(input)
			local v6 = object.reel.AbsoluteSize.X / 2

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonL2 or input.UserInputType == Enum.UserInputType.Touch and input.Position.X < v6 then
				v4 = false
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonR2 or input.UserInputType == Enum.UserInputType.Touch and v6 < input.Position.X then
				v5 = false
			end
		end))
		local v6 = tick() + random:NextNumber(config.GearSlashIntervalMin, config.GearSlashIntervalMax)
		p.reelTrove:Add(object.OnLogicStep:Connect(function()
			if not object.active or tick() < v6 then
				return
			end

			object:AddProgress(config.GearSlashProgress)
			object.fx:SpawnShake(object.reel_bar, 0.15, 0.3, 0.01, false)
			table.insert(v, (createGrind(reel_bar)))
			v6 = tick() + random:NextNumber(config.GearSlashIntervalMin, config.GearSlashIntervalMax)
		end))
	end)
end

setmetatable(SteampunkIndicator, module)
return SteampunkIndicator