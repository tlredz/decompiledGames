local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local PropsUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropsUtil)
local VehicleAttachedProps = {
	IsOwnedBy = function(instance, p)
		local player = instance:GetAttribute("Player")

		if typeof(player) == "number" then
			return player == p.UserId
		end

		return instance.Name == "Prop" .. p.Name
	end,
	IsAttachedToVehicle = function(instance, ancestor)
		local propWeldConstraint = instance:FindFirstChild("PropWeldConstraint")

		if propWeldConstraint == nil or propWeldConstraint:IsA("WeldConstraint") == false then
			return false
		end

		local part1 = propWeldConstraint.Part1
		return part1 ~= nil and (part1 == ancestor or part1:IsDescendantOf(ancestor))
	end,
	GetWeldTargetVehicle = function(instance)
		local propWeldConstraint = instance:FindFirstChild("PropWeldConstraint")

		if propWeldConstraint == nil or propWeldConstraint:IsA("WeldConstraint") == false then
			return nil
		end

		local part1 = propWeldConstraint.Part1

		if part1 == nil then
			return nil
		end

		local vehicles = Workspace:FindFirstChild("Vehicles")

		if vehicles == nil or part1 ~= vehicles and part1:IsDescendantOf(vehicles) == false then
			return nil
		end

		while part1.Parent ~= nil and part1.Parent ~= vehicles do
			part1 = part1.Parent
		end

		if part1.Parent == vehicles and part1:IsA("Model") ~= false then
			return part1
		end

		return nil
	end
}

function VehicleAttachedProps.IsAttachedToOwnedVehicle(p, p2)
	local weldTargetVehicle = VehicleAttachedProps.GetWeldTargetVehicle(p)

	if weldTargetVehicle == nil then
		return false
	end

	local owner = weldTargetVehicle:FindFirstChild("Owner")
	return owner ~= nil and owner:IsA("StringValue") ~= false and owner.Value == p2.Name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlacedAt(instance)
	local placedAt = instance:GetAttribute("PlacedAt")

	if typeof(placedAt) == "number" then
		return placedAt
	end

	return 0
end

function VehicleAttachedProps.CollectAttachedToVehicle(p, p2)
	local placementFolder = PropsUtil.GetPlacementFolder()

	if placementFolder == nil then
		return {}
	end

	local models = {}

	for _, model in placementFolder:GetChildren() do
		if not (model:IsA("Model") ~= false and model.PrimaryPart ~= nil and VehicleAttachedProps.IsOwnedBy(model, p2) == true) then
			continue
		end

		if not VehicleAttachedProps.IsAttachedToVehicle(model, p) then
			continue
		end

		table.insert(models, model)
	end

	return models
end

function VehicleAttachedProps.CollectOwnedVehicleProps(p)
	local placementFolder = PropsUtil.GetPlacementFolder()

	if placementFolder == nil then
		return {}
	end

	local models = {}

	for _, model in placementFolder:GetChildren() do
		if not (model:IsA("Model") ~= false and model.PrimaryPart ~= nil and VehicleAttachedProps.IsOwnedBy(model, p) == true) then
			continue
		end

		if VehicleAttachedProps.IsAttachedToOwnedVehicle(model, p) ~= true then
			continue
		end

		table.insert(models, model)
	end

	table.sort(models, function(a, b)
		local id = a:GetAttribute("id")
		local id2 = b:GetAttribute("id")

		if id ~= id2 then
			return tostring(id) < tostring(id2)
		end

		local placedAt = getPlacedAt(a) -- equivalent call inferred; original call site unknown
		return placedAt < getPlacedAt(b)
	end)
	return models
end

return VehicleAttachedProps