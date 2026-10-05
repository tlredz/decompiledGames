local Flashlight = {}
Flashlight.__index = Flashlight
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local batteryBar = nil
local flag = true
local flag2 = true
local random = Random.new()
local flag3 = false
game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

function Flashlight.new(model, realModel)
	local self = setmetatable({}, Flashlight)
	self.Model = model
	self.RealModel = realModel
	self.FlashlightOn = false
	self.Battery = self.RealModel:GetAttribute("Battery")
	self.ConeTransparency = 0.75

	if self.RealModel.Name == "Admin Flashlight" then
		self.ConeTransparency = 0.2
		self.AdminFlashlight = true
	end

	return self
end

function Flashlight.Break(p)
	Client.InventoryHandler.ClearItemFromInventory(p.RealModel)
end

function Flashlight:Flicker()
	task.spawn(function()
		if self.Flickering then
			return
		end

		local flag4 = true

		local function flickOn()
			if self.FlashlightOn and self.Model and self.Model:FindFirstChild("ConeHolder") then
				flag4 = true
				self.Model.ConeHolder.ConeLight.Transparency = self.ConeTransparency

				if self.Model.ConeHolder:FindFirstChild("HighlightFlashlightCone") then
					self.Model.ConeHolder.HighlightFlashlightCone.FillTransparency = 0.95
				end

				local tool = Client.FirstPersonModule.GetTool()

				if tool then
					tool.ConeHolder.ConeLight.Transparency = self.ConeTransparency

					if tool.ConeHolder:FindFirstChild("HighlightFlashlightCone") then
						tool.ConeHolder.HighlightFlashlightCone.FillTransparency = 0.95
					end
				end
			end
		end

		local function flickOff()
			if self.FlashlightOn and self.Model and self.Model:FindFirstChild("ConeHolder") then
				flag4 = false
				self.Model.ConeHolder.ConeLight.Transparency = 1

				if self.Model.ConeHolder:FindFirstChild("HighlightFlashlightCone") then
					self.Model.ConeHolder.HighlightFlashlightCone.FillTransparency = 1
				end

				local tool = Client.FirstPersonModule.GetTool()

				if tool then
					tool.ConeHolder.ConeLight.Transparency = 1

					if tool.ConeHolder:FindFirstChild("HighlightFlashlightCone") then
						tool.ConeHolder.HighlightFlashlightCone.FillTransparency = 1
					end
				end
			end
		end

		local integer = random:NextInteger(16, 24)

		if integer % 2 == 0 then
			integer += 1
		end

		self.Flickering = true

		for _ = 1, integer do
			if flag4 then
				flickOff()
			else
				flickOn()
			end

			wait(random:NextNumber(0.02, 0.45))
		end

		if self.FlashlightOn and self.Model and self.Model.PrimaryPart then
			Client.Sound.Play("FlashlightBroken")

			for _, emitter in pairs(self.Model.PrimaryPart:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			self:TurnFlashlightOff()

			if flag2 then
				flag2 = false
				task.spawn(function()
					wait(2.5)
				end)
			end
		end

		self.Flickering = false
	end)
end

function Flashlight:UpdateFlashlightBeam()
	if self.ConeHolder then
		local model = self.Model
		local tool = Client.FirstPersonModule.GetTool()

		if tool and Client.FirstPersonModule.IsVisible() then
			model = tool
		end

		local v = model:GetPivot() * self.ConeHolderOffset
		self.ConeHolder:PivotTo(v)
	end
end

function Flashlight:CreateTouchZone()
	if not self.TouchZone then
		local clone

		if self.RealModel.Name == "Old Flashlight" then
			clone = game.ReplicatedStorage.Assets.TorchZone.TorchZone:Clone()
		else
			clone = game.ReplicatedStorage.Assets.TorchZone.TorchZone2:Clone()
		end

		self.TouchZone = clone
		clone:PivotTo(localPlayer.Character:GetPivot())
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.RigidityEnabled = true
		alignPosition.Attachment0 = clone.PrimaryPart.Attachment
		alignPosition.Attachment1 = localPlayer.Character.HumanoidRootPart.RootAttachment
		alignPosition.Parent = clone.PrimaryPart
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.RigidityEnabled = true
		alignOrientation.Attachment0 = clone.PrimaryPart.Attachment
		alignOrientation.Attachment1 = localPlayer.Character.HumanoidRootPart.RootAttachment
		alignOrientation.Parent = clone.PrimaryPart
		clone.Parent = workspace
	end
end

function GuiRed(p)
	if p and batteryBar then
	end
end

function Flashlight:TurnFlashlightOn()
	if flag3 then
		return
	end

	if self.RealModel and self.RealModel:GetAttribute("Battery") <= 0 then
		if flag then
			flag = false
			Client.PopUpUI.AddPopUp("flashlight out of battery. recharge at campfire", "warning")
			task.spawn(function()
				wait(2)
				flag = true
			end)
		end

		self:TurnFlashlightOff()
	else
		Client.Events.FlashlightToggle:FireServer(true, self.RealModel.Name)

		if not self.TouchZone then
			self:CreateTouchZone()
		end

		GuiRed(true)
		self.FlashlightOn = true
		local coneHolder = self.ConeHolder
		coneHolder.ConeLight.Transparency = self.ConeTransparency
		task.spawn(function()
			local highlightFlashlightCone = coneHolder:WaitForChild("HighlightFlashlightCone", 2)

			if highlightFlashlightCone and self.FlashlightOn then
				highlightFlashlightCone.FillTransparency = 0.95
			end
		end)
		coneHolder.ConeLight.PointLight.Enabled = true
		self.RealModel:SetAttribute("On", true)
		task.spawn(function()
			if self.RealModel.Name == "Admin Flashlight" then
				self.AdminFlashlightTick = (self.AdminFlashlightTick or 0) + 1
				local adminFlashlightTick = self.AdminFlashlightTick
				self.AdminTorchDebounce = {}
				local overlapParams = OverlapParams.new()
				local coneLight = coneHolder.ConeLight
				coneLight.CanTouch = true

				while self.FlashlightOn and adminFlashlightTick == self.AdminFlashlightTick do
					local partsInPart = workspace:GetPartsInPart(coneLight, overlapParams)
					local v = {}

					for _, v2 in pairs(partsInPart) do
						local parent = v2.Parent

						if not (parent:FindFirstChild("NPC") and parent:GetAttribute("NotAttackable") == nil and parent:GetAttribute("NotDamageable") == nil) then
							continue
						end

						if parent:GetAttribute("Tamed") ~= nil or self.AdminTorchDebounce[parent] then
							continue
						end

						local position = parent:GetPivot().Position

						if not Client.CollisionUtility.HasLineOfSight(self.Model:GetPivot().Position, position) then
							continue
						end

						v[parent] = true
						self.AdminTorchDebounce[parent] = true
						local parent2 = parent
						task.delay(0.6, function()
							self.AdminTorchDebounce[parent2] = nil
						end)
					end

					for k in pairs(v) do
						Client.Events.AdminFlashlightTouchEnemy:FireServer(self.RealModel, k)
					end

					task.wait(0.5)
				end
			end
		end)
		Client.ColorCorrectionLightingClient.SetFlashlightActive(true, self.RealModel.Name)
	end
end

function Flashlight:TurnFlashlightOff()
	if not (self.Model and self.ConeHolder) then
		return
	end

	Client.Events.FlashlightToggle:FireServer(false, self.RealModel.Name)

	if self.TouchZone then
		self.TouchZone:Destroy()
		self.TouchZone = nil
	end

	GuiRed(false)
	self.FlashlightOn = false
	local coneHolder = self.ConeHolder
	coneHolder.ConeLight.Transparency = 1
	coneHolder.ConeLight.PointLight.Enabled = false
	task.spawn(function()
		local highlightFlashlightCone = coneHolder:WaitForChild("HighlightFlashlightCone", 2)

		if highlightFlashlightCone and not self.FlashlightOn then
			highlightFlashlightCone.FillTransparency = 1
		end
	end)
	self.RealModel:SetAttribute("On", false)
	Client.ColorCorrectionLightingClient.SetFlashlightActive(false, self.RealModel.Name)
end

local v = true

function Flashlight:Activate()
	if Client.GuiButtonHandler.GetCurrentPlatform() == "Controller" then
		if not v then
			return
		end

		v = false
		task.spawn(function()
			wait(0.25)
			v = true
		end)
	end

	if self.FlashlightOn then
		Client.Sound.Play("FlashlightOff", {
			Volume = 0.4,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.25
			}
		})
		self:TurnFlashlightOff()
	else
		Client.Sound.Play("FlashlightOn", {
			Volume = 0.4,
			Replicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.25
			}
		})
		self:TurnFlashlightOn()
	end
