local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local BezierCurve = require(game.ReplicatedStorage.Util.BezierCurve)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, armReplace, p, p2)
	local clone = armReplace:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local v2 = {
	"RightLowerArm",
	"LeftLowerArm",
	"RightHand",
	"LeftHand",
	"RightUpperArm",
	"LeftUpperArm"
}
return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
		return
	end

	Sound:Play("RubberRocketChargup", humanoidRootPart, nil, 0.8333333333333333)
	task.wait(0.25)

	for _, childName in pairs(v2) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 1
		end

		local child2 = humanoid:FindFirstChild(childName .. "_BusoLayer1")
		local child3 = humanoid:FindFirstChild(childName .. "_BusoLayer2")

		if child2 then
			child2.Transparency = 1
		end

		if child3 then
			child3.Transparency = 1
		end
	end

	local cFrame = humanoidRootPart.CFrame
	local clone = script.rings:Clone()
	clone.Name = "GattlingRings"
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone.Weld.Part0 = humanoidRootPart

	for i = 1, 2 do
		local v3 = i == 1 and "Left" or "Right"
		local effect = createEffect(humanoidRootPart.CFrame, script.ArmReplace, "Gattlingarmeff" .. character.Name) -- equivalent call inferred; original call site unknown
		effect.Weld.Part0 = character[v3 .. "LowerArm"]

		for _, emitter in pairs(effect.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Rate *= 0.5
			end
		end
	end

	local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
	local clone2 = script.Dust:Clone()
	clone2.Name = "GattlingDust"
	clone2.CFrame = cFrame2
	clone2.Parent = _WorldOrigin
	local lastTime = tick()
	local v4 = false
	local now = 0
	local now2 = 0
	local now3 = 0
	local now4 = 0

	while tick() - lastTime < 4 and character:IsDescendantOf(workspace) and not (humanoid.Health <= 0) and player.Holding and player.Holding:IsDescendantOf(workspace) and (not player.ClientStatus or not player.ClientStatus.Parent ~= character) do
		v4 = not player.Holding.Value or v4

		if tick() - lastTime > 0.6666666666666666 and v4 then
			break
		end

		for i = 1, 3 do
			local v5 = 0
			local cframe = CFrame.Angles(0, 0, 0)
			local v6 = math.random(-4, 4)

			if i == 1 then
				if tick() - now3 > 0.028000000000000004 then
					now3 = tick()
					cframe = CFrame.Angles(0, 1.57, 0)
					v5 = 0
				else
					continue
				end
			elseif i == 2 then
				if not (tick() - now2 > 0.08) then
					continue
				end

				now2 = tick()
				v5 = math.random(1, 2) == 1 and Random.new():NextNumber(-180, 45) or Random.new():NextNumber(-45, 180)

				if v5 < 0 then
					cframe = CFrame.Angles(1.57, -4.2, -1.5707963267948966)
					v6 = 1
				else
					cframe = CFrame.Angles(1.6, 2, -1.5707963267948966)
					v6 = -1
				end
			elseif i == 3 then
				if not (tick() - now > 0.04) then
					continue
				end

				now = tick()
				v5 = math.random(1, 2) == 1 and Random.new():NextNumber(-180, 45) or Random.new():NextNumber(-45, 180)

				if v5 < 0 then
					cframe = CFrame.Angles(1.57, -4.2, -1.5707963267948966)
					v6 = 3
				else
					cframe = CFrame.Angles(1.6, 2, -1.5707963267948966)
					v6 = -3
				end
			end

			local cFrame3 = humanoidRootPart.CFrame * CFrame.new(v6, i ~= 1 and -1 or math.random(-2, 2) or -1, -4) * cframe
			local clone3 = script["Arm" .. i]:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			local rightUpperArm = character.RightUpperArm
			local rightHand = character.RightHand

			if math.random(1, 2) == 2 then
				rightUpperArm = character.LeftUpperArm
				rightHand = character.LeftHand
			end

			local child = humanoid:FindFirstChild(rightHand.Name .. "_BusoLayer1")
			local color = rightUpperArm.Color
			local material

			if child then
				color = child.Color
				material = child.Material
			else
				material = "SmoothPlastic"
			end

			clone3.Color = color
			clone3.Material = material

			if i == 2 or i == 3 then
				if v5 > 0 then
					clone3.CFrame *= CFrame.Angles(-1.25, 0, 0)
					TweenService:Create(clone3, v[2], {
						Orientation = clone3.Orientation + createVector(0, -40, 0)
					}):Play()
				elseif v5 < 0 then
					clone3.CFrame *= CFrame.Angles(1.57, 0, 0)
					TweenService:Create(clone3, v[2], {
						Orientation = clone3.Orientation + createVector(0, 40, 0)
					}):Play()
				end

				local v8 = clone3
				task.delay(0.25, function()
					v8:Destroy()
				end)
			else
				local v8 = clone3
				task.delay(0.15, function()
					v8:Destroy()
				end)
			end

			local middlePosition = BezierCurve.GetMiddlePosition(
				clone3.Position,
				humanoidRootPart.CFrame * CFrame.new(0, 0, -15).Position,
				v5
			)

			if i == 1 then
				local bodyVelocity = Instance.new("BodyVelocity", clone3)
				bodyVelocity.MaxForce = createVector(40000, 40000, 40000)
				bodyVelocity.Velocity = (humanoidRootPart.CFrame * CFrame.new(0, 0, -15)).lookVector * 100
			else
				BezierCurve.QuadraticBezierCurves(
					15,
					400,
					clone3,
					clone3.Position,
					middlePosition,
					humanoidRootPart.CFrame * CFrame.new(0, 0, -15).Position
				)
			end
		end

		local ray = Ray.new(humanoidRootPart.Position, createVector(0, -10, 0))
		local part = workspace:FindPartOnRayWithWhitelist(ray, { map })

		if part == nil or clone2 == nil or clone2.Parent == nil then
			clone2.Attachment.ParticleEmitter.Enabled = false
			clone2.Attachment.ParticleEmitter2.Enabled = false
		else
			clone2.Attachment.ParticleEmitter.Color = ColorSequence.new(part.Color)
			clone2.Attachment.ParticleEmitter2.Color = ColorSequence.new(part.Color)
			clone2.Orientation = humanoidRootPart.Orientation - createVector(0, 180, 0)
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			clone2.Attachment.ParticleEmitter.Enabled = true
			clone2.Attachment.ParticleEmitter2.Enabled = true
		end

		if tick() - now4 > 0.11666666666666667 then
			Sound:Play("RubberCWhoosh", clone2.Position, nil, 1.125)
			now4 = tick()
		end

		task.wait()
	end

	for _, childName in pairs(v2) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 0
		end

		local child2 = humanoid:FindFirstChild(childName .. "_BusoLayer1")
		local child3 = humanoid:FindFirstChild(childName .. "_BusoLayer2")

		if child2 then
			child2.Transparency = 0
		end

		if child3 then
			child3.Transparency = 0
		end
	end

	if clone2 then
		clone2.Attachment.ParticleEmitter.Enabled = false
		clone2.Attachment.ParticleEmitter2.Enabled = false
		Debris:AddItem(clone2, 1)
	end

	if clone then
		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		pcall(function()
			clone.Weld.Part0 = nil
		end)
		clone.Anchored = true
		Debris:AddItem(clone, 1)
	end

	for _, folder in pairs(_WorldOrigin:GetChildren()) do
		if folder.Name ~= "Gattlingarmeff" .. character.Name then
			continue
		end

		for _, emitter in pairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter.Parent.Name == "Attachment" then
				emitter.Enabled = false
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Debris:AddItem(folder, 0.75)
	end
end