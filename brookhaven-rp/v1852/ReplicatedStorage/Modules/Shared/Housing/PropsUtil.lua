local PropsUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
PropsUtil.VIP_EXTRA_PROPS = 5
PropsUtil.PUBLIC_PROP_BASE = 15
PropsUtil.PUBLIC_PROP_INCREMENT = 10
PropsUtil.PUBLIC_PROP_MAX = 45
PropsUtil.PUBLIC_PROP_MAX_VIP = 50
PropsUtil.PUBLIC_PROP_LIMIT_UNLOCK_ICON = "rbxassetid://84437599197875"
PropsUtil.DEBUG_PROP_LIMIT_ATTR = "DebugPropLimitOverride"

function PropsUtil.GetDebugPropLimitOverride()
	local attribute = Workspace:GetAttribute(PropsUtil.DEBUG_PROP_LIMIT_ATTR)

	if typeof(attribute) == "number" then
		return (math.floor(attribute))
	end

	return nil
end

function PropsUtil.ComputePublicLimit(p: number, flag: boolean)
	local PUBLIC_PROP_BASE = PropsUtil.PUBLIC_PROP_BASE

	if flag then
		PUBLIC_PROP_BASE += PropsUtil.VIP_EXTRA_PROPS
	end

	local v = PUBLIC_PROP_BASE + p * PropsUtil.PUBLIC_PROP_INCREMENT
	local v2

	if flag then
		v2 = PropsUtil.PUBLIC_PROP_MAX_VIP
	else
		v2 = PropsUtil.PUBLIC_PROP_MAX
	end

	return (math.min(v, v2))
end

function PropsUtil.GetPlacementFolder()
	local workspaceCom = Workspace:FindFirstChild("WorkspaceCom")

	if workspaceCom == nil then
		return nil
	end

	return workspaceCom:FindFirstChild("001_TrafficCones")
end

function PropsUtil.CollectHouseProps(p: number)
	local placementFolder = PropsUtil.GetPlacementFolder()

	if placementFolder == nil then
		return {}
	end

	local property = LotUtil.GetProperty(p)

	if not property then
		return {}
	end

	local boundingBox, v = property:GetBoundingBox()
	local v2 = v.X / 2
	local v3 = v.Z / 2
	local models = {}

	for _, model in placementFolder:GetChildren() do
		if not model:IsA("Model") then
			continue
		end

		local primaryPart = model.PrimaryPart

		if primaryPart == nil then
			continue
		end

		local pointToObjectSpace = boundingBox:PointToObjectSpace(primaryPart.Position)

		if not (math.abs(pointToObjectSpace.X) <= v2 and math.abs(pointToObjectSpace.Z) <= v3) then
			continue
		end

		table.insert(models, model)
	end

	table.sort(models, function(a, b)
		local id = a:GetAttribute("id")
		local id2 = b:GetAttribute("id")

		if id == id2 then
			return (a:GetAttribute("PlacedAt") or 0) < (b:GetAttribute("PlacedAt") or 0)
		end

		return tostring(id) < tostring(id2)
	end)
	return models
end

function PropsUtil.CountOutsideHouseProps(p)
	local placementFolder = PropsUtil.GetPlacementFolder()

	if placementFolder == nil then
		return 0
	end

	local v = {}
	local playerOwnedLotNumber = LotUtil.GetPlayerOwnedLotNumber(p)

	if playerOwnedLotNumber ~= nil then
		for _, v2 in PropsUtil.CollectHouseProps(playerOwnedLotNumber) do
			v[v2] = true
		end
	end

	local v2 = GameUtil.IsPrivateServer() == true
	local v3 = "Prop" .. p.Name
	local count = 0

	for _, model in placementFolder:GetChildren() do
		if model:IsA("Model") and v[model] ~= true and (v2 or model.Name == v3) then
			count += 1
		end
	end

	return count
end

return PropsUtil