game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local FrameMarker = require(game.ReplicatedStorage.Resources.FrameMarker)
local newlibrarystar = require(game.ReplicatedStorage.Resources.newlibrarystar)
local MeshEmitNew = require(game.ReplicatedStorage.Resources.MeshEmitNew)

-- equivalent calls inferred from this helper; original call sites unknown
local function emitMesh(p, instance)
	local clone = instance:Clone()
	MeshEmitNew.new(clone):Emit(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enableMesh(p: number, p2: number, instance, p3, flag: boolean?)
	local clone = instance:Clone()
	MeshEmitNew.new(clone):EmitRate(p, p2, p3, flag)
end

local function Sky_Ripping_Fist(p)
	local char = p.Char
	local victim = p.Victim
	local primaryPart = char.PrimaryPart
	local _ = victim.PrimaryPart
	local rightArm = char:FindFirstChild("Right Arm")
	local leftArm = char:FindFirstChild("Left Arm")
	local clone = script.SkyRippingFistFX.Root:Clone()
	clone.Parent = workspace.Thrown
	clone.CFrame = primaryPart.CFrame
	local weld = Instance.new("Weld")
	clone.Anchored = false

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	weld.Part0 = clone
	weld.Part1 = primaryPart
	weld.Parent = clone
	return FrameMarker.new({
		Framerate = 60,
		Elapsed = 94
	}):Chain({
		[7] = function()
			newlibrarystar.particles.emit(clone.f25)
			newlibrarystar.particles.enable(rightArm)
			enableMesh(35, 0.9, script.Hands.FlowingBubbleBlue, rightArm:FindFirstChild("FX"), false) -- equivalent call inferred; original call site unknown
			newlibrarystar.particles.enable(leftArm)
			enableMesh(35, 0.9, script.Hands.FlowingBubbleRed, leftArm:FindFirstChild("FX"), false) -- equivalent call inferred; original call site unknown
		end,
		[68] = function()
			newlibrarystar.particles.disable(rightArm)
			newlibrarystar.particles.disable(leftArm)
			newlibrarystar.highlight.tween(
				primaryPart.Parent,
				Color3.fromRGB(90, 156, 255),
				Color3.fromRGB(53, 144, 255),
				1,
				Enum.HighlightDepthMode.Occluded,
				"In"
			)
			newlibrarystar.light.point(clone.f68, Color3.fromRGB(87, 168, 255), 0.7, 11, 8, 11)
			newlibrarystar.particles.emit(clone.f68)
			emitMesh(primaryPart, script.StartUp.LingerMesh) -- equivalent call inferred; original call site unknown
			emitMesh(primaryPart, script.StartUp.swirltuff) -- equivalent call inferred; original call site unknown
		end,
		[95] = function()
			newlibrarystar.highlight.tween(
				primaryPart.Parent,
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(255, 58, 61),
				1,
				Enum.HighlightDepthMode.Occluded,
				"In"
			)
			newlibrarystar.particles.emit(clone.f95)
			emitMesh(primaryPart, script.SuperDash.BigShockwave1) -- equivalent call inferred; original call site unknown
			enableMesh(21, 0.25, script.SuperDash.ShockwaveForward, primaryPart, nil) -- equivalent call inferred; original call site unknown
			enableMesh(11, 0.25, script.SuperDash.BigWind2, primaryPart, nil) -- equivalent call inferred; original call site unknown
			enableMesh(18, 0.25, script.SuperDash.GalaxyMeshWave, primaryPart, nil) -- equivalent call inferred; original call site unknown
			enableMesh(18, 0.25, script.SuperDash.GalaxyShock, primaryPart, nil) -- equivalent call inferred; original call site unknown
			task.wait(0.2)
			newlibrarystar.particles.emit(clone.f106)
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			newlibrarystar.effects.tweenBeams(clone.f95.Beam, tweenInfo, {
				Brightness = 1,
				LightEmission = 1,
				TextureSpeed = 0.6,
				Width0 = 15,
				Width1 = 25
			})
			emitMesh(primaryPart, script.SuperDash.BigShockwave2) -- equivalent call inferred; original call site unknown
			emitMesh(primaryPart, script.SuperDash.ImpactWaves) -- equivalent call inferred; original call site unknown
			emitMesh(primaryPart, script.SuperDash.Twirl1) -- equivalent call inferred; original call site unknown
		end,
		[116] = function() end,
		[156] = function()
			local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			newlibrarystar.effects.tweenBeams(clone.f95.Beam, tweenInfo, {
				Brightness = 0,
				LightEmission = 1,
				TextureSpeed = 2,
				Width0 = 5,
				Width1 = 43
			})
			newlibrarystar.particles.resetTimeScale(clone.f109)
			emitMesh(primaryPart, script.SlowMoPunch.BigShockwave1) -- equivalent call inferred; original call site unknown
			emitMesh(primaryPart, script.SlowMoPunch.BigShockwave2) -- equivalent call inferred; original call site unknown
			local tweenInfo2 = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			newlibrarystar.effects.tweenBeams(clone.f150.Beams, tweenInfo2, {
				Brightness = 0,
				LightEmission = 1,
				TextureSpeed = 0.9,
				Width0 = 5,
				Width1 = 25
			})
		end,
		[187] = function() end,
		[212] = function() end,
		[370] = function()
			newlibrarystar.particles.disable(clone.f205)
			local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
			newlibrarystar.effects.tweenBeams(clone.f205.Beams, tweenInfo, {
				Brightness = 0,
				LightEmission = 1,
				TextureSpeed = 1,
				Width0 = 5,
				Width1 = 19
			})
		end,
		[500] = function(instance)
			clone:Destroy()
			instance:Destroy()
		end
	})
end

return Sky_Ripping_Fist