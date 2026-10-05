local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Input = require(packages.Input)
local Signal = require(packages.Signal)
local module = require("./DataController")
local playerDataReplicator = module.PlayerDataReplicator
local v = {
	Keyboard = Input.Keyboard.new(),
	Touch = Input.Touch.new(),
	Gamepad = Input.Gamepad.new()
}
local v2 = "Xbox"
local v3 = {
	[Enum.KeyCode.ButtonA] = {
		PS = "rbxassetid://115570431357286",
		Xbox = "rbxassetid://100119854395498"
	},
	[Enum.KeyCode.ButtonB] = {
		PS = "rbxassetid://115570431357286",
		Xbox = "rbxassetid://119292416098345"
	},
	[Enum.KeyCode.ButtonX] = {
		PS = "rbxassetid://111289686020179",
		Xbox = "rbxassetid://74739290180914"
	},
	[Enum.KeyCode.ButtonY] = {
		PS = "rbxassetid://101656178529592",
		Xbox = "rbxassetid://95411304455756"
	},
	[Enum.KeyCode.ButtonSelect] = {
		PS = "rbxassetid://107212933315767",
		Xbox = "rbxassetid://138510146726545"
	},
	[Enum.KeyCode.ButtonR1] = {
		PS = "rbxassetid://72786825002652",
		Xbox = "rbxassetid://90301566553079"
	},
	[Enum.KeyCode.ButtonR2] = {
		PS = "rbxassetid://114477797658861",
		Xbox = "rbxassetid://80366441861909"
	},
	[Enum.KeyCode.ButtonR3] = {
		PS = "rbxassetid://123454365656457",
		Xbox = "rbxassetid://97515475257459"
	},
	[Enum.KeyCode.ButtonL1] = {
		PS = "rbxassetid://99605426755914",
		Xbox = "rbxassetid://94572216621899"
	},
	[Enum.KeyCode.ButtonL2] = {
		PS = "rbxassetid://123667000286295",
		Xbox = "rbxassetid://104522092634526"
	},
	[Enum.KeyCode.ButtonL3] = {
		PS = "rbxassetid://138167240203060",
		Xbox = "rbxassetid://81853923511957"
	},
	[Enum.KeyCode.DPadUp] = {
		PS = "rbxassetid://78111206974828",
		Xbox = "rbxassetid://81686865690865"
	},
	[Enum.KeyCode.DPadDown] = {
		PS = "rbxassetid://100489117588853",
		Xbox = "rbxassetid://112542276855985"
	},
	[Enum.KeyCode.DPadLeft] = {
		PS = "rbxassetid://75904870251930",
		Xbox = "rbxassetid://133466412175150"
	},
	[Enum.KeyCode.DPadRight] = {
		PS = "rbxassetid://97142878766512",
		Xbox = "rbxassetid://75816833293397"
	}
}
local InputController = {
	OnPreferredInputChanged = Signal.new()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateGamepadExclusive(p)
	p.Visible = Input.PreferredInput.Current == "Gamepad"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateGamepadExclusives()
	for _, v4 in CollectionService:GetTagged("GamepadExclusive") do
		UpdateGamepadExclusive(v4) -- equivalent call inferred; original call site unknown
	end
end

local function UpdateLabelIcon(guiObject)
	if not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
		return
	end

	if Input.PreferredInput.Current == "Gamepad" then
		guiObject.Image = v3[Enum.KeyCode[guiObject:GetAttribute("ButtonKeyCode") or "ButtonA"]][v2]
	else
		guiObject.Image = ""
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateLabelIcons()
	for _, v4 in CollectionService:GetTagged("GamepadButton") do
		UpdateLabelIcon(v4)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateGamepadPlatform()
	v2 = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX) == "ButtonSquare" and "PS" or "Xbox"
	UpdateLabelIcons() -- equivalent call inferred; original call site unknown
	UpdateGamepadExclusives() -- equivalent call inferred; original call site unknown
end

function InputController.Get(_, p: string)
	return v[p]
end

function InputController.Observe(onOnPreferredInputChanged)
	onOnPreferredInputChanged(Input.PreferredInput.Current)
	return InputController.OnPreferredInputChanged:Connect(onOnPreferredInputChanged)
end

function InputController.GetPreferredInput(_)
	return Input.PreferredInput.Current
end

function InputController.Start(_)
	Input.PreferredInput.Observe(function(p)
		UpdateGamepadPlatform() -- equivalent call inferred; original call site unknown
		InputController.OnPreferredInputChanged:Fire(p)
	end)
	UserInputService.GamepadConnected:Connect(function()
		UpdateGamepadPlatform() -- equivalent call inferred; original call site unknown
	end)
	UserInputService.GamepadDisconnected:Connect(function()
		UpdateGamepadPlatform() -- equivalent call inferred; original call site unknown
	end)
	CollectionService:GetInstanceAddedSignal("GamepadButton"):Connect(function(...)
		UpdateLabelIcon(...)
	end)
	CollectionService:GetInstanceAddedSignal("GamepadExclusive"):Connect(function(...)
		UpdateGamepadExclusive(...) -- equivalent call inferred; original call site unknown
	end)
	UpdateGamepadPlatform() -- equivalent call inferred; original call site unknown
	playerDataReplicator:Observe({ "TEMP_Rebinds" }, function(items)
		if not items then
			return
		end

		for childName, item in items do
			local child = ReplicatedStorage.client.inputs:FindFirstChild(childName, true)

			if child then
				if item.Gamepad then
					local xbox = child:FindFirstChild("Xbox")

					if xbox and xbox:IsA("InputBinding") then
						xbox.KeyCode = Enum.KeyCode:FromName(item.Gamepad)
					else
						warn((`Failed to find Gamepad binding for "{childName}"`))
					end
				end

				if item.PC then
					local PC = child:FindFirstChild("PC")

					if PC and PC:IsA("InputBinding") then
						PC.KeyCode = Enum.KeyCode:FromName(item.PC)
					else
						warn((`Failed to find PC binding for "{childName}"`))
					end
				end
			else
				warn((`Failed to find action "{childName}" for rebinding`))
			end
		end
	end)
end

return InputController