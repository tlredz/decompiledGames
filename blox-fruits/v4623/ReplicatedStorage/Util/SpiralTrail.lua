local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = require(game.ReplicatedStorage.Util.Debris)
local CreateTrail = require(script.CreateTrail)
local resume = coroutine.resume
local create = coroutine.create
return function(cFrame, data)
	local frequency = data.Frequency or 1e999
	local renderSteppedConnection = nil
	resume(create(function()
		for _ = 1, frequency do
			local v = 0
			local radius = data.Radius or 2
			local lifetime = data.Lifetime or 1e999
			local time = data.Time or 0.45
			local offset = data.Offset or 0.05
			local isReversed = data.IsReversed or false
			local size = data.Size or 0.275
			local color = data.Color or Color3.fromRGB(255, 255, 255)
			local transparency = data.Transparency or 0
			local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.CFrame = cFrame
			part.Size = createVector(1, 1, 1)
			part.Transparency = 1
			part.Parent = workspace._WorldOrigin

			if isReversed then
				TweenService:Create(part, tweenInfo, {
					Orientation = part.Orientation - createVector(0, 360, 0)
				}):Play()
			else
				TweenService:Create(part, tweenInfo, {
					Orientation = part.Orientation + createVector(0, 360, 0)
				}):Play()
			end

			local part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.CFrame = cFrame
			part2.Size = createVector(1, 1, 1)
			part2.Transparency = 1
			part2.Parent = workspace._WorldOrigin
			local trail = CreateTrail(part2, size, color, transparency)
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				v = (v + dt / lifetime) % 1
				local v8 = 6.283185307179586 * v
				part.CFrame *= CFrame.new(0, offset, 0)
				part2.CFrame = part.CFrame * CFrame.Angles(0, v8, 0) * CFrame.new(0, 0, radius)
			end)
			task.wait(1.35)
			trail.Enabled = false
			Debris:AddItem(part, 1)
			Debris:AddItem(part2, 1)
		end

		renderSteppedConnection:Disconnect()
	end))
end