local Snowball = {}
Snowball.__index = Snowball
Snowball.MagazineSize = 1
Snowball.ProjectileSpeed = 50
Snowball.ProjectileGravity = 35
Snowball.ProjectileDamage = 1
Snowball.ProjectileRotSpeed = -1600
Snowball.ProjectileRadius = 1.5
Snowball.LeaveHandle = true
Snowball.FireRate = 0.2
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mouse = localPlayer:GetMouse()
local random = Random.new()
local ammoLabel = Client.Interface.AmmoLabel
local ContextActionService = game:GetService("ContextActionService")

function Snowball.new(model, realModel)
	local self = setmetatable({}, Snowball)
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

function Snowball:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function Snowball:MakePredictionArc()
	self.PredictionAttachments = {}
	local model = Instance.new("Model")
	self.PredictionDebris = model

	for i = 1, 30 do
		local attachment = Instance.new("Attachment")
		attachment.Parent = workspace.Terrain
		table.insert(self.PredictionAttachments, attachment)

		if not (i > 1) then
			continue
		end

		local beam = Instance.new("Beam")
		beam.Attachment0 = self.PredictionAttachments[i - 1]
		beam.Attachment1 = attachment
		beam.Color = ColorSequence.new(Color3.fromRGB(124, 255, 246))
		beam.Brightness = 3
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.Transparency = NumberSequence.new(0.3)
		beam.Parent = model
	end

	model.Parent = workspace.Particles
end

function Snowball:GetLaunchProperties(p)
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

	return position, v4, v3, bulletStray, raycastParams
end

function Snowball:UpdatePredictionArc()
	if not self.PredictionAttachments then
		return
	end

	local launchProperties, v, _, _, v2 = self:GetLaunchProperties()
	local projectileClass = Client.ProjectileClass.new(self, launchProperties, v, nil, nil, nil, true, v2)

	for i = 1, 30 do
		self.PredictionAttachments[i].WorldCFrame = CFrame.new(projectileClass.Position)
		projectileClass:Step(0.1, nil, true)
	end
end

function Snowball:ClearPredictionArc()
	if self.PredictionAttachments then
		for _, predictionAttachment in pairs(self.PredictionAttachments) do
			predictionAttachment:Destroy()
		end
	end

	self.PredictionAttachments = nil

	if self.PredictionDebris then
		self.PredictionDebris:Destroy()
		self.PredictionDebris = nil
	end
end

function Snowball:Fire(p, _)
	self.LastFired = time()
	local launchProperties, v, v2, v3, v4 = self:GetLaunchProperties(p)
	local projectileClass = Client.ProjectileClass.new(self, launchProperties, v, nil, nil, nil, nil, v4)
	task.spawn(function()
		Client.Events.RegisterProjectile:InvokeServer(self.RealModel, projectileClass.ProjectileId)
	end)
	self.Ammo -= 1
	self:UpdateAmmo()
	Client.Sound.Play("Swing", {
		Volume = 1
	})

	local function hitCallback(p2)
		local position = p2.Position
		Client.Utility.SpawnParticles("SnowballHit", CFrame.new(position))
	end

	projectileClass:Fire(hitCallback)

	if self.ShotCount and self.ShotCount > 1 then
		for _ = 1, self.ShotCount - 1 do
			if self.BulletStray then
				v = (v2 * CFrame.Angles(v3 * (random:NextNumber() - 0.5), v3 * (random:NextNumber() - 0.5), 0)).LookVector * (self.ProjectileSpeed + random:NextInteger(
					-15,
					15
				))
			end

			Client.ProjectileClass.new(self, launchProperties, v, projectileClass.ProjectileId, nil, nil, nil, v4):Fire()
		end
	end
end

function Snowball:Activate(p)
	local activeCount = (self.ActiveCount or 0) + 1
	self.ActiveCount = activeCount

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

		task.spawn(function()
			self:MakePredictionArc()
			self.ProjectileSpeed = 30
			local total = 0

			while self.ActiveCount == activeCount and self.Equipped do
				print("charge")
				total += task.wait()
				local v2 = math.clamp(total / 2.5, 0, 1)
				self.ProjectileSpeed = math.clamp(math.clamp(v2 * -1 * (v2 - 2), 0, 1) * 60 + 30, 30, 90)
				self:UpdatePredictionArc()
			end

			if self.Equipped then
				print("fire")
				self:Fire(p)
			end
		end)
	end
end

function Snowball:Deactivate()
	self.ActiveCount = (self.ActiveCount or 0) + 1
	self:ClearPredictionArc()
end

function Snowball:Reload()
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

function Snowball:UpdateAmmo()
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
end

function Snowball:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Shoot")
	local mouse = localPlayer:GetMouse()
	mouse.Icon = "rbxassetid://107221172731109"
	Snowball.UpdateAmmoEvent = Client.Events.UpdateToolAmmo:Connect(function(p)
		self.Ammo += p
		self:UpdateAmmo()
	end)
	self.ActiveCount = (self.ActiveCount or 0) + 1
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
				local v = reloadFinishTime - time() + 0.01
				task.wait(v)
				self:UpdateAmmo()
			end
		end)
		Client.GuiButtonHandler.ShowButton("Reload")
	end

	if self.Lifesteal then
		Client.LifestealClient.EnableBar()
	end
end

function Snowball:OnUnequip()
	self.Equipped = false
	self.ActiveCount = (self.ActiveCount or 0) + 1
	Client.GuiButtonHandler.HideButton("Shoot")
	Client.GuiButtonHandler.HideButton("Reload")
	self:ClearPredictionArc()
	Snowball.UpdateAmmoEvent:Disconnect()
	local mouse = localPlayer:GetMouse()
	mouse.Icon = ""
	ammoLabel.Visible = false
end

return Snowball