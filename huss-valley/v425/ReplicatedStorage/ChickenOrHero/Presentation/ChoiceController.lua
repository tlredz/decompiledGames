local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local ParticipantDirectory = require(script.Parent.ParticipantDirectory)
local VerifiedName = require(script.Parent.VerifiedName)
local ChoiceView = require(script.Parent.ChoiceView)
local ChoiceController = {}
ChoiceController.__index = ChoiceController

function ChoiceController.new(gui, session, action)
	ChoiceView.apply(gui)
	local object = setmetatable({
		gui = gui,
		player = Players.LocalPlayer,
		session = session,
		action = action,
		panel = gui.MainFrame.Choices,
		template = gui.Templates.ChoiceOption,
		key = nil,
		buttons = {},
		connections = {},
		lifetime = {},
		pendingUntil = 0,
		mode = ""
	}, ChoiceController)
	table.insert(object.lifetime, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		if object.panel.Visible and UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			for _, button in object.buttons do
				if not button.Visible then
					continue
				end

				GuiService.SelectedObject = button
				return
			end
		end
	end))
	table.insert(object.lifetime, UserInputService.InputChanged:Connect(function(input)
		local press = object.press

		if not press then
			return
		end

		if (input == press.input or input.UserInputType == Enum.UserInputType.MouseMovement and press.input.UserInputType == Enum.UserInputType.MouseButton1) and (Vector2.new(
			input.Position.X,
			input.Position.Y
		) - press.position).Magnitude > 10 then
			press.dragged = true
		end
	end))
	table.insert(object.lifetime, object.panel.Search:GetPropertyChangedSignal("Text"):Connect(function()
		object:filter(true)
	end))
	table.insert(object.lifetime, object.panel.Reveal.Changed:Connect(function()
		ChoiceView.layout(gui, object.mode)
	end))
	return object
end

function ChoiceController:clear()
	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.panel) then
		GuiService.SelectedObject = nil
	end

	for _, connection in self.connections do
		connection:Disconnect()
	end

	table.clear(self.connections)

	for _, button in self.panel.PlayerPicker.Options:GetChildren() do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	table.clear(self.buttons)
	self.press = nil
	self.sent = nil
end

