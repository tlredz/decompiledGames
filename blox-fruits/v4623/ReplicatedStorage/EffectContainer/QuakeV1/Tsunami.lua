local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
return function(p)
	local tsunami = p.tsunami
	local clone = script.sphere:Clone()
	clone.Parent = workspace._WorldOrigin
	clone.CFrame = tsunami.CFrame
	clone.Size = tsunami.Size + createVector(20, 20, 20)
	clone.Material = tsunami.Material
	clone.Color = tsunami.Color
	clone.Transparency = 1
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		Transparency = 0
	}):Play()
	TweenService:Create(tsunami, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		Transparency = 1
	}):Play()
	local number = Random.new():NextNumber(3, 4)
	TweenService:Create(clone, TweenInfo.new(number, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		CFrame = tsunami.CFrame * CFrame.new(0, -tsunami.Size.Y / 2, 0),
		Size = createVector(1000, 10, 1000)
	}):Play()
	Util.Debris:AddItem(clone, number)
	task.delay(number / 2, function()
		TweenService:Create(clone, TweenInfo.new(number / 2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
	end)
end