local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local dPadUp = Enum.KeyCode.DPadUp
local gamepad = Enum.PreferredInput.Gamepad
local Gamepad = {}
local v = nil

function Gamepad.start(p)
	v = p
	v.highlightKey = false
	v.highlightIcon = false
	task.delay(1, function()
		local iconsDictionary = v.iconsDictionary

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getIconFromSelectedObject()
			local selectedObject = GuiService.SelectedObject
			local correspondingIconUID = selectedObject and selectedObject:GetAttribute("CorrespondingIconUID")
			return correspondingIconUID and iconsDictionary[correspondingIconUID]
		end

		local v2 = nil
		local v3 = dPadUp ~= v.highlightKey
		local v4 = dPadUp ~= v.highlightKey
		local Selection = require(script.Parent.Parent.Elements.Selection)

		local function updateSelectedObject()
			local iconFromSelectedObject = getIconFromSelectedObject() -- equivalent call inferred; original call site unknown
			local v5 = UserInputService.PreferredInput == gamepad

			if iconFromSelectedObject then
				if v5 then
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

				if v2 and v2 ~= iconFromSelectedObject then
					v2:setIndicator()
				end

				local buttonB

				if v5 and not (v4 or iconFromSelectedObject.parentIconUID) then
					buttonB = Enum.KeyCode.ButtonB
				end

				v2 = iconFromSelectedObject
				v.lastHighlightedIcon = iconFromSelectedObject
				iconFromSelectedObject:setIndicator(buttonB)
			else
				local highlightKey

				if v5 and not v3 then
					highlightKey = v.highlightKey
				end

				if not v2 then
					v2 = Gamepad.getIconToHighlight()
				end

				if highlightKey == v.highlightKey then
					v3 = true
				end

				if v2 then
					v2:setIndicator(highlightKey)
				end
			end
		end

		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(updateSelectedObject)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function preferredInputChanged()
			if UserInputService.PreferredInput ~= gamepad then
				v3 = false
				v4 = false
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