local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(script.Parent.Modules.Beziers)
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage2:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
require(script.Parent.Modules.RockRipple)
require(script.Parent.Modules.UselessRocksShouldntEvenBeUsedForGravity)
require(game.ReplicatedStorage.Util.Rock2)
require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local F = FX:WaitForChild("Gravity").F

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function ScaleAttachmentsAndEmittersWithin(folder, p: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= p
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, p)
		end
	end
end

local function tweenBeamTransparency(instance, tweenInfo, p: number)
	if instance:GetAttribute("BeamTransparency") == nil then
		instance:SetAttribute("BeamTransparency", instance.Transparency == NumberSequence.new(1) and 1 or 0)
		instance:SetAttribute("OriginalBeamTransparencyNumberSequence", instance.Transparency)
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance:GetAttribute("BeamTransparency")
	local changedConnection = numberValue.Changed:Connect(function(beamTransparency)
		local numberSequenceKeypoints = {}

		for i, keypoint in ipairs(instance:GetAttribute("OriginalBeamTransparencyNumberSequence").Keypoints) do
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value + (1 - keypoint.Value) * beamTransparency
			)
		end

		instance.Transparency = NumberSequence.new(numberSequenceKeypoints)
		instance:SetAttribute("BeamTransparency", beamTransparency)
	end)
	local v = game.TweenService:Create(numberValue, tweenInfo, {
		Value = p
	})
	v:Play()
	v.Completed:Once(function()
		changedConnection:Disconnect()
		changedConnection = nil
		numberValue:Destroy()
		numberValue = nil
	end)
end

local function windRibbon(cFrame, p, p2, parent, folder)
	Util.Debris:AddItem(folder, 2)
	folder.Part.Color = Color3.fromRGB(0, 0, 0)
	folder.Part.CFrame = cFrame
	folder.Part.Transparency = 1
	local tween = TweenService:Create(
		folder.Part,
		TweenInfo.new(math.random(1, 2) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = folder.Part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			),
			Size = folder.Part.Size * math.random(6, 8),
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 1
		}
	)
	Util.ResizeModel(folder, math.random(p, p2), folder.Part.Position)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v = beam
			task.spawn(function()
				task.wait(0.1)
				tweenBeamTransparency(v, TweenInfo.new(0.1), 1)
			end)
		end

		local beam = folder.Part.beam1.Beam
		local beam2 = folder.Part.beam2.Beam
		local beam3 = folder.Part.beam3.Beam
		local beam4 = folder.Part.beam4.Beam
		local beam5 = folder.Part.beam5.Beam
		local beam6 = folder.Part.beam6.Beam
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		task.wait(0.05)
		TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end)
	tween.Completed:Connect(function()
		folder:Destroy()
	end)
	folder.Parent = parent
	tween:Play()
end

return function(data)
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	if data.Stage == 1 then
		local root = data.Root
		local clone = F.Hand.Emit:Clone()
		Util.SetParentOverrideWithColor(
			clone,
			root.Parent:FindFirstChild("RightHand"),
			data.Player,
			"GravityFruitVFXColor"
		)
		emitAll(clone)
		Util.Debris:AddItem(clone, 1.5)
		Util.Sound:Play("GravFruit_F_Release_Laser_04", root.Position)
		local ray = Util.Ray
		local v = root.Position + createVector(0, 2, 0)
		local v2 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
		local v3, v4, v5 = ray(v, createVector(-0, -70, -0), v2, false)

		if v3 ~= nil then
			local cFrame = CFrame.new(v4, v4 + v5) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
			local clone2 = F.BLASTUP:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, data.Player, "GravityFruitVFXColor")
			Util.Debris:AddItem(clone2, 3)
			emitAll(clone2)
			Util.Sound:Play("GravFruit_F_Release_VortexCircle_01", root.Position)
			clone2.DUST.Smoke.Color = ColorSequence.new(v3.Color)
			clone2.DUST.Smoke2.Color = ColorSequence.new(v3.Color)
			task.spawn(function()
				for _ = 1, 9 do
					task.spawn(function()
						local clone3 = F.SPINWIND2:Clone()
						clone3.CFrame = clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
						Util.SetParentOverrideWithColor(clone3, _WorldOrigin, data.Player, "GravityFruitVFXColor")
						Util.Debris:AddItem(clone3, 2)
						TweenService:Create(
							clone3,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CFrame = clone3.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
							}
						):Play()
						TweenService:Create(
							clone3.Mesh,
							TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Scale = createVector(14.852, 34.222, 14.037)
							}
						):Play()
						TweenService:Create(
							clone3.Decal,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end)
					task.wait(0.015)
				end
			end)
			task.spawn(function()
				for _ = 1, 9 do
					task.spawn(function()
						local clone3 = F.SPINWIND:Clone()
						clone3.CFrame = clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
						Util.SetParentOverrideWithColor(clone3, _WorldOrigin, data.Player, "GravityFruitVFXColor")
						Util.Debris:AddItem(clone3, 2)
						TweenService:Create(
							clone3,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CFrame = clone3.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
							}
						):Play()
						TweenService:Create(
							clone3.Mesh,
							TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Scale = createVector(11.852, 21.222, 11.037)
							}
						):Play()
						TweenService:Create(
							clone3.Decal,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end)
					task.wait(0.015)
				end
			end)
		end
	end
end