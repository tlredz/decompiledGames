local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("cmdrService")
local import4 = _G.import("cmdrAutocompleteService")
local import5 = _G.import("cmdrTabUtil")
local import6 = _G.import("iterUtil")
local import7 = _G.import("clientUtil")
local import8 = _G.import("viewImports")
local basic = import8:get("basic")
local v = import8:get("item")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local function flattenGroups(currentGroups)
	if not (currentGroups and currentGroups.CategoryOrder and currentGroups.ByCategory) then
		return
	end

	local result = {}

	for _, v2 in ipairs(currentGroups.CategoryOrder) do
		local v3 = currentGroups.ByCategory[v2] or {}

		for i = 1, #v3 do
			result[#result + 1] = v3[i]
		end
	end

	return result
end

local model = import.model(basic.ConstrainedElement, basic.Corner)

function model.init(p)
	local v2 = {
		Size = UDim2.new(1, 0, 1, 0),
		AspectRatio = 1.5,
		BackgroundTransparency = 0.4,
		BackgroundColor3 = Color3.fromRGB(),
		CornerRadius = UDim.new(0.25),
		LayoutOrder = 1
	}
	local icon

	if p.Icon then
		icon = import.make(basic.ImageLabel, {
			Location = "Center",
			Size = UDim2.new(0.8, 0, 0.8, 0),
			Image = p.Icon
		}) or nil
	end

	return v2, {
		Icon = icon,
		Key = p.Key and import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(1, 0, 0.8, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = p.Key,
			Font = Enum.Font.SourceSansBold,
			StrokeWidth = 1
		})
	}
end

local model2 = import.model(basic.EmptyList)

function model2.init(p)
	local keys = p.Keys
	local count = 0
	local v2 = {}

	for i, key in ipairs(keys) do
		count += 1
		v2[count] = import.make(model, {
			Key = key,
			LayoutOrder = count
		})

		if not (i < #keys) then
			continue
		end

		count += 1
		v2[count] = import.make(basic.TextLabel, {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "/",
			Font = Enum.Font.SourceSansBold,
			StrokeWidth = 1,
			LayoutOrder = count
		})
	end

	local dict = import6.toDict(v2, function(p2, p3)
		return p2, p3
	end)
	return {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Padding = UDim.new(0.05)
	}, dict
end

local model3 = import.model(basic.EmptyList)

function model3.init(data)
	local v2 = {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0.05, 0)
	}
	local keyContainer

	if data.Key or data.Icon then
		keyContainer = import.make(model, {
			Icon = data.Icon,
			Key = data.Key
		}) or nil
	end

	local keysContainer

	if data.Keys then
		keysContainer = import.make(model2, {
			Keys = data.Keys
		}) or nil
	end

	return v2, {
		KeyContainer = keyContainer,
		KeysContainer = keysContainer,
		TextLabel = import.make(basic.TextLabel, {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = data.Text,
			Font = Enum.Font.SourceSansBold,
			StrokeWidth = 1,
			LayoutOrder = 2
		}, {
			Shadow = import.make(import.wrap(basic.Element, basic.Gradient), {
				Position = UDim2.new(data.Pos, 0, 0.5, 0),
				Size = UDim2.new(data.Siz, 0, 0.9, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(),
				GradientRotation = 90,
				GradientTransparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.2, 0.7),
					NumberSequenceKeypoint.new(0.5, 0.1),
					NumberSequenceKeypoint.new(0.8, 0.7),
					NumberSequenceKeypoint.new(1, 1)
				}),
				ZIndex = -1
			})
		})
	}
end

local model4 = import.model(basic.EmptyList)

