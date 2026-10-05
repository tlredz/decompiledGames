local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.Touch }
local Window = {
	Valid = true,
	AutoComplete = nil,
	ProcessEntry = nil,
	OnTextChanged = nil,
	Cmdr = nil,
	HistoryState = nil
}
local frame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Cmdr"):WaitForChild("Frame")
local line = frame:WaitForChild("Line")
local entry = frame:WaitForChild("Entry")
line.Parent = nil

function Window.UpdateLabel(p)
	entry.TextLabel.Text = localPlayer.Name .. "@" .. p.Cmdr.PlaceName .. "$"
end

function Window.GetLabel(_)
	return entry.TextLabel.Text
end

function Window:UpdateWindowHeight()
	local v2 = frame.UIListLayout.AbsoluteContentSize.Y + frame.UIPadding.PaddingTop.Offset + frame.UIPadding.PaddingBottom.Offset
	frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, (math.clamp(v2, 0, 300)))
	frame.CanvasPosition = Vector2.new(0, v2)
end

function Window:AddLine(p2, options)
	local color = options or {}
	local v3 = tostring(p2)

	if #v3 >= 199999 then
		v3 = v3:sub(1, 199999)
	end

	local v4 = typeof(color) == "Color3" and {
		Color = color
	} or color

	if #v3 == 0 then
		Window:UpdateWindowHeight()
		return
	end

	local emulateTabstops = self.Cmdr.Util.EmulateTabstops(v3 or "nil", 8)
	local clone = line:Clone()
	clone.Text = emulateTabstops
	clone.TextColor3 = v4.Color or clone.TextColor3
	clone.RichText = v4.RichText or false
	clone.Parent = frame
end

function Window:IsVisible()
	return frame.Visible
end

function Window:SetVisible(visible)
	frame.Visible = visible

	if visible then
		self.PreviousChatWindowConfigurationEnabled = TextChatService.ChatWindowConfiguration.Enabled
		self.PreviousChatInputBarConfigurationEnabled = TextChatService.ChatInputBarConfiguration.Enabled
		TextChatService.ChatWindowConfiguration.Enabled = false
		TextChatService.ChatInputBarConfiguration.Enabled = false
		entry.TextBox:CaptureFocus()
		self:SetEntryText("")

		if self.Cmdr.ActivationUnlocksMouse then
			self.PreviousMouseBehavior = UserInputService.MouseBehavior
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	else
		TextChatService.ChatWindowConfiguration.Enabled = self.PreviousChatWindowConfigurationEnabled == nil or self.PreviousChatWindowConfigurationEnabled
		TextChatService.ChatInputBarConfiguration.Enabled = self.PreviousChatInputBarConfigurationEnabled == nil or self.PreviousChatInputBarConfigurationEnabled
		entry.TextBox:ReleaseFocus()
		self.AutoComplete:Hide()

		if self.PreviousMouseBehavior then
			UserInputService.MouseBehavior = self.PreviousMouseBehavior
			self.PreviousMouseBehavior = nil
		end
	end
end

function Window:Hide()
	return self:SetVisible(false)
end

function Window:Show()
	return self:SetVisible(true)
end

function Window:SetEntryText(text)
	entry.TextBox.Text = text

	if self:IsVisible() then
		entry.TextBox:CaptureFocus()
		entry.TextBox.CursorPosition = #text + 1
		Window:UpdateWindowHeight()
	end
end

function Window:GetEntryText()
	return entry.TextBox.Text:gsub("\t", "")
end

function Window:SetIsValidInput(valid, errorText)
	entry.TextBox.TextColor3 = valid and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 73, 73)
	self.Valid = valid
	self._errorText = errorText
end

function Window.HideInvalidState(_)
	entry.TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
end

function Window:LoseFocus(p)
	local text = entry.TextBox.Text
	self:ClearHistoryState()

	if frame.Visible and not GuiService.MenuIsOpen then
		entry.TextBox:CaptureFocus()
	elseif GuiService.MenuIsOpen and frame.Visible then
		self:Hide()
	end

	if p and self.Valid then
		wait()
		self:SetEntryText("")
		self.ProcessEntry(text)
	elseif p then
		self:AddLine(self._errorText, Color3.fromRGB(255, 153, 153))
	end
end

