local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
game:GetService("HttpService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local v = {
	MouseWheel = "MouseWheel",
	MouseButton1 = "MB1",
	MouseButton2 = "MB2",
	MouseButton3 = "MB3",
	LeftControl = "LCtrl",
	RightControl = "RCtrl",
	LeftShift = "LShift",
	RightShift = "RShift",
	Zero = "0",
	Tab = "Tab",
	LeftAlt = "LAlt",
	RAlt = "RAlt",
	Space = "Space",
	Up = "⬆",
	Down = "⬇",
	Left = "⬅",
	Right = "➡"
}
local v2 = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
	"Zero"
}
local v3 = {
	MouseKeyboard = { "Hotkey MouseKeyboard%s1", "Hotkey MouseKeyboard%s2" },
	Gamepad = { "Hotkey Gamepad%s1", "Hotkey Gamepad%s2" }
}
local v4 = {
	Short = {
		Base = "rbxassetid://16491694294",
		Pressed = "rbxassetid://16491693602",
		DisplayString = nil
	},
	Long = {
		Base = "rbxassetid://16491693870",
		Pressed = "rbxassetid://16491693385",
		DisplayString = nil
	},
	MB1 = {
		Base = "rbxassetid://13194849055",
		Pressed = "rbxassetid://13194848851",
		DisplayString = ""
	},
	MB2 = {
		Base = "rbxassetid://13194848725",
		Pressed = "rbxassetid://13194848539",
		DisplayString = ""
	},
	MB3 = {
		Base = "rbxassetid://115443077181302",
		Pressed = "rbxassetid://121057755614364",
		DisplayString = ""
	}
}
local InputLibrary = {
	HOTKEY_FORMATS = v3,
	Inputs = {},
	ItemInputs = {},
	ItemInputTypeToName = {},
	MobileButtons = {},
	MobileInputNameToItemIndex = {}
}

function InputLibrary:GetInputName(p)
	for k in pairs(InputLibrary.Inputs) do
		if self:InputIs(k, p) then
			return k
		end
	end
end

function InputLibrary:GetInputs(p, p2)
	local input = InputLibrary.Inputs[p]

	if not input then
		return
	end

	if not input.IsHotkey then
		return input.InputEnums[p2 or ControlsController.CurrentControls]
	end

	local inputEnumFromNames = {}

	for _, formatString in pairs(v3[p2 or ControlsController.CurrentControls] or {}) do
		local v5 = string.format(formatString, p)
		table.insert(inputEnumFromNames, Utility:GetInputEnumFromName(PlayerDataController:GetSetting(v5)))
	end

	return inputEnumFromNames
end

function InputLibrary:GetInputIcons(p, p2)
	local success, result = pcall(function()
		return UserInputService:GetImageForKeyCode(Enum[p][p2])
	end)

	if success and result ~= "" then
		return result, result, ""
	end

	local inputString = self:GetInputString(p, p2)
	local v5 = v4[inputString] or v4[utf8.len(inputString) == 1 and "Short" or "Long"]
	return v5.Base, v5.Pressed, v5.DisplayString or inputString
end

function InputLibrary:GetInputString(p, p2)
	local v5 = v[p2]

	if v5 then
		return v5
	end

	local index = table.find(v2, p2)

	if index then
		return (tostring(index))
	end

	local success, stringForKeyCode = pcall(UserInputService.GetStringForKeyCode, UserInputService, Enum[p][p2])

	if not success or utf8.len(stringForKeyCode) == 0 then
		return p2
	end

	if #stringForKeyCode > 6 and string.sub(stringForKeyCode, 1, 6) == "Button" then
		return (string.sub(stringForKeyCode, 7))
	end

	if #stringForKeyCode > 4 and string.sub(stringForKeyCode, 1, 4) == "DPad" then
		return (string.sub(stringForKeyCode, 5))
	end

	return stringForKeyCode
end

