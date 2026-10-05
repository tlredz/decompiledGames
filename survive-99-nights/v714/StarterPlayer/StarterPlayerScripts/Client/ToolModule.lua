local createVector = vector.create
local ToolModule = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("Debris")
game:GetService("TweenService")
game:GetService("RunService")
local random = Random.new()
TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local hasLineOfSight = Client.CollisionUtility.HasLineOfSight
Client.Events.KnockbackPlayer:Connect(function(p, p2, p3)
	if p3 then
		local v = p3 - workspace:GetServerTimeNow()

		if v > 0 then
			task.wait(v)
		end
	end

	ApplyKnockback(p, p2)
end)
Client.Events.PlayerHitByEnemy:Connect(function(p, p2, p3)
	if p == localPlayer then
		ApplyKnockback(p2, p3)
	end
end)

function ApplyKnockback(instance, p)
	print("apply knockback", instance, p)
	local humanoidRootPart

	if type(instance) == "userdata" then
		if instance:IsA("BasePart") then
			humanoidRootPart = instance
		elseif instance:IsA("Player") then
			humanoidRootPart = instance.Character.HumanoidRootPart
		else
			humanoidRootPart = instance.PrimaryPart
		end
	end

	local humanoidRootPart2 = localPlayer.Character.HumanoidRootPart
	local humanoid = localPlayer.Character.Humanoid
	local assemblyMass = humanoidRootPart2.AssemblyMass

	if humanoid:GetState() ~= Enum.HumanoidStateType.Running then
		return
	end

	local v = assemblyMass * (p.Vertical or 0)
	local v2 = assemblyMass * (p.Horizontal or 0)
	local unit

	if humanoidRootPart then
		unit = ((humanoidRootPart2.Position - humanoidRootPart.Position) * createVector(1, 0, 1)).Unit

		if instance.Name == "Ram" then
			local lookVector = humanoidRootPart.CFrame.LookVector
			local _, v3 = Client.Utility.GetAngleBetweenVectors(lookVector, unit)
			unit = ((humanoidRootPart.CFrame * CFrame.Angles(0, 0.7853981633974483 * v3, 0)).LookVector * createVector(
				1,
				0,
				1
			)).Unit
		end
	else
		unit = ((humanoidRootPart2.Position - instance) * createVector(1, 0, 1)).Unit
	end

	local v3 = unit * v2 + Vector3.new(0, v, 0)
	humanoid:ChangeState(Enum.HumanoidStateType.Flying)

	for _, part in pairs(localPlayer.Character:GetChildren()) do
		if part:IsA("BasePart") then
			part.Velocity = createVector(0, 0, 0)
		end
	end

	humanoidRootPart2.AssemblyLinearVelocity = Vector3.new()
	humanoidRootPart2:ApplyImpulse(v3)
end

ToolModule.ApplyKnockback = ApplyKnockback

function ToolModule.PlayToolSound(p, clone, object, playbackSpeed, p2)
	Client.Events.PlayToolSound:FireOtherClients(p.RealModel, clone.Name, nil, playbackSpeed, p2)

	if playbackSpeed then
		clone.PlaybackSpeed = playbackSpeed
	end

	if p2 then
		local v = clone
		clone = v:Clone()
		clone.Parent = v.Parent
	end

	clone:Play()

	if object then
		object:Stop()
	end

	if p2 then
		task.spawn(function()
			wait(clone.TimeLength + 0.2)
			clone:Destroy()
		end)
	end
end

Client.Events.PlayToolSound:Connect(function(player, p, childName, childName2, playbackSpeed, p2)
	local toolHandle = player.Character:FindFirstChild("ToolHandle")

	if toolHandle and toolHandle.OriginalItem.Value == p then
		local child = toolHandle.PrimaryPart:FindFirstChild(childName)

		if p2 then
			local clone = child:Clone()
			clone.Parent = child.Parent
			child = clone
		end

		if child then
			if playbackSpeed then
				child.PlaybackSpeed = playbackSpeed
			end

			child:Play()
		end

		local child2 = childName2 and toolHandle.PrimaryPart:FindFirstChild(childName2)

		if child2 then
			child2:Play()
		end

		if p2 then
			wait(child.TimeLength + 0.2)
			child:Destroy()
		end
	end
end)

