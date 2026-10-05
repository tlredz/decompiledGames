local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
local humanoid = script.Parent:WaitForChild("Humanoid")
require(ReplicatedStorage.CAM.Global.Utility)
local StaminaComponent = require(ReplicatedStorage.CAM.Client.Components.Client.StaminaComponent)
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local billboardGui = Instance.new("BillboardGui")
billboardGui.Name = "Stamina"
billboardGui.AlwaysOnTop = true
billboardGui:AddTag("Billboards")
billboardGui.StudsOffset = vector.create(0, -3.25, 0)
billboardGui.Size = UDim2.fromScale(1.65, 0.14)
billboardGui.Parent = humanoidRootPart
local staminaComponent = StaminaComponent(billboardGui)
local diedConnection = nil
diedConnection = humanoid.Died:Connect(function()
	if diedConnection then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	if staminaComponent ~= nil then
		staminaComponent()
		staminaComponent = nil
	end
end)