end

function Flashlight.Deactivate(_) end

function Flashlight:OnEquip()
	self.BatteryListener = self.RealModel:GetAttributeChangedSignal("Battery"):Connect(function()
		if self.RealModel:GetAttribute("Battery") <= 0 then
			if flag then
				flag = false
				Client.PopUpUI.AddPopUp("flashlight out of battery. recharge at campfire", "warning")
				task.spawn(function()
					wait(2)
					flag = true
				end)
			end

			self:TurnFlashlightOff()
			self.Battery = self.RealModel:GetAttribute("Battery")
		end
	end)
	RunService:BindToRenderStep("UpdateFlashlight", Enum.RenderPriority.Last.Value + 20, function(_)
		self:UpdateFlashlightBeam()
	end)
	self.ConeHolderOffset = self.Model.PrimaryPart.CFrame:ToObjectSpace(self.Model.ConeHolder.PrimaryPart.CFrame)
	self.ConeHolderTemplate = self.Model.ConeHolder
	self.ConeHolder = self.Model.ConeHolder

	for _, descendant in pairs(self.ConeHolder:GetDescendants()) do
		if descendant:IsA("WeldConstraint") or descendant:IsA("Weld") or descendant:IsA("Motor6D") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
		end
	end

	self.ConeHolder.Parent = workspace
	Client.GuiButtonHandler.ShowButton("Light")
	Client.Events.EquippedFlashlight:FireServer()
	batteryBar = localPlayer.PlayerGui.Interface.StatBars.BatteryBar
	batteryBar.Visible = true

	if flag3 then
		self:TurnFlashlightOff()
		task.spawn(function()
			wait(3)
			flag3 = false
		end)
	elseif self.RealModel:GetAttribute("On") then
		self:TurnFlashlightOn()
	end

	self.Battery = self.RealModel:GetAttribute("Battery")
end

function Flashlight:OnUnequip()
	if self.TouchZone then
		self.TouchZone:Destroy()
	end

	if self.BatteryListener then
		self.BatteryListener:Disconnect()
		self.BatteryListener = nil
	end

	local _ = self.Flickering
	RunService:UnbindFromRenderStep("UpdateFlashlight")

	if self.ConeHolder then
		self.ConeHolder:Destroy()
		self.ConeHolder = nil
	end

	Client.GuiButtonHandler.HideButton("Light")
	Client.ColorCorrectionLightingClient.SetFlashlightActive(false, self.RealModel.Name)
	GuiRed(false)
	batteryBar.Visible = false
	Client.Events.FlashlightToggle:FireServer(false, self.RealModel.Name)
end

return Flashlight