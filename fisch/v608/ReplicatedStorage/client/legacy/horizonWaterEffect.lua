local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local clone = ReplicatedStorage.resources.models.HorizonWater:Clone()
clone.Parent = workspace.Terrain
local currentCamera = workspace.CurrentCamera
local mainSea = workspace:WaitForChild("world"):WaitForChild("water"):WaitForChild("seaVolumes"):WaitForChild("MainSea")
local v = mainSea.CFrame.Y + mainSea.Size.Y / 2 - 1.5
RunService.Heartbeat:Connect(function()
	clone:PivotTo(CFrame.new(currentCamera.Focus.X, v, currentCamera.Focus.Z))
end)