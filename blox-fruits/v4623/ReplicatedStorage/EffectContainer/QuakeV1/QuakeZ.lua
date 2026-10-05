local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local quakeEffects = FX:WaitForChild("QuakeEffects")
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
local debris = Util.Debris
local quakeRocks = require(game.ReplicatedStorage.EffectContainer.quakeRocks)
return function(p)
	local hrp = p.hrp
	local cFrame = hrp.CFrame
	local clone = quakeEffects.halfWindSphere:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Parent = workspace._WorldOrigin
	debris:AddItem(clone, 0.125)
	TweenService:Create(clone, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
		Size = createVector(35, 12.5, 35),
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.new(0, 10, 0)
	}):Play()

	for i = 1, 5 do
		task.delay(i / 10, function()
			local clone2 = quakeEffects.windCylinder:Clone()
			clone2.Transparency = 0.1
			clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 0, 0)
			clone2.Size = createVector(5, 15, 5)
			clone2.Parent = workspace._WorldOrigin
			debris:AddItem(clone2, 0.7)
			TweenService:Create(clone2, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {
				Size = createVector(67.5, 0, 67.5),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.new(0, -75, 0)
			}):Play()
		end)
	end

	task.spawn(quakeRocks, hrp, 8, -10, 60)
	task.spawn(quakeRocks, hrp, -8, 10, 60)
end