function ToolModule.GetModelFromPart(p, options, p2, instance, p3)
	local v = options or {}

	if p.Parent:GetAttribute("NotAttackable") then
		return nil
	end

	if p.Parent:GetAttribute("Resource") and p.Parent:GetAttribute("AllowTool_" .. p2) then
		local parent = p.Parent
		local toolTier = parent:GetAttribute("ToolTier")
		local axeLevel = instance:GetAttribute("AxeLevel")
		local v2

		if toolTier then
			if axeLevel then
				v2 = axeLevel >= 3
			else
				v2 = toolTier <= (instance:GetAttribute("ToolTier") or 1)
			end
		else
			v2 = true
		end

		if v2 and v[parent] == nil and parent:GetAttribute("Destroyed") == nil and hasLineOfSight(parent) then
			return parent, {
				Type = "Resource"
			}
		end
	elseif p.Parent:FindFirstChild("NPC") and p.Parent:HasTag("NPC") then
		local parent = p.Parent

		if v[parent] == nil and parent:GetAttribute("Dead") == nil and (parent.Name == "Chick" or parent:GetAttribute("Tamed") == nil) and (hasLineOfSight(parent) or p2 == "Arrow") then
			return parent, {
				Type = "NPC"
			}
		end
	elseif p.Parent:HasTag("WebBall") then
		local parent = p.Parent

		if instance.Name == "Happy's Scythe" then
			if v[parent] == nil then
				return parent, {
					Type = "Object"
				}
			end
		else
			Client.PopUpUI.AddPopUp("You need a special Scythe to clear this", "halloween")
		end
	elseif p.Parent:GetAttribute("AttackableObject") then
		local parent = p.Parent

		if v[parent] == nil then
			return parent, {
				Type = "Object"
			}
		end
	elseif p.Parent:FindFirstChild("Humanoid") then
		if not p3 then
			return nil
		end

		local parent = p.Parent
		local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter and playerFromCharacter ~= localPlayer and (instance:GetAttribute("PVP") or Client.PVPZoneClient.IsInPVPZone(localPlayer) and Client.PVPZoneClient.IsInPVPZone(parent)) and v[parent] == nil and parent:GetAttribute("Dead") == nil and (hasLineOfSight(parent) or p2 == "Arrow") then
			return parent, {
				Type = "Player"
			}
		end
	end
end

function ToolModule.GetWeaponHits(p, p2, p3, p4, p5, p6)
	local partBoundsInBox = workspace:GetPartBoundsInBox(p, p2, Client.CollisionUtility.OverlapParams)
	local v = {}
	local result = {}

	for _, v2 in pairs(partBoundsInBox) do
		if v[v2.Parent] ~= nil then
			continue
		end

		v[v2.Parent] = true
		local model, v3 = ToolModule.GetModelFromPart(v2, p3, p4, p5, p6)

		if model then
			result[model] = v3
		end
	end

	return result
end

function ToolModule.BoxCast(p, p2, options, callback, instance, p3)
	local v = options or {}
	local toolName = instance:GetAttribute("ToolName")
	local weaponHits = ToolModule.GetWeaponHits(p, p2, v, toolName, instance, p3)
	local v2 = false

	for k, weaponHit in pairs(weaponHits) do
		v[k] = true
		local v3 = k
		local v4 = weaponHit
		task.spawn(function()
			callback(v3, v4)
		end)
		v2 = true
	end

	return v2
end

function PlayEnemyHitSound(_, instance, instance2, p)
	local v = p or instance2:GetAttribute("WeaponMaterial")

	if v then
		local primaryPart = instance.PrimaryPart
		local v2 = primaryPart and (primaryPart:FindFirstChild(v .. "Hit") or primaryPart:FindFirstChild("GenericHit"))

		if v2 then
			v2.PlaybackSpeed = 0.9 + random:NextNumber() * 0.2
			v2:Play()
		end

		task.delay(0.05, function()
			if instance.Parent == nil or instance.PrimaryPart == nil then
				return
			end

			local lateGenericHit = instance.PrimaryPart:FindFirstChild("LateGenericHit")

			if lateGenericHit then
				lateGenericHit.PlaybackSpeed = 0.9 + random:NextNumber() * 0.2
				lateGenericHit:Play()
			end
		end)
	end
