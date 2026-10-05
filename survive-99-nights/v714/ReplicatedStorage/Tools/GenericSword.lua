local createVector = vector.create
local GenericSword = {}
GenericSword.__index = GenericSword
GenericSword.Cooldown = 1
GenericSword.Damage = 0
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()

function GenericSword.new(model, realModel)
	local self = setmetatable({}, GenericSword)
	self.Model = model
	self.RealModel = realModel
	self.LastSwing = 0
	self.Damage = realModel:GetAttribute("WeaponDamage") or 10
	self.Cooldown = realModel:GetAttribute("ToolCooldown") or 0.5
	self.KnockbackVertical = realModel:GetAttribute("WeaponKnockbackVertical")
	self.KnockbackHorizontal = realModel:GetAttribute("WeaponKnockbackHorizontal")
	self.AmmoType = realModel:GetAttribute("AmmoType")
	self.EnergyCost = realModel:GetAttribute("EnergyCost")
	self.CritEnergyCost = realModel:GetAttribute("CritEnergyCost")
	self.ToolHoldAnim = realModel:GetAttribute("ToolHoldAnim")
	self.Lifesteal = realModel:GetAttribute("Lifesteal")
	self.SplitHanded = realModel:GetAttribute("SplitHanded")
	return self
end

function GenericSword:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function GenericSword:CheckHitbox()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local function fn(instance, _)
			if self.Broken == true then
				return
			end

			task.spawn(function()
				Client.ToolModule.AddEnemyHitParticles(instance)
			end)
			Client.Events.PlayEnemyHitSound:FireAllClients(instance, self.RealModel)
			task.spawn(function()
				local damage = self.Damage

				if self.AmmoType == "Energy" then
					local currentEnergy = Client.EnergyResourceClient.GetCurrentEnergy()

					if currentEnergy == 100 then
						damage *= 1.25
						Client.EnergyResourceClient.ConsumeEnergy(self.CritEnergyCost)
						Client.Sound.Play("EnergyShock", {
							Volume = 0.3,
							Replicate = true,
							ReplicationProperties = {
								Instance = localPlayer.Character.Head,
								Volume = 0.4
							}
						})
						Client.Utility.WeldParticle(instance, "EnergyShock")
					elseif currentEnergy <= 0 then
						damage *= 0.1
					else
						Client.EnergyResourceClient.ConsumeEnergy(self.EnergyCost)
					end
				end

				Client.Sound.Play("WeaponHit", {
					Volume = 0.3,
					Replicate = true,
					ReplicationProperties = {
						Instance = localPlayer.Character.Head,
						Volume = 0.4
					}
				})

				if self.Lifesteal and not instance:HasTag("WebBall") then
					Client.Utility.SpawnParticles("LifestealDamage", instance:GetPivot())
				end

				if localPlayer and localPlayer:GetAttribute("Class") == "Feaster" and (localPlayer:GetAttribute("Hunger") or 0) > Client.GlobalSettings.MaxHunger then
					damage *= Client.GlobalSettings.FeasterDamageMultiplier
				end

				local v, v2 = Client.EnemyHandler.ApplyLocalDamage(instance, damage)
				local v3 = Client.Events.ToolDamageObject:InvokeServer(
					instance,
					self.RealModel,
					v,
					humanoidRootPart.CFrame
				)

				if not (v3 and v3.Success) and v2 then
					v2()
				end
			end)
		end

		task.spawn(function()
			local v = humanoidRootPart.CFrame * CFrame.new(0, 0, -4)
			Client.ToolModule.BoxCast(v, createVector(6, 8, 8), nil, fn, self.RealModel, true)
		end)
	end
end

function GenericSword:Activate()
	self.Damage = self.RealModel:GetAttribute("WeaponDamage") or 10
	self.Cooldown = self.RealModel:GetAttribute("ToolCooldown") or 0.5

	if time() < self.LastSwing + self.Cooldown then
		return
	end

	self.LastSwing = time()

	if self.SplitHanded then
		if self.SplitHandSwing == 1 then
			Client.Events.PlayAnimation:Fire("LeftArmSwing", {
				FadeTime = 0.05,
				Speed = 1.4
			})
			self.SplitHandSwing = 2
		else
			Client.Events.PlayAnimation:Fire("RightArmSwing", {
				FadeTime = 0.05,
				Speed = 1.4
			})
			self.SplitHandSwing = 1
		end
	elseif self.ToolHoldAnim == "ScytheHold" then
		Client.Events.PlayAnimation:Fire("SwingScythe", {
			FadeTime = 0.05,
			Speed = 1.4
		})
	else
		Client.Events.PlayAnimation:Fire("SwingTool", {
			FadeTime = 0.05,
			Speed = 1.7
		})
	end

	Client.FirstPersonModule.PlayAnimation("ToolSwing", 0.05, nil, 1.7)
	Client.Sound.Play("Swing", {
		Duplicate = true
	})

	if self.Model.PrimaryPart:FindFirstChild("Swing") then
		Client.ToolModule.PlayToolSound(self, self.Model.PrimaryPart.Swing)
	end

	task.delay(0.1, function()
		if not self.Equipped then
			return
		end

		self:CheckHitbox()
	end)
end

function GenericSword.Deactivate(_) end

function GenericSword:ConnectEnergy()
	Client.EnergyResourceClient.ShowEnergyBar(self.RealModel.Name)

	local function update(energyAmmo)
		for _, descendant in pairs(self.Model.ParticlePart:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = energyAmmo == 100
			end

			if descendant:IsA("BillboardGui") then
				descendant.Enabled = energyAmmo == 100
			end
		end
	end

	self.EnergyChangedEvent = localPlayer:GetAttributeChangedSignal("EnergyAmmo"):Connect(function()
		update(localPlayer:GetAttribute("EnergyAmmo"))
	end)
	update(localPlayer:GetAttribute("EnergyAmmo"))
end

function GenericSword:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Swing")

	if self.AmmoType == "Energy" then
		self:ConnectEnergy()
	end

	if self.Lifesteal then
		Client.LifestealClient.EnableBar()
	end
end

function GenericSword:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Swing")
	Client.EnergyResourceClient.HideEnergyBar()

	if self.EnergyChangedEvent then
		self.EnergyChangedEvent:Disconnect()
	end
end

return GenericSword