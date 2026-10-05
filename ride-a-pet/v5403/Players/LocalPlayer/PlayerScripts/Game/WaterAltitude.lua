local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local v = {}
local v2 = {}

local function Track(part)
	if not part:IsA("BasePart") or v[part] then
		return
	end

	local highAltitudeShift = tonumber(part:GetAttribute("HighAltitudeShift"))

	if not highAltitudeShift or highAltitudeShift == 0 then
		return
	end

	local altitudeBaseY = tonumber(part:GetAttribute("AltitudeBaseY"))

	if not altitudeBaseY then
		altitudeBaseY = part.Position.Y
		part:SetAttribute("AltitudeBaseY", altitudeBaseY)
	end

	v[part] = {
		BaseY = altitudeBaseY,
		Shift = highAltitudeShift,
		Offset = part.Position.Y - altitudeBaseY,
		VisualOnly = part:GetAttribute("AltitudeVisualOnly") == true
	}
end

local function Untrack(p)
	local v3 = v[p]

	if v3 and v3.Mesh and v3.Mesh.Parent then
		v3.Mesh.Offset = v3.MeshBaseOffset
	end

	v[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TrackSeabed(part)
	if part:IsA("BasePart") and v2[part] == nil then
		v2[part] = 0
	end
end

local function UntrackSeabed(p)
	if v2[p] ~= nil then
		v2[p] = nil
		p.LocalTransparencyModifier = 0
	end
end

CollectionService:GetInstanceAddedSignal("AltitudeSeabed"):Connect(TrackSeabed)
CollectionService:GetInstanceRemovedSignal("AltitudeSeabed"):Connect(UntrackSeabed)

for _, v3 in CollectionService:GetTagged("AltitudeSeabed") do
	TrackSeabed(v3) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("AltitudeWater"):Connect(Track)
CollectionService:GetInstanceRemovedSignal("AltitudeWater"):Connect(Untrack)

for _, v3 in CollectionService:GetTagged("AltitudeWater") do
	Track(v3)
end

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local Y = currentCamera.CFrame.Position.Y

	for k, v3 in v2 do
		if k.Parent then
			local localTransparencyModifier = math.clamp((Y - (k.Position.Y + k.Size.Y / 2) - 140) / 80, 0, 1)

			if localTransparencyModifier ~= v3 then
				v2[k] = localTransparencyModifier
				k.LocalTransparencyModifier = localTransparencyModifier
			end
		else
			v2[k] = nil
		end
	end

	for k, v3 in v do
		if k.Parent then
			local v4 = v3.BaseY + k.Size.Y / 2
			local specialMesh

			if v3.VisualOnly then
				specialMesh = k:FindFirstChildOfClass("SpecialMesh")

				if not specialMesh then
					continue
				end

				if specialMesh ~= v3.Mesh then
					local altitudeBaseOffset = specialMesh:GetAttribute("AltitudeBaseOffset")

					if typeof(altitudeBaseOffset) ~= "Vector3" then
						altitudeBaseOffset = specialMesh.Offset
						specialMesh:SetAttribute("AltitudeBaseOffset", altitudeBaseOffset)
					end

					v3.Mesh = specialMesh
					v3.MeshBaseOffset = altitudeBaseOffset
					v3.Offset = specialMesh.Offset.Y - altitudeBaseOffset.Y
				end

				v4 = v3.BaseY + v3.MeshBaseOffset.Y + k.Size.Y * specialMesh.Scale.Y / 2
			end

			local v5 = math.clamp((Y - v4 - 140) / 80, 0, 1)
			local offset = v3.Shift * v5
			local v7

			if v5 == 0 or v5 == 1 then
				v7 = offset ~= v3.Offset
			else
				v7 = false
			end

			if v7 or math.abs(offset - v3.Offset) >= 0.02 then
				v3.Offset = offset

				if specialMesh then
					specialMesh.Offset = v3.MeshBaseOffset + Vector3.new(0, offset, 0)
				else
					local cFrame = k.CFrame
					k.CFrame = cFrame + Vector3.new(0, v3.BaseY + offset - cFrame.Position.Y, 0)
				end
			end
		else
			v[k] = nil
		end
	end
end)