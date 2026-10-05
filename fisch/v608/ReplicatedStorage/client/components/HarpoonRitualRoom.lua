local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "HarpoonRitualRoom",
	Ancestors = { Workspace }
})

function v:Construct()
	self.trove = Trove.new()
	self.lastShot = 0
	self.stopped = false
end

function v:Start()
	task.spawn(function()
		self.remote = Net:RemoteEvent("RitualVault/TargetHit", -1)
		local remoteEvent = Net:RemoteEvent("RitualVault/Fade", -1)
		local remoteEvent2 = Net:RemoteEvent("HarpoonGun/FireFx", -1)

		if self.stopped then
			return
		end

		self.trove:Add(remoteEvent.OnClientEvent:Connect(function(value)
			CutsceneController:Fade(typeof(value) ~= "number" and 2.5 or value, 0.16, 0.24)
		end))
		self.trove:Add(remoteEvent2.OnClientEvent:Connect(function(p, p2, value, _, _, p3)
			if p ~= localPlayer.UserId or (typeof(p2) ~= "Vector3" or typeof(value) ~= "number") then
				return
			end

			if typeof(p3) ~= "Vector3" then
				p3 = nil
			end

			self:OnLocalShot(p2, value, p3)
		end))
	end)
end

function v:OnLocalShot(p, p2, p3)
	if tick() - self.lastShot < 0.4 or not self.remote then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = p3 or Workspace.CurrentCamera.CFrame.Position
	local v3 = math.min(p2 + (p3 and 2 or 24), 300)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local instances = { character }

	for _ = 1, 4 do
		raycastParams.FilterDescendantsInstances = instances
		local raycastResult = Workspace:Raycast(v2, p * v3, raycastParams)

		if not raycastResult then
			break
		end

		local instance = raycastResult.Instance

		while instance and instance ~= self.Instance and (instance.Name ~= "Target" or not instance:GetAttribute("TargetId")) do
			instance = instance.Parent
		end

		if instance and instance ~= self.Instance and instance:IsDescendantOf(self.Instance) then
			if (raycastResult.Position - humanoidRootPart.Position).Magnitude > 140 then
				break
			end

			self.lastShot = tick()
			self.remote:FireServer(self.Instance, instance:GetAttribute("TargetId"))
			break
		elseif raycastResult.Instance.CanCollide then
			break
		else
			table.insert(instances, raycastResult.Instance)
		end
	end
end

function v:Stop()
	self.stopped = true
	self.trove:Destroy()
end

return v