local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(data)
	if typeof(data.Player) == "Instance" and data.Player:IsA("Player") and not data.Player:FindFirstChild("PlayerGui") and data.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", data.Player)
		folder.Name = "PlayerGui"
	end

	local enemyRoot = data.enemyRoot
	local projectilePart = data.projectilePart
	local _ = data.victimRootParts
	local syncedEndTime = data.syncedEndTime
	local _ = data.initVec
	local rotPerFrame = data.rotPerFrame

	if enemyRoot == nil or enemyRoot.Parent == nil or (enemyRoot.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if projectilePart then
		projectilePart.CanCollide = false
	end

	local heartbeatConnection = nil
	local cFrame = projectilePart.CFrame
	local v = time()
	local v2 = time()
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if syncedEndTime < Workspace:GetServerTimeNow() or enemyRoot == nil or enemyRoot.Parent == nil or projectilePart == nil or projectilePart.Parent == nil then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		else
			local _ = time() - v

			if time() - v2 > 0.15 then
				v2 = time()
			end

			cFrame = CFrame.Angles(0, rotPerFrame, 0) * cFrame
			enemyRoot.CFrame = CFrame.new(projectilePart.CFrame.Position, data.hrp.Position)
		end
	end)
end