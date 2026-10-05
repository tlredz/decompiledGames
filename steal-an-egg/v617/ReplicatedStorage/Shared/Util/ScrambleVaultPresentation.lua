return table.freeze({
	CameraIn = 0.75,
	DoorStart = 0.5,
	DoorSeconds = 1.3,
	RevealAt = 1.8,
	DisplayScale = 0.35,
	FlyAt = 2.5,
	Duration = 4.2,
	Assets = function(instance)
		local door = instance:FindFirstChild("Door")
		local prompt = instance:FindFirstChild("Prompt")
		local batSpawn = instance:FindFirstChild("BatSpawn")

		if door and door:IsA("Model") and door:FindFirstChildWhichIsA("BasePart", true) and prompt and prompt:IsA("BasePart") and batSpawn and batSpawn:IsA("BasePart") then
			return door, prompt, batSpawn
		end

		return nil, nil, nil
	end,
	DoorPose = function(cframe: CFrame, value: number, value2: number?)
		local v = (type(value2) ~= "number" or value2 ~= value2) and 105 or math.clamp(value2, -170, 170)
		return CFrame.new(cframe.Position) * CFrame.Angles(0, math.rad(v) * math.clamp(value, 0, 1), 0) * cframe.Rotation
	end
})