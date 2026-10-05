local GuiService = game:GetService("GuiService")
game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local parent = script.Parent
local _ = parent.Parent.Parent
parent.Activated:Connect(function()
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	local currentCamera = workspace.CurrentCamera
	local v = PlayerMouse.Hit.Position - currentCamera.CFrame.Position

	if v.Magnitude < 0.001 then
		return
	end

	local unit = v.Unit
	local v2 = currentCamera.ViewportSize * 0.5
	local guiInset = GuiService:GetGuiInset()
	local v3 = UserInputService:GetMouseLocation() - guiInset
	local vector = Vector2.new(v3.X - v2.X, v3.Y - v2.Y)
	local v4 = math.min(v2.X, v2.Y)
	local v5 = math.clamp(vector.Magnitude / v4, 0, 1)
	Net:RemoteEvent("UseItem"):FireServer(unit, v5)
end)