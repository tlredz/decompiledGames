workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local FX = require(game.ReplicatedStorage.FX)

local function ScaleParticle(state, scale)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, state.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope)
		)
	end

	state.Speed = NumberRange.new(state.Speed.Min * scale, state.Speed.Max * scale)
	return NumberSequence.new(numberSequenceKeypoints)
end

require(game.ReplicatedStorage.Util.RocksModule)
return function(p)
	local position = p.Position
	local scale = p.Scale or 4

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1200 then
		return
	end

	local v = math.random(1, 360)
	local clone = FX:WaitForChild("Attachments").LightExplosion2:Clone()
	clone.PointLight.Range = 6 * scale
	clone.PointLight.Brightness = 5
	clone.Star.Rotation = NumberRange.new(v)
	clone.Star_Color.Rotation = NumberRange.new(v)
	clone.Parent = workspace.Terrain
	clone.CFrame = CFrame.new(position)
	clone.Explosion.Size = ScaleParticle(clone.Explosion, scale)
	clone.Star.Size = ScaleParticle(clone.Star, scale)
	clone.Star_Color.Size = ScaleParticle(clone.Star_Color, scale)
	clone.Explosion:Emit(scale > 4 and scale * 3 or 3)
	clone.Star:Emit(1)
	clone.Star_Color:Emit(1)
	TweenService:Create(clone.PointLight, TweenInfo.new(0.35), {
		Range = 0,
		Brightness = 0
	}):Play()
	Util.Debris:AddItem(clone, 1)
end