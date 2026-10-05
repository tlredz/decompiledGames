local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updatePlayerDevice = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable"):WaitForChild("UpdatePlayerDevice")

local function CurrentDevice()
	if GuiService:IsTenFootInterface() then
		return "Console"
	end

	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "Mobile"
	end

	return "Desktop"
end

local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function Report()
	local v2 = GuiService:IsTenFootInterface() and "Console" or UserInputService.TouchEnabled and not UserInputService.MouseEnabled and "Mobile" or "Desktop"

	if v2 == v then
		return
	end

	v = v2
	updatePlayerDevice:FireServer(v2)
end

Report() -- equivalent call inferred; original call site unknown
UserInputService.GamepadConnected:Connect(Report)
UserInputService.GamepadDisconnected:Connect(Report)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(Report)