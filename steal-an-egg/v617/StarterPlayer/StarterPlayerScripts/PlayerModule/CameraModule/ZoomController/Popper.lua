local Players = game:GetService("Players")
local commonUtils = script.Parent.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local CameraWrapper = require(commonUtils:WaitForChild("CameraWrapper"))
local ConnectionUtil = require(commonUtils:WaitForChild("ConnectionUtil"))
local userFlag = FlagUtil.getUserFlag("UserCurrentCameraUpdate2")
local userFlag2 = FlagUtil.getUserFlag("UserPlayerConnectionMemoryLeak")
local v

if userFlag then
	v = CameraWrapper.new()
else
	v = nil
end

local currentCamera

if userFlag then
	currentCamera = nil
else
	currentCamera = game.Workspace.CurrentCamera
end

if userFlag then
	v:Enable()
end

local min = math.min
local tan = math.tan
local rad = math.rad
local _ = Ray.new
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.CollisionGroup = "Players"
local raycastParams2 = RaycastParams.new()
raycastParams2.IgnoreWater = true
raycastParams2.FilterType = Enum.RaycastFilterType.Include
local v2

if userFlag2 then
	v2 = ConnectionUtil.new()
else
	v2 = nil
end

local v3 = nil
local v4 = 1e999
local v5 = ""
local v6 = nil
local v7 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function _debugResetLimiter()
	v3 = nil
	v4 = 1e999
	v5 = ""
	v6 = nil
	v7 = nil
end

local function _debugConsiderLimiter(_, _, _, _, _) end

local function _debugFlushLimiter(_, _) end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTotalTransparency(p)
	return 1 - (1 - p.Transparency) * (1 - p.LocalTransparencyModifier)
end

local function eraseFromEnd(list, p)
	for i = #list, p + 1, -1 do
		list[i] = nil
	end
end

local v8 = nil
local v9 = nil
local nearPlaneZ

if userFlag then
	local function updateProjection()
		local camera = v:getCamera()
		local v10 = rad(camera.FieldOfView)
		local viewportSize = camera.ViewportSize
		local v11 = viewportSize.X / viewportSize.Y
		v9 = tan(v10 / 2) * 2
		v8 = v11 * v9
	end

	v:Connect("FieldOfView", updateProjection)
	v:Connect("ViewportSize", updateProjection)
	local camera = v:getCamera()
	local fieldOfView = rad(camera.FieldOfView)
	local viewportSize = camera.ViewportSize
	local v10 = viewportSize.X / viewportSize.Y
	v9 = tan(fieldOfView / 2) * 2
	v8 = v10 * v9
	nearPlaneZ = v:getCamera().NearPlaneZ
	v:Connect("NearPlaneZ", function()
		nearPlaneZ = v:getCamera().NearPlaneZ
	end)
else
	local function updateProjection()
		local v10 = rad(currentCamera.FieldOfView)
		local viewportSize = currentCamera.ViewportSize
		local v11 = viewportSize.X / viewportSize.Y
		v9 = tan(v10 / 2) * 2
		v8 = v11 * v9
	end

	currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(updateProjection)
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateProjection)
	local fieldOfView = rad(currentCamera.FieldOfView)
	local viewportSize = currentCamera.ViewportSize
	local v10 = viewportSize.X / viewportSize.Y
	v9 = tan(fieldOfView / 2) * 2
	v8 = v10 * v9
	nearPlaneZ = currentCamera.NearPlaneZ
	currentCamera:GetPropertyChangedSignal("NearPlaneZ"):Connect(function()
		nearPlaneZ = currentCamera.NearPlaneZ
	end)
end

local filterDescendantsInstances = {}
local v11 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshIgnoreList()
	local v12 = 1
	filterDescendantsInstances = {}

	for _, v13 in pairs(v11) do
		filterDescendantsInstances[v12] = v13
		v12 += 1
	end
end

local function playerAdded(player)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterAdded(character)
		v11[player] = character
		refreshIgnoreList() -- equivalent call inferred; original call site unknown
	end

	local function characterRemoving()
		characterAdded(nil) -- equivalent call inferred; original call site unknown
	end

	if userFlag2 then
		v2:trackConnection(`{player.UserId}CharacterAdded`, player.CharacterAdded:Connect(characterAdded))
		v2:trackConnection(`{player.UserId}CharacterRemoving`, player.CharacterRemoving:Connect(characterRemoving))
	else
		player.CharacterAdded:Connect(characterAdded)
		player.CharacterRemoving:Connect(characterRemoving)
	end

	if player.Character then
		characterAdded(player.Character) -- equivalent call inferred; original call site unknown
	end
end

local function playerRemoving(p)
	v11[p] = nil
	refreshIgnoreList() -- equivalent call inferred; original call site unknown

	if userFlag2 then
		v2:disconnect((`{p.UserId}CharacterAdded`))
		v2:disconnect((`{p.UserId}CharacterRemoving`))
	end
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

for _, v12 in ipairs(Players:GetPlayers()) do
	playerAdded(v12)
end

refreshIgnoreList() -- equivalent call inferred; original call site unknown
local rootPart = nil
local rootPart2 = nil

if userFlag then
	v:Connect("CameraSubject", function()
		local cameraSubject = v:getCamera().CameraSubject

		if cameraSubject and cameraSubject:IsA("Humanoid") then
			rootPart2 = cameraSubject.RootPart
		elseif cameraSubject and cameraSubject:IsA("BasePart") then
			rootPart2 = cameraSubject
		else
			rootPart2 = nil
		end
	end)
