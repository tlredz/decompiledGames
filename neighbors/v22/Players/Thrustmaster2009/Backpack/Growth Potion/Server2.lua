local Network = require(game.ServerStorage.Modules.Network)
local v = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function getPartVolume(state)
	local size = state.Size
	return size.X * size.Y * size.Z
end

local function setPartMass(part, p)
	local customPhysicalProperties = part.CustomPhysicalProperties or PhysicalProperties.new(part.Material)
	local _ = customPhysicalProperties.Density
	local friction = customPhysicalProperties.Friction
	local elasticity = customPhysicalProperties.Elasticity
	local frictionWeight = customPhysicalProperties.FrictionWeight
	local elasticityWeight = customPhysicalProperties.ElasticityWeight
	local v2 = math.clamp(p / getPartVolume(part), 0.01, 100)
	part.CustomPhysicalProperties = PhysicalProperties.new(v2, friction, elasticity, frictionWeight, elasticityWeight)
end

return {
	Cooldown = 2,
	Init = function(self)
		self.CleanupStates = {}
		self:AddStates(self.DisabledStates, "Bonked", "Ragdoll")
		self.LastUpdate = -1e999
		local massesByName = {}
		local flag = false

		for _, part in self.Player.Character:GetChildren() do
			if part:IsA("BasePart") then
				massesByName[part.Name] = part.Mass
			end
		end

		self.Tool.UpdateScale.OnServerEvent:connect(function(player, growthScale)
			if self:IsBackpackDisabled() or self.LastUpdate + 1.5 > tick() then
				return
			end

			local character = self.Player.Character

			if player.Character ~= character then
				return
			end

			local humanoid = character.Humanoid

			if typeof(growthScale) ~= "number" or growthScale > 4 or growthScale < 0.35 then
				return
			end

			if v > 48 then
				if flag then
					return
				end

				flag = true
				task.delay(6, function()
					flag = false
				end)
				return Network:fire(
					"DisplayError",
					player,
					"Rate limited! Please wait a second before trying this again.",
					6
				)
			else
				v += 1

				if not humanoid:FindFirstChild("HeadScale") then
					return Network:fire("DisplayText", player, "The Growth potion only works on R15 character!", 5)
				end

				if character:GetAttribute("GrowthScale") == growthScale then
					return
				end

				local v2 = growthScale / (character:GetAttribute("GrowthScale") or 1)
				character:SetAttribute("GrowthScale", growthScale)
				humanoid.BodyDepthScale.Value *= v2
				humanoid.BodyHeightScale.Value *= v2
				humanoid.BodyWidthScale.Value *= v2
				humanoid.HeadScale.Value *= v2

				for _, part in self.Player.Character:GetChildren() do
					if part:IsA("BasePart") then
						setPartMass(part, massesByName[part.Name])
					end
				end

				local seatPart = humanoid.SeatPart

				if seatPart and seatPart.Parent:FindFirstChild("JetpackHandler") then
					local parent = seatPart.Parent

					for _, part in parent:GetDescendants() do
						if part:IsA("BasePart") and part:CanSetNetworkOwnership() then
							part:SetNetworkOwner(game.Players:GetPlayerFromCharacter(parent.Parent))
						end
					end
				end

				self.LastUpdate = tick()
			end
		end)
		task.spawn(function()
			while task.wait(1) and self.Tool do
				v = math.max(0, v - 3)
			end
		end)
	end
}