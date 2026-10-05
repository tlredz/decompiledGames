local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local SpiralTrail = require(game.ReplicatedStorage.Util.SpiralTrail)
require(game.ReplicatedStorage.Util.ScaleParticle)
local CraterModule = require(game.ReplicatedStorage.Util.CraterModule)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Effect = require(game.ReplicatedStorage.Effect)

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
	TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local v2 = {
	"LeftLowerArm",
	"RightLowerArm",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerLeg",
	"RightLowerLeg",
	"LeftUpperLeg",
	"RightUpperLeg"
}
return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local timer = player.Timer

	if player.Toggle then
		local cFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
		local clone = script.ExtraEffects:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		local color = Color3.new(1, 0.686275, 0.94902)
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color:lerp(Color3.new(1, 1, 1), 0.2)),
			ColorSequenceKeypoint.new(1, color:lerp(Color3.new(1, 1, 1), 0.4))
		})
		local colorSequence2 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, color:lerp(Color3.new(1, 1, 1), 0.2))
		})
		local colorSequence3 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color:lerp(Color3.new(0, 0, 0), 0.7)),
			ColorSequenceKeypoint.new(1, color:lerp(Color3.new(0, 0, 0), 0.7))
		})
		local colorSequence4 = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color:lerp(Color3.new(0.5, 0.5, 0.5), 0.85)),
			ColorSequenceKeypoint.new(1, color:lerp(Color3.new(0.5, 0.5, 0.5), 0.9))
		})

		for _, light in pairs(clone:GetDescendants()) do
			if light.Name == "Color1" then
				light.Color = colorSequence
			elseif light.Name == "Color2" then
				light.Color = colorSequence2
			elseif light.Name == "Color3" then
				light.Color = colorSequence3
			elseif light.Name == "Color4" then
				light.Color = colorSequence4
			elseif light:IsA("PointLight") then
				light.Color = color
			end
		end

		task.delay(0.25, function()
			for _, descendant in pairs(clone:GetDescendants()) do
				if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
					continue
				end

				descendant.Enabled = false
			end

			Debris:AddItem(clone, 3)
		end)

		for _, part in pairs(character:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local color3Value = Instance.new("Color3Value", part)
			color3Value.Name = "OLDCOLOR"
			color3Value.Value = part.Color
			TweenService:Create(part, v[2], {
				Color = Color3.new(1, 0.686275, 0.882353)
			}):Play()

			if table.find(v2, part.Name) then
				for _, child in pairs(script["Body effects"]:GetChildren()) do
					local clone2 = child:Clone()
					clone2.Parent = part
					clone2.Name = "Gear2Effect"
				end
			elseif part.Name == "UpperTorso" then
				local clone_2 = script.Gear2Ring:Clone()
				clone_2.Parent = part
			end
		end

		if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
			local gear2Ring = character.UpperTorso:FindFirstChild("Gear2Ring")

			if gear2Ring then
				gear2Ring.Enabled = false
				Debris:AddItem(gear2Ring, 1)
			end
		else
			if character == game.Players.LocalPlayer.Character then
				Effect.new("ShakeCam"):replicate({
					2.5,
					4,
					0.1,
					0.75,
					createVector(0.3, 0.3, 0.3),
					createVector(2, 2, 2)
				})
				local clone2 = script.Blur:Clone()
				clone2.Parent = game.Lighting
				TweenService:Create(clone2, v[3], {
					Size = 10
				}):Play()
				Debris:AddItem(clone2, 1)
			end

			local cFrame2 = humanoidRootPart.CFrame * CFrame.new(-0.6, -2.5, 0)
			local clone2 = script.Shock:Clone()
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame2
			clone2.Parent = _WorldOrigin
			Debris:AddItem(clone2, 1)
			TweenService:Create(clone2, v[1], {
				Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
				Transparency = 1
			}):Play()
			local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, -2, 0)
			local clone3 = script.FloorLines:Clone()
			clone3.Name = clone3.Name
			clone3.CFrame = cFrame3
			clone3.Parent = _WorldOrigin

			for _, descendant in pairs(clone3:GetDescendants()) do
				if descendant.Name == "ParticleEmitter" then
					descendant:Emit(descendant:GetAttribute("EmitCount"))
				end
			end

			CraterModule({
				Cframe = humanoidRootPart.CFrame * CFrame.new(-0.6, -2.5, 0),
				Size = 2.75,
				Ammount = 6,
				Despawn = 1,
				Distance = 3
			})
			SpiralTrail(humanoidRootPart.CFrame * CFrame.new(0, -3, 0), {
				Lifetime = 1,
				Size = 0.1,
				Time = 1.3,
				Radius = 3,
				Offset = 0.0485,
				Color = Color3.new(1, 1, 1),
				Frequency = 1
			})
			Sound:Play("RubberTransform", humanoidRootPart)
			Sound:Play("RubberSteamLoop", humanoidRootPart)
			task.wait(timer - 0.8)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			Debris:AddItem(clone3, 1)
			local gear2Ring = character.UpperTorso:FindFirstChild("Gear2Ring")

			if gear2Ring then
				gear2Ring.Enabled = false
				Debris:AddItem(gear2Ring, 1)
			end
		end
	else
		local rubberSteamLoop = humanoidRootPart:FindFirstChild("RubberSteamLoop")

		if rubberSteamLoop then
			Sound:FadeOut(rubberSteamLoop, 0.5)
		end

		for _, part in pairs(character:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local OLDCOLOR = part:FindFirstChild("OLDCOLOR")

			if OLDCOLOR then
				TweenService:Create(part, v[2], {
					Color = OLDCOLOR.Value
				}):Play()
				OLDCOLOR:Destroy()
			end

			if not table.find(v2, part.Name) then
				continue
			end

			for _, child in pairs(part:GetChildren()) do
				if child.Name ~= "Gear2Effect" then
					continue
				end

				child.Enabled = false
				Debris:AddItem(child, 1)
			end
		end
	end
end