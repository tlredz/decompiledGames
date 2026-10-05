local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local module = require("./PassiveHandler")
local world = ReplicatedStorage:WaitForChild("world")
local Dreambreaker = {
	Morph = function(p, _, object)
		local _ = world:WaitForChild("cycle").Value
		task.spawn(function()
			object:WaitUntilReady()
			object:GetRandom(5)
			local over = game.Players.LocalPlayer.PlayerGui:FindFirstChild("over")
			local clone = script.Darkness:Clone()
			clone.Name = "Darkness1"
			clone.Parent = over
			local clone2 = script.Darkness:Clone()
			clone2.Name = "Darkness2"
			clone2.Parent = over
			p.reelTrove:Add(clone)
			p.reelTrove:Add(clone2)
			clone2.AnchorPoint = Vector2.new(0.5, 0)
			clone2.Position = UDim2.fromScale(0.5, 0)
			clone2.UIGradient.Rotation = -90
			object.OnMinigameEnd:Connect(function()
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				TweenService:Create(clone, tweenInfo, {
					Size = UDim2.fromScale(1, 0)
				}):Play()
				TweenService:Create(clone2, tweenInfo, {
					Size = UDim2.fromScale(1, 0)
				}):Play()
			end)
			local modifier = object:CreateModifier("accel", "multiply")
			p.reelTrove:Add(object.OnLogicStep:Connect(function(_)
				if not object.active then
					return
				end

				modifier.Value = math.clamp(1 + (20 - object.progress) / 20, -1, 1)
				clone.Size = UDim2.fromScale(1, (object.progress - 20) / 100 / 2)
				clone2.Size = clone.Size
			end))
		end)
	end
}
setmetatable(Dreambreaker, module)
return Dreambreaker