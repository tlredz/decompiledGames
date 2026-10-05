local CollectionService = game:GetService("CollectionService")
local KeycapColorClient = {}
local v = nil
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function randomColor(colored)
	if colored and #colored ~= 0 then
		return colored[math.random(#colored)]
	end

	return nil
end

local function applyColor(part)
	if not part:IsA("BasePart") then
		return
	end

	local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")

	if not surfaceAppearance then
		return
	end

	local colored = CollectionService:HasTag(part, v.KeycapColoredTag) and v.KeycapColors.Colored or v.KeycapColors.NonColored
	local color = randomColor(colored) -- equivalent call inferred; original call site unknown

	if color then
		surfaceAppearance.Color = color
	end
end

function KeycapColorClient.start(p)
	KeycapColorClient.stop()
	v = p

	for _, v2 in CollectionService:GetTagged(p.KeycapTag) do
		applyColor(v2)
	end

	table.insert(connections, CollectionService:GetInstanceAddedSignal(p.KeycapTag):Connect(applyColor))
	table.insert(connections, CollectionService:GetInstanceAddedSignal(p.KeycapColoredTag):Connect(applyColor))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(p.KeycapColoredTag):Connect(applyColor))
end

function KeycapColorClient.stop()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	v = nil
end

return KeycapColorClient