local createVector = vector.create
local ItemModifier = {}
ItemModifier.__index = ItemModifier
ItemModifier.Cooldown = 1
ItemModifier.Damage = 0
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Items }

function ItemModifier.new(model, realModel)
	local self = setmetatable({}, ItemModifier)
	self.Model = model
	self.RealModel = realModel
	self.LastSwing = 0
	return self
end

function ItemModifier:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function ItemModifier:CheckHitbox()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local v = humanoidRootPart.CFrame * CFrame.new(0, 0, -2)
		local partBoundsInBox = workspace:GetPartBoundsInBox(v, createVector(6, 7, 7), overlapParams)
		local v2 = {}

		for _, v3 in pairs(partBoundsInBox) do
			local parent = v3.Parent

			if not (parent:GetAttribute("Interaction") == "Item" or parent:GetAttribute("Interaction") == "Tool") then
				continue
			end

			v2[parent] = true
		end

		for k in pairs(v2) do
			Client.Events.RequestToolModifyItem:FireServer(k, self.RealModel)
		end
	end
end

function ItemModifier:Activate()
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

function ItemModifier.Deactivate(_) end

function ItemModifier:OnEquip()
	self.Equipped = true
	Client.GuiButtonHandler.ShowButton("Swing")
end

function ItemModifier:OnUnequip()
	self.Equipped = false
	Client.GuiButtonHandler.HideButton("Swing")
end

return ItemModifier