else
	currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		local cameraSubject = currentCamera.CameraSubject

		if cameraSubject:IsA("Humanoid") then
			rootPart2 = cameraSubject.RootPart
		elseif cameraSubject:IsA("BasePart") then
			rootPart2 = cameraSubject
		else
			rootPart2 = nil
		end
	end)
end

local function canOcclude(trussPart)
	local canCollide

	if getTotalTransparency(trussPart) < 0.25 then
		canCollide = trussPart.CanCollide

		if canCollide then
			if rootPart == (trussPart:GetRootPart() or trussPart) then
				canCollide = false
			else
				canCollide = not trussPart:IsA("TrussPart")
			end
		end
	else
		canCollide = false
	end

	return canCollide
end

local v12 = {
	Vector2.new(0.4, 0),
	Vector2.new(-0.4, 0),
	Vector2.new(0, -0.4),
	Vector2.new(0, 0.4),
	Vector2.new(0, 0.2)
}

local function getCollisionPoint(p, p2)
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances

	while true do
		local raycastResult = workspace:Raycast(p, p2, raycastParams)

		if raycastResult then
			if raycastResult.Instance.CanCollide then
				return raycastResult.Position, true
			else
				raycastParams:AddToFilter(raycastResult.Instance)
			end
		end

		if not raycastResult then
			return p + p2, false
		end
	end
end

local function queryPoint(p, p2, p3, p4)
	debug.profilebegin("queryPoint")
	local _ = #filterDescendantsInstances
	local v13 = p3 + nearPlaneZ
	local v14 = p + p2 * v13
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local v15 = p
	local count = 0
	local v16 = 1e999
	local v17 = 1e999

	while true do
		local raycastResult = workspace:Raycast(v15, v14 - v15, raycastParams)

		if not raycastResult then
			break
		end

		count += 1
		local instance = raycastResult.Instance
		local position = raycastResult.Position
		local magnitude = (position - p).Magnitude

		if count >= 64 then
			local _ = magnitude - nearPlaneZ
			v17 = magnitude
		else
			local canCollide

			if getTotalTransparency(instance) < 0.25 then
				canCollide = instance.CanCollide

				if canCollide then
					if rootPart == (instance:GetRootPart() or instance) then
						canCollide = false
					else
						canCollide = not instance:IsA("TrussPart")
					end
				end
			else
				canCollide = false
			end

			if canCollide then
				raycastParams2.FilterDescendantsInstances = { instance }

				if workspace:Raycast(v14, position - v14, raycastParams2) then
					local v18

					if p4 then
						v18 = workspace:Raycast(p4, v14 - p4, raycastParams2) or workspace:Raycast(
							v14,
							p4 - v14,
							raycastParams2
						)
					else
						v18 = false
					end

					if v18 then
						local _ = magnitude - nearPlaneZ
						v17 = magnitude
					elseif v13 < v16 then
						local _ = magnitude - nearPlaneZ
						v16 = magnitude
					end
				else
					local _ = magnitude - nearPlaneZ
					v17 = magnitude
				end
			end
		end

		raycastParams:AddToFilter(instance)
		v15 = position - p2 * 0.001

		if v17 < 1e999 or not instance then
			break
		end
	end

	debug.profileend()
	return v16 - nearPlaneZ, v17 - nearPlaneZ
end

local function queryViewport(data, p)
	debug.profilebegin("queryViewport")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v13 = -data.lookVector
	local v14

	if userFlag then
		v14 = v:getCamera()
	else
		v14 = currentCamera
	end

	currentCamera = v14
	local viewportSize = currentCamera.ViewportSize
	local v15 = 1e999
	local v16 = 1e999

	for i = 0, 1 do
		local v17 = rightVector * ((i - 0.5) * v8)

		for i2 = 0, 1 do
			local v18 = upVector * ((i2 - 0.5) * v9)
			local v20, v21 = queryPoint(
				p2 + nearPlaneZ * (v17 + v18),
				v13,
				p,
				currentCamera:ViewportPointToRay(viewportSize.x * i, viewportSize.y * i2).Origin
			)

			if v21 < v15 then
				v15 = v21
			end

			if v20 < v16 then
				v16 = v20
			end
		end
	end

	debug.profileend()
	return v16, v15
end

local function testPromotion(data, p, data2)
	debug.profilebegin("testPromotion")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v13 = -data.lookVector
	debug.profilebegin("extrapolate")
	local magnitude = (getCollisionPoint(p2, data2.posVelocity * 1.25) - p2).Magnitude
	local magnitude2 = data2.posVelocity.magnitude

	for i = 0, min(1.25, data2.rotVelocity.magnitude + magnitude / magnitude2), 0.0625 do
		local extrapolate = data2.extrapolate(i)

		if p <= queryPoint(extrapolate.p, -extrapolate.lookVector, p) then
			return false
		end
	end

	debug.profileend()
	debug.profilebegin("testOffsets")

	for _, v15 in ipairs(v12) do
		local collisionPoint = getCollisionPoint(p2, rightVector * v15.x + upVector * v15.y)

		if queryPoint(collisionPoint, (p2 + v13 * p - collisionPoint).Unit, p) == 1e999 then
			return false
		end
	end

	debug.profileend()
	debug.profileend()
	return true
end

local function Popper(p, p2, p3)
	debug.profilebegin("popper")
	_debugResetLimiter() -- equivalent call inferred; original call site unknown
	rootPart = rootPart2 and rootPart2:GetRootPart() or rootPart2
	local v13, v14 = queryViewport(p, p2)

	if not (v14 < p2) then
		v14 = p2
	end

	if v13 < v14 and testPromotion(p, p2, p3) then
		v14 = v13
	end

	rootPart = nil
	debug.profileend()
	return v14
end

return Popper