local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local opeOpe = game.ReplicatedStorage["Ope-Ope"]
require(game.ReplicatedStorage.Util.Debris)

local function Ring(cFrame, duration, p, p2, value)
	local clone = opeOpe.Effects.SpikyRing:Clone()
	clone.Color = p2 or clone.Color
	clone.Size = Vector3.new()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0),
		Size = Vector3.new(1, value or 0.3, 1) * 4 * p,
		Transparency = 1
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()
end

return function(list)
	Ring(unpack(list))
end