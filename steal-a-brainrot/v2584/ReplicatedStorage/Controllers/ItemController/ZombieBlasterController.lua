local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
game:GetService("Lighting")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = localPlayer.PlayerScripts
local _ = workspace.CurrentCamera
playerGui:WaitForChild("ToolsScreen")
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local _ = CharacterController.Controls
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local v = {}
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p: string, data)
	if p ~= "FireZombieBlaster" then
		return
	end

	local mousePosition = data.MousePosition
	local lifeTime = data.LifeTime
	local origin = data.Origin
	local speed = data.Speed
	local UUID = data.UUID
	local attachment1 = origin:FindFirstChild("Attachment1")

	if not attachment1 then
		return
	end

	local worldPosition = attachment1.WorldPosition
	local unit = (mousePosition - worldPosition).Unit
	local clone = script.Shoot:Clone()
	local attachment = Instance.new("Attachment", clone)
	local linearVelocity = Instance.new("LinearVelocity")
	clone.CanQuery = false
	clone.Position = worldPosition
	clone.CanCollide = false
	linearVelocity.VectorVelocity = unit * speed
	linearVelocity.Attachment0 = attachment
	linearVelocity.Parent = clone
	Debris:AddItem(clone, lifeTime)
	clone.Parent = workspace
	clone.Destroying:Once(function()
		v[UUID] = nil
	end)
	v[UUID] = clone
end)
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p: string, p2)
	if p ~= "DestroyZombieBlaster" then
		return
	end

	if v[p2] then
		v[p2]:Destroy()
		v[p2] = nil
	end
end)
return {}