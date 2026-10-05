local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shake = require(ReplicatedStorage.Packages.Shake)
local ShakePresets = {
	Bump = Shake.new()
}
ShakePresets.Bump.Amplitude = 2.5
ShakePresets.Bump.Frequency = 0.25
ShakePresets.Bump.FadeInTime = 0.1
ShakePresets.Bump.FadeOutTime = 0.75
ShakePresets.Bump.PositionInfluence = createVector(0.15, 0.15, 0.15)
ShakePresets.Bump.RotationInfluence = createVector(1, 1, 1)
ShakePresets.BumpS = Shake.new()
ShakePresets.BumpS.Amplitude = 1.5
ShakePresets.BumpS.Frequency = 0.25
ShakePresets.BumpS.FadeInTime = 0.1
ShakePresets.BumpS.FadeOutTime = 0.75
ShakePresets.BumpS.PositionInfluence = createVector(0.15, 0.15, 0.15)
ShakePresets.BumpS.RotationInfluence = createVector(1, 1, 1)
ShakePresets.Explosion = Shake.new()
ShakePresets.Explosion.Amplitude = 5
ShakePresets.Explosion.Frequency = 0.1
ShakePresets.Explosion.FadeInTime = 0
ShakePresets.Explosion.FadeOutTime = 1.5
ShakePresets.Explosion.PositionInfluence = createVector(0.25, 0.25, 0.25)
ShakePresets.Explosion.RotationInfluence = createVector(4, 1, 1)
ShakePresets.Earthquake = Shake.new()
ShakePresets.Earthquake.Amplitude = 0.6
ShakePresets.Earthquake.Frequency = 0.2857142857142857
ShakePresets.Earthquake.FadeInTime = 2
ShakePresets.Earthquake.FadeOutTime = 10
ShakePresets.Earthquake.PositionInfluence = createVector(0.25, 0.25, 0.25)
ShakePresets.Earthquake.RotationInfluence = createVector(1, 1, 4)
ShakePresets.BadTrip = Shake.new()
ShakePresets.BadTrip.Amplitude = 10
ShakePresets.BadTrip.Frequency = 6.666666666666667
ShakePresets.BadTrip.FadeInTime = 5
ShakePresets.BadTrip.FadeOutTime = 10
ShakePresets.BadTrip.PositionInfluence = createVector(0, 0, 0.15)
ShakePresets.BadTrip.RotationInfluence = createVector(2, 1, 4)
ShakePresets.HandheldCamera = Shake.new()
ShakePresets.HandheldCamera.Amplitude = 1
ShakePresets.HandheldCamera.Frequency = 0.25
ShakePresets.HandheldCamera.FadeInTime = 5
ShakePresets.HandheldCamera.FadeOutTime = 10
ShakePresets.HandheldCamera.PositionInfluence = createVector(0, 0, 0)
ShakePresets.HandheldCamera.RotationInfluence = createVector(1, 0.5, 0.5)
ShakePresets.Vibration = Shake.new()
ShakePresets.Vibration.Amplitude = 0.4
ShakePresets.Vibration.Frequency = 0.05
ShakePresets.Vibration.FadeInTime = 2
ShakePresets.Vibration.FadeOutTime = 2
ShakePresets.Vibration.PositionInfluence = createVector(0, 0.15, 0)
ShakePresets.Vibration.RotationInfluence = createVector(1.25, 0, 4)
ShakePresets.RoughDriving = Shake.new()
ShakePresets.RoughDriving.Amplitude = 1
ShakePresets.RoughDriving.Frequency = 0.5
ShakePresets.RoughDriving.FadeInTime = 1
ShakePresets.RoughDriving.FadeOutTime = 1
ShakePresets.RoughDriving.PositionInfluence = createVector(0, 0, 0)
ShakePresets.RoughDriving.RotationInfluence = createVector(1, 1, 1)

function ShakePresets.BindShakeToCamera(instance, p)
	local v = p or workspace.CurrentCamera
	assert(v, "camera not found")
	local cFrame = nil
	local postSimulationConnection = nil
	local v2 = true
	instance:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(position, data, p2)
		cFrame = v.CFrame
		v.CFrame *= CFrame.new(position) * CFrame.Angles(0, math.rad(data.Y), 0) * CFrame.Angles(
			math.rad(data.X),
			0,
			(math.rad(data.Z))
		)

		if p2 then
			v2 = nil

			if postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
			end
		end
	end)

	if v2 == true then
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			debug.profilebegin("ShakePresets:UpdateCameraCFrame")

			if cFrame then
				v.CFrame = cFrame
			end

			debug.profileend()
		end)
	end

	return function()
		if postSimulationConnection then
			postSimulationConnection:Disconnect()
			postSimulationConnection = nil
		end

		instance:Destroy()
	end
end

return ShakePresets