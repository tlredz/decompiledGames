local createVector = vector.create
require(game.ReplicatedStorage.Util)
return function(list)
	local v = list[1]
	local TweenService = game:GetService("TweenService")
	TweenService:Create(v.HumanoidRootPart, TweenInfo.new(1.2), {
		CFrame = v.HumanoidRootPart.CFrame - createVector(0, 190, 0)
	}):Play()
end