script.Parent:WaitForChild("safezone")
local currentCamera = workspace.CurrentCamera

local function ReScale(instance)
	if instance:FindFirstChildWhichIsA("UIScale") then
		local viewportSize = currentCamera.ViewportSize
		local X = viewportSize.X

		if viewportSize.Y < X then
			X = viewportSize.Y
		end

		local uIScale = instance:FindFirstChildWhichIsA("UIScale")
		uIScale.Scale = math.clamp(X / instance.Size.X.Offset * 0.9, 0.8, 1.1)
	end
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function impact(safezone, position: UDim2, p: number, duration: number, flag: boolean, value: number)
	local v = 0.8

	for _ = 0, p, duration do
		safezone.Position = position:Lerp(
			position + UDim2.new(Random.new():NextNumber(-0.05, 0.05), 0, Random.new():NextNumber(-0.08, 0.08), 0),
			v
		)

		if flag then
			safezone.Rotation = 0 + (Random.new():NextNumber(-8, 8) - 0) * v
		end

		v *= value or 0.9
		task.wait(duration)
	end

	safezone.Position = position
	safezone.Rotation = flag and 0 or safezone.Rotation
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("events"):WaitForChild("shakehudeffect").OnClientEvent:Connect(function(...)
	impact(script.Parent:WaitForChild("safezone"), script.Parent:WaitForChild("safezone").Position, ...)
end)