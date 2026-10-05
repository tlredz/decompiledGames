local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shake = require(ReplicatedStorage.Packages.Shake)
local ShakePresets = {}

for _, v in {
	{
		"Bump",
		2.5,
		0.25,
		0.1,
		0.75,
		createVector(0.15, 0.15, 0.15),
		createVector(1, 1, 1)
	},
	{
		"BumpS",
		1.5,
		0.25,
		0.1,
		0.75,
		createVector(0.15, 0.15, 0.15),
		createVector(1, 1, 1)
	},
	{
		"Explosion",
		5,
		0.1,
		0,
		1.5,
		createVector(0.25, 0.25, 0.25),
		createVector(4, 1, 1)
	},
	{
		"Earthquake",
		0.6,
		0.2857142857142857,
		2,
		10,
		createVector(0.25, 0.25, 0.25),
		createVector(1, 1, 4)
	},
	{
		"BadTrip",
		10,
		6.666666666666667,
		5,
		10,
		createVector(0, 0, 0.15),
		createVector(2, 1, 4)
	},
	{
		"HandheldCamera",
		1,
		0.25,
		5,
		10,
		createVector(0, 0, 0),
		createVector(1, 0.5, 0.5)
	},
	{
		"Vibration",
		0.4,
		0.05,
		2,
		2,
		createVector(0, 0.15, 0),
		createVector(1.25, 0, 4)
	},
	{
		"RoughDriving",
		1,
		0.5,
		1,
		1,
		createVector(0, 0, 0),
		createVector(1, 1, 1)
	}
} do
	local v2 = Shake.new()
	v2.Amplitude = v[2]
	v2.Frequency = v[3]
	v2.FadeInTime = v[4]
	v2.FadeOutTime = v[5]
	v2.PositionInfluence = v[6]
	v2.RotationInfluence = v[7]
	ShakePresets[v[1]] = v2
end

function ShakePresets.DriveCamera(instance, p)
	local v = p or workspace.CurrentCamera
	assert(v, "no camera to attach a shake to")
	local cFrame = nil
	local postSimulationConnection = nil
	local flag = true
	instance:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(position, data, p2)
		cFrame = v.CFrame
		v.CFrame *= CFrame.new(position) * CFrame.Angles(0, math.rad(data.Y), 0) * CFrame.Angles(
			math.rad(data.X),
			0,
			(math.rad(data.Z))
		)

		if p2 then
			flag = false

			if postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
			end
		end
	end)

	if flag then
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			if cFrame then
				v.CFrame = cFrame
			end
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