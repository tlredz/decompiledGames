game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local TikiMask = {
	Morph = function(p, _, object)
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local progressBoost = p.config.ProgressBoost or 15
		local flashColor = p.config.FlashColor or Color3.fromRGB(255, 140, 0)
		local clone = script.TikiMask:Clone()
		clone.Parent = reel_bar
		local eyes = clone:FindFirstChild("Eyes") or clone:FindFirstChild("Icon") or clone
		local v = eyes:IsA("ImageLabel") or eyes:IsA("ImageButton")
		local v2 = v and "ImageColor3" or "BackgroundColor3"
		local v3 = v and "ImageTransparency" or "BackgroundTransparency"
		local eye = eyes[v2]
		local eye2 = eyes[v3]
		local v4 = false
		p.reelTrove:Add(object.OnLogicStep:Connect(function()
			if not object.active then
				return
			end

			local v5 = math.max(reel_bar.AbsoluteSize.X, 1)
			local v6 = (clone.AbsolutePosition.X + clone.AbsoluteSize.X * 0.5 - reel_bar.AbsolutePosition.X) / v5
			local v7 = clone.AbsoluteSize.X / v5 * 0.5 >= math.abs(object.fishPosition - v6)

			if v7 and not v4 then
				object:AddProgress(progressBoost)
				object.fx:SpawnShake(object.reel_bar, 0.25, 2, 0.01, true)
				eyes[v2] = flashColor
				eyes[v3] = 0
				TweenService:Create(eyes, TweenInfo.new(0.45), {
					[v2] = eye,
					[v3] = eye2
				}):Play()
			end

			v4 = v7
		end))
	end
}
setmetatable(TikiMask, module)
return TikiMask