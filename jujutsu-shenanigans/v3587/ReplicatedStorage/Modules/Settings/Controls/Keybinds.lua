local Keybinds = {
	Btn = 4,
	SortOrder = 5,
	Val = "Keybinds",
	Desc = "Change what keys you need to press to use your abilities",
	BtnText = "Keybinds"
}
local localPlayer = game.Players.LocalPlayer
local menus = localPlayer.PlayerGui:WaitForChild("Menus")
local settings = menus.Group.Settings
local _ = game.ReplicatedStorage.Sounds
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local controller = Knit.GetController("ToolController")
local v = nil
local v2 = nil
local UserInputService = game:GetService("UserInputService")

local function getPlatform(p)
	if p == Enum.UserInputType.Touch then
		return "Mobile"
	end

	if string.sub(p.Name, 1, 7) == "Gamepad" then
		return "Gamepad"
	end

	if p == Enum.UserInputType.Keyboard or string.sub(p.Name, 1, 5) == "Mouse" then
		return "Keyboard"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetEdit()
	v2 = nil

	if v then
		v[1]:Disconnect()
		v[2]:Disconnect()
		v = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getString(p)
	if p == Enum.KeyCode.Unknown then
		return ""
	end

	local stringForKeyCode = UserInputService:GetStringForKeyCode(p)

	if not stringForKeyCode or stringForKeyCode == "" then
		stringForKeyCode = p.Name
	end

	return stringForKeyCode or ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function returnStringForKeybind(p)
	if p.PrimaryModifier and p.PrimaryModifier ~= Enum.KeyCode.Unknown then
		local string2 = getString(p.PrimaryModifier) -- equivalent call inferred; original call site unknown
		local string3 = getString(p.KeyCode) -- equivalent call inferred; original call site unknown
		return string2 .. " + " .. string3
	else
		local keyCode = p.KeyCode

		if keyCode == Enum.KeyCode.Unknown then
			return ""
		end

		local stringForKeyCode = UserInputService:GetStringForKeyCode(keyCode)

		if not stringForKeyCode or stringForKeyCode == "" then
			stringForKeyCode = keyCode.Name
		end

		return stringForKeyCode or ""
	end
end

