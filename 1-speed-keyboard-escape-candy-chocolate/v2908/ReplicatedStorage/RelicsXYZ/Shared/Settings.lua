local parent = script.Parent
local Tags = require(parent.Tags)
local Guard = require(parent.Guard)
local UserId = require(parent.UserId)
local Network = require(parent.Network)
local PlayerData = require(parent.PlayerData)
local RunContext = require(parent.RunContext)
local event = Network.Event("RELICSxyz_ChangeSetting", function(p, p2)
	return Guard.String(p), Guard.Boolean(p2)
end)
local v = {
	BoomboxIdol = true,
	ProximityAudio = true
}
local v2 = {}

local function getBool(p: string, p2: number?)
	local v3 = PlayerData.Read(p2)

	if not v3 then
		warn("Player data not loaded for", p2, "when getting setting", p)
		return false
	end

	local default = v3.Settings[p]

	if default ~= nil then
		return default
	end

	local v4 = v2[p]

	if v4 then
		default = v4.Default
		return default
	end

	warn("Invalid setting name:", p)
	return nil
end

local function getSettings()
	return table.clone(v2)
end

local function changeSettingImpl(p: number, p2: string, flag: boolean)
	if not v2[p2] then
		warn("Invalid setting name:", p2)
		return
	end

	local v3 = PlayerData.Get(p)

	if v3.IsLoaded then
		v3:Patch(function(p3)
			p3.Settings[p2] = flag
		end)
	else
		warn("Player data not loaded for", p, "when changing setting", p2)
	end
end

local function changeSetting(p: string, flag: boolean, p2: number?)
	if RunContext.IsEdit then
		changeSettingImpl(UserId.Get(), p, flag)
	elseif RunContext.IsClient then
		event:Client():Fire(p, flag)
	elseif p2 then
		changeSettingImpl(p2, p, flag)
	end
end

if RunContext.IsServer then
	event:Server():On(function(p, p2, p3)
		changeSettingImpl(p.UserId, p2, p3)
	end)
end

Tags.BindWithMaid("RelicsSetting", function(instance, maid)
	if not instance:IsA("ValueBase") then
		return
	end

	local name = instance.Name

	if v2[name] then
		warn("Duplicate setting found:", name)
		return
	end

	local default

	if instance:IsA("BoolValue") then
		default = instance.Value
	else
		default = false
	end

	local icon = tostring(instance:GetAttribute("Icon"))
	local title = tostring(instance:GetAttribute("Title"))
	local free = instance:GetAttribute("Free") and true or false
	local order = tonumber(instance:GetAttribute("Order")) or 0
	local description = tostring(instance:GetAttribute("Description"))
	local v4 = instance:GetAttribute("RequiresBoombox") and true or false
	local requiredFeatures = tostring(instance:GetAttribute("RequiredFeatures"))
	local requiresBoombox = instance:GetAttribute("RequiresBoombox") == nil and v[name] and true or v4
	local requiredFeatures2 = {}

	for k in requiredFeatures:gmatch("[^;, ]+") do
		requiredFeatures2[k] = true
	end

	local attributesByAttributeName = {
		Title = title,
		Free = free,
		Description = description,
		RequiresBoombox = requiresBoombox,
		RequiredFeatures = requiredFeatures2,
		Default = default,
		Order = order,
		Icon = icon
	}
	v2[name] = attributesByAttributeName
	maid:Connect(instance.AttributeChanged, function(attributeName)
		if attributeName == "RequiredFeatures" then
			local requiredFeatures3 = {}

			for k in tostring(instance:GetAttribute("RequiredFeatures")):gmatch("[^;, ]+") do
				requiredFeatures3[k] = true
			end

			attributesByAttributeName.RequiredFeatures = requiredFeatures3
		else
			local attribute = instance:GetAttribute(attributeName)

			if typeof(attribute) == typeof(attributesByAttributeName[attributeName]) then
				attributesByAttributeName[attributeName] = attribute
			end
		end
	end)
	maid:Add(function()
		v2[name] = nil
	end)
end)
return table.freeze({
	GetBool = getBool,
	GetSettings = getSettings,
	ChangeSetting = changeSetting
})