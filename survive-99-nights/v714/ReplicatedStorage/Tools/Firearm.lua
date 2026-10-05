local Firearm = {}
Firearm.__index = Firearm
Firearm.MagazineSize = 1
Firearm.ProjectileSpeed = 350
Firearm.ProjectileGravity = 0
Firearm.ProjectileDamage = 35
Firearm.FireRate = 1
Firearm.ReloadTime = 2
Firearm.ToolHoldAnim = "RifleHold"
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mouse = localPlayer:GetMouse()
local random = Random.new()
local ammoLabel = Client.Interface.AmmoLabel
game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

function Firearm.new(model, realModel)
	local self = setmetatable({}, Firearm)
	self.Model = model
	self.RealModel = realModel
	self.LastFired = 0
	self.Reloading = false
	self.MouseDownTick = 0

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

function Firearm:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function Firearm:Fire(p, p2)
	if self.Reloading then
		return
	end

	local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

	if reloadFinishTime and time() < reloadFinishTime or self.RealModel:GetAttribute("ServerReloading") then
		return
	end

	local head = localPlayer.Character:FindFirstChild("Head")

	if not (head and Client.PlayerHandler.Alive) then
		return
	end

	if self.AmmoType == "Energy" then
		if not Client.EnergyResourceClient.CanUseEnergy(self.EnergyCost) then
			Client.Sound.Play("Alien_GunFailed")
			Client.EnergyResourceClient.EnergyTooLowIndicator(
				Client.EnergyResourceClient.GetCurrentEnergy(),
				self.EnergyCost
			)
			return
		end
	elseif self.Ammo <= 0 then
		self:Reload()
		return
	end

	if time() < self.LastFired + self.FireRate then
		return
	end

	self.LastFired = time()
	local fireSound = self.Model.PrimaryPart.FireSound

	if self.RealModel.Name == "Raygun" then
		fireSound.PlaybackSpeed = 1 - random:NextNumber() * 0.08 / 2
	end

	fireSound:Play()
	local ammoType = self.RealModel:GetAttribute("AmmoType") or "RifleAmmo"
	local attribute = localPlayer:GetAttribute("Explosive" .. ammoType)
	local v = attribute and attribute > 0 and true or false
	local v2 = self.RealModel:GetAttribute("ExplosiveBulletChance") and self.RealModel:GetAttribute("ExplosiveBulletChance") >= random:NextInteger(
		1,
		100
	) and true or v

	if v2 then
		Client.Sound.Play("ExplosiveRoundShot", {
			Volume = 0.12,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.12
			}
		})
	end

	Client.Events.PlayAnimation:Fire("RifleFire")
	Client.FirstPersonModule.PlayAnimation("RifleFire")
	task.spawn(function()
		if self.Model:FindFirstChild("MuzzlePart") then
			if Client.FirstPersonModule.IsVisible() then
				local tool = Client.FirstPersonModule.GetTool()

				if tool then
					if tool.MuzzlePart:FindFirstChild("MuzzleAttachment") then
						Client.Utility.RunParticles(tool.MuzzlePart:FindFirstChild("MuzzleAttachment"))
						return
					end

					local particleOuter = tool.MuzzlePart.ParticleOuter
					particleOuter:Emit(particleOuter:GetAttribute("EmitCount") or 20)
					local particleInner = tool.MuzzlePart.ParticleInner
					particleInner:Emit(particleInner:GetAttribute("EmitCount") or 10)
				end
			else
				if self.Model.MuzzlePart:FindFirstChild("MuzzleAttachment") then
					Client.Utility.RunParticles(self.Model.MuzzlePart:FindFirstChild("MuzzleAttachment"))
					return
				end

				local particleOuter = self.Model.MuzzlePart.ParticleOuter
				particleOuter:Emit(particleOuter:GetAttribute("EmitCount") or 20)
				local particleInner = self.Model.MuzzlePart.ParticleInner
				particleInner:Emit(particleInner:GetAttribute("EmitCount") or 10)
			end
		end
	end)
	local position = self.Model.Barrel.Position

	if Client.FirstPersonModule.IsVisible() then
		local tool = Client.FirstPersonModule.GetTool()

		if tool then
			position = tool.Barrel.Position
		end
	end

	local v3 = p or mouse.UnitRay
	local raycastParams

	if Client.PVPZoneClient.IsInPVPZone(localPlayer) then
		print("in pvp zone, use custom params")
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

	Ray.new(v3.Origin, v3.Direction * 500)
	local raycastResult = workspace:Raycast(
		v3.Origin,
		v3.Direction * 500,
		raycastParams or Client.CollisionUtility.ProjectileParams
	)
	local v4

	if raycastResult then
		v4 = raycastResult.Position
	else
		v4 = v3.Origin + v3.Direction * 500
	end

	local unit = (v4 - position).Unit

	if p2 ~= "MobileButton" then
		unit = Client.AimAssistClient.GetAimAssistDir(position, unit, self.RealModel.Name)
	end

	local bulletStray = self.BulletStray and math.rad(self.BulletStray)
	local cframe = CFrame.lookAlong(Vector3.new(), unit)
	local v5 = unit * self.ProjectileSpeed

	if self.BulletStray then
		v5 = (cframe * CFrame.Angles(
			bulletStray * (random:NextNumber() - 0.5),
			bulletStray * (random:NextNumber() - 0.5),
			0
		)).LookVector * self.ProjectileSpeed
	end

	local ammoType2 = self.RealModel:GetAttribute("AmmoType") or "RifleAmmo"
	local v6 = {}
	localPlayer:GetAttribute("Explosive" .. ammoType2)

	if v2 then
		v6.Explosive = true
	end

	local position2 = head.Position
	local projectileClass = Client.ProjectileClass.new(self, position, v5, nil, position2, v6, nil, raycastParams)
	task.spawn(function()
		local v7 = Client.Events.RegisterProjectile:InvokeServer(self.RealModel, projectileClass.ProjectileId, v2)

		if not (v7 and v7.Success) and ammoType2 ~= "Energy" then
			self.Ammo += 1
			self:UpdateAmmo()
		end
	end)

	if ammoType2 == "Energy" then
		local energyCost = self.EnergyCost
		Client.EnergyResourceClient.ConsumeEnergy(energyCost)
	else
		self.Ammo -= 1
		self:UpdateAmmo()
	end

	projectileClass:Fire()

	if self.ShotCount and self.ShotCount > 1 then
		for _ = 1, self.ShotCount - 1 do
			if self.BulletStray then
				v5 = (cframe * CFrame.Angles(
					bulletStray * (random:NextNumber() - 0.5),
					bulletStray * (random:NextNumber() - 0.5),
					0
				)).LookVector * (self.ProjectileSpeed + random:NextInteger(-15, 15))
			end

			Client.ProjectileClass.new(
				self,
				position,
				v5,
				projectileClass.ProjectileId,
				position2,
				v6,
				nil,
				raycastParams
			):Fire()
		end
	end
