local ReplicatedStorage = game:GetService("ReplicatedStorage")
local interpolationScheme = ReplicatedStorage:FindFirstChild("InterpolationScheme", true)
local PlaySchemes = require(interpolationScheme.PlaySchemes)
local GetSchemesFor = require(interpolationScheme.GetSchemesFor)

local function HasProperty(instance, childName)
	local success, result = pcall(function()
		return instance[childName]
	end)
	return success and result ~= instance:FindFirstChild(childName)
end

local function GetInitialState(p)
	local v, v2 = GetSchemesFor(p)
	local v3 = {}

	for _, v4 in pairs(v) do
		v4._InsertResetState(v3, p, v2)
	end

	return v3
end

local function ResetToInitialState(items)
	for k, item in pairs(items) do
		for k2, v in pairs(item) do
			k[k2] = v
		end
	end
end

local MakeInstancesInvisible

MakeInstancesInvisible = function(list, p)
	for _, v in ipairs(list) do
		if p[v] then
			continue
		end

		local v2 = {}
		local v4 = v
		local v5 = "Transparency"
		local success, result = pcall(function()
			return v4[v5]
		end)

		if success and result ~= v:FindFirstChild("Transparency") and typeof(v.Transparency) == "number" and v.Transparency ~= 1 then
			v2.Transparency = v.Transparency
			v.Transparency = 1
		end

		local v7 = v
		local v8 = "Enabled"
		local success2, result2 = pcall(function()
			return v7[v8]
		end)

		if success2 and result2 ~= v:FindFirstChild("Enabled") and typeof(v.Enabled) == "boolean" and v.Enabled ~= false then
			v2.Enabled = v.Enabled
			v.Enabled = false
		end

		local _ = v.ClassName == "ParticleEmitter"
		p[v] = v2
		MakeInstancesInvisible(v:GetChildren(), p)
	end

	return p
end

local function PlaySchemesAndResetAfter(list)
	local v = {}

	for _, v2 in ipairs(list) do
		table.insert(v, (GetInitialState(v2)))
	end

	for _ = 1, 2 do
		local v2 = {}
		MakeInstancesInvisible(list, v2)
		task.wait(0.4)
		ResetToInitialState(v2)
		local playSchemes = PlaySchemes(list)
		task.wait(playSchemes + 0.4)

		for _, v4 in ipairs(v) do
			ResetToInitialState(v4)
		end

		for _, v4 in ipairs(list) do
			v4:SetAttribute("IsPlaying", false)
		end
	end
end

local Selection = game:GetService("Selection")
local v = Selection:Get()
Selection:Set({})
local v2 = {}

for _, folder in ipairs(v) do
	if folder:GetAttribute("TimeLength") ~= nil and folder:GetAttribute("IsPlaying") == false then
		table.insert(v2, folder)
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:GetAttribute("TimeLength") ~= nil and descendant:GetAttribute("IsPlaying") == false) then
			continue
		end

		table.insert(v2, descendant)
	end
end

PlaySchemesAndResetAfter(v2)
Selection:Set(v)