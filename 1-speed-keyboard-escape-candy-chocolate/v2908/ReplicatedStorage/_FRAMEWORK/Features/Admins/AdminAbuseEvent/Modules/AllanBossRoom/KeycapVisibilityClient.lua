local CollectionService = game:GetService("CollectionService")
local KeycapVisibilityClient = {}
local corrodedMetal = Enum.Material.CorrodedMetal
local color = Color3.fromRGB(255, 0, 0)
local connections = {}
local v = {}

local function corrode(part)
	if part:IsA("BasePart") and v[part] == nil then
		local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
		v[part] = {
			material = part.Material,
			color = part.Color,
			transparency = part.Transparency,
			surfaceAppearance = surfaceAppearance
		}

		if surfaceAppearance then
			surfaceAppearance.Parent = nil
		end

		part.Material = corrodedMetal
		part.Color = color
		part.Transparency = 0.5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRestore(parent, data)
	local surfaceAppearance = parent:FindFirstChildOfClass("SurfaceAppearance")
	local surfaceAppearance2 = data.surfaceAppearance

	if surfaceAppearance2 then
		if surfaceAppearance then
			surfaceAppearance:Destroy()
		end

		surfaceAppearance2.Parent = parent
	elseif surfaceAppearance then
		surfaceAppearance.Color = data.color
	end

	if parent.Parent then
		parent.Material = data.material
		parent.Color = data.color
		parent.Transparency = data.transparency
	end
end

local function restore(part)
	if part:IsA("BasePart") then
		local v2 = v[part]

		if v2 ~= nil then
			v[part] = nil
			applyRestore(part, v2) -- equivalent call inferred; original call site unknown
		end
	end
end

function KeycapVisibilityClient.start(tag: string)
	KeycapVisibilityClient.stop()

	for _, v2 in CollectionService:GetTagged(tag) do
		corrode(v2)
	end

	table.insert(connections, CollectionService:GetInstanceAddedSignal(tag):Connect(corrode))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(tag):Connect(restore))
end

function KeycapVisibilityClient.stop()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)

	for k, v2 in v do
		applyRestore(k, v2) -- equivalent call inferred; original call site unknown
	end

	table.clear(v)
end

return KeycapVisibilityClient