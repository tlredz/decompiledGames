local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GenericAxe = {}
GenericAxe.__index = GenericAxe
GenericAxe.Cooldown = 1
GenericAxe.Damage = 0
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local ammoLabel = Client.Interface.AmmoLabel
local v = false

function GenericAxe.new(model, realModel)
	local self = setmetatable({}, GenericAxe)
	self.Model = model
	self.RealModel = realModel
	self.LastSwing = 0
	self.Damage = realModel:GetAttribute("WeaponDamage") or 10
	self.ResourceDamage = realModel:GetAttribute("WeaponResourceDamage") or 10
	self.Cooldown = realModel:GetAttribute("ToolCooldown") or 0.5
	self.KnockbackVertical = realModel:GetAttribute("WeaponKnockbackVertical")
	self.KnockbackHorizontal = realModel:GetAttribute("WeaponKnockbackHorizontal")
	return self
end

function GenericAxe:UpdateParams()
	local realModel = self.RealModel
	self.Damage = realModel:GetAttribute("WeaponDamage") or 10
	self.ResourceDamage = realModel:GetAttribute("WeaponResourceDamage") or 10
	self.Cooldown = realModel:GetAttribute("ToolCooldown") or 0.5
	self.KnockbackVertical = realModel:GetAttribute("WeaponKnockbackVertical")
	self.KnockbackHorizontal = realModel:GetAttribute("WeaponKnockbackHorizontal")
end

function GenericAxe:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function GenericAxe:CheckHitbox()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local function fn(instance, p)
			if self.Broken == true then
				return
			end

			task.spawn(function()
				Client.ToolModule.AddEnemyHitParticles(instance)
			end)
			Client.Events.PlayEnemyHitSound:FireAllClients(instance, self.RealModel)
			task.spawn(function()
				local resourceDamage = self.ResourceDamage

				if p.Type == "Player" or p.Type == "NPC" then
					resourceDamage = self.Damage
					Client.Sound.Play("WeaponHit", {
						Volume = 0.3,
						Replicate = true,
						ReplicationProperties = {
							Instance = localPlayer.Character.Head,
							Volume = 0.4
						}
					})
				end

				local iceDamageMultiplier = self.RealModel:GetAttribute("IceDamageMultiplier")

				if iceDamageMultiplier and instance:GetAttribute("Resource") == "IceBlock" then
					resourceDamage *= iceDamageMultiplier
				end

				if localPlayer and localPlayer:GetAttribute("Class") == "Feaster" and (localPlayer:GetAttribute("Hunger") or 0) > Client.GlobalSettings.MaxHunger then
					resourceDamage *= Client.GlobalSettings.FeasterDamageMultiplier
				end

				local v2, v3 = Client.EnemyHandler.ApplyLocalDamage(instance, resourceDamage)
				local v4 = false

				if p.Type == "Resource" then
					local hitRegisters = instance:FindFirstChild("HitRegisters")
					v4 = hitRegisters and instance:GetAttribute("Health") - Client.EnemyHandler.GetLocalHealthRegistered(hitRegisters) <= 0 and true or false
				end

				local v5 = Client.Events.ToolDamageObject:InvokeServer(
					instance,
					self.RealModel,
					v2,
					humanoidRootPart.CFrame,
					v4
				)

				if not (v5 and v5.Success) and v3 then
					v3()
				end
			end)
			local hitRegisters = p.Type == "Resource" and instance:FindFirstChild("HitRegisters")

			if hitRegisters then
				if instance:GetAttribute("Health") - Client.EnemyHandler.GetLocalHealthRegistered(hitRegisters) <= 0 then
					if not v and instance.Name == "Small Tree" and Client.TutorialClient.currentID == 1 then
						v = true
						task.spawn(function()
							local tutorialLabel = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("TutorialLabel")
							tutorialLabel.Text = "Put wood on Fire until it reaches 100%"
						end)
					end

					if instance:GetAttribute("Resource") == "IceBlock" then
						Client.Sound.Play("IceBreak", {
							Volume = 0.55,
							Replicate = true,
							Duplicate = true,
							ReplicationProperties = {
								Instance = localPlayer.Character.Head,
								Volume = 0.4
							}
						})
					elseif instance:GetAttribute("Resource") == "MeteorNode" then
						if instance.Name == "Obsidiron Node" then
							Client.Sound.Play("ObsidionNodeBreak", {
								Volume = 0.3,
								Replicate = true,
								Duplicate = true,
								ReplicationProperties = {
									Instance = localPlayer.Character.Head,
									Volume = 0.3
								}
							})
							local clone = ReplicatedStorage.Assets.Particles.BreakObsidiron:Clone()
							clone:PivotTo(instance:GetPivot())
							clone.Parent = workspace.Particles

							for _, emitter in pairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount") or 2)
								end
							end

							task.spawn(function()
								wait(5)

								if clone then
									clone:Destroy()
								end
							end)
						else
							Client.Sound.Play("MeteorNodeBreak", {
								Volume = 0.5,
								Replicate = true,
								Duplicate = true,
								ReplicationProperties = {
									Instance = localPlayer.Character.Head,
									Volume = 0.4
								}
							})
							local clone = ReplicatedStorage.Assets.Particles.BreakMeteor:Clone()
							clone:PivotTo(instance:GetPivot())
							clone.Parent = workspace.Particles

							for _, emitter in pairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount") or 2)
								end
							end

							task.spawn(function()
								wait(5)

								if clone then
									clone:Destroy()
								end
							end)
						end
					end

					Client.Events.DestroyObject:Fire(instance, humanoidRootPart.CFrame)
				else
					local hitSound = instance:GetAttribute("HitSound") or "WoodChop"
					local v2 = instance:GetAttribute("Resource") == "IceBlock" and "IceHit" or instance:GetAttribute("Resource") == "MeteorNode" and "MeteorNodeHit" or hitSound
					Client.Sound.Play(v2, {
						Volume = 0.5,
						Replicate = true,
						Duplicate = true,
						ReplicationProperties = {
							Instance = localPlayer.Character.Head,
							Volume = 0.4
						}
					})
				end
			end
		end

		task.spawn(function()
			local v2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
			local v3

			if self.RealModel.Name == "Woodsman's Axe" then
				v2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -4)
				v3 = createVector(6, 8, 8)
			else
				v3 = createVector(6, 7, 7)
			end

			Client.ToolModule.BoxCast(v2, v3, nil, fn, self.RealModel, true)
		end)
	end
