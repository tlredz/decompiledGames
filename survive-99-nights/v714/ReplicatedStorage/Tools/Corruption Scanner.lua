local createVector = vector.create
local CorruptionScanner = {}
CorruptionScanner.__index = CorruptionScanner
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local RunService = game:GetService("RunService")
local v = {}
local v2 = {
	["Corrupted Tree Rift"] = true,
	["Corrupted Wolf Rift"] = true
}

function CorruptionScanner.new(model, realModel)
	local self = setmetatable({}, CorruptionScanner)
	self.Model = model
	self.RealModel = realModel

	for k, v3 in pairs(self.RealModel:GetAttributes()) do
		self[k] = v3
	end

	return self
end

function CorruptionScanner:FindNearestRift()
	if not localPlayer.Character then
		return
	end

	local position = localPlayer.Character:GetPivot().Position
	local map = game.ReplicatedStorage.Map
	local v3 = nil
	local v4 = nil

	for _, child in pairs(map:GetChildren()) do
		if v[child.Name] or not v2[string.split(child.Name, ".")[1]] then
			continue
		end

		local position2 = child:GetAttribute("Position")

		if not position2 then
			continue
		end

		if v3 == nil then
			v4 = child
			v3 = position2
		elseif (position2 - position).Magnitude < (v3 - position).Magnitude then
			v4 = child
			v3 = position2
		end
	end

	return v3, v4, position and v3 and (v3 - position).Magnitude
end

function CorruptionScanner:PointBeamInDirection(p2, p3)
	local emitPoint = self.Model.PrimaryPart.EmitPoint
	local emitEnd = self.Model.PrimaryPart.EmitEnd
	local total = 0
	task.spawn(function()
		emitPoint.Beam.Enabled = true

		while total < p3 do
			emitEnd.WorldCFrame = emitPoint.WorldCFrame + p2 * 4 + createVector(0, 1, 0)
			total += RunService.RenderStepped:Wait()
		end

		emitPoint.Beam.Enabled = false
	end)
end

function CorruptionScanner:HighlightClosestRift()
	local nearestRift, v3, v4 = self:FindNearestRift()
	Client.Utility.RunParticles(self.Model.Main.EmitPoint)

	if nearestRift then
		if v3 and v4 and v4 <= 75 then
			v[v3.Name] = true
		else
			self:PointBeamInDirection(
				((nearestRift - localPlayer.Character:GetPivot().Position) * createVector(1, 0, 1)).Unit,
				1
			)
		end
	end
end

function CorruptionScanner:ScanForClosestRift()
	while true do
		task.wait(2)

		if not self.Equipped then
			break
		end

		Client.Sound.Play("RadarBeep")
		self:HighlightClosestRift()
	end
end

function CorruptionScanner:Break()
	print("time to break locally")
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function CorruptionScanner.Activate(_, _) end

function CorruptionScanner.Deactivate(_) end

function CorruptionScanner:OnEquip()
	self.Equipped = true
	Client.Interface.CorruptionScanner.Visible = true
	task.spawn(function()
		self:ScanForClosestRift()
	end)
end

function CorruptionScanner:OnUnequip()
	self.Equipped = false
	Client.Interface.CorruptionScanner.Visible = false
end

return CorruptionScanner