function Window:TraverseHistory(p)
	local history = self.Cmdr.Dispatcher:GetHistory()

	if self.HistoryState == nil then
		self.HistoryState = {
			Position = #history + 1,
			InitialText = self:GetEntryText()
		}
	end

	self.HistoryState.Position = math.clamp(self.HistoryState.Position + p, 1, #history + 1)
	self:SetEntryText(self.HistoryState.Position == #history + 1 and self.HistoryState.InitialText or history[self.HistoryState.Position])
end

function Window:ClearHistoryState()
	self.HistoryState = nil
end

function Window:SelectVertical(p)
	if self.AutoComplete:IsVisible() and not self.HistoryState then
		self.AutoComplete:Select(p)
	else
		self:TraverseHistory(p)
	end
end

local now = 0
local v2 = 0

function Window:BeginInput(data, p)
	if GuiService.MenuIsOpen then
		self:Hide()
	end

	if p and self:IsVisible() == false then
		return
	end

	if self.Cmdr.ActivationKeys[data.KeyCode] then
		if self.Cmdr.MashToEnable and not self.Cmdr.Enabled then
			if tick() - now < 1 then
				if v2 >= 5 then
					return self.Cmdr:SetEnabled(true)
				else
					v2 += 1
				end
			else
				v2 = 1
			end

			now = tick()
		elseif self.Cmdr.Enabled then
			self:SetVisible(not self:IsVisible())
			wait()
			self:SetEntryText("")

			if GuiService.MenuIsOpen then
				self:Hide()
			end
		end
	elseif self.Cmdr.Enabled == false or not self:IsVisible() then
		if self:IsVisible() then
			self:Hide()
		end
	elseif self.Cmdr.HideOnLostFocus and table.find(v, data.UserInputType) then
		local position = data.Position
		local absolutePosition = frame.AbsolutePosition
		local absoluteSize = frame.AbsoluteSize

		if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
			self:Hide()
		end
	elseif data.KeyCode == Enum.KeyCode.Down then
		self:SelectVertical(1)
	elseif data.KeyCode == Enum.KeyCode.Up then
		self:SelectVertical(-1)
	elseif data.KeyCode == Enum.KeyCode.Return then
		wait()
		self:SetEntryText(self:GetEntryText():gsub("\n", ""):gsub("\r", ""))
	elseif data.KeyCode == Enum.KeyCode.Tab then
		local selectedItem = self.AutoComplete:GetSelectedItem()
		local entryText = self:GetEntryText()

		if selectedItem and not (entryText:sub(#entryText, #entryText):match("%s") and self.AutoComplete.LastItem) then
			local v3 = selectedItem[2]
			local command = self.AutoComplete.Command
			local alias, v4

			if command then
				local arg = self.AutoComplete.Arg
				alias = command.Alias

				if self.AutoComplete.NumArgs == #command.ArgumentDefinitions then
					v4 = false
				else
					v4 = self.AutoComplete.IsPartial == false
				end

				local arguments = command.Arguments

				for i = 1, #arguments do
					local argument = arguments[i]
					local rawSegments = argument.RawSegments

					if argument == arg then
						rawSegments[#rawSegments] = v3
					end

					local v5 = argument.Prefix .. table.concat(rawSegments, ",")

					if v5:find(" ") or v5 == "" then
						v5 = ("%q"):format(v5)
					end

					alias = ("%s %s"):format(alias, v5)

					if argument == arg then
						break
					end
				end
			else
				alias = v3
				v4 = true
			end

			wait()
			self:SetEntryText(alias .. (v4 and " " or ""))
		else
			wait()
			self:SetEntryText(self:GetEntryText())
		end
	else
		self:ClearHistoryState()
	end
end

entry.TextBox.FocusLost:Connect(function(p)
	return Window:LoseFocus(p)
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	return Window:BeginInput(input, gameProcessed)
end)
entry.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	frame.CanvasPosition = Vector2.new(0, frame.AbsoluteCanvasSize.Y)

	if entry.TextBox.Text:match("\t") then
		entry.TextBox.Text = entry.TextBox.Text:gsub("\t", "")
	elseif Window.OnTextChanged then
		return Window.OnTextChanged(entry.TextBox.Text)
	end
end)
frame.ChildAdded:Connect(function()
	task.defer(Window.UpdateWindowHeight)
end)
return Window