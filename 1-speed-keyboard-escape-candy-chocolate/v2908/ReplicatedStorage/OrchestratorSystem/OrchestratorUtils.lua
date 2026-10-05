local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
require(parent.OrchestratorState)
local TableUtils = require(ReplicatedStorage.Utilities.TableUtils)
local OrchestratorUtils = {
	CURRENT_DATA_VERSION = 3,
	GLOBAL_EVENT_ACTOR_ID = "__orchestrator_events__"
}

local function IsFiniteNumber(value)
	return type(value) == "number" and value == value and math.abs(value) ~= 1e999
end

local function IsArray(list)
	if type(list) ~= "table" then
		return false
	end

	local v = #list

	for k in list do
		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 or v < k then
			return false
		end
	end

	return true
end

local ValidateSavedValue

ValidateSavedValue = function(value, p: string, p2)
	local typeName = typeof(value)

	if typeName == "nil" or typeName == "boolean" or typeName == "string" then
		return true, nil
	end

	if typeName == "number" then
		local v

		if type(value) == "number" and value == value then
			v = math.abs(value) ~= 1e999
		else
			v = false
		end

		if v then
			return true, nil
		end

		return false, (`{p} contains a non-finite number.`)
	else
		if typeName == "Instance" then
			return false, (`{p} contains an Instance. Save its game path instead.`)
		end

		if typeName == "CFrame" or typeName == "Vector2" or typeName == "Vector3" or typeName == "Color3" or typeName == "NumberRange" or typeName == "NumberSequence" or typeName == "EnumItem" then
			return true, nil
		end

		if typeName ~= "table" then
			return false, (`{p} contains unsupported type {typeName}.`)
		end

		if p2[value] then
			return false, (`{p} contains a cyclic table.`)
		end

		p2[value] = true

		for k, v in value do
			if type(k) ~= "string" and type(k) ~= "number" then
				p2[value] = nil
				return false, (`{p} has an unsupported table key.`)
			end

			local v2, v3 = ValidateSavedValue(v, `{p}.{tostring(k)}`, p2)

			if v2 then
				continue
			end

			p2[value] = nil
			return false, v3
		end

		p2[value] = nil
		return true, nil
	end
end

function OrchestratorUtils.CreateGlobalEventActor()
	return {
		Id = OrchestratorUtils.GLOBAL_EVENT_ACTOR_ID,
		Name = "Events",
		InstancePath = {},
		Strips = {}
	}
end

function OrchestratorUtils.CreateData(name: string?)
	return {
		Version = OrchestratorUtils.CURRENT_DATA_VERSION,
		Name = name,
		Actors = { OrchestratorUtils.CreateGlobalEventActor() }
	}
end

function OrchestratorUtils.GetInstancePath(instance)
	local parent2 = instance
	local result = {}

	while parent2 and parent2 ~= game do
		table.insert(result, 1, parent2.Name)
		parent2 = parent2.Parent
	end

	assert(parent2 == game, (`{instance:GetFullName()} is not parented under game.`))
	return result
end

function OrchestratorUtils.GetRelativeInstancePath(instance, instance2)
	local parent2 = instance2
	local result = {}

	while parent2 and parent2 ~= instance do
		table.insert(result, 1, parent2.Name)
		parent2 = parent2.Parent
	end

	assert(parent2 == instance, (`{instance2:GetFullName()} is not a descendant of {instance:GetFullName()}.`))
	return result
end

function OrchestratorUtils.FormatInstancePath(list)
	return table.concat(list, ".")
end

function OrchestratorUtils.ResolveInstancePath(items)
	local game2 = game

	for _, childName in items do
		game2 = game2:FindFirstChild(childName)

		if not game2 then
			return nil
		end
	end

	return game2
end

function OrchestratorUtils.ResolveRelativeInstancePath(child, items)
	for _, childName in items do
		child = child:FindFirstChild(childName)

		if not child then
			return nil
		end
	end

	return child
end

function OrchestratorUtils.FormatActorPath(data)
	if data.Id == OrchestratorUtils.GLOBAL_EVENT_ACTOR_ID then
		return data.Name or "Events"
	end

	local formatInstancePath = OrchestratorUtils.FormatInstancePath(data.InstancePath)

	if data.RootTag then
		if formatInstancePath == "" then
			return data.RootTag
		end

		return (`{data.RootTag}.{formatInstancePath}`)
	elseif formatInstancePath == "" then
		return "game"
	else
		return (`game.{formatInstancePath}`)
	end
end

