local localPlayer = game.Players.LocalPlayer
local import = _G.import("event")
local import2 = _G.import("dictUtil")
local import3 = _G.import("clientUtil")
_G.import("abilityCollection")
local UserInputService = game:GetService("UserInputService")
local v = import2.set(
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"Backspace",
	"Delete",
	"Period",
	"Comma",
	"Quote",
	"Semicolon",
	"Slash",
	"BackSlash",
	"LeftBracket",
	"RightBracket",
	"Minus",
	"Equals"
)
local v2 = {
	Period = ".",
	Comma = ",",
	Quote = "'",
	Semicolon = ":",
	Slash = "/",
	BackSlash = "\\",
	LeftBracket = "[",
	RightBracket = "]",
	Minus = "-",
	Equals = "="
}
local v3 = nil
local v4 = 0
local v5 = 0
local v6 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function tryKeystroke(p)
	if p == -1 and v4 <= v5 then
		return
	end

	v4 += p == -1 and -1 or 1
	v4 = math.max(v4, v5)
	import3.sound("KeyStroke")
	import.fire("keyStroke", p)
	import.remoteFire("keyStroke", p)
end

local function keystroke(p, _)
	if not (localPlayer:GetAttribute("InGame") and p.UserInputType == Enum.UserInputType.Keyboard and v[p.KeyCode.Name] and v3 == localPlayer) then
		return
	end

	if not v6 then
		return
	end

	local v7 = p.KeyCode == Enum.KeyCode.Backspace and -1 or v2[p.KeyCode.Name] or p.KeyCode.Name

	if v7 == -1 then
		local inputEndedConnection = nil
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode ~= Enum.KeyCode.Backspace then
				return
			end

			inputEndedConnection:Disconnect()
			inputEndedConnection = nil
		end)
		task.delay(0.25, function()
			while inputEndedConnection do
				tryKeystroke(-1) -- equivalent call inferred; original call site unknown
				task.wait(0.05)
			end
		end)
	end

	tryKeystroke(v7) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tryAnswer()
	if v4 <= 0 or v3 ~= localPlayer then
		return
	end

	import.remoteFire("tryAnswer")
end

local function answer(p, _)
	if not (localPlayer:GetAttribute("InGame") and p.KeyCode == Enum.KeyCode.Return) then
		return
	end

	tryAnswer() -- equivalent call inferred; original call site unknown
end

local function updateRound(p, _, p2)
	v6 = not p.Choices
	v3 = p2
	localPlayer:SetAttribute("IsTurn", v3 == localPlayer)
	v5 = p.RequiredLetter and #p.RequiredLetter or 0
	v4 = v5
end

local function takeDamage()
	v6 = false
end

local function correct()
	v6 = false
end

local function jumpRequest()
	import.remoteFire("jumpRequest")
end

return {
	Priority = 1,
	Run = function()
		import.remoteConnect("updateRound", updateRound)
		import.remoteConnect("takeDamage", takeDamage)
		import.remoteConnect("correct", correct)
		import.connect("tryAnswer", tryAnswer, {
			Blocking = true
		})
		import.connect("tryKeystroke", tryKeystroke, {
			Blocking = true
		})
		UserInputService.InputBegan:Connect(keystroke)
		UserInputService.InputBegan:Connect(answer)
		UserInputService.JumpRequest:Connect(jumpRequest)
	end
}