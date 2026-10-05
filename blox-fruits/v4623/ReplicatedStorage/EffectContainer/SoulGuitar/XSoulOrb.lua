local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local soulOrb = FX:WaitForChild("SoulGuitarEffects").SoulOrb
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local attachmentPair = Util.AttachmentPair

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local function RandomVectorOffsetBetween(axis, p, p2)
	return (CFrame.lookAt(Vector3.new(), axis) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), (math.cos(p))))),
		0,
		0
	)).LookVector
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function CubicBezier(p, position, p2, p3, position2)
	return position * (1 - p) ^ 3 + p2 * 3 * p * (1 - p) ^ 2 + p3 * 3 * (1 - p) * p ^ 2 + position2 * p ^ 3
end

local v = {}
return function(data)
	local _ = data.player
	local casterHrp = data.casterHrp
	local victimHrp = data.victimHrp
	local timeUntilSoulReaches = data.timeUntilSoulReaches
	local color = data.color
	local times = data.times or 1
	local axis = data.axis or createVector(0, 1, 0)

	for i = 1, times do
		local v2 = i
		task.spawn(function()
			task.delay((v2 - 1) * 0.1, function()
				if color then
					v[casterHrp] = v[casterHrp] or {}
					v[casterHrp][victimHrp] = v[casterHrp][victimHrp] or 0

					if v[casterHrp] and v[casterHrp][victimHrp] and v[casterHrp][victimHrp] > 1 then
						return
					end

					v[casterHrp][victimHrp] += 1
				end

				if casterHrp == nil or casterHrp.Parent == nil or (victimHrp == nil or victimHrp.Parent == nil) then
					return
				end

				if (casterHrp.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
					return
				end

				local v3 = attachmentPair.new(soulOrb.A0.CFrame, soulOrb.A1.CFrame)
				task.delay(timeUntilSoulReaches + 2, function()
					v3:destroy()
				end)
				local clone = soulOrb.A0.Trail:Clone()

				if data.WidthScale then
					clone.WidthScale = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1 * data.WidthScale),
						NumberSequenceKeypoint.new(1, 0)
					})
				end

				v3:hookUp(clone)
				local clone2 = soulOrb.A0.Drops:Clone()
				local clone3 = soulOrb.A0.Specs:Clone()

				if color then
					clone2.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
					})
					clone3.Color = clone2.Color
					clone.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, color),
						ColorSequenceKeypoint.new(1, color)
					})
				end

				v3:hookUp(clone2)
				v3:hookUp(clone3)
				local lookVector = RandomVectorOffsetBetween(axis, 0, 1.2217304763960306)
				local lookVector2 = RandomVectorOffsetBetween(axis, 0, 1.2217304763960306)
				local connection = nil
				connection = heartbeatLoopFor2(timeUntilSoulReaches, function(p, p2, p3)
					if casterHrp == nil or casterHrp.Parent == nil then
						connection:Disconnect()
						connection = nil
					elseif victimHrp == nil or victimHrp.Parent == nil then
						connection:Disconnect()
						connection = nil
					else
						local cFrame = casterHrp.CFrame
						local cFrame2 = victimHrp.CFrame
						local position = cFrame2.Position
						local v6 = cFrame2.Position + lookVector * 20
						local v7 = cFrame.Position + lookVector2 * 20
						local position2 = cFrame.Position
						v3:setRelativeCFrame(CFrame.new(CubicBezier(p3, position, v6, v7, position2)))
					end
				end, function()
					if casterHrp == nil or casterHrp.Parent == nil then
						return
					end

					v3:setRelativeCFrame(CFrame.new(casterHrp.Position))
					clone.Enabled = false
					clone2.Enabled = false
					clone3.Enabled = false

					for i2, child in ipairs(soulOrb.HitAttachment:GetChildren()) do
						local clone4 = child:Clone()
						v3:hookUp(clone4)
						clone4.Color = clone2.Color
						clone4:Emit(clone4:GetAttribute("EmitCount"))
					end

					if color then
						v[casterHrp] = v[casterHrp] or {}
						v[casterHrp][victimHrp] = v[casterHrp][victimHrp] or 0

						if v[casterHrp] and v[casterHrp][victimHrp] and v[casterHrp][victimHrp] > 2 then
							return
						end

						v[casterHrp][victimHrp] -= 1

						if v[casterHrp][victimHrp] == 0 then
							v[casterHrp][victimHrp] = nil

							if not next(v[casterHrp]) then
								v[casterHrp] = nil
							end
						end
					else
						local clone4 = soulOrb.SoulAbsorb:Clone()
						v3:hookUp(clone4)
						local play = Util.UtilSoundWrapper.Play(clone4, v3.attachment0.WorldPosition)
						play.PlaybackSpeed = 0.9 + math.random() * 0.2
					end
				end)
			end)
		end)
	end
end