function OrchestratorUtils.ResolveActorTarget(p, p2)
	if not p.RootTag then
		return {
			Root = nil,
			Target = OrchestratorUtils.ResolveInstancePath(p.InstancePath),
			RootCount = 1
		}
	end

	local v

	if p2 then
		v = p2[p.RootTag]
	end

	if not v then
		v = {}

		for _, v2 in CollectionService:GetTagged(p.RootTag) do
			if v2:IsDescendantOf(game) then
				table.insert(v, v2)
			end
		end

		table.sort(v, function(a, b)
			return a:GetFullName() < b:GetFullName()
		end)

		if p2 then
			p2[p.RootTag] = v
		end
	end

	local root = v[1]
	local target

	if root then
		target = OrchestratorUtils.ResolveRelativeInstancePath(root, p.InstancePath)
	end

	return {
		Root = root,
		Target = target,
		RootCount = #v
	}
end

function OrchestratorUtils.GetParentWorldCFrame(p)
	local parent2 = p.Parent

	if not parent2 then
		return CFrame.identity
	end

	if parent2:IsA("Model") then
		return parent2:GetPivot()
	end

	if parent2:IsA("BasePart") then
		return parent2.CFrame
	end

	if parent2:IsA("Attachment") then
		return parent2.WorldCFrame
	end

	return CFrame.identity
end

function OrchestratorUtils.WorldToParentSpace(p, cframe: CFrame)
	return OrchestratorUtils.GetParentWorldCFrame(p):ToObjectSpace(cframe)
end

function OrchestratorUtils.ParentToWorldSpace(p, cframe: CFrame)
	return OrchestratorUtils.GetParentWorldCFrame(p) * cframe
end

function OrchestratorUtils.GetMusic(instance)
	local music = instance:FindFirstChild("Music")

	if music and music:IsA("AudioPlayer") then
		return music
	end

	return instance:FindFirstChildWhichIsA("AudioPlayer")
end

function OrchestratorUtils.ValidateData(data)
	if type(data) ~= "table" then
		return false, "Orchestrator data must be a table."
	end

	if data.Version ~= OrchestratorUtils.CURRENT_DATA_VERSION then
		return
			false,
			(`Unsupported orchestrator data version {tostring(data.Version)} (expected {OrchestratorUtils.CURRENT_DATA_VERSION}).`)
	end

	if data.Name ~= nil and type(data.Name) ~= "string" then
		return false, "Orchestrator data Name must be a string when provided."
	end

	if data.Duration ~= nil then
		local duration = data.Duration
		local v

		if type(duration) == "number" and duration == duration then
			v = math.abs(duration) ~= 1e999
		else
			v = false
		end

		if not v or data.Duration < 0 then
			return false, "Orchestrator data Duration must be a non-negative finite number."
		end
	end

	if not IsArray(data.Actors) then
		return false, "Orchestrator data Actors must be an array."
	end

	local v = {}

	for k, actor in data.Actors do
		local formatted = `Actors[{k}]`

		if type(actor) ~= "table" then
			return false, (`{formatted} must be a table.`)
		end

		if type(actor.Id) ~= "string" or actor.Id == "" then
			return false, (`{formatted}.Id must be a non-empty string.`)
		end

		if v[actor.Id] then
			return false, (`{formatted}.Id duplicates actor ID {actor.Id}.`)
		end

		v[actor.Id] = true

		if actor.Name ~= nil and type(actor.Name) ~= "string" then
			return false, (`{formatted}.Name must be a string when provided.`)
		end

		if actor.RootTag ~= nil and (type(actor.RootTag) ~= "string" or actor.RootTag == "") then
			return false, (`{formatted}.RootTag must be a non-empty string when provided.`)
		end

		if not IsArray(actor.InstancePath) then
			return false, (`{formatted}.InstancePath must be an array.`)
		end

		if actor.Id == OrchestratorUtils.GLOBAL_EVENT_ACTOR_ID then
			if #actor.InstancePath ~= 0 or actor.RootTag ~= nil then
				return false, (`{formatted} is the global Events actor and must target game.`)
			end
		elseif #actor.InstancePath == 0 and actor.RootTag == nil then
			return false, (`{formatted}.InstancePath must be non-empty unless RootTag is provided.`)
		end

		for k2, v2 in actor.InstancePath do
			if type(v2) ~= "string" or v2 == "" then
				return false, (`{formatted}.InstancePath[{k2}] must be a non-empty string.`)
			end
		end

		if not IsArray(actor.Strips) then
			return false, (`{formatted}.Strips must be an array.`)
		end

		for k2, strip in actor.Strips do
			local formatted2 = `{formatted}.Strips[{k2}]`

			if type(strip) ~= "table" or type(strip.Type) ~= "string" or strip.Type == "" then
				return false, (`{formatted2} must have a non-empty Type.`)
			end

			if strip.Enabled ~= nil and type(strip.Enabled) ~= "boolean" then
				return false, (`{formatted2}.Enabled must be a boolean when provided.`)
			end

			if strip.PremiereOnly ~= nil and type(strip.PremiereOnly) ~= "boolean" then
				return false, (`{formatted2}.PremiereOnly must be a boolean when provided.`)
			end

			if not IsArray(strip.Keyframes) then
				return false, (`{formatted2}.Keyframes must be an array.`)
			end

			local time = -1e999

			for k3, keyframe in strip.Keyframes do
				local formatted3 = `{formatted2}.Keyframes[{k3}]`

				if type(keyframe) ~= "table" then
					return false, (`{formatted3}.Time must be a non-negative finite number.`)
				end

				local time2 = keyframe.Time
				local v2

				if type(time2) == "number" and time2 == time2 then
					v2 = math.abs(time2) ~= 1e999
				else
					v2 = false
				end

				if not v2 or keyframe.Time < 0 then
					return false, (`{formatted3}.Time must be a non-negative finite number.`)
				end

				if keyframe.Time <= time then
					return false, (`{formatted2}.Keyframes must be ordered by Time with no duplicates.`)
				end

				time = keyframe.Time

				if keyframe.EasingStyle ~= nil and keyframe.EasingStyle ~= "Constant" and (typeof(keyframe.EasingStyle) ~= "EnumItem" or keyframe.EasingStyle.EnumType ~= Enum.EasingStyle) then
					return
						false,
						(`{formatted3}.EasingStyle must be Constant or an EasingStyle EnumItem when provided.`)
				end

				if keyframe.EasingDirection ~= nil and (typeof(keyframe.EasingDirection) ~= "EnumItem" or keyframe.EasingDirection.EnumType ~= Enum.EasingDirection) then
					return false, (`{formatted3}.EasingDirection must be an EasingDirection EnumItem when provided.`)
				end

				local v3, v4 = ValidateSavedValue(keyframe.Value, `{formatted3}.Value`, {})

				if not v3 then
					return false, v4
				end
			end

			if strip.Data == nil then
				continue
			end

			local v2, v3 = ValidateSavedValue(strip.Data, `{formatted2}.Data`, {})

			if not v2 then
				return false, v3
			end
		end
	end

	return true, nil
