local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerActivity = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PlayerActivity", 30)

if not playerActivity then
	return
end

local v = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function Report()
	local now = os.clock()

	if now - v < 3 then
		return
	end

	v = now
	playerActivity:FireServer()
end

UserInputService.InputBegan:Connect(Report)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Gamepad1 or input.UserInputType == Enum.UserInputType.Touch then
		Report() -- equivalent call inferred; original call site unknown
	end
end)