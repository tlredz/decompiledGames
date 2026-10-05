local createVector = vector.create
local ProjectileClass = {}
ProjectileClass.__index = ProjectileClass
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local random = Random.new()
local RunService = game:GetService("RunService")
local projectileId2 = 1

function ProjectileClass.new(firearm, p2, velocity, projectileId, headPos, items, p3, pVPParams)
	local object = setmetatable({}, ProjectileClass)
	object.Firearm = firearm
	object.Position = p2
	object.HeadPos = headPos
	object.Origin = p2
	object.Velocity = velocity
	object.Gravity = Vector3.new(0, -(firearm.ProjectileGravity or 196.2), 0)
	object.PVPParams = pVPParams

	if projectileId then
		object.ProjectileId = projectileId
	else
		object.ProjectileId = projectileId2
		projectileId2 += 1
	end

	if items then
		for k, item in pairs(items) do
			object[k] = item
		end
	end

	if object.IgnoreList then
		local pVPParams2 = object.PVPParams or object.Firearm.ProjectileParams or Client.CollisionUtility.ProjectileParams

		if pVPParams2 then
			for _, filterDescendantsInstance in pairs(pVPParams2.FilterDescendantsInstances) do
				table.insert(object.IgnoreList, filterDescendantsInstance)
			end

			object.ProjectileParams = RaycastParams.new()
			object.ProjectileParams.FilterType = Enum.RaycastFilterType.Exclude
			object.ProjectileParams.FilterDescendantsInstances = object.IgnoreList
		end
	end

	if object.Firearm.AttackBounces and object.AttackBounces == nil then
		object.AttackBounces = object.Firearm.AttackBounces
	end

	if not p3 then
		object:CreateModel()
	end

	return object
end

function ProjectileClass.GetProjectileId()
	local v2 = projectileId2
	projectileId2 += 1
	return v2
end

function ProjectileClass:BounceToNearestEnemy(raycastResult: RaycastResult, p2)
	local v2 = {
		[p2] = true
	}
	local nearestEnemy = Client.AimAssistClient.GetNearestEnemy(raycastResult.Position, v2)

	if nearestEnemy then
		local position = raycastResult.Position
		local unit = (nearestEnemy:GetPivot().Position - position).Unit
		local aimAssistDir = Client.AimAssistClient.GetAimAssistDir(position, unit)
		local v3 = (CFrame.lookAlong(position, aimAssistDir) * CFrame.Angles(0.17453292519943295, 0, 0)).LookVector * self.Firearm.ProjectileSpeed
		Client.ProjectileClass.new(self.Firearm, position, v3, self.ProjectileId, nil, {
			AttackBounces = self.AttackBounces - 1,
			IgnoreList = { p2 },
			SecondBounce = true
		}):Fire()
	end
end

