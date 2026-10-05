local createVector = vector.create
local EnemyHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3)
Random.new()
local v = 1
local itemLinks = {}
EnemyHandler.ItemLinks = itemLinks
local random = Random.new()

function FireEnemyProjectile(p, p2, p3)
	p3.ProjectileParams = Client.CollisionUtility.EnemyProjectileParams
	local v3 = p2 * (p3.Speed or 20)
	local projectileClass = Client.ProjectileClass.new(p3, p, v3)
	projectileClass.NPCBullet = true
	projectileClass:Fire()
end

Client.Events.FireEnemyProjectile:Connect(FireEnemyProjectile)

function GetOwlSpawnPosition(_)
	print("owl spawn position")
	local cframe = CFrame.new(Client.PlayerHandler.HumanoidRootPart.Position)
	local position = cframe.Position
	local humanoid = Client.PlayerHandler.Humanoid
	local v3 = {}
	local v4 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkAdd(p)
		local raycastResult = workspace:Raycast(
			p + createVector(0, 50, 0),
			createVector(0, -80, 0),
			Client.CollisionUtility.DefaultParams
		)

		if raycastResult then
			local position2 = raycastResult.Position
			local _, v5 = workspace.CurrentCamera:WorldToScreenPoint(position2)

			if v5 then
				table.insert(v3, position2 - position)
			else
				table.insert(v4, position2 - position)
			end
		end
	end

	if humanoid and humanoid.MoveDirection.Magnitude > 0.2 then
		local v5 = humanoid.WalkSpeed * 5
		local v6 = position + humanoid.MoveDirection * v5
		local cframe2 = CFrame.lookAt(position, v6)
		checkAdd(v6) -- equivalent call inferred; original call site unknown

		for i = -30, 30, 15 do
			checkAdd((cframe2 * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, -v5)).Position) -- equivalent call inferred; original call site unknown
		end
	else
		for i = 0, 359, 45 do
			checkAdd((cframe * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, 30)).Position) -- equivalent call inferred; original call site unknown
		end
	end

	print(v3, v4)

	if #v3 > 0 and #v4 > 0 then
		return v3, v4
	end

	if #v3 > 0 then
		return v3
	end

	if #v4 > 0 then
		return v4
	end

	return nil
end

function GetDeerSpawnPosition(value)
	local v3 = {}
	local v4 = {}
	local cframe = CFrame.new(Client.PlayerHandler.HumanoidRootPart.Position)
	local position = cframe.Position

	local function checkAdd(position2)
		local raycastResult = workspace:Raycast(
			position2 + createVector(0, 10, 0),
			createVector(0, -20, 0),
			Client.CollisionUtility.DefaultParams
		)

		if raycastResult then
			local position3 = raycastResult.Position
			local _, v5 = workspace.CurrentCamera:WorldToScreenPoint(position3)

			if not v5 then
				if Client.CollisionUtility.HasLineOfSight(position, position3) then
					table.insert(v3, position3 - position)
				else
					table.insert(v4, position3 - position)
				end
			end
		end
	end

	for i = 0, 359, 45 do
		checkAdd((cframe * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, value or 30)).Position)
	end

	if #v3 > 0 and #v4 > 0 then
		return v3, v4
	end

	if #v3 > 0 then
		return v3
	end

	if #v4 > 0 then
		return v4
	end

	return nil
end

Client.Events.GetOffscreenData:OnClientInvoke(function(p, p2)
	if p2 == "Owl" then
		return GetOwlSpawnPosition(p)
	end

	return GetDeerSpawnPosition(p)
end)
Client.Events.EnemyAggroToPlayer:Connect(function(instance)
	if instance:GetAttribute("AggroDebounce") then
		return
	end

	instance:SetAttribute("AggroDebounce", true)
	task.delay(1, function()
		instance:SetAttribute("AggroDebounce", nil)
	end)

	if instance.HumanoidRootPart:FindFirstChild("Alert") then
		instance.HumanoidRootPart.Alert:Play()
	end

	if instance:FindFirstChild("AggroMarker") then
		instance.AggroMarker.Enabled = true
		task.delay(2, function()
			if instance:FindFirstChild("AggroMarker") then
				instance.AggroMarker.Enabled = false
			end
		end)
	end
end)

