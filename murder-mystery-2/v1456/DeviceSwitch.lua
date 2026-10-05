local parent = script.Parent
local keyboard = parent:WaitForChild("Keyboard")
local gamepad = parent:WaitForChild("Gamepad")
local UserInputService = game:GetService("UserInputService")
local v = nil
local v2 = {
	Keyboard = false,
	Gamepad = false
}
local v3 = {
	[Enum.UserInputType.Keyboard] = "Keyboard",
	[Enum.UserInputType.MouseMovement] = "Keyboard",
	[Enum.UserInputType.Gamepad1] = "Gamepad",
	[Enum.UserInputType.Gamepad2] = "Gamepad",
	[Enum.UserInputType.Gamepad3] = "Gamepad",
	[Enum.UserInputType.Gamepad4] = "Gamepad"
}

local function InitializeDevice(_: string) end

local function onDeviceSwitched(p: string)
	if not v2[p] then
		v2[p] = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetDevice(p: string)
	if v ~= p and not v2[p] then
		v2[p] = true
	end

	v = p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateCurrentDevice()
	local lastInputType = UserInputService:GetLastInputType()

	if v3[lastInputType] then
		SetDevice(v3[lastInputType]) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateCurrentFrame()
	keyboard.Visible = v == "Keyboard"
	gamepad.Visible = v == "Gamepad"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Update()
	UpdateCurrentDevice() -- equivalent call inferred; original call site unknown
	UpdateCurrentFrame() -- equivalent call inferred; original call site unknown
end

local function Initialize()
	Update() -- equivalent call inferred; original call site unknown
	UserInputService.LastInputTypeChanged:Connect(Update)
end

local lastInputType = UserInputService:GetLastInputType()

if v3[lastInputType] then
	local v4 = v3[lastInputType]

	if v ~= v4 and not v2[v4] then
		InitializeDevice(v4)
		v2[v4] = true
	end

	v = v4
end

UpdateCurrentFrame() -- equivalent call inferred; original call site unknown
UserInputService.LastInputTypeChanged:Connect(Update)