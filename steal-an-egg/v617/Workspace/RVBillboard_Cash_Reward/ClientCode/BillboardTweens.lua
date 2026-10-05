local TweenService = game:GetService("TweenService")
local color = Color3.new(1, 1, 1)
return {
	new = function(data)
		local v = nil
		local v2 = nil
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local v6 = {
			frameScale = function(scale: number, duration: number)
				if not data.frameScale then
					return nil
				end

				if v then
					v:Cancel()
				end

				local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				v = TweenService:Create(data.frameScale, tweenInfo, {
					Scale = scale
				})
				v:Play()
				return v
			end,
			buttonScale = function(scale: number, duration: number)
				if not data.buttonScale then
					return nil
				end

				if v2 then
					v2:Cancel()
				end

				local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				v2 = TweenService:Create(data.buttonScale, tweenInfo, {
					Scale = scale
				})
				v2:Play()
				return v2
			end,
			stroke = function(color2: Color3, thickness: number)
				if not data.frameStroke then
					return
				end

				if v3 then
					v3:Cancel()
				end

				local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				v3 = TweenService:Create(data.frameStroke, tweenInfo, {
					Color = color2,
					Thickness = thickness
				})
				v3:Play()
			end
		}

		function v6.strokeHoverIn()
			v6.stroke(color, 10)
		end

		function v6.strokeHoverOut()
			v6.stroke(data.baseStrokeColor, data.baseStrokeThickness)
		end

		function v6.brightness(brightness: number, duration: number)
			if v4 then
				v4:Cancel()
			end

			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			v4 = TweenService:Create(data.surfaceGui, tweenInfo, {
				Brightness = brightness
			})
			v4:Play()
		end

		function v6.background(color2: Color3, duration: number)
			if not data.surface then
				return
			end

			if v5 then
				v5:Cancel()
			end

			local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			v5 = TweenService:Create(data.surface, tweenInfo, {
				BackgroundColor3 = color2
			})
			v5:Play()
		end

		function v6.hoverIn()
			v6.frameScale(1.03, 0.12)
			v6.buttonScale(1.15, 0.12)
			v6.strokeHoverIn()
			v6.brightness(1.25, 0.12)
			v6.background(data.bumpedBackground, 0.12)
		end

		function v6.resetHover()
			v6.frameScale(1, 0.12)
			v6.buttonScale(1, 0.12)
			v6.strokeHoverOut()
			v6.brightness(data.baseBrightness, 0.12)
			v6.background(data.baseBackground, 0.12)
		end

		local flag = false

		function v6.shakeIcon()
			if flag or #data.shakeTargets == 0 then
				return
			end

			flag = true

			for _, shakeTarget in data.shakeTargets do
				shakeTarget.instance.Rotation = shakeTarget.baseRotation
			end

			task.spawn(function()
				local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				for _, v7 in {
					4,
					-4,
					4,
					0
				} do
					local v8 = nil

					for _, shakeTarget in data.shakeTargets do
						v8 = TweenService:Create(shakeTarget.instance, tweenInfo, {
							Rotation = shakeTarget.baseRotation + v7
						})
						v8:Play()
					end

					if v8 then
						v8.Completed:Wait()
					end
				end

				for _, shakeTarget in data.shakeTargets do
					shakeTarget.instance.Rotation = shakeTarget.baseRotation
				end

				flag = false
			end)
		end

		return v6
	end
}