function SpawnIceParticles(instance)
	for _ = 1, 10 do
		local clone = instance:Clone()
		task.spawn(function()
			task.wait(random:NextNumber(4, 7))
			clone:Destroy()
		end)
		clone:ScaleTo(0.08 + random:NextNumber() * 0.12)

		for _, part in pairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.Transparency ~= 1 then
					part.CollisionGroup = "Particles"
					part.CanCollide = true
					part.Anchored = false
				end
			else
				part:Destroy()
			end
		end

		for k, _ in pairs(clone:GetAttributes()) do
			clone:SetAttribute(k, nil)
		end

		local pivot = instance:GetPivot()
		local v4 = (random:NextNumber() - 0.5) * 2
		local v5 = (random:NextNumber() - 0.5) * 2
		local v6 = (random:NextNumber() - 0.5) * 2
		local v7 = pivot * CFrame.new(v4, v5, v6) * CFrame.Angles(
			random:NextNumber() * 3.141592653589793 * 2,
			random:NextNumber() * 3.141592653589793 * 2,
			random:NextNumber() * 3.141592653589793 * 2
		)
		clone:PivotTo(v7)
		local _ = (v7.Position - pivot.Position).Unit * 80 * clone.PrimaryPart.AssemblyMass
		clone.Parent = workspace.Particles
	end

	instance.Parent = game.ReplicatedStorage
end