local function screwRobloxMouseInput(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		return Enum.KeyCode.MouseLeftButton
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		return Enum.KeyCode.MouseRightButton
	end

	if input.UserInputType == Enum.UserInputType.MouseButton3 then
		return Enum.KeyCode.MouseMiddleButton
	end

	return input.KeyCode
end

for _, inputBinding in game.ReplicatedStorage.Keybind:GetDescendants() do
	if inputBinding:IsA("InputBinding") and inputBinding.KeyCode ~= Enum.KeyCode.Unknown then
		inputBinding:SetAttribute("D", inputBinding.KeyCode.Name)
	end
end

local function sendUpdate()
	local service = Knit.GetService("JoinService")
	local v3 = {}
	local v4 = {
		Keyboard = "K",
		Gamepad = "G"
	}

	for _, inputAction in game.ReplicatedStorage.Keybind:GetDescendants() do
		if not inputAction:IsA("InputAction") then
			continue
		end

		v3[inputAction.Name] = {}

		for _, inputBinding in inputAction:GetChildren() do
			if not (inputBinding:IsA("InputBinding") and v4[inputBinding.Name] and (inputBinding.KeyCode.Name ~= (inputBinding:GetAttribute("D") or "Unknown") or inputBinding.PrimaryModifier ~= Enum.KeyCode.Unknown)) then
				continue
			end

			v3[inputAction.Name][v4[inputBinding.Name]] = { inputBinding.KeyCode.Name }

			if inputBinding.PrimaryModifier and inputBinding.PrimaryModifier ~= Enum.KeyCode.Unknown then
				v3[inputAction.Name][v4[inputBinding.Name]][2] = inputBinding.PrimaryModifier.Name
			end
		end
	end

	local KeybindIcons = require(game.ReplicatedStorage.Modules.KeybindIcons)
	KeybindIcons:updateAll()
	service.MobileLayout:Fire(v3, true)
end

function Keybinds.Callback()
	settings.Keybinds.Visible = true
	settings.Settings.Visible = false
	local lastInput = controller.LastInput

	if lastInput == "Mobile" then
		return
	end

	local v3 = (lastInput == "Xbox" or lastInput == "Playstation") and "Gamepad" or lastInput
	resetEdit() -- equivalent call inferred; original call site unknown
	local preset = menus.Preset
	local count = 0

	for _, child in game.ReplicatedStorage.Keybind:GetChildren() do
		count += 1
		local clone = preset.KeybindCategory:Clone()
		clone.Name = child.Name
		clone.Text = child.Name:upper()
		clone.LayoutOrder = count
		clone.Parent = settings.Keybinds.List

		for _, child2 in child:GetChildren() do
			if not child2:FindFirstChild(v3) then
				continue
			end

			count += 1
			local clone2 = preset.KeybindButton:Clone()
			clone2.Name = child2.Name
			clone2.Option.Text = child2.Name
			clone2.LayoutOrder = count
			local textButton = clone2.TextButton
			local text = returnStringForKeybind(child2[v3]) -- equivalent call inferred; original call site unknown
			textButton.Text = text
			clone2.Parent = settings.Keybinds.List
			local v6 = child2
			clone2.TextButton.MouseButton1Down:Connect(function()
				task.wait()

				if v2 then
					if v2 == v6 then
						v2[v3].KeyCode = Enum.KeyCode[v2[v3]:GetAttribute("D") or "Unknown"]
						v2[v3].PrimaryModifier = Enum.KeyCode.Unknown
						local textButton2 = clone2.TextButton
						local text2 = returnStringForKeybind(v2[v3]) -- equivalent call inferred; original call site unknown
						textButton2.Text = text2
						resetEdit() -- equivalent call inferred; original call site unknown
						sendUpdate()
					end
				else
					v2 = v6
					clone2.TextButton.Text = "Press any key"
					local v8 = {}
					v = { UserInputService.InputBegan:Connect(function(input, gameProcessed)
							if v2 then
								local userInputType = input.UserInputType

								if (userInputType == Enum.UserInputType.Touch and "Mobile" or string.sub(
									userInputType.Name,
									1,
									7
								) == "Gamepad" and "Gamepad" or (userInputType == Enum.UserInputType.Keyboard or string.sub(
									userInputType.Name,
									1,
									5
								) == "Mouse") and "Keyboard" or nil) == v3 then
									if #v8 >= 2 then
										return
									end

									table.insert(v8, (screwRobloxMouseInput(input)))
								end
							end
						end), UserInputService.InputEnded:Connect(function(input)
							if v2 then
								local userInputType = input.UserInputType

								if (userInputType == Enum.UserInputType.Touch and "Mobile" or string.sub(
									userInputType.Name,
									1,
									7
								) == "Gamepad" and "Gamepad" or (userInputType == Enum.UserInputType.Keyboard or string.sub(
									userInputType.Name,
									1,
									5
								) == "Mouse") and "Keyboard" or nil) == v3 then
									if not table.find(v8, (screwRobloxMouseInput(input))) then
										return
									end

									v2[v3].KeyCode = v8[#v8]

									if #v8 > 1 then
										v2[v3].PrimaryModifier = v8[1]
									else
										v2[v3].PrimaryModifier = Enum.KeyCode.Unknown
									end

									local textButton2 = clone2.TextButton
									local text2 = returnStringForKeybind(v2[v3]) -- equivalent call inferred; original call site unknown
									textButton2.Text = text2
									resetEdit() -- equivalent call inferred; original call site unknown
									sendUpdate()
								end
							end
						end) }
				end
			end)
		end
	end
end

settings.Keybinds.Return.MouseButton1Down:Connect(function()
	settings.Keybinds.Visible = false
	settings.Settings.Visible = true
end)
settings:GetPropertyChangedSignal("Visible"):Connect(function()
	if settings.Visible == true then
		return
	end

	settings.Keybinds.Visible = false
	settings.Settings.Visible = true
end)
settings.Keybinds:GetPropertyChangedSignal("Visible"):Connect(function()
	localPlayer:SetAttribute("Adjusting_Keybinds", settings.Keybinds.Visible or nil)

	if settings.Keybinds.Visible == true then
		return
	end

	for _, uIListLayout in settings.Keybinds.List:GetChildren() do
		if not uIListLayout:IsA("UIListLayout") then
			uIListLayout:Destroy()
		end
	end

	resetEdit() -- equivalent call inferred; original call site unknown
end)
return Keybinds