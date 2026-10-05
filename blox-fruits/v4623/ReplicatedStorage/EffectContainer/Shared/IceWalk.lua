local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage.Util)
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
Util = Util.Sound
return function(data)
	local position = data.Position
	local clone = game.ReplicatedStorage.Assets.Models.IceSpikes4:Clone()

	if data.NonCollide then
		clone.CanCollide = false
	end

	clone.Size = Vector3.new(3 + math.random(10, 12), 1.7, 3 + math.random(10, 12))
	clone.Material = data.Material or clone.Material
	clone.Color = data.Color or clone.Color
	clone.CFrame = CFrame.new(position.X, not data.RespectHeight and -3.8 or position.Y or -3.8, position.Z) * CFrame.Angles(
		(math.random() - 0.5) * 0.06,
		math.random() * 7,
		(math.random() - 0.5) * 0.07
	)
	clone.Parent = workspace
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(data.Duration or 2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Size = createVector(0, 0.3, 0)
		}
	)
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end