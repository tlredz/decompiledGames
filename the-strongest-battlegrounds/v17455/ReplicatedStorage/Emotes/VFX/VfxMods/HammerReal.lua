local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local _ = game.Lighting
local library = require(script.Parent.library)
local playAttachment = library.PlayAttachment
local FrameMarker = require(ReplicatedStorage.Resources.FrameMarker)

local function fn(effect)
	if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
		effect.Enabled = true
	end

	for _, effect2 in effect:GetDescendants() do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail") or effect2:IsA("Beam")) then
			continue
		end

		effect2.Enabled = true
	end
end

local function fn2(effect)
	if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
		effect.Enabled = false
	end

	for _, effect2 in effect:GetDescendants() do
		if not (effect2:IsA("ParticleEmitter") or effect2:IsA("Trail") or effect2:IsA("Beam")) then
			continue
		end

		effect2.Enabled = false
	end
end

local function createTweenHighlight(p, color: Color3?, color2: Color3?, value: number?, p2, p3: string?, value2: number?)
	local v = value or 1
	local highlight = Instance.new("Highlight")
	highlight.Adornee = p
	highlight.DepthMode = p2 or Enum.HighlightDepthMode.Occluded
	highlight.FillColor = color or Color3.new(1, 1, 1)
	highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 0
	local v2, v3

	if p3 == "Out" then
		v2 = 1
		v3 = 0
	else
		v2 = value2 or 0
		v3 = 1
	end

	highlight.FillTransparency = v2
	highlight.OutlineTransparency = v2
	highlight.Parent = p
	TweenService:Create(highlight, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		FillTransparency = v3,
		OutlineTransparency = v3
	}):Play()
	Debris:AddItem(highlight, v)
	return highlight
end

local v = {
	tweenHighlight = createTweenHighlight,
	pulseHighlight = function(p, color: Color3?, color2: Color3?, value: number?, p2, value2: number?, value3: number?, value4: number?)
		local highlight = Instance.new("Highlight")
		highlight.Adornee = p
		highlight.DepthMode = p2 or Enum.HighlightDepthMode.Occluded
		highlight.FillColor = color or Color3.new(1, 1, 1)
		highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
		local v2 = value or 0.5
		local v3 = value3 or 0
		local v4 = value4 or 1
		highlight.FillTransparency = v3
		highlight.OutlineTransparency = v3
		highlight.Parent = p
		local tweenInfo = TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local tween = TweenService:Create(highlight, tweenInfo, {
			FillTransparency = v4,
			OutlineTransparency = v4
		})
		local tween2 = TweenService:Create(highlight, tweenInfo2, {
			FillTransparency = v3,
			OutlineTransparency = v3
		})
		local count = 0
		local v5 = value2 or 0
		local doPulse

		doPulse = function()
			if not (highlight and highlight.Parent) then
				return
			end

			tween:Play()
			tween.Completed:Wait()

			if not (highlight and highlight.Parent) then
				return
			end

			tween2:Play()
			tween2.Completed:Wait()
			count += 1

			if v5 == 0 or count < v5 then
				task.spawn(doPulse)
			else
				Debris:AddItem(highlight, 0.1)
			end
		end

		task.spawn(doPulse)
		return highlight
	end,
	flashHighlight = function(p, color: Color3?, color2: Color3?, value: number?, value2: number?, p2)
		local highlight = Instance.new("Highlight")
		highlight.Adornee = p
		highlight.DepthMode = p2 or Enum.HighlightDepthMode.Occluded
		highlight.FillColor = color or Color3.new(1, 1, 1)
		highlight.OutlineColor = color2 or Color3.new(1, 1, 1)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Parent = p
		local v2 = value2 or 0.1
		local v3 = value or 1
		local tweenInfo = TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo2 = TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local tween = TweenService:Create(highlight, tweenInfo, {
			FillTransparency = 0,
			OutlineTransparency = 0
		})
		local tween2 = TweenService:Create(highlight, tweenInfo2, {
			FillTransparency = 1,
			OutlineTransparency = 1
		})
		local lastTime = os.clock()
		local doFlash

		doFlash = function()
			if not (highlight and highlight.Parent) then
				return
			end

			if v3 <= os.clock() - lastTime then
				Debris:AddItem(highlight, 0.1)
				return
			end

			tween:Play()
			tween.Completed:Wait()

			if not (highlight and highlight.Parent) then
				return
			end

			tween2:Play()
			tween2.Completed:Wait()
			task.spawn(doFlash)
		end

		task.spawn(doFlash)
		Debris:AddItem(highlight, v3 + 0.5)
		return highlight
	end
}

