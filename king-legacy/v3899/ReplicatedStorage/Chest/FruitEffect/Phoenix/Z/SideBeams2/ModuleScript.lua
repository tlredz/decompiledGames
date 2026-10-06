local replicatedStorage = game.ReplicatedStorage
local BoatTween = require(replicatedStorage.Chest.Modules:WaitForChild("BoatTween"))
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
return function()
	PeodizService.ForceForLoop({
		Step = 4,
		WaitTime = 0.03
	}, function(p)
		local v = math.floor(p * 4)
		local v2

		if v == 2 then
			v2 = 3
		elseif v == 3 then
			v2 = 2
		elseif v == 4 then
			v2 = 1
		else
			v2 = 4
		end

		local folder = script.Parent["Test" .. v2]
		local leftFar = folder.LeftFar
		local leftNear = folder.LeftNear
		local rightFar = folder.RightFar
		local rightNear = folder.RightNear
		local position = leftFar.Position
		local position2 = rightFar.Position
		leftFar.Position = leftNear.Position
		rightFar.Position = rightNear.Position
		game.TweenService:Create(leftFar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = position
		}):Play()
		game.TweenService:Create(rightFar, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = position2
		}):Play()

		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local width = beam.Width0 * 3
			local width2 = beam.Width1 * 3
			beam.Width0 = 0
			beam.Width1 = 0
			beam.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.25, 0.75),
				NumberSequenceKeypoint.new(1, 1)
			})
			game.TweenService:Create(beam, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Width0 = width,
				Width1 = width2
			}):Play()
			local v5 = beam
			task.spawn(function()
				wait(0.35)
				BoatTween:Create(v5, {
					Time = 0.55,
					EasingStyle = "Expo",
					EasingDirection = "Out",
					StepType = "Heartbeat",
					Goal = {
						Transparency = NumberSequence.new(1)
					}
				}):Play()
			end)
		end
	end)
end