function ProjectileClass:Hit(raycastResult: RaycastResult)
	local clone = self.Model:Clone()
	self:Destroy()
	local parent = raycastResult.Instance.Parent

	if parent:IsA("Accoutrement") then
		parent = parent.Parent
	end

	if parent:HasTag("WebBall") and not (self.Replica or self.NPCBullet) then
		Client.PopUpUI.AddPopUp("You need a special Scythe to clear this", "halloween")
	end

	if parent:FindFirstChild("NPC") and parent:HasTag("NPC") then
		Client.Sound.Play("BulletHitFlesh", {
			Position = raycastResult.Position,
			Volume = 0.5
		})
	elseif parent == localPlayer.Character and self.NPCBullet then
		Client.Sound.Play("BulletHitFlesh", {
			Position = raycastResult.Position,
			Volume = 0.15,
			PitchShift = 1.15
		})
	elseif parent:GetAttribute("ShootingGalleryPlate") and parent:GetAttribute("KnockedDown") == nil and not self.Replica then
		Client.ShootingGalleryClient.KnockDownPlate(parent)
	else
		Client.Sound.Play("BulletHitTerrain", {
			Position = raycastResult.Position,
			Volume = 0.2
		})

		if self.Firearm.LeaveHandle and not self.Firearm.SplashDamage or parent:GetAttribute("ToolName") == "Shield" and self.ProjectileName == "Arrow" then
			task.spawn(function()
				local folder = clone
				task.delay(15, function()
					folder:Destroy()
				end)
				local instance2 = raycastResult.Instance
				folder:PivotTo(CFrame.lookAt(raycastResult.Position, self.Origin) * CFrame.Angles(
					3.141592653589793,
					0,
					0
				) * CFrame.new(0, 0, 0.5))

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant.Anchored = false
					elseif descendant:IsA("Trail") then
						descendant:Destroy()
					end
				end

				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Parent = folder.PrimaryPart
				weldConstraint.Part0 = folder.PrimaryPart
				weldConstraint.Part1 = instance2
				folder.Parent = workspace.Particles
			end)
		end
	end

	if clone:GetAttribute("CollisionParticles") then
		local collisionParticles = clone:GetAttribute("CollisionParticles")
		Client.Utility.SpawnParticles(collisionParticles, CFrame.new(raycastResult.Position))
	end

	task.spawn(function()
		if game.ReplicatedStorage.Assets.Projectiles:FindFirstChild(self.ProjectileName .. "Splash") then
			local clone2 = game.ReplicatedStorage.Assets.Projectiles[self.ProjectileName .. "Splash"]:Clone()
			task.delay(10, function()
				clone2:Destroy()
			end)
			clone2:PivotTo(CFrame.new(raycastResult.Position))
			clone2.Parent = workspace.Particles

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end)

	if self.Explosive then
		Client.Utility.SpawnParticles("ExplosiveBullet", CFrame.new(raycastResult.Position))
		Client.Sound.Play("ExplosiveRoundImpact", {
			Volume = 1.35,
			Position = raycastResult.Position
		})
	end

	if self.Replica then
		return
	end

	local projectileDamage = self.Firearm.ProjectileDamage

	if not self.Firearm.ExplosionRadius and raycastResult.Instance.Name == "Head" then
		projectileDamage *= Client.GlobalSettings.HeadshotMultiplier or 1
	end

	if self.SecondBounce then
		projectileDamage *= 0.5
	end

	if self.Explosive then
		projectileDamage *= Client.GlobalSettings.ExplosiveAmmoDamageMult
	end

	if localPlayer and localPlayer:GetAttribute("Class") == "Cyborg" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 and self.Firearm.AmmoType == "Energy" then
		projectileDamage *= 1.25
	end

	if self.Firearm.SplashDamage then
		if self.Firearm.SplashDamage == "Explosive" then
			local explosionRadius = self.Firearm.ExplosionRadius
			local v2 = raycastResult.Position + createVector(0, 1, 0)
			task.spawn(function()
				Client.ExplosivesClient.Explosion(localPlayer, v2, explosionRadius, self.ProjectileId)
			end)
		elseif self.Firearm.SplashDamage == "Honey" then
			local v2 = raycastResult.Position + createVector(0, 1, 0)
			Client.Utility.SpawnParticles("HoneyGrenade", CFrame.new(v2))
			Client.Sound.Play("PotionShatterWildfire", {
				Position = raycastResult.Position,
				Volume = 0.3,
				Replicate = true,
				ReplicationProperties = {
					Position = raycastResult.Position,
					Volume = 0.3
				}
			})
		elseif self.Firearm.SplashDamage == "HalloweenPotion" then
			local v2 = raycastResult.Position + createVector(0, 1, 0)

			if self.Firearm.HalloweenEffectKind == "Trick" then
				Client.Utility.SpawnParticles("HalloweenPotionTrick", CFrame.new(v2))
			else
				Client.Utility.SpawnParticles("HalloweenPotionTreat", CFrame.new(v2))
			end

			Client.Sound.Play("PotionShatter", {
				Position = raycastResult.Position,
				Volume = 0.3
			})
		elseif self.Firearm.SplashDamage == "WitchPotion" then
			local v2 = raycastResult.Position + createVector(0, 1, 0)
			Client.Utility.SpawnParticles("WitchPotion", CFrame.new(v2))
			Client.Sound.Play("PotionShatter", {
				Position = raycastResult.Position,
				Volume = 0.3
			})
		elseif self.Firearm.SplashDamage == "Lava" then
			Client.Sound.Play("PotionShatterWildfire", {
				Position = raycastResult.Position,
				Volume = 0.3,
				Replicate = true,
				ReplicationProperties = {
					Position = raycastResult.Position,
					Volume = 0.3
				}
			})
			task.spawn(function()
				wait(8)

				if p then
					p:Destroy()
				end
			end)
		end

		Client.Events.SplashProjectileExplode:InvokeServer(raycastResult.Position, self.ProjectileId)
	elseif self.Firearm.ExplosionRadius then
		local position = raycastResult.Position
		local explosionRadius = self.Firearm.ExplosionRadius
		local hitRegId = Client.EnemyHandler.GetHitRegId()
		local allCharacters = Client.CollisionUtility.AllCharacters
		local partBoundsInRadius = workspace:GetPartBoundsInRadius(position, explosionRadius, allCharacters)
		local v2 = {}
		local v3 = {}
		local v4 = {}

		for _, v5 in pairs(partBoundsInRadius) do
			local parent2 = v5.Parent

			if v2[parent2] then
				continue
			end

			v2[parent2] = true
			local v6 = parent2:HasTag("NPC") and not parent2:GetAttribute("NotAttackable")

			if v6 then
				v6 = not parent2:GetAttribute("Tamed") or parent2.Name == "Chick"
			end

			local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent2)
			local v7

			if playerFromCharacter == nil or playerFromCharacter == localPlayer then
				v7 = false
			else
				v7 = self.Firearm.PVP or Client.PVPZoneClient.IsInPVPZone(localPlayer) and Client.PVPZoneClient.IsInPVPZone(parent2)
			end

			if not (v6 or v7) then
				continue
			end

			local position2 = parent2:GetPivot().Position
			local magnitude = (position - position2).Magnitude
			local explosiveDamage = Client.CombatUtility.GetExplosiveDamage(
				self.Firearm.ProjectileDamage,
				magnitude,
				self.Firearm.ExplosionRadius
			)

			if not Client.CollisionUtility.HasLineOfSight(position, position2) then
				continue
			end

			local _, v8 = Client.EnemyHandler.ApplyLocalDamage(parent2, explosiveDamage, hitRegId)
			table.insert(v3, v8)

			if self.Firearm.DamageParticles then
				Client.Utility.WeldParticle(parent2, self.Firearm.DamageParticles)
			end

			table.insert(v4, {
				Model = parent2,
				Distance = magnitude
			})
		end

		local v5 = Client.Events.ExplosiveProjectileDamageEnemy:InvokeServer(
			v4,
			self.ProjectileId,
			hitRegId,
			raycastResult.Position
		)

		if not (v5 and v5.Success) then
			for _, v6 in pairs(v3) do
				v6()
			end
		end
	elseif parent:FindFirstChild("NPC") and parent:HasTag("NPC") and (not parent:GetAttribute("Tamed") or parent.Name == "Chick") then
		if parent:GetAttribute("NotAttackable") then
			return
		end

		if parent:HasTag("Turret") then
			projectileDamage *= Client.GlobalSettings.TurretRangedDamageMultiplier
		end

		if self.AttackBounces and self.AttackBounces > 0 then
			task.spawn(function()
				self:BounceToNearestEnemy(raycastResult, parent)
			end)
		end

		local v2, v3 = Client.EnemyHandler.ApplyLocalDamage(parent, projectileDamage)

		if self.Firearm.Lifesteal then
			Client.Utility.SpawnParticles("LifestealDamage", CFrame.new(raycastResult.Position))
		end

		local v4 = Client.Events.ProjectileDamageEnemy:InvokeServer(
			parent,
			self.ProjectileId,
			v2,
			raycastResult.Instance
		)

		if not (v4 and v4.Success) and v3 then
			v3()
		end
	elseif parent:FindFirstChild("Humanoid") and self.Firearm and self.Firearm.PVP then
		local v2, v3 = Client.EnemyHandler.ApplyLocalDamage(parent, projectileDamage)
		local v4 = Client.Events.ProjectileDamageEnemy:InvokeServer(
			parent,
			self.ProjectileId,
			v2,
			raycastResult.Instance
		)

		if not (v4 and v4.Success) and v3 then
			v3()
		end
	elseif parent:FindFirstChild("Humanoid") and Client.PVPZoneClient.IsInPVPZone(localPlayer) and Client.PVPZoneClient.IsInPVPZone(parent) then
		local v2, v3 = Client.EnemyHandler.ApplyLocalDamage(parent, projectileDamage)
		local v4 = Client.Events.ProjectileDamageEnemy:InvokeServer(
			parent,
			self.ProjectileId,
			v2,
			raycastResult.Instance
		)

		if not (v4 and v4.Success) and v3 then
			v3()
		end
	elseif self.NPCBullet then
		if parent == localPlayer.Character then
			Client.Events.NPCProjectileDamagePlayer:FireServer(parent, raycastResult.Instance, self.Firearm.NPCModel)
		elseif parent:FindFirstChild("NPC") and parent:HasTag("NPC") and parent:GetAttribute("Tamed") and parent:GetAttribute("OwnerId") == localPlayer.UserId then
			Client.Events.NPCProjectileDamagePet:FireServer(parent, raycastResult.Instance, self.Firearm.NPCModel)
		end
	end