end

local v = {}
local v2 = {}

function Firearm:UpdateParticles()
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

function Firearm:UpdateAmmo()
	local ammoType = self.RealModel:GetAttribute("AmmoType") or "RifleAmmo"

	if ammoType == "Energy" then
		return
	end

	local attribute = localPlayer:GetAttribute(ammoType) or 0

	if ammoType == "Infinite" then
		attribute = "∞"
	elseif ammoType == "AutoReload" then
		attribute = self.RealModel:GetAttribute("MagazineSize")
	end

	local attribute2 = localPlayer:GetAttribute("Explosive" .. ammoType)

	if attribute2 and attribute2 > 0 then
		ammoLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
		ammoLabel.SpecialAmmoAmount.TextColor3 = Color3.fromRGB(255, 0, 0)
		ammoLabel.SpecialAmmo.Image = "rbxassetid://135965869128913"
		ammoLabel.SpecialAmmo.Visible = true
		ammoLabel.SpecialAmmoAmount.Visible = true
		ammoLabel.SpecialAmmoAmount.Text = "x" .. attribute2
	elseif self.RealModel:GetAttribute("CorruptionStability") then
		ammoLabel.TextColor3 = Color3.fromRGB(115, 0, 255)
		ammoLabel.SpecialAmmoAmount.TextColor3 = Color3.fromRGB(115, 0, 255)
		ammoLabel.SpecialAmmo.Image = "rbxassetid://134896537251897"
		ammoLabel.SpecialAmmo.Visible = true
		ammoLabel.SpecialAmmoAmount.Visible = true
		local corruptionStability = self.RealModel:GetAttribute("CorruptionStability") or 100
		ammoLabel.SpecialAmmoAmount.Text = 100 - corruptionStability .. "%"
		self:UpdateParticles()
	else
		ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		ammoLabel.SpecialAmmo.Visible = false
		ammoLabel.SpecialAmmoAmount.Visible = false
	end

	local transparency = self.Ammo == 0 and 1 or 0

	if self.Model then
		for _, part in pairs(self.Model:GetDescendants()) do
			if part:IsA("BasePart") and part.Name == "AmmoPart" then
				part.Transparency = transparency
			end
		end
	end

	local folder = Client.FirstPersonModule.GetTool()

	if folder then
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") and part.Name == "AmmoPart" then
				part.Transparency = transparency
			end
		end
	end

	local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

	if reloadFinishTime and time() < reloadFinishTime then
		ammoLabel.Text = "Reloading..."
	else
		ammoLabel.Text = self.Ammo .. " / " .. attribute
	end
