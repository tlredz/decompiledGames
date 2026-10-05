local createVector = vector.create
local TurretClassClient = {}
TurretClassClient.__index = TurretClassClient
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function TurretClassClient.new(model)
	local self = setmetatable({}, TurretClassClient)
	self.Model = model
	self.TargetTick = 1
	self.CurrentTarget = false
	self.TargetValue = self.Model:WaitForChild("TurretTarget")
	self.Gun = self.Model:WaitForChild("Gun")
	self.GunOrigin = self.Gun:GetPivot()
	self.EnemyTurret = self.Model:GetAttribute("EnemyTurret")
	self.MaxRange = self.Model:GetAttribute("MaxRange") or 30
	self.VisionAngle = self.Model:GetAttribute("VisionAngle") or 45
	self.ProjectileSpeed = self.Model:GetAttribute("ProjectileSpeed")
	self.ProjectileDamage = self.Model:GetAttribute("ProjectileDamage")
	self.FiringDelay = self.Model:GetAttribute("FiringDelay")
	self.FireRate = self.Model:GetAttribute("FireRate") or 0.35
	self.TargetOrigin = self.Model:GetPivot()
	self.TurretAngle = 0
	self.MuzzleNumber = 2
	return self
end

function Flatten(p)
	return (p * createVector(1, 0, 1)).Unit
end

function TurretClassClient:IsWithinTargetRange(p)
	local v = p - self.TargetOrigin.Position
	local flattened = Flatten(v)

	if v.Magnitude > self.MaxRange then
		return false
	end

	local flattened2 = Flatten(self.TargetOrigin.LookVector)

	if math.abs((math.deg((Client.Utility.GetAngleBetweenVectors(flattened, flattened2))))) <= self.VisionAngle / 2 then
		return true
	end
end

function TurretClassClient:SentryMode(p)
	task.spawn(function()
		local halfVisionAngle = self.VisionAngle / 2
		local v2 = true

		while true do
			local v3 = task.wait()

			if not self.Active or self.TargetTick ~= p then
				break
			end

			local v4 = 40 * v3 * (v2 and 1 or -1)
			self.TurretAngle = math.clamp(self.TurretAngle + v4, -halfVisionAngle, halfVisionAngle)
			self:UpdatePosition()

			if not (halfVisionAngle <= math.abs(self.TurretAngle)) then
				continue
			end

			task.wait(1)
			v2 = not v2
		end
	end)
end

function TurretClassClient:TargetMode(p)
	task.spawn(function()
		local halfVisionAngle = self.VisionAngle / 2
		local currentTarget = self.CurrentTarget
		local lookVector = self.TargetOrigin.LookVector

		while true do
			local v2 = task.wait()

			if not self.Active or self.TargetTick ~= p or self.CurrentTarget ~= currentTarget then
				break
			end

			if not currentTarget.Parent then
				continue
			end

			local position = currentTarget:GetPivot().Position
			local flattened = Flatten(position - self.TargetOrigin.Position)
			local angleBetweenVectors, v3 = Client.Utility.GetAngleBetweenVectors(lookVector, flattened)
			local v4 = math.deg(angleBetweenVectors) * v3
			local v5 = v4 - self.TurretAngle

			if math.abs(v5) < 300 * v2 then
				self.TurretAngle = math.clamp(v4, -halfVisionAngle, halfVisionAngle)
			else
				local v6 = 300 * v2 * (v5 < 0 and -1 or 1)
				self.TurretAngle = math.clamp(self.TurretAngle + v6, -halfVisionAngle, halfVisionAngle)
			end

			self:UpdatePosition()
		end
	end)
end

function TurretClassClient:Fire(instance)
	if self.Model:GetAttribute("Ammo") <= 0 then
		return
	end

	local clone = self.Model.PrimaryPart.FireSound:Clone()
	task.delay(4, function()
		clone:Destroy()
	end)
	clone.Parent = self.Model.PrimaryPart
	clone:Play()
	self.MuzzleNumber = self.MuzzleNumber % 2 + 1
	local muzzleFlashTop = self.Gun.Muzzle.MuzzleFlashTop

	if self.MuzzleNumber == 2 then
		muzzleFlashTop = self.Gun.Muzzle.MuzzleFlashBottom
	end

	Client.Utility.RunParticles(muzzleFlashTop)
	local projectileSpeed = self.ProjectileSpeed
	local worldPosition = muzzleFlashTop.WorldPosition
	local position = instance:GetPivot().Position

	if self.EnemyTurret then
		position = (instance:GetPivot() * CFrame.new(0, -2, 0)).Position
	end

	local unit = (position - worldPosition).Unit

	if self.EnemyTurret then
		local v = {
			ProjectileGravity = 0,
			ProjectileName = "TurretBullet",
			Turret = true,
			ProjectileDamage = self.ProjectileDamage,
			ProjectileParams = Client.CollisionUtility.EnemyProjectileParams,
			NPCModel = self.Model
		}
		local projectileClass = Client.ProjectileClass.new(v, worldPosition, unit * projectileSpeed)
		projectileClass.NPCBullet = true
		projectileClass:Fire()
	else
		local v = {
			ProjectileGravity = 0,
			ProjectileName = "TurretBullet",
			Turret = true,
			ProjectileDamage = self.ProjectileDamage
		}
		local projectileClass = Client.ProjectileClass.new(v, worldPosition, unit * projectileSpeed)
		task.spawn(function()
			Client.Events.RegisterProjectile:InvokeServer(self.Model, projectileClass.ProjectileId)
		end)
		projectileClass:Fire()
	end
end