end

Client.Events.PlayEnemyHitSound:Connect(PlayEnemyHitSound)

function AnimateGong(instance, instance2)
	if not instance2 then
		return
	end

	print("GONG")
	instance.PrimaryPart.GongSound:Play()
	local middle = instance.Functional.Middle

	if middle:GetAttribute("Origin") == nil then
		middle:SetAttribute("Origin", middle:GetPivot())
	end

	local origin = middle:GetAttribute("Origin")
	local v = origin * CFrame.Angles(-0.2617993877991494, 0, 0)
	local position = instance2:GetPivot().Position
	local unit = ((middle:GetPivot().Position - position) * createVector(1, 0, 1)).Unit
	local angleBetweenVectors, _ = Client.Utility.GetAngleBetweenVectors(unit, origin.LookVector)

	if math.deg(angleBetweenVectors) <= 90 then
		v = origin * CFrame.Angles(0.2617993877991494, 0, 0)
	end

	Client.TweenModule.new(function(p)
		middle:PivotTo((origin:Lerp(v, p)))
	end, 0.8, "ReturnBounce", "Out"):Play()
end

Client.Events.AnimateGong:Connect(AnimateGong)

function AnimatePunchingBag(p, instance)
	if not instance then
		return
	end

	local bag = p.Bag

	if bag:GetAttribute("Origin") == nil then
		bag:SetAttribute("Origin", bag:GetPivot())
	end

	local position = instance:GetPivot().Position
	local unit = ((bag:GetPivot().Position - position) * createVector(1, 0, 1)).Unit
	local origin = bag:GetAttribute("Origin")
	local cframe = CFrame.new(origin.p, origin.p + unit * createVector(1, 0, 1))
	local objectSpace = cframe:ToObjectSpace(origin)
	local v = cframe * CFrame.Angles(-0.2617993877991494, 0, 0) * objectSpace
	Client.TweenModule.new(function(p2)
		bag:PivotTo((origin:Lerp(v, p2)))
	end, 0.8, "ReturnBounce", "Out"):Play()
end

Client.Events.AnimatePunchingBag:Connect(AnimatePunchingBag)

function ToolModule.AddEnemyHitParticles(parent)
	if game.Players:GetPlayerFromCharacter(parent) then
		return
	end

	if parent:FindFirstChild("HitParticles") then
		parent.HitParticles:Destroy()
	end

	if parent.Name == "Chick" then
		Client.Utility.SpawnParticles("ChickHit", parent:GetPivot())
	end

	local folder = Instance.new("Folder")
	folder.Name = "HitParticles"
	folder.Parent = parent

	if parent:GetAttribute("Resource") or parent:HasTag("WebBall") then
		local originalCF = parent:GetAttribute("OriginalCF")

		if originalCF == nil then
			originalCF = parent:GetPivot()
			parent:SetAttribute("OriginalCF", originalCF)
		end

		local _ = originalCF - createVector(0, 0.4, 0)
		Client.TweenModule.new(function(p)
			if folder.Parent == nil then
				return
			end

			parent:PivotTo(originalCF - Vector3.new(0, 0.4 * p, 0))
		end, 0.2, "ReturnBounce"):Play()
	end

	if parent:GetAttribute("SnowfallHeight") then
		local snowfallHeight = parent:GetAttribute("SnowfallHeight")
		local v = parent:GetPivot() + Vector3.new(0, snowfallHeight, 0)
		Client.Utility.SpawnParticles("SnowFall", v)
	end

	if parent:GetAttribute("AttackableObject") and parent.Name == "Punching Bag" then
		AnimatePunchingBag(parent, localPlayer.Character)
	elseif parent:GetAttribute("AttackableObject") and parent.Name == "Gong" then
		AnimateGong(parent, localPlayer.Character)
	end
end

Client.Events.AddEnemyHitParticles:Connect(function(...)
	ToolModule.AddEnemyHitParticles(...)
end)

function ToolModule.Init() end

return ToolModule