end

function Firearm:Reload()
	if self.Reloading or self.RealModel:GetAttribute("ServerReloading") then
		return
	end

	local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

	if reloadFinishTime and time() < reloadFinishTime or self.Ammo == self.MagazineSize then
		return
	end

	local ammoType = self.RealModel:GetAttribute("AmmoType") or "RifleAmmo"

	if ammoType == "Energy" then
		return
	end

	if ammoType ~= "Infinite" and (localPlayer:GetAttribute(ammoType) or 0) == 0 then
		Client.Sound.Play("NoAmmo")
		return
	end

	self.Reloading = true
	local v3 = time()
	self.RealModel:SetAttribute("ReloadFinishTime", time() + self.ReloadTime)
	self:UpdateAmmo()
	local v4 = Client.Events.RequestReloadFirearm:InvokeServer(self.RealModel)

	if v4.Success and self.Equipped then
		if ammoType == "Infinite" and self.RealModel.Name == "Blowpipe" then
			Client.Sound.Play("BlowpipeReload")
		elseif ammoType == "Infinite" and self.RealModel.Name == "Ice Bow" then
			Client.Sound.Play("BowReload")
		else
			Client.Sound.Play("Reload")
		end

		local v5 = time() - v3

		if v5 < self.ReloadTime then
			task.wait(self.ReloadTime - v5)
		end

		if not self.Equipped then
			return
		end

		self.Ammo = v4.Ammo
		self:UpdateAmmo()
	end

	self.Reloading = false
end

function Firearm:Activate(p, p2)
	local currentPlatform = Client.GuiButtonHandler.GetCurrentPlatform()

	if self.Automatic and currentPlatform == "Touch" and p2 ~= "MobileButton" then
		return
	end

	local mouseDownTick = self.MouseDownTick + 1
	self.MouseDownTick = mouseDownTick

	if self.Automatic then
		task.spawn(function()
			while true do
				if p == nil and p2 == "MobileButton" then
					local viewportSize = workspace.CurrentCamera.ViewportSize
					local GuiService = game:GetService("GuiService")
					local guiInset = GuiService:GetGuiInset()
					Client.Interface.MobileCursor.Visible = true
					p = workspace.CurrentCamera:ScreenPointToRay(viewportSize.X / 2, viewportSize.Y / 2 - guiInset.Y)
				end

				self:Fire(p, p2)
				p = nil
				task.wait(self.FireRate)

				if self.MouseDownTick ~= mouseDownTick or self.Reloading or self.RealModel:GetAttribute("ServerReloading") then
					break
				end

				if not (self.Ammo <= 0) then
					continue
				end

				self.AutoFire = false
				Client.GuiButtonHandler.RefreshButtonStyles()
				break
			end
		end)
	else
		self:Fire(p)
	end
end

function Firearm:ChangeAmmo(p)
	self.Ammo += p
	self:UpdateAmmo()
end

function Firearm:Deactivate(p)
	local currentPlatform = Client.GuiButtonHandler.GetCurrentPlatform()

	if self.Automatic and currentPlatform == "Touch" then
	end

	self.MouseDownTick += 1
end

function Firearm:IsHoveringEnemy()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local GuiService = game:GetService("GuiService")
	local guiInset = GuiService:GetGuiInset()
	Client.Interface.MobileCursor.Visible = true
	local screenPointToRay = workspace.CurrentCamera:ScreenPointToRay(
		viewportSize.X / 2,
		viewportSize.Y / 2 - guiInset.Y
	)
	local position = self.Model.Barrel.Position

	if Client.FirstPersonModule.IsVisible() then
		local tool = Client.FirstPersonModule.GetTool()

		if tool then
			position = tool.Barrel.Position
		end
	end

	local v3 = screenPointToRay or mouse.UnitRay
	Ray.new(v3.Origin, v3.Direction * 500)
	local raycastResult = workspace:Raycast(v3.Origin, v3.Direction * 500, Client.CollisionUtility.ProjectileParams)
	local v4

	if raycastResult then
		v4 = raycastResult.Position
	else
		v4 = v3.Origin + v3.Direction * 500
	end

	local unit = (v4 - position).Unit
	local _, v5 = Client.AimAssistClient.GetAimAssistDir(position, unit, self.RealModel.Name)

	if v5 and #v5 > 0 then
		return true
	end
end

function Firearm:ToggleAutoFire()
	self.AutoFire = not self.AutoFire
	Client.GuiButtonHandler.RefreshButtonStyles()
end

