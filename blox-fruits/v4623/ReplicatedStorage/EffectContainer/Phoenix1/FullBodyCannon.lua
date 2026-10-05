local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
require(game.ReplicatedStorage.Util.RocksModule)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local fullBodyCannon = FX:WaitForChild("Phoenix1").FullBodyCannon

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
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.4, Enum.EasingStyle.Sine)
}

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local _ = character.Humanoid
	local position = player.Position
	local ref = player.Ref

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 300 then
		return
	end

	if character == game.Players.LocalPlayer.Character or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude < 50 then
		Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion2)
	end

	local cFrame = CFrame.new(humanoidRootPart.Position, position) * CFrame.new(0, 0, -5) * CFrame.Angles(1.57, 0, 0)
	local ball = fullBodyCannon.Ball
	local clone = ball:Clone()
	clone.Name = clone.Name

	if ball:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
	else
		clone.CFrame = cFrame
	end

	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 3)
	local bodyVelocity = Instance.new("BodyVelocity", clone)
	bodyVelocity.MaxForce = createVector(500000, 500000, 500000)
	bodyVelocity.Velocity = CFrame.new(humanoidRootPart.Position, position).lookVector * 180
	local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, -1.57, 0)
	local release = fullBodyCannon.release
	local clone2 = release:Clone()
	clone2.Name = clone2.Name

	if release:IsA("Model") then
		clone2:SetPrimaryPartCFrame(cFrame2)
	else
		clone2.CFrame = cFrame2
	end

	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 1)

	for _, child in pairs(clone2.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, 0, -10)
	local wind = fullBodyCannon.Wind
	local clone3 = wind:Clone()
	clone3.Name = clone3.Name

	if wind:IsA("Model") then
		clone3:SetPrimaryPartCFrame(cFrame3)
	else
		clone3.CFrame = cFrame3
	end

	clone3.Parent = _WorldOrigin
	clone3.Mesh.Scale *= 0.75
	Debris:AddItem(clone3, 1)
	TweenService:Create(clone3, v[4], {
		Transparency = 1,
		CFrame = clone3.CFrame * CFrame.new(0, 0, -6) * CFrame.Angles(0, 0, 1.57)
	}):Play()
	TweenService:Create(clone3.Mesh, v[4], {
		Scale = Vector3.new(clone3.Mesh.Scale.X * 1.25, clone3.Mesh.Scale.Y * 1.25, clone3.Mesh.Scale.Z * 2.5)
	}):Play()

	repeat
		wait()
	until clone.Parent == nil or ref.Parent == nil or ref:GetAttribute("Hit")

	local hit = ref:GetAttribute("Hit")

	if not hit then
		return
	end

	if (workspace.CurrentCamera.CFrame.Position - clone.Position).magnitude < 100 then
		Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion)
		local clone4 = fullBodyCannon.Blur:Clone()
		clone4.Size = 0
		clone4.Parent = game.Lighting
		TweenService:Create(clone4, v[3], {
			Size = 10
		}):Play()
		Debris:AddItem(clone4, 1)
	end

	Util.Sound:Play("Mera_FireFistExplosion", clone.Position)
	clone.Anchored = true

	for _, descendant in pairs(clone:GetDescendants()) do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("PointLight")) then
			continue
		end

		descendant.Enabled = false
	end

	local cframe = CFrame.new(hit)
	local explosion = fullBodyCannon.Explosion
	local clone4 = explosion:Clone()
	clone4.Name = clone4.Name

	if explosion:IsA("Model") then
		clone4:SetPrimaryPartCFrame(cframe)
	else
		clone4.CFrame = cframe
	end

	clone4.Parent = _WorldOrigin
	Debris:AddItem(clone4, 2)

	for _, emitter in pairs(clone4:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local raycastResult = workspace:Raycast(hit + createVector(0, 1, 0), createVector(0, -10, 0), raycastParams)

	if raycastResult then
		local cFrame4 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local scar = fullBodyCannon.Scar
		local clone5 = scar:Clone()
		clone5.Name = clone5.Name

		if scar:IsA("Model") then
			clone5:SetPrimaryPartCFrame(cFrame4)
		else
			clone5.CFrame = cFrame4
		end

		clone5.Parent = _WorldOrigin

		for _, child in pairs(clone5:GetChildren()) do
			TweenService:Create(child, v[1], {
				Transparency = 1
			}):Play()
		end

		Debris:AddItem(clone5, 1.26)
	end
end