end

function ProjectileClass:Step(p2, callback, p3)
	self.Velocity += self.Gravity * p2

	if self.Firearm.TrackStrength then
		local magnitude = self.Velocity.Magnitude
		local aimAssistDir = Client.AimAssistClient.GetAimAssistDir(self.Position, self.Velocity.Unit, nil, 30, 50)

		if aimAssistDir then
			self.Velocity = (self.Velocity + aimAssistDir * self.Firearm.TrackStrength * magnitude * p2).Unit * magnitude
		end
	end

	local position = self.Position + self.Velocity * p2
	local v3

	if p3 then
		v3 = nil
	else
		v3 = Client.CollisionUtility.GetProjectileHit(
			self.Position,
			position,
			self.PVPParams or self.ProjectileParams or self.Firearm.ProjectileParams
		)

		if self.Firearm.ProjectileRadius then
			local sphereProjectileHit = Client.CollisionUtility.GetSphereProjectileHit(
				self.Position,
				position,
				self.Firearm.ProjectileRadius,
				self.PVPParams or self.ProjectileParams or self.Firearm.ProjectileParams
			)

			if sphereProjectileHit and sphereProjectileHit.Instance then
				local parent = sphereProjectileHit.Instance.Parent

				if parent:FindFirstChild("NPC") and parent:HasTag("NPC") then
					v3 = sphereProjectileHit
				end
			end
		end
	end

	self.Position = position
	local cframe = CFrame.lookAlong(self.Position, self.Velocity.Unit)

	if self.Firearm.ProjectileRotSpeed then
		if self.RollSpeed then
			local projectileRoll = (self.ProjectileRoll or 0) + self.Firearm.ProjectileRotSpeed * p2 * self.RollSpeed
			self.ProjectileRoll = projectileRoll
			cframe *= CFrame.Angles(0, 0, (math.rad(projectileRoll)))
		end

		local projectileRotation = (self.ProjectileRotation or 0) + self.Firearm.ProjectileRotSpeed * p2 * (self.RollSpeed and 0.5 or 1)
		self.ProjectileRotation = projectileRotation

		if self.Firearm.RotateYaw then
			cframe *= CFrame.Angles(0, math.rad(projectileRotation), 0)
		elseif self.Firearm.RotateRoll then
			cframe *= CFrame.Angles(0, 0, (math.rad(projectileRotation)))
		else
			cframe *= CFrame.Angles(math.rad(projectileRotation), 0, 0)
		end
	end

	if self.Model then
		self.Model:PivotTo(cframe)
	end

	if v3 then
		if callback then
			task.spawn(function()
				callback(v3)
			end)
			self:Destroy()
		elseif self.HitCallback then
			task.spawn(function()
				self.HitCallback(v3)
			end)
			self:Destroy()
		else
			self:Hit(v3)
		end
	end
