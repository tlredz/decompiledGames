local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Replion = require(ReplicatedStorage2.Packages.Replion)
require(ReplicatedStorage2.Shared.ReplionUtils)
local EmoteWheelController = require(ReplicatedStorage2.Controllers.EmoteWheelController)
local GamepadIconController = require(ReplicatedStorage2.Controllers.GamepadIconController)
local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerGui
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

script.Parent.Activated:Connect(registerEmoteBegan)
local v2 = Replion.Client:WaitReplion("Data")

local function update()
	local lastInputType = UserInputService:GetLastInputType()
	local v3

	if lastInputType == Enum.UserInputType.Focus then
		v3 = (#UserInputService:GetConnectedGamepads() >= 1 or GuiService:IsTenFootInterface()) and "Console" or "PC"
	else
		v3 = lastInputType.Name:find("Gamepad") and "Console" or "PC"
	end

	local expect = v2:GetExpect((`Settings.Keybinds.Emote.{v3}.Bind1`))
	script.Parent.Icon.Visible = false

	if v3 == "PC" then
		local v4 = expect:gsub("MouseButton", "M")
		script.Parent.Zatext.Text = `({v4}) Emote`
	else
		local v4 = pcall(function()
			return Enum.KeyCode[expect]
		end)
		local v5 = v4 and Enum.KeyCode[expect]
		local mappedImageForKeyCode = v4 and GamepadIconController:GetMappedImageForKeyCode(v5) or ""
		script.Parent.Zatext.Text = "         Emote"
		script.Parent.Icon.Image = mappedImageForKeyCode
		script.Parent.Icon.Visible = true
	end
end

UserInputService.LastInputTypeChanged:Connect(update)
v2:OnChange("Settings.Keybinds.Emote", update)
update()