function InputLibrary:GetInputIconsByInputName(p, p2)
	local firstEnum = self:FindFirstEnum(p, p2)

	if firstEnum then
		return self:GetInputIcons(tostring(firstEnum.EnumType), firstEnum.Name)
	end

	return v4.Short.Base, v4.Short.Pressed, ""
end

function InputLibrary:FindFirstEnum(p, p2)
	local inputs = self:GetInputs(p, p2)
	return inputs and inputs[1]
end

function InputLibrary:InputIs(p, p2)
	local input = InputLibrary.Inputs[p2]
	local inputs = self:GetInputs(p2)
	return (p == p2 or input and input.MobileInputName == p) and true or inputs and (table.find(inputs, p.KeyCode) or table.find(
		inputs,
		p.UserInputType
	))
end

function InputLibrary:IsInputDown(p, list)
	if ControlsController:IsInputDown(p) then
		return true
	end

	for _, v5 in pairs(self:GetInputs(p) or {}) do
		if not (list and table.find(list, v5)) and ControlsController:IsInputDown(v5) then
			return true
		end
	end
end

local function add_input(p, p2, inputName, displayName, image, options, options2, options3)
	local v5 = {
		IsItemInput = p or false,
		IsHotkey = p2 or false,
		InputName = inputName,
		StartName = "Start" .. inputName .. "ing",
		FinishName = "Finish" .. inputName .. "ing",
		MobileInputName = nil,
		DisplayName = displayName,
		Image = image,
		InputEnums = {
			MouseKeyboard = options or {},
			Gamepad = options2 or {},
			Touch = {},
			VR = options3 or {}
		}
	}
	InputLibrary.Inputs[inputName] = v5

	if p then
		table.insert(InputLibrary.ItemInputs, inputName)
		InputLibrary.ItemInputTypeToName[v5.StartName] = inputName
		InputLibrary.ItemInputTypeToName[v5.FinishName] = inputName
	end
end

