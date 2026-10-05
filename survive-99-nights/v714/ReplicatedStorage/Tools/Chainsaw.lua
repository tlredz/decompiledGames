local createVector = vector.create
local Chainsaw = {}
Chainsaw.__index = Chainsaw
Chainsaw.Cooldown = 1
Chainsaw.Damage = 0
Chainsaw.ToolHoldAnim = "RifleHold"
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local RunService = game:GetService("RunService")
local v = false
local object = setmetatable({}, {
	__mode = "k"
})

function Chainsaw.new(model, realModel)
	local self = setmetatable({}, Chainsaw)
	self.Model = model
	self.RealModel = realModel
	self.LastSwing = 0
	self.Damage = realModel:GetAttribute("WeaponDamage") or 10
	self.ResourceDamage = realModel:GetAttribute("WeaponResourceDamage") or 10
	self.Cooldown = realModel:GetAttribute("ToolCooldown") or 0.5
	self.KnockbackVertical = realModel:GetAttribute("WeaponKnockbackVertical")
	self.KnockbackHorizontal = realModel:GetAttribute("WeaponKnockbackHorizontal")
	self.TeethCount = 1
	return self
end

function Chainsaw:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function Chainsaw:CheckHitbox()
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
			local flag = false

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
				if instance:GetAttribute("Resource") == "Tree" and (instance:GetAttribute("Health") or 0) > 1400 and not object[instance] then
					object[instance] = true
					resourceDamage *= 5
					print("[Chainsaw] First-strike 5x on tree:", instance, "predicted damage:", resourceDamage)
					flag = true
				end

				Client.Sound.Play(instance:GetAttribute("HitSound") or "WoodChop", {
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

			if not (v4 and v4.Success) then
				if v3 then
					v3()
				end

				if flag then
					object[instance] = nil
				end
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

	local v2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
	return (Client.ToolModule.BoxCast(v2, createVector(6, 7, 7), nil, fn, self.RealModel, true))
end

function Chainsaw:Activate()
	if time() < self.LastSwing + self.Cooldown then
		return
	end

	self.LastSwing = time()
	local activeCount = (self.ActiveCount or 0) + 1
	self.ActiveCount = activeCount
	task.spawn(function()
		local total = 0

		while self.ActiveCount == activeCount do
			total += RunService.RenderStepped:Wait()

			if not (total >= 0.08) then
				continue
			end

			local teethCount = self.TeethCount == 1 and 2 or 1
			local v4 = teethCount == 1 and 2 or 1
			self.TeethCount = teethCount
			self.Model.Teeth["Teeth" .. teethCount].Transparency = 0
			self.Model.Teeth["Teeth" .. v4].Transparency = 1
			total = 0
		end
	end)
	task.spawn(function()
		Client.Sound.Play("ChainsawStart", {
			Volume = 0.5,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.5
			}
		})
		task.delay(0.7, function()
			if self.ActiveCount == activeCount then
				Client.Events.StopSound:Fire("ChainsawStart", {
					FadeTime = 0.4
				})
			end
		end)
		Client.Sound.Play("ChainsawIdle")
		wait(0.5)

		if self.ActiveCount ~= activeCount then
			return
		end

		local v3 = 0

		while self.ActiveCount == activeCount do
			local v4 = self:CheckHitbox()

			if time() - v3 > 0.4 and v4 then
				task.spawn(function()
					Client.Sound.Play("ChainsawHit", {
						TimePosition = 0.2,
						VarySpeed = 0.15,
						Volume = 0.3,
						Duplicate = true,
						Replicate = true,
						ReplicationProperties = {
							Instance = localPlayer.Character.Head,
							Volume = 0.5,
							Duplicate = true
						}
					})
				end)
				v3 = time()
			end

			wait(self.Cooldown)
		end
	end)
end

function Chainsaw:Deactivate()
	self.ActiveCount = (self.ActiveCount or 0) + 1
	Client.Events.StopSound:Fire("ChainsawIdle", {
		FadeTime = 0.2
	})
	Client.Events.StopSound:Fire("ChainsawStart", {
		FadeTime = 0.2
	})
end

function Chainsaw:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Swing")
end

function Chainsaw:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Swing")
	self.ActiveCount = (self.ActiveCount or 0) + 1
	Client.Events.StopSound:Fire("ChainsawIdle", {
		FadeTime = 0.2
	})
	Client.Events.StopSound:Fire("ChainsawStart", {
		FadeTime = 0.2
	})
end

return Chainsaw