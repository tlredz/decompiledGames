local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local hand = p.Hand
	local holding = p.Holding

	if not (hand and holding and holding.Value) then
		return
	end

	local clone = script.Umbrella:Clone()
	local v = Util.Sound:Play("WindBlowing", hand)
	local weld = Instance.new("Weld")
	weld.Part0 = clone.Handle
	weld.Part1 = hand
	weld.C0 = CFrame.Angles(3.141592653589793, 0, 0)
	weld.Parent = clone
	clone.Parent = hand.Parent
	local count = 0

	while wait(0.1) and holding:IsDescendantOf(workspace) and holding.Value do
		count += 1

		if count % 2 ~= 0 then
			continue
		end

		local clone2 = script.ThinRing:Clone()
		clone2.Size *= 0.6
		clone2.CFrame = CFrame.new(hand.Position)
		clone2.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
			Size = createVector(20, 0, 20),
			Transparency = 1,
			CFrame = clone2.CFrame + createVector(0, 7, 0)
		})
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()
	end

	clone:Destroy()
	Util.Sound:FadeOut(v, 0.2)
end