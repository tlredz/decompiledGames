local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local quakeEffects = FX:WaitForChild("QuakeEffects")
local debris = Util.Debris
return function(p)
	local clone = quakeEffects.windCylinder:Clone()
	clone.CFrame = p.obj.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Size = createVector(7.5, 18.75, 7.5)
	clone.Transparency = 0.25
	debris:AddItem(clone, 0.75)
	TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
		Size = createVector(82.5, 0, 82.5),
		Transparency = 1,
		CFrame = p.obj.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 20, 0)
	}):Play()
	clone.Parent = workspace._WorldOrigin
end