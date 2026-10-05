local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
return {
	mount = function(p)
		local v = nil
		local v2 = nil
		local count = 0
		local v3 = false
		local v4 = Vide.mount(function()
			return create("ScreenGui")({
				Name = "20YearsEventTransition",
				DisplayOrder = 29000,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ScreenInsets = Enum.ScreenInsets.None,
				ClipToDeviceSafeArea = false,
				create("Frame")({
					Name = "Fade",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Vide.action(function(p2)
						v = p2
					end)
				})
			})
		end, p)
		return {
			play = function()
				local v5 = v

				if v3 or not v5 then
					return
				end

				count += 1
				local v6 = count
				local v7 = v2

				if v7 then
					v7:Cancel()
				end

				local tween = TweenService:Create(v5, tweenInfo, {
					BackgroundTransparency = 0
				})
				v2 = tween
				tween:Play()
				task.delay(tweenInfo.Time + 0.1, function()
					if not v3 and v6 == count and v5.Parent then
						local tween2 = TweenService:Create(v5, tweenInfo2, {
							BackgroundTransparency = 1
						})
						v2 = tween2
						tween2:Play()
					end
				end)
			end,
			destroy = function()
				if not v3 then
					v3 = true
					count += 1
					local v5 = v2

					if v5 then
						v5:Cancel()
						v2 = nil
					end

					v4()
					v = nil
				end
			end
		}
	end
}