local createVector = vector.create
local LightningEmote = {}
local Players = game:GetService("Players")
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local _ = library.Maid
local _ = library.Able
local Threader = require(script.Threader)
local Line = require(script.Line)
local meshemit2 = require(game.ReplicatedStorage.Emotes.VFX.VfxMods.meshemit2)
local Lightning = require(script.Lightning)
local vfx = script.vfx
local class = {}
class.__index = class
Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleDestroy(instance)
	task.delay(15, function()
		if instance and instance.Parent then
			instance:Destroy()
		end
	end)
end

local function simpleEmit(folder)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			local emitCount = effect:GetAttribute("EmitCount")

			if emitCount then
				local emitDelay = effect:GetAttribute("EmitDelay")

				if emitDelay and emitDelay > 0 then
					local v = effect
					local v2 = emitCount
					task.delay(emitDelay, function()
						v:Emit(v2)
					end)
				else
					effect:Emit(emitCount)
				end
			end
		elseif effect:IsA("Trail") then
			effect.Enabled = true
		elseif effect:IsA("Beam") then
			effect.Enabled = true
		end
	end

	local emitCount = folder:IsA("ParticleEmitter") and folder:GetAttribute("EmitCount")

	if emitCount then
		local emitDelay = folder:GetAttribute("EmitDelay")

		if emitDelay and emitDelay > 0 then
			task.delay(emitDelay, function()
				folder:Emit(emitCount)
			end)
		else
			folder:Emit(emitCount)
		end
	end
end

