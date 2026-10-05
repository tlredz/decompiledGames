local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local count = 0

local function findHotbar()
	local backpackGui = playerGui:FindFirstChild("BackpackGui")
	local backpack = backpackGui and backpackGui:FindFirstChild("Backpack")
	local hotbar = backpack and backpack:FindFirstChild("Hotbar")

	if hotbar and hotbar:IsA("GuiObject") and hotbar.AbsoluteSize.Y > 0 then
		return hotbar
	end

	return nil
end

local function placeAboveHotbar(flashUserId, userId)
	local absoluteSize = flashUserId.AbsoluteSize
	local hotbar = findHotbar()

	if hotbar == nil or absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		userId.Position = UDim2.fromScale(0.5, 0.86)
		return
	end

	local gap = flashUserId:GetAttribute("Gap") or 0.01
	local absolutePosition = flashUserId.AbsolutePosition
	local v = hotbar.AbsolutePosition.X + hotbar.AbsoluteSize.X / 2 - absolutePosition.X
	local v2 = hotbar.AbsolutePosition.Y - absolutePosition.Y
	userId.Position = UDim2.fromScale(v / absoluteSize.X, v2 / absoluteSize.Y - gap)
end

local function flash()
	local flashUserId = playerGui:FindFirstChild("FlashUserId")
	local userId = flashUserId and flashUserId:FindFirstChild("UserId")

	if flashUserId == nil or not flashUserId:IsA("ScreenGui") or userId == nil or not userId:IsA("TextLabel") then
		warn("[FlashUserId] PlayerGui.FlashUserId.UserId is missing")
		return
	end

	count += 1
	local v = count
	userId.Text = tostring(localPlayer.UserId)
	placeAboveHotbar(flashUserId, userId)
	flashUserId.Enabled = true
	task.delay(flashUserId:GetAttribute("Seconds") or 0.5, function()
		if count == v then
			flashUserId.Enabled = false
		end
	end)
end

return {
	Start = function()
		Remotes.Broadcasts.FlashUserId.OnClientEvent:Connect(flash)
	end
}