Client.Events.DestroyObject:Connect(function(instance, deathOrigin, p, p2)
	if instance:GetAttribute("LocalDestroyed") or instance.Parent == nil then
		return
	end

	instance:SetAttribute("LocalDestroyed", true)

	if p then
		local v3 = p - workspace:GetServerTimeNow()

		if v3 > 0 then
			task.wait(v3)
		end
	end

	local destroySound = not p2 and instance:GetAttribute("DestroySound")

	if destroySound then
		Client.Sound.Play(destroySound, {
			Position = instance:GetPivot().Position
		})
	end

	if instance:GetAttribute("Resource") == "IceBlock" then
		task.spawn(function()
			SpawnIceParticles(instance)
		end)
		return
	end

	local child = game.ReplicatedStorage.Assets.DeathModels:FindFirstChild(instance.Name)

	if child then
		local clone = child:Clone()
		task.delay(5, function()
			clone:Destroy()
		end)
		clone:ScaleTo(instance:GetScale())
		clone:PivotTo(instance:GetAttribute("OriginalCF") or instance:GetPivot())
		local _ = clone:GetPivot().Position
		clone.PrimaryPart:Destroy()

		for _, child2 in pairs(instance:GetChildren()) do
			if child2 ~= instance.PrimaryPart then
				child2:Destroy()
			end
		end

		instance.Parent = game.ReplicatedStorage
		task.delay(3, function()
			instance:Destroy()
		end)

		if deathOrigin then
			clone:SetAttribute("DeathOrigin", deathOrigin)
		end

		clone.Parent = workspace

		if not p2 then
			Client.Sound.Play("TreeFinal", {
				Volume = 0.25,
				Position = deathOrigin.Position
			})
		end

		if clone:FindFirstChild("Animation") then
			clone.Animation.Enabled = true
		end
	else
		instance.Parent = game.ReplicatedStorage
	end
end)
Client.Events.PlayDeathAnimation:Connect(function(instance)
	if not instance then
		return
	end

	local child = game.ReplicatedStorage.Assets.DeathModels:FindFirstChild(instance.Name)

	if not child then
		instance:Destroy()
		return
	end

	local clone = child:Clone()
	task.delay(5, function()
		clone:Destroy()
	end)
	clone:PivotTo(instance:GetPivot())
	local position = clone.PrimaryPart.Position
	clone.PrimaryPart:Destroy()

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local child2 = instance:FindFirstChild(part.Name)

		if child2 then
			part.CFrame = child2.CFrame
		end
	end

	local assemblyLinearVelocity = instance.PrimaryPart.AssemblyLinearVelocity
	local explodeVelocity = clone:GetAttribute("ExplodeVelocity")

	for _, child2 in pairs(instance:GetChildren()) do
		if not child2:GetAttribute("EquippableLoot") then
			continue
		end

		local clone2 = child2:Clone()
		itemLinks[child2] = clone2
		clone2:SetAttribute("FakeItem", true)

		for _, part in pairs(clone2:GetChildren()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end

		clone2.Parent = workspace.Items
		local v3 = child2
		task.delay(5, function()
			itemLinks[v3] = nil
			clone2:Destroy()
		end)
	end

	for _, child2 in pairs(instance:GetChildren()) do
		if child2 ~= instance.PrimaryPart then
			child2:Destroy()
		end
	end

	instance.Parent = game.ReplicatedStorage
	task.delay(3, function()
		instance:Destroy()
	end)
	clone.Parent = workspace
	clone:BreakJoints()

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		if explodeVelocity then
			part.Velocity = assemblyLinearVelocity + (part.Position - position).Unit * explodeVelocity + Vector3.new(
				0,
				explodeVelocity * 2,
				0
			)
			part.RotVelocity = Vector3.new(random:NextNumber(), random:NextNumber(), random:NextNumber()) * explodeVelocity
		else
			part.Velocity = assemblyLinearVelocity
		end
	end
end)

function EnemyHandler.GetHitRegId()
	local v3 = v .. "_" .. math.abs(localPlayer.UserId)
	v += 1
	return v3
end

function UpdateIceBlockVisualModel(instance)
	local hitRegisters = instance:WaitForChild("HitRegisters")
	local v3 = math.clamp(
		(instance:GetAttribute("Health") - EnemyHandler.GetLocalHealthRegistered(hitRegisters)) / (instance:GetAttribute("MaxHealth") or instance:GetAttribute("Health")),
		0,
		1
	)
	local v4 = v3 == 1 and 1 or v3 < 0.5 and 3 or 2
	local child = instance:FindFirstChild("Block" .. 1)

	if child then
		if v4 == 1 then
			child.Transparency = 0.5
		else
			child.Transparency = 1
		end
	end

	local child2 = instance:FindFirstChild("Block" .. 2)

	if child2 then
		if v4 == 2 then
			child2.Transparency = 0.5
		else
			child2.Transparency = 1
		end
	end

	local child3 = instance:FindFirstChild("Block" .. 3)

	if child3 then
		if v4 == 3 then
			child3.Transparency = 0.5
		else
			child3.Transparency = 1
		end
	end
end

function EnemyHandler.ApplyLocalDamage(instance, p, p2)
	if instance:GetAttribute("NotDamageable") then
		return
	end

	if not p2 then
		p2 = v .. "_" .. math.abs(localPlayer.UserId)
		v += 1
	end

	local totalArmour = Client.CombatUtility.GetTotalArmour(instance)
	local v3 = Client.CombatUtility.ApplyArmourToDamage(p, totalArmour)
	local hitRegisters = instance:FindFirstChild("HitRegisters")
	local v4

	if hitRegisters then
		v4 = "Local_" .. p2
		hitRegisters:SetAttribute(v4, v3)
	else
		v4 = nil
	end

	local function undoLocalDamage()
		if v4 then
			hitRegisters:SetAttribute(v4, nil)
		end

		UpdateHealthBar(instance)
	end

	UpdateHealthBar(instance)

	if instance:GetAttribute("Resource") == "IceBlock" then
		UpdateIceBlockVisualModel(instance)
	end

	return p2, undoLocalDamage
end

function MakeFadingHealthChunk(instance, p)
	local healthBar = instance:WaitForChild("HealthBar")
	local clone = healthBar.HealthBar.Bar:Clone()
	clone.Size = UDim2.new(p, 0, 1, 0)
	clone.Name = "FadeChunk"
	clone.Parent = healthBar.HealthBar
	TweenService:Create(clone, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	task.delay(1, function()
		clone:Destroy()
	end)
end

function EnemyHandler.GetLocalHealthRegistered(instance)
	local total = 0

	for k, v3 in pairs(instance:GetAttributes()) do
		if k:sub(1, 6) ~= "Local_" then
			continue
		end

		if instance:GetAttribute((k:sub(7))) == nil then
			total += v3
		else
			instance:SetAttribute(k, nil)
		end
	end

	return total
end

function UpdateHealthBar(instance)
	local healthBar = instance:FindFirstChild("HealthBar")

	if healthBar == nil then
		return
	end

	local NPC = instance:WaitForChild("NPC")
	local hitRegisters = instance:WaitForChild("HitRegisters")
	local v3 = NPC.Health - EnemyHandler.GetLocalHealthRegistered(hitRegisters)
	local v4 = NPC:GetAttribute("Dead") == true and 0 or v3
	local prevHealth = NPC:GetAttribute("PrevHealth")
	local v5 = v4 / NPC.MaxHealth

	if v5 <= 0 then
		healthBar.Enabled = false
	else
		if prevHealth then
			healthBar.Enabled = true
		end

		healthBar.HealthBar.Bar.Size = UDim2.new(v5, 0, 1, 0)
	end

	local dissolveThreshold = localPlayer:GetAttribute("DissolveThreshold")

	if dissolveThreshold then
		healthBar.HealthBar.DissolveThreshold.Size = UDim2.new(dissolveThreshold, 0, 1, 0)
		healthBar.HealthBar.DissolveThreshold.Visible = true

		if v5 <= dissolveThreshold then
			healthBar.HealthBar.Bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		else
			healthBar.HealthBar.Bar.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		end
	end

	NPC:SetAttribute("PrevHealth", v4)
	task.delay(10, function()
		if v4 <= NPC:GetAttribute("PrevHealth") then
			healthBar.Enabled = false
		end
	end)
end

function EnemyAdded(instance)
	instance:WaitForChild("NPC"):GetPropertyChangedSignal("Health"):Connect(function()
		UpdateHealthBar(instance)
	end)
	UpdateHealthBar(instance)
end

function EnemyRemoved(_) end

function EnemyHandler.Init()
	Client.Utility.ForAllTagged("NPC", EnemyAdded, EnemyRemoved)
end

return EnemyHandler