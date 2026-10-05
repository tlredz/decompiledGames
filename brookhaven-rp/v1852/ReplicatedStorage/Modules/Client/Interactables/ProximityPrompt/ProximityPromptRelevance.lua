local ProximityPromptRelevance = {}
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- equivalent calls inferred from this helper; original call sites unknown
local function getDistanceScore(magnitude: number, maxDistance: number)
	if maxDistance <= 0 then
		return 0
	end

	return 1 - math.clamp(magnitude / maxDistance, 0, 1)
end

local function getCenterScore(vector: Vector3, camera)
	local worldToViewportPoint, v = camera:WorldToViewportPoint(vector)

	if not v or worldToViewportPoint.Z <= 0 then
		return 0
	end

	local viewportSize = camera.ViewportSize

	if viewportSize.X <= 0 or viewportSize.Y <= 0 then
		return 0
	end

	local v2 = worldToViewportPoint.X / viewportSize.X * 2 - 1
	local v3 = worldToViewportPoint.Y / viewportSize.Y * 2 - 1
	return (1 - math.clamp(math.sqrt(v2 * v2 + v3 * v3) / 1.4142135623730951, 0, 1)) ^ 1.35
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getClearScore(vector: Vector3, camera, filterDescendantsInstances)
	local position = camera.CFrame.Position
	local v = vector - position
	local magnitude = v.Magnitude

	if magnitude <= 0 then
		return 1
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = Workspace:Raycast(position, v, raycastParams)

	if raycastResult == nil then
		return 1
	end

	local magnitude2 = (raycastResult.Position - position).Magnitude

	if magnitude - 1 <= magnitude2 then
		return 1
	end

	return 0.15
end

local function isMouseOverTarget(model, vector: Vector3, camera, maxDistance: number, filterDescendantsInstances)
	if not UserInputService.MouseEnabled then
		return 0
	end

	local v = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local worldToViewportPoint, v2 = camera:WorldToViewportPoint(vector)

	if v2 and worldToViewportPoint.Z > 0 then
		local v3 = v.X - worldToViewportPoint.X
		local v4 = v.Y - worldToViewportPoint.Y
		local v5 = math.sqrt(v3 * v3 + v4 * v4)

		if v5 <= 96 then
			return 1 - v5 / 96
		end
	end

	local viewportPointToRay = camera:ViewportPointToRay(v.X, v.Y)
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = Workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * maxDistance,
		raycastParams
	)

	if raycastResult == nil then
		return 0
	end

	if raycastResult.Instance == model or raycastResult.Instance:IsDescendantOf(model) or model:IsA("Model") and raycastResult.Instance:IsDescendantOf(model) then
		return 1
	end

	return 0
end

function ProximityPromptRelevance.Score(vector: Vector3, data, options, p)
	local filterDescendantsInstances = options or {}
	local distanceScore = getDistanceScore((vector - data.playerPosition).Magnitude, data.maxDistance) -- equivalent call inferred; original call site unknown
	local centerScore = getCenterScore(vector, data.camera)
	local clearScore = getClearScore(vector, data.camera, filterDescendantsInstances) -- equivalent call inferred; original call site unknown
	local v2 = p == nil and 0 or isMouseOverTarget(p, vector, data.camera, data.maxDistance, filterDescendantsInstances)
	return distanceScore * 0.25 + centerScore * 0.65 + clearScore * 0.1 + v2 * 2.5
end

return ProximityPromptRelevance