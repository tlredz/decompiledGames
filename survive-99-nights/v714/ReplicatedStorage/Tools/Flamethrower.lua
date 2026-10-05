local createVector = vector.create
local Flamethrower = {}
Flamethrower.__index = Flamethrower
Flamethrower.Cooldown = 1
Flamethrower.Damage = 0
Flamethrower.ToolHoldAnim = "RifleHold"
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local flamethrowerBar = Client.Interface.StatBars.ExtraBars.FlamethrowerBar
game:GetService("RunService")
local v = false

function Flamethrower.new(model, realModel)
	local self = setmetatable({}, Flamethrower)
	self.Model = model
	self.RealModel = realModel
	self.LastSwing = 0
	self.Damage = realModel:GetAttribute("WeaponDamage") or 10
	self.ResourceDamage = realModel:GetAttribute("WeaponResourceDamage") or 10
	self.Cooldown = realModel:GetAttribute("ToolCooldown")
	return self
end

function Flamethrower:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function Flamethrower:CheckHitbox()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

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
			else
				Client.Sound.Play("WoodChop", {
					Volume = 0.5,
					Replicate = true,
					ReplicationProperties = {
						Instance = localPlayer.Character.Head,
						Volume = 0.4
					}
				})
			end

			local v2, v3 = Client.EnemyHandler.ApplyLocalDamage(instance, resourceDamage)
			local v4 = Client.Events.ToolDamageObject:InvokeServer(
				instance,
				self.RealModel,
				v2,
				humanoidRootPart.CFrame
			)

			if not (v4 and v4.Success) and v3 then
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
						Volume = 0.5,
						Replicate = true,
						Duplicate = true,
						ReplicationProperties = {
							Instance = localPlayer.Character.Head,
							Volume = 0.4
						}
					})
				end

				Client.Events.DestroyObject:Fire(instance, humanoidRootPart.CFrame)
			elseif instance:GetAttribute("Resource") == "IceBlock" then
				Client.Sound.Play("IceHit", {
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

	local v2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -9)
	return (Client.ToolModule.BoxCast(v2, createVector(6, 7, 20), nil, fn, self.RealModel, true))
end

function Flamethrower:SetMobileButtons(p2)
	if self.Equipped then
		if p2 then
			Client.GuiButtonHandler.HideButton("Flame")
			Client.GuiButtonHandler.ShowButton("Off")
		else
			Client.GuiButtonHandler.HideButton("Off")
			Client.GuiButtonHandler.ShowButton("Flame")
		end
	else
		Client.GuiButtonHandler.HideButton("Flame")
		Client.GuiButtonHandler.HideButton("Off")
	end
end

function Flamethrower:Activate()
	if (localPlayer:GetAttribute("FlamethrowerFuel") or 0) <= 0 then
		Client.Events.SetPopUpMessage:Fire("you are out of fuel", "warning")
		return
	end

	if time() < self.LastSwing + self.Cooldown then
		return
	end

	self.LastSwing = time()
	self.Model.Nozzle.Attachment.OrangeFlame.Enabled = true
	local tool = Client.FirstPersonModule.GetTool()

	if tool then
		tool.Nozzle.Attachment.OrangeFlame.Enabled = true
	end

	local activeCount = (self.ActiveCount or 0) + 1
	self.ActiveCount = activeCount
	self:SetMobileButtons(true)
	Client.Events.StartFlamethrower:FireServer(self.RealModel)
	task.spawn(function()
		Client.Sound.Play("Flamethrower")

		while self.ActiveCount == activeCount do
			self:CheckHitbox()
			wait(self.Cooldown)
		end
	end)
end

function Flamethrower:Deactivate()
	self.ActiveCount = (self.ActiveCount or 0) + 1
	self:SetMobileButtons(false)
	self.Model.Nozzle.Attachment.OrangeFlame.Enabled = false
	local tool = Client.FirstPersonModule.GetTool()

	if tool then
		tool.Nozzle.Attachment.OrangeFlame.Enabled = false
	end

	Client.Events.StopFlamethrower:FireServer(self.RealModel)
	Client.Events.StopSound:Fire("Flamethrower", {
		FadeTime = 0.2
	})
end

function Flamethrower:OnEquip()
	self.Equipped = true
	self:SetMobileButtons(false)
	local flamethrowerFuel = localPlayer:GetAttribute("FlamethrowerFuel") or 0
	flamethrowerBar.Bar.Size = UDim2.new(flamethrowerFuel / 100, 0, 1, 0)
	flamethrowerBar.Visible = true
	self.FuelEvent = localPlayer:GetAttributeChangedSignal("FlamethrowerFuel"):Connect(function()
		local flamethrowerFuel2 = localPlayer:GetAttribute("FlamethrowerFuel") or 0
		flamethrowerBar.Bar.Size = UDim2.new(flamethrowerFuel2 / 100, 0, 1, 0)

		if flamethrowerFuel2 <= 0 then
			self:Deactivate()
		end
	end)
end

function Flamethrower:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Flame")
	Client.GuiButtonHandler.HideButton("Off")
	self.Model.Nozzle.Attachment.OrangeFlame.Enabled = false
	self.ActiveCount = (self.ActiveCount or 0) + 1
	Client.Events.StopFlamethrower:FireServer(self.RealModel)
	Client.Events.StopSound:Fire("Flamethrower", {
		FadeTime = 0.2
	})

	if self.FuelEvent then
		self.FuelEvent:Disconnect()
		self.FuelEvent = nil
	end

	flamethrowerBar.Visible = false
end

return Flamethrower