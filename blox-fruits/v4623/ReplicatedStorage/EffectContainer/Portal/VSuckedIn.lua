local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(-1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(data)
	local player = data.player
	local origin = data.origin
	local endPos = data.endPos
	local root = data.root
	local syncedEndTime = data.syncedEndTime
	local receivingPlayer = data.receivingPlayer

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 3000 or root == nil or root.Parent == nil then
		return
	end

	local v = syncedEndTime - Workspace:GetServerTimeNow()

	if v <= 0 then
		return
	end

	local cFrame = root.CFrame
	local connections = {}
	table.insert(connections, RunService.Heartbeat:Connect(function()
		if syncedEndTime < Workspace:GetServerTimeNow() or root.Parent == nil then
			for _, connection in connections do
				connection:Disconnect()
			end
		else
			local v2 = 1 - (syncedEndTime - Workspace:GetServerTimeNow()) / v
			cFrame = cFrame.Rotation + origin + (endPos - origin) * v2
			local humanoid = root.Parent:FindFirstChildOfClass("Humanoid")

			if (root.CFrame.p - cFrame.p).Magnitude > 200 or humanoid:GetAttribute("LastCPortalUseTime") and Workspace:GetServerTimeNow() - humanoid:GetAttribute("LastCPortalUseTime") < 0.1 then
				for _, connection in connections do
					connection:Disconnect()
				end
			else
				root.CFrame = cFrame
			end
		end
	end))
	local humanoid = root.Parent:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid:IsDescendantOf(Workspace) then
		humanoid:GetAttributeChangedSignal("LastCPortalUseTime"):Once(function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end)
	end

	local v2 = syncedEndTime - Workspace:GetServerTimeNow()

	if localPlayer == receivingPlayer and data.dontPlayFlash ~= true then
		task.wait(v2)
		Util.CameraShaker:ShakeOnce(37, 10, 0, 1.6)

		if root ~= nil and root.Parent ~= nil then
			Util.Sound:Play("PortalVTeleport", root)
		end

		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "PortalVColorFlash"
		colorCorrectionEffect.Brightness = 2.5
		Util.SetParentOverrideWithColor(colorCorrectionEffect, Lighting, player, "PortalFruitVFXColor")
		task.wait(0.5)
		heartbeatLoopFor2(0.5, function(_, _, p)
			colorCorrectionEffect.Brightness = 2.5 - 2.5 * p
		end, function()
			colorCorrectionEffect:Destroy()
		end)
	end
end