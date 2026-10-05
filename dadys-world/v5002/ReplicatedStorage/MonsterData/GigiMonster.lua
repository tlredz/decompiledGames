local GigiMonster = {
	Name = "Twisted Gigi",
	Rarity = "Rare",
	Icon = "rbxassetid://106223056157959",
	VisionRadius = 65,
	InstantRadius = 30,
	WalkSpeed = 10,
	RunSpeed = 19,
	InterestTime = 2.25,
	HearingRadius = 120,
	LineOfSight = 0.4,
	Damage = 1,
	KillRadius = 5,
	HitCooldown = 3,
	WaitTime = 1,
	ChaseAbility = true,
	AbilityCooldown = 12,
	AbilityLineOfSight = true,
	HearingPriority = "high",
	Ranged = true,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			AttackTexture = "rbxassetid://115229255767263",
			BlinkTexture = "rbxassetid://98883758732854",
			NormalTexture = "rbxassetid://137204193123485"
		}
	}
}

function GigiMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, GigiMonster.SpecialAnimatorData.Config)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local function canseetarget(folder, ancestor, position, value)
	if not (folder and folder.PrimaryPart and ancestor and ancestor.PrimaryPart) then
		return false
	end

	if type(value) == "number" then
		local position2 = folder.PrimaryPart.Position

		if value < ((typeof(position) == "Vector3" and position or ancestor.PrimaryPart.Position) - position2).Magnitude then
			return false
		end
	end

	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local folders = {}
	local filterDescendantsInstances = {}
	local position2 = folder.PrimaryPart.Position
	local v2 = ancestor.PrimaryPart.Position - position2

	if v2.Magnitude <= 0.05 then
		return true
	end

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

	local CollectionService = game:GetService("CollectionService")

	for _, v3 in ipairs(CollectionService:GetTagged("GigiStash")) do
		table.insert(filterDescendantsInstances, v3)
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = game.Workspace:Raycast(position2, v2, raycastParams)

	if raycastResult and raycastResult.Instance then
		if raycastResult.Instance:IsDescendantOf(ancestor) then
			return true
		end

		return false
	else
		return true
	end
end

game:GetService("Debris")

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

local function commitSteal(_, instance, humanoidRootPart)
	local success, result = pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")
		return require(ServerScriptService:WaitForChild("Modules"):WaitForChild("ItemTransfer")).take(instance, {
			reason = "GigiSteal",
			owner = "GigiSteal"
		})
	end)

	if not success then
		warn("[GigiMonster] steal commit failed: " .. tostring(result))
		return nil
	end

	if not result then
		return nil
	end

	result.stolenFrom = instance.Name
	local steal = humanoidRootPart:FindFirstChild("Steal")

	if steal then
		steal:Stop()
		steal:Play()
	end

	return result
end

