local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIKit = require(script.Parent.UIKit)
local Remotes = require(ReplicatedStorage.CCPanel.Remotes)
local GiftTreadmillConfig = require(ReplicatedStorage.CCPanel.GiftTreadmillConfig)
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
return {
	build = function(data)
		local v = #GiftTreadmillConfig.TREADMILLS * 52 + 82 + 10
		local section = data.makeSection(4, v)
		UIKit.label(
			section,
			"T",
			"Gift Treadmill",
			UDim2.new(1, -60, 0, 20),
			UDim2.new(0, 10, 0, 6),
			13,
			UIKit.C_TEXT,
			UIKit.FONT_BOLD
		)
		local label = UIKit.label(
			section,
			"Target",
			"No target",
			UDim2.new(1, -10, 0, 16),
			UDim2.new(0, 10, 0, 28),
			11,
			UIKit.C_SUB,
			UIKit.FONT
		)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, -20, 0, 24)
		frame.Position = UDim2.new(0, 10, 0, 48)
		frame.BackgroundTransparency = 1
		frame.Parent = section
		local textBox = Instance.new("TextBox")
		textBox.Size = UDim2.new(1, -36, 1, 0)
		textBox.Position = UDim2.new(0, 0, 0, 0)
		textBox.BackgroundColor3 = UIKit.C_ENTRY
		textBox.TextColor3 = UIKit.C_TEXT
		textBox.PlaceholderText = "Username ou UserId..."
		textBox.PlaceholderColor3 = UIKit.C_SUB
		textBox.Text = ""
		textBox.TextSize = 12
		textBox.Font = UIKit.FONT
		textBox.BorderSizePixel = 0
		textBox.ClearTextOnFocus = false
		UIKit.corner(textBox, 4)
		textBox.Parent = frame
		local btn = UIKit.btn(
			frame,
			"Confirm",
			"→",
			UDim2.new(0, 30, 1, 0),
			UDim2.new(1, -30, 0, 0),
			UIKit.C_ACCENT,
			Color3.new(1, 1, 1)
		)
		local btn2 = UIKit.btn(section, "Refresh", "↺", UDim2.new(0, 26, 0, 20), UDim2.new(1, -32, 0, 6), UIKit.C_ENTRY)
		local label2 = UIKit.label(
			section,
			"NoPerm",
			"No gift permission",
			UDim2.new(1, -10, 0, 20),
			UDim2.new(0, 10, 0, 80),
			11,
			UIKit.C_SUB,
			UIKit.FONT,
			Enum.TextXAlignment.Center
		)
		label2.Visible = false
		local v2 = {}

		for k, v3 in GiftTreadmillConfig.TREADMILLS do
			local v4 = 78 + (k - 1) * 52
			local btn3 = UIKit.btn(
				section,
				"Btn_" .. v3.tag,
				v3.label,
				UDim2.new(1, -76, 0, 28),
				UDim2.new(0, 10, 0, v4),
				UIKit.C_ACCENT,
				Color3.new(1, 1, 1)
			)
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "Badge_" .. v3.tag
			textLabel.Size = UDim2.new(0, 58, 0, 28)
			textLabel.Position = UDim2.new(1, -66, 0, v4)
			textLabel.BackgroundColor3 = UIKit.C_ENTRY
			textLabel.BorderSizePixel = 0
			textLabel.Text = "..."
			textLabel.TextSize = 11
			textLabel.Font = UIKit.FONT_BOLD
			textLabel.TextColor3 = UIKit.C_TEXT
			textLabel.TextXAlignment = Enum.TextXAlignment.Center
			UIKit.corner(textLabel, 5)
			textLabel.Parent = section
			local label3 = UIKit.label(
				section,
				"Timer_" .. v3.tag,
				"",
				UDim2.new(1, -76, 0, 14),
				UDim2.new(0, 10, 0, v4 + 30),
				10,
				UIKit.C_SUB,
				UIKit.FONT
			)
			label3.Visible = false
			table.insert(v2, {
				btn = btn3,
				badge = textLabel,
				timerLbl = label3,
				tag = v3.tag,
				_periodStart = 0,
				_periodSeconds = 0
			})
		end

		local section2 = data.makeSection(5, 66)
		section2.Visible = false
		UIKit.label(
			section2,
			"T",
			"🍬 Candy — Self Gift",
			UDim2.new(1, -10, 0, 20),
			UDim2.new(0, 10, 0, 6),
			13,
			UIKit.C_TEXT,
			UIKit.FONT_BOLD
		)
		local btn3 = UIKit.btn(
			section2,
			"SelfGift",
			"Gift to myself",
			UDim2.new(1, -20, 0, 28),
			UDim2.new(0, 10, 0, 30),
			UIKit.C_ACCENT,
			Color3.new(1, 1, 1)
		)
		data.selection.onChanged(function()
			local offline = data.selection.getOffline()
			local v3 = data.selection.get()

			if offline then
				label.Text = "→ " .. offline.name .. " (offline)"
			elseif v3 then
				label.Text = "→ " .. v3.Name
			else
				label.Text = "No target"
			end
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applySelfGiftState(p)
			if not p.success then
				section2.Visible = false
				return
			end

			section2.Visible = true

			if p.hasCandy then
				btn3.Text = "✓ Already owned"
				btn3.BackgroundColor3 = UIKit.C_OFF
				btn3:SetAttribute("locked", true)
			else
				btn3.Text = "Gift to myself"
				btn3.BackgroundColor3 = UIKit.C_ACCENT
				btn3:SetAttribute("locked", false)
			end
		end

		local function applyGiftState(data2)
			if data2.success then
				label2.Visible = false

				for _, v3 in v2 do
					v3.btn.Visible = true
					v3.badge.Visible = true
				end

				for _, treadmill in data2.treadmills do
					for _, v4 in v2 do
						if v4.tag ~= treadmill.tag then
							continue
						end

						local v5 = treadmill.remaining > 0
						v4.badge.Text = treadmill.remaining .. "/" .. treadmill.quota
						v4.badge.TextColor3 = v5 and UIKit.C_ON or UIKit.C_OFF
						v4.btn.BackgroundColor3 = v5 and UIKit.C_ACCENT or UIKit.C_OFF
						v4.btn:SetAttribute("locked", not v5)
						v4._periodStart = treadmill.periodStart or 0
						v4._periodSeconds = treadmill.periodSeconds or 0
						local formatTimeRemaining = UIKit.formatTimeRemaining(v4._periodStart, v4._periodSeconds)
						v4.timerLbl.Text = formatTimeRemaining
						v4.timerLbl.Visible = formatTimeRemaining ~= ""
						break
					end
				end
			else
				label2.Text = data2.error or "Unavailable"
				label2.Visible = true

				for _, v3 in v2 do
					v3.btn.Visible = false
					v3.badge.Visible = false
					v3.timerLbl.Visible = false
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshSelfCandyState()
			task.spawn(function()
				applySelfGiftState(UIKit.invoke(Remotes.GetSelfCandyState)) -- equivalent call inferred; original call site unknown
			end)
		end

		local function refreshGiftState()
			task.spawn(function()
				applyGiftState(UIKit.invoke(Remotes.GetGiftTreadmillState))
			end)
			refreshSelfCandyState() -- equivalent call inferred; original call site unknown
		end

		btn3.MouseButton1Click:Connect(function()
			if btn3:GetAttribute("locked") then
				return
			end

			btn3.Active = false
			local v3 = UIKit.invoke(Remotes.SelfGiftCandy)
			btn3.Active = true

			if v3.success then
				data.setStatus("🍬 Candy Treadmill gifted to yourself!")
				NotificationSystem:ShowMessage("🍬 Candy Treadmill gifté !", Color3.fromRGB(255, 67, 199))
				btn3.Text = "✓ Already owned"
				btn3.BackgroundColor3 = UIKit.C_OFF
				btn3:SetAttribute("locked", true)
			else
				data.setStatus(v3.error or "Self gift failed", true)
				NotificationSystem:ShowMessage("✗ " .. (v3.error or "Self gift failed"), Color3.fromRGB(255, 60, 60))
			end
		end)
		task.spawn(function()
			while data.gui.Parent do
				task.wait(10)

				for _, v3 in v2 do
					if not (v3._periodStart > 0 and v3.timerLbl.Parent) then
						continue
					end

					local formatTimeRemaining = UIKit.formatTimeRemaining(v3._periodStart, v3._periodSeconds)
					v3.timerLbl.Text = formatTimeRemaining
					v3.timerLbl.Visible = formatTimeRemaining ~= ""
				end
			end
		end)

		for _, v3 in v2 do
			local v4 = v3
			v3.btn.MouseButton1Click:Connect(function()
				if v4.btn:GetAttribute("locked") then
					return
				end

				local offline = data.selection.getOffline()
				local v5 = data.selection.get()
				local userId, name

				if offline then
					userId = offline.userId
					name = offline.name
				elseif v5 and v5.Parent then
					userId = v5.UserId
					name = v5.Name
				else
					data.setStatus("Sélectionner un joueur d'abord", true)
					return
				end

				v4.btn.Active = false
				local v6 = UIKit.invoke(Remotes.GiftTreadmill, v4.tag, userId, name)
				v4.btn.Active = true

				if v6.success then
					local v7 = v6.offline and " (offline)" or ""
					data.setStatus("Gifted " .. v6.label .. " → " .. v6.targetName .. v7 .. "  (" .. v6.remaining .. " left)")
					NotificationSystem:ShowMessage(
						"✓ " .. v6.label .. " → " .. v6.targetName .. v7,
						Color3.fromRGB(0, 220, 110)
					)
					v4.badge.Text = v6.remaining .. "/" .. (v6.quota or "?")
					v4.badge.TextColor3 = v6.remaining > 0 and UIKit.C_ON or UIKit.C_OFF

					if v6.remaining == 0 then
						v4.btn.BackgroundColor3 = UIKit.C_OFF
						v4.btn:SetAttribute("locked", true)
					end

					if v6.offline then
						data.selection.select(nil)
					end

					task.spawn(refreshGiftState)
				else
					data.setStatus(v6.error or "Gift failed", true)
					NotificationSystem:ShowMessage("✗ " .. (v6.error or "Gift failed"), Color3.fromRGB(255, 60, 60))
				end
			end)
		end

		local function resolveOfflineTarget(text: string)
			local v3 = string.match(text, "^%s*(.-)%s*$") or ""

			if v3 == "" then
				return
			end

			btn.Active = false
			data.setStatus("Résolution en cours…")
			task.spawn(function()
				local result = tonumber(v3)
				local result2

				if result then
					local success
					success, result2 = pcall(function()
						return Players:GetNameFromUserIdAsync(result)
					end)

					if not success then
						btn.Active = true
						data.setStatus("UserId introuvable", true)
						return
					end
				else
					local success
					success, result = pcall(function()
						return Players:GetUserIdFromNameAsync(v3)
					end)

					if success then
						result2 = v3
					else
						btn.Active = true
						data.setStatus("Username introuvable", true)
						return
					end
				end

				data.selection.selectOffline(result, result2)
				textBox.Text = ""
				btn.Active = true
				data.setStatus("Cible offline : " .. result2 .. " [" .. result .. "]")
			end)
		end

		btn.MouseButton1Click:Connect(function()
			resolveOfflineTarget(textBox.Text)
		end)
		textBox.FocusLost:Connect(function(p)
			if p then
				resolveOfflineTarget(textBox.Text)
			end
		end)
		btn2.MouseButton1Click:Connect(refreshGiftState)
		return {
			refresh = refreshGiftState
		}
	end
}