end

function ProjectileClass:Fire(hitCallback)
	self.Active = true

	if hitCallback then
		self.HitCallback = hitCallback
	end

	if not (self.Replica or self.NPCBullet) then
		Client.Events.ReplicateBullet:FireOtherClients(self.ProjectileId, {
			Origin = self.Position,
			Velocity = self.Velocity,
			ProjectileGravity = self.Firearm.ProjectileGravity,
			ProjectileName = self.ProjectileName,
			HeadPos = self.HeadPos,
			Explosive = self.Explosive
		})
	end

	if self.Firearm.SplashDamage == "HalloweenPotion" or self.Firearm.SplashDamage == "WitchPotion" then
		self.RollSpeed = random:NextNumber() - 0.5
	end

	local total = 0
	task.spawn(function()
		local v2 = self.HeadPos and Client.CollisionUtility.GetProjectileHit(
			self.HeadPos,
			self.Origin,
			self.PVPParams or self.ProjectileParams or self.Firearm.ProjectileParams
		)

		if v2 then
			self:Hit(v2)
			return
		end

		while true do
			local v3 = RunService.RenderStepped:Wait()

			if not self.Active then
				break
			end

			if total > 15 then
				self:Destroy()
				break
			else
				total += v3
				self:Step(v3)
			end
		end
	end)
end

function ProjectileClass:CreateModel()
	local projectileName = self.Firearm.ProjectileName or "Default"

	if (projectileName == "Default" or projectileName == "GunslingerBullet") and self.Explosive then
		print("make explosive")
		projectileName = "ExplosiveBullet"
	end

	self.ProjectileName = projectileName
	local clone = game.ReplicatedStorage.Assets.Projectiles[projectileName]:Clone()
	clone:PivotTo((CFrame.lookAlong(self.Position, self.Velocity.Unit)))

	if (self.Firearm.SplashDamage == "HalloweenPotion" or self.Firearm.SplashDamage == "WitchPotion") and self.Firearm.RealModel:FindFirstChild("Contents") and clone:FindFirstChild("Contents") then
		clone.Contents.Color = self.Firearm.RealModel.Contents.Color
	end

	self.Model = clone
	clone.Parent = workspace.Particles
end

function ProjectileClass:Destroy()
	if not self.Active then
		return
	end

	self.Active = false

	if self.Model then
		local model = self.Model
		task.spawn(function()
			for _, descendant in pairs(self.Model:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Transparency = 1
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = false
				end
			end

			wait(5)
			model:Destroy()
		end)
		self.Model = nil
	end
end

return ProjectileClass