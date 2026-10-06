local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
return {
	Mount = function(state)
		local localPlayer = game.Players.LocalPlayer
		local rewardGiftRemote = game.ReplicatedStorage:WaitForChild("RewardGiftRemote")
		local rewardGiftEvent = game.ReplicatedStorage:WaitForChild("RewardGiftEvent")
		local panel = state.Panel
		local details = panel.Details
		details.Redeem.Position = UDim2.fromOffset(350, 212)
		local button = CatalogUI.button(
			"Gift",
			details,
			"Gift to a friend",
			UDim2.fromOffset(350, 272),
			UDim2.new(1, -374, 0, 44)
		)
		button.ZIndex = details.Redeem.ZIndex
		local folder = CatalogUI.make("Frame", "GiftDialog", state, {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = CatalogUI.colors.bg,
			BorderSizePixel = 0,
			Visible = false,
			Active = true,
			ZIndex = 30
		})
		CatalogUI.round(folder, 16)
		local displayOrder = state.DisplayOrder
		folder:GetPropertyChangedSignal("Visible"):Connect(function()
			state.DisplayOrder = folder.Visible and math.max(displayOrder, 260) or displayOrder
		end)
		local label = CatalogUI.label(
			"Heading",
			folder,
			"Gift a reward",
			UDim2.fromOffset(24, 18),
			UDim2.fromOffset(550, 38),
			26
		)
		local button2 = CatalogUI.button("Close", folder, "Close", UDim2.new(1, -94, 0, 22), UDim2.fromOffset(70, 36))
		local label2 = CatalogUI.label(
			"Intro",
			folder,
			"Use your coins to unlock a reward for someone else.",
			UDim2.fromOffset(24, 65),
			UDim2.new(1, -48, 0, 30),
			15
		)
		local v = CatalogUI.make("ImageLabel", "Preview", folder, {
			Position = UDim2.fromOffset(24, 114),
			Size = UDim2.fromOffset(280, 270),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit
		})
		local label3 = CatalogUI.label(
			"RewardName",
			folder,
			"",
			UDim2.fromOffset(24, 386),
			UDim2.fromOffset(280, 55),
			20
		)
		local label4 = CatalogUI.label("Cost", folder, "", UDim2.fromOffset(340, 105), UDim2.fromOffset(354, 30), 18)
		local input = CatalogUI.input(
			"Username",
			folder,
			"Friend's Roblox username",
			UDim2.fromOffset(340, 147),
			UDim2.fromOffset(354, 44)
		)
		input.MaxVisibleGraphemes = 24
		local button3 = CatalogUI.button(
			"Find",
			folder,
			"Find player",
			UDim2.fromOffset(340, 203),
			UDim2.fromOffset(354, 42)
		)
		local label5 = CatalogUI.label(
			"Confirmation",
			folder,
			"Enter their username, then confirm who receives the gift.",
			UDim2.fromOffset(340, 257),
			UDim2.fromOffset(354, 91),
			15
		)
		label5.TextYAlignment = Enum.TextYAlignment.Top
		local button4 = CatalogUI.button(
			"Send",
			folder,
			"Confirm gift",
			UDim2.fromOffset(340, 354),
			UDim2.fromOffset(354, 48),
			true
		)
		local label6 = CatalogUI.label("Status", folder, "", UDim2.fromOffset(340, 412), UDim2.fromOffset(354, 70), 13)
		label6.TextYAlignment = Enum.TextYAlignment.Top
		local parent = CatalogUI.make("ScrollingFrame", "Body", folder, {
			Position = UDim2.fromOffset(0, 64),
			Size = UDim2.new(1, 0, 1, -64),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			CanvasSize = UDim2.fromOffset(0, 436),
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Active = true,
			ZIndex = 31
		})

		for _, v3 in ipairs({
			label2,
			v,
			label3,
			label4,
			input,
			button3,
			label5,
			button4,
			label6
		}) do
			v3.Parent = parent
		end

		local uIScale = Instance.new("UIScale", folder)
		local uIScale2 = panel:FindFirstChildOfClass("UIScale")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function place(p, p2, p3, p4, p5)
			p.Position = UDim2.fromOffset(p2, p3)
			p.Size = UDim2.fromOffset(p4, p5)
		end

		local function layout()
			if not workspace.CurrentCamera then
				return
			end

			local absoluteSize = state.AbsoluteSize
			local v3 = absoluteSize.X < 740 or absoluteSize.Y < 550
			local scale = uIScale2 and uIScale2.Scale or 1
			folder.AnchorPoint = Vector2.new(0.5, 0.5)
			folder.Position = UDim2.fromScale(0.5, 0.5)
			uIScale.Scale = v3 and 1 or scale
			local v4 = not v3 and 720 or math.min(720, absoluteSize.X - 24) or 720
			local v5 = v3 and math.min(650, absoluteSize.Y - 24) or 500
			folder.Size = UDim2.fromOffset(v4, v5)
			label.TextSize = v3 and 22 or 26
			place(label, 20, 12, v4 - 124, 40) -- equivalent call inferred; original call site unknown
			place(button2, v4 - 94, 10, 74, 44) -- equivalent call inferred; original call site unknown
			parent.Position = UDim2.fromOffset(0, 64)
			parent.Size = UDim2.new(1, 0, 1, -64)
			local v10 = v3 and v4 < 520
			label2.Visible = not v3
			v.Visible = not v3 or v10

			if v10 then
				place(v, 20, 0, 96, 106) -- equivalent call inferred; original call site unknown
				place(label3, 132, 0, v4 - 152, 60) -- equivalent call inferred; original call site unknown
				label3.TextSize = 18
				place(label4, 132, 64, v4 - 152, 42) -- equivalent call inferred; original call site unknown
				label4.TextSize = 15
				place(input, 20, 120, v4 - 40, 44) -- equivalent call inferred; original call site unknown
				place(button3, 20, 176, v4 - 40, 44) -- equivalent call inferred; original call site unknown
				place(label5, 20, 232, v4 - 40, 98) -- equivalent call inferred; original call site unknown
				place(button4, 20, 342, v4 - 40, 48) -- equivalent call inferred; original call site unknown
				place(label6, 20, 402, v4 - 40, 116) -- equivalent call inferred; original call site unknown
				parent.CanvasSize = UDim2.fromOffset(0, 538)
			elseif v3 then
				place(label3, 20, 0, v4 - 200, 30) -- equivalent call inferred; original call site unknown
				label3.TextSize = 18
				place(label4, v4 - 176, 0, 156, 30) -- equivalent call inferred; original call site unknown
				label4.TextSize = 15
				place(input, 20, 42, v4 - 190, 44) -- equivalent call inferred; original call site unknown
				place(button3, v4 - 158, 42, 138, 44) -- equivalent call inferred; original call site unknown
				place(label5, 20, 98, v4 - 40, 72) -- equivalent call inferred; original call site unknown
				place(button4, 20, 180, v4 - 40, 48) -- equivalent call inferred; original call site unknown
				place(label6, 20, 240, v4 - 40, 90) -- equivalent call inferred; original call site unknown
				parent.CanvasSize = UDim2.fromOffset(0, 346)
			else
				place(label2, 24, 1, 672, 30) -- equivalent call inferred; original call site unknown
				place(v, 24, 50, 280, 270) -- equivalent call inferred; original call site unknown
				place(label3, 24, 322, 280, 55) -- equivalent call inferred; original call site unknown
				label3.TextSize = 20
				place(label4, 340, 41, 354, 30) -- equivalent call inferred; original call site unknown
				label4.TextSize = 18
				place(input, 340, 83, 354, 44) -- equivalent call inferred; original call site unknown
				place(button3, 340, 139, 354, 42) -- equivalent call inferred; original call site unknown
				place(label5, 340, 193, 354, 91) -- equivalent call inferred; original call site unknown
				place(button4, 340, 290, 354, 48) -- equivalent call inferred; original call site unknown
				place(label6, 340, 348, 354, 70) -- equivalent call inferred; original call site unknown
				parent.CanvasSize = UDim2.fromOffset(0, 436)
			end
		end

		local ViewportLayoutWatch = require(game.ReplicatedStorage.ViewportLayoutWatch)
		ViewportLayoutWatch.Bind(layout)

		if uIScale2 then
			uIScale2:GetPropertyChangedSignal("Scale"):Connect(layout)
		end

		layout()

		for _, guiObject in folder:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 31
			end
		end

		local clone = nil
		local v3 = nil
		local v4 = false
		local v5 = false
		local v6 = false
		local v7 = nil

		local function request(p, p2)
			local success, result = pcall(function()
				return rewardGiftRemote:InvokeServer(p, p2)
			end)

			if success and type(result) == "table" then
				return result
			end

			return {
				error = "Connection interrupted. Retry this gift to check its saved progress."
			}
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function controls()
			input.TextEditable = not (v4 or v5 or v6)
			button3.Interactable = not (v4 or v5 or v6)
			button2.Interactable = not v4
			button4.Interactable = v3 ~= nil and not (v4 or v6)
			button4.Text = v4 and "Please wait…" or v6 and "Gift saved" or v5 and "Retry gift" or "Confirm gift"
		end

		local function open()
			if not v7 or v4 then
				return
			end

			if not v5 then
				clone = table.clone(v7)
				v3 = nil
				v6 = false
				input.Text = ""
				label6.Text = ""
				label5.Text = "Enter their username, then confirm who receives the gift."
			end

			v.Image = "rbxthumb://type=Asset&id=" .. clone.id .. "&w=420&h=420"
			label3.Text = clone.name
			label4.Text = tostring(clone.cost) .. " coins from your balance"
			parent.CanvasPosition = Vector2.zero
			folder.Visible = true
			controls() -- equivalent call inferred; original call site unknown
		end

		button.Activated:Connect(open)
		button2.Activated:Connect(function()
			if not v4 then
				folder.Visible = false
			end
		end)
		panel:GetPropertyChangedSignal("Visible"):Connect(function()
			if not panel.Visible then
				folder.Visible = false
			end
		end)
		input:GetPropertyChangedSignal("Text"):Connect(function()
			if not (v4 or v5) then
				v3 = nil
				label5.Text = "Find the player to confirm their username."
				controls() -- equivalent call inferred; original call site unknown
			end
		end)
		button3.Activated:Connect(function()
			if v4 or v5 or v6 or not clone then
				return
			end

			v4 = true
			v3 = nil
			label6.Text = ""
			controls() -- equivalent call inferred; original call site unknown
			local v8 = request("Quote", {
				item = clone.id,
				username = input.Text
			})
			v4 = false

			if v8.error then
				label6.Text = v8.error
			else
				v3 = v8
				label5.Text = "Send " .. v8.name .. " to @" .. v8.username .. " for " .. v8.cost .. " coins?\nThey must join and press Claim. Stock is not reserved."
			end

			controls() -- equivalent call inferred; original call site unknown
		end)
		button4.Activated:Connect(function()
			if v4 or not v3 or v6 then
				return
			end

			v4 = true
			v5 = true
			label6.Text = ""
			controls() -- equivalent call inferred; original call site unknown
			local v8 = request("Send", {
				token = v3.token
			})
			v4 = false

			if v8.accepted then
				v6 = true
				v5 = false
				label5.Text = v8.refunded and "Gift refunded" or "Gift saved for @" .. v3.username
				label6.Text = v8.message or "Gift saved."
				parent.CanvasPosition = Vector2.new(
					0,
					(math.max(0, label6.Position.Y.Offset + label6.Size.Y.Offset - parent.AbsoluteSize.Y))
				)
			else
				label6.Text = v8.error or "Please retry this gift."

				if v8.finished or v8.reset then
					v5 = false
					v3 = nil
				end
			end

			controls() -- equivalent call inferred; original call site unknown
		end)
		local v8 = CatalogUI.make("Frame", "RewardGiftToast", state, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 90),
			Size = UDim2.fromOffset(500, 112),
			BackgroundColor3 = CatalogUI.colors.bg,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 40
		})
		CatalogUI.round(v8, 12)
		local label7 = CatalogUI.label("Message", v8, "", UDim2.fromOffset(16, 10), UDim2.new(1, -32, 0, 58), 15)
		label7.ZIndex = 41
		local button5 = CatalogUI.button("Dismiss", v8, "Got it", UDim2.new(1, -94, 1, -38), UDim2.fromOffset(78, 28))
		button5.ZIndex = 41
		button5.Activated:Connect(function()
			v8.Visible = false
		end)
		local uIScale3 = Instance.new("UIScale", v8)
		local ViewportLayoutWatch2 = require(game.ReplicatedStorage.ViewportLayoutWatch)
		ViewportLayoutWatch2.Bind(function()
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				uIScale3.Scale = math.min(1, (currentCamera.ViewportSize.X - 24) / 500)
			end
		end)
		local count = 0
		rewardGiftEvent.OnClientEvent:Connect(function(data)
			if type(data) ~= "table" then
				return
			end

			if data.kind == "Received" then
				label7.Text = "@" .. data.sender .. " gifted you " .. data.name .. "! Open Rewards, select the item, and press Claim."
			elseif data.kind == "Refunded" then
				label7.Text = data.amount .. " coins returned: " .. data.name .. ". " .. (data.reason or "The gift could not be used.")
			elseif data.kind == "Unavailable" then
				label7.Text = data.name .. " sold out before claiming. The coins will be returned to @" .. data.sender .. "."
			else
				return
			end

			count += 1
			local v9 = count
			v8.Visible = true
			task.delay(15, function()
				if v9 == count then
					v8.Visible = false
				end
			end)
		end)
		task.spawn(function()
			for _ = 1, 5 do
				if request("Ready", {}).ready then
					break
				else
					task.wait(2)
				end
			end
		end)
		input.TextEditable = not (v4 or v5 or v6)
		button3.Interactable = not (v4 or v5 or v6)
		button2.Interactable = not v4
		local interactable

		if v3 == nil then
			interactable = false
		else
			interactable = not (v4 or v6)
		end

		button4.Interactable = interactable
		button4.Text = v4 and "Please wait…" or v6 and "Gift saved" or v5 and "Retry gift" or "Confirm gift"
		return {
			Update = function(data, p)
				v7 = data
				button.Visible = data ~= nil and data.category ~= "Stream"
				local v12 = button
				local interactable2 = not (p or v4)

				if interactable2 then
					if data == nil or data.available ~= true or localPlayer:GetAttribute("CoinsReady") ~= true then
						interactable2 = false
					else
						interactable2 = (localPlayer:GetAttribute("Coins") or 0) >= (data.cost or 1e999)
					end
				end

				v12.Interactable = interactable2
			end
		}
	end
}