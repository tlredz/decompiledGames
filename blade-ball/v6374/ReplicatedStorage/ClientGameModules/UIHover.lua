local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
local v = {}

local function getUIScale(parent)
	local v2 = parent:FindFirstChildWhichIsA("UIScale")

	if not v2 then
		v2 = Instance.new("UIScale")
		v2.Parent = parent
	end

	return assert(v2)
end

local function animateUIScale(p, scale: number)
	local v2 = v[p]

	if v2 then
		v2:Cancel()
		v[p] = nil
	end

	local tween = TweenService:Create(p, tweenInfo, {
		Scale = scale
	})
	tween.Completed:Once(function()
		v[p] = nil
		tween:Destroy()
	end)
	tween:Play()
end

return table.freeze({
	Enter = function(parent)
		if not parent then
			ReplicatedStorage.Misc.smallclick:Play()
			return
		end

		local hoverScale = tonumber(parent:GetAttribute("HoverScale")) or 1.1
		local v3 = parent:FindFirstChildWhichIsA("UIScale")

		if not v3 then
			v3 = Instance.new("UIScale")
			v3.Parent = parent
		end

		animateUIScale(assert(v3), hoverScale)
		ReplicatedStorage.Misc.smallclick:Play()
	end,
	Exit = function(parent)
		local v3 = parent:FindFirstChildWhichIsA("UIScale")

		if not v3 then
			v3 = Instance.new("UIScale")
			v3.Parent = parent
		end

		animateUIScale(assert(v3), 1)
	end
})