local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIKit = require(script.Parent.UIKit)
local Remotes = require(ReplicatedStorage.CCPanel.Remotes)
local CCWorldsConfig = require(ReplicatedStorage.CCPanel.CCWorldsConfig)
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
return {
	build = function(p)
		local section = p.makeSection(6, 472)
		section.Visible = false
		local label = UIKit.label(
			section,
			"T",
			"🌍 CC Worlds",
			UDim2.new(1, -10, 0, 20),
			UDim2.new(0, 10, 0, 6),
			13,
			UIKit.C_TEXT,
			UIKit.FONT_BOLD
		)
		local frame = Instance.new("Frame")
		frame.Name = "TpRow"
		frame.Size = UDim2.new(1, -20, 0, 28)
		frame.Position = UDim2.new(0, 10, 0, 28)
		frame.BackgroundTransparency = 1
		frame.Parent = section
		local btn = UIKit.btn(
			section,
			"Back",
			"⬅ Back to main game",
			UDim2.new(1, -20, 0, 26),
			UDim2.new(0, 10, 0, 62),
			UIKit.C_ENTRY
		)
		local frame2 = Instance.new("Frame")
		frame2.Name = "InviteRow"
		frame2.Size = UDim2.new(1, -20, 0, 26)
		frame2.Position = UDim2.new(0, 10, 0, 92)
		frame2.BackgroundTransparency = 1
		frame2.Visible = false
		frame2.Parent = section
		local textBox = Instance.new("TextBox")
		textBox.Name = "InviteInput"
		textBox.Size = UDim2.new(1, -76, 1, 0)
		textBox.BackgroundColor3 = UIKit.C_ENTRY
		textBox.TextColor3 = UIKit.C_TEXT
		textBox.PlaceholderText = "Pseudo du CC à inviter…"
		textBox.PlaceholderColor3 = UIKit.C_SUB
		textBox.Text = ""
		textBox.TextSize = 12
		textBox.Font = UIKit.FONT
		textBox.BorderSizePixel = 0
		textBox.ClearTextOnFocus = false
		UIKit.corner(textBox, 4)
		textBox.Parent = frame2
		local btn2 = UIKit.btn(
			frame2,
			"Invite",
			"Invite",
			UDim2.new(0, 70, 1, 0),
			UDim2.new(1, -70, 0, 0),
			UIKit.C_ACCENT,
			Color3.new(1, 1, 1)
		)
		btn2.TextSize = 12
		UIKit.label(
			section,
			"Divider",
			"Sandbox tools",
			UDim2.new(1, -20, 0, 14),
			UDim2.new(0, 10, 0, 126),
			10,
			UIKit.C_SUB,
			UIKit.FONT,
			Enum.TextXAlignment.Center
		)
		local btnsById = {}

		for k, v in CCWorldsConfig.CATEGORIES do
			local v2 = (k - 1) % 2
			local v3 = math.floor((k - 1) / 2)
			local btn3 = UIKit.btn(
				section,
				"Give_" .. v.id,
				v.label,
				UDim2.new(0.5, -13, 0, 26),
				UDim2.new(v2 == 0 and 0 or 0.5, v2 == 0 and 10 or 3, 0, v3 * 32 + 144),
				UIKit.C_ACCENT,
				Color3.new(1, 1, 1)
			)
			btn3.TextSize = 11
			btnsById[v.id] = btn3
		end

		local frame3 = Instance.new("Frame")
		frame3.Name = "TabRow"
		frame3.Size = UDim2.new(1, -20, 0, 22)
		frame3.Position = UDim2.new(0, 10, 0, 206)
		frame3.BackgroundTransparency = 1
		frame3.Parent = section
		local v = 1 / #CCWorldsConfig.CATEGORIES
		local btnsById2 = {}

		for k, v2 in CCWorldsConfig.CATEGORIES do
			local btn3 = UIKit.btn(
				frame3,
				"Tab_" .. v2.id,
				v2.tabLabel,
				UDim2.new(v, -4, 1, 0),
				UDim2.new(v * (k - 1), k == 1 and 0 or 4, 0, 0),
				UIKit.C_ENTRY
			)
			btn3.TextSize = 11
			btnsById2[v2.id] = btn3
		end

		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = "PickList"
		scrollingFrame.Size = UDim2.new(1, -20, 0, 140)
		scrollingFrame.Position = UDim2.new(0, 10, 0, 232)
		scrollingFrame.BackgroundColor3 = UIKit.C_HEADER
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.ScrollBarThickness = 3
		scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		UIKit.corner(scrollingFrame, 5)
		scrollingFrame.Parent = section
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Padding = UDim.new(0, 2)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = scrollingFrame
		uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y + 4)
		end)
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingTop = UDim.new(0, 2)
		uIPadding.PaddingLeft = UDim.new(0, 2)
		uIPadding.PaddingRight = UDim.new(0, 2)
		uIPadding.Parent = scrollingFrame

		local function statRow(p2, p3, placeholderText)
			local frame4 = Instance.new("Frame")
			frame4.Name = p2 .. "Row"
			frame4.Size = UDim2.new(1, -20, 0, 24)
			frame4.Position = UDim2.new(0, 10, 0, p3)
			frame4.BackgroundTransparency = 1
			frame4.Parent = section
			local textBox2 = Instance.new("TextBox")
			textBox2.Size = UDim2.new(1, -66, 1, 0)
			textBox2.BackgroundColor3 = UIKit.C_ENTRY
			textBox2.TextColor3 = UIKit.C_TEXT
			textBox2.PlaceholderText = placeholderText
			textBox2.PlaceholderColor3 = UIKit.C_SUB
			textBox2.Text = ""
			textBox2.TextSize = 12
			textBox2.Font = UIKit.FONT
			textBox2.BorderSizePixel = 0
			textBox2.ClearTextOnFocus = false
			UIKit.corner(textBox2, 4)
			textBox2.Parent = frame4
			return
				frame4,
				textBox2,
				(UIKit.btn(
					frame4,
					"Set",
					"Set",
					UDim2.new(0, 60, 1, 0),
					UDim2.new(1, -60, 0, 0),
					UIKit.C_ACCENT,
					Color3.new(1, 1, 1)
				))
		end

		local _, v2, v3 = statRow("Wins", 378, "Wins…")
		local _, v4, v5 = statRow("Level", 406, "Level…")
		local btn3 = UIKit.btn(
			section,
			"Reset",
			"⚠ Reset my data",
			UDim2.new(1, -20, 0, 28),
			UDim2.new(0, 10, 0, 436),
			UIKit.C_OFF,
			Color3.new(1, 1, 1)
		)
		local flag = false
		local v6 = nil
		local v7 = nil

		local function sendInvite()
			local v8 = string.match(textBox.Text, "^%s*(.-)%s*$") or ""

			if #v8 < 1 then
				p.setStatus("Entre le pseudo d'un CC", true)
				return
			end

			btn2.Active = false
			task.spawn(function()
				local v9 = UIKit.invoke(Remotes.SendCCWorldInvite, v8)
				btn2.Active = true

				if not v9.success then
					p.setStatus(v9.error or "Invite failed", true)
					return
				end

				textBox.Text = ""
				local inviteId = v9.inviteId
				v7 = inviteId
				p.setStatus("Invitation envoyée à " .. tostring(v9.targetName))
				task.delay(tonumber(v9.ackWindow) or 8, function()
					if v7 == inviteId then
						v7 = nil
						p.setStatus("CC introuvable dans CC Worlds", true)
					end
				end)
			end)
		end

		btn2.MouseButton1Click:Connect(sendInvite)
		textBox.FocusLost:Connect(function(p2)
			if p2 then
				sendInvite()
			end
		end)
		local v8 = {
			no_access = "n'a pas accès à CC Worlds",
			inbox_full = "a trop d'invitations en attente",
			duplicate = "a déjà une invitation de ta part"
		}
		Remotes.CCWorldInviteAck:connect(function(data)
			if type(data) ~= "table" or data.inviteId ~= v7 then
				return
			end

			v7 = nil
			local targetName = tostring(data.targetName)

			if data.ok then
				p.setStatus("✓ " .. targetName .. " a reçu l'invitation")
			else
				p.setStatus(targetName .. " " .. (v8[data.reason] or "n'a pas pu la recevoir"), true)
			end
		end)

		local function populatePicker(p2: string)
			v6 = p2

			for k, v9 in btnsById2 do
				v9.BackgroundColor3 = k == p2 and UIKit.C_SEL or UIKit.C_ENTRY
			end

			for _, button in scrollingFrame:GetChildren() do
				if button:IsA("TextButton") then
					button:Destroy()
				end
			end

			task.spawn(function()
				local v9 = UIKit.invoke(Remotes.CCWorldCatalog, p2)

				if v6 ~= p2 then
					return
				end

				if not v9.success then
					p.setStatus(v9.error or "Catalog failed", true)
					return
				end

				for i, v10 in ipairs(v9.entries or {}) do
					local v11 = v10.owned and p2 ~= "items"
					local btn4 = UIKit.btn(
						scrollingFrame,
						v10.key,
						(v10.owned and "✓ " or "") .. v10.label,
						UDim2.new(1, -6, 0, 20),
						UDim2.new(0, 0, 0, 0),
						v11 and UIKit.C_ENTRY or UIKit.C_ACCENT,
						v11 and UIKit.C_SUB or Color3.new(1, 1, 1)
					)
					btn4.LayoutOrder = i
					btn4.TextSize = 11

					if v11 then
						btn4:SetAttribute("locked", true)
					end

					local v13 = v10
					btn4.MouseButton1Click:Connect(function()
						if btn4:GetAttribute("locked") then
							return
						end

						btn4.Active = false
						local v14 = UIKit.invoke(Remotes.CCWorldGiveOne, p2, v13.key)
						btn4.Active = true

						if v14.success then
							p.setStatus("✓ " .. v13.label)
							btn4.Text = "✓ " .. v13.label

							if p2 ~= "items" then
								btn4:SetAttribute("locked", true)
								btn4.BackgroundColor3 = UIKit.C_ENTRY
								btn4.TextColor3 = UIKit.C_SUB
							end
						else
							p.setStatus(v14.error or "Give failed", true)
						end
					end)
				end
			end)
		end

		for k, v9 in btnsById2 do
			local v10 = k
			v9.MouseButton1Click:Connect(function()
				populatePicker(v10)
			end)
		end

		local function applyState(data)
			for _, child in frame:GetChildren() do
				child:Destroy()
			end

			if not (data.success and data.canUse and data.isCCWorld) then
				section.Visible = false
				return
			end

			section.Visible = true
			label.Text = data.isDebugPlace and "🌍 CC Worlds — [DEBUG]" or "🌍 CC Worlds"
			local v9 = label
			local textColor

			if data.isDebugPlace then
				textColor = UIKit.C_ACCENT
			else
				textColor = UIKit.C_TEXT
			end

			v9.TextColor3 = textColor
			frame2.Visible = data.inReservedServer == true
			btn.Visible = data.inReservedServer == true
			local worldCount = data.worldCount or 3
			local v11 = 1 / worldCount

			for i = 1, worldCount do
				local v12

				if data.currentWorldIndex == i then
					v12 = data.inOwnServer == true
				else
					v12 = false
				end

				local btn4 = UIKit.btn(
					frame,
					"Tp_" .. i,
					"World " .. i,
					UDim2.new(v11, -4, 1, 0),
					UDim2.new(v11 * (i - 1), i == 1 and 0 or 4, 0, 0),
					v12 and UIKit.C_SEL or UIKit.C_ACCENT,
					Color3.new(1, 1, 1)
				)

				if v12 then
					btn4:SetAttribute("locked", true)
				end

				local v14 = i
				btn4.MouseButton1Click:Connect(function()
					if btn4:GetAttribute("locked") then
						return
					end

					btn4.Active = false
					local v15 = UIKit.invoke(Remotes.TeleportToCCWorld, v14)
					btn4.Active = true

					if not v15.success then
						p.setStatus(v15.error or "Teleport failed", true)
					end
				end)
			end

			populatePicker(v6 or CCWorldsConfig.CATEGORIES[1].id)
		end

		local function refresh()
			task.spawn(function()
				applyState(UIKit.invoke(Remotes.GetCCWorldState))
			end)
		end

		btn.MouseButton1Click:Connect(function()
			local v9 = UIKit.invoke(Remotes.ReturnToProd)

			if not v9.success then
				p.setStatus(v9.error or "Teleport failed", true)
			end
		end)

		for k, v9 in btnsById do
			local v10 = v9
			local v11 = k
			v9.MouseButton1Click:Connect(function()
				v10.Active = false
				local v12 = UIKit.invoke(Remotes.CCWorldGiveAll, v11)
				v10.Active = true

				if v12.success then
					p.setStatus("✓ " .. v10.Text)
					NotificationSystem:ShowMessage("✓ " .. v10.Text, Color3.fromRGB(0, 220, 110))

					if v6 == v11 then
						populatePicker(v11)
					end
				else
					p.setStatus(v12.error or "Give failed", true)
				end
			end)
		end

		local function wireStatSetter(state, p2, p3: string)
			local function apply()
				local text = tonumber(state.Text)

				if not text then
					p.setStatus("Invalid number", true)
					return
				end

				p2.Active = false
				local v9 = UIKit.invoke(Remotes.CCWorldSetStat, p3, text)
				p2.Active = true

				if not v9.success then
					p.setStatus(v9.error or "Set failed", true)
					return
				end

				state.Text = ""
				p.setStatus("✓ " .. p3 .. " = " .. tostring(v9.value))
			end

			p2.MouseButton1Click:Connect(apply)
			state.FocusLost:Connect(function(p4)
				if p4 then
					apply()
				end
			end)
		end

		wireStatSetter(v2, v3, "Wins")
		wireStatSetter(v4, v5, "Level")
		btn3.MouseButton1Click:Connect(function()
			if flag then
				flag = false
				btn3.Text = "⚠ Reset my data"
				btn3.Active = false
				local v9 = UIKit.invoke(Remotes.CCWorldResetData)
				btn3.Active = true

				if not v9.success then
					p.setStatus(v9.error or "Reset failed", true)
					return
				end

				p.setStatus("✓ Data reset")
				NotificationSystem:ShowMessage("✓ Data reset !", Color3.fromRGB(0, 220, 110))
			else
				flag = true
				btn3.Text = "Click again to CONFIRM reset"
				task.delay(5, function()
					if flag then
						flag = false
						btn3.Text = "⚠ Reset my data"
					end
				end)
			end
		end)
		return {
			refresh = refresh
		}
	end
}