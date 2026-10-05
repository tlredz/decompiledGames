local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local lightningBolt3 = Util.LightningBolt3

local function AllVFX(clone, enabled2, p2)
	local function Emit(folder, enabled, duration)
		for _, effect in ipairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
				continue
			end

			effect.Enabled = enabled
		end

		if duration then
			task.delay(duration, function()
				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					effect.Enabled = false
				end
			end)
		end
	end

	if typeof(clone) ~= "table" then
		Emit(clone, enabled2, p2)
		return
	end

	for _, item in clone do
		Emit(item, enabled2, p2)
	end
end

function EmitAll(items)
	local function Emit(folder)
		for _, emitter in ipairs(folder:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if emitter:GetAttribute("EmitDelay") then
				local v = emitter
				task.delay(emitter:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if typeof(items) ~= "table" then
		Emit(items)
		return
	end

	for _, item in items do
		Emit(item)
	end
end

return function(data)
	local player = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local cFrame = data.CFrame
	local cFrame2 = data.CFrame * CFrame.new(0, 0, -data.Distance)
	local color = Color3.fromRGB(75, 111, 255)
	Util.Sound:Play("TremorErupt", hrp, 25)
	Util.Sound:Play("QuickSlice", hrp, 25)
	Util.Sound:Play("ElectricDragonStrike", hrp, 25, nil, 0.5)
	local clone = FX:WaitForChild("Koko").Sphere:Clone()
	clone.CFrame = parent.RightHand.CFrame * CFrame.new(0, -parent.RightHand.Size.Y / 2, 0)
	clone.CFrame = CFrame.new(clone.Position, cFrame2.Position)
	clone.Size = createVector(10, 10, 10)
	clone.Color = color
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(0.2), {
		Size = Vector3.new(0, 0, (clone.Position - cFrame2.Position).magnitude),
		CFrame = CFrame.new(clone.Position, cFrame2.Position) * CFrame.new(
			0,
			0,
			(clone.Position - cFrame2.Position).magnitude / -2
		)
	})
	tween:Play()
	tween:Destroy()
	destroyAfter(clone, 0.2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = { parent, Workspace._WorldOrigin }
	local raycastResult = Workspace:Raycast(cFrame.Position, createVector(0, -10, 0), raycastParams)

	if raycastResult then
		local clone2 = FX:WaitForChild("Koko").Soot:Clone()
		clone2.CFrame = Util.Misc.AlignCFrame(
			CFrame.new(createVector(0, 0, 0), cFrame2.p - cFrame.p) + raycastResult.Position,
			raycastResult.Normal
		) + raycastResult.Normal * 0.05
		clone2.Parent = _WorldOrigin
		local tween2 = TweenService:Create(clone2, TweenInfo.new(0.2), {
			Size = Vector3.new(clone2.Size.X, clone2.Size.Y, (cFrame.Position - cFrame2.Position).Magnitude * 1.5),
			CFrame = clone2.CFrame * CFrame.new(0, 0, -(cFrame.Position - cFrame2.Position).Magnitude / 2)
		})
		tween2:Play()
		tween2:Destroy()
		task.delay(0.7, function()
			local tween3 = TweenService:Create(clone2.Decal, TweenInfo.new(0.7), {
				Transparency = 1
			})
			tween3:Play()
			tween3:Destroy()
			destroyAfter(clone2, 0.7)
		end)
	end

	local clone2 = FX:WaitForChild("Koko").Ring2:Clone()
	clone2.CFrame = cFrame * CFrame.new(0, 0, -(hrp.Position - cFrame2.Position).Magnitude / 4) * CFrame.Angles(
		1.5707963267948966,
		0,
		0
	)
	clone2.Size = Vector3.new(10, (clone2.Position - cFrame2.Position).Magnitude / 2, 10)
	clone2.Parent = _WorldOrigin
	local tween2 = TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = createVector(30, 0, 30),
		CFrame = clone2.CFrame * CFrame.new(0, clone2.Size.Y / 2, 0),
		Transparency = 1
	})
	tween2:Play()
	tween2:Destroy()
	destroyAfter(clone2, 0.5)
	local clone3 = FX:WaitForChild("Koko").Ring2:Clone()
	clone3.CFrame = cFrame * CFrame.new(0, 0, -(hrp.Position - cFrame2.Position).Magnitude / 2.5) * CFrame.Angles(
		1.5707963267948966,
		0,
		0
	)
	clone3.Size = Vector3.new(10, (clone3.Position - cFrame2.Position).Magnitude / 2, 10)
	clone3.Color = color
	clone3.Parent = _WorldOrigin
	local tween3 = TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = createVector(20, 0, 20),
		CFrame = clone3.CFrame * CFrame.new(0, clone3.Size.Y / 2, 0),
		Transparency = 1
	})
	tween3:Play()
	tween3:Destroy()
	destroyAfter(clone3, 0.5)

	for _ = 1, 3 do
		local magnitude = (clone3.Position - cFrame2.Position).Magnitude
		local clone4 = FX:WaitForChild("Koko").Sphere:Clone()
		clone4.CFrame = cFrame * CFrame.new(
			math.random(-5, 5),
			math.random(-1, 4),
			-(hrp.Position - cFrame2.Position).Magnitude / 1.4
		)
		clone4.Size = createVector(1, 1, 1)
		clone4.Parent = _WorldOrigin
		local tween4 = TweenService:Create(clone4, TweenInfo.new(0.3), {
			Size = Vector3.new(0, 0, magnitude),
			CFrame = clone4.CFrame * CFrame.new(0, 0, magnitude / 2)
		})
		tween4:Play()
		tween4:Destroy()
		destroyAfter(clone4, 0.3)
	end

	for _ = 1, 3 do
		local magnitude = (clone3.Position - cFrame2.Position).Magnitude
		local clone4 = FX:WaitForChild("Koko").Sphere:Clone()
		clone4.CFrame = cFrame * CFrame.new(
			math.random(-5, 5),
			math.random(-1, 4),
			-(hrp.Position - cFrame2.Position).Magnitude / 1.5
		)
		clone4.Size = createVector(1, 1, 1)
		clone4.Color = Color3.fromRGB(0, 0, 0)
		clone4.Parent = _WorldOrigin
		local tween4 = TweenService:Create(clone4, TweenInfo.new(0.3), {
			Size = Vector3.new(0, 0, magnitude),
			CFrame = clone4.CFrame * CFrame.new(0, 0, magnitude / 2)
		})
		tween4:Play()
		tween4:Destroy()
		destroyAfter(clone4, 0.3)
	end

	for _ = 1, 2 do
		local v2 = {
			WorldPosition = cFrame.Position,
			WorldAxis = createVector(0, 1, 0)
		}
		local v3 = {
			WorldPosition = cFrame2.Position,
			WorldAxis = createVector(0, 0, 0)
		}
		local v4 = lightningBolt3.new(v2, v3, 10)
		v4.PulseSpeed = 5.5
		v4.Frequency = 5
		v4.PulseLength = 1
		v4.FadeLength = 0.2
		v4.MinRadius = 10
		v4.MaxRadius = 15
		v4.Thickness = 2
		v4.Color = ColorSequence.new(color, color)
	end

	if player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(10, 7, 0.2, 1.2, createVector(1, 1, 1), createVector(1, 1, 4))
	end

	local clone4 = FX:WaitForChild("Koko")["Electric Stab"]:Clone()
	clone4.PrimaryPart.Anchored = true
	clone4:PivotTo(cFrame)
	AllVFX(clone4, false)
	clone4.Parent = Workspace._WorldOrigin

	for _, emitter in pairs(clone4:GetDescendants()) do
		if not (emitter:IsA("ParticleEmitter") and (not emitter.Parent.Name:find("Hold") or raycastResult)) then
			continue
		end

		if emitter:GetAttribute("EmitDelay") then
			local v2 = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	destroyAfter(clone4, 2)
	local tween4 = TweenService:Create(hrp, TweenInfo.new(data.Distance / 500), {
		CFrame = cFrame2
	})
	tween4:Play()
	tween4:Destroy()
end