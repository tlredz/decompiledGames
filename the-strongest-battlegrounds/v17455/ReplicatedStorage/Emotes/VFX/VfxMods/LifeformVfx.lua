local LifeformVfx = {}
local library = require(game.ReplicatedStorage.library)
local _ = library.PlayAttachment
local _ = library.Maid
local _ = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local _ = library.dtwait
local _ = library.EFP
local _ = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local _ = library.Able
local _ = library.LifeScale
local _ = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local class = {}
class.__index = class
Random.new()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local _ = game.Workspace.CurrentCamera
local MeshControl = require(ReplicatedStorage.Emotes.VFX.VfxMods.MeshControl)
local VfxUtils = require(ReplicatedStorage.VfxUtils)
local thrown = workspace.Thrown
local vfx = script.vfx

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleDestroy(instance)
	task.delay(9, function()
		if instance and instance.Parent then
			instance:Destroy()
		end
	end)
end

function LifeformVfx.FirstEvent(data)
	local char = data.Char
	local playerFromCharacter = Players:GetPlayerFromCharacter(char)
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {
		["Lighting|E"] = {
			{
				ExposureCompensation = 0
			},
			{
				ExposureCompensation = 13
			},
			{
				ExposureCompensation = 0
			},
			{
				ExposureCompensation = 0
			},
			{
				ExposureCompensation = 13
			},
			{
				ExposureCompensation = 0
			}
		}
	}
	local v9 = {
		["Lighting|G"] = {
			TweenInfo.new(0, Enum.EasingStyle.Linear),
			TweenInfo.new(13.35, Enum.EasingStyle.Linear),
			TweenInfo.new(15.05, Enum.EasingStyle.Linear)
		},
		["Lighting|E"] = {
			TweenInfo.new(13.016, Enum.EasingStyle.Linear),
			TweenInfo.new(13.283, Enum.EasingStyle.Linear),
			TweenInfo.new(13.733, Enum.EasingStyle.Linear),
			TweenInfo.new(14.93, Enum.EasingStyle.Linear),
			TweenInfo.new(15.133, Enum.EasingStyle.Linear),
			TweenInfo.new(15.5, Enum.EasingStyle.Linear)
		}
	}
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind
	local v10 = false
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	local CreateTweenLoop

	CreateTweenLoop = function(p, p2, value)
		if not v6[p2] then
			v6[p2] = 1
		end

		local v11 = value or 0
		local v12 = v6[p2]
		local v13 = v8[p2] and v8[p2][v12]
		local v14 = v9[p2] and v9[p2][v12]

		if v14 and v13 then
			local flag

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				flag = false
			else
				flag = true
			end

			if flag then
				if v2[p2] then
					v2[p2]:Disconnect()
				end

				local time = v14.Time
				local v15 = math.max(0, time - v11)
				local tween = TweenService:Create(
					p,
					TweenInfo.new(v15, v14.EasingStyle, v14.EasingDirection or Enum.EasingDirection.In),
					v13
				)
				tween:Play()
				v2[p2] = tween.Completed:Connect(function()
					v2[p2]:Disconnect()
					v2[p2] = nil
					v6[p2] = v12 + 1

					if v6[p2] > #v8[p2] then
						v6[p2] = 1
						v7[p2] = false
					end

					if v7[p2] then
						CreateTweenLoop(p, p2, time)
					end
				end)
				return
			end
		end

		v6[p2] = 1
		v7[p2] = false

		if v2[p2] then
			v2[p2]:Disconnect()
			v2[p2] = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function StartTweenLoop(p, p2)
		if v2[p2] then
			v2[p2]:Disconnect()
			v2[p2] = nil
		end

		v7[p2] = true
		v6[p2] = 1
		CreateTweenLoop(p, p2, 0)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function LerpColor3(data2, data3, p)
		return Color3.new(
			data2.R + (data3.R - data2.R) * p,
			data2.G + (data3.G - data2.G) * p,
			data2.B + (data3.B - data2.B) * p
		)
	end

	local function TweenScale(p: number, p2: number, data2, instance)
		local v11 = 0
		local v12 = 0

		local function onStep(p3: number)
			v11 = math.min(v11 + p3, data2.Time)
			v12 = p + TweenService:GetValue(v11 / data2.Time, data2.EasingStyle, data2.EasingDirection) * (p2 - p)

			if v12 <= 0 then
				v12 = 0.00001
			end

			instance:ScaleTo(v12)

			if v11 == data2.Time then
				v3.TweenScaleConnection:Disconnect()
			else
				local v13

				if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v10 = true
					v13 = false
				else
					v13 = true
				end

				if not v13 then
					v3.TweenScaleConnection:Disconnect()
				end
			end
		end

		if v3.TweenScaleConnection then
			v3.TweenScaleConnection:Disconnect()
		end

		v3.TweenScaleConnection = RunService.Heartbeat:Connect(onStep)
	end

	local function TweenBeamColor(p, p2, p3, p4, p5)
		local v11 = p4 / p5
		task.spawn(function()
			for i = 1, p5 do
				local v12

				if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v10 = true
					v12 = false
				else
					v12 = true
				end

				if not v12 then
					break
				end

				local lerpColor3 = LerpColor3(p2, p3, i / p5) -- equivalent call inferred; original call site unknown
				p.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor3),
					ColorSequenceKeypoint.new(1, lerpColor3)
				})
				task.wait(v11)
			end
		end)
	end

	local function TweenBeamColors(folder, p, p2)
		for _, beam in folder:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			local v11

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v11 = false
			else
				v11 = true
			end

			if not v11 then
				break
			end

			beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
			local v14 = 2
			local v15 = beam
			local v16 = 0.5
			task.spawn(function()
				for i = 1, v14 do
					local v17

					if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v10 = true
						v17 = false
					else
						v17 = true
					end

					if not v17 then
						break
					end

					local lerpColor3 = LerpColor3(p, p2, i / v14) -- equivalent call inferred; original call site unknown
					v15.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, lerpColor3),
						ColorSequenceKeypoint.new(1, lerpColor3)
					})
					task.wait(v16)
				end
			end)
		end
	end

	local function ToggleVisiblity(folder, p, p2)
		local v11 = p2 == nil and {} or p2
		local transparency = p == false and 1 or 0

		for _, part in folder:GetDescendants() do
			if table.find(v11, part.Name) or not (part:IsA("MeshPart") or part:IsA("BasePart")) then
				continue
			end

			local v13

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v13 = false
			else
				v13 = true
			end

			if not v13 then
				break
			end

			part.Transparency = transparency
		end
	end

	local function ApplySkinColor(folder, color)
		for _, part in folder:GetDescendants() do
			if not ((part:IsA("MeshPart") or part:IsA("BasePart")) and part:GetAttribute("SkinColor")) then
				continue
			end

			local v11

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v11 = false
			else
				v11 = true
			end

			if not v11 then
				break
			end

			part.Color = color
		end
	end

	local function ApplyMeshEffects(folder)
		for _, model in folder:GetDescendants() do
			if model:IsA("Model") then
				MeshControl(model)
			end
		end
	end

	local function EmitEffects(folder)
		for _, emitter in folder:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v11 = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				local v12

				if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v10 = true
					v12 = false
				else
					v12 = true
				end

				if not v12 then
					return
				end

				v11:Emit(v11:GetAttribute("EmitCount"))
			end)
		end
	end

	local function ToggleEffects(folder, enabled)
		for _, descendant in folder:GetDescendants() do
			if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("Trail")) then
				continue
			end

			local v11

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v11 = false
			else
				v11 = true
			end

			if not v11 then
				break
			end

			descendant.Enabled = enabled
		end
	end

	local flag = false
	local lastTime = tick()

	local function CleanUp(_, _)
		if flag then
			return
		end

		flag = true

		for k, connection in v2 do
			if connection then
				connection:Disconnect()
			end

			v2[k] = nil
		end

		for k, v11 in v5 do
			local v12 = v11
			pcall(function()
				v12:Cancel()
				v12:Destroy()
			end)
			v5[k] = nil
		end

		for k, v11 in v4 do
			pcall(task.cancel, v11)
			v4[k] = nil
		end

		for k, connection in v3 do
			if connection then
				connection:Disconnect()
			end

			v3[k] = nil
		end

		for k, v11 in v do
			if v11 and v11.Parent then
				local v12 = v11
				pcall(function()
					v12:Destroy()
				end)
			end

			v[k] = nil
		end

		table.clear(v7)
		table.clear(v6)
	end

	local v11

	if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v10 = true
		v11 = false
	else
		v11 = true
	end

	if not v11 then
		return
	end

	v3.cleanup = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if not (bind and bind.Parent) then
			v10 = true
			CleanUp(char)
		end
	end)
	v3.cleanup2 = realAnim.Stopped:Connect(function()
		if not realAnim.IsPlaying and tick() - lastTime <= 12 then
			v10 = true
			CleanUp(char)
		end
	end)
	task.delay(25, function()
		CleanUp(char)

		if cleanupTable then
			for _, v12 in cleanupTable do
				if not (typeof(v12) == "Instance" and v12.Parent) then
					continue
				end

				local v13 = v12
				pcall(function()
					v13:Destroy()
				end)
			end
		end
	end)
	local v12 = playerFromCharacter == Players.LocalPlayer
	local _ = workspace.CurrentCamera
	local playerGui = playerFromCharacter:FindFirstChildOfClass("PlayerGui")

	local function firstEvent()
		local v13

		if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v10 = true
			v13 = false
		else
			v13 = true
		end

		if not v13 then
			return
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		char:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
		char:FindFirstChild("Left Arm")
		char:FindFirstChild("Right Arm")
		char:FindFirstChild("Left Leg")
		char:FindFirstChild("Right Leg")
		char:FindFirstChild("Head")
		local torso = char:FindFirstChild("Torso")
		local clone

		if v12 then
			clone = vfx.Screen:Clone()
			task.delay(4, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
			scheduleDestroy(clone) -- equivalent call inferred; original call site unknown
			clone.Parent = playerGui.MobileJunk
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone.Vignette, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0.43
			}):Play()
			table.insert(v, clone)
			v7["Lighting|G"] = true
			StartTweenLoop(Lighting, "Lighting|G") -- equivalent call inferred; original call site unknown
			v7["Lighting|E"] = true
			StartTweenLoop(Lighting, "Lighting|E") -- equivalent call inferred; original call site unknown
		else
			clone = nil
		end

		local mask = char:WaitForChild("Mask", 2)
		char:WaitForChild("Blades")
		local clone2 = vfx.Handler:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = thrown
		table.insert(v, clone2)
		local clone3 = vfx.Meshes:Clone()
		scheduleDestroy(clone3) -- equivalent call inferred; original call site unknown
		clone3:PivotTo(humanoidRootPart.CFrame * (CFrame.new(0, -14, -1.808) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)))
		clone3.Parent = thrown
		table.insert(v, clone3)

		for _, child in vfx.TorsoEffects:GetChildren() do
			local clone4 = child:Clone()
			scheduleDestroy(clone4) -- equivalent call inferred; original call site unknown
			clone4.Parent = torso
			table.insert(v, clone4)
		end

		v4.EffectEmit1 = task.delay(3.683, function()
			local v14

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			VfxUtils.Emit(mask, "blood")
			VfxUtils.Highlight(char, {
				fadeOut = 1,
				delay = 0.3,
				easingStyle = "Smoother",
				easingDirection = "Out",
				fillColor = Color3.fromRGB(131, 31, 31),
				outlineColor = Color3.fromRGB(227, 0, 0),
				fillTransparency = 0.85,
				outlineTransparency = 0.85
			})
			VfxUtils.Emit(torso.heart)

			if v12 then
				VfxUtils.ColorCorrection({
					fadeOut = 1,
					easingStyle = "Smoother",
					easingDirection = "Out",
					brightness = 0.2,
					saturation = 0.05,
					contrast = 0.3,
					tint = Color3.fromRGB(255, 255, 255)
				})
			end

			VfxUtils.Emit(mask.Jewel)
		end)
		v4.EffectEmit2 = task.delay(4.5, function()
			local v14

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			VfxUtils.Emit(clone2.arm)
		end)
		v4.EffectEmit3 = task.delay(5.55, function()
			local v14

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			VfxUtils.Emit(clone2.fall)
		end)
		v4.EffectEmit4 = task.delay(8.683, function()
			local v14

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			VfxUtils.Emit(clone2.flash)
		end)
		v4.EffectEmit5 = task.delay(8.783, function()
			local v14

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			VfxUtils.Emit(clone2.kanji)
			VfxUtils.Emit(mask.Mask)
		end)
		v4.EffectEmit6 = task.delay(9.8833, function()
			local v14

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			VfxUtils.Emit(clone2.rgb)

			if v12 then
				local cameraRigK = char:FindFirstChild("CameraRigK")
				VfxUtils.Emit(cameraRigK.Camera.CLIENTONLY)
				VfxUtils.RGBGradient(cameraRigK.Camera.CLIENTONLY, {
					duration = 3.3,
					speed = 0.25,
					saturation = 0.65
				})
			end

			for _, child in pairs(clone3:GetChildren()) do
				local v15

				if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v10 = true
					v15 = false
				else
					v15 = true
				end

				if not v15 then
					return
				end

				VfxUtils.MeshEmit(child)
			end

			local v15

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v15 = false
			else
				v15 = true
			end

			if not v15 then
				return
			end

			VfxUtils.RGBGradient(clone2.rgb, {
				duration = 3.4,
				speed = 0.2,
				saturation = 0.55
			})
			VfxUtils.BeamFade(clone2.bms, {
				fadeOut = 0.65,
				easingStyle = "Smoother",
				easingDirection = "Out",
				delayTime = 3
			})
			VfxUtils.BeamFade(clone2.windBeams, {
				fadeOut = 0.6,
				easingStyle = "Smoother",
				easingDirection = "Out",
				delayTime = 3
			})
			local v16

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v16 = false
			else
				v16 = true
			end

			if not v16 then
				return
			end

			clone2.rgb.PointLight.Enabled = true
			task.wait(3)
			local v17

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v17 = false
			else
				v17 = true
			end

			if not v17 then
				return
			end

			clone2.rgb.PointLight.Enabled = false
		end)

		if v12 then
			v4.EffectEmit7 = task.delay(10, function()
				local v14

				if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v10 = true
					v14 = false
				else
					v14 = true
				end

				if not (v14 and v12) then
					return
				end

				char:FindFirstChild("CameraRigK")
				task.wait(3)
				local v15

				if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v10 = true
					v15 = false
				else
					v15 = true
				end

				if not v15 then
					return
				end

				local cameraRigK = char:FindFirstChild("CameraRigK")
				VfxUtils.Emit(cameraRigK.Camera.CLIENTGALAXY)
				task.delay(2.25, function()
					if not (cameraRigK and cameraRigK.Parent) then
						return
					end

					if clone and clone.Parent then
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(clone.Vignette, TweenInfo.new(0.35), {
							ImageTransparency = 1
						}):Play()
					end

					for _, v16 in pairs(cameraRigK.AnimationController:GetPlayingAnimationTracks()) do
						v16:Stop(0)
					end
				end)
			end)
		end

		v4.EffectEmit8 = task.delay(14.85, function()
			local v14

			if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v10 = true
				v14 = false
			else
				v14 = true
			end

			if not v14 then
				return
			end

			if clone2 and clone2.Parent then
				VfxUtils.Emit(clone2.aura)
			end
		end)
	end

	local v13

	if v10 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v10 = true
		v13 = false
	else
		v13 = true
	end

	if not v13 then
		return
	end

	task.spawn(firstEvent)
end

return LifeformVfx