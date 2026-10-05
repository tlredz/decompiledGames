local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.ServerInfo)
local v = { "MoonMap", "ZeroGravityArena" }

local function getModelMass(folder)
	local total = 0

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			total += part:GetMass()
		end
	end

	return total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isLowGravityMap()
	local currentlySelectedMap = workspace:GetAttribute("CurrentlySelectedMap")

	if currentlySelectedMap and table.find(v, currentlySelectedMap) then
		return true
	end

	return false
end

return {
	ChildrenOf = { workspace.Alive },
	Callback = function(character)
		if not (Players:GetPlayerFromCharacter(character) and isLowGravityMap()) then
			return
		end

		local primaryPart = character.PrimaryPart

		if primaryPart:FindFirstChild("LowGravity") then
			return
		end

		local connections = {}
		local bodyForce = Instance.new("BodyForce")
		bodyForce.Name = "LowGravity"
		bodyForce.Force = Vector3.new(0, getModelMass(character) * workspace.Gravity * 0.5, 0)
		bodyForce.Parent = primaryPart

		local function destroyBodyForces()
			if bodyForce then
				bodyForce:Destroy()
				bodyForce = nil
			end

			for _, connection in ipairs(connections) do
				if connection.Connected then
					connection:Disconnect()
				end
			end

			table.clear(connections)
		end

		table.insert(connections, workspace:GetAttributeChangedSignal("CurrentlySelectedMap"):Once(function()
			local currentlySelectedMap = workspace:GetAttribute("CurrentlySelectedMap")

			if not (currentlySelectedMap and table.find(v, currentlySelectedMap)) then
				destroyBodyForces()
			end
		end))
		table.insert(connections, character:GetAttributeChangedSignal("Dead"):Once(destroyBodyForces))
		return destroyBodyForces
	end
}