function model4.init()
	return {
		Position = UDim2.new(0, 0, -0.5, 0),
		Size = UDim2.new(1, 0, 0.4, 0),
		Padding = UDim.new(0.03, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Right
	}, {
		Select = import.make(model3, {
			Icon = "rbxassetid://84416159332428",
			Text = "Select",
			Pos = -0.75,
			Siz = 1.75
		}),
		TabComplete = import.make(model3, {
			Key = "TAB",
			Text = "Autocomplete",
			Pos = -0.35,
			Siz = 1.35
		}),
		Run = import.make(model3, {
			Icon = "rbxassetid://82766860281841",
			Text = "Run",
			Pos = -1.15,
			Siz = 2.15
		}),
		Close = import.make(model3, {
			Keys = { "P", "ESC" },
			Text = "Close",
			Pos = -1.95,
			Siz = 2.95
		})
	}
end

local model5 = import.model(basic.EmptyList)

function model5.init(p)
	return {
		Size = UDim2.new(1, 0, 0, 26),
		VerticalAlignment = Enum.VerticalAlignment.Center
	}, {
		Label = import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(1, 0, 0.8, 0),
			TextColor3 = Color3.fromRGB(160, 160, 160),
			Text = string.upper(p.Text),
			Font = Enum.Font.SourceSansBold,
			StrokeWidth = 1
		})
	}
end

local model6 = import.model(basic.EmptyList)

