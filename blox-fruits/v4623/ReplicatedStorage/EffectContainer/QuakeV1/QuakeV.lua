local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local quakeEffects = FX:WaitForChild("QuakeEffects")
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local debris = Util.Debris
return function(p)
	local clone = quakeEffects.halfWindSphere:Clone()
	clone.Parent = workspace._WorldOrigin
	clone.CFrame = p.hrp.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
	TweenService:Create(clone, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
		Size = createVector(35, 12.5, 35),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.new(0, 10, 0)
	}):Play()
	debris:AddItem(clone, 0.125)
	local clone2 = quakeEffects.windCylinder:Clone()
	clone2.Parent = workspace._WorldOrigin
	clone2.CFrame = p.hrp.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0)
	clone2.Size = createVector(5, 25, 5)
	debris:AddItem(clone2, 0.25)
	TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		Size = createVector(35, 0, 35),
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.new(0, -10, 0)
	}):Play()
end