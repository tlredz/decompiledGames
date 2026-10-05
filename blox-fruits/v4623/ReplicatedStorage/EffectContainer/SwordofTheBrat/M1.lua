local RunService = game:GetService("RunService")
local v = {
	"Center",
	"Blade1",
	"Blade2",
	"Blade3",
	"Blade4",
	"Blade5",
	"Blade6"
}
local transforms = {}
local v2 = {}
local v3 = {}
local v4 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothstep(value)
	local v5 = math.clamp(value, 0, 1)
	return v5 * v5 * (3 - 2 * v5)
end

local function getChain(instance)
	local handle = instance:FindFirstChild("Handle", true)

	if not handle then
		return nil
	end

	local handles = {}

	for _, childName in ipairs(v) do
		handle = handle:FindFirstChild(childName)

		if not handle then
			break
		end

		table.insert(handles, handle)
	end

	return handles
end

local function findBlades(folder)
	local parents = {}

	if not folder then
		return parents
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name == "Handle" and descendant:FindFirstChild("Center") then
			table.insert(parents, descendant.Parent)
		end
	end

	return parents
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getAlpha(i, p)
	if p <= 1 then
		return 1
	end

	return ((i - 1) / (p - 1)) ^ 1.35
end

local function makeOverlapParams(_, p)
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.RespectCanCollide = false
	local filterDescendantsInstances = {}

	if workspace:FindFirstChild("Characters") then
		table.insert(filterDescendantsInstances, workspace.Characters)
	end

	if workspace:FindFirstChild("Enemies") then
		table.insert(filterDescendantsInstances, workspace.Enemies)
	end

	if workspace:FindFirstChild("Hitboxes") then
		table.insert(filterDescendantsInstances, workspace.Hitboxes)
	end

	if p and workspace:FindFirstChild("Map") then
		table.insert(filterDescendantsInstances, workspace.Map)
	end

	overlapParams.FilterDescendantsInstances = filterDescendantsInstances
	return overlapParams
end

local function isValidTargetPart(part, ancestor, p)
	if not part or not part:IsA("BasePart") or not part.Parent or part:IsDescendantOf(ancestor) then
		return false
	end

	local hitboxes = workspace:FindFirstChild("Hitboxes")

	if hitboxes and part:IsDescendantOf(hitboxes) then
		return true
	end

	local map = workspace:FindFirstChild("Map")

	if p and map and part:IsDescendantOf(map) then
		return true
	end

	local model = part:FindFirstAncestorOfClass("Model")

	if not (model and model ~= ancestor) then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return not (humanoid.Health <= 0)
	end

	return false
end

local function pointTouchingTarget(p, p2, p3, p4, p5)
	local partBoundsInRadius = workspace:GetPartBoundsInRadius(p, p4, p3)

	for _, v5 in ipairs(partBoundsInRadius) do
		if not isValidTargetPart(v5, p2, p5) then
			continue
		end

		if v4 then
			print("[SwordofTheBrat.M1] touching:", v5:GetFullName())
		end

		return true
	end

	return false
end

local function boneSegmentTouchingTarget(p, p2, p3, overlapParams, p4, p5)
	local worldPosition = p.WorldPosition
	local worldPosition2

	if p2 then
		worldPosition2 = p2.WorldPosition or worldPosition
	else
		worldPosition2 = worldPosition
	end

	if (worldPosition2 - worldPosition).Magnitude <= 0.01 then
		return (pointTouchingTarget(worldPosition, p3, overlapParams, p4, p5))
	end

	for i = 0, 5 do
		if pointTouchingTarget(worldPosition:Lerp(worldPosition2, i / 5), p3, overlapParams, p4, p5) then
			return true
		end
	end

	return false
end

local function springTowards(state, p, p2, p3, p4)
	local v5 = (p - state.angle) * p2
	state.velocity += v5 * p4
	state.velocity *= math.exp(-p3 * p4)
	state.angle += state.velocity * p4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBoneTransform(p, angle, p2)
	p.Transform = transforms[p] * CFrame.Angles(angle * 0.1 * p2, 0, angle * p2)
end

local function resetBlade(instance, chain)
	if v2[instance] then
		v2[instance]:Disconnect()
		v2[instance] = nil
	end

	for _, v5 in ipairs(chain) do
		if transforms[v5] then
			v5.Transform = transforms[v5]
		end
	end

	local v5 = v3[instance]

	if v5 then
		for _, v6 in pairs(v5) do
			v6.angle = 0
			v6.velocity = 0
			v6.contactUntil = 0
		end
	end
end

