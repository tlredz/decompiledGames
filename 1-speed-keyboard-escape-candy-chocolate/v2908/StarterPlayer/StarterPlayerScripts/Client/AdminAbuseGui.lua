local Players = game:GetService("Players")
local color = Color3.fromRGB(24, 24, 26)
local color2 = Color3.fromRGB(38, 38, 42)
local color3 = Color3.fromRGB(48, 48, 54)
local color4 = Color3.fromRGB(210, 255, 80)
local color5 = Color3.fromRGB(235, 235, 238)
local color6 = Color3.fromRGB(120, 120, 128)
local color7 = Color3.fromRGB(190, 45, 55)
local color8 = Color3.fromRGB(80, 200, 120)
local robotoMono = Enum.Font.RobotoMono

-- equivalent calls inferred from this helper; original call sites unknown
local function formatMinutesLabel(maxDurationSeconds: number)
	local v = maxDurationSeconds / 60

	if v == math.floor(v) then
		return string.format("%d min", (math.floor(v)))
	end

	return string.format("%.1f min", v)
end

local function makeRow(moduleMeta, layoutOrder: number)
	local textButton = Instance.new("TextButton")
	textButton.Name = moduleMeta.name
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = color2
	textButton.BorderSizePixel = 0
	textButton.Size = UDim2.new(1, 0, 0, 40)
	textButton.LayoutOrder = layoutOrder
	textButton.Font = robotoMono
	textButton.Text = "  " .. (moduleMeta.displayName or moduleMeta.name)
	textButton.TextColor3 = color5
	textButton.TextSize = 15
	textButton.TextXAlignment = Enum.TextXAlignment.Left
	textButton.ZIndex = 2
	textButton.MouseEnter:Connect(function()
		textButton.BackgroundColor3 = color3
	end)
	textButton.MouseLeave:Connect(function()
		textButton.BackgroundColor3 = color2
	end)
	return textButton
end