function Firearm:TrackAutoFire()
	self.CurrentlyHovering = false
	Client.GuiButtonHandler.ShowButton("Auto Fire")
	task.spawn(function()
		while true do
			if self.Ammo <= 0 then
				self.AutoFire = false
				Client.GuiButtonHandler.RefreshButtonStyles()
			end

			if self:IsHoveringEnemy() and not self.CurrentlyHovering and self.AutoFire then
				print("TARGET")
				self.CurrentlyHovering = true
				self:Activate(nil, "MobileButton")
			elseif self.CurrentlyHovering then
				self.CurrentlyHovering = false
				self:Deactivate()
			end

			task.wait()
		end
	end)
end

function Firearm:OnEquip()
	self.Equipped = true
	local currentPlatform = Client.GuiButtonHandler.GetCurrentPlatform()
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
	Client.GuiButtonHandler.ShowButton("Shoot")
	local mouse = localPlayer:GetMouse()
	mouse.Icon = "rbxassetid://107221172731109"
	local ammoType = self.RealModel:GetAttribute("AmmoType") or "RifleAmmo"
	self.AmmoType = ammoType

	if ammoType == "Energy" then
		Client.EnergyResourceClient.ShowEnergyBar(self.RealModel.Name)
	else
		if ammoType ~= "AutoReload" then
			Client.GuiButtonHandler.ShowButton("Reload")
		end

		local _ = localPlayer:GetAttribute(ammoType) or 0
		self:UpdateAmmo()
		ammoLabel.Visible = true
		self.AmmoChangedEvent = localPlayer:GetAttributeChangedSignal(ammoType):Connect(function()
			self:UpdateAmmo()
		end)
		self.AmmoChangedEvent2 = localPlayer:GetAttributeChangedSignal("Explosive" .. ammoType):Connect(function()
			self:UpdateAmmo()
		end)
		self.AmmoChangedEvent3 = self.RealModel:GetAttributeChangedSignal("CorruptionStability"):Connect(function()
			self:UpdateAmmo()
		end)
		task.spawn(function()
			local reloadFinishTime = self.RealModel:GetAttribute("ReloadFinishTime")

			if reloadFinishTime and time() < reloadFinishTime then
				local v3 = reloadFinishTime - time() + 0.01
				task.wait(v3)
				self:UpdateAmmo()
			end
		end)
	end

	if localPlayer:GetAttribute("Class") == "Gunslinger" and self.RealModel.Name == "Trusty Revolver" then
		self.AutoUpdateEvents = {}
		table.insert(
			self.AutoUpdateEvents,
			self.RealModel:GetAttributeChangedSignal("ProjectileSpeed"):Connect(function()
				self.ProjectileSpeed = self.RealModel:GetAttribute("ProjectileSpeed")
			end)
		)
		table.insert(self.AutoUpdateEvents, self.RealModel:GetAttributeChangedSignal("ReloadTime"):Connect(function()
			self.ReloadTime = self.RealModel:GetAttribute("ReloadTime")
		end))
		table.insert(
			self.AutoUpdateEvents,
			self.RealModel:GetAttributeChangedSignal("ProjectileDamage"):Connect(function()
				self.ProjectileDamage = self.RealModel:GetAttribute("ProjectileDamage")
			end)
		)
		table.insert(self.AutoUpdateEvents, self.RealModel:GetAttributeChangedSignal("FireRate"):Connect(function()
			self.FireRate = self.RealModel:GetAttribute("FireRate")
		end))
		table.insert(
			self.AutoUpdateEvents,
			self.RealModel:GetAttributeChangedSignal("ExplosiveBulletChance"):Connect(function()
				self.ExplosiveBulletChance = self.RealModel:GetAttribute("ExplosiveBulletChance")
			end)
		)
	end

	if currentPlatform == "Touch" and self.Automatic then
		self:TrackAutoFire()
	end
end

function Firearm:OnUnequip()
	self.Equipped = false
	ContextActionService:UnbindAction("ReloadFirearm")
	Client.GuiButtonHandler.HideButton("Reload")
	Client.GuiButtonHandler.HideButton("Shoot")
	Client.GuiButtonHandler.HideButton("Auto Fire")
	self.MouseDownTick += 1
	local mouse = localPlayer:GetMouse()
	mouse.Icon = ""
	self.ReloadListener:Disconnect()

	if self.AmmoChangedEvent then
		self.AmmoChangedEvent:Disconnect()
	end

	if self.AmmoChangedEvent2 then
		self.AmmoChangedEvent2:Disconnect()
	end

	if self.AmmoChangedEvent3 then
		self.AmmoChangedEvent3:Disconnect()
	end

	Client.EnergyResourceClient.HideEnergyBar()

	if self.AutoUpdateEvents then
		for _, autoUpdateEvent in pairs(self.AutoUpdateEvents) do
			autoUpdateEvent:Disconnect()
		end

		self.AutoUpdateEvents = nil
	end

	ammoLabel.Visible = false
end

return Firearm