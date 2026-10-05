local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
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
require(script.Parent.Modules.SwirlsZ)
require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("Gravity").M1
local Players = game:GetService("Players")

local function GetGravityColorOwner(data)
	local player = data.Player

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return player
	end

	local root = data.Root

	if typeof(root) == "Instance" and root.Parent then
		local playerFromCharacter = Players:GetPlayerFromCharacter(root.Parent)

		if playerFromCharacter and playerFromCharacter.Parent then
			return playerFromCharacter
		end
	end

	return nil
end

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

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

return function(data)
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage
	local root = data.Root

	if stage == 1 then
		local cframe = CFrame.new(0, 2, 0)
		local clone = M1.PortalA:Clone()
		clone.CFrame = data.StartCFrame * cframe * CFrame.Angles(0, 1.5707963267948966, -1.5707963267948966)
		clone.Anchored = true
		clone.CanCollide = false
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, GetGravityColorOwner(data), "GravityFruitVFXColor")
		Util.Sound:Play("GravFruit_PortalA", clone.Position)
		Util.Debris:AddItem(clone, 4)
		emitAll(clone)
	elseif stage == 2 then
		local cframe = CFrame.new(0, 2, -1)
		local clone = M1.PortalB:Clone()
		clone.CFrame = data.EndCFrame * cframe
		local unit = (root.Position - clone.Position).Unit
		clone.CFrame = CFrame.new(clone.Position, clone.Position - unit * createVector(1, 0, 1)) * CFrame.Angles(
			0,
			1.5707963267948966,
			-1.5707963267948966
		)
		clone.Anchored = true
		clone.CanCollide = false
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, GetGravityColorOwner(data), "GravityFruitVFXColor")
		Util.Sound:Play("GravFruit_PortalB", clone.Position)
		Util.Debris:AddItem(clone, 4)
		emitAll(clone)
	end
end