local function emitMeshVFX(folder)
	if not folder then
		return
	end

	local function process(effect)
		if effect:IsA("ParticleEmitter") then
			local emitCount = effect:GetAttribute("EmitCount") or effect:GetAttribute("Count")
			local emitDelay = effect:GetAttribute("EmitDelay") or 0
			local emitDuration = effect:GetAttribute("EmitDuration") or effect:GetAttribute("Duration")
			task.delay(emitDelay, function()
				if not effect.Parent then
					return
				end

				if emitCount then
					effect:Emit(emitCount)
				end

				if emitDuration and emitDuration > 0 then
					effect.Enabled = true
					task.wait(emitDuration)

					if effect.Parent then
						effect.Enabled = false
					end
				end
			end)
		elseif effect:IsA("Trail") or effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay") or 0
			task.delay(emitDelay, function()
				if effect.Parent then
					effect.Enabled = true
				end
			end)
		end
	end

	process(folder)

	for _, descendant in folder:GetDescendants() do
		process(descendant)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleFX(folder, enabled)
	task.spawn(function()
		for _, effect in folder:GetDescendants() do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = enabled
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emitFX(folder)
	task.spawn(function()
		for _, descendant in folder:GetDescendants() do
			if descendant.ClassName ~= "ParticleEmitter" then
				continue
			end

			local emitCount = descendant:GetAttribute("EmitCount")

			if not emitCount then
				continue
			end

			local emitDelay = descendant:GetAttribute("EmitDelay")

			if emitDelay then
				local v = descendant
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				descendant:Emit(emitCount)
			end
		end
	end)
end

local thrown = game.Workspace.Thrown
local v = {}
local v2 = {}
local v3 = {}
local v4 = {
	Beam = {
		{
			Color = Color3.fromRGB(85, 125, 255)
		},
		{
			Color = Color3.fromRGB(222, 77, 0)
		}
	},
	Beam1 = {
		{
			Color = Color3.fromRGB(167, 167, 167)
		},
		{
			Color = Color3.fromRGB(108, 108, 108)
		}
	},
	Beam2 = {
		{
			Color = Color3.fromRGB(167, 167, 167)
		},
		{
			Color = Color3.fromRGB(108, 108, 108)
		}
	},
	Beam3 = {
		{
			Color = Color3.fromRGB(167, 167, 167)
		},
		{
			Color = Color3.fromRGB(108, 108, 108)
		}
	},
	Beam4 = {
		{
			Color = Color3.fromRGB(167, 167, 167)
		},
		{
			Color = Color3.fromRGB(108, 108, 108)
		}
	},
	DepthOfField = {
		{
			FocusDistance = 0,
			InFocusRadius = 0,
			FarIntensity = 0,
			NearIntensity = 0
		},
		{
			FocusDistance = 4.62,
			InFocusRadius = 0,
			FarIntensity = 0.461,
			NearIntensity = 1
		},
		{
			FocusDistance = 32.3,
			InFocusRadius = 0,
			FarIntensity = 0.592,
			NearIntensity = 10.269
		},
		{
			FocusDistance = 41.54,
			InFocusRadius = 0,
			FarIntensity = 0.615,
			NearIntensity = 0
		},
		{
			FocusDistance = 38.345,
			InFocusRadius = 0,
			FarIntensity = 0.568,
			NearIntensity = 0
		},
		{
			FocusDistance = 35.887,
			InFocusRadius = 0,
			FarIntensity = 0.531,
			NearIntensity = 1
		},
		{
			FocusDistance = 12.3,
			InFocusRadius = 0,
			FarIntensity = 0.455,
			NearIntensity = 0
		},
		{
			FocusDistance = 27.284,
			InFocusRadius = 0,
			FarIntensity = 0.404,
			NearIntensity = 0
		},
		{
			FocusDistance = 24.047,
			InFocusRadius = 0,
			FarIntensity = 0.356,
			NearIntensity = 0
		},
		{
			FocusDistance = 22.944,
			InFocusRadius = 22.31,
			FarIntensity = 0.3,
			NearIntensity = 1
		},
		{
			FocusDistance = 0,
			InFocusRadius = 0,
			FarIntensity = 1,
			NearIntensity = 1
		},
		{
			FocusDistance = 0,
			InFocusRadius = 0,
			FarIntensity = 0.87,
			NearIntensity = 0.87
		},
		{
			FocusDistance = 12.3,
			InFocusRadius = 1.495,
			FarIntensity = 1,
			NearIntensity = 0.671
		},
		{
			FocusDistance = 0,
			InFocusRadius = 6.54,
			FarIntensity = 1,
			NearIntensity = 0
		},
		{
			FocusDistance = 21.053,
			InFocusRadius = 5.45,
			FarIntensity = 0.745,
			NearIntensity = 0
		},
		{
			FocusDistance = 40,
			InFocusRadius = 4.469,
			FarIntensity = 1,
			NearIntensity = 0.346
		},
		{
			FocusDistance = 0,
			InFocusRadius = 7.31,
			FarIntensity = 1,
			NearIntensity = 0
		},
		{
			FocusDistance = 0,
			InFocusRadius = 0,
			FarIntensity = 0,
			NearIntensity = 0
		},
		{
			FocusDistance = 0,
			InFocusRadius = 0,
			FarIntensity = 0,
			NearIntensity = 0
		},
		{
			FocusDistance = 1,
			InFocusRadius = 1,
			FarIntensity = 1,
			NearIntensity = 1
		},
		{
			FocusDistance = 75.38,
			InFocusRadius = 20,
			FarIntensity = 1,
			NearIntensity = 1
		},
		{
			FocusDistance = 4.62,
			InFocusRadius = 0,
			FarIntensity = 0.746,
			NearIntensity = 1
		},
		{
			FocusDistance = 0,
			InFocusRadius = 13.845,
			FarIntensity = 0.554,
			NearIntensity = 1
		},
		{
			FocusDistance = 24.62,
			InFocusRadius = 0,
			FarIntensity = 0.323,
			NearIntensity = 1
		},
		{
			FocusDistance = 70.76,
			InFocusRadius = 13.845,
			FarIntensity = 1,
			NearIntensity = 1
		},
		{
			FocusDistance = 0,
			InFocusRadius = 5.77,
			FarIntensity = 0.592,
			NearIntensity = 1
		},
		{
			FocusDistance = 0,
			InFocusRadius = 5.77,
			FarIntensity = 0.592,
			NearIntensity = 1
		},
		{
			FocusDistance = 0,
			InFocusRadius = 0,
			FarIntensity = 0,
			NearIntensity = 0
		}
	},
	ColorSkill = {
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		},
		{
			TintColor = Color3.fromRGB(255, 123, 123),
			Brightness = 0.1,
			Contrast = 0.4,
			Saturation = 0.2
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = -0.1,
			Contrast = 0.322,
			Saturation = 0
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0.2,
			Saturation = 0.3
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0.2,
			Saturation = 0.3
		},
		{
			TintColor = Color3.fromRGB(157, 199, 255),
			Brightness = 0.1,
			Contrast = 0.4,
			Saturation = 0.2
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0.1,
			Contrast = 0.2,
			Saturation = 0.7
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0.062,
			Contrast = 0.2,
			Saturation = 0.546
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0.5,
			Contrast = 0.45,
			Saturation = 0.544
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0.062,
			Contrast = 0.2,
			Saturation = 0.546
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0.2,
			Saturation = 0.3
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		}
	},
	Lighting = {
		{
			EnvironmentDiffuseScale = 0,
			EnvironmentSpecularScale = 0
		},
		{
			EnvironmentDiffuseScale = 1,
			EnvironmentSpecularScale = 1
		},
		{
			EnvironmentDiffuseScale = 1,
			EnvironmentSpecularScale = 1
		},
		{
			EnvironmentDiffuseScale = 0,
			EnvironmentSpecularScale = 0
		}
	},
	Bloom = {
		{
			Intensity = 1,
			Size = 24,
			Threshold = 2
		},
		{
			Intensity = 5,
			Size = 56,
			Threshold = 1.2
		},
		{
			Intensity = 5,
			Size = 56,
			Threshold = 1.2
		},
		{
			Intensity = 1,
			Size = 24,
			Threshold = 2
		},
		{
			Intensity = 1,
			Size = 24,
			Threshold = 2
		}
	},
	Atmosphere = {
		{
			Color = Color3.fromRGB(255, 255, 255),
			Density = 0.3,
			Haze = 0,
			Decay = Color3.fromRGB(255, 255, 255)
		},
		{
			Color = Color3.fromRGB(0, 0, 0),
			Density = 0.3,
			Haze = 15,
			Decay = Color3.fromRGB(0, 0, 0)
		},
		{
			Color = Color3.fromRGB(0, 0, 0),
			Density = 0.3,
			Haze = 10,
			Decay = Color3.fromRGB(0, 0, 0)
		},
		{
			Color = Color3.fromRGB(255, 255, 255),
			Density = 0.3,
			Haze = 0,
			Decay = Color3.fromRGB(255, 255, 255)
		}
	},
	Highlight = {
		{
			FillTransparency = 1
		},
		{
			FillTransparency = 0
		},
		{
			FillTransparency = 0
		},
		{
			FillTransparency = 1
		}
	},
	Highlight2 = {
		{
			FillTransparency = 1
		},
		{
			FillTransparency = 0
		},
		{
			FillTransparency = 0
		},
		{
			FillTransparency = 1
		}
	}
}
local v5 = {
	Beam = { TweenInfo.new(8.95, Enum.EasingStyle.Linear), TweenInfo.new(9.65, Enum.EasingStyle.Linear) },
	Beam1 = { TweenInfo.new(8.95, Enum.EasingStyle.Linear), TweenInfo.new(9.65, Enum.EasingStyle.Linear) },
	Beam2 = { TweenInfo.new(8.95, Enum.EasingStyle.Linear), TweenInfo.new(9.65, Enum.EasingStyle.Linear) },
	Beam3 = { TweenInfo.new(8.95, Enum.EasingStyle.Linear), TweenInfo.new(9.65, Enum.EasingStyle.Linear) },
	Beam4 = { TweenInfo.new(8.95, Enum.EasingStyle.Linear), TweenInfo.new(9.65, Enum.EasingStyle.Linear) },
	DepthOfField = {
		TweenInfo.new(0.533, Enum.EasingStyle.Linear),
		TweenInfo.new(0.75, Enum.EasingStyle.Linear),
		TweenInfo.new(0.917, Enum.EasingStyle.Linear),
		TweenInfo.new(1.35, Enum.EasingStyle.Linear),
		TweenInfo.new(1.567, Enum.EasingStyle.Linear),
		TweenInfo.new(1.733, Enum.EasingStyle.Linear),
		TweenInfo.new(1.817, Enum.EasingStyle.Linear),
		TweenInfo.new(2.2, Enum.EasingStyle.Linear),
		TweenInfo.new(2.35, Enum.EasingStyle.Linear),
		TweenInfo.new(2.383, Enum.EasingStyle.Linear),
		TweenInfo.new(2.5, Enum.EasingStyle.Linear),
		TweenInfo.new(2.717, Enum.EasingStyle.Linear),
		TweenInfo.new(2.85, Enum.EasingStyle.Linear),
		TweenInfo.new(3.167, Enum.EasingStyle.Linear),
		TweenInfo.new(3.333, Enum.EasingStyle.Linear),
		TweenInfo.new(3.483, Enum.EasingStyle.Linear),
		TweenInfo.new(3.717, Enum.EasingStyle.Linear),
		TweenInfo.new(3.933, Enum.EasingStyle.Linear),
		TweenInfo.new(4.083, Enum.EasingStyle.Linear),
		TweenInfo.new(4.167, Enum.EasingStyle.Linear),
		TweenInfo.new(4.783, Enum.EasingStyle.Linear),
		TweenInfo.new(5.417, Enum.EasingStyle.Linear),
		TweenInfo.new(5.85, Enum.EasingStyle.Linear),
		TweenInfo.new(6.583, Enum.EasingStyle.Linear),
		TweenInfo.new(7.05, Enum.EasingStyle.Linear),
		TweenInfo.new(7.533, Enum.EasingStyle.Linear),
		TweenInfo.new(8.233, Enum.EasingStyle.Linear),
		TweenInfo.new(8.267, Enum.EasingStyle.Linear)
	},
	ColorSkill = {
		TweenInfo.new(1.567, Enum.EasingStyle.Linear),
		TweenInfo.new(1.617, Enum.EasingStyle.Linear),
		TweenInfo.new(2.117, Enum.EasingStyle.Linear),
		TweenInfo.new(4.167, Enum.EasingStyle.Linear),
		TweenInfo.new(4.45, Enum.EasingStyle.Linear),
		TweenInfo.new(6.617, Enum.EasingStyle.Linear),
		TweenInfo.new(6.717, Enum.EasingStyle.Linear),
		TweenInfo.new(7.217, Enum.EasingStyle.Linear),
		TweenInfo.new(8.25, Enum.EasingStyle.Linear),
		TweenInfo.new(8.267, Enum.EasingStyle.Linear),
		TweenInfo.new(8.533, Enum.EasingStyle.Linear),
		TweenInfo.new(9.95, Enum.EasingStyle.Linear),
		TweenInfo.new(9.983, Enum.EasingStyle.Linear)
	},
	Lighting = {
		TweenInfo.new(4.433, Enum.EasingStyle.Linear),
		TweenInfo.new(5.017, Enum.EasingStyle.Linear),
		TweenInfo.new(9.767, Enum.EasingStyle.Linear),
		TweenInfo.new(9.983, Enum.EasingStyle.Linear)
	},
	Bloom = {
		TweenInfo.new(3.117, Enum.EasingStyle.Linear),
		TweenInfo.new(3.417, Enum.EasingStyle.Linear),
		TweenInfo.new(4.167, Enum.EasingStyle.Linear),
		TweenInfo.new(4.633, Enum.EasingStyle.Linear),
		TweenInfo.new(8.35, Enum.EasingStyle.Linear)
	},
	Atmosphere = {
		TweenInfo.new(4.133, Enum.EasingStyle.Linear),
		TweenInfo.new(4.233, Enum.EasingStyle.Linear),
		TweenInfo.new(9.783, Enum.EasingStyle.Linear),
		TweenInfo.new(9.983, Enum.EasingStyle.Linear)
	},
	Highlight = {
		TweenInfo.new(8.25, Enum.EasingStyle.Linear),
		TweenInfo.new(8.267, Enum.EasingStyle.Linear),
		TweenInfo.new(9.467, Enum.EasingStyle.Linear),
		TweenInfo.new(9.533, Enum.EasingStyle.Linear)
	},
	Highlight2 = {
		TweenInfo.new(8.25, Enum.EasingStyle.Linear),
		TweenInfo.new(8.267, Enum.EasingStyle.Linear),
		TweenInfo.new(9.467, Enum.EasingStyle.Linear),
		TweenInfo.new(9.533, Enum.EasingStyle.Linear)
	}
}
local CreateTweenLoop

