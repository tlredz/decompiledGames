local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
end

local function ScaleParticles(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local numberSequenceKeypoints = {}

		for _, keypoint in emitter.Size.Keypoints do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * 0.25, keypoint.Envelope * 0.25)
			)
		end

		emitter.Size = NumberSequence.new(numberSequenceKeypoints)
		local speed = emitter.Speed
		emitter.Speed = NumberRange.new(speed.Min * 0.25, speed.Max * 0.25)
	end
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local FX = require(ReplicatedStorage:WaitForChild("FX"))
local F = FX:WaitForChild("BombRework").F
local random = Random.new()
local v = {
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://135530889139185",
	"rbxassetid://138511637855738",
	"rbxassetid://138511637855738",
	"rbxassetid://120749649345523",
	"rbxassetid://120749649345523",
	"rbxassetid://102310243857129",
	"rbxassetid://102310243857129",
	"rbxassetid://108474977001459",
	"rbxassetid://108474977001459",
	"rbxassetid://92213695816660",
	"rbxassetid://92213695816660",
	"rbxassetid://118643736609722",
	"rbxassetid://118643736609722",
	"rbxassetid://93828106193342",
	"rbxassetid://93828106193342",
	"rbxassetid://130925880037995",
	"rbxassetid://130925880037995",
	"rbxassetid://132445268949222",
	"rbxassetid://132445268949222",
	"rbxassetid://131755796674054",
	"rbxassetid://131755796674054",
	"rbxassetid://101329734542701",
	"rbxassetid://101329734542701",
	"rbxassetid://73441550360544",
	"rbxassetid://73441550360544"
}
local v2 = {
	"rbxassetid://116393957503079",
	"rbxassetid://80909680394785",
	"rbxassetid://95630632044819",
	"rbxassetid://108191552775354",
	"rbxassetid://89074170362017",
	"rbxassetid://71571417999265",
	"rbxassetid://80535182901890",
	"rbxassetid://77405538044765",
	"rbxassetid://103677931814244",
	"rbxassetid://106052936885775",
	"rbxassetid://120903577796175",
	"rbxassetid://131294518763834"
}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
return function(p)
	local position = p.Position

	if (workspace.CurrentCamera.CFrame.p - position).Magnitude > 900 then
		return
	end

	Util.Sound:Play("BF_NewFruit_F_ExplodeDash_0" .. tostring(math.random(1, 3)), position)
	local clone = F.Explosion:Clone()
	clone.Size *= 0.25
	ScaleParticles(clone)
	clone.Position = position
	clone.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(clone, 5)

	if (workspace.CurrentCamera.CFrame.p - clone.CFrame.Position).Magnitude < 22.5 then
		Util.CameraShaker:ShakeOnce(2, 1.5, 0.1, 0.25)
	end

	task.delay(ParticleState(clone), clone.Destroy, clone)
	local raycastResult = workspace:Raycast(position, createVector(0, -5, 0), raycastParams)

	if raycastResult then
		local clone2 = F.FloorScorch:Clone()
		clone2.Size *= 0.25
		ScaleParticles(clone2)
		clone2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone2.Parent = workspace._WorldOrigin
		task.delay(ParticleState(clone2), clone2.Destroy, clone2)
	end

	local clone2 = F.Cylinder:Clone()
	clone2.Size *= 0.25
	ScaleParticles(clone2)
	clone2.Position = clone.Position
	clone2.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(clone2, 5)
	task.spawn(function()
		for _, texture in v2 do
			clone2.Decal.Texture = texture
			RunService.Heartbeat:Wait()
		end

		clone2:Destroy()
	end)

	for _ = 1, 7 do
		local clone3 = F.CloudMesh:Clone()
		clone3.Position = clone.Position + Vector3.new(
			random:NextNumber(-20, 20),
			random:NextNumber(-20, 20),
			random:NextNumber(-20, 20)
		) * 0.25
		clone3.Orientation = Vector3.new(
			random:NextNumber(0, 360),
			random:NextNumber(0, 360),
			random:NextNumber(0, 360)
		)
		clone3.Mesh.Scale = createVector(1, 1, 1) * random:NextNumber(4, 5) * 0.25
		Util.Debris:AddItem(clone3, 5)
		local lookVector = raycastResult and (CFrame.lookAt(
			raycastResult.Position,
			raycastResult.Position + raycastResult.Normal
		) * CFrame.Angles(
			math.rad((random:NextNumber(-90, 90))),
			math.rad((random:NextNumber(-90, 90))),
			(math.rad((random:NextNumber(-90, 90))))
		)).LookVector or Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
		TweenService:Create(
			clone3,
			TweenInfo.new(random:NextNumber(0.45, 0.65), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Position = clone3.Position + lookVector * random:NextNumber(10, 15) * 0.25,
				Orientation = clone3.Orientation + Vector3.new(
					random:NextNumber(-70, 70),
					random:NextNumber(-70, 70),
					random:NextNumber(-70, 70)
				)
			}
		):Play()
		TweenService:Create(clone3.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Scale = clone3.Mesh.Scale + createVector(1, 1, 1) * random:NextNumber(8, 10) * 0.25
		}):Play()
		task.delay(0.15, function()
			if clone3.Parent ~= nil then
				TweenService:Create(
					clone3.Decal,
					TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Color3 = Color3.new(0, 0, 0)
					}
				):Play()
			end
		end)
		clone3.Parent = workspace._WorldOrigin
		local v4 = clone3
		task.spawn(function()
			for k, texture in v do
				v4.Decal.Texture = texture
				RunService.Heartbeat:Wait()
			end

			v4:Destroy()
		end)
	end

	for i = 1, 3 do
		local v3 = (i - 1) * 120
		local v4 = 3.75
		local number = random:NextNumber(0, 360)
		local clone3 = F.Trail:Clone()
		ScaleParticles(clone3)
		local v5 = math.sin((math.rad(v3))) * v4
		local v6 = math.sin((math.rad(number))) * v4
		clone3.Position = position + Vector3.new(v5, v6, math.cos((math.rad(v3))) * v4)
		clone3.Parent = workspace._WorldOrigin
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			v3 += 720 * dt
			number += 720 * dt
			v4 = v4 <= 0 and v4 or v4 - 3.75 * dt * 2
			clone3.Position = position + Vector3.new(
				math.sin((math.rad(v3))) * v4,
				math.sin((math.rad(number))) * v4,
				math.cos((math.rad(v3))) * v4
			)
		end)
		local v8 = clone3
		task.delay(0.5, function()
			heartbeatConnection:Disconnect()
			task.wait(v8.Trail.Lifetime)
			v8:Destroy()
		end)
	end
end