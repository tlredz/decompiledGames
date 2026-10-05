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

		function v:Reset()
			v2 = false
			v.Container:TweenSize(UDim2.new(1, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.2, true)
			v.Container.Shadow:TweenSize(
				UDim2.new(1, v.shadowSize * 2, 1, v.shadowSize * 3),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Back,
				0.2,
				true
			)
		end

		function v.Press(_)
			if not v3 then
				return
			end

			v2 = true
			v.Container:TweenSize(
				UDim2.new(0.95, 0, 0.95, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.05,
				true
			)
			v.Container.Shadow:TweenSize(
				UDim2.new(1, v.shadowSize * 2, 1, v.shadowSize * 2),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.05,
				true
			)
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