local TweenService = game:GetService("TweenService")
return {
	new = function(instance, instance2)
		local v = {}
		local v2 = instance2:WaitForChild("动效缩放")
		local parent = instance.Parent
		local frame

		if parent and parent:FindFirstChildOfClass("UIListLayout") then
			frame = Instance.new("Frame")
			frame.Name = instance.Name .. "动效容器"
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = instance.Size
			frame.Position = instance.Position
			frame.AnchorPoint = instance.AnchorPoint
			frame.LayoutOrder = instance.LayoutOrder
			frame.ClipsDescendants = false
			frame.Visible = false
			frame.Parent = parent
			instance.Parent = frame
			instance.Size = UDim2.fromScale(1, 1)
			instance.Position = UDim2.fromScale(instance.AnchorPoint.X, instance.AnchorPoint.Y)
		else
			frame = nil
		end

		local position = instance.Position

		local function hiddenPosition()
			local screenGui = instance:FindFirstAncestorOfClass("ScreenGui")
			local v3 = not screenGui and 1080 or screenGui.AbsoluteSize.Y
			local v4 = not (instance.Parent and instance.Parent:IsA("GuiObject")) and 0 or instance.Parent.AbsoluteSize.Y
			local v5

			if v4 > 0 then
				local v7

				if frame then
					v7 = frame.AbsolutePosition.Y
				else
					v7 = instance.AbsolutePosition.Y
				end

				v5 = (math.max(0, v3 - v7) + instance.AbsoluteSize.Y + 32) / v4
			else
				v5 = 3
			end

			return position + UDim2.fromScale(0, v5)
		end

		local position2 = hiddenPosition()
		local v4 = nil
		local v5 = nil
		local count = 0
		local v6 = false
		local v7 = false
		local v8 = false
		local v9 = false
		instance.Visible = false
		instance.Position = position2
		instance2.AutoButtonColor = false

		local function updateFeedback()
			if v5 then
				v5:Cancel()
			end

			local scale = v7 and (v9 and 0.94 or v8 and 1.045 or 1) or 1
			v5 = TweenService:Create(v2, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Scale = scale
			})
			v5:Play()
		end

		function v.SetEnabled(_, p)
			v7 = p
			instance2.Active = p
			instance2.Selectable = p

			if not p then
				v9 = false
				v8 = false
			end

			updateFeedback()
		end

		function v.SetVisible(_, p)
			if v6 == p then
				return
			end

			v6 = p
			count += 1
			local v10 = count

			if v4 then
				v4:Cancel()
			end

			if frame then
				frame.Visible = true
			end

			instance.Visible = true
			position2 = hiddenPosition()
			local v14

			if p then
				v14 = Enum.EasingStyle.Back
			else
				v14 = Enum.EasingStyle.Quad
			end

			local tweenInfo = TweenInfo.new(p and 0.34 or 0.28, v14, Enum.EasingDirection.Out)
			local position3

			if p then
				position3 = position
			else
				position3 = position2
			end

			v4 = TweenService:Create(instance, tweenInfo, {
				Position = position3
			})

			if not p then
				v4.Completed:Once(function(p2)
					if p2 == Enum.PlaybackState.Completed and count == v10 and not v6 then
						instance.Visible = false

						if frame then
							frame.Visible = false
						end
					end
				end)
			end

			v4:Play()
		end

		instance2.MouseEnter:Connect(function()
			v8 = true
			updateFeedback()
		end)
		instance2.MouseLeave:Connect(function()
			v8 = false
			v9 = false
			updateFeedback()
		end)
		instance2.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v9 = true
				updateFeedback()
			end
		end)
		instance2.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v9 = false
				updateFeedback()
			end
		end)
		return v
	end
}