function model6.init(p)
	local entry = p.Entry
	local isSelected = p.IsSelected
	local destructive = entry.Destructive
	local preview = entry.Preview
	local color = destructive and Color3.fromRGB(255, 110, 110) or Color3.fromRGB(85, 170, 255)
	local color2 = destructive and Color3.fromRGB(255, 190, 190) or Color3.fromRGB(255, 255, 255)
	local v2 = preview and 56 or 0
	return {
		Size = UDim2.new(1, 0, 0, preview and 62 or 44),
		BackgroundTransparency = isSelected and 0.7 or 0.85,
		BackgroundColor3 = color2,
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}, {
		Content = import.make(basic.Element, {
			Size = UDim2.new(0.96, 0, 1, 0),
			Position = UDim2.new(0, 16, 0, 0),
			BackgroundTransparency = 1
		}, {
			Accent = import.make(basic.Element, {
				Position = UDim2.new(-0.01, 0, 0.5, 0),
				Size = UDim2.new(0, 3, 0.6, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = color,
				BackgroundTransparency = isSelected and 0 or 1,
				BorderSizePixel = 0
			}),
			ItemFrame = preview and import.make(v.RewardFrame, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, 48, 0, 48),
				NoAspectRatio = true,
				ItemType = preview.ItemType,
				Id = preview.Id,
				Hoverable = false,
				ZIndex = 2
			}) or nil,
			NameLabel = import.make(basic.TextLabel, {
				Position = UDim2.new(0, v2, 0.5, 0),
				Size = UDim2.new(0, 220, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				Text = entry.Name,
				TextColor3 = destructive and Color3.fromRGB(255, 150, 150) or nil,
				Font = Enum.Font.SourceSansBold,
				StrokeWidth = 1
			}),
			DescriptionLabel = import.make(basic.TextLabel, {
				Position = UDim2.new(0, v2 + 240, 0.5, 0),
				Size = UDim2.new(1, -(v2 + 580), 0.4, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				TextColor3 = Color3.fromRGB(170, 170, 170),
				Text = entry.Description,
				Font = Enum.Font.SourceSansBold,
				StrokeWidth = 1,
				TextTruncate = Enum.TextTruncate.AtEnd
			}),
			ArgsLabel = import.make(basic.TextLabel, {
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 320, 0.4, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextScaled = true,
				TextColor3 = Color3.fromRGB(210, 210, 210),
				Text = entry.ArgsText,
				Font = Enum.Font.SourceSansBold,
				StrokeWidth = 1
			})
		})
	}
end

local model7 = import.model(basic.ScrollingList, basic.Stroke, basic.Padding)

function model7.init(data)
	local groups = data.Groups
	local selectedIndex = data.SelectedIndex or 1
	local v2 = {}
	local rowKeyByIndex = {}
	local count = 0
	local count2 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addHeader(text)
		count += 1
		v2["h" .. count] = import.make(model5, {
			Text = text,
			LayoutOrder = count
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addRow(entry)
		count2 += 1
		count += 1
		local v4 = tostring(count2)
		rowKeyByIndex[count2] = v4
		v2[v4] = import.make(model6, {
			Entry = entry,
			IsSelected = count2 == selectedIndex,
			LayoutOrder = count
		})
	end

	if groups and groups.CategoryOrder and groups.ByCategory then
		for _, v4 in ipairs(groups.CategoryOrder) do
			addHeader(v4) -- equivalent call inferred; original call site unknown
			local v5 = groups.ByCategory[v4]

			for i = 1, #v5 do
				addRow(v5[i]) -- equivalent call inferred; original call site unknown
			end
		end
	else
		local suggestions = data.Suggestions or {}

		for i = 1, #suggestions do
			addRow(suggestions[i]) -- equivalent call inferred; original call site unknown
		end
	end

	count += 1
	v2.TailSpacer = import.make(basic.EmptyElement, {
		Size = UDim2.new(0, 0, 0, 0),
		LayoutOrder = count
	})
	return {
		Position = UDim2.new(0.5, 0, 1, 8),
		Size = UDim2.new(1, -28, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		StrokeTransparency = 0.7,
		StrokeColor = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.2,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 6),
		PaddingTop = UDim.new(0.005),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		RowKeyByIndex = rowKeyByIndex
	}, v2
end

local model8 = import.model("TextBox")

function model8.init()
	return {
		Position = UDim2.new(0.04, 0, 0.5, 0),
		Size = UDim2.new(1, -28, 0.6, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		PlaceholderText = "Type a command...",
		PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
		Text = "",
		TextScaled = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.SourceSansBold,
		ZIndex = 3,
		_Events = {
			Changed = function(object, p)
				if p and p ~= "Text" or object.HandlingTab then
					return
				end

				local text = object.Instance.Text or ""

				if text == "" then
					object.PlaceholderText = "Type a command..."
				end

				if string.find(text, "\t", 1, true) then
					object.HandlingTab = true
					local text2 = string.gsub(text, "\t", "")
					object.Instance.Text = text2
					object.Instance.CursorPosition = #text2 + 1
					object:tabComplete(text2)
					object.HandlingTab = false
				else
					object:applyAutocomplete(text)
					object.Parent.SelectedIndex = 1
				end
			end,
			Focused = function(object)
				object:connectArrowKeys()
			end,
			FocusLost = function(object, p)
				object:disconnectArrowKeys()

				if not p then
					return
				end

				object:submitCommand(object.Text or "")
			end
		}
	}
end

function model8:applyAutocomplete(p)
	local computed = import4.compute(p)
	self:setGhost(computed.GhostText or "")

	if self.Parent.LastKey == computed.Key then
		return
	end

	self.Parent.LastKey = computed.Key
	self.Parent:setList(computed.Entries, computed.Groups)
end

function model8:submitCommand(p2)
	if p2 == "" then
		import2.fire("signal", "Please enter a command to execute")
		return
	end

	local input, v2, v3 = import3.parseInput(p2)

	if v3 and v3.UnterminatedQuote or not input or not import3.getCommandByName(input) then
		return
	end

	local v4 = select(1, import3.parseToId(p2))

	if not v4 then
		return
	end

	if import2.remoteFire("executeAdminCommand", v4, v2) == true then
		self.Ui:Destroy()
	else
		self.Instance:CaptureFocus()
	end
end

function model8:setGhost(value)
	local ghostLabel = self.Parent.GhostLabel

	if not ghostLabel then
		return
	end

	ghostLabel.Instance.Text = value or ""
end

function model8:tabComplete(p)
	if not self.Instance:IsFocused() then
		return
	end

	local computed = import4.compute(p)
	local selectedIndex = self.Parent.SelectedIndex or 1
	local insertText

	if computed.Stage == "command" then
		local v2 = (self.Parent.CurrentEntries or {})[selectedIndex]
		insertText = v2 and (v2.InsertText or v2.Name)
	else
		insertText = import5.getTabCandidates(computed)[selectedIndex]
	end

	if not insertText or insertText == "" then
		return
	end

	local splitCurrentToken = import5.splitCurrentToken(p)
	local text

	if computed.Stage == "command" then
		text = insertText .. " "
	else
		text = splitCurrentToken .. insertText .. " "
	end

	self.Instance.Text = text
	self.Instance.CursorPosition = #text + 1
	self:applyAutocomplete(text)
	task.defer(function()
		self.Parent:updateSelection(self.Parent.SelectedIndex or 1, true)
	end)
end

function model8:connectArrowKeys()
	self.ArrowConnection = UserInputService.InputBegan:Connect(function(input, _)
		if not self.Instance:IsFocused() then
			return
		end

		if input.KeyCode == Enum.KeyCode.Down then
			self:cycleSelection(1)
		elseif input.KeyCode == Enum.KeyCode.Up then
			self:cycleSelection(-1)
		end
	end)
end

function model8:disconnectArrowKeys()
	if not self.ArrowConnection then
		return
	end

	self.ArrowConnection:Disconnect()
	self.ArrowConnection = nil
end

function model8:cycleSelection(p)
	self.Instance.PlaceholderText = ""
	local text = self.Instance.Text or ""

	if text == "" then
		self:applyAutocomplete("")
	end

	local currentEntries = self.Parent.CurrentEntries

	if not currentEntries or #currentEntries == 0 then
		return
	end

	local v2 = (self.Parent.SelectedIndex or 1) + p
	local v3

	if v2 < 1 then
		v3 = #currentEntries
	else
		v3 = #currentEntries < v2 and 1 or v2
	end

	self.Parent:updateSelection(v3)
	local computed = import4.compute(text)
	local currentEntry = currentEntries[v3]

	if computed.Stage == "command" then
		if currentEntry and currentEntry.Name then
			self:setGhost((currentEntry.InsertText or currentEntry.Name) .. " " .. (currentEntry.ArgsText or ""))
		end
	elseif currentEntry and currentEntry.Name then
		local v4 = import5.splitCurrentToken(text) .. (currentEntry.InsertText or currentEntry.Name)

		if currentEntry.ArgsText and currentEntry.ArgsText ~= "" then
			v4 ..= " " .. currentEntry.ArgsText
		end

		self:setGhost(v4)
	end
end

local model9 = import.model(basic.Element, basic.Corner, basic.Stroke)

function model9.init()
	return {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 0.2,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		CornerRadius = UDim.new(0.15, 0),
		StrokeTransparency = 0.7,
		StrokeColor = Color3.fromRGB(255, 255, 255)
	}, {
		ChevronRight = import.make(basic.ImageLabel, {
			Position = UDim2.new(0.015, 0, 0.5, 0),
			Size = UDim2.new(0.4, 0, 0.4, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://100175566733558",
			ImageColor3 = Color3.fromRGB(140, 140, 140)
		}),
		GhostLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.04, 0, 0.5, 0),
			Size = UDim2.new(1, -28, 0.6, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Text = "",
			TextScaled = true,
			TextColor3 = Color3.fromRGB(140, 140, 140),
			TextXAlignment = Enum.TextXAlignment.Left,
			Font = Enum.Font.SourceSansBold,
			StrokeWidth = 1,
			ZIndex = 2
		}),
		TextBox = import.make(model8)
	}
end

function model9:scrollSelectionIntoView()
	local selectedIndex = self.SelectedIndex or 1

	if not self.CommandList then
		return
	end

	local instance = self.CommandList.Instance
	local v2 = nil

	for _, guiObject in ipairs(instance:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and tonumber(guiObject.Name) == selectedIndex) then
			continue
		end

		v2 = guiObject
		break
	end

	if not v2 then
		return
	end

	task.defer(function()
		if not (instance.Parent and v2.Parent) then
			return
		end

		task.wait()
		local Y = instance.CanvasPosition.Y
		local v4 = Y + instance.AbsoluteSize.Y
		local v5 = v2.AbsolutePosition.Y - instance.AbsolutePosition.Y + Y
		local v6 = v5 + v2.AbsoluteSize.Y
		local v7 = nil

		if v4 < v6 then
			v7 = v6 - instance.AbsoluteSize.Y + 6
		elseif v5 < Y then
			v7 = v5 - 6
		end

		if not v7 then
			return
		end

		local v8 = v7 < 0 and 0 or v7
		local v9 = (selectedIndex == 1 or v8 <= 1) and 0 or v8

		if self.ScrollTween then
			self.ScrollTween:Cancel()
			self.ScrollTween = nil
		end

		self.ScrollTween = TweenService:Create(instance, TweenInfo.new(0.1), {
			CanvasPosition = Vector2.new(0, v9)
		})
		self.ScrollTween:Play()
	end)
end

function model9:bindCappedAutoHeight()
	local instance = self.CommandList.Instance
	local uIListLayout = instance:FindFirstChildWhichIsA("UIListLayout", true)

	if not uIListLayout then
		return
	end

	if self.Conn then
		self.Conn:Disconnect()
		self.Conn = nil
	end

	local function update()
		if uIListLayout.AbsoluteContentSize.Y <= 450 then
			instance.AutomaticSize = Enum.AutomaticSize.Y
			instance.Size = UDim2.new(1, -28, 0, 0)
		else
			instance.AutomaticSize = Enum.AutomaticSize.None
			instance.Size = UDim2.new(1, -28, 0, 450)
		end
	end

	update()
	self.Conn = uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
end

function model9:setList(list, currentGroups)
	local commandList = self.CommandList

	if commandList then
		commandList:Destroy()
	end

	local v2 = (not list or #list == 0) and {
		{
			Name = "No matches",
			Description = "Try a different search.",
			ArgsText = "",
			NonInsertable = true
		}
	} or list
	local v3 = flattenGroups(currentGroups) or v2
	self.CurrentEntries = v3
	self.SelectedIndex = 1
	self.CurrentGroups = currentGroups
	import.apply(self, nil, {
		CommandList = import.make(model7, {
			Suggestions = v3,
			Groups = currentGroups,
			SelectedIndex = 1
		})
	})
	task.defer(function()
		self:bindCappedAutoHeight()
		self:updateSelection(self.SelectedIndex, true)
	end)
end

function model9:updateSelection(selectedIndex, p)
	if not self.CurrentEntries or #self.CurrentEntries == 0 then
		return
	end

	self.SelectedIndex = selectedIndex
	local instance = self.CommandList.Instance

	for _, guiObject in ipairs(instance:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = tonumber(guiObject.Name)

		if not name then
			continue
		end

		if name == selectedIndex then
			guiObject.BackgroundTransparency = 0.7
			local accent = guiObject.Content:FindFirstChild("Accent")
			accent.BackgroundTransparency = 0
		else
			guiObject.BackgroundTransparency = 0.85
			local accent_2 = guiObject.Content:FindFirstChild("Accent")
			accent_2.BackgroundTransparency = 1
		end
	end

	self:scrollSelectionIntoView()

	if p then
		return
	end

	import7.sound("Pop3")
end

function model9:despawn()
	if self.Conn then
		self.Conn:Disconnect()
		self.Conn = nil
	end

	if self.ScrollTween then
		self.ScrollTween:Cancel()
		self.ScrollTween = nil
	end
end

local model10 = import.model("ScreenGui", basic.Ui)

function model10.init(_)
	return {
		ContainerPosition = UDim2.new(0.5, 0, 0.125, 0),
		ContainerAnchorPoint = Vector2.new(0.5, 0),
		Visible = true,
		Level = 2,
		Scale = 0.75,
		AspectRatio = 18,
		Content = {
			KeybindHelp = import.make(model4),
			Container = import.make(model9)
		}
	}
end

function model10:spawn()
	local textBox = self.Container.Content.Container.TextBox
	textBox:applyAutocomplete(textBox.Instance.Text or "")
	textBox.Instance:CaptureFocus()

	if self.EscConn then
		return
	end

	self.EscConn = UserInputService.InputBegan:Connect(function(input, _)
		if input.KeyCode ~= Enum.KeyCode.Escape then
			return
		end

		self.EscConn:Disconnect()
		self.Ui:Destroy()
	end)
end

function model10:despawn()
	if not self.EscConn then
		return
	end

	self.EscConn:Disconnect()
	self.EscConn = nil
end

return {
	Cmdr = model10
}