local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local encrust = FX:WaitForChild("Diamond").Encrust
local _WorldOrigin = workspace._WorldOrigin
local CustomCollisions = require(ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = CustomCollisions.new("Rocks")
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local v = {
	Head = true,
	LowerTorso = true,
	UpperTorso = true,
	LeftUpperArm = true,
	RightUpperArm = true,
	LeftLowerArm = true,
	RightLowerArm = true,
	LeftLowerLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	RightUpperLeg = true,
	LeftHand = true,
	RightHand = true,
	LeftFoot = true,
	RightFoot = true,
	__DiamondShard = true
}

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end
	end
end

local function applyShards(character, player)
	local upperTorso = character:FindFirstChild("UpperTorso")

	if upperTorso then
		for i = -1, 1, 2 do
			local clone = script.Shard:Clone()
			clone.Name = "__DiamondShard"
			clone.CFrame = upperTorso.CFrame * CFrame.new(
				i * upperTorso.Size.X * 0.4,
				upperTorso.Size.Y / 1.75,
				upperTorso.Size.Z
			) * CFrame.Angles(3.741592653589793, 0, i * 0.33)
			clone.Size = Vector3.new(upperTorso.Size.X / 2.5, upperTorso.Size.Y * 2, upperTorso.Size.X / 2.5)
			clone.WeldConstraint.Part1 = upperTorso
			Util.SetParentOverrideWithColor(clone, character, player, "DiamondFruitVFXColor", true)
			Util.SyncColorsOnChange(clone, player, "DiamondFruitVFXColor", true)
		end
	end
end

local function removeShards(character)
	for _, child in pairs(character:GetChildren()) do
		if child.Name == "__DiamondShard" then
			child:Destroy()
		end
	end
end

return function(player)
	local origin = player.Origin or player.Character.PrimaryPart.Position or player.HRP.Position
	local stage = player.Stage
	local player2 = player.Player
	local v2 = false

	if (currentCamera.CFrame.p - origin).Magnitude > 1200 then
		if player.Stage == 1 and player.Transform then
			v2 = true
			stage = 3
		elseif player.Stage == 2 then
			v2 = true
			stage = 4
		elseif player.Stage == 3 then
			v2 = true
		end

		if not v2 then
			return
		end
	end

	local transform = player.Transform

	if stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "DiamondZEffects"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "DiamondFruitVFXColor")
		local HRP = player.HRP
		local character = player.Character

		if transform then
			local clone = encrust.Encrust:Clone()
			clone.Weld.Part0 = HRP
			Util.SetParentOverrideWithColor(clone, folder, player2, "DiamondFruitVFXColor")
			sound:Play("DIAMOND_Encrust_Activate_01", origin)
			applyShards(character, player2)

			for _, part in character:GetDescendants() do
				if not (part:IsA("BasePart") and v[part.Name]) then
					continue
				end

				part:SetAttribute("OriginalDiamondColor", part.Color)
				local clone2 = encrust.Shine:Clone()
				clone2.Rate = random:NextNumber(0.3, 1)
				Util.SetParentOverrideWithColor(clone2, part, player2, "DiamondFruitVFXColor", true)
				Util.SyncColorsOnChange(clone2, player2, "DiamondFruitVFXColor", true)
				part.Color = Util.WrapColor3Constructor(
					Color3.new(0.435294, 0.878431, 1),
					player2,
					"DiamondFruitVFXColor"
				)
			end

			ParticleState(clone)
			task.delay(0.3, function()
				local folder2 = clone

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					Range = 0,
					Brightness = 0
				}):Play()
			end)
		end

		local crystalCount = player.CrystalCount
		local crystalSpeed = player.CrystalSpeed
		local crystalLifetime = player.CrystalLifetime
		local clone = encrust.CrystalBurst:Clone()
		clone.CFrame = HRP.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player2, "DiamondFruitVFXColor")
		ParticleState(clone)
		sound:Play("DIAMOND_Encrust_Fire_01", origin)

		for i = 1, crystalCount do
			local v3 = player.CrystalData[i]
			local clone2 = encrust.Crystal:Clone()
			clone2.CFrame = v3[1]
			Util.SetParentOverrideWithColor(clone2, folder, player2, "DiamondFruitVFXColor")
			local raycastResult = nil
			local heartbeatConnection = nil
			local v5 = os.clock()
			local v6 = i
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				raycastResult = workspace:Raycast(
					clone2.Position,
					clone2.CFrame.LookVector * dt * crystalSpeed,
					raycastParams
				)
				local folder2, clone3

				if raycastResult then
					heartbeatConnection:Disconnect()
					clone2.Position = raycastResult and raycastResult.Position or clone2.Position
					folder2 = clone2

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					clone2.Transparency = 1
					clone3 = encrust.Explosion:Clone()
					clone3.CFrame = clone2.CFrame
					Util.SetParentOverrideWithColor(clone3, folder, player2, "DiamondFruitVFXColor")
					ParticleState(clone3)

					if v6 ~= 1 then
						return
					end

					sound:Play("DIAMOND_Encrust_Explode_01", origin)
				else
					if not (crystalLifetime <= os.clock() - v5) then
						clone2.CFrame *= CFrame.new(0, 0, -dt * crystalSpeed)
						return
					end

					heartbeatConnection:Disconnect()
					clone2.Position = raycastResult and raycastResult.Position or clone2.Position
					folder2 = clone2

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					clone2.Transparency = 1
					clone3 = encrust.Explosion:Clone()
					clone3.CFrame = clone2.CFrame
					Util.SetParentOverrideWithColor(clone3, folder, player2, "DiamondFruitVFXColor")
					ParticleState(clone3)

					if v6 ~= 1 then
						return
					end

					sound:Play("DIAMOND_Encrust_Explode_01", origin)
				end
			end)
		end

		task.wait(5)
		folder:Destroy()
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "DiamondZEffects"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "DiamondFruitVFXColor")
		local HRP = player.HRP
		local character = player.Character
		local crystalsPerPart = player.CrystalsPerPart
		local clone = encrust.Ending:Clone()
		clone.Weld.Part0 = HRP
		Util.SetParentOverrideWithColor(clone, folder, player2, "DiamondFruitVFXColor")
		sound:Play("DIAMOND_Encrust_Break_01", origin)
		removeShards(character)

		for _, part in character:GetDescendants() do
			if not (part:IsA("BasePart") and v[part.Name]) then
				continue
			end

			if part:FindFirstChild("Shine") then
				part:FindFirstChild("Shine"):Destroy()
			end

			for _ = 1, crystalsPerPart do
				local clone2 = encrust.Shard:Clone()
				clone2.Size = createVector(1, 1, 1) * random:NextNumber(1, 3)
				clone2.Orientation = Vector3.new(
					random:NextNumber(-360, 360),
					random:NextNumber(-360, 360),
					random:NextNumber(-360, 360)
				)
				clone2.Position = part.Position + Vector3.new(
					random:NextNumber(-part.Size.X / 2, part.Size.X / 2),
					random:NextNumber(-part.Size.Y / 2, part.Size.Y / 2),
					random:NextNumber(-part.Size.Z / 2, part.Size.Z / 2)
				)
				rocks:ApplyCollision(clone2, nil, true)
				Util.SetParentOverrideWithColor(clone2, folder, player2, "DiamondFruitVFXColor")
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new(
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1)
				).Unit * random:NextNumber(30, 60)
				bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
				Util.SetParentOverrideWithColor(bodyVelocity, clone2, player2, "DiamondFruitVFXColor")
				task.delay(0.1, function()
					bodyVelocity:Destroy()
					task.wait(random:NextNumber(0.3, 0.6))
					TweenService:Create(clone2, TweenInfo.new(random:NextNumber(0.2, 0.5), Enum.EasingStyle.Linear), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end

			part.Color = part:GetAttribute("OriginalDiamondColor")
		end

		ParticleState(clone)
		task.delay(0.3, function()
			local folder2 = clone

			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0,
				Brightness = 0
			}):Play()
		end)
		task.wait(5)
		folder:Destroy()
	elseif stage == 3 then
		local _ = player.HRP
		local character = player.Character
		applyShards(character, player2)

		for _, part in character:GetDescendants() do
			if not (part:IsA("BasePart") and v[part.Name]) then
				continue
			end

			part:SetAttribute("OriginalDiamondColor", part.Color)
			local clone = encrust.Shine:Clone()
			clone.Rate = random:NextNumber(0.3, 1)
			Util.SetParentOverrideWithColor(clone, part, player2, "DiamondFruitVFXColor", true)
			Util.SyncColorsOnChange(clone, player2, "DiamondFruitVFXColor", true)
			part.Color = Util.WrapColor3Constructor(Color3.new(0.435294, 0.878431, 1), player2, "DiamondFruitVFXColor")
		end
	elseif stage == 4 then
		local character = player.Character
		removeShards(character)

		for _, part in character:GetDescendants() do
			if not (part:IsA("BasePart") and v[part.Name]) then
				continue
			end

			if part:FindFirstChild("Shine") then
				part:FindFirstChild("Shine"):Destroy()
			end

			if part:GetAttribute("OriginalDiamondColor") then
				part.Color = part:GetAttribute("OriginalDiamondColor")
			end
		end
	end
end