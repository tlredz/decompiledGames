local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local FX = require(game.ReplicatedStorage.FX)
local quakeEffects = FX:WaitForChild("QuakeEffects")
return function(p)
	local clone = quakeEffects.windCylinder:Clone()
	clone.Parent = workspace._WorldOrigin
	clone.CFrame = p.hrp.CFrame * CFrame.new(0, 6, 0)
	clone.Size = createVector(5, 12.5, 5)
	clone.Transparency = 0.5
	debris:AddItem(clone, 0.5)
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(100, 0, 100),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.new(0, -9, 0)
	}):Play()

	local function effect(p2, p3)
		local clone2 = quakeEffects.halfWindSphere:Clone()
		clone2.Parent = workspace._WorldOrigin
		clone2.CFrame = p.hrp.CFrame * CFrame.new(p2, 0, 0) * CFrame.Angles(0, 0, (math.rad(p3)))
		debris:AddItem(clone2, 0.125)
		TweenService:Create(clone2, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
			Size = createVector(35, 12.5, 35),
			Transparency = 1,
			CFrame = clone2.CFrame * CFrame.new(0, 25, 0)
		}):Play()
	end

	effect(10, 90)
	effect(-10, -90)
end