local ValleyPanels = require(script.Parent.ValleyPanels)
local ValleyTheme = require(script.Parent.ValleyTheme)
local SkinCatalog = require(script.Parent.Parent.Weapons.SkinCatalog)
local GiveawayRules = require(script.Parent.Parent.Admin.GiveawayRules)
local GiveawayView = require(script.Parent.GiveawayView)
return {
	new = function(instance, object)
		local screen = ValleyPanels.screen(instance, "GiveawayPicker", 9900)
		screen.IgnoreGuiInset = true
		screen.ScreenInsets = Enum.ScreenInsets.None
		screen.ClipToDeviceSafeArea = false
		local panel, v, v2 = ValleyPanels.panel(screen, "Picker", 800, 580)
		ValleyTheme.surface(v, ValleyTheme.Ink, ValleyTheme.Gold, 8, 0.4)
		ValleyPanels.text(v, "Eyebrow", "OWNER TOOLS  /  GLOBAL GIVEAWAY", 24, 18, 690, 22, 12, ValleyTheme.Gold)
		local text_2 = ValleyPanels.text(
			v,
			"Title",
			"Choose the prize. Let the wheel choose the player.",
			24,
			51,
			685,
			54,
			24,
			ValleyTheme.Paper
		)
		text_2.Font = Enum.Font.GothamBold
		local text = ValleyPanels.text(
			v,
			"Help",
			"One winner in each running server. Existing owners skip dagger draws.",
			24,
			113,
			752,
			38,
			14,
			ValleyTheme.Muted
		)
		local kind = "Dagger"
		local skin = SkinCatalog.Order[2] or SkinCatalog.Default
		local v5 = false
		local buttons = {}
		local v6 = ValleyPanels.make("ScrollingFrame", v, "Daggers", {
			Position = UDim2.fromOffset(24, 207),
			Size = UDim2.fromOffset(440, 220),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 5,
			ScrollBarImageColor3 = ValleyTheme.Gold,
			Active = true,
			ScrollingDirection = Enum.ScrollingDirection.Y
		})
		ValleyPanels.make("UIListLayout", v6, "Layout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		local buttons2 = {}
		local v7 = ValleyPanels.make("ViewportFrame", v, "Preview", {
			Position = UDim2.fromOffset(487, 207),
			Size = UDim2.fromOffset(285, 220),
			BackgroundTransparency = 1
		})
		local v8 = ValleyPanels.make("TextBox", v, "Amount", {
			Position = UDim2.fromOffset(24, 229),
			Size = UDim2.fromOffset(440, 70),
			Text = "1000",
			PlaceholderText = "Whole amount",
			ClearTextOnFocus = false,
			TextColor3 = ValleyTheme.Paper,
			TextSize = 30,
			Font = Enum.Font.GothamBold,
			BorderSizePixel = 0,
			Visible = false
		})
		ValleyTheme.surface(v8, ValleyTheme.InventoryInk, ValleyTheme.Gold, 6, 0.5)
		local text2 = ValleyPanels.text(
			v,
			"Unit",
			"Exact amount. No XP multiplier or bowners coins.",
			24,
			316,
			440,
			64,
			16,
			ValleyTheme.Muted
		)
		text2.Visible = false
		local text3 = ValleyPanels.text(v, "Status", "", 24, 438, 748, 56, 16, ValleyTheme.Gold)
		local button = ValleyPanels.button(v, "PreviewButton", "PREVIEW HERE", 24, 508, 215, 46)
		ValleyTheme.button(button, ValleyTheme.Blue)
		local button2 = ValleyPanels.button(v, "Launch", "START GLOBAL WHEEL", 253, 508, 519, 46)
		ValleyTheme.button(button2, ValleyTheme.Gold)

		local function prize()
			return kind == "Dagger" and {
				kind = kind,
				skin = skin
			} or {
				kind = kind,
				amount = tonumber(v8.Text)
			}
		end

		local function draw()
			v5 = false
			button2.Text = "START GLOBAL WHEEL"
			text3.Text = GiveawayRules.validPrize((prize())) and GiveawayRules.label((prize())) or "Enter a whole amount from 1 to 1,000,000."

			for k, v9 in buttons do
				ValleyTheme.button(v9, k == kind and ValleyTheme.Gold or ValleyTheme.Border)
			end

			for k, v9 in buttons2 do
				ValleyTheme.button(v9, k == skin and ValleyTheme.Gold or ValleyTheme.Border)
			end

			v6.Visible = kind == "Dagger"
			v7.Visible = v6.Visible
			v8.Visible = not v6.Visible
			text2.Visible = v8.Visible

			if v6.Visible then
				GiveawayView.preview(v7, skin)
			end
		end

		local flag = false

		for k, v9 in {
			"Dagger",
			"Gems",
			"Coins",
			"XP"
		} do
			local button3 = ValleyPanels.button(v, v9, v9:upper(), 24 + (k - 1) * 189, 159, 181, 38)
			buttons[v9] = button3
			local v10 = v9
			button3.Activated:Connect(function()
				if not flag then
					kind = v10
					draw()
				end
			end)
		end

		for k, v9 in SkinCatalog.Order do
			local v10 = SkinCatalog.get(v9)
			local button3 = ValleyPanels.button(v6, v9, v10.Name, 0, 0, 425, 43)
			button3.LayoutOrder = k
			button3.TextSize = 14
			buttons2[v9] = button3
			local v11 = v9
			button3.Activated:Connect(function()
				if not flag then
					skin = v11
					draw()
				end
			end)
		end

		v8:GetPropertyChangedSignal("Text"):Connect(function()
			if not flag then
				draw()
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function visible(visible2)
			panel.Visible = visible2
			instance:SetAttribute("GiveawayPickerOpen", visible2 or nil)

			if visible2 then
				flag = false
				draw()
				local focusedTextBox = game.UserInputService:GetFocusedTextBox()

				if focusedTextBox then
					focusedTextBox:ReleaseFocus()
				end
			end
		end

		v2.Activated:Connect(function()
			visible(false) -- equivalent call inferred; original call site unknown
		end)

		local function send(p)
			if flag or not GiveawayRules.validPrize((prize())) then
				return
			end

			if p or v5 then
				flag = true
				text3.Text = "Starting…"
				object:FireServer(p and "Preview" or "Launch", (prize()))
				task.delay(12, function()
					if flag then
						flag = false
						text3.Text = "Still waiting for the server. Check before trying again."
						v5 = false
						button2.Text = "START GLOBAL WHEEL"
					end
				end)
			else
				v5 = true
				button2.Text = "CONFIRM · START IN ALL SERVERS"
				text3.Text = "Give " .. GiveawayRules.label((prize())) .. " to one eligible player per server? Matches pause during the spin."
			end
		end

		button.Activated:Connect(function()
			if not flag then
				if not GiveawayRules.validPrize((prize())) then
					return
				end

				flag = true
				text3.Text = "Starting…"
				object:FireServer("Preview", (prize()))
				task.delay(12, function()
					if flag then
						flag = false
						text3.Text = "Still waiting for the server. Check before trying again."
						v5 = false
						button2.Text = "START GLOBAL WHEEL"
					end
				end)
			end
		end)
		button2.Activated:Connect(function()
			send(false)
		end)

		local function layout()
			local absoluteSize = screen.AbsoluteSize
			local v9 = absoluteSize.X < absoluteSize.Y
			local v10 = not v9 and absoluteSize.Y < 520
			local v11 = v9 and 540 or 800
			local v12 = v9 and 680 or v10 and 420 or 580
			v.Size = UDim2.fromOffset(v11, v12)
			v.Scale.Scale = math.min(1.15, absoluteSize.X * 0.94 / v11, absoluteSize.Y * 0.92 / v12)
			v.Title.Size = UDim2.fromOffset(v11 - 95, v9 and 72 or v10 and 44 or 54)
			v.Title.Position = UDim2.fromOffset(24, v10 and 36 or 51)
			v.Title.TextSize = v9 and 22 or v10 and 20 or 24
			v.Eyebrow.Position = UDim2.fromOffset(24, v10 and 10 or 18)
			v.Eyebrow.Size = UDim2.fromOffset(v11 - 100, 22)
			text.Position = UDim2.fromOffset(24, v9 and 126 or v10 and 77 or 113)
			text.Size = UDim2.fromOffset(v11 - 48, 38)
			text.TextSize = v10 and 12 or 14
			v2.Position = UDim2.fromOffset(v11 - 70, 12)
			v2.Size = UDim2.fromOffset(54, 48)

			for k, v13 in {
				"Dagger",
				"Gems",
				"Coins",
				"XP"
			} do
				local v14 = buttons[v13]
				v14.Position = UDim2.fromOffset(24 + (k - 1) * (v11 - 48) / 4, v9 and 178 or v10 and 116 or 159)
				v14.Size = UDim2.fromOffset((v11 - 48) / 4 - 8, 34)
			end

			local v13 = v9 and 230 or v10 and 163 or 207
			v6.Position = UDim2.fromOffset(24, v13)
			v6.Size = UDim2.fromOffset(v9 and 300 or 440, v9 and 280 or v10 and 142 or 220)

			for _, v14 in buttons2 do
				v14.Size = UDim2.fromOffset(v9 and 284 or 425, v9 and 60 or 48)
				v14.TextSize = 16
			end

			v7.Position = UDim2.fromOffset(v9 and 340 or 487, v13)
			v7.Size = UDim2.fromOffset(v9 and 176 or 285, v10 and 145 or 220)
			v8.Position = UDim2.fromOffset(24, v13 + 10)
			v8.Size = UDim2.fromOffset(v9 and 300 or 440, 60)
			text2.Position = UDim2.fromOffset(24, v13 + 75)
			text2.Size = UDim2.fromOffset(v9 and 300 or 440, 60)
			text3.Position = UDim2.fromOffset(24, v12 - 137)
			text3.Size = UDim2.fromOffset(v11 - 48, 62)
			text3.TextSize = v10 and 13 or 16
			button.Position = UDim2.fromOffset(24, v12 - 66)
			button.Size = UDim2.fromOffset(v9 and 155 or 215, 44)
			button2.Position = UDim2.fromOffset(v9 and 190 or 253, v12 - 66)
			button2.Size = UDim2.fromOffset(v9 and 326 or 519, 44)
			button2.TextSize = v9 and 11 or 14
		end

		screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
		layout()
		draw()
		return {
			open = function()
				if instance:GetAttribute("AdminTier") == "Owner" then
					panel.Visible = true
					instance:SetAttribute("GiveawayPickerOpen", true)
					flag = false
					draw()
					local focusedTextBox = game.UserInputService:GetFocusedTextBox()

					if focusedTextBox then
						focusedTextBox:ReleaseFocus()
					end
				end
			end,
			hide = function()
				visible(false) -- equivalent call inferred; original call site unknown
			end,
			reply = function(p)
				flag = false
				v5 = false

				if p.ok then
					visible(false) -- equivalent call inferred; original call site unknown
				else
					text3.Text = p.message
					button2.Text = "START GLOBAL WHEEL"
				end
			end,
			destroy = function()
				instance:SetAttribute("GiveawayPickerOpen", nil)
				screen:Destroy()
			end
		}
	end
}