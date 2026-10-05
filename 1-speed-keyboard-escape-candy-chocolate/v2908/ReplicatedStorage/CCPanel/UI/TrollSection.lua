local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIKit = require(script.Parent.UIKit)
local Remotes = require(ReplicatedStorage.CCPanel.Remotes)
return {
	build = function(data)
		local section = data.makeSection(3, 36)
		section.Visible = false
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, -14, 0, 20)
		frame.Position = UDim2.new(0, 10, 0, 6)
		frame.BackgroundTransparency = 1
		frame.Parent = section
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.Padding = UDim.new(0, 6)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.LayoutOrder = 1
		textLabel.AutomaticSize = Enum.AutomaticSize.X
		textLabel.Size = UDim2.new(0, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "Troll Actions"
		textLabel.TextSize = 13
		textLabel.Font = UIKit.FONT_BOLD
		textLabel.TextColor3 = UIKit.C_TEXT
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Parent = frame
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.LayoutOrder = 2
		textLabel2.AutomaticSize = Enum.AutomaticSize.X
		textLabel2.Size = UDim2.new(0, 0, 1, 0)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = ""
		textLabel2.TextSize = 12
		textLabel2.Font = UIKit.FONT_BOLD
		textLabel2.TextColor3 = UIKit.C_OFF
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.Visible = false
		textLabel2.Parent = frame
		local v = 0
		local btns = {}
		local heartbeatConnection = nil

		local function startCooldownUI()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			local lastTime = tick()

			for _, v2 in btns do
				v2.BackgroundColor3 = UIKit.C_ENTRY
				v2:SetAttribute("locked", true)
			end

			textLabel2.Text = "⏳ " .. 10 .. "s"
			textLabel2.Visible = true
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v2 = 10 - (tick() - lastTime)

				if not (v2 <= 0) then
					textLabel2.Text = "⏳ " .. math.ceil(v2) .. "s"
					return
				end

				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
				textLabel2.Visible = false

				for _, v3 in btns do
					v3.BackgroundColor3 = UIKit.C_ACCENT
					v3:SetAttribute("locked", false)
				end
			end)
		end

		local function applyState(p)
			btns = {}

			for _, button in section:GetChildren() do
				if button:IsA("TextButton") then
					button:Destroy()
				end
			end

			if not p.success then
				section.Visible = false
				return
			end

			local actions = p.actions or {}
			local v2 = math.ceil(#actions / 2)
			section.Size = UDim2.new(1, 0, 0, v2 * 32 + 28 + 6)
			section.Visible = true
			local v3 = tick() - v < 10

			for i, action in ipairs(actions) do
				local v4 = (i - 1) % 2
				local v5 = math.floor((i - 1) / 2)
				local uDim = v4 == 0 and UDim2.new(0, 10, 0, 0) or UDim2.new(0.5, 3, 0, 0)
				local btn = UIKit.btn(
					section,
					"Troll_" .. action.id,
					action.label,
					UDim2.new(0.5, -7, 0, 26),
					UDim2.new(uDim.X.Scale, uDim.X.Offset, 0, v5 * 32 + 28),
					v3 and UIKit.C_ENTRY or UIKit.C_ACCENT,
					Color3.new(1, 1, 1)
				)

				if v3 then
					btn:SetAttribute("locked", true)
				end

				table.insert(btns, btn)
				local v6 = action
				btn.MouseButton1Click:Connect(function()
					local v7 = data.selection.get()

					if not (v7 and v7.Parent) then
						data.setStatus("Select a player first", true)
						return
					end

					local now = tick()

					if now - v < 10 then
						return
					end

					v = now
					startCooldownUI()
					Remotes.TrollAction:fire(v6.id, v7.UserId)
					data.setStatus(v6.label .. " → " .. v7.Name)
				end)
			end
		end

		return {
			refresh = function()
				task.spawn(function()
					applyState(UIKit.invoke(Remotes.GetTrollState))
				end)
			end
		}
	end
}