add_input(
	true,
	true,
	"Inspect",
	"Inspect",
	"rbxassetid://17513805400",
	{ Enum.KeyCode.V },
	{ Enum.KeyCode.DPadDown },
	nil
)
add_input(
	true,
	true,
	"Shoot",
	"Attack",
	"rbxassetid://17513805027",
	{ Enum.UserInputType.MouseButton1 },
	{ Enum.KeyCode.ButtonR2 },
	{ Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2 }
)
add_input(
	true,
	true,
	"Aim",
	"Ability",
	"rbxassetid://17513805525",
	{ Enum.UserInputType.MouseButton2, Enum.KeyCode.E },
	{ Enum.KeyCode.ButtonL2 },
	{ Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1 }
)
add_input(
	true,
	true,
	"Reload",
	"Reload",
	"rbxassetid://17513813485",
	{ Enum.KeyCode.R },
	{ Enum.KeyCode.ButtonX },
	{ Enum.KeyCode.ButtonY }
)
add_input(
	true,
	true,
	"Sprint",
	"Sprint",
	"rbxassetid://17513821002",
	{ Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift },
	{ Enum.KeyCode.ButtonL3 },
	{ Enum.KeyCode.ButtonL3 }
)
add_input(
	nil,
	true,
	"Crouch",
	"Crouch",
	"rbxassetid://17513805623",
	{ Enum.KeyCode.LeftControl, Enum.KeyCode.C },
	{ Enum.KeyCode.ButtonB },
	{ Enum.KeyCode.ButtonB }
)
add_input(nil, true, "Slide", "Slide", "rbxassetid://17524267716", nil, nil, nil)
add_input(
	nil,
	true,
	"SwitchCameraPOV",
	"Camera",
	"rbxassetid://17548980857",
	{ Enum.KeyCode.B },
	{ Enum.KeyCode.DPadUp },
	nil
)
add_input(nil, true, "EquipPrimary", "Equip Primary", "rbxassetid://17539215512", { Enum.KeyCode.One }, nil, nil)
add_input(nil, true, "EquipSecondary", "Equip Secondary", "rbxassetid://17539215639", { Enum.KeyCode.Two }, nil, nil)
add_input(nil, true, "EquipMelee", "Equip Melee", "rbxassetid://17539235478", { Enum.KeyCode.Three }, nil, nil)
add_input(nil, true, "EquipUtility", "Equip Utility", "rbxassetid://17539235638", { Enum.KeyCode.Four }, nil, nil)
add_input(
	nil,
	true,
	"EquipLast",
	"Equip Previous Weapon",
	"rbxassetid://17513804864",
	nil,
	{ Enum.KeyCode.ButtonL1 },
	nil
)
add_input(
	nil,
	true,
	"EquipNext",
	"Equip Next Weapon",
	"rbxassetid://17513804705",
	nil,
	{ Enum.KeyCode.ButtonR1 },
	{ Enum.KeyCode.ButtonX }
)
add_input(
	nil,
	true,
	"Jump",
	"Jump",
	"rbxassetid://17513836637",
	{ Enum.KeyCode.Space },
	{ Enum.KeyCode.ButtonA },
	{ Enum.KeyCode.ButtonA }
)
add_input(
	nil,
	true,
	"QuickMelee",
	"Quick Melee",
	"rbxassetid://17506296977",
	{ Enum.KeyCode.F },
	{ Enum.KeyCode.ButtonR3 },
	nil
)
add_input(
	nil,
	true,
	"QuickUtility",
	"Quick Utility",
	"rbxassetid://17513805716",
	{ Enum.KeyCode.G },
	{ Enum.KeyCode.ButtonY },
	nil
)
add_input(nil, true, "Ping", "Signal", "rbxassetid://17269776216", { Enum.UserInputType.MouseButton3 }, nil, nil)
add_input(
	nil,
	true,
	"OpenPlayerList",
	"Open Scoreboard",
	"rbxassetid://17513827700",
	{ Enum.KeyCode.Tab, Enum.KeyCode.LeftAlt },
	{ Enum.KeyCode.DPadLeft },
	nil
)
add_input(
	nil,
	true,
	"SpectateLast",
	"Spectate Previous Player",
	"rbxassetid://77908042044589",
	{ Enum.UserInputType.MouseButton1 },
	nil,
	nil
)
add_input(
	nil,
	true,
	"SpectateNext",
	"Spectate Next Player",
	"rbxassetid://77908042044589",
	{ Enum.UserInputType.MouseButton2 },
	{ Enum.KeyCode.DPadRight },
	nil
)
add_input(
	nil,
	true,
	"SpectateExit",
	"Stop Spectating",
	"rbxassetid://77908042044589",
	{ Enum.KeyCode.M },
	{ Enum.KeyCode.DPadDown },
	nil
)
add_input(
	nil,
	true,
	"SwitchItems",
	"Switch Weapons",
	"rbxassetid://13667080363",
	{ Enum.KeyCode.M },
	{ Enum.KeyCode.DPadDown },
	nil
)
add_input(
	nil,
	true,
	"LeaveDuel",
	"Leave Duel",
	"rbxassetid://17498605048",
	{ Enum.KeyCode.M },
	{ Enum.KeyCode.DPadDown },
	nil
)
add_input(
	nil,
	true,
	"UseEmote",
	"Emote",
	"rbxassetid://82983645557125",
	{ Enum.KeyCode.T },
	{ Enum.KeyCode.DPadRight },
	nil
)
add_input(nil, true, "HideHUD", "Hide HUD", "rbxassetid://126633805196326", nil, nil, nil)
add_input(
	nil,
	true,
	"WalkForward",
	"Walk Forward",
	"rbxassetid://102807333252186",
	{ Enum.KeyCode.W, Enum.KeyCode.Up },
	nil,
	nil
)
add_input(
	nil,
	true,
	"WalkBackward",
	"Walk Backward",
	"rbxassetid://92032489827936",
	{ Enum.KeyCode.S, Enum.KeyCode.Down },
	nil,
	nil
)
add_input(nil, true, "WalkLeftward", "Strafe Left", "rbxassetid://107466029361522", { Enum.KeyCode.A }, nil, nil)
add_input(nil, true, "WalkRightward", "Strafe Right", "rbxassetid://118121732524898", { Enum.KeyCode.D }, nil, nil)

