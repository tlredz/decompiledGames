local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local parent = script.Parent
local text = parent.Text
local v = false
local v2 = {
	"ButtonX",
	"ButtonY",
	"ButtonL1",
	"ButtonL2",
	"ButtonR1",
	"ButtonR2",
	"ButtonB",
	"ButtonA"
}

local function UpdatePlatformText()
	local text2 = text

	for _, v4 in v2 do
		text2 = string.gsub(text2, v4, UserInputService:GetStringForKeyCode(Enum.KeyCode[v4]))
	end

	parent.Text = text2
end

local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Cleanup()
	for _, connection in connections do
		if connection ~= nil and connection.Connected then
			connection:Disconnect()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateInputType(lastInputType)
	if not v and lastInputType.Name:find("Gamepad") then
		v = true
		Cleanup() -- equivalent call inferred; original call site unknown
		UpdatePlatformText()
	end
end

table.insert(connections, UserInputService.LastInputTypeChanged:Connect(UpdateInputType))
UpdateInputType(UserInputService:GetLastInputType()) -- equivalent call inferred; original call site unknown