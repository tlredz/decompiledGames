local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local KeycapStreamConfig = require(ReplicatedStorage.Utilities.KeycapsRendering.KeycapStreamConfig)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local cframe = CFrame.new(0, 0.08, 0)
local v = math.ceil(Config.electrifiedDurationSeconds / Config.strikeIntervalSeconds) * Config.maxStrikesPerWave

-- equivalent calls inferred from this helper; original call sites unknown
local function getStreamPosition(vector2: Vector3)
	local positionScale = KeycapStreamConfig.PositionScale
	return Vector3.new(
		math.round(vector2.X * positionScale),
		math.round(vector2.Y * positionScale),
		(math.round(vector2.Z * positionScale))
	) / positionScale
end

local function isSource(part, vector2: Vector3, p)
	local isA = part:IsA("MeshPart")

	if not isA then
		return isA
	end

	if part.Parent == p and part:GetAttribute(KeycapStreamConfig.StreamedAttributeName) == true then
		isA = part:GetAttribute(KeycapStreamConfig.PositionAttributeName) == getStreamPosition(vector2)
	else
		isA = false
	end

	return isA
end

local function clearMetadata(instance)
	for k in instance:GetAttributes() do
		instance:SetAttribute(k, nil)
	end

	for _, tag in instance:GetTags() do
		instance:RemoveTag(tag)
	end
end

local function createCopy(instance)
	local clone = instance:Clone()
	clone.Name = "ElectrifiedKeycap"
	clearMetadata(clone)

	for _, surfaceAppearance in clone:GetChildren() do
		if surfaceAppearance:IsA("SurfaceAppearance") then
			clearMetadata(surfaceAppearance)
			surfaceAppearance:ClearAllChildren()
		else
			surfaceAppearance:Destroy()
		end
	end

	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CastShadow = false
	clone.Material = Enum.Material.Neon
	local attachment = Instance.new("Attachment")
	attachment.Name = "LightingEffects"
	attachment.Parent = clone
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 18
	pointLight.Parent = attachment
	local sparkles = Instance.new("Sparkles")
	sparkles.Parent = attachment
	local highlight = Instance.new("Highlight")
	highlight.Adornee = clone
	highlight.FillTransparency = 0.55
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.OutlineTransparency = 0.25
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = attachment
	return {
		mesh = clone,
		surface = clone:FindFirstChildWhichIsA("SurfaceAppearance"),
		light = pointLight,
		sparks = sparkles,
		highlight = highlight
	}
end

local function matches(p, p2, p3)
	local surface = p.surface
	local v2

	if surface and p3 then
		v2 = surface.Name == p3.Name
	elseif surface == nil then
		v2 = p3 == nil
	else
		v2 = false
	end

	if p.mesh.MeshId == p2.MeshId then
		if p.mesh.TextureID ~= p2.TextureID then
			return false
		end
	else
		return false
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function follow(binding)
	binding.copy.mesh.CFrame = binding.source.CFrame * cframe
	binding.copy.mesh.Size = binding.source.Size * 1.005
	binding.copy.mesh.Transparency = binding.source.Transparency
	binding.copy.mesh.LocalTransparencyModifier = binding.source.LocalTransparencyModifier
end

local function apply(p)
	local binding = p.binding

	if binding then
		local v2 = nil

		for _, strike in p.strikes do
			if not v2 or strike.id > v2.id then
				v2 = strike
			end
		end

		if v2 then
			local copy = binding.copy
			copy.mesh.Color = v2.color

			if copy.surface then
				copy.surface.Color = v2.color
			end

			copy.light.Color = v2.color
			copy.sparks.SparkleColor = v2.color
			copy.highlight.FillColor = v2.color
		end
	end
end

