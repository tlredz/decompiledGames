local createVector = vector.create
game:GetService("TweenService")
game:GetService("ReplicatedStorage")
return function(list)
	local _, v, v2, _ = unpack(list)
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.p).Magnitude > 1000
	end)

	if success then
		if result then
			return
		end

		local rootPart = v2.RootPart
		local baseSize = v2.BaseSize
		local clone = v2.Object:Clone()
		clone.Bot.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
		clone.Top.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
		clone.Bot.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.144, 0.252 * baseSize),
			NumberSequenceKeypoint.new(0.352, 1.76 * baseSize, 0.535 * baseSize),
			NumberSequenceKeypoint.new(0.836, 0.126 * baseSize),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Top.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.144, 0.252 * baseSize),
			NumberSequenceKeypoint.new(0.361, 4.47 * baseSize, 0.535 * baseSize),
			NumberSequenceKeypoint.new(0.836, 0.126 * baseSize),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Bot.Speed = NumberRange.new(20 * baseSize, 50 * baseSize)
		clone.Top.Speed = NumberRange.new(5 * baseSize, 20 * baseSize)
		clone.Bot.Acceleration = Vector3.new(0, 475 * baseSize, 0)
		clone.Top.Acceleration = Vector3.new(0, 375 * baseSize, 0)
		clone.Bot.Rate = 200
		clone.Top.Rate = 50
		clone.Position = createVector(0, -3, 0)
		clone.Parent = rootPart
		clone.Bot.Enabled = true
		clone.Top.Enabled = true
		spawn(function()
			wait(3)
			clone.Bot.Enabled = false
			clone.Top.Enabled = false
		end)
		_G.PU:Dust(clone, 5)
	end
end