function ChoiceController:filter(p)
	if self.mode ~= "select" then
		return
	end

	local v = self.panel.Search.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
	local buttons = {}

	for _, button in self.buttons do
		local visible = v == "" or (button:GetAttribute("SearchText") or ""):find(v, 1, true) ~= nil
		button.Visible = visible

		if visible then
			table.insert(buttons, button)
		end
	end

	local options = self.panel.PlayerPicker.Options

	if p then
		options.CanvasPosition = Vector2.zero
		self.press = nil
	end

	self.panel.PlayerPicker.Empty.Visible = #buttons == 0
	self.panel.Count.Text = (#buttons == #self.buttons and ("%d runners"):format(#buttons) or ("%d of %d runners"):format(
		#buttons,
		#self.buttons
	)) .. " · Scroll to browse"
	local pickerColumns = self.panel:GetAttribute("PickerColumns") or 2

	for k, v2 in buttons do
		v2.NextSelectionUp = buttons[math.max(1, k - pickerColumns)]
		v2.NextSelectionDown = buttons[math.min(#buttons, k + pickerColumns)]
		v2.NextSelectionLeft = buttons[math.max(1, k - 1)]
		v2.NextSelectionRight = buttons[math.min(#buttons, k + 1)]
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(options) and not GuiService.SelectedObject.Visible then
		GuiService.SelectedObject = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and buttons[1] or nil
	end
end

function ChoiceController:bind(sent, callback)
	table.insert(self.buttons, sent)
	local backgroundColor3 = sent.BackgroundColor3

	local function hover(p)
		if self.sent == sent then
			return
		end

		TweenService:Create(sent, TweenInfo.new(0.12), {
			BackgroundColor3 = p and backgroundColor3:Lerp(Color3.new(1, 1, 1), 0.07) or backgroundColor3
		}):Play()
		sent.Border.Transparency = p and 0.18 or 0.65
	end

	for _, v in { sent.MouseEnter, sent.SelectionGained } do
		table.insert(self.connections, v:Connect(function()
			hover(true)
		end))
	end

	for _, v in { sent.MouseLeave, sent.SelectionLost } do
		table.insert(self.connections, v:Connect(function()
			if self.sent == sent then
				return
			end

			TweenService:Create(sent, TweenInfo.new(0.12), {
				BackgroundColor3 = backgroundColor3
			}):Play()
			sent.Border.Transparency = 0.65
		end))
	end

	table.insert(self.connections, sent.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.press = {
				input = input,
				button = sent,
				position = Vector2.new(input.Position.X, input.Position.Y),
				canvas = self.panel.PlayerPicker.Options.CanvasPosition.Y,
				dragged = false
			}
		end
	end))
	table.insert(self.connections, sent.Activated:Connect(function(p)
		if not self.panel.Visible or not sent.Visible or os.clock() < self.pendingUntil then
			return
		end

		local press = self.press

		if p and (p.UserInputType == Enum.UserInputType.Touch or p.UserInputType == Enum.UserInputType.MouseButton1) and press and press.button == sent and (press.dragged or math.abs(self.panel.PlayerPicker.Options.CanvasPosition.Y - press.canvas) > 6) then
			return
		end

		self.pendingUntil = os.clock() + 0.8

		if self.sent and self.sent.Parent and self.mode == "select" then
			ChoiceView.selected(self.sent, false)
		end

		self.sent = sent

		if self.mode == "select" then
			ChoiceView.selected(sent, true)
		end

		self.panel.Status.Text = "Choice sent…"
		self.panel.Search:ReleaseFocus()
		callback()
	end))
end

function ChoiceController:update(p)
	local session = self.session
	local player = self.player
	local panel = self.panel
	local mode = p == "SelectHero" and session:GetAttribute("LeadUserId") == player.UserId and "select" or p == "HeroChoice" and session:GetAttribute("SelectedUserId") == player.UserId and "choice" or ""
	self.gui.DisplayOrder = mode == "" and 10 or 78
	player:SetAttribute("ReleaseCameraForUI", mode ~= "" or nil)
	local v2 = {}

	if mode == "select" then
		for _, v3 in ParticipantDirectory.list() do
			if v3 ~= player and v3:GetAttribute("GameRole") == "Runner" then
				table.insert(v2, v3)
			end
		end
	end

	table.sort(v2, function(a, b)
		local displayName = a.DisplayName:lower()
		local displayName2 = b.DisplayName:lower()

		if displayName == displayName2 then
			return a.UserId < b.UserId
		end

		return displayName < displayName2
	end)
	local v3 = {}

	for _, v4 in v2 do
		table.insert(v3, tostring(v4.UserId) .. ":" .. v4.DisplayName)
	end

	local v4 = mode .. ":" .. table.concat(v3, ",") .. ":" .. tostring(session:GetAttribute("RunNumber")) .. ":" .. tostring(session:GetAttribute("LeadUserId"))

	if self.key ~= v4 then
		local v5 = self.mode ~= mode
		self:clear()
		self.key = v4
		self.mode = mode
		self.pendingUntil = 0
		panel.PlayerPicker.Visible = mode == "select"
		panel.RunnerChoice.Visible = mode == "choice"
		panel.Visible = mode ~= ""
		panel:SetAttribute("Mode", mode)

		if v5 then
			panel.Search:ReleaseFocus()
			panel.Search.Text = ""
		end

		ChoiceView.layout(self.gui, mode)

		if mode == "select" then
			panel.Title.Text = "Choose a runner"
			panel.Hint.Text = "Who will face Chicken or Hero? Tap their card."
			local options = panel.PlayerPicker.Options

			if v5 then
				options.CanvasPosition = Vector2.zero
			end

			for k, v6 in v2 do
				local clone = self.template:Clone()
				clone.Name = "Player_" .. v6.UserId
				clone.LayoutOrder = k
				clone.Visible = true
				local isBot

				if type(v6) == "table" then
					isBot = v6.IsBot
				else
					isBot = false
				end

				clone.Title.RichText = true
				clone.Title.Text = VerifiedName.player(v6)
				clone.Description.Text = isBot and "" or "@" .. v6.Name
				clone.Description.Visible = not isBot
				clone:SetAttribute("SearchText", (v6.DisplayName .. " " .. v6.Name):lower())
				local avatarUserId

				if isBot then
					avatarUserId = v6:GetAttribute("AvatarUserId") or 0
				else
					avatarUserId = v6.UserId
				end

				clone.Avatar.Image = not (avatarUserId > 0) and "" or ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(avatarUserId) or ""
				clone.Avatar.Fallback.Visible = avatarUserId <= 0
				clone.Avatar.Fallback.Text = v6.DisplayName:sub(1, 1):upper()
				clone.Parent = options
				local v7 = v6
				self:bind(clone, function()
					self.action:FireServer("SelectHero", v7.UserId)
				end)
			end

			self:filter(false)
		elseif mode == "choice" then
			panel.Title.Text = "Chicken or Hero?"
			local v6 = nil

			for _, v8 in ParticipantDirectory.list() do
				if v8.UserId ~= session:GetAttribute("LeadUserId") then
					continue
				end

				v6 = v8
				break
			end

			panel.Hint.RichText = true
			panel.Hint.Text = (v6 and VerifiedName.player(v6) or "The Catcher") .. " challenged you. Choose your crossing."

			for _, v8 in { "Chicken", "Hero" } do
				local v9 = v8
				self:bind(panel.RunnerChoice.Options[v8], function()
					self.action:FireServer("HeroChoice", v9)
				end)
			end

			self.buttons[1].NextSelectionRight = self.buttons[2]
			self.buttons[1].NextSelectionDown = self.buttons[2]
			self.buttons[2].NextSelectionLeft = self.buttons[1]
			self.buttons[2].NextSelectionUp = self.buttons[1]
		end

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			for _, button in self.buttons do
				if not button.Visible then
					continue
				end

				GuiService.SelectedObject = button
				break
			end
		end

		if panel.Visible and v5 then
			panel.Reveal.Value = 0.98
			TweenService:Create(panel.Reveal, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Value = 1
			}):Play()
		end
	end

	if mode ~= "" then
		ChoiceView.layout(self.gui, mode)

		if self.columns ~= panel:GetAttribute("PickerColumns") then
			self.columns = panel:GetAttribute("PickerColumns")
			self:filter(false)
		end

		if os.clock() >= self.pendingUntil then
			if self.sent and self.sent.Parent and mode == "select" then
				ChoiceView.selected(self.sent, false)
				self.sent = nil
			end

			local v5 = math.max(0, (math.ceil((session:GetAttribute("EndsAt") or 0) - workspace:GetServerTimeNow())))
			panel.Status.Text = mode == "select" and #v2 == 0 and "Waiting for runners…" or ("%ds remaining"):format(v5)
		end
	end
end

function ChoiceController:destroy()
	self:clear()

	for _, connection in self.lifetime do
		connection:Disconnect()
	end

	self.gui.DisplayOrder = 10
	self.panel.Search:ReleaseFocus()
	self.panel.Visible = false
	self.player:SetAttribute("ReleaseCameraForUI", nil)
end

return ChoiceController