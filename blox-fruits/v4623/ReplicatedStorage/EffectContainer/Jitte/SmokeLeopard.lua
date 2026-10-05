local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage.Util)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local debris = Util.Debris

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local v = {
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone.Parent = p2 or _WorldOrigin
		clone.PrimaryPart.CFrame = cFrame
	else
		clone.CFrame = cFrame
		clone.Parent = p2 or _WorldOrigin
	end

	return clone
end

local v2 = {
	"rbxassetid://12558376366",
	"rbxassetid://12558376101",
	"rbxassetid://12558375916",
	"rbxassetid://12558375736",
	"rbxassetid://12558375599",
	"rbxassetid://12558375321",
	"rbxassetid://12558375128",
	"rbxassetid://12558374890",
	"rbxassetid://12558374679"
}
return function(data)
	local cFrame = data.CFrame
	local reference = data.Reference

	if not reference or (workspace.CurrentCamera.CFrame.Position - cFrame.Position).magnitude > 1000 then
		return
	end

	local v3 = Util.MasterClock:GetTime() - data.Timestamp

	if v3 > 0.7 then
		return
	end

	local cFrame3 = cFrame * CFrame.new(0, 1, -3)
	local start = script.start
	local clone = start:Clone()
	clone.Name = clone.Name

	if start:IsA("Model") then
		clone.Parent = _WorldOrigin
		clone.PrimaryPart.CFrame = cFrame3
	else
		clone.CFrame = cFrame3
		clone.Parent = _WorldOrigin
	end

	debris:AddItem(clone, 1)

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local cFrame4 = cFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, 0, (math.rad((math.random(-180, 180)))))
	local spiral = script.spiral
	local clone2 = spiral:Clone()
	clone2.Name = clone2.Name

	if spiral:IsA("Model") then
		clone2.Parent = _WorldOrigin
		clone2.PrimaryPart.CFrame = cFrame4
	else
		clone2.CFrame = cFrame4
		clone2.Parent = _WorldOrigin
	end

	TweenService:Create(clone2.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = createVector(0.09, 0.09, 0.011)
	}):Play()
	TweenService:Create(clone2.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0.1
	}):Play()
	task.spawn(function()
		for i = 1, #v2 do
			local decal = clone2:FindFirstChild("Decal")
			decal.Texture = v2[i]
			task.wait(0.04)
		end

		clone2:Destroy()
	end)
	local ray = Ray.new(cFrame.Position, createVector(0, -10, 0))
	local part = workspace:FindPartOnRayWithWhitelist(ray, { map })

	if part then
		local cFrame2 = cFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		local dust = script.Dust
		local clone3 = dust:Clone()
		clone3.Name = clone3.Name

		if dust:IsA("Model") then
			clone3.Parent = _WorldOrigin
			clone3.PrimaryPart.CFrame = cFrame2
		else
			clone3.CFrame = cFrame2
			clone3.Parent = _WorldOrigin
		end

		debris:AddItem(clone3, 1)

		for _, child in pairs(clone3.Attachment:GetChildren()) do
			child.Color = ColorSequence.new(part.Color)
			local speed = child.Speed
			child.Speed = NumberRange.new(speed.Min * 1.5, speed.Max * 1.5)
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	local cFrame5 = cFrame * CFrame.new(0, 1, -3)
	local lepoard = script.Lepoard
	local clone3 = lepoard:Clone()
	clone3.Name = clone3.Name

	if lepoard:IsA("Model") then
		clone3.Parent = _WorldOrigin
		clone3.PrimaryPart.CFrame = cFrame5
	else
		clone3.CFrame = cFrame5
		clone3.Parent = _WorldOrigin
	end

	debris:AddItem(clone3, 3)
	local mesh = clone3.Mesh
	Util.Sound:Play("SmokeBallAppear", mesh)
	Util.Sound:Play("SmokeLeopard", mesh)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(10000000000, 10000000000, 10000000000)
	bodyVelocity.Velocity = cFrame.lookVector * 275 / (1 - v3)
	bodyVelocity.Parent = mesh
	clone3.AnimationController:LoadAnimation(clone3.Run):Play()

	for _, emitter in pairs(mesh.Attachment:GetChildren()) do
		if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("Change")) then
			continue
		end

		emitter.Rate *= 2.2
		local lifetime = emitter.Lifetime
		emitter.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
	end

	local flag = false

	local function touch()
		if flag then
			return
		end

		flag = true
		local boom = reference:GetAttribute("Boom")
		clone3.Root.CFrame = boom
		clone3.Root.Anchored = true
		bodyVelocity:Destroy()

		for _, child in pairs(clone3:GetChildren()) do
			if child:IsA("Mesh") or child:IsA("MeshPart") then
				TweenService:Create(child, v[2], {
					Transparency = 1
				}):Play()
			end
		end

		for _, effect in pairs(mesh:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local play = Util.Sound:Play("SmokeImpact", mesh.CFrame)
		play.TimePosition = 0.125
		local cFrame2 = mesh.CFrame
		local explosion = script.Explosion
		local clone4 = explosion:Clone()
		clone4.Name = clone4.Name

		if explosion:IsA("Model") then
			clone4.Parent = _WorldOrigin
			clone4.PrimaryPart.CFrame = cFrame2
		else
			clone4.CFrame = cFrame2
			clone4.Parent = _WorldOrigin
		end

		debris:AddItem(clone4, 3)

		for _, child in pairs(clone4.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		if (workspace.CurrentCamera.CFrame.Position - boom.Position).magnitude < 100 then
			Util.CameraShaker:ShakeOnce(10, 8, 0.1, 1, createVector(1, 1, 1), createVector(1, 1, 5))
			local clone5 = script.Blur:Clone()
			clone5.Parent = game.Lighting
			TweenService:Create(clone5, v[1], {
				Size = 10
			}):Play()
			debris:AddItem(clone5, 1)
		end
	end

	local boomChangedConnection = nil

	if reference:GetAttribute("Boom") then
		touch()
	else
		boomChangedConnection = reference:GetAttributeChangedSignal("Boom"):Connect(function()
			touch()
		end)
	end

	task.wait(0.75 - v3)

	if boomChangedConnection then
		boomChangedConnection:Disconnect()
	end

	if not flag then
		flag = true
		clone3.Root.Anchored = true
		bodyVelocity:Destroy()
		local cFrame2 = mesh.CFrame
		local explosion2 = script.Explosion2
		local clone4 = explosion2:Clone()
		clone4.Name = clone4.Name

		if explosion2:IsA("Model") then
			clone4.Parent = _WorldOrigin
			clone4.PrimaryPart.CFrame = cFrame2
		else
			clone4.CFrame = cFrame2
			clone4.Parent = _WorldOrigin
		end

		debris:AddItem(clone4, 2.5)

		for _, child in pairs(clone4.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		Util.Sound:Play("SmokeCharge", mesh.CFrame)

		for _, child in pairs(clone3:GetChildren()) do
			if child:IsA("Mesh") or child:IsA("MeshPart") then
				TweenService:Create(child, v[2], {
					Transparency = 1
				}):Play()
			end
		end

		for _, effect in pairs(mesh:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end
end