CreateTweenLoop = function(p, p2, value)
	if not v2[p2] then
		v2[p2] = 1
	end

	local v6 = value or 0
	local v7 = v2[p2]
	local v8 = v4[p2] and v4[p2][v7]
	local v9 = v5[p2] and v5[p2][v7]

	if v9 and v8 then
		if v[p2] then
			v[p2]:Disconnect()
		end

		local time = v9.Time
		local v10 = math.max(0, time - v6)
		local tween = TweenService:Create(
			p,
			TweenInfo.new(v10, v9.EasingStyle, v9.EasingDirection or Enum.EasingDirection.In),
			v8
		)
		tween:Play()
		v[p2] = tween.Completed:Connect(function()
			v[p2]:Disconnect()
			v[p2] = nil
			v2[p2] = v7 + 1

			if v2[p2] > #v4[p2] then
				v2[p2] = 1
				v3[p2] = false
			end

			if v3[p2] then
				CreateTweenLoop(p, p2, time)
			end
		end)
	else
		v2[p2] = 1
		v3[p2] = false

		if v[p2] then
			v[p2]:Disconnect()
			v[p2] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartTweenLoop(p, p2)
	if v[p2] then
		v[p2]:Disconnect()
		v[p2] = nil
	end

	v3[p2] = true
	v2[p2] = 1
	CreateTweenLoop(p, p2, 0)
end

local function isLocalCharacter(p)
	local localPlayer = Players.LocalPlayer
	return localPlayer and localPlayer.Character == p
end