local AdminAbuseGui = {
	mount = function(parent, current2)
		local v = {
			current = current2
		}
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "AdminAbuseEvent"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.DisplayOrder = 100
		screenGui.Enabled = false
		screenGui.Parent = parent
		local textButton = Instance.new("TextButton")
		textButton.Name = "Backdrop"
		textButton.AutoButtonColor = false
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.BackgroundColor3 = Color3.new(0, 0, 0)
		textButton.BackgroundTransparency = 0.45
		textButton.BorderSizePixel = 0
		textButton.Text = ""
		textButton.ZIndex = 1
		textButton.Parent = screenGui
		local frame = Instance.new("Frame")
		frame.Name = "Root"
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.fromOffset(360, 420)
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		frame.ZIndex = 2
		frame.Parent = screenGui
		local frame2 = Instance.new("Frame")
		frame2.Name = "Stripe"
		frame2.BackgroundColor3 = color4
		frame2.BorderSizePixel = 0
		frame2.Position = UDim2.new(0, 0, 0, 0)
		frame2.Size = UDim2.new(0, 4, 1, 0)
		frame2.ZIndex = 3
		frame2.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Title"
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.new(0, 16, 0, 14)
		textLabel.Size = UDim2.new(1, -24, 0, 22)
		textLabel.Font = robotoMono
		textLabel.Text = "admin_abuse"
		textLabel.TextColor3 = color4
		textLabel.TextSize = 17
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.ZIndex = 3
		textLabel.Parent = frame
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Hint"
		textLabel2.BackgroundTransparency = 1
		textLabel2.Position = UDim2.new(0, 16, 0, 36)
		textLabel2.Size = UDim2.new(1, -24, 0, 16)
		textLabel2.Font = robotoMono
		textLabel2.Text = "modules/"
		textLabel2.TextColor3 = color6
		textLabel2.TextSize = 12
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.ZIndex = 3
		textLabel2.Parent = frame
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = "Actions"
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.Position = UDim2.new(0, 12, 0, 64)
		scrollingFrame.Size = UDim2.new(1, -24, 1, -120)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scrollingFrame.ScrollBarThickness = 6
		scrollingFrame.ScrollBarImageColor3 = color6
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		scrollingFrame.ZIndex = 2
		scrollingFrame.Parent = frame
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Padding = UDim.new(0, 2)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = scrollingFrame
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingBottom = UDim.new(0, 4)
		uIPadding.PaddingTop = UDim.new(0, 2)
		uIPadding.Parent = scrollingFrame
		local frame3 = Instance.new("Frame")
		frame3.Name = "Footer"
		frame3.BackgroundTransparency = 1
		frame3.AnchorPoint = Vector2.new(0, 1)
		frame3.Position = UDim2.new(0, 0, 1, 0)
		frame3.Size = UDim2.new(1, 0, 0, 52)
		frame3.ZIndex = 3
		frame3.Parent = frame
		local textButton2 = Instance.new("TextButton")
		textButton2.Name = "Stop"
		textButton2.AutoButtonColor = false
		textButton2.AnchorPoint = Vector2.new(0, 1)
		textButton2.Position = UDim2.new(0, 12, 1, -12)
		textButton2.Size = UDim2.new(0.28, -8, 0, 36)
		textButton2.BackgroundColor3 = color7
		textButton2.BorderSizePixel = 0
		textButton2.Font = robotoMono
		textButton2.Text = "stop"
		textButton2.TextColor3 = color5
		textButton2.TextSize = 14
		textButton2.ZIndex = 3
		textButton2.Parent = frame3
		local fn
		local onMouseButton1Click
		textButton2.MouseButton1Click:Connect(function()
			fn()
		end)
		local textButton3 = Instance.new("TextButton")
		textButton3.Name = "Close"
		textButton3.AutoButtonColor = false
		textButton3.AnchorPoint = Vector2.new(1, 1)
		textButton3.Position = UDim2.new(1, -12, 1, -12)
		textButton3.Size = UDim2.new(0.3, -8, 0, 36)
		textButton3.BackgroundColor3 = color2
		textButton3.BorderSizePixel = 0
		textButton3.Font = robotoMono
		textButton3.Text = "close"
		textButton3.TextColor3 = color5
		textButton3.TextSize = 14
		textButton3.ZIndex = 3
		textButton3.Parent = frame3
		local frame4 = Instance.new("Frame")
		frame4.Name = "DurationPrompt"
		frame4.BackgroundColor3 = color
		frame4.BorderSizePixel = 0
		frame4.Size = UDim2.new(1, 0, 1, 0)
		frame4.Position = UDim2.new(0, 0, 0, 0)
		frame4.Visible = false
		frame4.ZIndex = 5
		frame4.Parent = frame
		local frame5 = Instance.new("Frame")
		frame5.BackgroundColor3 = color4
		frame5.BorderSizePixel = 0
		frame5.Size = UDim2.new(0, 4, 1, 0)
		frame5.ZIndex = 6
		frame5.Parent = frame4
		local textLabel3 = Instance.new("TextLabel")
		textLabel3.BackgroundTransparency = 1
		textLabel3.Position = UDim2.new(0, 16, 0, 14)
		textLabel3.Size = UDim2.new(1, -24, 0, 22)
		textLabel3.Font = robotoMono
		textLabel3.Text = "duration"
		textLabel3.TextColor3 = color4
		textLabel3.TextSize = 17
		textLabel3.TextXAlignment = Enum.TextXAlignment.Left
		textLabel3.ZIndex = 6
		textLabel3.Parent = frame4
		local textLabel4 = Instance.new("TextLabel")
		textLabel4.Name = "Subtitle"
		textLabel4.BackgroundTransparency = 1
		textLabel4.Position = UDim2.new(0, 16, 0, 36)
		textLabel4.Size = UDim2.new(1, -24, 0, 16)
		textLabel4.Font = robotoMono
		textLabel4.Text = "module"
		textLabel4.TextColor3 = color6
		textLabel4.TextSize = 12
		textLabel4.TextXAlignment = Enum.TextXAlignment.Left
		textLabel4.ZIndex = 6
		textLabel4.Parent = frame4
		local textLabel5 = Instance.new("TextLabel")
		textLabel5.BackgroundTransparency = 1
		textLabel5.Position = UDim2.new(0, 16, 0, 80)
		textLabel5.Size = UDim2.new(1, -32, 0, 18)
		textLabel5.Font = robotoMono
		textLabel5.Text = "Durée (minutes)"
		textLabel5.TextColor3 = color5
		textLabel5.TextSize = 13
		textLabel5.TextXAlignment = Enum.TextXAlignment.Left
		textLabel5.ZIndex = 6
		textLabel5.Parent = frame4
		local textLabel6 = Instance.new("TextLabel")
		textLabel6.Name = "DurHint"
		textLabel6.BackgroundTransparency = 1
		textLabel6.Position = UDim2.new(0, 16, 0, 158)
		textLabel6.Size = UDim2.new(1, -32, 0, 16)
		textLabel6.Font = robotoMono
		textLabel6.Text = ""
		textLabel6.TextColor3 = color6
		textLabel6.TextSize = 12
		textLabel6.TextXAlignment = Enum.TextXAlignment.Left
		textLabel6.ZIndex = 6
		textLabel6.Parent = frame4
		local textBox = Instance.new("TextBox")
		textBox.Name = "DurBox"
		textBox.BackgroundColor3 = color2
		textBox.BorderSizePixel = 0
		textBox.Position = UDim2.new(0, 16, 0, 102)
		textBox.Size = UDim2.new(1, -32, 0, 48)
		textBox.Font = robotoMono
		textBox.PlaceholderText = "5"
		textBox.Text = ""
		textBox.TextColor3 = color5
		textBox.TextSize = 22
		textBox.ClearTextOnFocus = false
		textBox.ZIndex = 6
		textBox.Parent = frame4
		local textButton4 = Instance.new("TextButton")
		textButton4.Name = "DurStart"
		textButton4.AutoButtonColor = false
		textButton4.AnchorPoint = Vector2.new(0, 1)
		textButton4.Position = UDim2.new(0, 12, 1, -12)
		textButton4.Size = UDim2.new(0.5, -14, 0, 36)
		textButton4.BackgroundColor3 = color8
		textButton4.BorderSizePixel = 0
		textButton4.Font = robotoMono
		textButton4.Text = "start"
		textButton4.TextColor3 = color5
		textButton4.TextSize = 14
		textButton4.ZIndex = 6
		textButton4.Parent = frame4
		local textButton5 = Instance.new("TextButton")
		textButton5.Name = "DurCancel"
		textButton5.AutoButtonColor = false
		textButton5.AnchorPoint = Vector2.new(1, 1)
		textButton5.Position = UDim2.new(1, -12, 1, -12)
		textButton5.Size = UDim2.new(0.5, -14, 0, 36)
		textButton5.BackgroundColor3 = color2
		textButton5.BorderSizePixel = 0
		textButton5.Font = robotoMono
		textButton5.Text = "cancel"
		textButton5.TextColor3 = color5
		textButton5.TextSize = 14
		textButton5.ZIndex = 6
		textButton5.Parent = frame4
		local frame6 = Instance.new("Frame")
		frame6.Name = "ConfirmPrompt"
		frame6.BackgroundColor3 = color
		frame6.BorderSizePixel = 0
		frame6.Size = UDim2.new(1, 0, 1, 0)
		frame6.Position = UDim2.new(0, 0, 0, 0)
		frame6.Visible = false
		frame6.ZIndex = 8
		frame6.Parent = frame
		local frame7 = Instance.new("Frame")
		frame7.BackgroundColor3 = color4
		frame7.BorderSizePixel = 0
		frame7.Size = UDim2.new(0, 4, 1, 0)
		frame7.ZIndex = 9
		frame7.Parent = frame6
		local textLabel7 = Instance.new("TextLabel")
		textLabel7.BackgroundTransparency = 1
		textLabel7.Position = UDim2.new(0, 16, 0, 14)
		textLabel7.Size = UDim2.new(1, -24, 0, 22)
		textLabel7.Font = robotoMono
		textLabel7.Text = "are you sure?"
		textLabel7.TextColor3 = color4
		textLabel7.TextSize = 17
		textLabel7.TextXAlignment = Enum.TextXAlignment.Left
		textLabel7.ZIndex = 9
		textLabel7.Parent = frame6
		local textLabel8 = Instance.new("TextLabel")
		textLabel8.Name = "Subtitle"
		textLabel8.BackgroundTransparency = 1
		textLabel8.Position = UDim2.new(0, 16, 0, 36)
		textLabel8.Size = UDim2.new(1, -24, 0, 16)
		textLabel8.Font = robotoMono
		textLabel8.Text = "module"
		textLabel8.TextColor3 = color6
		textLabel8.TextSize = 12
		textLabel8.TextXAlignment = Enum.TextXAlignment.Left
		textLabel8.ZIndex = 9
		textLabel8.Parent = frame6
		local textButton6 = Instance.new("TextButton")
		textButton6.Name = "ConfirmYes"
		textButton6.AutoButtonColor = false
		textButton6.AnchorPoint = Vector2.new(0, 1)
		textButton6.Position = UDim2.new(0, 12, 1, -12)
		textButton6.Size = UDim2.new(0.5, -14, 0, 36)
		textButton6.BackgroundColor3 = color8
		textButton6.BorderSizePixel = 0
		textButton6.Font = robotoMono
		textButton6.Text = "yes"
		textButton6.TextColor3 = color5
		textButton6.TextSize = 14
		textButton6.ZIndex = 9
		textButton6.Parent = frame6
		local textButton7 = Instance.new("TextButton")
		textButton7.Name = "ConfirmNo"
		textButton7.AutoButtonColor = false
		textButton7.AnchorPoint = Vector2.new(1, 1)
		textButton7.Position = UDim2.new(1, -12, 1, -12)
		textButton7.Size = UDim2.new(0.5, -14, 0, 36)
		textButton7.BackgroundColor3 = color7
		textButton7.BorderSizePixel = 0
		textButton7.Font = robotoMono
		textButton7.Text = "no"
		textButton7.TextColor3 = color5
		textButton7.TextSize = 14
		textButton7.ZIndex = 9
		textButton7.Parent = frame6
		local frame8 = Instance.new("Frame")
		frame8.Name = "StopMenu"
		frame8.BackgroundColor3 = color
		frame8.BorderSizePixel = 0
		frame8.Size = UDim2.new(1, 0, 1, 0)
		frame8.Position = UDim2.new(0, 0, 0, 0)
		frame8.Visible = false
		frame8.ZIndex = 7
		frame8.Parent = frame
		local frame9 = Instance.new("Frame")
		frame9.BackgroundColor3 = color4
		frame9.BorderSizePixel = 0
		frame9.Size = UDim2.new(0, 4, 1, 0)
		frame9.ZIndex = 8
		frame9.Parent = frame8
		local textLabel9 = Instance.new("TextLabel")
		textLabel9.BackgroundTransparency = 1
		textLabel9.Position = UDim2.new(0, 16, 0, 14)
		textLabel9.Size = UDim2.new(1, -24, 0, 22)
		textLabel9.Font = robotoMono
		textLabel9.Text = "stop_event"
		textLabel9.TextColor3 = color4
		textLabel9.TextSize = 17
		textLabel9.TextXAlignment = Enum.TextXAlignment.Left
		textLabel9.ZIndex = 8
		textLabel9.Parent = frame8
		local textLabel10 = Instance.new("TextLabel")
		textLabel10.BackgroundTransparency = 1
		textLabel10.Position = UDim2.new(0, 16, 0, 36)
		textLabel10.Size = UDim2.new(1, -24, 0, 16)
		textLabel10.Font = robotoMono
		textLabel10.Text = "active/"
		textLabel10.TextColor3 = color6
		textLabel10.TextSize = 12
		textLabel10.TextXAlignment = Enum.TextXAlignment.Left
		textLabel10.ZIndex = 8
		textLabel10.Parent = frame8
		local frame10 = Instance.new("Frame")
		frame10.BackgroundTransparency = 1
		frame10.BorderSizePixel = 0
		frame10.Position = UDim2.new(0, 12, 0, 64)
		frame10.Size = UDim2.new(1, -24, 0, 88)
		frame10.ZIndex = 8
		frame10.Parent = frame8
		local uIListLayout2 = Instance.new("UIListLayout")
		uIListLayout2.Padding = UDim.new(0, 4)
		uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout2.Parent = frame10
		local textLabel11 = Instance.new("TextLabel")
		textLabel11.BackgroundTransparency = 1
		textLabel11.Size = UDim2.new(1, 0, 0, 40)
		textLabel11.Font = robotoMono
		textLabel11.Text = "nothing active"
		textLabel11.TextColor3 = color6
		textLabel11.TextSize = 14
		textLabel11.TextXAlignment = Enum.TextXAlignment.Left
		textLabel11.ZIndex = 8
		textLabel11.Visible = false
		textLabel11.Parent = frame10
		local textButton8 = Instance.new("TextButton")
		textButton8.Name = "Back"
		textButton8.AutoButtonColor = false
		textButton8.AnchorPoint = Vector2.new(0.5, 1)
		textButton8.Position = UDim2.new(0.5, 0, 1, -12)
		textButton8.Size = UDim2.new(1, -24, 0, 36)
		textButton8.BackgroundColor3 = color2
		textButton8.BorderSizePixel = 0
		textButton8.Font = robotoMono
		textButton8.Text = "back"
		textButton8.TextColor3 = color5
		textButton8.TextSize = 14
		textButton8.ZIndex = 8
		textButton8.Parent = frame8
		local v2 = nil
		local v3 = nil
		local v4 = nil
		local fn2 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeDurationPrompt()
			v2 = nil
			frame4.Visible = false
		end

		local function openDurationPrompt(data)
			v2 = data
			local maxDurationSeconds = data.maxDurationSeconds or 600
			local v5 = math.floor((data.defaultDurationSeconds or maxDurationSeconds) / 60 + 0.5)
			local v6 = v5 < 1 and 1 or v5
			textLabel4.Text = "modules/" .. (data.displayName or data.name)
			textBox.Text = tostring(v6)
			textBox.PlaceholderText = tostring(v6)
			local v7 = textLabel6
			local v9 = formatMinutesLabel(maxDurationSeconds) -- equivalent call inferred; original call site unknown
			v7.Text = "Maximum " .. v9
			frame4.Visible = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeConfirmationPrompt()
			v3 = nil
			v4 = nil
			fn2 = nil
			textLabel7.Text = "are you sure?"
			frame6.Visible = false
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function openConfirmationPrompt(p2, p3: number?)
			v3 = p2
			v4 = p3
			textLabel8.Text = "modules/" .. (p2.displayName or p2.name)
			frame6.Visible = true
		end

		local function openStopConfirmation(p2: string, callback)
			fn2 = callback
			v3 = nil
			v4 = nil
			textLabel7.Text = "end this event?"
			textLabel8.Text = "active/" .. p2
			frame6.Visible = true
		end

		local function closeAll()
			closeDurationPrompt() -- equivalent call inferred; original call site unknown
			closeConfirmationPrompt() -- equivalent call inferred; original call site unknown
			onMouseButton1Click()
			screenGui.Enabled = false

			if v.current.onClose then
				v.current.onClose()
			end
		end

		onMouseButton1Click = function()
			for _, button in ipairs(frame10:GetChildren()) do
				if button:IsA("TextButton") then
					button:Destroy()
				end
			end

			textLabel11.Visible = false
			frame8.Visible = false
		end

		fn = function()
			onMouseButton1Click()
			local current = v.current
			local count = 0

			if current.activeAdminAbuse and current.activeAdminAbuse ~= "" then
				count += 1
				local activeAdminAbuse = current.activeAdminAbuse
				local textButton9 = Instance.new("TextButton")
				textButton9.AutoButtonColor = false
				textButton9.BackgroundColor3 = color2
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, 40)
				textButton9.LayoutOrder = count
				textButton9.Font = robotoMono
				textButton9.Text = "  " .. activeAdminAbuse .. "  [admin abuse]"
				textButton9.TextColor3 = color5
				textButton9.TextSize = 14
				textButton9.TextXAlignment = Enum.TextXAlignment.Left
				textButton9.ZIndex = 8
				textButton9.MouseEnter:Connect(function()
					textButton9.BackgroundColor3 = color3
				end)
				textButton9.MouseLeave:Connect(function()
					textButton9.BackgroundColor3 = color2
				end)
				textButton9.MouseButton1Click:Connect(function()
					onMouseButton1Click()
					local v5 = activeAdminAbuse .. "  [admin abuse]"

					fn2 = function()
						v.current.onStop()
					end

					v3 = nil
					v4 = nil
					textLabel7.Text = "end this event?"
					textLabel8.Text = "active/" .. v5
					frame6.Visible = true
				end)
				textButton9.Parent = frame10
			end

			if current.activeEvent and current.activeEvent ~= "" then
				count += 1
				local activeEvent = current.activeEvent
				local textButton9 = Instance.new("TextButton")
				textButton9.AutoButtonColor = false
				textButton9.BackgroundColor3 = color2
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, 40)
				textButton9.LayoutOrder = count
				textButton9.Font = robotoMono
				textButton9.Text = "  " .. activeEvent .. "  [event]"
				textButton9.TextColor3 = color5
				textButton9.TextSize = 14
				textButton9.TextXAlignment = Enum.TextXAlignment.Left
				textButton9.ZIndex = 8
				textButton9.MouseEnter:Connect(function()
					textButton9.BackgroundColor3 = color3
				end)
				textButton9.MouseLeave:Connect(function()
					textButton9.BackgroundColor3 = color2
				end)
				textButton9.MouseButton1Click:Connect(function()
					onMouseButton1Click()
					local v5 = activeEvent .. "  [event]"

					fn2 = function()
						v.current.onStopEvent()
					end

					v3 = nil
					v4 = nil
					textLabel7.Text = "end this event?"
					textLabel8.Text = "active/" .. v5
					frame6.Visible = true
				end)
				textButton9.Parent = frame10
			end

			if count == 0 then
				textLabel11.Visible = true
			end

			frame8.Visible = true
		end

		textButton3.MouseButton1Click:Connect(closeAll)
		textButton.MouseButton1Click:Connect(closeAll)
		textButton5.MouseButton1Click:Connect(closeDurationPrompt)
		textButton8.MouseButton1Click:Connect(onMouseButton1Click)
		textButton7.MouseButton1Click:Connect(closeConfirmationPrompt)
		textButton6.MouseButton1Click:Connect(function()
			if fn2 then
				local v5 = fn2
				closeConfirmationPrompt() -- equivalent call inferred; original call site unknown
				v5()
			else
				local v5 = v3
				local v6 = v4
				closeConfirmationPrompt() -- equivalent call inferred; original call site unknown

				if v5 then
					v.current.onPickModule(v5.name, v6)
					screenGui.Enabled = false
				end
			end
		end)
		textButton4.MouseButton1Click:Connect(function()
			local v5 = v2

			if not v5 then
				return
			end

			local maxDurationSeconds = v5.maxDurationSeconds or 600
			local text = tonumber(textBox.Text)

			if not text or text <= 0 then
				text = (v5.defaultDurationSeconds or maxDurationSeconds) / 60
			end

			local v6 = math.floor(text * 60 + 0.5)
			local v7 = v6 <= 0 and 60 or v6

			if maxDurationSeconds < v7 then
				v7 = maxDurationSeconds
			end

			closeDurationPrompt() -- equivalent call inferred; original call site unknown
			openConfirmationPrompt(v5, v7) -- equivalent call inferred; original call site unknown
		end)

		local function clearScrollButtons()
			for _, button in ipairs(scrollingFrame:GetChildren()) do
				if button:IsA("TextButton") then
					button:Destroy()
				end
			end
		end

		local function applyProps(current)
			clearScrollButtons()
			closeDurationPrompt() -- equivalent call inferred; original call site unknown
			closeConfirmationPrompt() -- equivalent call inferred; original call site unknown

			for i, moduleMeta in ipairs(current.moduleMetas) do
				local row = makeRow(moduleMeta, i)
				row.Parent = scrollingFrame
				local v5 = moduleMeta
				row.MouseButton1Click:Connect(function()
					if v5.needsDuration then
						openDurationPrompt(v5)
						return
					end

					openConfirmationPrompt(v5, nil) -- equivalent call inferred; original call site unknown
				end)
			end

			textButton2.Visible = current.showStop

			if current.showStop then
				textButton2.AnchorPoint = Vector2.new(0, 1)
				textButton2.Position = UDim2.new(0, 12, 1, -12)
				textButton2.Size = UDim2.new(0.28, -8, 0, 36)
				textButton3.AnchorPoint = Vector2.new(1, 1)
				textButton3.Position = UDim2.new(1, -12, 1, -12)
				textButton3.Size = UDim2.new(0.3, -8, 0, 36)
			else
				textButton3.AnchorPoint = Vector2.new(0.5, 1)
				textButton3.Position = UDim2.new(0.5, 0, 1, -12)
				textButton3.Size = UDim2.new(1, -24, 0, 36)
			end
		end

		applyProps(v.current)
		return {
			ScreenGui = screenGui,
			SetVisible = function(enabled: boolean)
				if not enabled then
					closeDurationPrompt() -- equivalent call inferred; original call site unknown
					closeConfirmationPrompt() -- equivalent call inferred; original call site unknown
					onMouseButton1Click()
				end

				screenGui.Enabled = enabled
			end,
			SetProps = function(current)
				v.current = current
				applyProps(current)
			end,
			Destroy = function()
				screenGui:Destroy()
			end
		}
	end
}

function AdminAbuseGui.mountLocalPlayer(p)
	local localPlayer = Players.LocalPlayer
	assert(localPlayer, "LocalPlayer manquant")
	return AdminAbuseGui.mount(localPlayer:WaitForChild("PlayerGui"), p)
end

return AdminAbuseGui