local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
game:GetService("RunService")
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterEffects)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.CraterExtension)
local TokenKit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Token.TokenKit)
Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local parent = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")

if parent == nil then
	parent = Instance.new("Folder", workspace.Debree)
	parent.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local function EmitAllSpec(folder, duration)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local v2 = descendant
			task.delay(descendant:GetAttribute("EmitDelay") or 0, function()
				v2:Emit(v2:GetAttribute("EmitCount") or 30)
			end)
		end

		if descendant:IsA("PointLight") then
			TweenService:Create(descendant, TweenInfo.new(duration), {
				Brightness = 0
			}):Play()
		end
	end
end

local function Toggle(folder, enabled)
	local descendants = folder:GetDescendants()

	for _, instance in ipairs(descendants) do
		if instance:IsA("ParticleEmitter") then
			instance.Enabled = enabled
		end

		if instance:IsA("PointLight") or instance:IsA("SurfaceLight") then
			instance.Enabled = enabled
		end

		if instance:IsA("Beam") then
			instance.Enabled = enabled
		end

		if instance:IsA("Trail") then
			instance.Enabled = enabled
		end
	end
end

local v2 = {
	Animations = {
		NezukoSlash = {
			"rbxassetid://16772444701",
			"rbxassetid://16772445208",
			"rbxassetid://16772445394",
			"rbxassetid://16772445551",
			"rbxassetid://16772445718",
			"rbxassetid://16772445890",
			"rbxassetid://16772446007"
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaySlash(p, nezukoSlash, value)
	local v3 = value or 60
	local decal = p.Decal
	task.spawn(function()
		for _, item in nezukoSlash do
			decal.Texture = item
			task.wait(1 / v3)
		end

		decal.Transparency = 1
	end)
end

function ImpactFrame(value)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)
	local lighting = game.Lighting
	colorCorrectionEffect.Contrast = -50
	colorCorrectionEffect.Saturation = -1
	colorCorrectionEffect.Parent = lighting
	DebrisModule:AddItem(colorCorrectionEffect, value or 0.08333333333333333)
end

function BlurEffect(value)
	local blurEffect = Instance.new("BlurEffect")
	local lighting = game.Lighting
	blurEffect.Size = 3
	blurEffect.Parent = lighting
	DebrisModule:AddItem(blurEffect, value or 0.08333333333333333)
end

return function(instance, p, instance2)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local magnitude = (instance.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

	if magnitude >= 250 then
		return
	end

	if p == "StarterSlash" then
		local clone = script.Attempt:Clone()
		clone.Parent = humanoidRootPart
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
		local clone2 = script.NezukoSlash1:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.31, -0.59, -0.39) * CFrame.fromEulerAnglesYXZ(
			0.498,
			3.08,
			1.37
		))
		clone2.Parent = parent
		DebrisModule:AddItem(clone2, 1.5)
		EmitAllSpec(clone2, 1)
		PlaySlash(clone2.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone2.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone2.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		local clone3 = script.ScratchMark:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(-5.18, -2.5, -5.9) * CFrame.fromEulerAnglesYXZ(-0, 2.4, 0)
		clone3.Parent = parent
		TokenKit.EmitAll(clone3)
		DebrisModule:AddItem(clone3, 1.5)
		local clone4 = script.NezukoSlash1:Clone()
		clone4:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.27, -0.43, -0.43) * CFrame.fromEulerAnglesYXZ(
			0.34,
			-3.04,
			-1.35
		))
		clone4.Parent = parent
		DebrisModule:AddItem(clone4, 1.5)
		EmitAllSpec(clone4, 1)
		TokenKit.EmitAll(clone4)
		PlaySlash(clone4.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone4.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone4.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		local clone5 = script.ScratchMark:Clone()
		clone5.CFrame = humanoidRootPart.CFrame * CFrame.new(3.82, -2.5, -5.9) * CFrame.fromEulerAnglesYXZ(-0, -2.06, 0)
		clone5.Parent = parent
		TokenKit.EmitAll(clone5)
		DebrisModule:AddItem(clone5, 1.5)
	elseif p == "Slash1" then
		local clone = script.NezukoSlash1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(-0.18743896484375, -1.4835057258605957, -1.59686279296875) * CFrame.fromEulerAnglesYXZ(
			-0.057513587176799774,
			-3.0886170864105225,
			1.1774322986602783
		))
		clone.Parent = parent
		DebrisModule:AddItem(clone, 1.5)
		EmitAllSpec(clone, 1)
		PlaySlash(clone.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown

		if magnitude <= 50 then
			BlurEffect(0.1)
		end
	elseif p == "Slash2" then
		local clone = script.NezukoSlash1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(1, -1.3675274848937988, -0.43023681640625) * CFrame.fromEulerAnglesYXZ(
			-0.12331271171569824,
			3.0492522716522217,
			-0.8966320157051086
		))
		clone.Parent = parent
		DebrisModule:AddItem(clone, 1.5)
		EmitAllSpec(clone, 1)
		PlaySlash(clone.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown

		if magnitude <= 50 then
			BlurEffect(0.1)
		end
	elseif p == "Slash3" then
		local clone = script.NezukoSlash1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(2.5667724609375, -1.0992112159729004, -0.2515869140625) * CFrame.fromEulerAnglesYXZ(
			0.07966601103544235,
			3.0933125019073486,
			-1.313460111618042
		))
		clone.Parent = parent
		DebrisModule:AddItem(clone, 1.5)
		EmitAllSpec(clone, 1)
		PlaySlash(clone.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		local clone2 = script.NezukoSlash1:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(-2.21319580078125, -1.0364785194396973, -0.25) * CFrame.fromEulerAnglesYXZ(
			0.08501958101987839,
			-3.088571310043335,
			1.339966893196106
		))
		clone2.Parent = parent
		DebrisModule:AddItem(clone2, 1.5)
		EmitAllSpec(clone2, 1)
		PlaySlash(clone2.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone2.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone2.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown

		if magnitude <= 50 then
			BlurEffect(0.1)
		end
	elseif p == "Slash4" then
		local clone = script.NezukoSlash1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(1.97894287109375, 1.7392258644104004, -0.3804931640625) * CFrame.fromEulerAnglesYXZ(
			0.07384803146123886,
			3.016101360321045,
			3.018805742263794
		))
		clone.Parent = parent
		DebrisModule:AddItem(clone, 1.5)
		EmitAllSpec(clone, 1)
		PlaySlash(clone.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		local clone2 = script.NezukoSlash1:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame * CFrame.new(-2.15863037109375, 1.6343369483947754, -0.750732421875) * CFrame.fromEulerAnglesYXZ(
			0.08203065395355225,
			3.1171817779541016,
			-2.9184024333953857
		))
		clone2.Parent = parent
		DebrisModule:AddItem(clone2, 1.5)
		EmitAllSpec(clone2, 1)
		PlaySlash(clone2.Slash1, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone2.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
		PlaySlash(clone2.Slash3, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown

		if magnitude <= 50 then
			BlurEffect(0.1)
		end
	elseif p == "Jump" then
		local clone = script.Jump:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.100616455078125, -2.5, 0.5013885498046875)
		clone.Parent = parent
		TokenKit.EmitAll(clone)
		DebrisModule:AddItem(clone, 6)
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(3.5, 3.5, 3.5)
		})
	elseif p == "Kick1" then
		local clone = script.Kick1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0.35980224609375, -0.7034642696380615, 1.76177978515625) * CFrame.fromEulerAnglesYXZ(
			-0.0575135312974453,
			-3.0886170864105225,
			1.177432656288147
		))
		clone.Parent = parent
		DebrisModule:AddItem(clone, 3)
		EmitAllSpec(clone, 1)
		PlaySlash(clone.Slash2, v2.Animations.NezukoSlash, 30) -- equivalent call inferred; original call site unknown
	elseif p == "Kick2" then
		local clone = script.HandInirial:Clone()
		clone.CFrame = instance2.CFrame
		clone.Parent = parent
		DebrisModule:AddItem(clone, 3)
		EmitAllSpec(clone, 1)
		Cam_Shaker(clone.Position, {
			FadeInTime = 0.05,
			Frequency = 0.1,
			Amplitude = 0.3,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		task.delay(0.2, function()
			local clone2 = script.WindupSparkles:Clone()
			clone2.CFrame = instance2.CFrame
			clone2.Parent = parent
			DebrisModule:AddItem(clone2, 3)
			task.wait(0.2)
			Toggle(clone2, false)
			task.wait(0.1)
			EmitAllSpec(clone2, 1)
		end)
		task.wait(0.6)

		if magnitude <= 50 then
			ImpactFrame(0.02)
			BlurEffect(0.5, humanoidRootPart)
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.1,
			Amplitude = 0.1,
			SustainTime = 3,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(2.5, 2.5, 2.5)
		})
		task.spawn(function()
			for _ = 1, 5 do
				local clone2 = script.HitFXBigger:Clone()
				clone2:PivotTo(instance2.CFrame)
				clone2.Parent = parent
				DebrisModule:AddItem(clone2, 3)
				TokenKit.EmitAll(clone2)
				Cam_Shaker(humanoidRootPart.Position, {
					FadeInTime = 0,
					Frequency = 0.1,
					Amplitude = 0.3,
					SustainTime = 0.1,
					FadeOutTime = 0.2,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(1.5, 1.5, 1.5)
				})
				task.wait(0.5)
			end
		end)
		local clone2 = script.FinalTornadoRevamp:Clone()
		clone2:PivotTo(instance2.CFrame * CFrame.new(0.814, -12, 1.259) * CFrame.Angles(3.142, -1.516, 1.571))
		clone2.Parent = parent
		Toggle(clone2, true)
		local flag = true
		task.delay(3, function()
			flag = false
		end)
		TokenKit.EmitAll(clone2)
		local v3 = nil

		while flag do
			clone2.Part.CFrame = clone2.Part.CFrame * CFrame.Angles(0.08726646259971647 * (v3 or 0.016) * 90, 0, 0)
			v3 = task.wait(0.0025)
		end

		local cFrame = instance2.CFrame
		local raycastResult = workspace:Raycast(
			cFrame * CFrame.new(0, 1, 0).Position,
			cFrame.UpVector * -30,
			raycastParams
		)

		if raycastResult ~= nil and raycastResult.Instance ~= nil then
			local clone3 = script.NezTornadoAfter:Clone()
			clone3.TopSurface = Enum.SurfaceType.Hinge
			clone3.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.new(
				0,
				0,
				-0.1
			) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Parent = parent
			DebrisModule:AddItem(clone3, 7)
			EmitAllSpec(clone3, 1)
		end

		if magnitude <= 50 then
			ImpactFrame(0.02)
			BlurEffect(0.5)
		end

		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.3,
			Amplitude = 0.6,
			SustainTime = 0.1,
			FadeOutTime = 0.9,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
		local descendants = clone2:GetDescendants()

		for _, trail in ipairs(descendants) do
			if trail:IsA("Trail") then
				TweenService:Create(trail, TweenInfo.new(2), {
					TextureLength = 0.1
				}):Play()
			end
		end

		task.wait()
		Toggle(clone2, false)
		local descendants2 = clone2:GetDescendants()

		for _, part in ipairs(descendants2) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.05), {
					Size = createVector(0.01, 0.01, 0.01)
				}):Play()
			end
		end

		DebrisModule:AddItem(clone2, 3)
	elseif p == "Drag" then
		local flag = true
		local clone = script.Finish:Clone()
		clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.615440607070923, 2.89837646484375) * CFrame.fromEulerAnglesYXZ(
			-0,
			3.1415927410125732,
			0
		)
		clone.Parent = parent
		Toggle(clone, true)
		DebrisModule:AddItem(clone, 6)
		local weld = Instance.new("Weld")
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone
		weld.Parent = humanoidRootPart
		weld.C0 = CFrame.new(0, -2.615440607070923, 2.89837646484375) * CFrame.fromEulerAnglesYXZ(
			-0,
			3.1415927410125732,
			0
		)
		task.delay(0.5, function()
			flag = false
		end)

		while flag do
			task.wait()
		end

		Toggle(clone, false)
	elseif p == "HitFX" then
		local upperTorso = instance2:FindFirstChild("UpperTorso") or instance2:FindFirstChild("Torso") or instance2:FindFirstChild("HumanoidRootPart")

		if upperTorso == nil then
			return
		end

		local clone = script.HitFX:Clone()
		clone.CFrame = upperTorso.CFrame
		clone.Parent = parent
		game.Debris:AddItem(clone, 2)
		TokenKit.EmitAll(clone)
		Cam_Shaker(clone.Position, {
			FadeInTime = 0.05,
			Frequency = 0.1,
			Amplitude = 0.2,
			SustainTime = 0.1,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(1.5, 1.5, 1.5)
		})
	end
end