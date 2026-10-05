local SproutMonster = {
	Name = "Twisted Sprout",
	Rarity = "MainCharacter",
	Icon = "rbxassetid://18688072034",
	VisionRadius = 60,
	InstantRadius = 28,
	WalkSpeed = 8.5,
	RunSpeed = 17,
	InterestTime = 3,
	HearingRadius = 150,
	Damage = 1,
	WaitTime = 3,
	LineOfSight = 0.4,
	KillRadius = 4,
	HitCooldown = 2,
	ChaseAbility = true,
	AbilityCooldown = 10,
	AbilityLineOfSight = true,
	UseBehaviorTree = true,
	HearingPriority = "high",
	GuardsPosters = true,
	PosterGuardRadius = 40,
	PosterStareDuration = 3,
	PosterStareCooldown = 60,
	PosterStareCommitCooldown = 20,
	PosterGlobalCooldown = 20,
	PosterStareDistance = 7,
	PosterStareAnimation = "rbxassetid://139859859334105",
	PosterIgnoreChance = 0.2,
	PosterIgnoreDuration = 15,
	PosterTypeCooldown = 25,
	PosterUIDCooldown = 40,
	PosterScanInterval = 0.75,
	PosterReactionTexture = "rbxassetid://74679683465991",
	PosterDecalIds = {
		"rbxassetid://18352082124",
		"rbxassetid://90837196277063",
		"rbxassetid://132759687989809",
		"rbxassetid://121446997974265",
		"rbxassetid://14501402715",
		"rbxassetid://14498907666",
		"rbxassetid://73954346159675",
		"rbxassetid://72024934384436",
		"rbxassetid://114693581414754",
		"rbxassetid://94646296446461",
		"rbxassetid://117922313989126"
	},
	PosterDecalTypes = {
		["rbxassetid://18352082124"] = "poster",
		["rbxassetid://90837196277063"] = "poster",
		["rbxassetid://121446997974265"] = "drawing",
		["rbxassetid://14501402715"] = "drawing",
		["rbxassetid://14498907666"] = "drawing",
		["rbxassetid://132759687989809"] = "memory",
		["rbxassetid://73954346159675"] = "memory",
		["rbxassetid://72024934384436"] = "memory",
		["rbxassetid://114693581414754"] = "memory",
		["rbxassetid://94646296446461"] = "memory",
		["rbxassetid://117922313989126"] = "sign"
	}
}
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function renderlerp(instance, p, instance2, p2, p3, p4, p5, p6, instance3)
	local heartbeatConnection = nil
	local total = 0
	local v = false
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if instance and p and instance2 then
			if p6 == true and instance3 then
				local _, v2, _ = CFrame.lookAt(instance3.PrimaryPart.Position, instance2.CFrame.Position):ToOrientation()
				local X = instance2.CFrame.Position.X
				local Y = instance2.CFrame.Position.Y
				local Z = instance2.CFrame.Position.Z
				local cFrame = instance3.PrimaryPart.CFrame
				local v3 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)
				total += dt
				local v4 = total / 0.5
				local value = TweenService:GetValue(math.min(total / 0.5, 1), p3, p4)
				local lerped = cFrame.Position:Lerp(v3.Position, value)
				local lerped2 = cFrame.Rotation:Lerp(v3.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v4 >= 1 then
					v = true
					heartbeatConnection:Disconnect()
				end
			else
				total += dt
				local v2 = total / p2
				local value = TweenService:GetValue(math.min(total / p2, 1), p3, p4)
				local lerped = p.Position:Lerp(instance2.Position, value)
				local lerped2 = p.Rotation:Lerp(instance2.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v2 >= 1 then
					v = true
					heartbeatConnection:Disconnect()
				end
			end
		else
			v = true
			heartbeatConnection:Disconnect()
		end
	end)

	if p5 then
		while not v do
			task.wait()
		end
	end
end

local function canseetarget(folder, ancestor, _, p)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local folders = {}
	local filterDescendantsInstances = {}
	local position = folder.PrimaryPart.Position
	local v2 = (ancestor.PrimaryPart.Position - folder.PrimaryPart.Position).Unit * p
	local raycastParams = RaycastParams.new()

	if model then
		for _, folder2 in pairs(model.Monsters:GetChildren()) do
			if table.find(folders, folder2) then
				continue
			end

			for _, part in pairs(folder2:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(filterDescendantsInstances, part)
				end
			end

			table.insert(folders, folder2)
		end
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			table.insert(filterDescendantsInstances, part)
		end
	end

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		if child ~= ancestor then
			table.insert(filterDescendantsInstances, child)
		end
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = game.Workspace:Raycast(position, v2, raycastParams)

	if raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(ancestor) then
		return true
	end

	return false
end

local function resolveChaserAI(p)
	local success, result = pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")
		local MonsterAI = require(ServerScriptService:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

		for _, v in ipairs(MonsterAI.getActiveInstances()) do
			if v.chaser == p then
				return v
			end
		end

		return nil
	end)

	if success then
		return result
	end

	return nil
end

function SproutMonster.UseChaseAbility(instance, instance2, instance3)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:WaitForChild("HumanoidRootPart")
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoid2 = instance2:WaitForChild("Humanoid")
	instance2:WaitForChild("Decoding")
	game.Players:GetPlayerFromCharacter(instance2)
	local runSpeed = instance3:WaitForChild("RunSpeed")
	local patrolSpeed = instance3:WaitForChild("PatrolSpeed")
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local vector = Vector3.new(0, -(humanoidRootPart.Size.Y / 2 + humanoid.HipHeight), 0)
	local v = humanoidRootPart2.Size.Y / 2 + humanoid2.HipHeight
	Vector3.new(0, -v, 0)
	CFrame.new(0, -v, 0)
	humanoid.WalkSpeed = 0
	local success, result = pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")
		local MonsterAI = require(ServerScriptService:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

		for _, v2 in ipairs(MonsterAI.getActiveInstances()) do
			if v2.chaser == instance then
				return v2
			end
		end

		return nil
	end)

	if not success then
		result = nil
	end

	if result then
		pcall(function()
			local ServerScriptService = game:GetService("ServerScriptService")
			require(ServerScriptService.MonsterAI.Modules.AnimationDirector).forMonster(result):setMoving(false)
		end)
	end

	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Grab")
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local _, v2, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
	local X = instance.PrimaryPart.Position.X
	local Y = instance.PrimaryPart.Position.Y
	local Z = instance.PrimaryPart.Position.Z
	local cFrame = instance.PrimaryPart.CFrame
	local v3 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)

	if (instance2.PrimaryPart.Position - (instance.PrimaryPart.Position - vector)).Unit:Dot(instance.PrimaryPart.CFrame.LookVector) < 0.6 then
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		local heartbeatConnection = nil
		local total = 0
		local v4 = false
		local v5 = nil
		local v6 = nil
		local v7 = 0.4
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if instance and cFrame and v3 then
				if v5 == true and v6 then
					local _, v8, _ = CFrame.lookAt(v6.PrimaryPart.Position, v3.CFrame.Position):ToOrientation()
					local X2 = v3.CFrame.Position.X
					local Y2 = v3.CFrame.Position.Y
					local Z2 = v3.CFrame.Position.Z
					local cFrame2 = v6.PrimaryPart.CFrame
					local v9 = CFrame.new(X2, Y2, Z2) * CFrame.fromOrientation(0, v8, 0)
					total += dt
					local v10 = total / 0.5
					local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
					local lerped = cFrame2.Position:Lerp(v9.Position, value)
					local lerped2 = cFrame2.Rotation:Lerp(v9.Rotation, value)
					instance:PivotTo(CFrame.new(lerped) * lerped2)

					if v10 >= 1 then
						v4 = true
						heartbeatConnection:Disconnect()
					end
				else
					total += dt
					local v8 = total / v7
					local value = TweenService:GetValue(math.min(total / v7, 1), quad, out)
					local lerped = cFrame.Position:Lerp(v3.Position, value)
					local lerped2 = cFrame.Rotation:Lerp(v3.Rotation, value)
					instance:PivotTo(CFrame.new(lerped) * lerped2)

					if v8 >= 1 then
						v4 = true
						heartbeatConnection:Disconnect()
					end
				end
			else
				v4 = true
				heartbeatConnection:Disconnect()
			end
		end)
	end

	task.wait(0.5)

	if humanoidRootPart and humanoidRootPart2 and humanoid2 then
		local v4 = humanoidRootPart2.Size.Y / 2 + humanoid2.HipHeight
		Vector3.new(0, -v4, 0)
		local cframe = CFrame.new(0, -v4, 0)

		if model then
			local create = humanoidRootPart:WaitForChild("Create")
			create:Stop()
			create:Play()
			local clone = game.ReplicatedStorage.Parts.SproutTendril:Clone()
			clone.Parent = model:FindFirstChild("FreeArea") or model
			clone:PivotTo(humanoidRootPart2.CFrame * cframe)
			clone.Script.Disabled = false
		end
	end

	task.wait(0.5)
	task.spawn(function()
		if instance.Parent ~= nil and instance2.Parent ~= nil then
			local ServerScriptService = game:GetService("ServerScriptService")
			local SpeedControlModule = require(ServerScriptService.MonsterAI.Modules.SpeedControlModule)
			local chasing = instance:GetAttribute("Chasing")
			local v4 = instance
			local success2, result2 = pcall(function()
				local ServerScriptService2 = game:GetService("ServerScriptService")
				local MonsterAI = require(ServerScriptService2:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

				for _, v5 in ipairs(MonsterAI.getActiveInstances()) do
					if v5.chaser == v4 then
						return v5
					end
				end

				return nil
			end)

			if not success2 then
				result2 = nil
			end

			if result2 and result2.lostInterestAnimationActive then
				return
			end

			if result2 and chasing then
				SpeedControlModule.setSpeed(instance, runSpeed.Value, "chase", result2)
			else
				SpeedControlModule.setSpeed(
					instance,
					chasing and runSpeed.Value or patrolSpeed.Value,
					chasing and "chase" or "patrol"
				)
			end
		end
	end)
end

SproutMonster.PatrolCompanion = "CosmoMonster"
SproutMonster.CompanionRole = "follower"
SproutMonster.CompanionFollowDistance = 12

function SproutMonster.CustomPatrol(p)
	return p.PatrolModule.buildCompanionPatrol(p)
end

SproutMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "rbxassetid://93233916317391",
		NormalTexture = "rbxassetid://113326127939005",
		AttackTexture = "rbxassetid://70380640300838",
		PosterReactionTexture = SproutMonster.PosterReactionTexture
	}
}

function SproutMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, SproutMonster.SpecialAnimatorData.Config)
end

return SproutMonster