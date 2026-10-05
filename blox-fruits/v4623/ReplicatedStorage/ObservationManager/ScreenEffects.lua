local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local tweens = {}
local count = 0
return {
	setActive = function(flag: boolean, flag2: boolean, flag3: boolean?)
		count += 1
		local v = count

		for _, v2 in tweens do
			v2:Cancel()
			v2:Destroy()
		end

		table.clear(tweens)

		local function update(postEffect, items)
			if not postEffect then
				return
			end

			if postEffect:IsA("PostEffect") then
				postEffect.Enabled = flag or not flag3
			end

			if flag3 then
				for k, item in items do
					postEffect[k] = item
				end
			else
				local tween = TweenService:Create(postEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quad), items)
				table.insert(tweens, tween)

				if not flag and postEffect:IsA("PostEffect") then
					tween.Completed:Once(function(p)
						if p == Enum.PlaybackState.Completed and count == v then
							postEffect.Enabled = false
						end
					end)
				end

				tween:Play()
			end
		end

		update(Lighting, {
			ExposureCompensation = flag and (flag2 and -0.5 or -1) or 0
		})
		update(Lighting:FindFirstChild("Blur"), {
			Size = flag and (flag2 and 1 or 7.5) or 0
		})
		local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
		local tintColor

		if flag then
			tintColor = Color3.fromRGB(125, 255, 255)
		else
			tintColor = Color3.new(1, 1, 1)
		end

		update(colorCorrection, {
			TintColor = tintColor
		})
	end
}