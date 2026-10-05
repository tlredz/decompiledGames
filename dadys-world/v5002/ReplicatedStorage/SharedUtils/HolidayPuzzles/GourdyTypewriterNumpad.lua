local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local GourdyTypewriterNumpad = {}
local v = {
	{ "1", "2", "3" },
	{ "4", "5", "6" },
	{ "7", "8", "9" },
	{ "Clear", "0", "Enter" }
}
local v2 = {
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.KeypadZero] = "0",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.KeypadOne] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.KeypadTwo] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.KeypadThree] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.KeypadFour] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.KeypadFive] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.KeypadSix] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.KeypadSeven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.KeypadEight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.KeypadNine] = "9"
}
local v3 = { "Assets", "GourdyTypewriterNumpad" }
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v4 = nil

local function buildGui(title: string)
	local screenGui = ReplicatedStorage

	for _, childName in ipairs(v3) do
		screenGui = screenGui and screenGui:FindFirstChild(childName)
	end

	if not (screenGui and screenGui:IsA("ScreenGui")) then
		warn(("[GourdyTypewriterNumpad] no ScreenGui at ReplicatedStorage.%s"):format(table.concat(v3, ".")))
		return nil
	end

	local clone = screenGui:Clone()
	clone.ResetOnSpawn = false

	local function find(childName: string, className: string)
		local child = clone:FindFirstChild(childName, true)

		if child and child:IsA(className) then
			return child
		end

		warn(("[GourdyTypewriterNumpad] template is missing %s %q"):format(className, childName))
		return nil
	end

	local title2 = clone:FindFirstChild("Title", true)

	if not (title2 and title2:IsA("TextLabel")) then
		warn(("[GourdyTypewriterNumpad] template is missing %s %q"):format("TextLabel", "Title"))
		title2 = nil
	end

	local close = clone:FindFirstChild("Close", true)

	if not (close and close:IsA("GuiButton")) then
		warn(("[GourdyTypewriterNumpad] template is missing %s %q"):format("GuiButton", "Close"))
		close = nil
	end

	local display = clone:FindFirstChild("Display", true)

	if not (display and display:IsA("TextLabel")) then
		warn(("[GourdyTypewriterNumpad] template is missing %s %q"):format("TextLabel", "Display"))
		display = nil
	end

	local status = clone:FindFirstChild("Status", true)

	if not (status and status:IsA("TextLabel")) then
		warn(("[GourdyTypewriterNumpad] template is missing %s %q"):format("TextLabel", "Status"))
		status = nil
	end

	local buttons = {}
	local v5

	if close == nil or display == nil then
		v5 = false
	else
		v5 = status ~= nil
	end

	for _, list in ipairs(v) do
		for _, v6 in ipairs(list) do
			local v7 = "Key" .. v6
			local button = clone:FindFirstChild(v7, true)

			if not (button and button:IsA("GuiButton")) then
				warn(("[GourdyTypewriterNumpad] template is missing %s %q"):format("GuiButton", v7))
				button = nil
			end

			buttons[v6] = button
			v5 = v5 and buttons[v6] ~= nil
		end
	end

	if not v5 then
		clone:Destroy()
		return nil
	end

	if title2 then
		title2.Text = title
	end

	status.Text = ""
	local v6 = #v
	local v7 = #v[1]

	for i, list in ipairs(v) do
		for i2, v8 in ipairs(list) do
			local v9 = buttons[v8]
			v9.NextSelectionLeft = buttons[list[i2 - 1]] or v9
			v9.NextSelectionRight = buttons[list[i2 + 1]] or v9
			local nextSelectionUp

			if i > 1 then
				nextSelectionUp = buttons[v[i - 1][i2]]
			else
				nextSelectionUp = close
			end

			v9.NextSelectionUp = nextSelectionUp
			local nextSelectionDown

			if i < v6 then
				nextSelectionDown = buttons[v[i + 1][i2]]
			else
				nextSelectionDown = v9
			end

			v9.NextSelectionDown = nextSelectionDown
		end
	end

	close.NextSelectionDown = buttons[v[1][v7]]
	close.NextSelectionLeft = close
	close.NextSelectionRight = close
	close.NextSelectionUp = close
	return {
		gui = clone,
		display = display,
		status = status,
		keys = buttons,
		close = close
	}
end

local function animateKey(instance)
	local imageLabel = instance:FindFirstChildWhichIsA("ImageLabel")

	if not imageLabel then
		return function() end, {}
	end

	local size = imageLabel.Size
	local position = imageLabel.Position
	local v5 = Vector2.new(0.5, 0.5) - imageLabel.AnchorPoint
	local v6 = false
	local v7 = false
	local v8 = false

	local function apply()
		local v9 = v8 and 0.92 or (v6 or v7) and 1.06 or 1
		local v10 = size.X.Scale * (v9 - 1)
		local v11 = size.X.Offset * (v9 - 1)
		local v12 = size.Y.Scale * (v9 - 1)
		local v13 = size.Y.Offset * (v9 - 1)
		TweenService:Create(imageLabel, tweenInfo, {
			Size = size + UDim2.new(v10, v11, v12, v13),
			Position = position - UDim2.new(v10 * v5.X, v11 * v5.X, v12 * v5.Y, v13 * v5.Y)
		}):Play()
	end

	local count = 0

	local function pulse()
		count += 1
		local v9 = count
		v8 = true
		apply()
		task.delay(0.08, function()
			if v9 ~= count or not imageLabel.Parent then
				return
			end

			v8 = false
			apply()
		end)
	end

	return pulse, {
		instance.MouseEnter:Connect(function()
			v6 = true
			apply()
		end),
		instance.MouseLeave:Connect(function()
			v6 = false
			apply()
		end),
		instance.SelectionGained:Connect(function()
			v7 = true
			apply()
		end),
		instance.SelectionLost:Connect(function()
			v7 = false
			apply()
		end)
	}
