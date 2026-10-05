local Players = game:GetService("Players")
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPoppercamLooseOpacityThreshold")
end)
local v = success and result
local currentCamera = game.Workspace.CurrentCamera
local min = math.min
local tan = math.tan
local rad = math.rad
local new = Ray.new

-- equivalent calls inferred from this helper; original call sites unknown
local function getTotalTransparency(p)
	return 1 - (1 - p.Transparency) * (1 - p.LocalTransparencyModifier)
end

local function eraseFromEnd(list, p)
	for i = #list, p + 1, -1 do
		list[i] = nil
	end
end

local v2 = nil
local v3 = nil

local function updateProjection()
	local v4 = rad(currentCamera.FieldOfView)
	local viewportSize = currentCamera.ViewportSize
	local v5 = viewportSize.X / viewportSize.Y
	v3 = tan(v4 / 2) * 2
	v2 = v5 * v3
end

currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(updateProjection)
currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateProjection)
local fieldOfView = rad(currentCamera.FieldOfView)
local viewportSize = currentCamera.ViewportSize
local v4 = viewportSize.X / viewportSize.Y
v3 = tan(fieldOfView / 2) * 2
v2 = v4 * v3
local nearPlaneZ = currentCamera.NearPlaneZ
currentCamera:GetPropertyChangedSignal("NearPlaneZ"):Connect(function()
	nearPlaneZ = currentCamera.NearPlaneZ
end)
local v5 = {}
do local _values = table.pack(workspace:FindFirstChild("_WorldOrigin"), workspace:FindFirstChild("Enemies")); for _k = 1, _values.n do v5[_k] = _values[_k] end end
local v6 = {}

local function refreshIgnoreList()
	v5 = { workspace:FindFirstChild("_WorldOrigin"), workspace:FindFirstChild("Enemies") }
	local count = #v5

	for _, v7 in pairs(v6) do
		v5[count] = v7
		count += 1
	end
end

local function playerAdded(player)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterAdded(character)
		v6[player] = character
		refreshIgnoreList()
	end

	local function characterRemoving()
		characterAdded(nil) -- equivalent call inferred; original call site unknown
	end

	player.CharacterAdded:Connect(characterAdded)
	player.CharacterRemoving:Connect(characterRemoving)

	if player.Character then
		characterAdded(player.Character) -- equivalent call inferred; original call site unknown
	end
end

local function playerRemoving(p)
	v6[p] = nil
	refreshIgnoreList()
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

for _, v7 in ipairs(Players:GetPlayers()) do
	playerAdded(v7)
end

refreshIgnoreList()
local rootPart = nil
local rootPart2 = nil
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

local function canOcclude(trussPart)
	if v then
		local canCollide

		if getTotalTransparency(trussPart) < 0.25 then
			canCollide = trussPart.CanCollide

			if canCollide then
				if rootPart == (trussPart:GetRootPart() or trussPart) then
					canCollide = false
				else
					canCollide = trussPart.Parent

					if canCollide then
						if trussPart.Parent:FindFirstChild("Humanoid") == nil then
							canCollide = not trussPart:IsA("TrussPart")
						else
							canCollide = false
						end
					end
				end
			end
		else
			canCollide = false
		end

		return canCollide
	else
		local parent

		if trussPart.Transparency < 0.95 then
			parent = trussPart.CanCollide and trussPart.Parent

			if parent then
				if trussPart.Parent:FindFirstChild("Humanoid") == nil then
					parent = rootPart ~= (trussPart:GetRootPart() or trussPart)
				else
					parent = false
				end
			end
		else
			parent = false
		end

		return parent
	end
end

local v7 = {
	Vector2.new(0.4, 0),
	Vector2.new(-0.4, 0),
	Vector2.new(0, -0.4),
	Vector2.new(0, 0.4),
	Vector2.new(0, 0.2)
}

local function getCollisionPoint(p, p2)
	local count = #v5

	while true do
		local part, v8 = workspace:FindPartOnRayWithIgnoreList(new(p, p2), v5, false, true)

		if part then
			if part.CanCollide then
				local v9 = v5

				for i = #v9, count + 1, -1 do
					v9[i] = nil
				end

				return v8, true
			else
				v5[#v5 + 1] = part
			end
		end

		if part then
			continue
		end

		local v9 = v5

		for i = #v9, count + 1, -1 do
			v9[i] = nil
		end

		return p + p2, false
	end
end

local function queryPoint(p, p2, p3, p4)
	debug.profilebegin("queryPoint")
	local v8 = #v5
	local v9 = p3 + nearPlaneZ
	local v10 = p + p2 * v9
	local v11 = p
	local v12 = 1e999
	local v13 = 1e999

	while true do
		local part, v14 = workspace:FindPartOnRayWithIgnoreList(new(v11, v10 - v11), v5, false, true)

		if part then
			if canOcclude(part) then
				local v15 = { part }
				local part2 = workspace:FindPartOnRayWithWhitelist(new(v10, v14 - v10), v15, true)
				local magnitude = (v14 - p).Magnitude

				if part2 then
					local v16

					if p4 then
						v16 = workspace:FindPartOnRayWithWhitelist(new(p4, v10 - p4), v15, true) or workspace:FindPartOnRayWithWhitelist(
							new(v10, p4 - v10),
							v15,
							true
						)
					else
						v16 = false
					end

					if v16 then
						v12 = magnitude
					elseif v9 < v13 then
						v13 = magnitude
					end
				else
					v12 = magnitude
				end
			end

			v5[#v5 + 1] = part
			v11 = v14 - p2 * 0.001
		end

		if not (v12 < 1e999 or not part) then
			continue
		end

		local v15 = v5

		for i = #v15, v8 + 1, -1 do
			v15[i] = nil
		end

		debug.profileend()
		return v13 - nearPlaneZ, v12 - nearPlaneZ
	end
end

local function queryViewport(data, p)
	debug.profilebegin("queryViewport")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v8 = -data.lookVector
	local viewportSize2 = currentCamera.ViewportSize
	local v9 = 1e999
	local v10 = 1e999

	for i = 0, 1 do
		local v11 = rightVector * ((i - 0.5) * v2)

		for i2 = 0, 1 do
			local v12 = upVector * ((i2 - 0.5) * v3)
			local v14, v15 = queryPoint(
				p2 + nearPlaneZ * (v11 + v12),
				v8,
				p,
				currentCamera:ViewportPointToRay(viewportSize2.x * i, viewportSize2.y * i2).Origin
			)

			if v15 < v9 then
				v9 = v15
			end

			if v14 < v10 then
				v10 = v14
			end
		end
	end

	debug.profileend()
	return v10, v9
end

local function testPromotion(data, p, data2)
	debug.profilebegin("testPromotion")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v8 = -data.lookVector
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

	for _, v10 in ipairs(v7) do
		local collisionPoint, _ = getCollisionPoint(p2, rightVector * v10.x + upVector * v10.y)

		if queryPoint(collisionPoint, (p2 + v8 * p - collisionPoint).Unit, p) == 1e999 then
			return false
		end
	end

	debug.profileend()
	debug.profileend()
	return true
end

local function Popper(p, p2, p3)
	debug.profilebegin("popper")
	rootPart = rootPart2 and rootPart2:GetRootPart() or rootPart2
	local v8, v9 = queryViewport(p, p2)

	if not (v9 < p2) then
		v9 = p2
	end

	if v8 < v9 and testPromotion(p, p2, p3) then
		v9 = v8
	end

	rootPart = nil
	debug.profileend()
	return v9
end

return Popper