local createVector = vector.create
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local RunService = game:GetService("RunService")
local script2 = script

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			if emitter:GetAttribute("Color") == true then
				if p then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		else
			emitter.Enabled = enabled
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local v = {
	"Head",
	"HumanoidRootPart",
	"UpperTorso",
	"LowerTorso",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot"
}

for k, v2 in pairs(v) do
	v[k] = nil
	v[v2] = true
end

local function IsBodyPart(part)
	return v[part.Name]
end

local random = Random.new()
return function(player)
	local cFrame = player.CFrame
	local scale = player.Scale or 12

	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		scale *= player.Character.HumanoidRootPart.Size.Z
	end

	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 450 + scale * 10 < magnitude then
		return
	end

	local v2 = scale / 12
	local model = Instance.new("Model")
	model.Name = "EffectsFolder"
	Util.Sound:Play("Soru", cFrame)

	if player.Mode == nil then
		player.Mode = 2
	end

	local character = player.Character

	if player.Mode == 1 then
		local clone = script2.TpPart:Clone()
		local raycastResult = workspace:Raycast(cFrame.p, createVector(0, -5, 0) * v2, raycastParams)

		if raycastResult then
			for _, child in clone.Floor:GetChildren() do
				child.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, raycastResult.Instance.Color),
					ColorSequenceKeypoint.new(1, raycastResult.Instance.Color)
				})
			end
		else
			clone.Floor:Destroy()
		end

		if math.abs(v2 - 1) > 0.05 then
			Util.ResizeModel(clone, v2)
		end

		clone.Position = cFrame.p
		clone.Parent = model
		local clone2 = script2.Wave:Clone()
		clone2.Position = cFrame.p + Vector3.new(0, 3 * v2, 0)
		clone2.Orientation = createVector(-90, 0, 0)
		clone2.Size = createVector(6, 6, 10) * v2
		clone2.Parent = model
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(35, 35, 1) * v2,
			Position = cFrame.p + createVector(0, -3, 0) * v2,
			Transparency = 1
		}):Play()
		local clone3 = script2.Wave:Clone()
		clone3.Position = cFrame.p + createVector(0, 3, 0) * v2
		clone3.Orientation = createVector(-90, 0, 0)
		clone3.Size = createVector(6, 6, 15) * v2
		clone3.Parent = model
		TweenService:Create(clone3, TweenInfo.new(0.14, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(35, 35, 1) * v2,
			Position = cFrame.p + createVector(0, -3, 0) * v2,
			Transparency = 1
		}):Play()
		local clone4 = script2.Sprial:Clone()
		clone4.Size = createVector(20, 5, 5) * v2
		clone4.Position = cFrame.p
		clone4.Orientation = createVector(0, 0, -90)
		clone4.Parent = model
		TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(15, 25, 25) * v2,
			Orientation = clone4.Orientation + createVector(0, 400, 0),
			Transparency = 1
		}):Play()
		local v3 = cFrame.p + createVector(0, -3, 0) * v2
		local clone5 = script2.Trail:Clone()

		if math.abs(v2 - 1) > 0.05 then
			Util.ResizeModel(clone5, v2)
		end

		for _ = 1, 10 do
			local clone6 = clone5:Clone()
			local number = random:NextNumber(0, 360)
			local number2 = random:NextNumber(200, 500)
			local number3 = random:NextNumber(1500, 2000)
			local v4 = random:NextNumber(3, 10) * v2
			local v5 = random:NextNumber(2, 12) * v2
			local total = 0
			local v6 = random:NextNumber(10, 35) * v2
			local v7 = -random:NextNumber(10, 20) * v2
			local v8 = math.sin((math.rad(number))) * v4
			local v9 = math.cos((math.rad(number))) * v4
			clone6.Position = v3 + Vector3.new(v8, total, v9)
			clone6.Parent = model
			local position = clone6.Position
			local v10 = nil
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				number += number2 * dt
				number2 += number3 * dt
				v4 += v5 * dt
				total += v6 * dt
				v6 += v7 * dt
				v10 = v3 + Vector3.new(math.sin((math.rad(number))) * v4, total, math.cos((math.rad(number))) * v4)
				clone6.CFrame = CFrame.lookAt(v10, position) * CFrame.Angles(0, 3.141592653589793, 0)
				position = v10
			end)
			local v15 = clone6
			task.delay(random:NextNumber(0.2, 0.4), function()
				heartbeatConnection:Disconnect()
				local folder = v15

				for i, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end

		clone5:Destroy()
		local clone6 = script2.UpParticles:Clone()

		if math.abs(v2 - 1) > 0.05 then
			Util.ResizeModel(clone6, v2)
		end

		for _, part in character:GetChildren() do
			if not (part:IsA("BasePart") and IsBodyPart(part)) then
				continue
			end

			local clone7 = part:Clone()
			clone7:ClearAllChildren()
			clone7.Anchored = true
			clone7.CanCollide = false
			clone7.CanQuery = false
			clone7.Color = Color3.new()
			clone7.Transparency = 0.8
			clone7.Parent = model
			TweenService:Create(clone7, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 0.4
			}):Play()
			task.delay(0.15, function()
				for i, child in clone6:GetChildren() do
					if child:GetAttribute("ChangeColor") == true then
						child.Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, clone7.Color),
							ColorSequenceKeypoint.new(1, clone7.Color)
						})
					end

					child.Parent = clone7
					child:Emit(child:GetAttribute("EmitCount"))
				end

				TweenService:Create(clone7, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
		end

		clone6:Destroy()
		model.Parent = workspace._WorldOrigin
		ParticleState(clone)
	else
		local clone = script2.TpPart:Clone()
		local raycastResult = workspace:Raycast(cFrame.p, createVector(0, -5, 0) * v2, raycastParams)

		if raycastResult then
			for _, child in clone.Floor:GetChildren() do
				child.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, raycastResult.Instance.Color),
					ColorSequenceKeypoint.new(1, raycastResult.Instance.Color)
				})
			end
		else
			clone.Floor:Destroy()
		end

		if math.abs(v2 - 1) > 0.05 then
			Util.ResizeModel(clone, v2)
		end

		clone.Position = cFrame.p
		clone.Parent = model
		local clone2 = script2.Wave:Clone()
		clone2.Position = cFrame.p + createVector(0, 3, 0) * v2
		clone2.Orientation = createVector(-90, 0, 0)
		clone2.Size = createVector(6, 6, 10) * v2
		clone2.Parent = model
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(35, 35, 1) * v2,
			Position = cFrame.p + createVector(0, -3, 0) * v2,
			Transparency = 1
		}):Play()
		local clone3 = script2.Wave:Clone()
		clone3.Position = cFrame.p + createVector(0, 3, 0) * v2
		clone3.Orientation = createVector(-90, 0, 0)
		clone3.Size = createVector(6, 6, 15) * v2
		clone3.Parent = model
		TweenService:Create(clone3, TweenInfo.new(0.14, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(35, 35, 1) * v2,
			Position = cFrame.p + createVector(0, -3, 0) * v2,
			Transparency = 1
		}):Play()
		local clone4 = script2.Sprial:Clone()
		clone4.Size = createVector(20, 5, 5) * v2
		clone4.Position = cFrame.p
		clone4.Orientation = createVector(0, 0, -90)
		clone4.Parent = model
		TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(15, 25, 25) * v2,
			Orientation = clone4.Orientation + createVector(0, 400, 0),
			Transparency = 1
		}):Play()
		local v3 = cFrame.p + createVector(0, -3, 0) * v2
		local clone5 = script2.Trail:Clone()

		if math.abs(v2 - 1) > 0.05 then
			Util.ResizeModel(clone5, v2)
		end

		for _ = 1, 10 do
			local clone6 = clone5:Clone()
			local number = random:NextNumber(0, 360)
			local number2 = random:NextNumber(200, 500)
			local number3 = random:NextNumber(1500, 2000)
			local v4 = random:NextNumber(3, 10) * v2
			local v5 = random:NextNumber(2, 12) * v2
			local total = 0
			local v6 = random:NextNumber(10, 35) * v2
			local v7 = -random:NextNumber(10, 20) * v2
			local v8 = math.sin((math.rad(number))) * v4
			local v9 = math.cos((math.rad(number))) * v4
			clone6.Position = v3 + Vector3.new(v8, total, v9)
			clone6.Parent = model
			local position = clone6.Position
			local v10 = nil
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				number += number2 * dt
				number2 += number3 * dt
				v4 += v5 * dt
				total += v6 * dt
				v6 += v7 * dt
				v10 = v3 + Vector3.new(math.sin((math.rad(number))) * v4, total, math.cos((math.rad(number))) * v4)
				clone6.CFrame = CFrame.lookAt(v10, position) * CFrame.Angles(0, 3.141592653589793, 0)
				position = v10
			end)
			local v15 = clone6
			task.delay(random:NextNumber(0.2, 0.4), function()
				heartbeatConnection:Disconnect()
				local folder = v15

				for i, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end

		clone5:Destroy()
		model.Parent = workspace._WorldOrigin
		ParticleState(clone)
	end

	task.wait(3)
	model:Destroy()
end