return {
	create = function(parent)
		local folder = Instance.new("Folder")
		folder.Name = "ElectrifiedKeycaps"
		folder.Parent = parent
		local v2 = {}
		local v3 = {}
		local copies = {}
		local v4 = {}
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		local v5 = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function detach(p)
			local binding = p.binding

			if binding then
				binding.copy.mesh.Parent = nil

				if #copies < v then
					table.insert(copies, binding.copy)
				else
					binding.copy.mesh:Destroy()
				end

				p.binding = nil
			end
		end

		local function attach(p, part)
			local surfaceAppearance = part:FindFirstChildWhichIsA("SurfaceAppearance")
			local v6 = nil

			for k, v8 in copies do
				local surface = v8.surface
				local v9

				if surface and surfaceAppearance then
					v9 = surface.Name == surfaceAppearance.Name
				elseif surface == nil then
					v9 = surfaceAppearance == nil
				else
					v9 = false
				end

				if v8.mesh.MeshId == part.MeshId then
					if v8.mesh.TextureID ~= part.TextureID then
						v9 = false
					end
				else
					v9 = false
				end

				if not v9 then
					continue
				end

				v6 = table.remove(copies, k)
				break
			end

			local copy = v6 or createCopy(part)
			p.binding = {
				source = part,
				copy = copy
			}
			follow(p.binding) -- equivalent call inferred; original call site unknown
			apply(p)
			copy.mesh.Parent = folder
		end

		local function findSource(p)
			local keycaps = Workspace:FindFirstChild("Keycaps")

			if keycaps then
				overlapParams.FilterDescendantsInstances = { keycaps }

				for _, part in Workspace:GetPartBoundsInBox(p.cframe, p.size + createVector(0.2, 4, 0.2), overlapParams) do
					local position = p.cframe.Position
					local isA = part:IsA("MeshPart")

					if isA then
						if part.Parent == keycaps and part:GetAttribute(KeycapStreamConfig.StreamedAttributeName) == true then
							isA = part:GetAttribute(KeycapStreamConfig.PositionAttributeName) == getStreamPosition(position)
						else
							isA = false
						end
					end

					if not isA then
						continue
					end

					attach(p, part)
					return
				end
			end
		end

		function v4.add(data)
			if not v3[data.id] then
				local v6 = v2[data.cframe.Position]

				if not v6 then
					v6 = {
						strikes = {},
						binding = nil,
						cframe = data.cframe,
						size = data.size
					}
					v2[data.cframe.Position] = v6
				end

				v3[data.id] = data
				v6.strikes[data.id] = data

				if v6.binding then
					apply(v6)
				else
					findSource(v6)
				end
			end
		end

		function v4.remove(p: number)
			local v6 = v3[p]

			if v6 then
				local v7 = v2[v6.cframe.Position]
				v7.strikes[p] = nil
				v3[p] = nil

				if next(v7.strikes) == nil then
					detach(v7) -- equivalent call inferred; original call site unknown
					v2[v6.cframe.Position] = nil
				else
					apply(v7)
				end
			end
		end

		function v4.update(p: number)
			for k, v6 in v3 do
				if v6.expiresAt <= p then
					v4.remove(k)
				end
			end

			local keycaps = Workspace:FindFirstChild("Keycaps")
			local v6 = v5 <= p

			if v6 then
				v5 = p + Config.keycapCheckIntervalSeconds
			end

			for _, v7 in v2 do
				local binding = v7.binding

				if binding then
					local binding2

					if keycaps then
						local source = binding.source
						local position = v7.cframe.Position
						local isA = source:IsA("MeshPart")

						if isA then
							if source.Parent == keycaps and source:GetAttribute(KeycapStreamConfig.StreamedAttributeName) == true then
								isA = source:GetAttribute(KeycapStreamConfig.PositionAttributeName) == getStreamPosition(position)
							else
								isA = false
							end
						end

						if isA then
							follow(binding) -- equivalent call inferred; original call site unknown
						else
							binding2 = v7.binding

							if binding2 then
								binding2.copy.mesh.Parent = nil

								if #copies < v then
									table.insert(copies, binding2.copy)
								else
									binding2.copy.mesh:Destroy()
								end

								v7.binding = nil
							end
						end
					else
						binding2 = v7.binding

						if binding2 then
							binding2.copy.mesh.Parent = nil

							if #copies < v then
								table.insert(copies, binding2.copy)
							else
								binding2.copy.mesh:Destroy()
							end

							v7.binding = nil
						end
					end
				end

				if v7.binding or not v6 then
					continue
				end

				findSource(v7)
			end
		end

		function v4.destroy()
			for _, v6 in v2 do
				if v6.binding then
					v6.binding.copy.mesh:Destroy()
				end
			end

			for _, v6 in copies do
				v6.mesh:Destroy()
			end

			folder:Destroy()
			table.clear(copies)
			table.clear(v2)
			table.clear(v3)
		end

		return v4
	end
}