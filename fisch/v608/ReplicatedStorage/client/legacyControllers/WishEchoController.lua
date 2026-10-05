local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local maid = Trove.new()
local total = 0
local v = {
	{
		Tag = "WishEcho",
		Remote = Net:RemoteEvent("Skycrest/SetEchoVisible"),
		Mode = "Fade",
		Keyed = false,
		Hold = 1,
		FadeIn = 0.4,
		FadeOut = 1.5,
		Entries = {},
		Keys = {},
		Granted = {}
	},
	{
		Tag = "AprilFoolsOnly",
		Remote = Net:RemoteEvent("Skycrest/SetAprilVisible"),
		Mode = "Hide",
		Keyed = false,
		Hold = 5,
		FadeIn = 0,
		FadeOut = 0,
		Entries = {},
		Keys = {},
		Granted = {}
	},
	{
		Tag = "ShadowNpc",
		Remote = Net:RemoteEvent("Lullaby/SetShadowVisible"),
		Mode = "Hide",
		Keyed = true,
		Hold = 5,
		FadeIn = 0,
		FadeOut = 0,
		Entries = {},
		Keys = {},
		Granted = {}
	},
	{
		Tag = "AstraeusSpirit",
		Remote = Net:RemoteEvent("Astraeus/SetSpiritVisible"),
		Mode = "Fade",
		Keyed = true,
		Solid = true,
		Hold = 1,
		FadeIn = 0.75,
		FadeOut = 1.5,
		Entries = {},
		Keys = {},
		Granted = {}
	},
	{
		Tag = "LullabyProp",
		Remote = Net:RemoteEvent("Lullaby/SetPropVisible"),
		Mode = "Hide",
		Keyed = false,
		Hold = 0,
		FadeIn = 0,
		FadeOut = 0,
		Entries = {},
		Keys = {},
		Granted = {}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function keyOf(data, instance)
	if not data.Keyed then
		return ""
	end

	local attribute = instance:GetAttribute(data.KeyAttribute or "UID")

	if typeof(attribute) == "string" then
		return attribute
	end

	return ""
end

local function stateFor(p, p2: string)
	local key = p.Keys[p2]

	if key then
		return key
	end

	local v2 = {
		Granted = p.Granted[p2] == true,
		Wanted = false,
		Visible = false,
		Alpha = 0,
		HoldLeft = 0
	}
	p.Keys[p2] = v2
	return v2
end

local function talkingKey(data)
	local character = localPlayer.Character
	local dialoglink = character and character:FindFirstChild("dialoglink")

	if not (dialoglink and dialoglink:IsA("ObjectValue") and dialoglink.Value and CollectionService:HasTag(
		dialoglink.Value,
		data.Tag
	)) then
		return nil
	end

	local value = dialoglink.Value

	if not data.Keyed then
		return ""
	end

	local attribute = value:GetAttribute(data.KeyAttribute or "UID")

	if typeof(attribute) == "string" then
		return attribute
	end

	return ""
end

local function getOriginalProp(instance, p: string)
	if instance:GetAttribute((`Original{p}`)) ~= nil then
		return instance:GetAttribute((`Original{p}`))
	end

	instance:SetAttribute(`Original{p}`, instance[p])
	return instance[p]
end

local function cacheInstance(p, instance)
	if p.Records[instance] then
		return
	end

	if instance:IsA("BasePart") then
		p.Records[instance] = "part"
	elseif instance:IsA("Decal") then
		p.Records[instance] = "decal"
	elseif instance:IsA("Sound") then
		p.Records[instance] = "sound"
	elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Fire") or instance:IsA("Smoke") or instance:IsA("Sparkles") or instance:IsA("Light") or instance:IsA("ProximityPrompt") or instance:IsA("LayerCollector") or instance:IsA("Highlight") then
		p.Records[instance] = "toggle"
	end
end

local function cacheModel(p)
	cacheInstance(p, p.Model)

	for _, descendant in p.Model:GetDescendants() do
		cacheInstance(p, descendant)
	end
end

local function applyEntry(data, p)
	local key = p.Key
	local key2 = data.Keys[key]

	if not key2 then
		key2 = {
			Granted = data.Granted[key] == true,
			Wanted = false,
			Visible = false,
			Alpha = 0,
			HoldLeft = 0
		}
		data.Keys[key] = key2
	end

	local solid

	if data.Solid == nil then
		solid = data.Mode == "Hide"
	else
		solid = data.Solid
	end

	for k, record in p.Records do
		if k.Parent then
			if record == "part" then
				k.LocalTransparencyModifier = 1 - key2.Alpha

				if solid then
					local canCollide

					if k:GetAttribute("OriginalCanCollide") == nil then
						k:SetAttribute("OriginalCanCollide", k.CanCollide)
						canCollide = k.CanCollide
					else
						canCollide = k:GetAttribute("OriginalCanCollide")
					end

					k.CanCollide = canCollide and key2.Visible
					local canQuery

					if k:GetAttribute("OriginalCanQuery") == nil then
						k:SetAttribute("OriginalCanQuery", k.CanQuery)
						canQuery = k.CanQuery
					else
						canQuery = k:GetAttribute("OriginalCanQuery")
					end

					k.CanQuery = canQuery and key2.Visible
					local canTouch

					if k:GetAttribute("OriginalCanTouch") == nil then
						k:SetAttribute("OriginalCanTouch", k.CanTouch)
						canTouch = k.CanTouch
					else
						canTouch = k:GetAttribute("OriginalCanTouch")
					end

					k.CanTouch = canTouch and key2.Visible
				end
			elseif record == "decal" then
				local transparency

				if k:GetAttribute("OriginalTransparency") == nil then
					k:SetAttribute("OriginalTransparency", k.Transparency)
					transparency = k.Transparency
				else
					transparency = k:GetAttribute("OriginalTransparency")
				end

				k.Transparency = 1 - (1 - transparency) * key2.Alpha
			elseif record == "sound" then
				local volume

				if k:GetAttribute("OriginalVolume") == nil then
					k:SetAttribute("OriginalVolume", k.Volume)
					volume = k.Volume
				else
					volume = k:GetAttribute("OriginalVolume")
				end

				k.Volume = volume * key2.Alpha
			elseif record == "toggle" then
				local enabled

				if k:GetAttribute("OriginalEnabled") == nil then
					k:SetAttribute("OriginalEnabled", k.Enabled)
					enabled = k.Enabled
				else
					enabled = k:GetAttribute("OriginalEnabled")
				end

				k.Enabled = enabled and key2.Visible
			end
		else
			p.Records[k] = nil
		end
	end
end

local function restoreEntry(entry)
	for k, record in entry.Records do
		if not k.Parent then
			continue
		end

		if record == "part" then
			k.LocalTransparencyModifier = 0
			local canCollide

			if k:GetAttribute("OriginalCanCollide") == nil then
				k:SetAttribute("OriginalCanCollide", k.CanCollide)
				canCollide = k.CanCollide
			else
				canCollide = k:GetAttribute("OriginalCanCollide")
			end

			k.CanCollide = canCollide
			local canQuery

			if k:GetAttribute("OriginalCanQuery") == nil then
				k:SetAttribute("OriginalCanQuery", k.CanQuery)
				canQuery = k.CanQuery
			else
				canQuery = k:GetAttribute("OriginalCanQuery")
			end

			k.CanQuery = canQuery
			local canTouch

			if k:GetAttribute("OriginalCanTouch") == nil then
				k:SetAttribute("OriginalCanTouch", k.CanTouch)
				canTouch = k.CanTouch
			else
				canTouch = k:GetAttribute("OriginalCanTouch")
			end

			k.CanTouch = canTouch
		elseif record == "decal" then
			local transparency

			if k:GetAttribute("OriginalTransparency") == nil then
				k:SetAttribute("OriginalTransparency", k.Transparency)
				transparency = k.Transparency
			else
				transparency = k:GetAttribute("OriginalTransparency")
			end

			k.Transparency = transparency
		elseif record == "sound" then
			local volume

			if k:GetAttribute("OriginalVolume") == nil then
				k:SetAttribute("OriginalVolume", k.Volume)
				volume = k.Volume
			else
				volume = k:GetAttribute("OriginalVolume")
			end

			k.Volume = volume
		elseif record == "toggle" then
			local enabled

			if k:GetAttribute("OriginalEnabled") == nil then
				k:SetAttribute("OriginalEnabled", k.Enabled)
				enabled = k.Enabled
			else
				enabled = k:GetAttribute("OriginalEnabled")
			end

			k.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropEntry(p, p2: number)
	local entry = p.Entries[p2]
	table.remove(p.Entries, p2)
	restoreEntry(entry)
end

local function applyKey(p, k: string)
	for _, entry in p.Entries do
		if entry.Key == k then
			applyEntry(p, entry)
		end
	end
end

local function stepKey(data, k: string, key, p: number, p2: string?)
	local granted = key.Granted or k == p2

	if granted ~= key.Wanted then
		key.Wanted = granted
		key.HoldLeft = granted and 0 or data.Hold
	end

	if data.Mode == "Hide" then
		if granted then
			if key.Visible then
				return false
			end

			key.Visible = true
			key.Alpha = 1
		else
			if key.HoldLeft > 0 then
				key.HoldLeft -= p
				return false
			end

			if not key.Visible then
				return false
			end

			key.Visible = false
			key.Alpha = 0
		end

		return true
	else
		local v2

		if granted == key.Visible then
			v2 = false
		else
			key.Visible = granted
			v2 = true
		end

		local v3 = key.Visible and 1 or 0

		if key.Alpha == v3 then
			return v2
		end

		if key.Visible then
			key.HoldLeft = 0
			key.Alpha = math.min(1, key.Alpha + p / data.FadeIn)
		elseif key.HoldLeft > 0 then
			key.HoldLeft -= p
			return v2
		else
			key.Alpha = math.max(0, key.Alpha - p / data.FadeOut)
		end

		return true
	end
end

local function stepGroup(p, p2: number, flag: boolean)
	local v2 = talkingKey(p)

	for k, key in p.Keys do
		if stepKey(p, k, key, p2, v2) or flag then
			applyKey(p, k)
		end
	end
end

local function watch(data, instance)
	for _, entry in data.Entries do
		if entry.Model == instance then
			return
		end
	end

	local v2 = {
		Model = instance,
		Key = 0,
		Records = 0
	}
	local v3 = keyOf(data, instance) -- equivalent call inferred; original call site unknown
	v2.Key = v3
	v2.Records = {}

	if data.Keyed and v2.Key == "" then
		warn((`[WishEcho] "{instance:GetFullName()}" is tagged {data.Tag} with no {data.KeyAttribute or "UID"} attribute; it will never be shown`))
	end

	table.insert(data.Entries, v2)
	local key = v2.Key

	if not data.Keys[key] then
		local v4 = {
			Granted = data.Granted[key] == true,
			Wanted = false,
			Visible = false,
			Alpha = 0,
			HoldLeft = 0
		}
		data.Keys[key] = v4
	end

	cacheModel(v2)
	maid:Add(instance.DescendantAdded:Connect(function()
		cacheModel(v2)
		applyEntry(data, v2)
	end))
	maid:Add(instance.Destroying:Connect(function()
		local index = table.find(data.Entries, v2)

		if index then
			table.remove(data.Entries, index)
		end
	end))
	applyEntry(data, v2)
end

local function rescan(p)
	for i = #p.Entries, 1, -1 do
		local entry = p.Entries[i]

		if entry.Model.Parent and CollectionService:HasTag(entry.Model, p.Tag) then
			continue
		end

		dropEntry(p, i) -- equivalent call inferred; original call site unknown
	end

	for _, v2 in CollectionService:GetTagged(p.Tag) do
		watch(p, v2)
	end
end

local function step(p: number)
	total += p
	local v2 = total >= 1

	if v2 then
		total = 0
	end

	for _, v3 in v do
		if v2 then
			rescan(v3)
		end

		stepGroup(v3, p, v2)
	end
end

return {
	Start = function(_)
		for _, v2 in v do
			local v3 = v2
			maid:Connect(v2.Remote.OnClientEvent, function(items)
				if v3.Keyed then
					if typeof(items) ~= "table" then
						return
					end

					local granted = {}

					for k, item in items do
						if typeof(k) == "string" then
							granted[k] = item == true
						end
					end

					v3.Granted = granted

					for k, key in v3.Keys do
						key.Granted = granted[k] == true
					end
				else
					v3.Granted[""] = items == true
					local v4 = v3
					local v5 = v4.Keys[""]

					if not v5 then
						v5 = {
							Granted = v4.Granted[""] == true,
							Wanted = false,
							Visible = false,
							Alpha = 0,
							HoldLeft = 0
						}
						v4.Keys[""] = v5
					end

					v5.Granted = items == true
				end
			end)
			local v4 = v2
			maid:Add(CollectionService:GetInstanceAddedSignal(v2.Tag):Connect(function(model)
				watch(v4, model)
			end))
			local v5 = v2
			maid:Add(CollectionService:GetInstanceRemovedSignal(v2.Tag):Connect(function(p)
				for k, entry in v5.Entries do
					if entry.Model ~= p then
						continue
					end

					dropEntry(v5, k) -- equivalent call inferred; original call site unknown
					break
				end
			end))

			for _, v6 in CollectionService:GetTagged(v2.Tag) do
				watch(v2, v6)
			end

			v2.Remote:FireServer()
		end

		maid:Connect(RunService.RenderStepped, step)
	end
}