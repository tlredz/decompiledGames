local KeybindIcons = {}
game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
KeybindIcons.KeybindImages = {
	A = "rbxassetid://8146751176",
	B = "rbxassetid://8146750581",
	C = "rbxassetid://8152439938",
	D = "rbxassetid://8146749901",
	E = "rbxassetid://8146749798",
	F = "rbxassetid://8146749201",
	G = "rbxassetid://8146748420",
	H = "rbxassetid://8146748365",
	I = "rbxassetid://8146847383",
	J = "rbxassetid://8146748011",
	K = "rbxassetid://8146747857",
	L = "rbxassetid://8146747717",
	M = "rbxassetid://8146747645",
	N = "rbxassetid://8146746995",
	O = "rbxassetid://8146746778",
	P = "rbxassetid://8146746668",
	Q = "rbxassetid://8146746233",
	R = "rbxassetid://8146746001",
	S = "rbxassetid://8146745940",
	T = "rbxassetid://8146745419",
	U = "rbxassetid://8146745174",
	V = "rbxassetid://8146745093",
	W = "rbxassetid://8146744984",
	X = "rbxassetid://8146744696",
	Y = "rbxassetid://8146744550",
	Z = "rbxassetid://8146744410",
	One = "rbxassetid://11903615867",
	Two = "rbxassetid://11903615788",
	Three = "rbxassetid://11903615673",
	Four = "rbxassetid://11903615512",
	Five = "rbxassetid://11903615416",
	Six = "rbxassetid://11903615300",
	Seven = "rbxassetid://11903615178",
	Eight = "rbxassetid://11903615103",
	Nine = "rbxassetid://11903615000",
	Zero = "rbxassetid://11903615962",
	Tilde = "rbxassetid://11850722536",
	Tab = "rbxassetid://11850722621",
	Space = "rbxassetid://11850722719",
	Slash = "rbxassetid://11850722719",
	LeftShift = "rbxassetid://11850722930",
	RightShift = "rbxassetid://11850722930",
	Semicolon = "rbxassetid://11850723070",
	Quote = "rbxassetid://11850723169",
	Print = "rbxassetid://11850723294",
	Plus = "rbxassetid://11850723417",
	PageUp = "rbxassetid://11850723587",
	PageDown = "rbxassetid://11850723690",
	NumLock = "rbxassetid://11850723790",
	Minus = "rbxassetid://11850724167",
	GreaterThan = "rbxassetid://11850724227",
	LessThan = "rbxassetid://11850724300",
	Insert = "rbxassetid://11850724382",
	Question = "rbxassetid://11847018113",
	Home = "rbxassetid://11850724460",
	Escape = "rbxassetid://11850725463",
	End = "rbxassetid://11850725621",
	LeftControl = "rbxassetid://11850725785",
	RightControl = "rbxassetid://11850725785",
	CapsLock = "rbxassetid://11850726085",
	RightBracket = "rbxassetid://11850726178",
	LeftBracket = "rbxassetid://11850726306",
	Backspace = "rbxassetid://11850726427",
	Asterisk = "rbxassetid://11850726560",
	Up = "rbxassetid://11850726651",
	Right = "rbxassetid://11850726738",
	Left = "rbxassetid://11850726783",
	Down = "rbxassetid://11850726864",
	Delete = "rbxassetid://11850728216",
	F1 = "rbxassetid://11850725391",
	F2 = "rbxassetid://11850725319",
	F3 = "rbxassetid://11850725240",
	F4 = "rbxassetid://11850725190",
	F5 = "rbxassetid://11850725123",
	F6 = "rbxassetid://11850725056",
	F7 = "rbxassetid://11850724967",
	F8 = "rbxassetid://11850724874",
	F9 = "rbxassetid://11850724778",
	F10 = "rbxassetid://11850724678",
	F11 = "rbxassetid://11850724610",
	F12 = "rbxassetid://11850724532",
	MouseLeftButton = "rbxassetid://11850724082",
	MouseRightButton = "rbxassetid://11850723936",
	MouseMiddleButton = "rbxassetid://11850724008",
	ButtonA = "rbxassetid://9972618653",
	ButtonB = "rbxassetid://9972618503",
	ButtonX = "rbxassetid://9972613768",
	ButtonY = "rbxassetid://9972613363",
	DPadLeft = "rbxassetid://9972617213",
	DPadRight = "rbxassetid://9972617043",
	DPadUp = "rbxassetid://9972616869",
	DPadDown = "rbxassetid://9972617526",
	ButtonR1 = "rbxassetid://9972615066",
	ButtonR2 = "rbxassetid://9972614227",
	ButtonR3 = "rbxassetid://9972614509",
	ButtonL1 = "rbxassetid://9972616647",
	ButtonL2 = "rbxassetid://9972615998",
	ButtonL3 = "rbxassetid://9972616233"
}
KeybindIcons.KeybindNames = {
	One = "1",
	Two = "2",
	Three = "3",
	Four = "4",
	Five = "5",
	Six = "6",
	Seven = "7",
	Eight = "8",
	Nine = "9",
	Zero = "0",
	ButtonL1 = "LB",
	ButtonL2 = "LT",
	ButtonR2 = "RT",
	ButtonR1 = "RB"
}
KeybindIcons.KeybindPSNames = {
	ButtonL1 = "L1",
	ButtonL2 = "L2",
	ButtonR2 = "R2",
	ButtonR1 = "R1"
}
KeybindIcons.KeybindPSImages = {
	ButtonA = "rbxassetid://15030912568",
	ButtonB = "rbxassetid://15030911057",
	ButtonX = "rbxassetid://15030917250",
	ButtonY = "rbxassetid://15030914615",
	ButtonR1 = "rbxassetid://15030928539",
	ButtonR2 = "rbxassetid://15030930133",
	ButtonR3 = "rbxassetid://15030935337",
	ButtonL1 = "rbxassetid://15030926703",
	ButtonL2 = "rbxassetid://15030927456",
	ButtonL3 = "rbxassetid://15030934635",
	DPadLeft = "rbxassetid://15030920602",
	DPadRight = "rbxassetid://15030921122",
	DPadUp = "rbxassetid://15030919257",
	DPadDown = "rbxassetid://15030919788"
}

