local GoobMonster = {
	Name = "Twisted Goob",
	Rarity = "Rare",
	Icon = "rbxassetid://17268662964",
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 8,
	RunSpeed = 16,
	InterestTime = 3,
	HearingRadius = 100,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.5,
	HitCooldown = 2.5,
	ChaseAbility = true,
	AbilityCooldown = 12,
	AbilityLineOfSight = true,
	Ranged = true,
	UseBehaviorTree = true
}
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

function GoobMonster.UseChaseAbility(instance, instance2, instance3)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:WaitForChild("HumanoidRootPart")
	local humanoid = instance:WaitForChild("Humanoid")
	local humanoid2 = instance2:WaitForChild("Humanoid")
	local decoding = instance2:WaitForChild("Decoding")
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

		ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Windup")
		local ServerScriptService = game:GetService("ServerScriptService")
		local RangedTwistedManager = require(ServerScriptService.MonsterAI.Modules.RangedTwistedManager)
		local v3 = RangedTwistedManager.playWindupSound(humanoidRootPart, RangedTwistedManager.getGoobWindupSoundId())
		RangedTwistedManager.showRangedIndicator(humanoidRootPart, instance2)
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local _, v4, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
		local X = instance.PrimaryPart.Position.X
		local Y = instance.PrimaryPart.Position.Y
		local Z = instance.PrimaryPart.Position.Z
		local cFrame = instance.PrimaryPart.CFrame
		local v5 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v4, 0)

		if (instance2.PrimaryPart.Position - (instance.PrimaryPart.Position - vector)).Unit:Dot(instance.PrimaryPart.CFrame.LookVector) < 0.6 then
			local quad = Enum.EasingStyle.Quad
			local out = Enum.EasingDirection.Out
			local heartbeatConnection = nil
			local total = 0
			local v6 = false
			local v7 = nil
			local v8 = nil
			local v9 = 0.4
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if instance and cFrame and v5 then
					if v7 == true and v8 then
						local _, v10, _ = CFrame.lookAt(v8.PrimaryPart.Position, v5.CFrame.Position):ToOrientation()
						local X2 = v5.CFrame.Position.X
						local Y2 = v5.CFrame.Position.Y
						local Z2 = v5.CFrame.Position.Z
						local cFrame2 = v8.PrimaryPart.CFrame
						local v11 = CFrame.new(X2, Y2, Z2) * CFrame.fromOrientation(0, v10, 0)
						total += dt
						local v12 = total / 0.5
						local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
						local lerped = cFrame2.Position:Lerp(v11.Position, value)
						local lerped2 = cFrame2.Rotation:Lerp(v11.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v12 >= 1 then
							v6 = true
							heartbeatConnection:Disconnect()
						end
					else
						total += dt
						local v10 = total / v9
						local value = TweenService:GetValue(math.min(total / v9, 1), quad, out)
						local lerped = cFrame.Position:Lerp(v5.Position, value)
						local lerped2 = cFrame.Rotation:Lerp(v5.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v10 >= 1 then
							v6 = true
							heartbeatConnection:Disconnect()
						end
					end
				else
					v6 = true
					heartbeatConnection:Disconnect()
				end
			end)
		end

		task.wait(0.75)
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
				local v6 = instance
				local success2, result2 = pcall(function()
					local ServerScriptService3 = game:GetService("ServerScriptService")
					local MonsterAI = require(ServerScriptService3:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))

					for _, v7 in ipairs(MonsterAI.getActiveInstances()) do
						if v7.chaser == v6 then
							return v7
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
			if v3 and v3.Parent then
				v3:Stop()
				v3:Destroy()
			end

			task.spawn(function()
				RangedTwistedManager.playTargetingCue(humanoidRootPart)
			end)
			grabbing.Value = true
			local _, v6, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
			local X2 = instance.PrimaryPart.Position.X
			local Y2 = instance.PrimaryPart.Position.Y
			local Z2 = instance.PrimaryPart.Position.Z
			local cFrame2 = instance.PrimaryPart.CFrame
			local v7 = CFrame.new(X2, Y2, Z2) * CFrame.fromOrientation(0, v6, 0)
			local quad = Enum.EasingStyle.Quad
			local out = Enum.EasingDirection.Out
			local heartbeatConnection = nil
			local total = 0
			local v8 = false
			local v9 = nil
			local v10 = nil
			local v11 = 0.4
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if instance and cFrame2 and v7 then
					if v9 == true and v10 then
						local _, v12, _ = CFrame.lookAt(v10.PrimaryPart.Position, v7.CFrame.Position):ToOrientation()
						local X3 = v7.CFrame.Position.X
						local Y3 = v7.CFrame.Position.Y
						local Z3 = v7.CFrame.Position.Z
						local cFrame3 = v10.PrimaryPart.CFrame
						local v13 = CFrame.new(X3, Y3, Z3) * CFrame.fromOrientation(0, v12, 0)
						total += dt
						local v14 = total / 0.5
						local value = TweenService:GetValue(math.min(total / 0.5, 1), quad, out)
						local lerped = cFrame3.Position:Lerp(v13.Position, value)
						local lerped2 = cFrame3.Rotation:Lerp(v13.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v14 >= 1 then
							v8 = true
							heartbeatConnection:Disconnect()
						end
					else
						total += dt
						local v12 = total / v11
						local value = TweenService:GetValue(math.min(total / v11, 1), quad, out)
						local lerped = cFrame2.Position:Lerp(v7.Position, value)
						local lerped2 = cFrame2.Rotation:Lerp(v7.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v12 >= 1 then
							v8 = true
							heartbeatConnection:Disconnect()
						end
					end
				else
					v8 = true
					heartbeatConnection:Disconnect()
				end
			end)
			task.spawn(function()
				if instance and instance.Parent ~= nil then
					local goobGrab = ReplicatedStorage.Parts.RenderModules.GoobGrab
					ReplicatedStorage.Events.RenderObject:FireAllClients(goobGrab, { instance, instance2 })
				end
			end)
			task.wait(0.5)
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule"):Fire(
				game.Players:GetPlayerFromCharacter(instance2),
				true,
				nil,
				5
			)
			task.wait()

			if not (instance.Parent and instance.PrimaryPart and instance2.Parent and instance2.PrimaryPart) then
				return
			end

			local _, v12, _ = CFrame.lookAt(instance.PrimaryPart.Position, instance2.PrimaryPart.Position):ToOrientation()
			local X3 = instance.PrimaryPart.Position.X
			local Y3 = instance.PrimaryPart.Position.Y
			local Z3 = instance.PrimaryPart.Position.Z
			local cFrame3 = instance.PrimaryPart.CFrame
			local v13 = CFrame.new(X3, Y3, Z3) * CFrame.fromOrientation(0, v12, 0)
			local quad2 = Enum.EasingStyle.Quad
			local out2 = Enum.EasingDirection.Out
			local heartbeatConnection2 = nil
			local total2 = 0
			local v14 = false
			local v15 = nil
			local v16 = nil
			local v17 = 0.4
			heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
				if instance and cFrame3 and v13 then
					if v15 == true and v16 then
						local _, v18, _ = CFrame.lookAt(v16.PrimaryPart.Position, v13.CFrame.Position):ToOrientation()
						local X4 = v13.CFrame.Position.X
						local Y4 = v13.CFrame.Position.Y
						local Z4 = v13.CFrame.Position.Z
						local cFrame4 = v16.PrimaryPart.CFrame
						local v19 = CFrame.new(X4, Y4, Z4) * CFrame.fromOrientation(0, v18, 0)
						total2 += dt
						local v20 = total2 / 0.5
						local value = TweenService:GetValue(math.min(total2 / 0.5, 1), quad2, out2)
						local lerped = cFrame4.Position:Lerp(v19.Position, value)
						local lerped2 = cFrame4.Rotation:Lerp(v19.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v20 >= 1 then
							v14 = true
							heartbeatConnection2:Disconnect()
						end
					else
						total2 += dt
						local v18 = total2 / v17
						local value = TweenService:GetValue(math.min(total2 / v17, 1), quad2, out2)
						local lerped = cFrame3.Position:Lerp(v13.Position, value)
						local lerped2 = cFrame3.Rotation:Lerp(v13.Rotation, value)
						instance:PivotTo(CFrame.new(lerped) * lerped2)

						if v18 >= 1 then
							v14 = true
							heartbeatConnection2:Disconnect()
						end
					end
				else
					v14 = true
					heartbeatConnection2:Disconnect()
				end
			end)
			local _, _ = pcall(function()
				if game.Players:GetPlayerFromCharacter(instance2) then
					position = instance2.PrimaryPart.Position
				end
			end)

			if position ~= nil then
				local stats = instance2:WaitForChild("Stats")
				local v18 = math.clamp(
					1 - (stats.Stealth.Value * stats.StealthModifier.Value / 5 * 0.075 - 0.15),
					0.85,
					1.15
				)
				local v19 = GoobMonster.VisionRadius * v18

				if canseetarget(instance, instance2, position, v19) and instance2 and instance2.Parent ~= nil and humanoidRootPart2 and humanoidRootPart2.Parent ~= nil then
					local v20 = false
					local trinkets = instance2:FindFirstChild("Trinkets")

					if trinkets then
						local trinket1 = trinkets:FindFirstChild("Trinket1")
						local trinket2 = trinkets:FindFirstChild("Trinket2")

						local function checkArmor(instance4)
							if not instance4 or instance4.Value ~= "CardboardArmor" then
								return
							end

							local active = instance4:FindFirstChild("Active")

							if active and active.Value == true then
								active.Value = false
								v20 = true
								local success2, cardboardArmor = pcall(
									require,
									ReplicatedStorage.TrinketData.CardboardArmor
								)

								if success2 and cardboardArmor and cardboardArmor.SpecialEvent then
									cardboardArmor.SpecialEvent(instance2)
								end
							end
						end

						checkArmor(trinket1)

						if not v20 then
							checkArmor(trinket2)
						end
					end

					if not v20 then
						local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

						if decoding and decoding.Parent ~= nil and decoding.Value ~= nil and playerFromCharacter then
							decoding.Value:WaitForChild("Stats"):WaitForChild("ForceStop"):Fire(playerFromCharacter)
							ReplicatedStorage.Events.StopInteracting:FireClient(playerFromCharacter)
						end

						local v21 = instance.PrimaryPart.CFrame * CFrame.new(0, 0, -0.5)

						if humanoidRootPart2 and humanoidRootPart2.Parent ~= nil and game.Players:GetPlayerFromCharacter(humanoidRootPart2.Parent) then
							local clone = game.ServerStorage.Scripts.OwnerSetter:Clone()
							clone.Parent = humanoidRootPart2

							if game.Players:GetPlayerFromCharacter(humanoidRootPart2.Parent) then
								clone.PlayerValue.Value = game.Players:GetPlayerFromCharacter(humanoidRootPart2.Parent)
							end

							clone.Duration.Value = 0.5
							clone.Disabled = false
						end

						local tween = TweenService:Create(humanoidRootPart2, tweenInfo, {
							CFrame = v21 * CFrame.Angles(0, 3.141592653589793, 0)
						})
						tween:Play()
						tween.Completed:Wait()
					end
				end
			end
		end
	end
end

GoobMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "rbxassetid://86631772760336",
		NormalTexture = "rbxassetid://136101980168617",
		AttackTexture = "rbxassetid://73526649717051"
	}
}

function GoobMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, GoobMonster.SpecialAnimatorData.Config)
end

return GoobMonster