for i = 1, CONSTANTS.MAX_EQUIPPABLE_EMOTES do
	add_input(nil, true, "UseEmote" .. i, "Quick Emote " .. i, "rbxassetid://82983645557125", nil, nil, nil)
end

add_input(nil, nil, "LeanLeft", "Lean Left", "rbxassetid://17513844569", nil, nil, nil)
add_input(nil, nil, "LeanRight", "Lean Right", "rbxassetid://17513844569", nil, nil, nil)
add_input(
	nil,
	nil,
	"UICancelAction",
	"UI Cancel Action",
	"rbxassetid://17136633629",
	{ Enum.KeyCode.Backspace, Enum.KeyCode.Escape },
	{ Enum.KeyCode.ButtonB },
	nil
)
add_input(
	nil,
	nil,
	"UIPrimaryAction",
	"UI Primary Action",
	"rbxassetid://17136633629",
	nil,
	{ Enum.KeyCode.ButtonX },
	nil
)
add_input(
	nil,
	nil,
	"UISecondaryAction",
	"UI Secondary Action",
	"rbxassetid://17136633629",
	nil,
	{ Enum.KeyCode.ButtonY },
	nil
)
add_input(
	nil,
	nil,
	"UITertiaryAction",
	"UI Tertiary Action",
	"rbxassetid://17136633629",
	nil,
	{ Enum.KeyCode.ButtonL1 },
	nil
)
add_input(
	nil,
	nil,
	"UIQuaternaryAction",
	"UI Quaternary Action",
	"rbxassetid://17136633629",
	nil,
	{ Enum.KeyCode.ButtonR1 },
	nil
)
add_input(nil, nil, "UIOpenPage1", "UI Open Page 1", "rbxassetid://17136633629", nil, { Enum.KeyCode.DPadLeft }, nil)
add_input(nil, nil, "UIOpenPage2", "UI Open Page 2", "rbxassetid://17136633629", nil, { Enum.KeyCode.DPadDown }, nil)
add_input(nil, nil, "UIOpenPage3", "UI Open Page 3", "rbxassetid://17136633629", nil, { Enum.KeyCode.DPadRight }, nil)
add_input(nil, nil, "UIOpenPage4", "UI Open Page 4", "rbxassetid://17136633629", nil, { Enum.KeyCode.DPadUp }, nil)

local function add_mobile_button(p, p2, mobileInputName, inputName, value, uDim, uDim2, alwaysVisible, alwaysToggle, p6, visibleWhileSpectatingForeignDuel, options)
	local v5 = {
		IsCoreInput = p or false,
		InputName = inputName,
		Image = value or "rbxassetid://13695061446",
		DefaultVisibility = not p2,
		DefaultPosition = uDim,
		DefaultSize = uDim2,
		AlwaysVisible = alwaysVisible,
		AlwaysToggle = alwaysToggle,
		VisibleWhileSpectatingForeignDuel = visibleWhileSpectatingForeignDuel,
		HideIfDead = not p6
	}

	for k, v6 in pairs(options or {}) do
		v5[k] = v6
	end

	InputLibrary.MobileButtons[mobileInputName] = v5
	InputLibrary.Inputs[inputName].MobileInputName = mobileInputName

	if v5.ItemIndex then
		InputLibrary.MobileInputNameToItemIndex[mobileInputName] = v5.ItemIndex
	end
end

