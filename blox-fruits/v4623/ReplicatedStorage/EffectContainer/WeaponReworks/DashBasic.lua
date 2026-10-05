local createVector = vector.create
local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
require(game.ReplicatedStorage.Util.Sound)
local Util = require(game.ReplicatedStorage.Util)

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
	TweenInfo.new(0.13, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local humanoidRootPart = player.Character.HumanoidRootPart
	local player2 = player.Player

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 400 then
		return
	end

	local duration = player.Duration or 0.2
	local cFrame = player.CFrame or humanoidRootPart.CFrame
	local color1 = player.Color1 or Color3.new(0.666667, 0.827451, 1)
	local color2 = player.Color2 or Color3.new(0.631373, 0.654902, 0.847059)

	if player2 == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(10, 7, 0.2, 2, createVector(1, 1, 1), createVector(1, 1, 5))
	end

	local _, v2 = Util.Ray(
		cFrame.Position,
		cFrame.LookVector * (player.Distance or 50),
		{ workspace.Characters, workspace.Enemies }
	)
	task.delay(duration * 0.1, function()
		TweenService:Create(humanoidRootPart, TweenInfo.new(duration * 0.9, Enum.EasingStyle.Quad), {
			CFrame = CFrame.new(v2, cFrame.Position) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
	end)
	Util.Sound:Play("QuickSlice", cFrame)
	local clone = script.eff:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 0.5)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		if child.Name == "Star" then
			child.Color = ColorSequence.new(color1)
		end

		child:Emit(child:GetAttribute("EmitCount"))
	end

	local cFrame2 = humanoidRootPart.CFrame
	local clone2 = script.Ball:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame2
	clone2.Parent = _WorldOrigin
	clone2.Color = color2
	clone2.Weld.Part0 = humanoidRootPart
	TweenService:Create(clone2, TweenInfo.new(duration * 0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = Vector3.new(0, clone2.Size.Y, 0)
	}):Play()
	task.delay(duration * 0.8, function()
		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(0.075)
		clone2.Transparency = 1
		Debris:AddItem(clone2, 0.5)
	end)
	resume(create(function()
		task.wait(0.025)

		for i = 1, 6, 5 do
			local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, 1, i * -2) * CFrame.Angles(0, 1.57, 1.57)
			local clone3 = script.Shockwave:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			Debris:AddItem(clone3, 0.5)

			if i == 1 then
				TweenService:Create(clone3, v[2], {
					CFrame = clone3.CFrame * CFrame.new(0, -6, 0),
					Size = Vector3.new(clone3.Size.X * 2.5, 0, clone3.Size.Z * 2.5),
					Transparency = 1
				}):Play()
			else
				TweenService:Create(clone3, v[2], {
					CFrame = clone3.CFrame * CFrame.new(0, -6, 0),
					Size = Vector3.new(clone3.Size.X * 1.75, 0, clone3.Size.Z * 1.75),
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.025)

		for _ = 1, 5 do
			local v3 = math.random(-3, 3)
			local v4 = math.random(-3, 3)
			local v5 = math.random(-3, 3)
			local v6 = math.random(1, 8) * 4
			local cFrame3 = humanoidRootPart.CFrame * CFrame.new(v3, v4, 12 + v6 + v5)
			local clone3 = script.Line:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin
			clone3.Size = Vector3.new(math.random(2, 6) / 12, math.random(2, 6) / 12, math.random(3, 10) * 2)
			Debris:AddItem(clone3, 0.13)

			if math.random(1, 2) == 1 then
				clone3.Color = Color3.new(1, 1, 1)
			else
				clone3.Color = color2
			end

			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.Parent = clone3
			specialMesh.MeshType = Enum.MeshType.Sphere
			TweenService:Create(clone3, v[1], {
				CFrame = humanoidRootPart.CFrame * CFrame.new(v3, v4, -10),
				Transparency = 1
			}):Play()
			task.wait(0.01)
		end
	end))
end