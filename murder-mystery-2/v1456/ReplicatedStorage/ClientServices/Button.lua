local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
return {
	createButton = function(frame, p2, callback)
		local v = {
			Frame = frame,
			Container = frame.Container
		}
		v.shadowSize = math.abs(v.Container.Shadow.Position.X.Offset)
		v.clickStart = callback or function() end
		v.clickEnd = p2 or function() end
		local v2 = false
		local v3 = true
		local position = v.Container.Position
		local position2 = v.Container.Shadow.Position

		function v:Reset()
			v2 = false
			TweenService:Create(v.Container, tweenInfo, {
				Size = UDim2.fromScale(1, 1),
				Position = position
			}):Play()
			TweenService:Create(v.Container.Shadow, tweenInfo, {
				Size = UDim2.new(1, v.shadowSize * 2, 1, v.shadowSize * 3),
				Position = position2
			}):Play()
		end

		function v.Press(_)
			if not v3 then
				return
			end

			v2 = true
			TweenService:Create(v.Container, tweenInfo, {
				Size = UDim2.fromScale(0.95, 0.95),
				Position = v.Container.Position + UDim2.new(0, 0, 0, 2)
			}):Play()
			TweenService:Create(v.Container.Shadow, tweenInfo, {
				Size = UDim2.new(1, v.shadowSize * 2, 1, v.shadowSize * 2),
				Position = v.Container.Shadow.Position
			}):Play()
		end

		function v.Disable(_)
			v3 = false
			v.Container.Background.Visible = false
		end

		function v.Enable(_)
			v3 = true
			v.Container.Background.Visible = true
		end

		function v.GetEnabled(_)
			return v3
		end

		function v.Clicked(_)
			if not (v2 and v3) then
				v:Reset()
				return
			end

			v:Reset()
			v.clickStart()
			task.wait(0.025)
			v.clickEnd()
		end

		v.Frame.Button.MouseButton1Down:Connect(v.Press)
		v.Frame.Button.MouseButton1Up:Connect(v.Clicked)
		v.Frame.MouseLeave:Connect(v.Reset)
		return v
	end
}