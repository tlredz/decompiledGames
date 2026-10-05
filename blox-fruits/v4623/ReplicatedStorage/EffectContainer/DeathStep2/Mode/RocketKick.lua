local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local CraterModule = require(game.ReplicatedStorage.Util.CraterModule)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local FX = require(game.ReplicatedStorage.FX)
local rocketKick = FX:WaitForChild("DeathStep2").Mode.RocketKick

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
	TweenInfo.new(0.3, Enum.EasingStyle.Linear),
	TweenInfo.new(0.4, Enum.EasingStyle.Quint),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.35, Enum.EasingStyle.Quad),
	TweenInfo.new(0.1, Enum.EasingStyle.Sine),
	TweenInfo.new(0.4, Enum.EasingStyle.Quart),
	TweenInfo.new(0.6, Enum.EasingStyle.Quad)
}
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

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

return function(data)
	local HRP = data.HRP

	if (workspace.CurrentCamera.CFrame.Position - HRP.Position).magnitude > 800 then
		return
	end

	if data.Normal == nil then
		if not (data.Using and data.Holding) then
			return
		end

		local clone = rocketKick.Charge:Clone()
		clone.Anchored = false
		clone.Weld.Part0 = HRP
		clone.Parent = workspace._WorldOrigin

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = true
			end
		end

		while data.Holding.Value and data.Holding:IsDescendantOf(workspace) do
			wait()
		end

		Util.Sound:Play("SpinWoosh2", HRP)
		local cFrame = HRP.CFrame
		local lines = rocketKick.Lines
		local clone2 = lines:Clone()
		clone2.Name = clone2.Name

		if lines:IsA("Model") then
			clone2:SetPrimaryPartCFrame(cFrame)
		else
			clone2.CFrame = cFrame
		end

		clone2.Parent = _WorldOrigin
		local weld = Instance.new("Weld", clone2)
		weld.Part0 = HRP
		weld.Part1 = clone2

		while data.Using:IsDescendantOf(workspace) do
			wait()
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Debris:AddItem(clone2, 1)
		Debris:AddItem(clone, 1)
	else
		local position = data.Position
		local character = game.Players.LocalPlayer.Character

		if character ~= nil then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and (humanoidRootPart.Position - position).magnitude <= 75 then
				Util.CameraShaker:Shake(Util.CameraShaker.Presets.Explosion2)
			end
		end

		local scale = data.Scale or 1
		Util.Sound:Play("GroundSmash", data.Position)
		local cframe = CFrame.new(data.Position, data.Position + data.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local cFrame = cframe * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0) * CFrame.Angles(
			0,
			0,
			1.57
		)
		local middleShock = rocketKick.MiddleShock
		local clone = middleShock:Clone()
		clone.Name = clone.Name

		if middleShock:IsA("Model") then
			clone:SetPrimaryPartCFrame(cFrame)
		else
			clone.CFrame = cFrame
		end

		clone.Parent = _WorldOrigin
		clone.Size *= scale
		Debris:AddItem(clone, 1)
		TweenService:Create(clone, v[2], {
			CFrame = clone.CFrame * CFrame.new(15 * scale, 0, 0)
		}):Play()
		TweenService:Create(clone.Mesh, v[3], {
			Scale = clone.Mesh.Scale * createVector(8.1, 0, 0) * 1.5 * scale
		}):Play()
		local cFrame2 = cframe * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-180, 180))),
			1.57
		)
		local shockwave = rocketKick.Shockwave
		local clone2 = shockwave:Clone()
		clone2.Name = clone2.Name

		if shockwave:IsA("Model") then
			clone2:SetPrimaryPartCFrame(cFrame2)
		else
			clone2.CFrame = cFrame2
		end

		clone2.Parent = _WorldOrigin
		clone2.Size *= scale
		Debris:AddItem(clone2, 1)
		TweenService:Create(clone2, v[4], {
			CFrame = clone2.CFrame * CFrame.new(-2 * scale, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone2.Mesh, v[5], {
			Scale = createVector(0.3, 1.2, 1.2) * scale
		}):Play()
		TweenService:Create(clone2.Decal, v[5], {
			Transparency = 1
		}):Play()
		local cFrame3 = cframe * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-180, 180))),
			1.5707963267948966
		)
		local shockwave2 = rocketKick.Shockwave2
		local clone3 = shockwave2:Clone()
		clone3.Name = clone3.Name

		if shockwave2:IsA("Model") then
			clone3:SetPrimaryPartCFrame(cFrame3)
		else
			clone3.CFrame = cFrame3
		end

		clone3.Parent = _WorldOrigin
		clone3.Size *= scale
		Debris:AddItem(clone3, 1)
		TweenService:Create(clone3, v[6], {
			CFrame = clone3.CFrame * CFrame.new(-3.7 * scale, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone3.Mesh, v[7], {
			Scale = createVector(0, 0.90000004, 0.90000004) * scale
		}):Play()
		TweenService:Create(clone3.Decal, v[8], {
			Transparency = 1
		}):Play()
		local cFrame4 = cframe * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local explosion = rocketKick.Explosion
		local clone4 = explosion:Clone()
		clone4.Name = clone4.Name

		if explosion:IsA("Model") then
			clone4:SetPrimaryPartCFrame(cFrame4)
		else
			clone4.CFrame = cFrame4
		end

		clone4.Parent = _WorldOrigin
		clone4.Size *= scale
		Debris:AddItem(clone4, 1)

		for _, child in pairs(clone4.Attachment:GetChildren()) do
			if scale ~= 1 then
				ScaleParticle({
					Emitter = child,
					Time = 0,
					Scale = scale
				})
			end

			if child.Name == "GroundStuff" then
				child.Color = ColorSequence.new(data.Color)
			end

			child:Emit(child:GetAttribute("EmitCount"))
		end

		local cFrame5 = cframe * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local scar = rocketKick.Scar
		local clone5 = scar:Clone()
		clone5.Name = clone5.Name

		if scar:IsA("Model") then
			clone5:SetPrimaryPartCFrame(cFrame5)
		else
			clone5.CFrame = cFrame5
		end

		clone5.Parent = _WorldOrigin
		clone5.Size *= 1.75 * scale

		for _, child in pairs(clone5:GetChildren()) do
			TweenService:Create(child, v[1], {
				Transparency = 1
			}):Play()
		end

		Debris:AddItem(clone5, 1.26)
		CraterModule({
			Cframe = cframe,
			Size = 6 * scale,
			Ammount = 7,
			Despawn = 1 * scale,
			Distance = 12 * scale
		})
	end
end