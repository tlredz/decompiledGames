local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local autoRejoinRemote = game.ReplicatedStorage:WaitForChild("AutoRejoinRemote")
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local autoRejoin = playerGui:WaitForChild("PreferencesGui").Panel.Pages.General:WaitForChild("AutoRejoin")
local v = true
local now = os.clock()
local now2 = 0
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoRejoinNotice"
screenGui.DisplayOrder = 120
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
local button = CatalogUI.button("Notice", screenGui, "", UDim2.new(0.5, -220, 0, 90), UDim2.fromOffset(440, 54))
button.Visible = false

-- equivalent calls inferred from this helper; original call sites unknown
local function activity()
	now = os.clock()
	button.Visible = false
end

UserInputService.InputBegan:Connect(activity)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Gamepad1 then
		activity() -- equivalent call inferred; original call site unknown
	end
end)
localPlayer.Idled:Connect(function(p)
	now = math.min(now, os.clock() - p)
end)
button.Activated:Connect(activity)
autoRejoin.Activated:Connect(function()
	v = not v
	autoRejoin.Text = "Auto rejoin when AFK: " .. (v and "On" or "Off")
	autoRejoinRemote:FireServer("Setting", v)
	activity() -- equivalent call inferred; original call site unknown
end)
autoRejoinRemote.OnClientEvent:Connect(function(p, p2)
	button.Text = p == "Studio" and "Auto rejoin is ready. Teleports only work in the published game." or p2
	button.Visible = true

	if p == "Studio" then
		now = os.clock()
	end
end)
task.spawn(function()
	while screenGui.Parent do
		task.wait(1)
		local v2 = os.clock() - now

		if not (v and v2 >= 1095) then
			continue
		end

		button.Visible = true
		button.Text = "AFK rejoin in " .. math.max(0, (math.ceil(1125 - v2))) .. "s · Move or click to cancel"

		if not (v2 >= 1125 and os.clock() - now2 >= 15) then
			continue
		end

		now2 = os.clock()
		button.Text = "Saving coins and rejoining…"
		autoRejoinRemote:FireServer("Rejoin")
	end
end)