local v6 = {
	{
		Time = 0,
		Fn = function(player)
			if not player.IsCutscene then
				return
			end

			local kakashicamrig = player.Character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				toggleFX(kakashicamrig.CamPart.Beams.M1, true) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 1.633,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local clone = vfx.SharingunFx:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = thrown
			emitFX(clone) -- equivalent call inferred; original call site unknown
			local clone2 = vfx.HeadFx:Clone()
			scheduleDestroy(clone2) -- equivalent call inferred; original call site unknown
			game.Debris:AddItem(clone2, 4)
			clone2.Anchored = false
			clone2.Massless = true
			clone2.CanCollide = false
			clone2.Parent = workspace.Thrown
			clone2.Transparency = 1
			clone2.HeadFx.Part0 = character.Head
			clone2.HeadFx.Part1 = clone2
			emitFX(clone2.EyesFx) -- equivalent call inferred; original call site unknown
		end
	},
	{
		Time = 2.283,
		Fn = function(player)
			if not player.IsCutscene then
				return
			end

			local kakashicamrig = player.Character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				toggleFX(kakashicamrig.TransitionFx, true) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 3.217,
		Threaded = true,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local kakashicamrig = player.IsCutscene and character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				toggleFX(kakashicamrig.CamPart.Beams.M2, true) -- equivalent call inferred; original call site unknown
				toggleFX(kakashicamrig.TransitionFx, false) -- equivalent call inferred; original call site unknown
			end

			task.wait(0.01)
			task.spawn(Line, 55, humanoidRootPart.CFrame * CFrame.new(0.702, 1.4450000000000003, 0))
			local clone = vfx.WarpFx:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
				-0.782726765,
				1.18564892,
				-0.32432121,
				1,
				0,
				0,
				0,
				1,
				0,
				0,
				0,
				1
			)
			clone.Name = character.Name .. "sumchillaxWarpOk"
			clone.Parent = thrown
			toggleFX(clone, true) -- equivalent call inferred; original call site unknown

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v8 = emitter
				delay(emitter:GetAttribute("EmitDelay"), function()
					v8:Emit(v8:GetAttribute("EmitCount"))
				end)
			end

			local clone2 = vfx.Mesh.Flipbook1.Wave:Clone()
			scheduleDestroy(clone2) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone2)
			clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(
				-0.396772504,
				-3.21936464,
				0.418985367,
				0,
				1,
				0,
				1,
				0,
				0,
				0,
				0,
				-1
			))
			clone2.Parent = thrown
			emitMeshVFX(clone2)
		end
	},
	{
		Time = 3.267,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local clone = vfx.Mesh.warpmeshes:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			Debris:AddItem(clone, 15)
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Name = character.Name .. "warprwaprwarpMeshess"
			clone.Parent = thrown

			for _, model in clone:GetChildren() do
				if model:IsA("Model") then
					task.spawn(meshemit2, model)
				end
			end

			local clone2 = vfx.Trail:Clone()
			scheduleDestroy(clone2) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone2)
			Debris:AddItem(clone2, 15)
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(
				0,
				-3.13946939,
				0,
				1.91068547e-15,
				4.37113883e-8,
				1,
				1,
				-4.37113883e-8,
				0,
				4.37113883e-8,
				1,
				-4.37113883e-8
			)
			clone2.Name = character.Name .. "trailtrailtail"
			clone2.Parent = thrown
			emitMeshVFX(clone2)
		end
	},
	{
		Time = 3.35,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local clone = vfx.Mesh.glassmeshes:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			Debris:AddItem(clone, 15)
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Name = character.Name .. "glassmesheshaha"
			clone.Parent = thrown
			emitMeshVFX(clone)
		end
	},
	{
		Time = 3.433,
		Threaded = true,
		Fn = function(player)
			local character = player.Character
			local child = thrown:FindFirstChild(character.Name .. "warprwaprwarpMeshess")

			if child then
				for _, model in child:GetChildren() do
					if model:IsA("Model") then
						task.spawn(meshemit2, model)
					end
				end
			end

			local child2 = thrown:FindFirstChild(character.Name .. "glassmesheshaha")

			if child2 then
				emitMeshVFX(child2)
			end

			local child3 = thrown:FindFirstChild(character.Name .. "trailtrailtail")

			if child3 then
				emitMeshVFX(child3)
			end
		end
	},
	{
		Time = 3.55,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "glassmesheshaha")

			if child then
				emitMeshVFX(child)
			end
		end
	},
	{
		Time = 3.667,
		Fn = function(player)
			local character = player.Character
			local child = thrown:FindFirstChild(character.Name .. "warprwaprwarpMeshess")

			if child then
				for _, model in child:GetChildren() do
					if model:IsA("Model") then
						task.spawn(meshemit2, model)
					end
				end
			end

			local child2 = thrown:FindFirstChild(character.Name .. "glassmesheshaha")

			if child2 then
				emitMeshVFX(child2)
			end

			local child3 = thrown:FindFirstChild(character.Name .. "trailtrailtail")

			if child3 then
				emitMeshVFX(child3)
			end
		end
	},
	{
		Time = 3.767,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "glassmesheshaha")

			if child then
				emitMeshVFX(child)
			end
		end
	},
	{
		Time = 3.883,
		Fn = function(player)
			local character = player.Character
			local child = thrown:FindFirstChild(character.Name .. "warprwaprwarpMeshess")

			if child then
				for _, model in child:GetChildren() do
					if model:IsA("Model") then
						task.spawn(meshemit2, model)
					end
				end
			end

			local child2 = thrown:FindFirstChild(character.Name .. "glassmesheshaha")

			if child2 then
				emitMeshVFX(child2)
			end

			local child3 = thrown:FindFirstChild(character.Name .. "sumchillaxWarpOk")

			if child3 then
				toggleFX(child3, false) -- equivalent call inferred; original call site unknown
			end

			local child4 = thrown:FindFirstChild(character.Name .. "trailtrailtail")

			if child4 then
				emitMeshVFX(child4)
			end
		end
	},
	{
		Time = 4.167,
		Fn = function(player)
			if not player.IsCutscene then
				return
			end

			local kakashicamrig = player.Character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				toggleFX(kakashicamrig.CamPart.Beams.M2, false) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 4.217,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup

			if player.IsCutscene then
				local clone = vfx.Map:Clone()
				scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
				clone.Name = "_KamuiMap"
				task.spawn(cleanup, clone)
				clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 16.893, 0))
				clone.Name = character.Name .. " kamuiMapp"
				clone.Parent = thrown
			end

			local clone = vfx.LinesFx:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
				-1.0803566,
				57.1100273,
				9.02706432,
				1,
				0,
				0,
				0,
				1,
				0,
				0,
				0,
				1
			)
			clone.Name = character.Name .. "linesFXlinesFXff"
			clone.Parent = thrown
			toggleFX(clone, true) -- equivalent call inferred; original call site unknown
		end
	},
	{
		Time = 4.983,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "linesFXlinesFXff")

			if child then
				toggleFX(child, false) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 5.483,
		Fn = function(player)
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local clone = vfx.SmokeFx:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
				-0.699073195,
				-2.92538452,
				9.51296711,
				1,
				0,
				0,
				0,
				1,
				0,
				0,
				0,
				1
			)
			clone.Parent = thrown
			emitFX(clone) -- equivalent call inferred; original call site unknown
		end
	},
	{
		Time = 6.817,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local clone = vfx.Warp2Fx:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
				0.149822712,
				7.29647064,
				62.0304985,
				1,
				0,
				0,
				0,
				1,
				0,
				0,
				0,
				1
			)
			clone.Name = character.Name .. "warp2fxfxxOkHaha"
			clone.Parent = thrown
			emitFX(clone) -- equivalent call inferred; original call site unknown
			toggleFX(clone, true) -- equivalent call inferred; original call site unknown
			local clone2 = vfx.Mesh.warpmeshes2:Clone()
			scheduleDestroy(clone2) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone2)
			clone2:PivotTo(humanoidRootPart.CFrame)
			clone2.Name = character.Name .. "warpmeshes2hah hxhxMeshes"
			clone2.Parent = thrown

			for _, model in clone2:GetChildren() do
				if model:IsA("Model") then
					task.spawn(meshemit2, model)
				end
			end

			local clone3 = vfx.Mesh.Flipbook2.Wave:Clone()
			scheduleDestroy(clone3) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone3)
			clone3:PivotTo(humanoidRootPart.CFrame * CFrame.new(
				-1.50992179,
				-3.21936464,
				54.6563644,
				0,
				1,
				0,
				1,
				0,
				0,
				0,
				0,
				-1
			))
			clone3.Parent = thrown
			emitMeshVFX(clone3)
			local clone4 = vfx.Trail1:Clone()
			scheduleDestroy(clone4) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone4)
			clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(
				2.22846916e-6,
				4.18277025,
				50.9814301,
				0,
				0,
				1,
				1,
				0,
				0,
				0,
				1,
				0
			)
			clone4.Name = character.Name .. "trailfx2 de stuff ok"
			clone4.Parent = thrown
			emitMeshVFX(clone4)
		end
	},
	{
		Time = 6.967,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local leftArm = character:FindFirstChild("Left Arm")
			local cleanup = player.Cleanup
			local child = thrown:FindFirstChild(character.Name .. "warpmeshes2hah hxhxMeshes")

			if child then
				for _, model in child:GetChildren() do
					if model:IsA("Model") then
						task.spawn(meshemit2, model)
					end
				end
			end

			local clone = vfx.ChidoriFx:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			local motor6D = Instance.new("Motor6D")
			scheduleDestroy(motor6D) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, motor6D)
			motor6D.Part0 = leftArm
			motor6D.Part1 = clone
			motor6D.C0 = CFrame.new(-0.0213961601, -1.43670702, -0.0331273675, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			motor6D.Name = "ChidoriFx"
			motor6D.Parent = leftArm
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(
				-1.88477683,
				-1.01096177,
				-0.430608094,
				0.606090844,
				0.509835899,
				-0.610509157,
				-0.727081656,
				0.666339576,
				-0.165359929,
				0.32249999,
				0.544113159,
				0.77455467
			)
			clone.Name = character.Name .. "chidoriFX ok"
			clone.Parent = thrown
			toggleFX(clone.E1, true) -- equivalent call inferred; original call site unknown
			local child2 = thrown:FindFirstChild(character.Name .. "trailfx2 de stuff ok")

			if child2 then
				emitMeshVFX(child2)
			end
		end
	},
	{
		Time = 7.033,
		Fn = function(player)
			if not player.IsCutscene then
				return
			end

			local kakashicamrig = player.Character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				toggleFX(kakashicamrig.TransitionFx, true) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 7.117,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local child = thrown:FindFirstChild(character.Name .. "warp2fxfxxOkHaha")

			if child then
				toggleFX(child, false) -- equivalent call inferred; original call site unknown
			end

			local child2 = thrown:FindFirstChild(character.Name .. "warpmeshes2hah hxhxMeshes")

			if child2 then
				for _, model in child2:GetChildren() do
					if model:IsA("Model") then
						task.spawn(meshemit2, model)
					end
				end
			end

			local child3 = thrown:FindFirstChild(character.Name .. "trailfx2 de stuff ok")

			if child3 then
				emitMeshVFX(child3)
			end

			local cFrame = humanoidRootPart.CFrame
			local v7 = cFrame * CFrame.new(1.50289488, -2.41647863, 44.8987885, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local v8 = cFrame * CFrame.new(1.50289488, -2.41647863, -17.1711807, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local cFrameValue = Instance.new("CFrameValue")
			scheduleDestroy(cFrameValue) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, cFrameValue)
			cFrameValue.Value = v7
			cFrameValue.Name = character.Name .. "thinggbrooo"
			cFrameValue.Parent = thrown
			TweenService:Create(cFrameValue, TweenInfo.new(0.966, Enum.EasingStyle.Linear), {
				Value = v8
			}):Play()
		end
	},
	{
		Time = 7.15,
		Fn = function(player)
			if not player.IsCutscene then
				return
			end

			local kakashicamrig = player.Character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				toggleFX(kakashicamrig.CamPart.Beams.M3, true) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 7.183,
		Fn = function(player)
			local character = player.Character
			local cFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local v7 = cFrame * CFrame.new(
				-1.88477683,
				-1.01096177,
				-0.430608094,
				0.606090844,
				0.509835899,
				-0.610509157,
				-0.727081656,
				0.666339576,
				-0.165359929,
				0.32249999,
				0.544113159,
				0.77455467
			)
			local v8 = cFrame * CFrame.new(1.50289488, -2.41647863, 44.8987885, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local child = thrown:FindFirstChild(character.Name .. "thinggbrooo")
			local random = Random.new(3.141592653589793)

			for _, v9 in {
				beam = {
					rate = 2,
					offset = 5,
					config = {
						mode = "beam",
						segments = 6,
						offset = 9,
						dur = 0.15,
						animate_dur = 0.1,
						move_dur = 0.1,
						size = 1.5,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(73, 128, 255),
						end_color = Color3.fromRGB(99, 195, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 3
					}
				},
				part = {
					rate = 2,
					offset = 20,
					config = {
						mode = "part",
						segments = 4,
						offset = 1,
						dur = 0.1,
						size = 0.4,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(74, 128, 255),
						end_color = Color3.fromRGB(97, 179, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 4
					}
				}
			} do
				for _ = 1, v9.rate do
					local position = v7.Position
					local end_pos = (child and child.Value.Position or v8.Position) + Vector3.new(
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset)
					)
					v9.config.start_pos = position
					v9.config.end_pos = end_pos
					task.spawn(Lightning, v9.config)
				end
			end
		end
	},
	{
		Time = 7.267,
		Fn = function(player)
			local character = player.Character
			local cFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local v7 = cFrame * CFrame.new(
				-1.88477683,
				-1.01096177,
				-0.430608094,
				0.606090844,
				0.509835899,
				-0.610509157,
				-0.727081656,
				0.666339576,
				-0.165359929,
				0.32249999,
				0.544113159,
				0.77455467
			)
			local v8 = cFrame * CFrame.new(1.50289488, -2.41647863, 44.8987885, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local child = thrown:FindFirstChild(character.Name .. "thinggbrooo")
			local random = Random.new(3.141592653589793)

			for _, v9 in {
				beam = {
					rate = 2,
					offset = 5,
					config = {
						mode = "beam",
						segments = 6,
						offset = 9,
						dur = 0.15,
						animate_dur = 0.1,
						move_dur = 0.1,
						size = 1.5,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(73, 128, 255),
						end_color = Color3.fromRGB(99, 195, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 3
					}
				},
				part = {
					rate = 2,
					offset = 20,
					config = {
						mode = "part",
						segments = 4,
						offset = 1,
						dur = 0.1,
						size = 0.4,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(74, 128, 255),
						end_color = Color3.fromRGB(97, 179, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 4
					}
				}
			} do
				for _ = 1, v9.rate do
					local position = v7.Position
					local end_pos = (child and child.Value.Position or v8.Position) + Vector3.new(
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset)
					)
					v9.config.start_pos = position
					v9.config.end_pos = end_pos
					task.spawn(Lightning, v9.config)
				end
			end
		end
	},
	{
		Time = 7.417,
		Fn = function(player)
			local character = player.Character
			local cFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local v7 = cFrame * CFrame.new(
				-1.88477683,
				-1.01096177,
				-0.430608094,
				0.606090844,
				0.509835899,
				-0.610509157,
				-0.727081656,
				0.666339576,
				-0.165359929,
				0.32249999,
				0.544113159,
				0.77455467
			)
			local v8 = cFrame * CFrame.new(1.50289488, -2.41647863, 44.8987885, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local child = thrown:FindFirstChild(character.Name .. "thinggbrooo")
			local random = Random.new(3.141592653589793)

			for _, v9 in {
				beam = {
					rate = 2,
					offset = 5,
					config = {
						mode = "beam",
						segments = 6,
						offset = 9,
						dur = 0.15,
						animate_dur = 0.1,
						move_dur = 0.1,
						size = 1.5,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(73, 128, 255),
						end_color = Color3.fromRGB(99, 195, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 3
					}
				},
				part = {
					rate = 2,
					offset = 20,
					config = {
						mode = "part",
						segments = 4,
						offset = 1,
						dur = 0.1,
						size = 0.4,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(74, 128, 255),
						end_color = Color3.fromRGB(97, 179, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 4
					}
				}
			} do
				for _ = 1, v9.rate do
					local position = v7.Position
					local end_pos = (child and child.Value.Position or v8.Position) + Vector3.new(
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset)
					)
					v9.config.start_pos = position
					v9.config.end_pos = end_pos
					task.spawn(Lightning, v9.config)
				end
			end
		end
	},
	{
		Time = 7.483,
		Fn = function(player)
			if not player.IsCutscene then
				return
			end

			local kakashicamrig = player.Character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				toggleFX(kakashicamrig.TransitionFx, false) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 7.6,
		Fn = function(player)
			local character = player.Character
			local cFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local v7 = cFrame * CFrame.new(
				-1.88477683,
				-1.01096177,
				-0.430608094,
				0.606090844,
				0.509835899,
				-0.610509157,
				-0.727081656,
				0.666339576,
				-0.165359929,
				0.32249999,
				0.544113159,
				0.77455467
			)
			local v8 = cFrame * CFrame.new(1.50289488, -2.41647863, 44.8987885, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local child = thrown:FindFirstChild(character.Name .. "thinggbrooo")
			local random = Random.new(3.141592653589793)

			for _, v9 in {
				beam = {
					rate = 2,
					offset = 5,
					config = {
						mode = "beam",
						segments = 6,
						offset = 9,
						dur = 0.15,
						animate_dur = 0.1,
						move_dur = 0.1,
						size = 1.5,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(73, 128, 255),
						end_color = Color3.fromRGB(99, 195, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 3
					}
				},
				part = {
					rate = 2,
					offset = 20,
					config = {
						mode = "part",
						segments = 4,
						offset = 1,
						dur = 0.1,
						size = 0.4,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(74, 128, 255),
						end_color = Color3.fromRGB(97, 179, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 4
					}
				}
			} do
				for _ = 1, v9.rate do
					local position = v7.Position
					local end_pos = (child and child.Value.Position or v8.Position) + Vector3.new(
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset)
					)
					v9.config.start_pos = position
					v9.config.end_pos = end_pos
					task.spawn(Lightning, v9.config)
				end
			end
		end
	},
	{
		Time = 7.733,
		Fn = function(player)
			local character = player.Character
			local cFrame = character:FindFirstChild("HumanoidRootPart").CFrame
			local v7 = cFrame * CFrame.new(
				-1.88477683,
				-1.01096177,
				-0.430608094,
				0.606090844,
				0.509835899,
				-0.610509157,
				-0.727081656,
				0.666339576,
				-0.165359929,
				0.32249999,
				0.544113159,
				0.77455467
			)
			local v8 = cFrame * CFrame.new(1.50289488, -2.41647863, 44.8987885, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local child = thrown:FindFirstChild(character.Name .. "thinggbrooo")
			local random = Random.new(3.141592653589793)

			for _, v9 in {
				beam = {
					rate = 2,
					offset = 5,
					config = {
						mode = "beam",
						segments = 6,
						offset = 9,
						dur = 0.15,
						animate_dur = 0.1,
						move_dur = 0.1,
						size = 1.5,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(73, 128, 255),
						end_color = Color3.fromRGB(99, 195, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 3
					}
				},
				part = {
					rate = 2,
					offset = 20,
					config = {
						mode = "part",
						segments = 4,
						offset = 1,
						dur = 0.1,
						size = 0.4,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(74, 128, 255),
						end_color = Color3.fromRGB(97, 179, 255),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 1,
						ground_chance = 5,
						move_offset = 4
					}
				}
			} do
				for _ = 1, v9.rate do
					local position = v7.Position
					local end_pos = (child and child.Value.Position or v8.Position) + Vector3.new(
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset)
					)
					v9.config.start_pos = position
					v9.config.end_pos = end_pos
					task.spawn(Lightning, v9.config)
				end
			end
		end
	},
	{
		Time = 8.1,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "chidoriFX ok")

			if child then
				toggleFX(child.E1, false) -- equivalent call inferred; original call site unknown
				toggleFX(child.E2, true) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 8.267,
		Fn = function(player)
			local character = player.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local cleanup = player.Cleanup
			local cFrame = humanoidRootPart.CFrame

			if player.IsCutscene then
				local kakashicamrig = character:FindFirstChild("kakashicamrig")

				if kakashicamrig then
					toggleFX(kakashicamrig.CamPart.Beams.M1, false) -- equivalent call inferred; original call site unknown
					toggleFX(kakashicamrig.CamPart.Beams.M3, false) -- equivalent call inferred; original call site unknown
				end

				local child = thrown:FindFirstChild(character.Name .. " kamuiMapp")

				if child then
					child:Destroy()
				end
			end

			local v7 = cFrame * CFrame.new(-0.732626677, -0.106523991, 6.56621838, 0, 0, 1, 0, 1, 0, -1, 0, 0)
			local v8 = cFrame * CFrame.new(-0.732626677, -1.48713553, 24.2341232, 0, 0, 1, 0, 1, 0, -1, 0, 0)
			local child = thrown:FindFirstChild(character.Name .. "thinggbrooo")
			local random = Random.new(3.141592653589793)
			local clone = vfx.ChidoriScene:Clone()
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone)
			clone:PivotTo(cFrame * CFrame.new(-4.18795443, -0.137094021, 9.28022099, -1, 0, 0, 0, 1, 0, 0, 0, -1))
			clone.Scene.Transparency = player.IsCutscene and 0 or 1
			clone.Name = character.Name .. "chidorisceneHahdhh"
			clone.Parent = thrown

			if player.IsCutscene then
				toggleFX(clone, true) -- equivalent call inferred; original call site unknown
			end

			local clone2 = vfx.HitFx:Clone()
			scheduleDestroy(clone2) -- equivalent call inferred; original call site unknown
			task.spawn(cleanup, clone2)
			clone2.CFrame = cFrame * CFrame.new(-0.340300083, -0.607505322, 8.54798794, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			clone2.Parent = thrown
			emitFX(clone2) -- equivalent call inferred; original call site unknown
			emitMeshVFX(clone2.Enable)

			for _, v9 in {
				beam = {
					rate = 3,
					offset = 20,
					config = {
						mode = "beam",
						segments = 4,
						offset = 1,
						dur = 1,
						animate_dur = 0.3,
						move_dur = 0.1,
						size = 1,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(0, 0, 0),
						end_color = Color3.fromRGB(0, 0, 0),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 0,
						ground_chance = 0,
						move_offset = 3
					}
				},
				part = {
					rate = 6,
					offset = 20,
					config = {
						mode = "part",
						segments = 4,
						offset = 1,
						dur = 0.1,
						size = 1,
						material = Enum.Material.Neon,
						start_color = Color3.fromRGB(0, 0, 0),
						end_color = Color3.fromRGB(0, 0, 0),
						outline_color = Color3.fromRGB(0, 0, 0),
						outline_transparency = 0,
						ground_chance = 0,
						move_offset = 4
					}
				}
			} do
				for _ = 1, v9.rate do
					local position = v7.Position
					local end_pos = (child and child.Value.Position or v8.Position) + Vector3.new(
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset),
						random:NextNumber(-v9.offset, v9.offset)
					)
					v9.config.start_pos = position
					v9.config.end_pos = end_pos
					task.spawn(Lightning, v9.config)
				end
			end
		end
	},
	{
		Time = 8.533,
		Fn = function(player)
			local character = player.Character
			local child = thrown:FindFirstChild(character.Name .. "chidorisceneHahdhh")

			if child then
				emitFX(child.Scene.KanjiEmit.E1) -- equivalent call inferred; original call site unknown
			end

			local child2 = thrown:FindFirstChild(character.Name .. "chidoriFX ok")

			if child2 then
				toggleFX(child2.E2, false) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 8.883,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "chidorisceneHahdhh")

			if child then
				emitFX(child.Scene.KanjiEmit.E2) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 9.067,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "chidorisceneHahdhh")

			if child then
				child.Scene.Color = Color3.fromRGB(65, 68, 79)
				TweenService:Create(child.Scene, TweenInfo.new(0.45, Enum.EasingStyle.Linear), {
					Color = Color3.fromRGB(79, 61, 61)
				}):Play()
			end
		end
	},
	{
		Time = 9.333,
		Fn = function(player)
			if not player.IsCutscene then
				return
			end

			local kakashicamrig = player.Character:FindFirstChild("kakashicamrig")

			if kakashicamrig then
				emitFX(kakashicamrig.CamPart.Fx.M4) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 9.85,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "chidorisceneHahdhh")

			if child then
				toggleFX(child, false) -- equivalent call inferred; original call site unknown
			end
		end
	},
	{
		Time = 9.9,
		Fn = function(player)
			local child = thrown:FindFirstChild(player.Character.Name .. "chidorisceneHahdhh")

			if child then
				child.Scene.Transparency = 1
			end
		end
	}
}

function LightningEmote.FirstEvent(data)
	local char = data.Char
	local targChar = data.targChar
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local isCutscene = character == char or character == targChar
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind
	char:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	local v8 = false
	local parentChangedConnection = nil
	local heartbeatConnection = nil
	local v9 = false
	local transparenciesByPart = {}

	local function cleanup()
		if not v9 then
			v9 = true

			if parentChangedConnection then
				parentChangedConnection:Disconnect()
				parentChangedConnection = nil
			end

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			if isCutscene then
				for k, connection in v do
					if not connection then
						continue
					end

					connection:Disconnect()
					v[k] = nil
				end

				table.clear(v3)
				table.clear(v2)

				for k, transparency in pairs(transparenciesByPart) do
					if k and k.Parent then
						k.Transparency = transparency
					end
				end

				table.clear(transparenciesByPart)
				local _ = Color3.fromRGB
				shared.originallighting({
					time = 0.5
				})
			end
		end
	end

	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if not (bind and bind.Parent) then
			v8 = true
			cleanup()
		end
	end)
	task.delay(15, function()
		cleanup()

		if cleanupTable then
			for _, v10 in cleanupTable do
				if not (typeof(v10) == "Instance" and v10.Parent) then
					continue
				end

				local v11 = v10
				pcall(function()
					v11:Destroy()
				end)
			end
		end

		for k, v10 in v do
			if v10 then
				local connection = v10
				pcall(function()
					connection:Disconnect()
				end)
			end

			v[k] = nil
		end

		table.clear(v3)
		table.clear(v2)
	end)
	local v10

	if v8 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v8 = true
		v10 = false
	else
		v10 = true
	end

	if not v10 then
		return
	end

	local function FirstEvent()
		local function fn(p)
			game.Debris:AddItem(p, 20)
			table.insert(cleanupTable, p)
		end

		if isCutscene then
			local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
			scheduleDestroy(depthOfFieldEffect) -- equivalent call inferred; original call site unknown
			task.spawn(fn, depthOfFieldEffect)
			depthOfFieldEffect.Parent = Lighting
			v3.DepthOfField = true
			StartTweenLoop(depthOfFieldEffect, "DepthOfField") -- equivalent call inferred; original call site unknown
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			scheduleDestroy(colorCorrectionEffect) -- equivalent call inferred; original call site unknown
			task.spawn(fn, colorCorrectionEffect)
			colorCorrectionEffect.Parent = Lighting
			v3.ColorSkill = true
			StartTweenLoop(colorCorrectionEffect, "ColorSkill") -- equivalent call inferred; original call site unknown
			local bloomEffect = Instance.new("BloomEffect")
			scheduleDestroy(bloomEffect) -- equivalent call inferred; original call site unknown
			task.spawn(fn, bloomEffect)
			bloomEffect.Parent = Lighting
			v3.Bloom = true
			StartTweenLoop(bloomEffect, "Bloom") -- equivalent call inferred; original call site unknown
			local atmosphere = Instance.new("Atmosphere")
			scheduleDestroy(atmosphere) -- equivalent call inferred; original call site unknown
			task.spawn(fn, atmosphere)
			atmosphere.Parent = Lighting
			v3.Atmosphere = true
			StartTweenLoop(atmosphere, "Atmosphere") -- equivalent call inferred; original call site unknown
			v3.Lighting = true
			StartTweenLoop(Lighting, "Lighting") -- equivalent call inferred; original call site unknown
			local highlight = Instance.new("Highlight")
			scheduleDestroy(highlight) -- equivalent call inferred; original call site unknown
			task.spawn(fn, highlight)
			local color = Color3.fromRGB(0, 0, 0)
			local color2 = Color3.fromRGB(0, 0, 0)
			highlight.FillColor = color
			highlight.OutlineColor = color2
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = char
			v3.Highlight = true
			StartTweenLoop(highlight, "Highlight") -- equivalent call inferred; original call site unknown
			local highlight2 = Instance.new("Highlight")
			scheduleDestroy(highlight2) -- equivalent call inferred; original call site unknown
			task.spawn(fn, highlight2)
			local color3 = Color3.fromRGB(0, 0, 0)
			local color4 = Color3.fromRGB(0, 0, 0)
			highlight2.FillColor = color3
			highlight2.OutlineColor = color4
			highlight2.FillTransparency = 1
			highlight2.OutlineTransparency = 1
			highlight2.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight2.Parent = targChar
			v3.Highlight2 = true
			StartTweenLoop(highlight2, "Highlight2") -- equivalent call inferred; original call site unknown
		end

		local v11 = {
			Character = char,
			Victim = targChar,
			Cleanup = fn,
			IsCutscene = isCutscene
		}
		local v12 = 1
		local total = 0
		local threader = Threader()
		local v14 = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			local v15 = v6[v12]
			total += dt

			if v15 and not v9 then
				local fn2 = v15.Fn
				local time = v15.Time

				if time and time < total then
					local v16

					if v8 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v8 = true
						v16 = false
					else
						v16 = true
					end

					if not v16 then
						return
					end

					if isCutscene and time >= 4 and not v14 then
						v14 = true
						task.spawn(function()
							local part = Instance.new("Part")
							scheduleDestroy(part) -- equivalent call inferred; original call site unknown
							table.insert(cleanupTable, part)
							part.Size = createVector(100, 100, 100)
							part.Anchored = true
							part.CanQuery = false
							part.CanTouch = false
							part.CanCollide = false
							part.CFrame = char.Torso.CFrame
							part.Parent = workspace.Thrown
							part.Transparency = 1
							part.CastShadow = false
							game.Debris:AddItem(part, 5)
							local overlapParams = OverlapParams.new()
							overlapParams.FilterType = Enum.RaycastFilterType.Exclude
							overlapParams.FilterDescendantsInstances = { workspace.Live }
							local partsInPart = workspace:GetPartsInPart(part, overlapParams)

							for _, part2 in pairs(partsInPart) do
								if not part2:IsA("BasePart") or transparenciesByPart[part2] then
									continue
								end

								transparenciesByPart[part2] = part2.Transparency
								part2.Transparency = 1
							end

							local map = workspace:FindFirstChild("Map")
							local trees = map and map:FindFirstChild("Trees")

							if trees then
								local function fn3(folder)
									for _, part2 in pairs(folder:GetDescendants()) do
										if not part2:IsA("BasePart") or transparenciesByPart[part2] then
											continue
										end

										transparenciesByPart[part2] = part2.Transparency
										part2.Transparency = 1
									end
								end

								for _, child in pairs(workspace.Map.Trash:GetChildren()) do
									local trashcan = child:FindFirstChild("Trashcan")

									if trashcan and (humanoidRootPart.Position - trashcan.Position).Magnitude <= 400 then
										fn3(child)
									end
								end

								for _, child in pairs(trees:GetChildren()) do
									local part2 = child:FindFirstChildOfClass("Part") or child:FindFirstChildOfClass("MeshPart")

									if part2 and (humanoidRootPart.Position - part2.Position).Magnitude <= 350 then
										fn3(child)
									end
								end
							end
						end)
					end

					if v15.Threaded then
						threader.RunFunction(fn2, v11)
					else
						pcall(fn2, v11)
					end

					v12 += 1
				end
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		end)
	end

	task.spawn(FirstEvent)
end

return LightningEmote