function TurretClassClient:StartFiring(p)
	task.spawn(function()
		local currentTarget = self.CurrentTarget
		local fireRate = self.FireRate

		if localPlayer:GetAttribute("Class") == "Engineer" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 3 then
			fireRate = 0.25
		end

		while true do
			task.wait(fireRate)

			if not self.Active or self.TargetTick ~= p or self.CurrentTarget ~= currentTarget then
				break
			end

			if not (currentTarget.Parent and self:IsWithinTargetRange(currentTarget:GetPivot().Position) and currentTarget:GetAttribute("Dead") == nil) then
				continue
			end

			self:Fire(currentTarget)
		end
	end)
end

function TurretClassClient:ReplicateFire()
	local clone = self.Model.PrimaryPart.FireSound:Clone()
	task.delay(4, function()
		clone:Destroy()
	end)
	clone.Parent = self.Model.PrimaryPart
	clone:Play()
	self.MuzzleNumber = self.MuzzleNumber % 2 + 1
	local muzzleFlashTop = self.Gun.Muzzle.MuzzleFlashTop

	if self.MuzzleNumber == 2 then
		muzzleFlashTop = self.Gun.Muzzle.MuzzleFlashBottom
	end

	Client.Utility.RunParticles(muzzleFlashTop)
end

function TurretClassClient:UpdateTarget(currentTarget)
	if not (self.Active and currentTarget ~= self.CurrentTarget) then
		return
	end

	self.CurrentTarget = currentTarget

	if currentTarget and not self.SoundDb then
		self.SoundDb = true
		self.Model.Main.TurretLockOn:Play()
		task.spawn(function()
			wait(0.5)
			self.SoundDb = false
		end)
	end

	local targetTick = self.TargetTick + 1
	self.TargetTick = targetTick

	if self.CurrentTarget then
		self.TargetHighlight.OutlineColor = Color3.fromRGB(255, 73, 1)
		self:TargetMode(targetTick)

		if self.EnemyTurret then
			if self.FiringDelay then
				task.wait(self.FiringDelay)
			end

			if self.TargetTick == targetTick then
				self:StartFiring(targetTick)
			end
		elseif self.Model:GetAttribute("Owner") == localPlayer.UserId then
			self:StartFiring(targetTick)
		end
	else
		self.TargetHighlight.OutlineColor = Color3.fromRGB(0, 255, 162)
		self:SentryMode(targetTick)
	end
end

function TurretClassClient:TrackTarget()
	self.TargetValue.Changed:Connect(function()
		if self.TargetValue.Value then
			self:UpdateTarget(self.TargetValue.Value)
		else
			self:UpdateTarget(nil)
		end
	end)
	self:UpdateTarget(self.TargetValue.Value)
end

function TurretClassClient:Deactivate()
	if not self.Active then
		return
	end

	self.Active = false
	self:UpdateTarget(false)
	local gunOrigin = self.GunOrigin
	Client.Utility.SpawnParticles("TurretDestroy", gunOrigin)
	self.Model.PrimaryPart.TurretExplode:Play()

	if self.TargetHighlight then
		self.TargetHighlight:Destroy()
	end

	if self.Model:FindFirstChild("HealthBar") then
		self.Model.HealthBar:Destroy()
	end

	task.delay(0.25, function()
		Client.TweenModule.new(function(p)
			local v = 55 * p
			local v2 = self.GunOrigin * CFrame.Angles(0, math.rad(self.TurretAngle), 0) * CFrame.Angles(
				math.rad(v),
				0,
				0
			)
			self.Gun:PivotTo(v2)
		end, 1, "Quad"):Play()
	end)
end

function TurretClassClient:TrackAmmo()
	task.spawn(function()
		local ammo = self.Gun:WaitForChild("Main"):WaitForChild("Ammo")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local ammo2 = self.Model:GetAttribute("Ammo")

			if ammo2 <= 0 then
				ammo.TextLabel.Text = "Reload with rifle ammo"
				return
			end

			local maxAmmo = self.Model:GetAttribute("MaxAmmo") or ""
			ammo.TextLabel.Text = ammo2 .. "/" .. maxAmmo
		end

		self.Model:GetAttributeChangedSignal("Ammo"):Connect(update)
		self.Model:GetAttributeChangedSignal("MaxAmmo"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end)
end

function TurretClassClient:LoadTouchZone()
	self.Model:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if self.Model:GetAttribute("Ammo") == self.Model:GetAttribute("MaxAmmo") then
			return
		end

		local parent = otherPart.Parent

		if parent.Name == "Rifle Ammo" and parent:GetAttribute("Owner") == localPlayer.UserId then
			parent.Parent = game.ReplicatedStorage.TempStorage
			self.Model.PrimaryPart.Reload:Play()
			local v = Client.Events.RequestReloadTurret:InvokeServer(self.Model, parent)

			if not (v and v.Success) then
				task.delay(0.5, function()
					parent.Parent = workspace.Items
				end)
			end
		end
	end)
end

function TurretClassClient:UpdatePosition()
	local v = self.GunOrigin * CFrame.Angles(0, math.rad(self.TurretAngle), 0)
	self.Gun:PivotTo(v)
end

function TurretClassClient:Activate()
	if self.Model:GetAttribute("Ammo") <= 0 then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(0, 255, 162)
	highlight.Adornee = self.Model
	highlight.Enabled = true
	highlight.Parent = self.Model

	if self.EnemyTurret then
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	end

	self.TargetHighlight = highlight
	self.Active = true
	self:TrackTarget()

	if self.EnemyTurret then
		self.Model:GetAttributeChangedSignal("Deactivated"):Connect(function()
			self:Deactivate()
		end)
		return
	end

	self:TrackAmmo()
	self:LoadTouchZone()
end

function TurretClassClient:Destroy()
	self.Destroyed = true
end

return TurretClassClient