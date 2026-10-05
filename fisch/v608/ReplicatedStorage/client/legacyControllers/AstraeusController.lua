local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local assets = require(ReplicatedStorage.shared.utils.assets)
local v = {
	Driftwood = "Slot1",
	Resin = "Slot2"
}
local remoteEvent = Net:RemoteEvent("Eus/PlaceInDirtEvent")
local clones = {}

local function findDarkness()
	for _, v2 in CollectionService:GetTagged("AstraeusSpirit") do
		if v2:GetAttribute("UID") == "SpiritOfDarkness" then
			return v2
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEnabled(instance, enabled: boolean)
	instance:SetAttribute("OriginalEnabled", enabled)
	instance.Enabled = enabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearPlaced()
	for _, v2 in clones do
		v2:Destroy()
	end

	table.clear(clones)
end

local function place(dirtPile, p: string)
	local v2 = v[p]

	if not v2 then
		return
	end

	local child = dirtPile:FindFirstChild(v2)

	if not child then
		return
	end

	local async = assets.getAsync("fish", p)

	if not async then
		return
	end

	local clone = async:Clone()

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.Anchored = true
	end

	local worldCFrame = child.WorldCFrame
	clone.Parent = dirtPile
	clone:PivotTo(CFrame.new(worldCFrame.X, worldCFrame.Y, worldCFrame.Z))
	table.insert(clones, clone)
end

local function render(data)
	local darkness = findDarkness()

	if not darkness then
		return
	end

	local dirtPile = darkness:FindFirstChild("DirtPile")

	if not dirtPile then
		return
	end

	clearPlaced() -- equivalent call inferred; original call site unknown

	if data.Lit then
		local sound = dirtPile:FindFirstChild("Sound")

		if sound and sound:IsA("Sound") and data.Added == "Molten Ripple" then
			sound:Play()
		end

		setEnabled(dirtPile.Flames, true) -- equivalent call inferred; original call site unknown
		setEnabled(dirtPile.ProximityPrompt, false) -- equivalent call inferred; original call site unknown
	else
		setEnabled(dirtPile.Flames, false) -- equivalent call inferred; original call site unknown
		setEnabled(dirtPile.ProximityPrompt, true) -- equivalent call inferred; original call site unknown

		for _, v2 in data.Placed do
			place(dirtPile, v2)
		end

		dirtPile.ProximityPrompt.ActionText = #data.Placed >= 2 and "Add Fire" or "Place"
	end

	if data.Added then
		ReplicatedStorage.events.anno_localthought:Fire((`Placed <b>{data.Added}</b> in the dirt pile`))
	end
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(p)
			if typeof(p) ~= "table" then
				return
			end

			render(p)
		end)
		remoteEvent:FireServer()
	end
}