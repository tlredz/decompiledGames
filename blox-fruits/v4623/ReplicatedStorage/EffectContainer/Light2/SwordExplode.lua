local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function ScaleParticle(state, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, state.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

require(game.ReplicatedStorage.Util.RocksModule)
return function(p)
	local position = p.Position

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1200 then
		return
	end

	local clone = script.Part:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.Position = position
	local attachment = clone.Attachment
	attachment.PointLight.Range = 25
	attachment.PointLight.Brightness = 5
	clone.Parent = _WorldOrigin

	for _, emitter in ipairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	TweenService:Create(attachment.PointLight, TweenInfo.new(0.35), {
		Range = 0,
		Brightness = 0
	}):Play()
end