add_mobile_button(
	nil,
	nil,
	"mobile_aim",
	"Aim",
	"rbxassetid://13774376480",
	UDim2.new(1, -90, 1, -185),
	UDim2.new(0, 70, 0, 70)
)
add_mobile_button(
	nil,
	nil,
	"mobile_shoot",
	"Shoot",
	"rbxassetid://13774376715",
	UDim2.new(1, -160, 1, -150),
	UDim2.new(0, 70, 0, 70)
)
add_mobile_button(
	nil,
	nil,
	"mobile_reload",
	"Reload",
	"rbxassetid://13774376638",
	UDim2.new(1, -230, 1, -130),
	UDim2.new(0, 50, 0, 50)
)
add_mobile_button(
	nil,
	nil,
	"mobile_inspect",
	"Inspect",
	"rbxassetid://13774376564",
	UDim2.new(0, 90, 0, 80),
	UDim2.new(0, 40, 0, 40)
)
add_mobile_button(
	nil,
	nil,
	"mobile_quickmelee",
	"QuickMelee",
	"rbxassetid://13814923695",
	UDim2.new(1, -85, 0, 100),
	UDim2.new(0, 30, 0, 30),
	true,
	nil,
	nil,
	nil,
	{
		QuickAttackType = "Melee"
	}
)
add_mobile_button(
	nil,
	nil,
	"mobile_quickutility",
	"QuickUtility",
	"rbxassetid://16600936252",
	UDim2.new(1, -40, 0, 100),
	UDim2.new(0, 30, 0, 30),
	true,
	nil,
	nil,
	nil,
	{
		QuickAttackType = "Utility"
	}
)
add_mobile_button(
	true,
	nil,
	"mobile_crouch",
	"Crouch",
	"rbxassetid://13814923555",
	UDim2.new(1, -185, 1, -75),
	UDim2.new(0, 70, 0, 70),
	true,
	true
)
add_mobile_button(
	true,
	true,
	"mobile_slide",
	"Slide",
	"rbxassetid://17674207175",
	UDim2.new(1, -270, 1, -75),
	UDim2.new(0, 70, 0, 70),
	true
)
add_mobile_button(
	true,
	nil,
	"mobile_jump",
	"Jump",
	"rbxassetid://13774392305",
	UDim2.new(1, -90, 1, -90),
	UDim2.new(0, 80, 0, 80),
	true
)
add_mobile_button(
	true,
	nil,
	"mobile_switchcamerapov",
	"SwitchCameraPOV",
	"rbxassetid://137766393325923",
	UDim2.new(0, 40, 0, 80),
	UDim2.new(0, 40, 0, 40),
	true,
	nil,
	true,
	true
)
add_mobile_button(
	nil,
	nil,
	"mobile_openplayerlist",
	"OpenPlayerList",
	"rbxassetid://17319839617",
	UDim2.new(0, 140, 0, 80),
	UDim2.new(0, 40, 0, 40),
	true,
	nil,
	true,
	true
)
add_mobile_button(
	nil,
	nil,
	"mobile_equipprimary",
	"EquipPrimary",
	"rbxassetid://124117259408457",
	UDim2.new(1, -175, 0, 60),
	UDim2.new(0, 40, 0, 40),
	true,
	nil,
	nil,
	nil,
	{
		ItemIndex = 1
	}
)
add_mobile_button(
	nil,
	nil,
	"mobile_equipsecondary",
	"EquipSecondary",
	"rbxassetid://87384533585497",
	UDim2.new(1, -130, 0, 60),
	UDim2.new(0, 40, 0, 40),
	true,
	nil,
	nil,
	nil,
	{
		ItemIndex = 2
	}
)
add_mobile_button(
	nil,
	nil,
	"mobile_equipmelee",
	"EquipMelee",
	"rbxassetid://124237418792068",
	UDim2.new(1, -85, 0, 60),
	UDim2.new(0, 40, 0, 40),
	true,
	nil,
	nil,
	nil,
	{
		ItemIndex = 3
	}
)
add_mobile_button(
	nil,
	nil,
	"mobile_equiputility",
	"EquipUtility",
	"rbxassetid://112565014737738",
	UDim2.new(1, -40, 0, 60),
	UDim2.new(0, 40, 0, 40),
	true,
	nil,
	nil,
	nil,
	{
		ItemIndex = 4
	}
)
add_mobile_button(
	nil,
	nil,
	"mobile_useemote",
	"UseEmote",
	"rbxassetid://137981590006803",
	UDim2.new(0, 190, 0, 80),
	UDim2.new(0, 40, 0, 40),
	true
)
return InputLibrary