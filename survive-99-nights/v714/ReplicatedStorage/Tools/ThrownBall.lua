local createVector = vector.create
local ThrownBall = {}
ThrownBall.__index = ThrownBall
ThrownBall.ToolHoldAnim = "RifleHold"
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local mouse = localPlayer:GetMouse()
game:GetService("RunService")
game:GetService("ContextActionService")

function ThrownBall.new(model, realModel)
	local self = setmetatable({}, ThrownBall)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	return self
end

function ThrownBall:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function ThrownBall.Activate(data, p)
	local v = p or mouse.UnitRay
	local raycastResult = workspace:Raycast(v.Origin, v.Direction * 500, Client.CollisionUtility.ProjectileParams)
	local unit = ((raycastResult and raycastResult.Position or v.Origin + v.Direction * 500) - data.Model:GetPivot().Position).Unit
	local primaryPart = data.RealModel.PrimaryPart
	data.RealModel:PivotTo(data.Model:GetPivot())
	data.RealModel.Parent = workspace.Items
	primaryPart.AssemblyLinearVelocity = Vector3.new()
	primaryPart.AssemblyAngularVelocity = Vector3.new()

	if data.CarnivalBall then
		print("carnival ball", {
			Replicate = true,
			Duplicate = true
		})
		Client.Sound.Play("RingToss")
		primaryPart:ApplyImpulse(unit * 1.8 + createVector(0, 1.5, 0))
	elseif data.CarnivalRing then
		print("carnival ring")
		Client.Sound.Play("RingToss", {
			Replicate = true,
			Duplicate = true
		})
		local assemblyMass = primaryPart.AssemblyMass
		primaryPart:ApplyImpulse(unit * assemblyMass * 42 + Vector3.new(0, assemblyMass * 28, 0))
		data.RealModel:RemoveTag("Interaction")
	elseif data.EasterEggId then
		local assemblyMass = primaryPart.AssemblyMass
		primaryPart:ApplyImpulse((unit * 70 + createVector(0, 30, 0)) * assemblyMass)
	else
		primaryPart:ApplyImpulse(unit * 4.5 + createVector(0, 4, 0))
	end

	Client.Events.RequestThrowItem:FireServer(data.RealModel)
	return Enum.ContextActionResult.Sink
end

function ThrownBall.Deactivate(_) end

function ThrownBall.OnEquip(_) end

function ThrownBall.OnUnequip(_) end

return ThrownBall