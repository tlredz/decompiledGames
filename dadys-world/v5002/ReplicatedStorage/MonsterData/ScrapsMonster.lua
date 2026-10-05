local ScrapsMonster = {
	Name = "Twisted Scraps",
	Rarity = "Rare",
	Icon = "rbxassetid://17572307852",
	VisionRadius = 75,
	InstantRadius = 30,
	WalkSpeed = 8,
	RunSpeed = 16,
	InterestTime = 2,
	HearingRadius = 100,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.5,
	HitCooldown = 2.5,
	ChaseAbility = true,
	AbilityCooldown = 15,
	AbilityLineOfSight = true,
	Ranged = true,
	UseBehaviorTree = true
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local character = ReplicatedStorage:WaitForChild("SharedModules"):WaitForChild("Character")
local DamageHandler = require(character:WaitForChild("DamageHandler"))

-- equivalent calls inferred from this helper; original call sites unknown
local function getScrapsGrabLaunchDelay()
	local info = workspace:FindFirstChild("Info")
	local scrapsGrabLaunchDelay = info and info:GetAttribute("ScrapsGrabLaunchDelay")

	if typeof(scrapsGrabLaunchDelay) == "number" and scrapsGrabLaunchDelay >= 0 then
		return scrapsGrabLaunchDelay
	end

	return 0
end

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

	local decoys = workspace:FindFirstChild("Decoys")

	if decoys then
		for _, child in pairs(decoys:GetChildren()) do
			if child ~= ancestor then
				table.insert(filterDescendantsInstances, child)
			end
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

function ScrapsMonster.UseChaseAbility(instance, instance2, instance3)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:WaitForChild("HumanoidRootPart")
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoid2 = instance2:WaitForChild("Humanoid")
	instance2:WaitForChild("Decoding")
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance2)
	local runSpeed = instance3:WaitForChild("RunSpeed")
	local patrolSpeed = instance3:WaitForChild("PatrolSpeed")
	local grabbing = instance:WaitForChild("Grabbing")
	local position = nil
	local vector = Vector3.new(0, -(humanoidRootPart.Size.Y / 2 + humanoid.HipHeight), 0)
	Vector3.new(0, -(humanoidRootPart2.Size.Y / 2 + humanoid2.HipHeight), 0)
	local _, _ = pcall(function()
		position = nil

		if playerFromCharacter then
			position = instance2.PrimaryPart.Position
		end
	end)

	if position ~= nil and canseetarget(
		instance,
		instance2,
		position,
		(position - instance.PrimaryPart.Position).Magnitude
	) then
		local v = true
		task.spawn(function()
			while v and instance.Parent ~= nil do
				humanoid.WalkSpeed = 0
				task.wait()
			end
		end)
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

		local v2

		if result then
			v2 = pcall(function()
				local ServerScriptService = game:GetService("ServerScriptService")
				require(ServerScriptService.MonsterAI.Modules.AnimationDirector).forMonster(result):setMoving(false)
			end)
		else
			v2 = false
		end

		if not v2 then
			ReplicatedStorage.Events.AnimationStop:FireAllClients(instance, "Run")
			ReplicatedStorage.Events.AnimationStop:FireAllClients(instance, "Walk")
		end

		local ServerScriptService = game:GetService("ServerScriptService")
		local RangedTwistedManager = require(ServerScriptService.MonsterAI.Modules.RangedTwistedManager)
		local v3 = RangedTwistedManager.playWindupAnim(instance, RangedTwistedManager.getScrapsWindupAnimId())
		local v4 = RangedTwistedManager.playWindupSound(humanoidRootPart, RangedTwistedManager.getScrapsWindupSoundId())
		RangedTwistedManager.showRangedIndicator(humanoidRootPart, instance2)
		local _, v5, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
		local X = instance.PrimaryPart.Position.X
		local Y = instance.PrimaryPart.Position.Y
		local Z = instance.PrimaryPart.Position.Z
		local cFrame = instance.PrimaryPart.CFrame
		local v6 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v5, 0)

		if (instance2.PrimaryPart.Position - (instance.PrimaryPart.Position - vector)).Unit:Dot(instance.PrimaryPart.CFrame.LookVector) < 0.6 then
			local quad = Enum.EasingStyle.Quad
			local out = Enum.EasingDirection.Out
			local heartbeatConnection = nil
			local total = 0
			local v7 = false
			local v8 = nil
			local v9 = nil
			local v10 = 0.4
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if instance and cFrame and v6 then
					if v8 == true and v9 then
						local _, v11, _ = CFrame.lookAt(v9.PrimaryPart.Position, v6.CFrame.Position):ToOrientation()
						local X2 = v6.CFrame.Position.X
						local Y2 = v6.CFrame.Position.Y
						local Z2 = v6.CFrame.Position.Z
						local cFrame2 = v9.PrimaryPart.CFrame
						local v12 = CFrame.new(X2, Y2, Z2) * CFrame.fromOrientation(0, v11, 0)
						total += dt
						local v13 = total / 0.5
						local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
						local lerped = cFrame2.Position:Lerp(v12.Position, value)
						local lerped2 = cFrame2.Rotation:Lerp(v12.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v13 >= 1 then
							v7 = true
							heartbeatConnection:Disconnect()
						end
					else
						total += dt
						local v11 = total / v10
						local value = TweenService:GetValue(math.min(total / v10, 1), quad, out)
						local lerped = cFrame.Position:Lerp(v6.Position, value)
						local lerped2 = cFrame.Rotation:Lerp(v6.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v11 >= 1 then
							v7 = true
							heartbeatConnection:Disconnect()
						end
					end
				else
					v7 = true
					heartbeatConnection:Disconnect()
				end
			end)
		end

		RangedTwistedManager.waitForScrapsGrabCue(v3)

		if v3 and v3.IsPlaying then
			v3:Stop(0.1)
		end

		if v4 and v4.Parent then
			v4:Stop()
			v4:Destroy()
		end

		RangedTwistedManager.playGrabAnim(instance, RangedTwistedManager.getScrapsGrabAnimId())
		local scrapsGrabLaunchDelay = getScrapsGrabLaunchDelay() -- equivalent call inferred; original call site unknown

		if scrapsGrabLaunchDelay > 0 then
			task.wait(scrapsGrabLaunchDelay)
		end

		task.delay(0.4, function()
			if instance and instance.Parent then
				RangedTwistedManager.playTargetingCue(humanoidRootPart)
			end
		end)
		task.delay(1, function()
			v = false

			if instance.Parent ~= nil and instance2.Parent ~= nil then
				grabbing.Value = false

				if instance:GetAttribute("Attacking") then
					return
				end

				local ServerScriptService2 = game:GetService("ServerScriptService")
				local SpeedControlModule = require(ServerScriptService2.MonsterAI.Modules.SpeedControlModule)
				local chasing = instance:GetAttribute("Chasing")
				local v7 = instance
				local success2, result2 = pcall(function()
					local ServerScriptService3 = game:GetService("ServerScriptService")
					local MonsterAI = require(ServerScriptService3:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

					for _, v8 in ipairs(MonsterAI.getActiveInstances()) do
						if v8.chaser == v7 then
							return v8
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

				if result2 then
					if chasing then
						SpeedControlModule.setSpeed(instance, runSpeed.Value, "chase", result2)
					else
						SpeedControlModule.setSpeed(instance, patrolSpeed.Value, "patrol")
					end
				else
					ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, chasing and "Run" or "Walk")
					instance:SetAttribute("ChaseState", chasing and "run" or "walk")
					SpeedControlModule.setSpeed(
						instance,
						chasing and runSpeed.Value or patrolSpeed.Value,
						chasing and "chase" or "patrol"
					)
				end
			end
		end)
		local _, _ = pcall(function()
			if game.Players:GetPlayerFromCharacter(instance2) then
				position = instance2.PrimaryPart.Position
			end
		end)

		if position ~= nil and canseetarget(
			instance,
			instance2,
			position,
			(position - instance.PrimaryPart.Position).Magnitude
		) and instance2 and instance2.Parent ~= nil and humanoidRootPart2 and humanoidRootPart2.Parent ~= nil and not (instance2:FindFirstChild("BoxAbilityActive") or instance2:GetAttribute("RangedAttackImmune")) then
			grabbing.Value = true
			local _, v7, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
			local X2 = instance.PrimaryPart.Position.X
			local Y2 = instance.PrimaryPart.Position.Y
			local Z2 = instance.PrimaryPart.Position.Z
			local _ = instance.PrimaryPart.CFrame
			local _ = CFrame.new(X2, Y2, Z2) * CFrame.fromOrientation(0, v7, 0)
			task.spawn(function()
				if instance and instance.Parent ~= nil then
					local scrapsGrab = ReplicatedStorage.Parts.RenderModules.ScrapsGrab
					ReplicatedStorage.Events.RenderObject:FireAllClients(scrapsGrab, { instance, instance2 })
				end
			end)
			task.wait(0.5)
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local _, v8, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
			local X3 = instance.PrimaryPart.Position.X
			local Y3 = instance.PrimaryPart.Position.Y
			local Z3 = instance.PrimaryPart.Position.Z
			local _ = instance.PrimaryPart.CFrame
			local _ = CFrame.new(X3, Y3, Z3) * CFrame.fromOrientation(0, v8, 0)
			local _, _ = pcall(function()
				if game.Players:GetPlayerFromCharacter(instance2) then
					position = instance2.PrimaryPart.Position
				end
			end)

			if position ~= nil then
				local stats = instance2:WaitForChild("Stats")
				local v9 = math.clamp(
					1 - (stats.Stealth.Value * stats.StealthModifier.Value / 5 * 0.075 - 0.15),
					0.85,
					1.15
				)
				local v10 = ScrapsMonster.VisionRadius * v9

				if canseetarget(instance, instance2, position, v10) and instance2 and instance2.Parent ~= nil and humanoidRootPart2 and humanoidRootPart2.Parent ~= nil then
					DamageHandler.handleDamage(
						instance2,
						ScrapsMonster.Damage,
						instance.Name,
						ScrapsMonster.HitCooldown,
						{
							isRangedAttack = true
						}
					)
				end
			end
		end
	end
end

ScrapsMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "rbxassetid://110469431224958",
		NormalTexture = "rbxassetid://126968452752785",
		AttackTexture = "rbxassetid://114471532312325"
	}
}

function ScrapsMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, ScrapsMonster.SpecialAnimatorData.Config)
end

return ScrapsMonster