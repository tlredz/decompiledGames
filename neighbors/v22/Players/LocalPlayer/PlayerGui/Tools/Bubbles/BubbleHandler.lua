local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local _ = game.Players.LocalPlayer
local Network = require(game.ReplicatedStorage.Modules.Network)
local spitBlur = game.Lighting:FindFirstChild("SpitBlur") or Instance.new("BlurEffect", game.Lighting)
spitBlur.Name = "SplashBlur"
spitBlur.Size = 0
spitBlur.Enabled = true

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function splashEffect()
	local clone = script.BubbleSplash:Clone()
	clone.ImageTransparency = 0.3
	clone.Parent = script.Parent
	local tween = TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
end

Network:listen("BubbleSplash", function()
	splashEffect()
end)
local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(p)
	local v = spitBlur
	local size = spitBlur.Size
	local v2 = p * 15
	v.Size = size + (3 - size) * v2
end)