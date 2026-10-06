local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityClient = {}
local currentCamera = workspace.CurrentCamera
local _ = Players.LocalPlayer
local v = {}
local proxy = script:WaitForChild("Proxy")
local tracks = script.Parent:WaitForChild("Tracks")
local animations = script:WaitForChild("Animations")
local monster = workspace:WaitForChild("Monster")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local Streaming = require(ReplicatedStorage.Chest.Assets.Modules.Streaming)
local DamageIndicator = require(ReplicatedStorage.Chest.Assets.Modules.Features.DamageIndicator)
local Utils = require(script:WaitForChild("Utils"))
local Ignore = require(script:WaitForChild("Ignore"))
local v2 = {
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.Swimming,
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.PlatformStanding,
	Enum.HumanoidStateType.RunningNoPhysics,
	Enum.HumanoidStateType.StrafingNoPhysics
}

function EntityClient.SetDisabledState(object)
	for _, v3 in pairs(v2) do
		object:SetStateEnabled(v3, false)
	end
end

function EntityClient.GetEntityController(p)
	for _, v3 in ipairs(v) do
		if v3.Entity == p then
			return v3
		end
	end
end

function EntityClient.AddEntityProxy(parent)
	if table.find(Ignore, parent.Name) then
		return
	end

	local folder = proxy:FindFirstChild(parent.Name)

	if folder and folder:IsA("Folder") then
		local variant = parent:GetAttribute("Variant") or 1
		folder = folder:GetChildren()[variant]
	end

	local humanoid = parent:WaitForChild("Humanoid", 7)
	local humanoidRootPart = parent:WaitForChild("HumanoidRootPart", 7)

	if not (humanoid and humanoidRootPart) or (EntityClient.GetEntityController(parent) or parent:GetAttribute("EntityRegistered")) then
		return
	end

	for _, part in ipairs(parent:GetChildren()) do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	if folder then
		local clone = folder:Clone()
		clone.Name = parent.Name

		if parent.Name == "Pteranodon [Lv. 12500]" then
			clone.Name = "Pteranodon_KL"
		elseif parent.Name == "Spinosaurus [Lv. 5400]" then
			clone.Name = "Spinosaurus"
		elseif parent.Name == "Allosaurus [Lv. 5350]" then
			clone.Name = "Allosaurus"
		end

		if clone:GetAttribute("EntityRig") then
			for _, part in ipairs(clone:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
			end

			local primaryPart = clone.PrimaryPart
			local motor6D = Instance.new("Motor6D")
			motor6D.Part0 = humanoidRootPart
			motor6D.Part1 = primaryPart

			if parent.Name == "Allosaurus [Lv. 5350]" or parent.Name == "Spinosaurus [Lv. 5400]" then
				motor6D.C0 = CFrame.Angles(0, 3.141592653589793, 0)
			end

			motor6D.Parent = humanoidRootPart
			clone.Parent = parent
		else
			local root = clone:FindFirstChild("LowerTorso") and clone.LowerTorso:FindFirstChild("Root")

			if root then
				for _, part in pairs(clone:GetChildren()) do
					if part.Name == "HumanoidRootPart" then
						continue
					end

					if part:IsA("BasePart") then
						part.Massless = true
						part.CollisionGroup = "Mob"
					end

					part.Parent = parent
				end

				root.Part0 = humanoidRootPart
			end

			clone:Destroy()
		end
	end

	parent:SetAttribute("EntityRegistered", true)
	EntityClient.SetDisabledState(humanoid)
	local v3 = {
		Entity = parent,
		_Events = {}
	}

	function v3._OnUpdate()
		if not v3.UpdateAnimation then
			return
		end

		local magnitude = (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude
		local renderDistance = Streaming:GetRenderDistance()
		v3:SetPerformanceMode(renderDistance < magnitude)

		if renderDistance < magnitude then
			v3:UpdatePerformanceMode()
		else
			v3:UpdateAnimation()
		end
	end

	local _ = humanoid.Health
	table.insert(v3._Events, DamageIndicator.new(parent))
	require(animations:FindFirstChild(parent.Name) or animations.Default):Setup(v3)
	Streaming:RegisterDetail(parent)
	table.insert(v, v3)
end

function EntityClient.RemoveEntityProxy(p)
	for i = #v, 1, -1 do
		local v3 = v[i]

		if v3.Entity ~= p then
			continue
		end

		for _, _Event in pairs(v3._Events) do
			if typeof(_Event) == "RBXScriptConnection" and _Event.Connected then
				_Event:Disconnect()
			end
		end

		table.remove(v, i)
		table.clear(v3)
		Streaming:UnregisterDetail(p)
		break
	end
end

function EntityClient.OnEntityUpdater(p, p2: string, p3)
	if not (p and p2 and p2 == "SetEntityInvisible") then
		return
	end

	return Utils:SetEntityVisible(p, p3.Active)
end

function EntityClient.PlayEntityAnimation(p, p2: string, childName: string, options)
	if not (p and p2 and childName) then
		return
	end

	local entityController = EntityClient.GetEntityController(p)

	if not entityController then
		return
	end

	if p2 == "StopAnimationId" then
		entityController._LoopTracks = entityController._LoopTracks or {}
		local lastTime = tick()

		while not entityController._LoopTracks[childName] and tick() - lastTime < 1 do
			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()
		end

		if not entityController._LoopTracks[childName] then
			return
		end

		entityController._LoopTracks[childName]:Stop()
		entityController._LoopTracks[childName] = nil
	else
		if not entityController.PlayAnimation or (not entityController.GetPerformanceMode or entityController:GetPerformanceMode()) or entityController[p2] then
			return
		end

		entityController._LoopTracks = entityController._LoopTracks or {}
		local v3

		if p2 == "PlayAnimationId" then
			v3 = tracks:FindFirstChild(childName)

			if not v3 then
				v3 = Instance.new("Animation")
				v3.Name = childName
				v3.AnimationId = childName
				v3.Parent = tracks
			end
		end

		local v5 = entityController:PlayAnimation(childName, v3)

		if not v5 then
			return
		end

		local lastTime = tick()
		v5:AdjustSpeed((options or {}).AdjustSpeed or 1)

		while v5.Length <= 0 and tick() - lastTime < 1 do
			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()
		end

		if v5.Looped then
			if entityController._LoopTracks[childName] then
				return
			else
				entityController._LoopTracks[childName] = v5
			end
		end
	end
end

function EntityClient:Setup()
	monster.Mon.ChildAdded:Connect(EntityClient.AddEntityProxy)
	monster.Boss.ChildAdded:Connect(EntityClient.AddEntityProxy)
	monster.Mon.ChildRemoved:Connect(EntityClient.RemoveEntityProxy)
	monster.Boss.ChildRemoved:Connect(EntityClient.RemoveEntityProxy)
	ReplicatedStorage.Chest.Remotes.Events.EntityAnimate.OnClientEvent:Connect(EntityClient.PlayEntityAnimation)
	ReplicatedStorage.Chest.Remotes.Events.EntityUpdater.OnClientEvent:Connect(EntityClient.OnEntityUpdater)

	for i, child in pairs(monster.Mon:GetChildren()) do
		task.defer(EntityClient.AddEntityProxy, child)

		if i % 4 == 0 then
			task.wait(0.03333333333333333)
		end
	end

	for i, child in pairs(monster.Boss:GetChildren()) do
		task.defer(EntityClient.AddEntityProxy, child)

		if i % 4 == 0 then
			task.wait(0.03333333333333333)
		end
	end
end

local total = 0

function EntityClient.Step(_, p)
	total += p

	if total < 0.1 then
		return
	end

	total = 0

	for i = #v, 1, -1 do
		local v3 = v[i]

		if v3 then
			if v3._OnUpdate then
				local v4 = v3
				local success, result = pcall(function()
					v4._OnUpdate()
				end)

				if not success then
					warn(result)
				end
			else
				table.remove(v, i)
			end
		else
			table.remove(v, i)
		end
	end
end

return EntityClient