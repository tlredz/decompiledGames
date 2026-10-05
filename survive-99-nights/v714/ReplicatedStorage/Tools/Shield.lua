local Shield = {}
Shield.__index = Shield
Shield.ToolHoldAnim = "RifleHold"
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
Random.new()
game:GetService("ContextActionService")

function Shield.new(model, realModel)
	local self = setmetatable({}, Shield)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	self.LastUse = realModel:GetAttribute("LastUse") or 0
	self.Cooldown = realModel:GetAttribute("ToolCooldown") or 5
	self.TauntRange = realModel:GetAttribute("TauntRange") or 40
	return self
end

function Shield:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function Shield:Taunt()
	if time() < self.LastUse + self.Cooldown then
		return
	end

	self.LastUse = time()
	self.RealModel:SetAttribute("LastUse", self.LastUse)
	Client.Sound.Play("ShieldTrumpet", {
		Volume = 0.3,
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.4
		}
	})
	print("Taunt")
	Client.Events.RequestTauntEnemies:FireServer(self.RealModel, self.TauntRange)
	Client.ParticlesClient.Taunt(localPlayer)
end

function Shield:Activate(_)
	if self.RealModel:GetAttribute("CanTaunt") and localPlayer:GetAttribute("Class") == "Brute" then
		self:Taunt()
	end
end

function Shield.Deactivate(_) end

function Shield:OnEquip()
	self.Equipped = true
end

function Shield:OnUnequip()
	self.Equipped = false
end

return Shield