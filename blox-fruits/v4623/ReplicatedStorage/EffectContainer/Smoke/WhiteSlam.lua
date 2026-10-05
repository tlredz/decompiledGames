local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local CraterModule = require(game.ReplicatedStorage.Util.CraterModule)
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
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.3, Enum.EasingStyle.Linear),
	TweenInfo.new(0.4, Enum.EasingStyle.Quint),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.35, Enum.EasingStyle.Quad),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, rightPart, p, p2)
	local clone = rightPart:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local v2 = { "RightLowerArm", "RightHand", "RightUpperArm" }
return function(player)
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 400 then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local rightPart = script.RightPart
	local v3 = "WhiteSlamArm" .. character.Name
	local effect_2 = createEffect(cFrame, rightPart, v3)
	effect_2.Weld.Part0 = character.RightLowerArm

	for _, childName in pairs(v2) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 1
		end
	end

	Sound:Play("SmokeCharge", humanoidRootPart.Position)

	repeat
		wait()
	until not player.Holding or not player.Holding:IsDescendantOf(workspace) or humanoid.Health <= 0 or not player.Holding.Value

	local child = _WorldOrigin:FindFirstChild("WhiteSlamArm" .. character.Name)

	if child then
		child.Name = "OldArm"
		task.wait(0.15)

		if character == game.Players.LocalPlayer.Character then
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ShakeCam"):replicate({
				3.5,
				8,
				0,
				1.5,
				createVector(0.25, 0.25, 0.25),
				createVector(1, 1, 1)
			})
			local clone = script.Blur:Clone()
			clone.Parent = game.Lighting
			TweenService:Create(clone, v[6], {
				Size = 10
			}):Play()
			Debris:AddItem(clone, 1)
		end

		Sound:Play("SmokeImpact", humanoidRootPart.CFrame * createVector(0, 0, -10))
		local raycastResult = workspace:Raycast(
			(humanoidRootPart.CFrame * CFrame.new(0, 0, -10)).Position,
			createVector(0, -20, 0),
			raycastParams
		)

		if raycastResult then
			local cFrame2 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
			local clone = script.Scar:Clone()
			clone.Name = clone.Name
			clone.CFrame = cFrame2
			clone.Parent = _WorldOrigin

			for _, child2 in pairs(clone:GetChildren()) do
				TweenService:Create(child2, v[1], {
					Transparency = 1
				}):Play()
			end

			Debris:AddItem(clone, 1.26)
		end

		local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, -2, -10)
		local clone = script.eff:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame3
		clone.Parent = _WorldOrigin
		Debris:AddItem(clone, 2)

		for _, child2 in pairs(clone.Attachment:GetChildren()) do
			child2:Emit(child2:GetAttribute("EmitCount"))
		end

		local cFrame4 = humanoidRootPart.CFrame * CFrame.new(0, 3, -10) * CFrame.Angles(0, 0, 1.57)
		local clone2 = script.MiddleShock:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame4
		clone2.Parent = _WorldOrigin
		Debris:AddItem(clone2, 1)
		TweenService:Create(clone2, v[2], {
			CFrame = clone2.CFrame * CFrame.new(15, 0, 0)
		}):Play()
		TweenService:Create(clone2.Mesh, v[3], {
			Scale = clone2.Mesh.Scale * createVector(8.1, 0, 0)
		}):Play()
		local cFrame5 = humanoidRootPart.CFrame * CFrame.new(0, -1, -10) * CFrame.Angles(
			0,
			math.rad((math.random(-180, 180))),
			1.57
		)
		local clone3 = script.Shockwave:Clone()
		clone3.Name = clone3.Name
		clone3.CFrame = cFrame5
		clone3.Parent = _WorldOrigin
		Debris:AddItem(clone3, 1)
		TweenService:Create(clone3, v[4], {
			CFrame = clone3.CFrame * CFrame.new(-2, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone3.Mesh, v[5], {
			Scale = createVector(0.2, 0.8, 0.8)
		}):Play()
		TweenService:Create(clone3.Decal, v[5], {
			Transparency = 1
		}):Play()
		CraterModule({
			Cframe = humanoidRootPart.CFrame * CFrame.new(0, 0, -10),
			Size = 4,
			Ammount = 5,
			Despawn = 1,
			Distance = 8
		})
		task.delay(0.2, function()
			Debris:AddItem(child, 2)
			pcall(function()
				child.Weld.Part0 = nil
			end)
			child.Anchored = true

			for _, effect in pairs(child:GetChildren()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			for _, childName in pairs(v2) do
				local child2 = character:FindFirstChild(childName)

				if child2 then
					child2.Transparency = 0
				end
			end
		end)
	end
end