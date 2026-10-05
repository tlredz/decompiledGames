local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local EmoteWheelController = require(ReplicatedStorage2.Controllers.EmoteWheelController)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local zero = Vector2.zero
local v = zero

-- equivalent calls inferred from this helper; original call sites unknown
local function validateCharacter()
	local character = localPlayer.Character

	if not character then
		return false
	end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		return not (humanoid.MoveDirection.Magnitude > 0)
	end

	return false
end

local function registerEmoteBegan(_)
	-- equivalent call inferred; original call site unknown
	if not validateCharacter() then
		return
	end

	EmoteWheelController:open()
	zero = v
end

local function registerEmoteEnded(_)
	EmoteWheelController:close(true)
end

if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled and UserInputService.GamepadEnabled and GuiService:IsTenFootInterface()) then
	script.Parent.Visible = true
else
	script.Parent.Visible = false
end

task.spawn(function()
	local HUD = playerGui:WaitForChild("HUD")
	HUD.LeftFrame.Emote.InputBegan:Connect(registerEmoteBegan)
	HUD.LeftFrame.Emote.InputEnded:Connect(registerEmoteEnded)
end)
task.spawn(function()
	local mobileHUD = playerGui:WaitForChild("MobileHUD", 10)

	if mobileHUD then
		mobileHUD.SideSection.Emotes.InputBegan:Connect(registerEmoteBegan)
		mobileHUD.SideSection.Emotes.InputEnded:Connect(registerEmoteEnded)
	end
end)