local function fn3(instance, data, p)
	local clone = instance:Clone()
	clone.Parent = workspace.Thrown
	local v2 = p or clone.CFrame

	for _, beam in clone:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local v3 = {
			Width0 = beam.Width0,
			Width1 = beam.Width1,
			TextureSpeed = beam.TextureSpeed,
			Brightness = beam.Brightness,
			LightEmission = beam.LightEmission
		}
		local tween = TweenService:Create(
			beam,
			TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
			data.Properties
		)
		tween:Play()
		local v4 = beam
		tween.Completed:Once(function()
			v4.Enabled = false

			for k, v6 in v3 do
				v4[k] = v6
			end
		end)
	end

	TweenService:Create(
		clone,
		TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
		{
			Position = (v2 * data.Offset).Position
		}
	):Play()
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		clone.CFrame *= CFrame.Angles(0, 0, (math.rad(data.RotationSpeed)))
		total += dt

		if total > 5 and heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	Debris:AddItem(clone, 5)
	return clone
end

local mesh_emit = require(script.Parent.mesh_emit)

local function fn4(p, tweenInfo, p2: number)
	local model = Instance.new("Model", workspace.Thrown)
	p.Parent = model
	Debris:AddItem(model, 5)
	local numberValue = Instance.new("NumberValue", model)
	numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		model:ScaleTo(numberValue.Value)
	end)
	TweenService:Create(numberValue, tweenInfo, {
		Value = p2
	}):Play()
end

