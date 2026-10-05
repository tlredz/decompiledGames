local ThrownWeapon = {}
ThrownWeapon.__index = ThrownWeapon
ThrownWeapon.MagazineSize = 1
ThrownWeapon.ProjectileSpeed = 80
ThrownWeapon.ProjectileGravity = 35
ThrownWeapon.ProjectileDamage = 35
ThrownWeapon.ProjectileRotSpeed = -1600
ThrownWeapon.ProjectileRadius = 1.5
ThrownWeapon.LeaveHandle = true
ThrownWeapon.FireRate = 0.2
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mouse = localPlayer:GetMouse()
local random = Random.new()
local ammoLabel = Client.Interface.AmmoLabel
local ContextActionService = game:GetService("ContextActionService")

function ThrownWeapon.new(model, realModel)
	local self = setmetatable({}, ThrownWeapon)
	self.Model = model
	self.RealModel = realModel
	self.LastFired = 0
	self.Reloading = false
	self.ProjectileName = self.RealModel.Name

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	if not self.PVP then
		return self
	end

	local filterDescendantsInstances = {
		workspace.Items,
		workspace.Particles,
		workspace.Map.Blockers,
		workspace.Map.Water,
		localPlayer.Character
	}
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	self.ProjectileParams = raycastParams
	return self
end

function ThrownWeapon:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function ThrownWeapon:Fire(p)
	if self.Reloading then
		return
	end

	local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

	if reloadFinishTime and time() < reloadFinishTime or self.RealModel:GetAttribute("ServerReloading") or not Client.PlayerHandler.Alive then
		return
	end

	if self.Ammo <= 0 then
		if self.AmmoType == "Infinite" then
			self:Reload()
		end
	else
		if time() < self.LastFired + self.FireRate then
			return
		end

		self.LastFired = time()
		local position = self.Model:GetPivot().Position

		if Client.FirstPersonModule.IsVisible() and Client.FirstPersonModule.GetTool() then
			position = self.Model:GetPivot().Position
		end

		local v = p or mouse.UnitRay
		local raycastParams

		if Client.PVPZoneClient.IsInPVPZone(localPlayer) then
			local filterDescendantsInstances = {
				workspace.Items,
				workspace.Particles,
				workspace.Map.Blockers,
				workspace.Map.Water,
				localPlayer.Character
			}
			raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		end

		Ray.new(v.Origin, v.Direction * 500)
		local raycastResult = workspace:Raycast(
			v.Origin,
			v.Direction * 500,
			raycastParams or Client.CollisionUtility.ProjectileParams
		)
		local v2

		if raycastResult then
			v2 = raycastResult.Position
		else
			v2 = v.Origin + v.Direction * 500
		end

		local unit = (v2 - position).Unit
		local aimAssistDir = Client.AimAssistClient.GetAimAssistDir(position, unit)
		local bulletStray = self.BulletStray and math.rad(self.BulletStray)
		local v3 = CFrame.lookAlong(Vector3.new(), aimAssistDir) * CFrame.Angles(0.10471975511965978, 0, 0)
		local v4 = v3.LookVector * self.ProjectileSpeed

		if self.BulletStray then
			v4 = (v3 * CFrame.Angles(
				bulletStray * (random:NextNumber() - 0.5),
				bulletStray * (random:NextNumber() - 0.5),
				0
			)).LookVector * self.ProjectileSpeed
		end

		local projectileClass = Client.ProjectileClass.new(self, position, v4, nil, nil, nil, nil, raycastParams)
		task.spawn(function()
			Client.Events.RegisterProjectile:InvokeServer(self.RealModel, projectileClass.ProjectileId)
		end)
		self.Ammo -= 1
		self:UpdateAmmo()
		Client.Sound.Play("Swing", {
			Volume = 1
		})
		projectileClass:Fire()

		if self.ShotCount and self.ShotCount > 1 then
			for _ = 1, self.ShotCount - 1 do
				if self.BulletStray then
					v4 = (v3 * CFrame.Angles(
						bulletStray * (random:NextNumber() - 0.5),
						bulletStray * (random:NextNumber() - 0.5),
						0
					)).LookVector * (self.ProjectileSpeed + random:NextInteger(-15, 15))
				end

				Client.ProjectileClass.new(
					self,
					position,
					v4,
					projectileClass.ProjectileId,
					nil,
					nil,
					nil,
					raycastParams
				):Fire()
			end
		end
	end
end

function ThrownWeapon:Activate(p)
	self:Fire(p)
end

function ThrownWeapon:Reload()
	if self.Reloading or self.RealModel:GetAttribute("ServerReloading") then
		return
	end

	local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

	if reloadFinishTime and time() < reloadFinishTime or self.Ammo == self.MagazineSize then
		return
	end

	self.RealModel:GetAttribute("AmmoType")
	self.Reloading = true
	local v = time()
	self.RealModel:SetAttribute("ReloadFinishTime", time() + self.ReloadTime)
	self:UpdateAmmo()
	print("request reload")
	local v2 = Client.Events.RequestReloadFirearm:InvokeServer(self.RealModel)
	print(v2)

	if v2.Success and self.Equipped then
		local v3 = time() - v

		if v3 < self.ReloadTime then
			task.wait(self.ReloadTime - v3)
		end

		if not self.Equipped then
			return
		end

		self.Ammo = v2.Ammo
		self:UpdateAmmo()
	end

	self.Reloading = false
