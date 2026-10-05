local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.React.Components.PlayerProfile.base)
local Component = require(game.ReplicatedStorage.Modules.Component)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local RunService = game:GetService("RunService")
local v = not RunService:IsRunning() and {
	Play = function()
		return {}
	end,
	FadeOut = function() end
} or require(game.ReplicatedStorage.Util.Sound)
local _ = game.Players.LocalPlayer

if workspace:GetAttribute("MAP") ~= "Dungeons" then
	return {}
end

local v2 = 1

local function getInstantValue()
	if v2 > 1 then
		return 10
	end

	return v2
end

local v4 = {
	BigFanThatCanMove = {
		match = function(model)
			if model:IsA("Model") and model:FindFirstChild("Cylinder.016") and model:FindFirstChild("Cylinder.009") then
				return true
			end

			return false
		end,
		run = function(instance)
			local cylinder009 = instance:FindFirstChild("Cylinder.009")
			local particleEmitter = Instance.new("ParticleEmitter")
			particleEmitter.Name = "FloorDelaySmoke"
			particleEmitter.Brightness = 0.08
			particleEmitter.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 249, 244)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 249, 244))
			})
			particleEmitter.EmissionDirection = Enum.NormalId.Right
			particleEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
			particleEmitter.FlipbookFramerate = NumberRange.new(1.5)
			particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
			particleEmitter.FlipbookMode = Enum.ParticleFlipbookMode.OneShot
			particleEmitter.Lifetime = NumberRange.new(1, 2)
			particleEmitter.LightEmission = 1
			particleEmitter.Rate = 10
			particleEmitter.Rotation = NumberRange.new(90)
			particleEmitter.SpreadAngle = Vector2.new(10, 10)
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 50),
				NumberSequenceKeypoint.new(1, 30)
			})
			particleEmitter.Speed = NumberRange.new(100)
			particleEmitter.Squash = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0.5)
			})
			particleEmitter.Texture = "http://www.roblox.com/asset/?id=12796141719"
			particleEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.300667),
				NumberSequenceKeypoint.new(0.236678, 0.406667, 0.09),
				NumberSequenceKeypoint.new(0.860678, 0.54),
				NumberSequenceKeypoint.new(1, 1)
			})
			particleEmitter.VelocityInheritance = 0.5
			particleEmitter.ZOffset = -10
			particleEmitter.Parent = cylinder009
			local v5 = v:Play("BFLab_Ambience_Air_01", cylinder009, 10, 1)
			v5.Volume = 0.5
			local v6 = nil

			while cylinder009 and cylinder009.Parent do
				if v2 > 2 then
					if not v6 then
						v:Play("BFLab_Fan_SpinOn_Activate_01", cylinder009, 15, 1)
						v6 = v:Play("BFLab_Metal_Rattle_03", cylinder009, 7, 1)
						v6.Looped = true
					end

					v6.Volume = (v2 - 1) * 0.1 + 0.1
				elseif v6 then
					v:FadeOut(v6, 1)
					v6 = nil
				end

				v5.Volume = math.clamp((v2 - 1) * 0.1 + 0.5, 0, 2)
				particleEmitter.Rate = (v2 - 1) * 1.5
				particleEmitter.Speed = NumberRange.new(v2 * 20, v2 * 30)
				cylinder009.CFrame *= CFrame.Angles(math.rad(v2 * 1 * task.wait() * 60), 0, 0)
			end
		end
	},
	Lightbars_top = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Cube.035" and part.Color == Color3.fromRGB(170, 25, 25) then
				return true
			end

			return false
		end,
		run = function(instance)
			local HSV, v5, v6 = Color3.toHSV(instance.Color)

			while instance and instance.Parent do
				instance.Color = Color3.fromHSV(
					HSV,
					v5 * math.clamp(math.sin(tick() * 0.2 * (v2 > 1 and 10 or v2)) * 5 + 0.5, 0, 1),
					v6
				)
				task.wait()
			end
		end
	},
	Lightbars_underground = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Plane.048" and part.Color == Color3.fromRGB(170, 25, 25) then
				return true
			end

			return false
		end,
		run = function(instance)
			local HSV, v5, v6 = Color3.toHSV(instance.Color)

			while instance and instance.Parent do
				instance.Color = Color3.fromHSV(
					HSV,
					v5,
					v6 * math.clamp(math.sin(tick() * 0.5 * (v2 > 1 and 10 or v2)) * 1 + 0.5, 0, 1)
				)
				task.wait()
			end
		end
	},
	Lightbars_Side_Stage = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Plane.050" and part.Color == Color3.fromRGB(131, 170, 158) then
				return true
			end

			return false
		end,
		run = function(instance)
			local HSV, v5, v6 = Color3.toHSV(instance.Color)

			while instance and instance.Parent do
				local _, _, _ = Color3.toHSV(instance.Color)
				instance.Color = Color3.fromHSV(
					math.lerp(HSV, HSV % 1 + 0.17, (math.min((v2 - 1) * 0.5, 1))),
					math.lerp(v5, 0.3, (math.min((v2 - 1) * 0.5, 1))),
					(math.lerp(v6, 0.5, (math.min((v2 - 1) * 0.5, 1))))
				)
				task.wait()
			end
		end
	},
	Lightbars_TopSide = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Plane.045" and part.Color == Color3.fromRGB(207, 205, 209) then
				return true
			end

			return false
		end,
		run = function(instance)
			local HSV, v5, v6 = Color3.toHSV(instance.Color)

			while instance and instance.Parent do
				local _, _, _ = Color3.toHSV(instance.Color)
				instance.Color = Color3.fromHSV(
					math.lerp(HSV, HSV % 1 - 0.15, (v2 - 1) * 0.1),
					math.lerp(v5, 0.8, (v2 - 1) * 0.1),
					v6
				)
				task.wait()
			end
		end
	},
	ConsoleWithLights = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Meshes/ignitionbossroom_Cube.008" then
				return true
			end

			return false
		end,
		run = function(instance)
			local function makeKey(p: number)
				local clone = instance:Clone()
				clone.Name = "Meshes/ignitionbossroom_Cube.008"
				clone.Anchored = true
				clone.Material = Enum.Material.Neon
				clone.Parent = instance.Parent
				clone.CFrame = instance.CFrame * CFrame.new((p - 1) * 2.4 + -6, 0.1, -0.1)
				clone.Size *= createVector(0.1, 1.1, 1.1)
				task.spawn(function()
					local HSV, v5, v6 = Color3.toHSV(clone.Color)

					while clone and clone.Parent do
						task.wait()

						if not (math.random() < v2 * 0.005) then
							continue
						end

						clone.Color = Color3.fromHSV(HSV, v5 * 0.5, v6 * 0.5)
						task.wait(math.random() * 0.3)
						clone.Color = Color3.fromHSV(HSV, v5, v6)
					end
				end)
			end

			makeKey(1)
			makeKey(2)
			makeKey(3)
			makeKey(4)
			makeKey(5)
			makeKey(6)
			local HSV, v5, v6 = Color3.toHSV(instance.Color)
			local _ = math.random() * 10
			local v7 = v:Play("BFLab_Ambience_Telemetry_Beeps_01", instance, 4, 1)
			v7.Volume = 0.2
			v7.Looped = true
			local v8 = nil

			while instance and instance.Parent do
				if v2 > 2 then
					if not v8 then
						v8 = v:Play("BFLab_Ambience_Telemetry_Beeps_Busy_01", instance, 5, 1)
						v8.Looped = true
					end

					v8.Volume = (v2 - 1) * 0.05 + 0.1

					if v7 then
						v:FadeOut(v7, 1)
						v7 = nil
					end
				else
					if v8 then
						v:FadeOut(v8, 1)
						v8 = nil
					end

					if not v7 then
						v7 = v:Play("BFLab_Ambience_Telemetry_Beeps_01", instance, 4, 1)
						v7.Volume = 0.2
						v7.Looped = true
					end
				end

				local _, _, _ = Color3.toHSV(instance.Color)
				instance.Color = Color3.fromHSV(math.lerp(HSV, 1, (v2 - 1) * 0.1), v5, v6)
				task.wait()
			end
		end
	},
	Wallgear1 = {
		match = function(part)
			if part:IsA("BasePart") and part.Color == Color3.fromRGB(129, 119, 96) then
				return true
			end

			return false
		end,
		run = function(instance)
			while instance and instance.Parent do
				instance.CFrame *= CFrame.Angles(math.rad(v2 * 5 * task.wait() * -5), 0, 0)
			end
		end
	},
	Wallgear2 = {
		match = function(part)
			if part:IsA("MeshPart") and part.Color == Color3.fromRGB(252, 250, 255) and part.MeshId == "rbxassetid://140527695225704" then
				return true
			end

			return false
		end,
		run = function(instance)
			while instance and instance.Parent do
				instance.CFrame *= CFrame.Angles(0, 0, (math.rad(v2 * 5 * task.wait() * 10)))
			end
		end
	},
	["big filly thing"] = {
		match = function(model)
			if model:IsA("Model") and model:FindFirstChild("Plane.046") then
				return true
			end

			return false
		end,
		run = function(parent)
			local plane046 = parent:FindFirstChild("Plane.046")
			local clone = plane046:Clone()
			clone.Name = "filly"
			clone.Anchored = true
			clone.CFrame *= CFrame.new(0, 0, 1)
			clone.CastShadow = false
			clone.Transparency = 0
			clone.Color = Color3.fromRGB(76, 127, 255)
			clone.Material = Enum.Material.Neon
			clone.Parent = parent

			while clone and clone.Parent do
				local v5 = (20 - math.abs(5 - v2) * 1.8) * task.wait() * 0.5
				local v6 = plane046.CFrame.Y - (v2 - 1) * 1 * 100

				if clone.CFrame.Y < v6 then
					clone.CFrame *= CFrame.new(0, v5, 0)
				elseif v6 < clone.CFrame.Y then
					clone.CFrame *= CFrame.new(0, -v5, 0)
				end
			end
		end
	},
	empty = {
		match = function(part)
			if part:IsA("BasePart") and part.Color == Color3.fromRGB(129, 119, 96) then
				return true
			end

			return false
		end,
		run = function(_) end
	},
	surflights = {
		match = function(light)
			if light:IsA("SurfaceLight") then
				return true
			end

			return false
		end,
		run = function(instance)
			local HSV, v5, v6 = Color3.toHSV(instance.Color)
			local brightness = instance.Brightness

			while instance and instance.Parent do
				local _, _, _ = Color3.toHSV(instance.Color)
				instance.Brightness = brightness - (v2 - 1) * 0
				instance.Color = Color3.fromHSV(
					HSV % 1 + 0.6,
					math.lerp(v5, 0.5, (v2 - 1) * 0.1),
					(math.lerp(v6, 0.8, (v2 - 1) * 0.1))
				)
				task.wait()
			end
		end
	},
	hexagons = {
		match = function(part)
			if part:IsA("BasePart") and (part.Name == "hexagonwall.001" or part.Name == "hexagonwall.002") then
				return true
			end

			return false
		end,
		run = function(instance)
			local HSV, v5, v6 = Color3.toHSV(instance.Color)

			while instance and instance.Parent do
				local _, _, _ = Color3.toHSV(instance.Color)
				instance.Color = Color3.fromHSV(HSV, math.lerp(v5, 0.5, (v2 - 1) * 0.1), v6)
				task.wait()
			end
		end
	},
	["green beam"] = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Cube.030" and part.Color == Color3.fromRGB(27, 100, 19) then
				return true
			end

			return false
		end,
		run = function(instance)
			local _ = instance.Color
			local cFrame = instance.CFrame
			local v5 = nil

			while instance and instance.Parent do
				task.wait()

				if v2 > 2 then
					if not v5 then
						v5 = v:Play("BFLab_Metal_Rattle_02", instance, 4, 1)
						v5.Looped = true
					end

					v5.Volume = (v2 - 1) * 0.05 + 0.1
					local v6 = (v2 - 1) * -0.05
					instance.CFrame = cFrame * CFrame.new(
						math.random(-1, 1) * v6,
						math.random(-1, 1) * v6,
						math.random(-1, 1) * v6
					)
				elseif v5 then
					v:FadeOut(v5, 1)
					v5 = nil
				end
			end
		end
	},
	othervents1 = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "lavaside.010" then
				return true
			end

			return false
		end,
		run = function(instance)
			local _ = instance.Color
			local cFrame = instance.CFrame
			local v5 = v:Play("BFLab_Ambience_Air_Vent_01", instance, 2, 1)
			v5.Looped = true

			while instance and instance.Parent do
				task.wait()
				v5.Volume = math.clamp((v2 - 1) * 0.1 + 0.2, 0, 2)
				v5.PlaybackSpeed = math.clamp((v2 - 1) * 0.05 + 1, 0, 3)

				if not (v2 > 2) then
					continue
				end

				local v6 = (v2 - 1) * -0.025
				instance.CFrame = cFrame * CFrame.new(
					math.random(-1, 1) * v6,
					math.random(-1, 1) * v6,
					math.random(-1, 1) * v6
				)
			end
		end
	},
	othervents2 = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "acunits.006" then
				return true
			end

			return false
		end,
		run = function(instance)
			local _ = instance.Color
			local cFrame = instance.CFrame
			local v5 = v:Play("BFLab_Ambience_Air_Vent_01", instance, 2, 1)
			v5.Looped = true

			while instance and instance.Parent do
				task.wait()
				v5.Volume = math.clamp((v2 - 1) * 0.1 + 0.2, 0, 2)
				v5.PlaybackSpeed = math.clamp((v2 - 1) * 0.05 + 1, 0, 3)

				if not (v2 > 2) then
					continue
				end

				local v6 = (v2 - 1) * -0.025
				instance.CFrame = cFrame * CFrame.new(
					math.random(-1, 1) * v6,
					math.random(-1, 1) * v6,
					math.random(-1, 1) * v6
				)
			end
		end
	},
	aircond = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "lavaside.030" and part.Color == Color3.fromRGB(202, 203, 209) then
				return true
			end

			return false
		end,
		run = function(instance)
			local _ = instance.Color
			local cFrame = instance.CFrame
			local v5 = v:Play("BFLab_Ambience_Airconditioning_01", instance, 8, 1)
			v5.Looped = true

			while instance and instance.Parent do
				task.wait()
				v5.Volume = math.clamp((v2 - 1) * 0.1 + 0.3, 0, 2)
				v5.PlaybackSpeed = math.clamp((v2 - 1) * 0.05 + 1, 0, 3)

				if not (v2 > 2) then
					continue
				end

				local v6 = (v2 - 1) * -0.025
				instance.CFrame = cFrame * CFrame.new(
					math.random(-1, 1) * v6,
					math.random(-1, 1) * v6,
					math.random(-1, 1) * v6
				)
			end
		end
	},
	skybeams = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Cube.053" and part.Color == Color3.fromRGB(127, 123, 111) then
				return true
			end

			return false
		end,
		run = function(instance)
			local _ = instance.Color
			local cFrame = instance.CFrame
			local v5 = nil

			while instance and instance.Parent do
				task.wait()

				if v2 > 2 then
					if not v5 then
						v5 = v:Play("BFLab_Metal_Rattle_01", instance, 20, 1)
						v5.Looped = true
					end

					v5.Volume = (v2 - 1) * 0.05 + 0.1
					local v6 = (v2 - 1) * -0.025
					instance.CFrame = cFrame * CFrame.new(
						math.random(-1, 1) * v6,
						math.random(-1, 1) * v6,
						math.random(-1, 1) * v6
					)
				elseif v5 then
					v:FadeOut(v5, 1)
					v5 = nil
				end
			end
		end
	},
	sidepipes = {
		match = function(part)
			if part:IsA("BasePart") and part.Name == "Meshes/leafbuildings_Cube.027" then
				return true
			end

			return false
		end,
		run = function(instance)
			local _ = instance.Color
			local cFrame = instance.CFrame
			local v5 = nil

			while instance and instance.Parent do
				task.wait()

				if v2 > 2 then
					if not v5 then
						v5 = v:Play("BFLab_Metal_Rattle_02", instance, 4, 1)
						v5.Looped = true
					end

					v5.Volume = (v2 - 1) * 0.05 + 0.1
					local v6 = (v2 - 1) * -0.015
					instance.CFrame = cFrame * CFrame.new(
						math.random(-1, 1) * v6,
						math.random(-1, 1) * v6,
						math.random(-1, 1) * v6
					)
				elseif v5 then
					v:FadeOut(v5, 1)
					v5 = nil
				end
			end
		end
	},
	["teleporter spotlights"] = {
		match = function(part)
			if part:IsA("BasePart") and part.Color == Color3.fromRGB(105, 128, 182) and part.Name == "Cube.001" then
				return true
			end

			return false
		end,
		run = function(parent)
			for i = -1, 1 do
				local child = workspace:FindFirstChild("DUNGEON_TELEPORTER" .. tostring(i), true)

				while not child do
					task.wait()
					child = workspace:FindFirstChild("DUNGEON_TELEPORTER" .. tostring(i), true)
				end

				local attachment = Instance.new("Attachment")
				attachment.Name = "Attachment"
				attachment.Axis = createVector(1, -1.0549386e-8, 0)
				attachment.CFrame = CFrame.new(-178.999, 19, 0, 1, 1.05494e-8, 0, -1.05494e-8, 1, 0, 0, 0, 1)
				attachment.CFrame *= CFrame.new(0, math.abs(i) * -50, i * 113)
				attachment.SecondaryAxis = createVector(1.0549386e-8, 1, 0)
				local spotLight = Instance.new("SpotLight")
				spotLight.Name = "SpotLight"
				spotLight.Angle = 60
				spotLight.Brightness = 0
				spotLight.Color = Color3.fromRGB(201, 255, 255)
				spotLight.Face = Enum.NormalId.Left
				spotLight.Range = 120
				spotLight.Parent = attachment
				attachment.Parent = parent
				local _ = spotLight.Brightness
				task.spawn(function()
					while parent and parent.Parent do
						local v6 = v2
						local v7 = not child:GetAttribute("PreparingToTeleport") and 1 or v6
						spotLight.Brightness = (v7 - 1) * 0.5 + 0
						spotLight.Angle = (v7 - 1) * 6 + 0
						task.wait()
					end
				end)
			end
		end
	}
}
local v3 = {
	LoadProps = function(self)
		local instance = self.Instance
		instance:GetAttributeChangedSignal("LabEnergyOutputModifier"):Connect(function()
			while v2 < math.min(instance:GetAttribute("LabEnergyOutputModifier") or 1, 10) do
				v2 += task.wait() * 2
			end

			while v2 > (instance:GetAttribute("LabEnergyOutputModifier") or 1) do
				v2 -= task.wait() * 2
			end

			v2 = math.min(instance:GetAttribute("LabEnergyOutputModifier") or 1, 10)
		end)
		v2 = math.min(instance:GetAttribute("LabEnergyOutputModifier") or 1, 10)
		self.objectDictionary = {}

		for k, v5 in pairs(v4) do
			self.objectDictionary[k] = {}

			for _, descendant in pairs(instance:GetDescendants()) do
				if not v5.match(descendant) then
					continue
				end

				table.insert(self.objectDictionary[k], descendant)
				task.defer(v5.run, descendant)
			end
		end

		task.spawn(function()
			local sound = Instance.new("Sound", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
			sound.Name = "Ambience"
			sound.SoundId = "rbxassetid://139717033545794"
			sound.Looped = true
			sound.Volume = 0.2
			sound:Play()
		end)
		task.spawn(function()
			while instance and instance.Parent do
				task.wait()

				if not (v2 > 1) then
					continue
				end

				local sound = Instance.new("Sound", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
				sound.Name = "Startup"
				sound.SoundId = "rbxassetid://131542767665614"
				sound.Volume = 0.5
				sound:Play()

				repeat
					task.wait(0.1)
				until v2 <= 1

				sound:Destroy()
			end
		end)
	end,
	Construct = function(self)
		self.maid = Maid.new()
	end,
	Start = function(self)
		local instance = self.Instance
		local CameraShake = require(game.ReplicatedStorage.Util.CameraShake)
		self:LoadProps()
		task.spawn(function()
			while instance and instance.Parent do
				local v5 = task.wait()

				if v2 > 7 then
					CameraShake:ShakeOnce((v2 - 7) * 0.01, 0.01, v5, v5, 0, 1)
				end

				game.Lighting.ClockTime = 0
				game.Lighting.Sky.SunAngularSize = 0
			end

			self.maid:Destroy()
		end)
		task.spawn(function()
			require(script.TrinketMachine)
		end)
	end,
	Stop = function(p)
		p.maid:Destroy()
	end
}
local RunService2 = game:GetService("RunService")
local result

if RunService2:IsRunning() then
	result = Component.new({
		Tag = "SimulationHubController",
		Ancestors = { workspace.Map }
	})
else
	result = {
		Tag = "SimulationHubController",
		Ancestors = { workspace:FindFirstChild("Test") },
		Instance = workspace:FindFirstChild("Test"):FindFirstChild("Simulation Hub")
	}
end

for k, v5 in pairs(v3) do
	result[k] = v5
end

return result