function KeybindIcons.GetTextForKeyCode(_, p)
	local name = p.KeyCode.Name
	return KeybindIcons.KeybindPSNames[name] or KeybindIcons.KeybindNames[name] or name
end

function KeybindIcons:updateKeyText(p, instance)
	local Knit = require(game.ReplicatedStorage.Knit.Knit)
	local lastInput = Knit.GetController("ToolController").LastInput or "Keyboard"
	local child = instance:FindFirstChild((lastInput == "Xbox" or lastInput == "Playstation") and "Gamepad" or lastInput)

	if not child then
		return
	end

	if lastInput == "Playstation" and KeybindIcons.KeybindPSNames[child.KeyCode.Name] then
		p.Key.Visible = true
		p.KeyIcon.Visible = false
		p.Key.Text = KeybindIcons.KeybindPSNames[child.KeyCode.Name]
	elseif KeybindIcons.KeybindNames[child.KeyCode.Name] then
		p.Key.Visible = true
		p.KeyIcon.Visible = false
		p.Key.Text = KeybindIcons.KeybindNames[child.KeyCode.Name]
	elseif lastInput == "Playstation" and KeybindIcons.KeybindPSImages[child.KeyCode.Name] then
		p.Key.Visible = false
		p.KeyIcon.Visible = true
		p.KeyIcon.Image = KeybindIcons.KeybindPSImages[child.KeyCode.Name]
	elseif KeybindIcons.KeybindImages[child.KeyCode.Name] then
		p.Key.Visible = false
		p.KeyIcon.Visible = true
		p.KeyIcon.Image = KeybindIcons.KeybindImages[child.KeyCode.Name]
	elseif UserInputService:GetImageForKeyCode(child.KeyCode) == "" then
		p.Key.Visible = true
		p.KeyIcon.Visible = false
		p.Key.Text = child.KeyCode.Name
	else
		p.Key.Visible = false
		p.KeyIcon.Visible = true
		p.KeyIcon.Image = UserInputService:GetImageForKeyCode(child.KeyCode)
	end
end

function KeybindIcons:updateKeyImage(p, instance)
	local Knit = require(game.ReplicatedStorage.Knit.Knit)
	local lastInput = Knit.GetController("ToolController").LastInput or "Keyboard"
	local child = instance:FindFirstChild((lastInput == "Xbox" or lastInput == "Playstation") and "Gamepad" or lastInput)

	if not child then
		return
	end

	if lastInput == "Playstation" and KeybindIcons.KeybindPSImages[child.KeyCode.Name] then
		p.Image = KeybindIcons.KeybindPSImages[child.KeyCode.Name]
	elseif KeybindIcons.KeybindImages[child.KeyCode.Name] then
		p.Image = KeybindIcons.KeybindImages[child.KeyCode.Name]
	else
		p.Image = UserInputService:GetImageForKeyCode(child.KeyCode)
	end
end

function KeybindIcons:updateAll()
	local combat = game.ReplicatedStorage.Keybind.Combat
	local gamepad = localPlayer.PlayerGui.Controls.Gamepad
	self:updateKeyImage(gamepad.Block, combat.Block)
	self:updateKeyImage(gamepad.Dash, combat.Dash)
	self:updateKeyImage(gamepad.LockOn, combat["Lock On"])
	self:updateKeyImage(gamepad.Melee, combat.Melee)
	self:updateKeyImage(gamepad.ShiftLock, combat["Shift Lock"])
	self:updateKeyImage(gamepad.Special, combat.Special)

	for _, frame in localPlayer.PlayerGui.Main.Controls.Moveset:GetChildren() do
		if not (frame:IsA("Frame") and frame:FindFirstChild("Item") and frame.Item.Value and frame.Item.Value:GetAttribute("Key")) then
			continue
		end

		local child = combat:FindFirstChild("Skill " .. frame.Item.Value:GetAttribute("Key"))

		if child then
			self:updateKeyText(frame.Key, child)
		end
	end
end

return KeybindIcons