end

function OrchestratorUtils.EncodeData(p)
	local v, v2 = OrchestratorUtils.ValidateData(p)

	if not v then
		return nil, v2
	end

	local success, result = pcall(TableUtils.EncodeJSON, p)

	if success then
		return result, nil
	end

	return nil, (tostring(result))
end

function OrchestratorUtils.DecodeData(data, p: string?)
	if typeof(data) == "Instance" then
		if not data:IsA("Folder") then
			return nil, "Orchestrator data must be read from a Folder."
		end

		data = data:GetAttribute("Data")

		if data == nil or data == "" then
			return OrchestratorUtils.CreateData(p), nil
		end
	end

	if type(data) ~= "string" or data == "" then
		return nil, "Orchestrator Data attribute is missing or empty."
	end

	local success, result = pcall(TableUtils.DecodeJSON, data)

	if not success then
		return nil, (tostring(result))
	end

	local v

	if type(result) == "table" and result.Version == 1 and type(result.Root) == "table" and type(result.Root.Clips) == "table" and #result.Root.Clips == 0 then
		result = OrchestratorUtils.CreateData(result.Name)
		v = true
	else
		v = false
	end

	if type(result) == "table" and result.Version == 2 and type(result.Actors) == "table" then
		result.Version = OrchestratorUtils.CURRENT_DATA_VERSION
		local v2 = {}
		v = true

		for _, actor in result.Actors do
			if type(actor) ~= "table" then
				continue
			end

			actor.RootTag = nil
			local id

			if type(actor.Id) == "string" and actor.Id ~= "" then
				id = actor.Id
			end

			if not id or v2[id] then
				repeat
					id = HttpService:GenerateGUID(false)
				until not v2[id]

				actor.Id = id
			end

			v2[assert(id)] = true
		end
	end

	local v2, v3 = OrchestratorUtils.ValidateData(result)

	if v2 then
		return result, nil, v
	end

	return nil, v3
end

function OrchestratorUtils.LoadSequence(name: string, instance)
	local orchestrator = instance:FindFirstChild("Orchestrator")

	if orchestrator and not orchestrator:IsA("Folder") then
		return nil, (`{instance:GetFullName()}.Orchestrator must be a Folder.`)
	end

	local v

	if not orchestrator then
		v = OrchestratorUtils.CreateData(name)
		return {
			Name = name,
			AssetFolder = instance,
			DataFolder = orchestrator,
			Music = OrchestratorUtils.GetMusic(instance),
			Data = v
		}, nil
	end

	local v2
	v, v2 = OrchestratorUtils.DecodeData(orchestrator, name)

	if v then
		return {
			Name = name,
			AssetFolder = instance,
			DataFolder = orchestrator,
			Music = OrchestratorUtils.GetMusic(instance),
			Data = v
		}, nil
	end

	return nil, v2
end

return OrchestratorUtils