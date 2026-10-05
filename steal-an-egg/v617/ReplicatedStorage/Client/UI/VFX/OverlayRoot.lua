local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local v = {
	displayOrder = 1200,
	marker = "OverlayRootFallback"
}
local localPlayer = Players.LocalPlayer
local v2 = nil

local function playerGui()
	local v3 = v2

	if v3 and v3.Parent then
		return v3
	end

	local playerGui2 = localPlayer:WaitForChild("PlayerGui")
	v2 = playerGui2
	return playerGui2
end

local function authoredDisplayOrder()
	local overlayUI = StarterGui:FindFirstChild("OverlayUI")

	if overlayUI and overlayUI:IsA("ScreenGui") then
		return overlayUI.DisplayOrder
	end

	return 1200
end

local function buildFallback(parent)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OverlayUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	local overlayUI = StarterGui:FindFirstChild("OverlayUI")
	local displayOrder

	if overlayUI and overlayUI:IsA("ScreenGui") then
		displayOrder = overlayUI.DisplayOrder
	else
		displayOrder = v.displayOrder
	end

	screenGui.DisplayOrder = displayOrder
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui:SetAttribute("OverlayRootFallback", true)
	screenGui.Parent = parent
	return screenGui
end

return function()
	local playerGui2 = v2

	if not (playerGui2 and playerGui2.Parent) then
		playerGui2 = localPlayer:WaitForChild("PlayerGui")
		v2 = playerGui2
	end

	local overlayUI = playerGui2:FindFirstChild("OverlayUI") or playerGui2:WaitForChild("OverlayUI", 8)

	if overlayUI and overlayUI:IsA("ScreenGui") then
		return overlayUI
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "OverlayUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	local overlayUI2 = StarterGui:FindFirstChild("OverlayUI")
	local displayOrder

	if overlayUI2 and overlayUI2:IsA("ScreenGui") then
		displayOrder = overlayUI2.DisplayOrder
	else
		displayOrder = v.displayOrder
	end

	screenGui.DisplayOrder = displayOrder
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui:SetAttribute(v.marker, true)
	screenGui.Parent = playerGui2
	return screenGui
end