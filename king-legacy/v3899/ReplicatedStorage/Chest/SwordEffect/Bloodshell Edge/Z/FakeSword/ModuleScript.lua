game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	for _, part in pairs(script.Parent:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name == "Base" then
			part.Transparency = 0
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		else
			part.Transparency = 1
			TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 0
			}):Play()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function easeOutExpo(p)
		if p == 1 then
			return 1
		end

		return 1 - math.pow(2, -10 * p)
	end

	PeodizService.HeartbeatWait({
		Time = 0.5
	}, function(p)
		script.Parent:ScaleTo(1 + easeOutExpo(p) * 8)
	end)
	wait(0.4)
	PeodizService.HeartbeatWait({
		Time = 0.5
	}, function(p)
		script.Parent:ScaleTo(9 - easeOutExpo(p) * 8)
	end)
end