local createVector = vector.create
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
return function(data)
	local position = data.Root.Position
	local parent = data.Root.Parent

	if parent and parent:FindFirstChild("AntiMover") or position == nil or (currentCamera.CFrame.p - position).Magnitude > 900 then
		return
	end

	task.spawn(function()
		local root = data.Root
		local dashSpeed = data.DashSpeed
		root.Velocity = createVector(0, 0, 0)
		local orientation = data.Orientation or CFrame.new(data.CFrame.Position, data.EndPosition)
		local lastTime = os.clock()

		while os.clock() - lastTime < dashSpeed do
			local v = (os.clock() - lastTime) / dashSpeed
			root.CFrame = CFrame.new(data.CFrame.Position:Lerp(data.EndPosition, v)) * (orientation - orientation.p)
			RunService.PreSimulation:Wait()
		end

		root.CFrame = CFrame.new(data.CFrame.Position:Lerp(data.EndPosition, 1)) * (orientation - orientation.p)
	end)
end