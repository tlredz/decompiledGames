local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Gamepad = {}
local v = nil

function Gamepad.start(p)
	v = p
	local v2 = v
	local highlightKey2

	if v.highlightKey ~= nil then
		highlightKey2 = v.highlightKey
	end

	v2.highlightKey = highlightKey2
	v.highlightIcon = false
	task.delay(1, function()
		local iconsDictionary = v.iconsDictionary

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getIconFromSelectedObject()
			local selectedObject = GuiService.SelectedObject
			local correspondingIconUID = selectedObject and selectedObject:GetAttribute("CorrespondingIconUID")
			return correspondingIconUID and iconsDictionary[correspondingIconUID]
		end

		local v4 = nil
		local v5 = v.highlightKey ~= nil
		local v6 = v.highlightKey ~= nil
		local Selection = require(script.Parent.Parent.Elements.Selection)

		local function updateSelectedObject()
			local iconFromSelectedObject = getIconFromSelectedObject() -- equivalent call inferred; original call site unknown
			local v7 = UserInputService.PreferredInput == nil

			if iconFromSelectedObject then
				if v7 then
					local instance = iconFromSelectedObject:getInstance("ClickRegion")
					local selection = iconFromSelectedObject.selection

					if not selection then
						selection = iconFromSelectedObject.janitor:add(Selection(v))
						selection:SetAttribute("IgnoreVisibilityUpdater", true)
						selection.Parent = iconFromSelectedObject.widget
						iconFromSelectedObject.selection = selection
						iconFromSelectedObject:refreshAppearance(selection)
					end

					instance.SelectionImageObject = selection.Selection
				end

				if v4 and v4 ~= iconFromSelectedObject then
					v4:setIndicator()
				end

				local buttonB

				if v7 and not (v6 or iconFromSelectedObject.parentIconUID) then
					buttonB = Enum.KeyCode.ButtonB
				end

				v4 = iconFromSelectedObject
				v.lastHighlightedIcon = iconFromSelectedObject
				iconFromSelectedObject:setIndicator(buttonB)
			else
				local highlightKey

				if v7 and not v5 then
					highlightKey = v.highlightKey
				end

				if not v4 then
					v4 = Gamepad.getIconToHighlight()
				end

				if highlightKey == v.highlightKey then
					v5 = true
				end

				if v4 then
					v4:setIndicator(highlightKey)
				end
			end
		end

		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(updateSelectedObject)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function preferredInputChanged()
			if UserInputService.PreferredInput ~= nil then
				v5 = false
				v6 = false
			end

			updateSelectedObject()
		end

		UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(preferredInputChanged)
		preferredInputChanged() -- equivalent call inferred; original call site unknown
		UserInputService.InputBegan:Connect(function(input, _)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if getIconFromSelectedObject() then
					GuiService.SelectedObject = nil
				end
			else
				if input.KeyCode ~= v.highlightKey then
					return
				end

				local iconToHighlight = Gamepad.getIconToHighlight()

				if iconToHighlight then
					if GamepadService.GamepadCursorEnabled then
						task.wait(0.2)
						GamepadService:DisableGamepadCursor()
					end

					GuiService.SelectedObject = iconToHighlight:getInstance("ClickRegion")
				end
			end
		end)
	end)
end

function Gamepad.getIconToHighlight()
	local iconsDictionary = v.iconsDictionary
	local highlightIcon = v.highlightIcon or v.lastHighlightedIcon

	if highlightIcon then
		return highlightIcon
	end

	local X = nil

	for _, v2 in pairs(iconsDictionary) do
		if v2.parentIconUID then
			continue
		end

		local X2 = v2.widget.AbsolutePosition.X

		if not (not X or X2 < X) then
			continue
		end

		X = v2.widget.AbsolutePosition.X
		highlightIcon = v2
	end

	return highlightIcon
end

function Gamepad.registerButton(selectedObject)
	local v2 = false
	selectedObject.InputBegan:Connect(function(_)
		v2 = true
		task.wait()
		task.wait()
		v2 = false
	end)
	local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		task.wait()

		if input.KeyCode == Enum.KeyCode.ButtonA and v2 then
			task.wait(0.2)
			GamepadService:DisableGamepadCursor()
			GuiService.SelectedObject = selectedObject
		else
			local v3 = GuiService.SelectedObject == selectedObject
			local name = input.KeyCode.Name

			if table.find({ "ButtonB", "ButtonSelect" }, name) and v3 and (name ~= "ButtonSelect" or GamepadService.GamepadCursorEnabled) then
				GuiService.SelectedObject = nil
			end
		end
	end)
	selectedObject.Destroying:Once(function()
		inputBeganConnection:Disconnect()
	end)
end

return Gamepad