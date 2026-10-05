local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.15)
return {
	new = function(data, layoutOrder, p)
		local v = {
			Duration = data.Duration,
			Value = p,
			Labels = table.create(10),
			CanvasTweens = table.create(10)
		}
		local tweenInfo2 = TweenInfo.new(data.Duration)
		local frame = Instance.new("Frame")
		frame.Name = "digit"
		frame.LayoutOrder = layoutOrder
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(0, 0, 0, data.TextSize + 6)
		frame.ClipsDescendants = false
		local frame2 = Instance.new("Frame")
		frame2.Name = "canvas"
		frame2.Size = UDim2.new(1, 0, 10, 0)
		frame2.BackgroundTransparency = 1
		frame2.Parent = frame
		frame2.Position = UDim2.new(0, 0, -v.Value, 0)

		for i = 0, 9 do
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "n_" .. i
			textLabel.BackgroundTransparency = 1
			textLabel.TextSize = data.TextSize
			textLabel.TextColor3 = data.TextColor3
			textLabel.FontFace = data.FontFace
			textLabel.Text = i
			textLabel.Size = UDim2.new(1, 0, 0.1, 0)
			textLabel.Position = UDim2.new(0, 0, i * 0.1, 0)

			if data.UIStroke then
				local clone = data.UIStroke:Clone()
				clone.Parent = textLabel
			end

			textLabel.Parent = frame2
			v.Labels[i] = textLabel
			v.CanvasTweens[i] = TweenService:Create(frame2, tweenInfo2, {
				Position = UDim2.new(0, 0, -i, 0)
			})
		end

		frame.Parent = data.Frame
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSize(p2)
			task.spawn(function()
				getTextBoundsParams.Text = "8"
				getTextBoundsParams.Font = data.FontFace
				getTextBoundsParams.Size = data.TextSize
				getTextBoundsParams.Width = data.TextSize
				local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

				if success then
					local tween = TweenService:Create(frame, tweenInfo, {
						Size = UDim2.new(0, p2 and 0 or textBoundsAsync.X + 1, 0, textBoundsAsync.Y + 10)
					})
					tween.Completed:Connect(function()
						if p2 then
							frame:Destroy()
							table.clear(v)
						end

						tween:Destroy()
					end)
					tween:Play()
				end
			end)
		end

		local v2 = nil
		task.spawn(function()
			getTextBoundsParams.Text = "8"
			getTextBoundsParams.Font = data.FontFace
			getTextBoundsParams.Size = data.TextSize
			getTextBoundsParams.Width = data.TextSize
			local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

			if success then
				local tween = TweenService:Create(frame, tweenInfo, {
					Size = UDim2.new(0, v2 and 0 or textBoundsAsync.X + 1, 0, textBoundsAsync.Y + 10)
				})
				tween.Completed:Connect(function()
					if v2 then
						frame:Destroy()
						table.clear(v)
					end

					tween:Destroy()
				end)
				tween:Play()
			end
		end)
		local object = setmetatable({}, {
			__index = function(_, p2)
				local v3 = v[p2]

				if v3 then
					return v3
				end

				if pcall(function()
					local _ = v.Labels[1][p2]
				end) then
					return v.Labels[1][p2]
				end

				return nil
			end,
			__newindex = function(_, p2, p3)
				if v[p2] then
					v[p2] = p3
					v:Update(p2, p3)
				elseif pcall(function()
					local _ = v.Labels[1][p2]
				end) then
					v.Labels[0][p2] = p3
					v.Labels[1][p2] = p3
					v.Labels[2][p2] = p3
					v.Labels[3][p2] = p3
					v.Labels[4][p2] = p3
					v.Labels[5][p2] = p3
					v.Labels[6][p2] = p3
					v.Labels[7][p2] = p3
					v.Labels[8][p2] = p3
					v.Labels[9][p2] = p3
					v:Update(p2, p3)
				end
			end
		})

		function v:Destroy()
			updateSize(true) -- equivalent call inferred; original call site unknown
		end

		function v:Update(p2, duration)
			if p2 == "Duration" then
				tweenInfo2 = TweenInfo.new(duration)

				for i = 0, 9 do
					v.CanvasTweens[i] = TweenService:Create(frame2, tweenInfo2, {
						Position = UDim2.new(0, 0, -i, 0)
					})
				end
			elseif p2 == "Value" then
				v.CanvasTweens[duration]:Play()
			elseif p2 == "TextSize" or p2 == "FontFace" then
				updateSize(nil) -- equivalent call inferred; original call site unknown
			end
		end

		return object
	end
}