local function watchBlade(blade, character, bendAngle, hitBendAngle, window, contactRadius, includeMap)
	local chain = getChain(blade)

	if not chain or #chain <= 0 then
		warn("[SwordofTheBrat.M1] No bone chain found in:", blade:GetFullName())
		return
	end

	if v2[blade] then
		v2[blade]:Disconnect()
		v2[blade] = nil
	end

	local handle = blade:FindFirstChild("Handle", true)

	if not handle then
		return
	end

	local v5 = v3[blade]

	if not v5 then
		v5 = {}
		v3[blade] = v5
	end

	for _, v6 in ipairs(chain) do
		if transforms[v6] == nil then
			transforms[v6] = v6.Transform
		end

		if v5[v6] then
			v5[v6].angle = 0
			v5[v6].velocity = 0
			v5[v6].contactUntil = 0
		else
			v5[v6] = {
				angle = 0,
				velocity = 0,
				contactUntil = 0
			}
		end
	end

	local overlapParams = makeOverlapParams(character, includeMap)
	local now = os.clock()
	local v6 = chain[#chain]
	local pointToObjectSpace = handle.CFrame:PointToObjectSpace(v6.WorldPosition)
	local pointToWorldSpace = handle.CFrame:PointToWorldSpace(pointToObjectSpace)
	local total = 0
	local v7 = 1
	v2[blade] = RunService.RenderStepped:Connect(function(dt)
		if not (blade and blade.Parent) then
			resetBlade(blade, chain)
			return
		end

		if not (character and character.Parent) then
			resetBlade(blade, chain)
			return
		end

		if not (handle and handle.Parent) then
			resetBlade(blade, chain)
			return
		end

		local now2 = os.clock()
		local v8 = now2 - now
		local v9 = v8 <= window
		local v10 = true
		local pointToWorldSpace2 = handle.CFrame:PointToWorldSpace(pointToObjectSpace)
		local v11 = (pointToWorldSpace2 - pointToWorldSpace) / math.max(dt, 0.004166666666666667)
		pointToWorldSpace = pointToWorldSpace2
		local vectorToObjectSpace = handle.CFrame:VectorToObjectSpace(v11)
		local v12 = math.clamp(-vectorToObjectSpace.X / 42, -1, 1)
		local v13 = math.abs(vectorToObjectSpace.X) < 3 and 0 or v12
		total += (v13 - total) * math.clamp(dt * 18, 0, 1)

		if math.abs(total) > 0.08 then
			v7 = total > 0 and 1 or -1
		end

		local v14 = math.abs(total) > 0.05 and total or v7

		for i, v15 in ipairs(chain) do
			local v16 = v5[v15]
			local alpha = getAlpha(i, #chain)
			local v18 = chain[i + 1]

			if v9 and boneSegmentTouchingTarget(v15, v18, character, overlapParams, contactRadius, includeMap) then
				v16.contactUntil = now2 + 0.11
			end

			local v19 = v9 and now2 < v16.contactUntil
			local v20 = v8 - alpha * 0.035
			local v21 = smoothstep(v20 / 0.055) -- equivalent call inferred; original call site unknown
			local v22 = v21 * (1 - smoothstep((v20 - 0.055) / 0.28))
			local v23

			if v9 and v19 then
				v23 = hitBendAngle * alpha
			else
				v23 = not v9 and 0 or bendAngle * alpha * v22
			end

			local v24 = (v23 - v16.angle) * (v19 and 85 or 52)
			v16.velocity += v24 * dt
			v16.velocity *= math.exp(-(v19 and 12 or 9) * dt)
			v16.angle += v16.velocity * dt
			applyBoneTransform(v15, v16.angle, v14) -- equivalent call inferred; original call site unknown

			if not (math.abs(v16.angle) > 0.002 or math.abs(v16.velocity) > 0.002) then
				continue
			end

			v10 = false
		end

		if not v9 and v10 then
			for _, v15 in ipairs(chain) do
				v15.Transform = transforms[v15]
				local v16 = v5[v15]

				if not v16 then
					continue
				end

				v16.angle = 0
				v16.velocity = 0
				v16.contactUntil = 0
			end

			v2[blade]:Disconnect()
			v2[blade] = nil
		end
	end)
end

return function(options)
	local v5 = options or {}
	local character = v5.Character
	local bendAngle = v5.BendAngle or 0.3141592653589793
	local hitBendAngle = v5.HitBendAngle or 1.6580627893946132
	local window = v5.Window or 0.3
	local contactRadius = v5.ContactRadius or 1.35
	local includeMap = v5.IncludeMap == true
	v4 = v5.Debug == true

	if not character then
		warn("[SwordofTheBrat.M1] Missing Character")
		return
	end

	local equippedWeapon = character:FindFirstChild("EquippedWeapon")

	if not equippedWeapon then
		warn("[SwordofTheBrat.M1] No EquippedWeapon found in character")
		return
	end

	local blades = findBlades(equippedWeapon)

	if #blades <= 0 then
		warn("[SwordofTheBrat.M1] No blade found inside EquippedWeapon:", equippedWeapon:GetFullName())
		return
	end

	for _, blade in ipairs(blades) do
		watchBlade(blade, character, bendAngle, hitBendAngle, window, contactRadius, includeMap)
	end
end