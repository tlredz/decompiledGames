local createVector = vector.create
local WateringCan = {}
WateringCan.__index = WateringCan
WateringCan.Cooldown = 0.25
WateringCan.Damage = 0
WateringCan.TimeToWater = 3
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
game:GetService("RunService")
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Structures }

function WateringCan.new(model, realModel)
	local self = setmetatable({}, WateringCan)
	self.Model = model
	self.RealModel = realModel
	self.LastSwing = 0
	self.LastHits = {}
	return self
end

function WateringCan:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function WateringCan:CheckHitbox(p)
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local v = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
		local partBoundsInBox = workspace:GetPartBoundsInBox(v, createVector(6, 7, 7), overlapParams)
		local v2 = {}

		for _, v3 in pairs(partBoundsInBox) do
			local parent = v3.Parent:HasTag("FarmPlot") and v3.Parent or v3.Parent.Parent

			if parent:HasTag("FarmPlot") then
				v2[parent] = true
			end
		end

		for k in pairs(v2) do
			self.LastHits[k] = (self.LastHits[k] or 0) + p
		end

		for k in pairs(self.LastHits) do
			if not v2[k] then
				self.LastHits[k] = nil
			end
		end

		for k, lastHit in pairs(self.LastHits) do
			if not (self.TimeToWater < lastHit) or k:GetAttribute("Watered") then
				continue
			end

			Client.Events.RequestWaterPlot:FireServer(self.RealModel, k)
		end
	end
end

function WateringCan:GroundWaterParticles()
	if not self.WaterParticles then
		self.WaterParticles = game.ReplicatedStorage.Assets.Particles.WaterSplash:Clone()
	end

	local v = self.Model.PrimaryPart.SpoutAttachment.WorldCFrame * CFrame.Angles(0.08726646259971647, 0, 0)
	task.delay(0.25, function()
		local raycastResult = workspace:Raycast(v.Position, v.LookVector * 20)

		if raycastResult then
			print(raycastResult.Instance:GetFullName())
			self.WaterParticles.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.3, 0))
			self.WaterParticles.Parent = workspace.Particles
		end
	end)
end

function WateringCan:Activate()
	print("water")

	if time() < self.LastSwing + self.Cooldown then
		return
	end

	self.LastSwing = time()
	local activeCount = (self.ActiveCount or 0) + 1
	self.ActiveCount = activeCount
	task.spawn(function()
		Client.Sound.Play("WateringCan")
		Client.Events.PlayAnimation:Fire("WateringCanPour")
		self.Model.PrimaryPart.SpoutAttachment.Particles.Enabled = true

		while self.ActiveCount == activeCount do
			local v2 = task.wait(self.Cooldown)

			if not (self.Equipped and self.ActiveCount == activeCount) then
				continue
			end

			self:CheckHitbox(v2)
			task.spawn(function()
				self:GroundWaterParticles()
			end)
		end

		task.delay(0.25, function()
			if self.ActiveCount == activeCount + 1 and self.WaterParticles then
				self.WaterParticles.Parent = nil
			end
		end)
	end)
end

function WateringCan:Deactivate()
	self.Model.PrimaryPart.SpoutAttachment.Particles.Enabled = false
	self.ActiveCount = (self.ActiveCount or 0) + 1
	Client.Events.StopSound:Fire("WateringCan", {
		FadeTime = 0.2
	})
	Client.Events.StopAnimation:Fire("WateringCanPour")
	self.LastHits = {}
end

function WateringCan:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Swing")
end

function WateringCan:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Swing")
	self.ActiveCount = (self.ActiveCount or 0) + 1
	Client.Events.StopSound:Fire("WateringCan", {
		FadeTime = 0.2
	})
	Client.Events.StopAnimation:Fire("WateringCanPour")
	self.LastHits = {}

	if self.WaterParticles then
		self.WaterParticles:Destroy()
		self.WaterParticles = nil
	end
end

return WateringCan