end

function ThrownWeapon.Deactivate(_) end

local v = {}
local v2 = {}

function ThrownWeapon:UpdateParticles()
	local cursedItemEffects = self.Model:FindFirstChild("CursedItemEffects")

	if cursedItemEffects then
		local corruptionStability = self.RealModel:GetAttribute("CorruptionStability") or 100

		for _, emitter in pairs(cursedItemEffects:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if string.sub(emitter.Name, 1, 6) == "State1" then
				if corruptionStability > 25 and corruptionStability <= 50 then
					emitter.Enabled = true

					if not v[self.Model] then
						v[self.Model] = true
						Client.Sound.Play("EnergyPulseLight")
					end
				else
					emitter.Enabled = false
				end
			elseif string.sub(emitter.Name, 1, 6) == "State2" then
				if corruptionStability <= 25 then
					emitter.Enabled = true

					if not v2[self.Model] then
						v2[self.Model] = true
						Client.Sound.Play("EnergyPulseMedium")
					end
				else
					emitter.Enabled = false
				end
			end
		end
	end
end

function ThrownWeapon:UpdateAmmo()
	local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

	if reloadFinishTime and time() < reloadFinishTime then
		ammoLabel.Text = "Reloading..."

		if self.Model and self.Model:FindFirstChild("Contents") then
			self.Model.Contents.Transparency = 1
		end
	else
		ammoLabel.Text = self.Ammo

		if self.Model and self.Model:FindFirstChild("Contents") then
			self.Model.Contents.Transparency = self.Ammo == 0 and 1 or 0
		end
	end

	if self.RealModel:GetAttribute("CorruptionStability") then
		ammoLabel.TextColor3 = Color3.fromRGB(115, 0, 255)
		ammoLabel.SpecialAmmoAmount.TextColor3 = Color3.fromRGB(115, 0, 255)
		ammoLabel.SpecialAmmo.Image = "rbxassetid://134896537251897"
		ammoLabel.SpecialAmmo.Visible = true
		ammoLabel.SpecialAmmoAmount.Visible = true
		local corruptionStability = self.RealModel:GetAttribute("CorruptionStability") or 100
		ammoLabel.SpecialAmmoAmount.Text = 100 - corruptionStability .. "%"
		ammoLabel.Text = ""
		self:UpdateParticles()
	else
		ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		ammoLabel.SpecialAmmo.Visible = false
		ammoLabel.SpecialAmmoAmount.Visible = false
	end
end

function ThrownWeapon:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Shoot")
	local mouse = localPlayer:GetMouse()
	mouse.Icon = "rbxassetid://107221172731109"
	ThrownWeapon.UpdateAmmoEvent = Client.Events.UpdateToolAmmo:Connect(function(p)
		self.Ammo += p
		self:UpdateAmmo()
	end)
	self.AmmoChangedEvent2 = Client.Events.AddCarrotDartAmmo:Connect(function()
		if self.RealModel.Name == "Carrot Dart" then
			self.Ammo += 1
			self:UpdateAmmo()
		end
	end)
	self.AmmoChangedEvent3 = self.RealModel:GetAttributeChangedSignal("CorruptionStability"):Connect(function()
		self:UpdateAmmo()
	end)
	self:UpdateAmmo()
	ammoLabel.Visible = true

	if self.SplashDamage == "HalloweenPotion" then
		Client.PopUpUI.AddPopUp("Click to throw splash potion", "green")
	end

	if self.AmmoType == "Infinite" then
		ContextActionService:BindActionAtPriority("ReloadFirearm", function(_, p, _)
			if not Client.PlayerHandler.Alive then
				return Enum.ContextActionResult.Pass
			end

			if p ~= Enum.UserInputState.Begin then
				return
			end

			self:Reload()
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.R, Enum.KeyCode.ButtonY)
		self.ReloadListener = Client.Events.RequestReloadWeapon:Connect(function()
			self:Reload()
		end)
		task.spawn(function()
			local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

			if reloadFinishTime and time() < reloadFinishTime then
				local v3 = reloadFinishTime - time() + 0.01
				task.wait(v3)
				self:UpdateAmmo()
			end
		end)
		Client.GuiButtonHandler.ShowButton("Reload")
	end

	if self.Lifesteal then
		Client.LifestealClient.EnableBar()
	end
end

function ThrownWeapon:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Shoot")
	Client.GuiButtonHandler.HideButton("Reload")
	ThrownWeapon.UpdateAmmoEvent:Disconnect()

	if self.AmmoChangedEvent2 then
		self.AmmoChangedEvent2:Disconnect()
	end

	if self.AmmoChangedEvent3 then
		self.AmmoChangedEvent3:Disconnect()
	end

	local mouse = localPlayer:GetMouse()
	mouse.Icon = ""
	ammoLabel.Visible = false
end

return ThrownWeapon