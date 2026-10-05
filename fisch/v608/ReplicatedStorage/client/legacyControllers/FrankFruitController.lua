local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local remoteEvent = Net:RemoteEvent("Skycrest/FruitCollected")
local remoteEvent2 = Net:RemoteEvent("Skycrest/FruitSync")
local maid = Trove.new()
local v = {}
local v2 = {}
local total = 0

local function getFruitId(instance)
	local fruitId = instance:GetAttribute("FruitId")

	if typeof(fruitId) == "number" then
		return (tostring(fruitId))
	end

	if typeof(fruitId) == "string" and fruitId ~= "" then
		return fruitId
	end

	return nil
end

local function cacheModel(p)
	for _, descendant in p.Model:GetDescendants() do
		if p.Records[descendant] then
			continue
		end

		if descendant:IsA("BasePart") then
			p.Records[descendant] = {
				Kind = "Part",
				CanCollide = descendant.CanCollide,
				CanQuery = descendant.CanQuery,
				CanTouch = descendant.CanTouch
			}
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			p.Records[descendant] = {
				Kind = "Decal",
				Transparency = descendant.Transparency
			}
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") or descendant:IsA("ProximityPrompt") or descendant:IsA("Highlight") or descendant:IsA("LayerCollector") then
			p.Records[descendant] = {
				Kind = "Toggle"
			}
		end
	end

	if p.Model:IsA("BasePart") and not p.Records[p.Model] then
		local model = p.Model
		p.Records[model] = {
			Kind = "Part",
			CanCollide = model.CanCollide,
			CanQuery = model.CanQuery,
			CanTouch = model.CanTouch
		}
	end
end

local function applyEntry(p)
	local enabled = not v[p.Id]

	for k, record in p.Records do
		if k.Parent then
			if record.Kind == "Part" then
				k.LocalTransparencyModifier = enabled and 0 or 1
				k.CanCollide = enabled and record.CanCollide == true
				k.CanQuery = enabled and record.CanQuery == true
				k.CanTouch = enabled and record.CanTouch == true
			elseif record.Kind == "Decal" then
				k.Transparency = not enabled and 1 or record.Transparency or 0
			elseif record.Kind == "Toggle" then
				k.Enabled = enabled
			end
		else
			p.Records[k] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyAll()
	for _, v3 in v2 do
		applyEntry(v3)
	end
end

local function watch(instance)
	for _, v3 in v2 do
		if v3.Model == instance then
			return
		end
	end

	local fruitId = instance:GetAttribute("FruitId")

	if typeof(fruitId) == "number" then
		fruitId = tostring(fruitId)
	elseif typeof(fruitId) ~= "string" or fruitId == "" then
		fruitId = nil
	end

	if not fruitId then
		return
	end

	local v3 = {
		Model = instance,
		Id = fruitId,
		Records = {}
	}
	table.insert(v2, v3)
	cacheModel(v3)
	maid:Add(instance.DescendantAdded:Connect(function()
		cacheModel(v3)
		applyEntry(v3)
	end))
	maid:Add(instance.Destroying:Connect(function()
		local index = table.find(v2, v3)

		if index then
			table.remove(v2, index)
		end
	end))
	applyEntry(v3)
end

local function rescan()
	for i = #v2, 1, -1 do
		if not v2[i].Model.Parent then
			table.remove(v2, i)
		end
	end

	for _, v3 in CollectionService:GetTagged("SkycrestFruit") do
		watch(v3)
	end
end

local function step(p: number)
	total += p

	if total < 1 then
		return
	end

	total = 0
	rescan()
	applyAll() -- equivalent call inferred; original call site unknown
end

return {
	Start = function(_)
		maid:Connect(remoteEvent2.OnClientEvent, function(items)
			if typeof(items) ~= "table" then
				return
			end

			table.clear(v)

			for k, item in items do
				if typeof(k) == "string" then
					v[k] = item == true
				end
			end

			applyAll() -- equivalent call inferred; original call site unknown
		end)
		maid:Connect(remoteEvent.OnClientEvent, function(value)
			if typeof(value) ~= "string" then
				return
			end

			v[value] = true
			applyAll() -- equivalent call inferred; original call site unknown
		end)
		maid:Add(CollectionService:GetInstanceAddedSignal("SkycrestFruit"):Connect(watch))
		maid:Add(CollectionService:GetInstanceRemovedSignal("SkycrestFruit"):Connect(function(p)
			for k, v3 in v2 do
				if v3.Model ~= p then
					continue
				end

				table.remove(v2, k)
				break
			end
		end))
		rescan()
		remoteEvent2:FireServer()
		maid:Connect(RunService.RenderStepped, step)
	end
}