function GigiMonster.UseChaseAbility(instance, instance2, instance3)
	local WAIT_INTERVAL = 0.5
	local v = nil
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:WaitForChild("HumanoidRootPart", 5)
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoid2 = instance2:WaitForChild("Humanoid", 5)

	if not (humanoidRootPart2 and humanoid2) then
		return nil
	end

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
	local inventory = instance2:WaitForChild("Inventory", 5)

	if not inventory then
		return
	end

	local slot1 = inventory:WaitForChild("Slot1")
	local slot2 = inventory:WaitForChild("Slot2")
	local slot3 = inventory:WaitForChild("Slot3")
	local slot4 = inventory:FindFirstChild("Slot4")
	local v3 = slot1.Value ~= "None" and true or false
	local v4 = slot2.Value ~= "None" and not v3 or v3
	local v5 = slot3.Value ~= "None" and not v4 or v4
	local v6 = slot4 and slot4.Value ~= "None" and not v5 and true or v5

	if position == nil or not (v6 and canseetarget(
		instance,
		instance2,
		position,
		(position - instance.PrimaryPart.Position).Magnitude
	)) then
		return v
	end

	local v7 = true
	local v8 = os.clock() + 2
	task.spawn(function()
		while v7 and os.clock() < v8 and instance.Parent ~= nil do
			humanoid.WalkSpeed = 0
			task.wait()
		end

		if v7 and instance.Parent then
			v7 = false
			grabbing.Value = false
			local v9 = instance
			local success, result = pcall(function()
				local ServerScriptService = game:GetService("ServerScriptService")
				local MonsterAI = require(ServerScriptService:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

				for _, v10 in ipairs(MonsterAI.getActiveInstances()) do
					if v10.chaser == v9 then
						return v10
					end
				end

				return nil
			end)

			if not success then
				result = nil
			end

			if not (result and result.customState or instance:GetAttribute("Attacking")) then
				local ServerScriptService = game:GetService("ServerScriptService")
				local SpeedControlModule = require(ServerScriptService.MonsterAI.Modules.SpeedControlModule)
				local chasing = instance:GetAttribute("Chasing")
				SpeedControlModule.setSpeed(
					instance,
					chasing and runSpeed.Value or patrolSpeed.Value,
					chasing and "chase" or "patrol",
					chasing and result or nil
				)
			end
		end
	end)
	local success, result = pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")
		local MonsterAI = require(ServerScriptService:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

		for _, v9 in ipairs(MonsterAI.getActiveInstances()) do
			if v9.chaser == instance then
				return v9
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
	local ServerScriptService = game:GetService("ServerScriptService")
	local RangedTwistedManager = require(ServerScriptService.MonsterAI.Modules.RangedTwistedManager)
	local v9 = RangedTwistedManager.playWindupSound(humanoidRootPart, RangedTwistedManager.getGigiWindupSoundId())
	RangedTwistedManager.showRangedIndicator(humanoidRootPart, instance2)
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local _, v10, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
	local X = instance.PrimaryPart.Position.X
	local Y = instance.PrimaryPart.Position.Y
	local Z = instance.PrimaryPart.Position.Z
	local cFrame = instance.PrimaryPart.CFrame
	local v11 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v10, 0)

	if (instance2.PrimaryPart.Position - (instance.PrimaryPart.Position - vector)).Unit:Dot(instance.PrimaryPart.CFrame.LookVector) < 0.6 then
		local quad = Enum.EasingStyle.Quad
		local out = Enum.EasingDirection.Out
		local heartbeatConnection = nil
		local total = 0
		local v12 = false
		local v13 = nil
		local v14 = nil
		local v15 = 0.4
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if instance and cFrame and v11 then
				if v13 == true and v14 then
					local _, v16, _ = CFrame.lookAt(v14.PrimaryPart.Position, v11.CFrame.Position):ToOrientation()
					local X2 = v11.CFrame.Position.X
					local Y2 = v11.CFrame.Position.Y
					local Z2 = v11.CFrame.Position.Z
					local cFrame2 = v14.PrimaryPart.CFrame
					local v17 = CFrame.new(X2, Y2, Z2) * CFrame.fromOrientation(0, v16, 0)
					total += dt
					local v18 = total / 0.5
					local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
					local lerped = cFrame2.Position:Lerp(v17.Position, value)
					local lerped2 = cFrame2.Rotation:Lerp(v17.Rotation, value)
					instance:PivotTo(CFrame.new(lerped) * lerped2)

					if v18 >= 1 then
						v12 = true
						heartbeatConnection:Disconnect()
					end
				else
					total += dt
					local v16 = total / v15
					local value = TweenService:GetValue(math.min(total / v15, 1), quad, out)
					local lerped = cFrame.Position:Lerp(v11.Position, value)
					local lerped2 = cFrame.Rotation:Lerp(v11.Rotation, value)
					instance:PivotTo(CFrame.new(lerped) * lerped2)

					if v16 >= 1 then
						v12 = true
						heartbeatConnection:Disconnect()
					end
				end
			else
				v12 = true
				heartbeatConnection:Disconnect()
			end
		end)
	end

	task.wait(WAIT_INTERVAL)
	task.delay(1, function()
		v7 = false

		if grabbing and grabbing.Parent then
			grabbing.Value = false
		end

		if instance.Parent ~= nil then
			if instance:GetAttribute("Attacking") then
				return
			end

			local ServerScriptService2 = game:GetService("ServerScriptService")
			local SpeedControlModule = require(ServerScriptService2.MonsterAI.Modules.SpeedControlModule)
			local chasing = instance:GetAttribute("Chasing")
			local v12 = instance
			local success2, result2 = pcall(function()
				local ServerScriptService3 = game:GetService("ServerScriptService")
				local MonsterAI = require(ServerScriptService3:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

				for _, v13 in ipairs(MonsterAI.getActiveInstances()) do
					if v13.chaser == v12 then
						return v13
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
	local _, _ = pcall(function()
		if game.Players:GetPlayerFromCharacter(instance2) then
			position = instance2.PrimaryPart.Position
		end
	end)

	if not (position ~= nil and canseetarget(
		instance,
		instance2,
		position,
		(position - instance.PrimaryPart.Position).Magnitude
	) and instance2 and instance2.Parent ~= nil and humanoidRootPart2 and humanoidRootPart2.Parent ~= nil) then
		return v
	end

	if v9 and v9.Parent then
		v9:Stop()
		v9:Destroy()
	end

	task.spawn(function()
		RangedTwistedManager.playTargetingCue(humanoidRootPart)
	end)
	grabbing.Value = true
	local _, v12, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
	local X2 = instance.PrimaryPart.Position.X
	local Y2 = instance.PrimaryPart.Position.Y
	local Z2 = instance.PrimaryPart.Position.Z
	local cFrame2 = instance.PrimaryPart.CFrame
	local v13 = CFrame.new(X2, Y2, Z2) * CFrame.fromOrientation(0, v12, 0)
	local quad = Enum.EasingStyle.Quad
	local out = Enum.EasingDirection.Out
	local heartbeatConnection = nil
	local total = 0
	local v14 = false
	local v15 = nil
	local v16 = nil
	local v17 = 0.4
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if instance and cFrame2 and v13 then
			if v15 == true and v16 then
				local _, v18, _ = CFrame.lookAt(v16.PrimaryPart.Position, v13.CFrame.Position):ToOrientation()
				local X3 = v13.CFrame.Position.X
				local Y3 = v13.CFrame.Position.Y
				local Z3 = v13.CFrame.Position.Z
				local cFrame3 = v16.PrimaryPart.CFrame
				local v19 = CFrame.new(X3, Y3, Z3) * CFrame.fromOrientation(0, v18, 0)
				total += dt
				local v20 = total / 0.5
				local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
				local lerped = cFrame3.Position:Lerp(v19.Position, value)
				local lerped2 = cFrame3.Rotation:Lerp(v19.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v20 >= 1 then
					v14 = true
					heartbeatConnection:Disconnect()
				end
			else
				total += dt
				local v18 = total / v17
				local value = TweenService:GetValue(math.min(total / v17, 1), quad, out)
				local lerped = cFrame2.Position:Lerp(v13.Position, value)
				local lerped2 = cFrame2.Rotation:Lerp(v13.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v18 >= 1 then
					v14 = true
					heartbeatConnection:Disconnect()
				end
			end
		else
			v14 = true
			heartbeatConnection:Disconnect()
		end
	end)
	task.spawn(function()
		if instance and instance.Parent ~= nil then
			local gigiGrab = ReplicatedStorage.Parts.RenderModules.GigiGrab
			ReplicatedStorage.Events.RenderObject:FireAllClients(gigiGrab, { instance, instance2 })
		end
	end)
	local waitForStealConnect = GigiMonster.WaitForStealConnect

	if type(waitForStealConnect) == "function" then
		local success2, result2 = pcall(waitForStealConnect, instance, 0.5)

		if not success2 then
			warn("[GigiMonster] WaitForStealConnect errored: " .. tostring(result2))
			task.wait(WAIT_INTERVAL)
		end
	else
		task.wait(WAIT_INTERVAL)
	end

	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local _, v18, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
	local X3 = instance.PrimaryPart.Position.X
	local Y3 = instance.PrimaryPart.Position.Y
	local Z3 = instance.PrimaryPart.Position.Z
	local cFrame3 = instance.PrimaryPart.CFrame
	local v19 = CFrame.new(X3, Y3, Z3) * CFrame.fromOrientation(0, v18, 0)
	local quad2 = Enum.EasingStyle.Quad
	local out2 = Enum.EasingDirection.Out
	local heartbeatConnection2 = nil
	local total2 = 0
	local v20 = false
	local v21 = nil
	local v22 = nil
	local v23 = 0.4
	heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
		if instance and cFrame3 and v19 then
			if v21 == true and v22 then
				local _, v24, _ = CFrame.lookAt(v22.PrimaryPart.Position, v19.CFrame.Position):ToOrientation()
				local X4 = v19.CFrame.Position.X
				local Y4 = v19.CFrame.Position.Y
				local Z4 = v19.CFrame.Position.Z
				local cFrame4 = v22.PrimaryPart.CFrame
				local v25 = CFrame.new(X4, Y4, Z4) * CFrame.fromOrientation(0, v24, 0)
				total2 += dt
				local v26 = total2 / 0.5
				local value = TweenService:GetValue(math.min(total2 / 0.5, 1), quad2, out2)
				local lerped = cFrame4.Position:Lerp(v25.Position, value)
				local lerped2 = cFrame4.Rotation:Lerp(v25.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v26 >= 1 then
					v20 = true
					heartbeatConnection2:Disconnect()
				end
			else
				total2 += dt
				local v24 = total2 / v23
				local value = TweenService:GetValue(math.min(total2 / v23, 1), quad2, out2)
				local lerped = cFrame3.Position:Lerp(v19.Position, value)
				local lerped2 = cFrame3.Rotation:Lerp(v19.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v24 >= 1 then
					v20 = true
					heartbeatConnection2:Disconnect()
				end
			end
		else
			v20 = true
			heartbeatConnection2:Disconnect()
		end
	end)
	local _, _ = pcall(function()
		if game.Players:GetPlayerFromCharacter(instance2) then
			position = instance2.PrimaryPart.Position
		end
	end)

	if position ~= nil and instance2.Parent ~= nil then
		local stats = instance2:WaitForChild("Stats", 3)

		if not stats then
			return nil
		end

		local v24 = math.clamp(1 - (stats.Stealth.Value * stats.StealthModifier.Value / 5 * 0.075 - 0.15), 0.85, 1.15)
		local v25 = GigiMonster.VisionRadius * v24

		if canseetarget(instance, instance2, position, v25) and instance2 and instance2.Parent ~= nil and humanoidRootPart2 and humanoidRootPart2.Parent ~= nil then
			local humanoid3 = instance2:WaitForChild("Humanoid", 3)

			if humanoid3 and humanoid3.Health > 0 and not instance2:FindFirstChild("Invincible") then
				local trinkets = instance2:WaitForChild("Trinkets", 3)
				local trinket1 = trinkets and trinkets:WaitForChild("Trinket1", 3)
				local trinket2 = trinkets and trinkets:WaitForChild("Trinket2", 3)

				if not (trinket1 and trinket2) then
					return nil
				end

				local flag = true

				local function checkArmor(instance4)
					if not instance4 or instance4.Value ~= "CardboardArmor" then
						return
					end

					local active = instance4:FindFirstChild("Active")

					if active and active.Value == true then
						active.Value = false
						flag = false
						local success2, cardboardArmor = pcall(require, ReplicatedStorage.TrinketData.CardboardArmor)

						if success2 and cardboardArmor and cardboardArmor.SpecialEvent then
							cardboardArmor.SpecialEvent(instance2)
						end
					end
				end

				checkArmor(trinket1)

				if flag then
					checkArmor(trinket2)
				end

				if flag and humanoid3.Health > 0 then
					return (commitSteal(instance, instance2, humanoidRootPart))
				end
			end
		end
	end

	return v
end

return GigiMonster