local function Move3Finisher(p)
	local char = p.Char
	local victim = p.Victim
	local primaryPart = char.PrimaryPart
	local primaryPart2 = victim.PrimaryPart
	local clone = script.HammerHeelFinisherFX.PartFx:Clone()
	clone.Parent = workspace.Thrown
	clone.CFrame = primaryPart.CFrame
	game.Debris:AddItem(clone, 6)
	local weld = Instance.new("Weld")
	weld.Parent = clone
	weld.Part0 = clone
	weld.Part1 = primaryPart
	return FrameMarker.new({
		Framerate = 60
	}):Chain({
		[1] = function()
			v.tweenHighlight(
				primaryPart2.Parent,
				Color3.fromRGB(255, 255, 255),
				Color3.fromRGB(255, 255, 255),
				0.7,
				Enum.HighlightDepthMode.Occluded,
				"In",
				0
			)
			playAttachment(clone.f1)
			local pullUpBeams = script.Kick.Mesh.PullUpBeams
			pullUpBeams.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 1.5707963267948966, 0)
			fn3(pullUpBeams, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = 0.5,
					Width0 = 2,
					Width1 = 22
				},
				RotationSpeed = 2,
				Rotation = true,
				Offset = CFrame.new(0, 0, -8),
				Duration = 0.45,
				Easing = "Sine",
				EasingDirection = "Out"
			})
			local clone2 = script.Kick.Mesh.KickSwirl:Clone()
			game.Debris:AddItem(clone2, 7)
			mesh_emit.new(clone2):Emit(primaryPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.Kick.Mesh.HitSlightImpact:Clone()
			game.Debris:AddItem(clone3, 7)
			mesh_emit.new(clone3):Emit(primaryPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.Kick.Mesh.HitHardImpact:Clone()
			game.Debris:AddItem(clone4, 7)
			mesh_emit.new(clone4):Emit(primaryPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			local clone5 = script.Kick.Mesh.HitShockImpact:Clone()
			game.Debris:AddItem(clone5, 7)
			mesh_emit.new(clone5):Emit(primaryPart.CFrame * CFrame.new(clone5:GetAttribute("Offset")))
			local clone6 = script.Kick.Mesh.RingMesh:Clone()
			game.Debris:AddItem(clone6, 7)
			mesh_emit.new(clone6):Emit(primaryPart.CFrame * CFrame.new(clone6:GetAttribute("Offset")))
		end,
		[30] = function()
			local pullBeams = script.Pull.Mesh.PullBeams
			pullBeams.CFrame = primaryPart.CFrame * CFrame.new(-9, 0, -1) * CFrame.Angles(0, -1.3439035240356338, 0)
			fn3(pullBeams, {
				Properties = {
					Brightness = 1,
					LightEmission = 1,
					TextureSpeed = 11,
					Width0 = 2,
					Width1 = 22
				},
				RotationSpeed = 2,
				Rotation = true,
				Offset = CFrame.new(0, 0, -13),
				Duration = 0.4,
				Easing = "Sine",
				EasingDirection = "In"
			})
		end,
		[50] = function()
			playAttachment(clone.f50)
			local spinFX = clone.f50.SpinFX
			spinFX.Parent = workspace.Thrown
			spinFX.CFrame = primaryPart.CFrame * CFrame.new(0, -2.5, 0)
			Debris:AddItem(spinFX, 3)
			TweenService:Create(spinFX, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0), {
				CFrame = spinFX.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local clone2 = script.Swing.Mesh.WindDecal1:Clone()
			game.Debris:AddItem(clone2, 7)
			mesh_emit.new(clone2):Emit(primaryPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.Swing.Mesh.WindThroweey:Clone()
			game.Debris:AddItem(clone3, 7)
			mesh_emit.new(clone3):Emit(primaryPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.Swing.Mesh.WindSwirl1:Clone()
			game.Debris:AddItem(clone4, 7)
			mesh_emit.new(clone4):Emit(primaryPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			local root = script.Swing.Mesh.GroundBeams.Root
			root.CFrame = primaryPart.CFrame * CFrame.new(2, -1, 0) * CFrame.Angles(0, -2.0943951023931953, 0)
			fn4(fn3(root, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = -0.45,
					Width0 = 2,
					Width1 = 13
				},
				RotationSpeed = 0,
				Rotation = true,
				Offset = CFrame.new(0, 0, 0),
				Duration = 1.5,
				Easing = "Sine",
				EasingDirection = "Out"
			}), TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 1.5)
			local root2 = script.Swing.Mesh.FullGBeams.Root
			root2.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 0.7853981633974483, 0)
			fn4(fn3(root2, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = -0.5,
					Width0 = 3,
					Width1 = 23
				},
				RotationSpeed = 0,
				Rotation = true,
				Offset = CFrame.new(0, 2, 0),
				Duration = 0.8,
				Easing = "Sine",
				EasingDirection = "Out"
			}), TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 4)
		end,
		[63] = function()
			fn2(primaryPart2.Parent)
			playAttachment(clone.f63)
			local spinFX = clone.f63.SpinFX
			spinFX.Parent = workspace.Thrown
			spinFX.CFrame = primaryPart.CFrame * CFrame.new(0, -2.5, 0)
			Debris:AddItem(spinFX, 3)
			TweenService:Create(spinFX, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0), {
				CFrame = spinFX.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local clone2 = script.Swing.Mesh.WindSwirl2:Clone()
			game.Debris:AddItem(clone2, 7)
			mesh_emit.new(clone2):Emit(primaryPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			local clone3 = script.Swing.Mesh.WindDecal2:Clone()
			game.Debris:AddItem(clone3, 7)
			mesh_emit.new(clone3):Emit(primaryPart.CFrame * CFrame.new(clone3:GetAttribute("Offset")))
			local clone4 = script.Swing.Mesh.WindThroweey2:Clone()
			game.Debris:AddItem(clone4, 7)
			mesh_emit.new(clone4):Emit(primaryPart.CFrame * CFrame.new(clone4:GetAttribute("Offset")))
			local root = script.Swing.Mesh.GroundBeams2.Root
			root.CFrame = primaryPart.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(0, 0.7853981633974483, 0)
			fn4(fn3(root, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = -0.4,
					Width0 = 2,
					Width1 = 13
				},
				RotationSpeed = 0,
				Rotation = true,
				Offset = CFrame.new(0, 0, 0),
				Duration = 1.5,
				Easing = "Sine",
				EasingDirection = "Out"
			}), TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 1.5)
			local root2 = script.Swing.Mesh.FullGBeams.Root
			root2.CFrame = primaryPart.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 1.4835298641951802, 0)
			fn4(fn3(root2, {
				Properties = {
					Brightness = 0,
					LightEmission = 1,
					TextureSpeed = -0.2,
					Width0 = 3,
					Width1 = 23
				},
				RotationSpeed = 0,
				Rotation = true,
				Offset = CFrame.new(0, 2, 0),
				Duration = 1.53,
				Easing = "Quad",
				EasingDirection = "Out"
			}), TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 3.5)
		end,
		[100] = function()
			fn(clone.f100)
			local clone2 = script.ChargingUp.Mesh.RingMesh:Clone()
			game.Debris:AddItem(clone2, 7)
			mesh_emit.new(clone2):EmitRate(8.5, 0.5, primaryPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			v.tweenHighlight(
				primaryPart2.Parent,
				Color3.fromRGB(36, 0, 0),
				Color3.fromRGB(65, 0, 0),
				0.5,
				Enum.HighlightDepthMode.Occluded,
				"Out",
				0
			)
			task.wait(0.5)
			v.tweenHighlight(
				primaryPart2.Parent,
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(0, 0, 0),
				1,
				Enum.HighlightDepthMode.Occluded,
				"In",
				0.5
			)
		end,
		[131] = function()
			fn2(clone.f100)
			playAttachment(clone.f131)
			local clone2 = script.RipOff.Mesh.WindThroweey:Clone()
			game.Debris:AddItem(clone2, 7)
			local v2 = mesh_emit.new(clone2)
			v2:Emit(primaryPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			v2:Emit(primaryPart.CFrame * CFrame.new(clone2:GetAttribute("Offset")))
			v.tweenHighlight(
				primaryPart.Parent,
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(0, 0, 0),
				1,
				Enum.HighlightDepthMode.Occluded,
				"In",
				0
			)
		end,
		[300] = function(instance)
			clone:Destroy()
			instance:Destroy()
		end
	})
end

return Move3Finisher