end

function GenericAxe:Activate()
	if time() < self.LastSwing + self.Cooldown then
		return
	end

	self.LastSwing = time()
	Client.Events.PlayAnimation:Fire("SwingTool", {
		FadeTime = 0.05,
		Speed = 1.7
	})
	Client.Sound.Play("Swing", {
		Duplicate = true
	})
	Client.FirstPersonModule.PlayAnimation("ToolSwing", 0.05, nil, 1.7)

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

function GenericAxe.Deactivate(_) end

local v2 = {}
local v3 = {}

function GenericAxe:UpdateParticles()
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

					if not v2[self.Model] then
						v2[self.Model] = true
						Client.Sound.Play("EnergyPulseLight")
					end
				else
					emitter.Enabled = false
				end
			elseif string.sub(emitter.Name, 1, 6) == "State2" then
				if corruptionStability <= 25 then
					emitter.Enabled = true

					if not v3[self.Model] then
						v3[self.Model] = true
						Client.Sound.Play("EnergyPulseMedium")
					end
				else
					emitter.Enabled = false
				end
			end
		end
	end
end

function GenericAxe:UpdateAmmo()
	if self.RealModel:GetAttribute("CorruptionStability") then
		ammoLabel.TextColor3 = Color3.fromRGB(115, 0, 255)
		ammoLabel.SpecialAmmoAmount.TextColor3 = Color3.fromRGB(115, 0, 255)
		ammoLabel.SpecialAmmo.Image = "rbxassetid://134896537251897"
		ammoLabel.SpecialAmmo.Visible = true
		ammoLabel.SpecialAmmoAmount.Visible = true
		local corruptionStability = self.RealModel:GetAttribute("CorruptionStability") or 100
		ammoLabel.SpecialAmmoAmount.Text = 100 - corruptionStability .. "%"
		ammoLabel.Text = ""
		ammoLabel.Visible = true
		self:UpdateParticles()
	end
end

function GenericAxe:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Swing")
	self.AmmoChangedEvent = self.RealModel:GetAttributeChangedSignal("CorruptionStability"):Connect(function()
		self:UpdateAmmo()
	end)
	self:UpdateAmmo()
end

function GenericAxe:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Swing")

	if self.AmmoChangedEvent then
		self.AmmoChangedEvent:Disconnect()
	end

	ammoLabel.Visible = false
end

return GenericAxe