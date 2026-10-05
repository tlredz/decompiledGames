local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CommandCompletion = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Admin"):WaitForChild("CommandCompletion"))
return {
	bind = function(parent, instance, list)
		local command = parent.Command
		local frame = Instance.new("Frame")
		frame.Name = "Suggestions"
		frame.AnchorPoint = Vector2.new(0, 1)
		frame.Position = UDim2.fromScale(0.025, 0.86)
		frame.Size = UDim2.fromScale(0.95, 0.43)
		frame.BackgroundColor3 = Color3.fromRGB(23, 35, 46)
		frame.BorderSizePixel = 0
		frame.ZIndex = 105
		frame.Visible = false
		frame.Parent = parent
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = Color3.fromRGB(73, 112, 129)
		uIStroke.Transparency = 0.25
		uIStroke.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Hint"
		textLabel.Size = UDim2.fromScale(0.96, 0.15)
		textLabel.Position = UDim2.fromScale(0.02, 0)
		textLabel.Text = "TAB TO COMPLETE  ·  ↑ ↓ SELECT  ·  TAP A ROW"
		textLabel.TextColor3 = Color3.fromRGB(147, 191, 209)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamMedium
		textLabel.TextScaled = true
		textLabel.ZIndex = 106
		textLabel.Parent = frame
		local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint.MaxTextSize = 12
		uITextSizeConstraint.MinTextSize = 8
		uITextSizeConstraint.Parent = textLabel
		local v = {}
		local v2 = {}
		local v3 = 1
		local flag = true
		local connections = {}
		local v4 = false
		local v5 = nil
		local v6 = nil
		local now = -1e999

		-- equivalent calls inferred from this helper; original call sites unknown
		local function connect(object, refresh)
			table.insert(connections, object:Connect(refresh))
		end

		local function paint()
			for k, v7 in v do
				local v8 = v2[k]
				v7.Visible = v8 ~= nil

				if not v8 then
					continue
				end

				v7.Text = v8.Label
				v7.BackgroundTransparency = k == v3 and 0 or 1
			end
		end

		local function refresh()
			if not flag or v4 then
				return
			end

			if not parent.Visible then
				frame.Visible = false
				return
			end

			if not command:IsFocused() then
				task.delay(0.2, function()
					if flag and not (command:IsFocused() or v6) then
						frame.Visible = false
					end
				end)
				return
			end

			v2 = CommandCompletion.suggest(
				command.Text,
				command.CursorPosition > 0 and command.CursorPosition or #command.Text + 1,
				instance:GetAttribute("AdminLevel") or 0,
				Players:GetPlayers(),
				instance:GetAttribute("CreatorAuthorized") == true
			)
			v3 = math.clamp(v3, 1, (math.max(1, #v2)))
			frame.Visible = #v2 > 0
			paint()
		end

		local function accept(p)
			local v7 = type(p) == "table" and p or v2[p or v3]

			if not v7 then
				return
			end

			v6 = nil
			v4 = true
			command.Text = v7.Text
			command:CaptureFocus()
			command.CursorPosition = v7.Cursor
			command.SelectionStart = -1
			v4 = false
			v3 = 1
			v5 = nil
			task.defer(refresh)
		end

		local function tabComplete()
			if os.clock() - now < 0.1 then
				return
			end

			now = os.clock()
			local v7 = v2[v3]
			task.defer(function()
				if flag then
					accept(v7)
				end
			end)
		end

		for i = 1, 6 do
			local textButton = Instance.new("TextButton")
			textButton.Name = "Suggestion" .. i
			textButton.Position = UDim2.fromScale(0.015, (i - 1) * 0.138 + 0.155)
			textButton.Size = UDim2.fromScale(0.97, 0.132)
			textButton.BackgroundColor3 = Color3.fromRGB(42, 65, 82)
			textButton.BorderSizePixel = 0
			textButton.Font = Enum.Font.Code
			textButton.TextColor3 = Color3.fromRGB(229, 239, 245)
			textButton.TextScaled = true
			textButton.TextXAlignment = Enum.TextXAlignment.Left
			textButton.ZIndex = 106
			textButton.AutoButtonColor = true
			textButton.Parent = frame
			v[i] = textButton
			local uIPadding = Instance.new("UIPadding")
			uIPadding.PaddingLeft = UDim.new(0.015, 0)
			uIPadding.PaddingRight = UDim.new(0.015, 0)
			uIPadding.Parent = textButton
			local uITextSizeConstraint2 = Instance.new("UITextSizeConstraint")
			uITextSizeConstraint2.MaxTextSize = 16
			uITextSizeConstraint2.MinTextSize = 8
			uITextSizeConstraint2.Parent = textButton
			local v7 = i
			table.insert(connections, textButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					v6 = v2[v7]
				end
			end))
			local v8 = i
			table.insert(connections, textButton.Activated:Connect(function()
				accept(v6 or v8)
			end))
		end

		table.insert(connections, command:GetPropertyChangedSignal("Text"):Connect(function()
			v3 = 1
			task.defer(refresh)
		end))
		table.insert(connections, command:GetPropertyChangedSignal("CursorPosition"):Connect(function()
			task.defer(refresh)
		end))
		table.insert(connections, command.Focused:Connect(function()
			v5 = nil
			refresh()
		end))
		table.insert(connections, command.FocusLost:Connect(function(_, p)
			if p and p.KeyCode == Enum.KeyCode.Tab and frame.Visible then
				tabComplete()
			else
				task.delay(0.2, function()
					if flag and not (command:IsFocused() or v6) then
						frame.Visible = false
					end
				end)
			end
		end))
		connect(parent:GetPropertyChangedSignal("Visible"), refresh) -- equivalent call inferred; original call site unknown
		connect(instance:GetAttributeChangedSignal("AdminLevel"), refresh) -- equivalent call inferred; original call site unknown
		connect(instance:GetAttributeChangedSignal("CreatorAuthorized"), refresh) -- equivalent call inferred; original call site unknown
		connect(Players.PlayerAdded, refresh) -- equivalent call inferred; original call site unknown
		table.insert(connections, Players.PlayerRemoving:Connect(function()
			task.defer(refresh)
		end))
		table.insert(connections, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				task.delay(0.03, function()
					if flag then
						v6 = nil

						if not command:IsFocused() then
							frame.Visible = false
						end
					end
				end)
			end
		end))
		table.insert(connections, UserInputService.InputBegan:Connect(function(input)
			if not (parent.Visible and command:IsFocused()) then
				return
			end

			if (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) and (input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down) then
				v5 = math.clamp((v5 or #list + 1) + (input.KeyCode == Enum.KeyCode.Up and -1 or 1), 1, #list + 1)
				local text = list[v5] or ";"
				task.defer(function()
					if flag and command:IsFocused() then
						command.Text = text
						command.CursorPosition = #text + 1
					end
				end)
			elseif frame.Visible and input.KeyCode == Enum.KeyCode.Tab then
				tabComplete()
			elseif frame.Visible and (input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.Down) then
				v3 = (v3 - 1 + (input.KeyCode == Enum.KeyCode.Up and -1 or 1)) % #v2 + 1
				paint()
				local cursorPosition = command.CursorPosition
				task.defer(function()
					if flag and command:IsFocused() then
						v4 = true
						command.CursorPosition = cursorPosition
						command.SelectionStart = -1
						v4 = false
					end
				end)
			end
		end))
		return {
			destroy = function()
				flag = false

				for _, connection in connections do
					connection:Disconnect()
				end

				frame:Destroy()
			end
		}
	end
}