end

local function formatCode(value: string, length: number, groupSize: number)
	local v5 = {}

	for i = 1, length do
		table.insert(v5, string.sub(value, i, i) == "" and "_" or string.sub(value, i, i) or "_")

		if i % groupSize == 0 and i < length then
			table.insert(v5, "-")
		end
	end

	return table.concat(v5, " ")
end

function GourdyTypewriterNumpad.IsOpen()
	return v4 ~= nil
end

function GourdyTypewriterNumpad.Close()
	local v5 = v4

	if not v5 then
		return
	end

	v4 = nil
	InputService:CloseMenu()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	CameraAuthority.setRotationEnabled("GourdyTypewriterNumpad", true)
	ContextActionService:UnbindAction("GourdyTypewriterNumpadClose")

	for _, connection in ipairs(v5.connections) do
		connection:Disconnect()
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(v5.ui.gui) then
		GuiService.SelectedObject = nil
	end

	v5.ui.gui:Destroy()

	if v5.onClosed then
		task.spawn(v5.onClosed)
	end
end

function GourdyTypewriterNumpad.Open(data)
	if v4 then
		return
	end

	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local length = data.length
	local groupSize = data.groupSize
	local gui = buildGui(data.title or "Typewriter")

	if not gui then
		return
	end

	local v5 = {
		ui = gui,
		connections = {},
		onClosed = data.onClosed
	}
	v4 = v5
	InputService:OpenMenu()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	CameraAuthority.setRotationEnabled("GourdyTypewriterNumpad", false)
	local v6 = ""
	local v7 = false
	local v8 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		gui.display.Text = formatCode(v6, length, groupSize)
	end

	local function press(p: string)
		if v7 or v4 ~= v5 then
			return
		end

		v8[p]()

		if p == "Clear" then
			v6 = ""
			gui.status.Text = ""
		elseif p == "Enter" then
			if #v6 < length then
				gui.status.Text = "Enter all " .. length .. " numbers"
				return
			end

			v7 = true
			gui.status.Text = ""
			task.spawn(function()
				local success, result, v9 = pcall(data.onSubmit, v6)

				if v4 ~= v5 then
					return
				end

				v7 = false

				if success and result then
					GourdyTypewriterNumpad.Close()
					return
				end

				v6 = ""
				gui.status.Text = success and v9 or "Nothing happens..."
				refresh() -- equivalent call inferred; original call site unknown
			end)
		elseif #v6 < length then
			v6 ..= p
			gui.status.Text = ""
		end

		refresh() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function animate(p)
		local v9, v10 = animateKey(p)
		table.move(v10, 1, #v10, #v5.connections + 1, v5.connections)
		return v9
	end

	for k, key in pairs(gui.keys) do
		v8[k] = animate(key)
		local v9 = k
		table.insert(v5.connections, key.Activated:Connect(function()
			press(v9)
		end))
	end

	animate(gui.close) -- equivalent call inferred; original call site unknown
	table.insert(v5.connections, gui.close.Activated:Connect(GourdyTypewriterNumpad.Close))
	table.insert(v5.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local v9 = v2[input.KeyCode]

		if v9 then
			press(v9)
		elseif input.KeyCode == Enum.KeyCode.Backspace and not v7 then
			v6 = string.sub(v6, 1, -2)
			refresh() -- equivalent call inferred; original call site unknown
		elseif (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter) and not v7 then
			if v4 ~= v5 then
				return
			end

			v8.Enter()

			if #v6 < length then
				gui.status.Text = "Enter all " .. length .. " numbers"
				return
			end

			v7 = true
			gui.status.Text = ""
			task.spawn(function()
				local success, result, v10 = pcall(data.onSubmit, v6)

				if v4 ~= v5 then
					return
				end

				v7 = false

				if success and result then
					GourdyTypewriterNumpad.Close()
					return
				end

				v6 = ""
				gui.status.Text = success and v10 or "Nothing happens..."
				refresh() -- equivalent call inferred; original call site unknown
			end)
			refresh() -- equivalent call inferred; original call site unknown
		end
	end))
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		table.insert(v5.connections, humanoid.Died:Connect(GourdyTypewriterNumpad.Close))
	end

	ContextActionService:BindActionAtPriority("GourdyTypewriterNumpadClose", function(_, p)
		if p == Enum.UserInputState.Begin then
			GourdyTypewriterNumpad.Close()
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)
	refresh() -- equivalent call inferred; original call site unknown
	gui.gui.Parent = playerGui

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GuiService.SelectedObject = gui.keys["1"]
	end
end

return GourdyTypewriterNumpad