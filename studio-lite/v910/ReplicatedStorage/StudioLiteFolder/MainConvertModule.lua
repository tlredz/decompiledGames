local v = {
	IncludeProperties = true,
	OnlySaveUniqueProperties = true,
	OnlySaveWritableProperties = true,
	ExcludedProperties = {
		"ExcludedProperty1",
		"ExcludedProperty2",
		"ExcludedProperty3",
		"etc."
	},
	SpecificExcludedProperties = {},
	ExcludedClasses = {},
	IgnoreAttachmentWorldProperties = true,
	FetchLatestPropertiesOnline = false,
	ShowHTTPWarning = true,
	IncludeAttributes = true,
	IncludeTags = true,
	ExcludedTags = {
		"ExcludedTag1",
		"ExcludedTag2",
		"ExcludedTag3",
		"etc."
	},
	IncludeObjectVariables = true,
	Color3Scale = 255,
	EnumType = "Enum",
	DataStoreFriendly = true,
	PrintDataStoreApproximateSize = false,
	DefaultInstanceType = "Folder",
	CarryOverSurfaceAppearances = false,
	IncludeSurfaceAppearancesOverride = true,
	AutoConvertMeshParts = true,
	AutoSmoothParts = false,
	PrintCompatibilityErrors = true,
	PrintObjectVariableErrors = true,
	PrintCompletionTime = false,
	PrintCleanupAmount = false
}
local _ = {
	ModuleCanRunFromTheClient = true
}
local v2 = {
	Color3Scale = { 1, 255 },
	EnumType = { "Enum", "String", "Int" }
}
local v3 = {
	"Workspace",
	"Lighting",
	"StarterPlayer",
	"TestService",
	"SoundService",
	"Chat",
	"Terrain"
}
local OfflineAPI = require(script.OfflineAPI)
local _ = OfflineAPI.APISTRING
local v4 = {
	"LeftParamA",
	"LeftParamB",
	"TopParamA",
	"TopParamB",
	"BottomParamA",
	"BottomParamB",
	"RightParamA",
	"RightParamB",
	"FrontParamA",
	"FrontParamB",
	"BackParamA",
	"BackParamB",
	"LeftSurfaceInput",
	"TopSurfaceInput",
	"BottomSurfaceInput",
	"RightSurfaceInput",
	"FrontSurfaceInput",
	"BackSurfaceInput",
	"Source",
	"ResizeableFaces",
	"Parent",
	"clone",
	"SL_UniqueId"
}
local v5 = { "UnionOperation" }
local instancesByClassName = {}
local v6 = {}
local meshPart = Instance.new("MeshPart")
local copy = nil
local v7 = true
local surfaceAppearance = Instance.new("SurfaceAppearance")
local CollectionService = game:GetService("CollectionService")
local AssetService = game:GetService("AssetService")
local MainConvertModule = {}
MainConvertModule.__index = MainConvertModule

function GetDictionaryLength(items)
	local count = 0

	for _, _ in pairs(items) do
		count += 1
	end

	return count
end

function DeepCopy(items)
	if type(items) ~= "table" then
		return items
	end

	local copies = {}

	for k, item in pairs(items) do
		copies[k] = DeepCopy(item)
	end

	return copies
end

local function fn()
	return os.clock()
end

function RecheckIfHTTPEnabled() end

function InsertAlpha(list, value)
	if not (typeof(list) == "table" and typeof(value) == "string") then
		return
	end

	local v8 = nil

	for i = 1, #list do
		if not (list[i] < value) then
			continue
		end

		table.insert(list, i, value)
		v8 = true
		break
	end

	if not v8 then
		table.insert(list, value)
	end
end

function RemoveUnwantedCharacters(p)
	local v8 = tostring(p == nil and "" or p)

	if table.find({
		"name",
		"parent",
		"classname",
		"archivable"
	}, string.lower(v8)) then
		v8 ..= "InstanceToTableModuleRenamedMeBecauseIAmANameThatIsAlsoAPropertyYouShouldNotNameYourInstancesAfterPropertiesItIsABadHabit"
	end

	return (v8:gsub("%[VISUAL ONLY%]", ""):gsub("%[OLD%]", ""):gsub("%[PLUGIN REFERENCE DO NOT EDIT%]", ""):gsub(
		"[%W]",
		""
	))
end

function FetchSettings(items)
	local result = {}

	for k, v8 in pairs(v) do
		result[k] = v8
	end

	if typeof(items) == "table" then
		for k, item in pairs(items) do
			if result[k] == nil then
				continue
			end

			if typeof(result[k]) == typeof(item) then
				if v2[k] == nil then
					result[k] = item
				elseif table.find(v2[k], item) then
					result[k] = item
				else
					local v8 = "{"

					for _, v9 in ipairs(v2[k]) do
						local v10 = typeof(v9) == "string" and "\"" or ""
						v8 ..= v10 .. tostring(v9) .. v10 .. ","
					end

					local v9 = v8 .. "}"
					warn("ConversionSetting \"" .. tostring(k) .. "\" was given a setting that is not an option. Recieved setting was: " .. tostring(item) .. ".\n Available options for \"" .. tostring(k) .. "\" are: \n" .. v9 .. " \n ConversionSetting was reset to its default setting (" .. tostring(result[k]) .. ")")
				end
			else
				warn("ConversionSetting \"" .. tostring(k) .. "\" is not formatted correctly. Recieved a " .. string.upper((tostring((typeof(item))))) .. ". \"" .. tostring(k) .. "\" needs to be a " .. string.upper((tostring((typeof(result[k]))))) .. ".")
			end
		end
	end

	if result.IgnoreAttachmentWorldProperties ~= true or typeof(result.ExcludedProperties) ~= "table" then
		return result
	end

	if not table.find(result.ExcludedProperties, "WorldCFrame") then
		table.insert(result.ExcludedProperties, "WorldCFrame")
	end

	if not table.find(result.ExcludedProperties, "WorldPosition") then
		table.insert(result.ExcludedProperties, "WorldPosition")
	end

	if not table.find(result.ExcludedProperties, "WorldAxis") then
		table.insert(result.ExcludedProperties, "WorldAxis")
	end

	if not table.find(result.ExcludedProperties, "WorldOrientation") then
		table.insert(result.ExcludedProperties, "WorldOrientation")
	end

	if not table.find(result.ExcludedProperties, "WorldSecondaryAxis") then
		table.insert(result.ExcludedProperties, "WorldSecondaryAxis")
	end

	return result
end

function InsertPreviousProperties(list, p, p2)
	if typeof(list) ~= "table" or typeof(p) ~= "table" then
		return
	end

	local v8 = GetDictionaryLength(list)
	local v9 = false

	for _, v10 in pairs(v6) do
		if not (typeof(v10) == "table" and typeof(v10[1]) == "table" and typeof(v10[2]) == "table") then
			continue
		end

		if GetDictionaryLength(v10[1]) ~= v8 then
			continue
		end

		local v11 = true

		for _, v12 in pairs(v10[1]) do
			if typeof(v12) ~= "string" or table.find(list, v12) then
				continue
			end

			v11 = false
		end

		if v11 == true and not v10[3] == not p2 then
			v9 = true
		end
	end

	if v9 == false then
		table.insert(v6, { list, p, p2 or false })
	end
end

function FetchPreviousProperties(list, p)
	if typeof(list) ~= "table" then
		return nil
	end

	local v8 = GetDictionaryLength(list)

	for _, v10 in pairs(v6) do
		if not (typeof(v10) == "table" and typeof(v10[1]) == "table" and typeof(v10[2]) == "table") then
			continue
		end

		if GetDictionaryLength(v10[1]) ~= v8 then
			continue
		end

		local v11 = true

		for _, v12 in pairs(v10[1]) do
			if typeof(v12) == "string" then
				if not table.find(list, v12) then
					v11 = false
				end
			else
				v11 = false
			end
		end

		if v11 == true and not v10[3] == not p then
			return v10[2]
		end
	end

	return nil
end

function MainConvertModule:FetchProperties(p, list, _, p2, p3)
	if typeof(p) ~= "boolean" then
		warn("Fetching Properties function needs a boolean. True = Fetch directly from the Roblox API. | False = Fetch from a Roblox Module scraped from the API.")
		return {}
	end

	local HttpService = game:GetService("HttpService")
	local APISTRING = OfflineAPI.APISTRING
	local v8 = {}
	local success, _ = pcall(function()
		v8 = HttpService:JSONDecode(APISTRING)
	end)

	if not success then
		warn("An error occured while trying to decode properties from the API.")
		return
	end

	local GetClassesFromClassItem

	GetClassesFromClassItem = function(p4)
		local v9 = {}

		for _, class in pairs(v8.Classes) do
			if not (class.Name and class.Name == p4) then
				continue
			end

			if typeof(class.Members) == "table" then
				for _, member in pairs(class.Members) do
					if not (member.MemberType and member.MemberType == "Property" and typeof(member.Name) == "string") then
						continue
					end

					if not (not (table.find(v4, member.Name) or table.find(list, member.Name)) or p3 == true) then
						continue
					end

					if member.Tags then
						if not (table.find(member.Tags, "Hidden") or table.find(member.Tags, "Deprecated")) then
							if table.find(member.Tags, "ReadOnly") and p2 == true then
								InsertAlpha(v9, member.Name)
							elseif not table.find(member.Tags, "ReadOnly") or member.Name == "ClassName" then
								InsertAlpha(v9, member.Name)
							end
						end
					else
						InsertAlpha(v9, member.Name)
					end
				end
			end

			if not class.Superclass then
				continue
			end

			for _, v10 in pairs(GetClassesFromClassItem(class.Superclass)) do
				if not table.find(v9, v10) then
					InsertAlpha(v9, v10)
				end
			end
		end

		return v9
	end

	local result = {}

	for _, class in pairs(v8.Classes) do
		local v9 = {}

		if not class.Name then
			continue
		end

		if typeof(class.Members) == "table" then
			for _, member in pairs(class.Members) do
				if not (member.MemberType and member.MemberType == "Property" and typeof(member.Name) == "string") then
					continue
				end

				if not (not (table.find(v4, member.Name) or table.find(list, member.Name)) or p3 == true) then
					continue
				end

				if member.Tags then
					if not (table.find(member.Tags, "Hidden") or table.find(member.Tags, "Deprecated")) then
						if table.find(member.Tags, "ReadOnly") and p2 == true then
							InsertAlpha(v9, member.Name)
						elseif not table.find(member.Tags, "ReadOnly") or member.Name == "ClassName" then
							InsertAlpha(v9, member.Name)
						end
					end
				else
					InsertAlpha(v9, member.Name)
				end
			end
		end

		if class.Superclass then
			for _, v10 in pairs((GetClassesFromClassItem(class.Name))) do
				if not table.find(v9, v10) then
					InsertAlpha(v9, v10)
				end
			end
		end

		result[class.Name] = v9
	end

	return result
end

local v8 = nil

function ConvertObjectToString(instance, instance2, ancestor)
	if not (instance and instance2 and ancestor) then
		return ""
	end

	if instance2:IsDescendantOf(instance) then
		local v9 = "self"

		while true do
			for _, ancestor2 in pairs(instance:GetChildren()) do
				if not (ancestor2 and instance2:IsDescendantOf(ancestor2)) then
					continue
				end

				v9 ..= "." .. ancestor2.Name
				instance = ancestor2
			end

			if instance2 and instance then
				if instance == instance2.Parent then
					return v9 .. "." .. instance2.Name
				end
			else
				return ""
			end
		end
	elseif instance2:IsDescendantOf(ancestor) then
		local parent = instance.Parent
		local parents = {}
		local v9 = "self"

		repeat
			table.insert(parents, parent)
			parent = parent.Parent
		until not parent:IsDescendantOf(ancestor) and parent ~= ancestor

		local v10 = nil

		for i = 1, #parents do
			v9 ..= ".Parent"

			if not (parents[i] and instance2:IsDescendantOf(parents[i])) then
				continue
			end

			v10 = parents[i]
			break
		end

		if not v10 then
			return ""
		end

		while true do
			for _, ancestor2 in pairs(v10:GetChildren()) do
				if not (ancestor2 and instance2:IsDescendantOf(ancestor2)) then
					continue
				end

				v9 ..= "." .. ancestor2.Name
				v10 = ancestor2
			end

			if instance2 and v10 then
				if v10 == instance2.Parent then
					return v9 .. "." .. instance2.Name
				end
			else
				return ""
			end
		end
	else
		local game2 = game
		local v9 = "game"

		while true do
			for _, ancestor2 in pairs(game2:GetChildren()) do
				if not (ancestor2 and instance2:IsDescendantOf(ancestor2)) then
					continue
				end

				v9 ..= "." .. ancestor2.Name
				game2 = ancestor2
			end

			if not instance2 or not game2 or v9 == "game" then
				return ""
			end

			if game2 == instance2.Parent then
				return v9 .. "." .. instance2.Name
			end
		end
	end
end

function CollectTags(instance, p)
	if typeof(instance) ~= "Instance" then
		return nil
	end

	local v9 = typeof(p) ~= "table" and {} or p
	local tags = CollectionService:GetTags(instance)
	local tags2 = {}

	for _, tag in pairs(tags) do
		if not table.find(v9, tag) then
			table.insert(tags2, tag)
		end
	end

	return tags2
end

function SafelyAddToTable(p, value, value2, state, instance, instance2)
	if not (typeof(p) == "table" and typeof(value) == "string" and typeof(state) == "table") then
		return
	end

	local dataStoreFriendly = state.DataStoreFriendly
	local color3Scale = state.Color3Scale or 1
	local enumType = state.EnumType or "Enum"
	local includeObjectVariables = state.IncludeObjectVariables
	local v9 = typeof(includeObjectVariables) ~= "boolean" or includeObjectVariables

	if not (typeof(dataStoreFriendly) == "boolean" and value2 ~= nil) then
		return
	end

	local v10

	if p[value] == nil then
		v10 = value
	else
		local v11 = 1

		repeat
			v11 += 1
		until p[value .. tostring(v11)] == nil

		v10 = value .. tostring(v11)
	end

	if typeof(value2) == "table" or typeof(value2) == "boolean" or typeof(value2) == "number" or typeof(value2) == "string" or dataStoreFriendly ~= true then
		if typeof(value2) == "EnumItem" then
			if string.lower(enumType) == "string" then
				p[v10] = value2.Name
			elseif string.lower(enumType) == "int" then
				p[v10] = value2.Value
			else
				p[v10] = value2
			end
		elseif typeof(value2) == "Instance" then
			if v9 then
				p[v10] = value2
			end
		else
			p[v10] = value2
		end
	elseif typeof(value2) == "Vector2" then
		p[v10] = {
			X = value2.X,
			Y = value2.Y
		}
	elseif typeof(value2) == "Vector3" then
		p[v10] = {
			X = value2.X,
			Y = value2.Y,
			Z = value2.Z
		}
	elseif typeof(value2) == "Color3" then
		if color3Scale == 1 then
			p[v10] = {
				R = value2.R,
				G = value2.G,
				B = value2.B,
				Scale = 1
			}
		elseif color3Scale == 255 then
			p[v10] = {
				R = math.round(value2.R * 255),
				G = math.round(value2.G * 255),
				B = math.round(value2.B * 255),
				Scale = 255
			}
		end
	elseif typeof(value2) == "UDim" then
		p[v10] = {
			Scale = value2.Scale,
			Offset = value2.Offset
		}
	elseif typeof(value2) == "UDim2" then
		p[v10] = {
			X = {
				Scale = value2.X.Scale,
				Offset = value2.X.Offset
			},
			Y = {
				Scale = value2.Y.Scale,
				Offset = value2.Y.Offset
			}
		}
	elseif typeof(value2) == "Font" then
		local success, result = pcall(function()
			if value2.Weight and value2.Style then
				p[v10] = {
					FontFamily = value2.Family,
					FontWeight = value2.Weight.Name,
					FontStyle = value2.Style.Name
				}
			else
				p[v10] = {
					FontFamily = value2.Family,
					FontWeight = "Regular",
					FontStyle = "Normal"
				}
			end
		end)

		if not success and state.PrintCompatibilityErrors then
			warn(result)
		end
	elseif typeof(value2) == "Rect" then
		p[v10] = {
			Min = {
				X = value2.Min.X,
				Y = value2.Min.Y
			},
			Max = {
				X = value2.Max.X,
				Y = value2.Max.Y
			}
		}
	elseif typeof(value2) == "NumberRange" then
		p[v10] = {
			Min = value2.Min,
			Max = value2.Max
		}
	elseif typeof(value2) == "NumberSequence" then
		local v11 = {}

		for i = 1, #value2.Keypoints do
			v11[tostring(i)] = {
				Time = value2.Keypoints[i].Time,
				Value = value2.Keypoints[i].Value,
				Envelope = value2.Keypoints[i].Envelope
			}
		end

		p[v10] = v11
	elseif typeof(value2) == "ColorSequence" then
		local v11 = {}

		for i = 1, #value2.Keypoints do
			v11[tostring(i)] = {
				Time = value2.Keypoints[i].Time,
				R = value2.Keypoints[i].Value.R,
				G = value2.Keypoints[i].Value.G,
				B = value2.Keypoints[i].Value.B
			}
		end

		p[v10] = v11
	elseif typeof(value2) == "PhysicalProperties" then
		p[v10] = {
			Density = value2.Density,
			Friction = value2.Friction,
			Elasticity = value2.Elasticity,
			FrictionWeight = value2.FrictionWeight,
			ElasticityWeight = value2.ElasticityWeight
		}
	elseif typeof(value2) == "EnumItem" then
		if string.lower(enumType) == "string" then
			p[v10] = value2.Name
		elseif string.lower(enumType) == "int" then
			p[v10] = value2.Value
		else
			p[v10] = {
				EnumType = tostring(value2.EnumType),
				Name = value2.Name
			}
		end
	elseif typeof(value2) == "CFrame" then
		local v11 = string.split(tostring(value2), ",")
		p[v10] = {
			X = tonumber(v11[1]),
			Y = tonumber(v11[2]),
			Z = tonumber(v11[3]),
			R00 = tonumber(v11[4]),
			R01 = tonumber(v11[5]),
			R02 = tonumber(v11[6]),
			R10 = tonumber(v11[7]),
			R11 = tonumber(v11[8]),
			R12 = tonumber(v11[9]),
			R20 = tonumber(v11[10]),
			R21 = tonumber(v11[11]),
			R22 = tonumber(v11[12])
		}
	elseif typeof(value2) == "Instance" then
		if v9 and typeof(instance) == "Instance" and typeof(instance2) == "Instance" then
			p[v10] = ConvertObjectToString(instance, value2, instance2)
		end
	elseif typeof(value2) == "BrickColor" then
		p[v10] = {
			BrickColor = value2.Name
		}
	elseif typeof(value2) == "Axes" then
		p[v10] = {
			X = value2.X,
			Y = value2.Y,
			Z = value2.Z
		}
	elseif typeof(value2) == "Ray" then
		p[v10] = {
			Origin = {
				X = value2.Origin.X,
				Y = value2.Origin.Y,
				Z = value2.Origin.Z
			},
			Direction = {
				X = value2.Direction.X,
				Y = value2.Direction.Y,
				Z = value2.Direction.Z
			}
		}
	elseif typeof(value2) == "Faces" then
		p[v10] = {
			Top = value2.Top,
			Bottom = value2.Bottom,
			Left = value2.Left,
			Right = value2.Right,
			Front = value2.Front,
			Back = value2.Back
		}
	elseif typeof(value2) == "TweenInfo" then
		if typeof(state.ErrorTable) ~= "table" then
			state.ErrorTable = {}
		end

		local v11 = "Converter Module: Instance ↔ Table does not support " .. tostring((typeof(value2))) .. " values while being DataStoreFriendly. Any " .. tostring((typeof(value2))) .. " properties were not saved."

		if not table.find(state.ErrorTable, v11) then
			table.insert(state.ErrorTable, v11)
		end
	else
		if typeof(state.ErrorTable) ~= "table" then
			state.ErrorTable = {}
		end

		if typeof(instance) == "Instance" then
			local v11 = "Found new value type. Item Name: " .. tostring(instance.Name) .. " | Value Name: \"" .. value .. "\" | Type:" .. tostring((typeof(value2))) .. " | Value: " .. tostring(value2)

			if not table.find(state.ErrorTable, v11) then
				table.insert(state.ErrorTable, v11)
			end
		end
	end

	return p[v10]
end

function DoForEveryObject(instance, p, p2, state, p3)
	if typeof(instance) ~= "Instance" then
		return p
	end

	if state.IncludeProperties == true then
		local className = instance.ClassName or "NOTAVAILABLE"
		local _, _ = pcall(function()
			local className2 = instance.ClassName

			if typeof(className2) == "string" and table.find(v5, className2) then
				if className2 == "UnionOperation" then
					className = "Part"
				end

				if typeof(state.ErrorTable) ~= "table" then
					state.ErrorTable = {}
				end

				local v9 = "The instance to table conversion contained a " .. tostring(className2) .. " object. " .. tostring(className2) .. "s are not supported."

				if not table.find(state.ErrorTable, v9) then
					table.insert(state.ErrorTable, v9)
				end
			end
		end)
		local v9

		if state.OnlySaveWritableProperties == true then
			v9 = p2[className]
		else
			v9 = v8[className]
		end

		if typeof(v9) == "table" then
			local v10 = instancesByClassName[className]

			if not v10 then
				local instance2 = nil
				pcall(function()
					instance2 = Instance.new(className)

					if instance2:IsA("BasePart") then
						instance2.TopSurface = Enum.SurfaceType.Smooth
						instance2.BottomSurface = Enum.SurfaceType.Smooth
					end
				end)
				instancesByClassName[className] = instance2
				v10 = instance2
			end

			for _, v11 in pairs(v9) do
				if not v11 then
					continue
				end

				local v12 = v11
				local success, _ = pcall(function()
					local v13 = instance[v12]
				end)
				local v13 = typeof(state.SpecificExcludedProperties[className]) ~= "table" and {} or state.SpecificExcludedProperties[className]

				if not success or (table.find(state.ExcludedProperties, v11) or table.find(v13, v11)) then
					continue
				end

				if v10 then
					if v10[v11] == instance[v11] or instance[v11] == nil or state.OnlySaveUniqueProperties ~= true or v11 == "ClassName" or v11 == "Name" then
						if v11 == "ClassName" or v11 == "Name" then
							if v11 == "ClassName" and instance[v11] == "UnionOperation" then
								SafelyAddToTable(p, "ClassName", "Part", state, instance, p3)
							else
								SafelyAddToTable(p, v11, instance[v11], state, instance, p3)
							end
						elseif state.OnlySaveUniqueProperties == false then
							SafelyAddToTable(p, v11, instance[v11], state, instance, p3)
						end
					else
						SafelyAddToTable(p, v11, instance[v11], state, instance, p3)
					end
				else
					SafelyAddToTable(p, v11, instance[v11], state, instance, p3)
				end
			end
		end
	end

	if state.IncludeAttributes == true and instance then
		local attributes = instance:GetAttributes()

		for k, attribute in pairs(attributes) do
			SafelyAddToTable(p, k, attribute, state, instance, p3)
		end
	end

	if state.IncludeTags == true and instance then
		local TAGS = CollectTags(instance, state.ExcludedTags)

		if #TAGS > 0 then
			p["[TAGS]"] = TAGS
		end
	end

	if not instance then
		return p
	end

	local children = instance:GetChildren()
	local className = ""
	local _, _ = pcall(function()
		className = instance.ClassName or ""
	end)

	if #children > 0 and not table.find(v3, className) and className ~= "" then
		for _, v9 in pairs(children) do
			if not v9 then
				continue
			end

			if v7 == false and state.IncludeSurfaceAppearancesOverride == true and v9.ClassName == "SurfaceAppearance" then
				local v10 = SafelyAddToTable(p, RemoveUnwantedCharacters(v9.Name), {}, state)
				DoForEveryObject(v9, v10, p2, state, p3)
			elseif v9.ClassName == "SurfaceAppearance" then
				if v7 == true then
					local v10 = SafelyAddToTable(p, RemoveUnwantedCharacters(v9.Name), {}, state)
					DoForEveryObject(v9, v10, p2, state, p3)
				end
			else
				local v10 = SafelyAddToTable(p, RemoveUnwantedCharacters(v9.Name), {}, state)
				DoForEveryObject(v9, v10, p2, state, p3)
			end
		end
	end

	return p
end

function MainConvertModule:ConvertToTable(instance, p)
	v7 = pcall(function()
		surfaceAppearance.ColorMap = ""
	end)
	local RunService = game:GetService("RunService")
	local v9 = false
	pcall(function()
		v9 = RunService:IsEdit()
	end)
	local _ = RunService:IsClient() and RunService:IsStudio()

	if typeof(instance) == "Instance" then
		if typeof(p) ~= "table" and typeof(p) ~= "nil" then
			warn("Recieved ConversionSettings as a " .. string.upper(tostring((typeof(p))) .. " format. ConversionSettings need to be in a dictionary format. "))
			return nil
		end

		local success, _ = pcall(function()
			local clone = instance:Clone()

			if clone then
				clone:Destroy()
			end
		end)

		if not success then
			local className = ""
			local name = ""
			local _, _ = pcall(function()
				className = instance.ClassName or ""
				name = instance.Name or ""
			end)

			if not table.find(v3, className) then
				warn("Selected directory \"" .. name .. "\" is an unsupported service or an unrecognized object type. Converter Module: Instance ↔ Table only supports making tables from the following services: ")
				warn(v3)
				return nil
			end
		end

		local name = instance.Name
		local v10 = FetchSettings(p)
		v10.StartTime = tonumber(fn())
		local _, _ = pcall(function()
			local className = instance.ClassName

			if typeof(className) == "string" and table.find(v5, className) then
				if typeof(v10.ErrorTable) ~= "table" then
					v10.ErrorTable = {}
				end

				local v11 = "The instance to table conversion contained a " .. tostring(className) .. " object. " .. tostring(className) .. "s are not supported."

				if not table.find(v10.ErrorTable, v11) then
					table.insert(v10.ErrorTable, v11)
				end
			end
		end)

		if v10.IncludeProperties == true then
			if v10.FetchLatestPropertiesOnline == true and v9 == false then
				RecheckIfHTTPEnabled()
			end

			if v10.FetchLatestPropertiesOnline == true and v10.ShowHTTPWarning == true then
				warn("In order for Converter Module: Instance ↔ Table to fetch the latest properties from the API, HTTP service needs to be enabled.")
			end

			v10.FetchLatestPropertiesOnline = false
		end

		local v11 = FetchPreviousProperties(v10.ExcludedProperties, v10.OnlySaveWritableProperties)

		if not v8 then
			v8 = MainConvertModule:FetchProperties(v10.FetchLatestPropertiesOnline, {}, false, true)
		end

		if not v11 then
			v11 = MainConvertModule:FetchProperties(
				v10.FetchLatestPropertiesOnline,
				v10.ExcludedProperties,
				v10.ShowHTTPWarning,
				not v10.OnlySaveWritableProperties
			)
			InsertPreviousProperties(v10.ExcludedProperties, v11, v10.OnlySaveWritableProperties)
		end

		local v12 = {}
		DoForEveryObject(instance, v12, v11, v10, instance)

		local function GetStringSizeInBytes(value, _, p2)
			if not value or typeof(value) ~= "string" and typeof(value) ~= "number" then
				warn("Got a non-string while trying to index string size in bytes.")
				return ""
			end

			local v13

			if value >= 1000 then
				value /= 1000

				if value >= 1000 then
					value /= 1000

					if value >= 1000 then
						value /= 1000

						if value >= 1000 then
							value /= 1000
							v13 = "TB"
						else
							v13 = "GB"
						end
					else
						v13 = "MB"
					end
				else
					v13 = "KB"
				end
			else
				v13 = "BYTES"
			end

			if p2 ~= true then
				value = math.floor(value * 100) / 100
			end

			return tostring(value) .. " " .. v13
		end

		if typeof(v10.ErrorTable) == "table" and v10.PrintCompatibilityErrors == true then
			for _, v13 in ipairs(v10.ErrorTable) do
				warn(v13)
			end
		end

		local v13 = false
		pcall(function()
			v13 = RunService:IsEdit()
		end)
		local v14 = RunService:IsClient() and not (RunService:IsStudio() and v13) and "client" or RunService:IsStudio() and "Roblox Studio handler" or "server"

		if v10.PrintCompletionTime == true and typeof(v10.StartTime) == "number" and typeof(instance) == "Instance" then
			local v15 = math.round((tonumber(fn()) - v10.StartTime) * 10) / 10
			local v16

			if v15 >= 60 then
				v15 = math.round(v15 / 60 * 100) / 100

				if v15 > 1 then
					v16 = "minutes"
				else
					v16 = "minute"
				end
			else
				v16 = "seconds"
			end

			local v17 = tostring(v15)
			print(
				"SL_",
				"It took the " .. v14 .. " " .. v17 .. " " .. v16 .. " to convert the object \"" .. name .. "\" into a table."
			)
		end

		local HttpService = game:GetService("HttpService")
		local v15 = string.len((tostring(HttpService:JSONEncode(v12))))
		local stringSizeInBytes = GetStringSizeInBytes(v15)
		local v17 = true

		if v15 >= 34000000 and v10.DataStoreFriendly == true and v13 == false then
			warn("TOO MANY MODELS!  Your game may not save correctly.")
			warn(" See Tip#10 in the Studio Lite Community description for ways to save space.")
			v17 = false
		elseif v15 >= 20000000 and v10.DataStoreFriendly == true and v13 == false then
			warn("NOTE: Your game is very large and will take very long to save and publish.")
			warn(" See Tip#10 in the Studio Lite Community description for ways to save space.")
		end

		print("SL_ Current Size: " .. stringSizeInBytes .. "  (Maximum is 36 MB).")
		return v12, v17
	else
		if not v9 then
			warn("Supplied object is nil or not an object.")
		end

		return nil
	end
end

function FormatValue(data, p)
	if typeof(data) ~= "table" then
		return nil
	end

	local cframe = nil
	local _, _ = pcall(function()
		if p == "CFrame" then
			cframe = CFrame.new(
				data.X,
				data.Y,
				data.Z,
				data.R00,
				data.R01,
				data.R02,
				data.R10,
				data.R11,
				data.R12,
				data.R20,
				data.R21,
				data.R22
			)
		elseif p == "EnumItem" then
			local enumType = tostring(data.EnumType)
			local name = tostring(data.Name)
			cframe = Enum[enumType][name]
		elseif p == "BrickColor" then
			cframe = BrickColor.new((tostring(data.BrickColor)))
		elseif p == "Color3" then
			local scale = data.Scale
			cframe = Color3.new(data.R / scale, data.G / scale, data.B / scale)
		elseif p == "Vector3" then
			cframe = Vector3.new(data.X, data.Y, data.Z)
		elseif p == "Vector2" then
			cframe = Vector2.new(data.X, data.Y)
		elseif p == "UDim" then
			cframe = UDim.new(data.Scale, data.Offset)
		elseif p == "UDim2" then
			cframe = UDim2.new(data.X.Scale, data.X.Offset, data.Y.Scale, data.Y.Offset)
		elseif p == "NumberRange" then
			cframe = NumberRange.new(data.Min, data.Max)
		elseif p == "Font" then
			local v9 = "NONE"
			pcall(function()
				if typeof(data.FontWeight) == "string" and typeof(data.FontStyle) == "string" and typeof(Enum.FontWeight[data.FontWeight]) == "EnumItem" and typeof(Enum.FontStyle[data.FontStyle]) == "EnumItem" then
					v9 = "string"
				end
			end)

			if v9 == "string" then
				cframe = Font.new(data.FontFamily, Enum.FontWeight[data.FontWeight], Enum.FontStyle[data.FontStyle])
			end
		elseif p == "NumberSequence" then
			local numberSequenceKeypoints = {}

			for i = 1, GetDictionaryLength(data) do
				if not (data[tostring(i)].Time and data[tostring(i)].Value and data[tostring(i)].Envelope) then
					continue
				end

				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(
						data[tostring(i)].Time,
						data[tostring(i)].Value,
						data[tostring(i)].Envelope
					)
				)
			end

			cframe = NumberSequence.new(numberSequenceKeypoints)
		elseif p == "ColorSequence" then
			local colorSequenceKeypoints = {}

			for i = 1, GetDictionaryLength(data) do
				if not (data[tostring(i)].Time and data[tostring(i)].R and data[tostring(i)].G) then
					continue
				end

				if not data[tostring(i)].B then
					continue
				end

				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(
						data[tostring(i)].Time,
						Color3.new(data[tostring(i)].R, data[tostring(i)].G, data[tostring(i)].B)
					)
				)
			end

			cframe = ColorSequence.new(colorSequenceKeypoints)
		elseif p == "PhysicalProperties" then
			cframe = PhysicalProperties.new(
				data.Density,
				data.Friction,
				data.Elasticity,
				data.FrictionWeight,
				data.ElasticityWeight
			)
		elseif p == "Rect" then
			cframe = Rect.new(Vector2.new(data.Min.X, data.Min.Y), Vector2.new(data.Max.X, data.Max.Y))
		elseif p == "Axes" then
			local X = data.X
			local Y = data.Y
			local Z = data.Z
			pcall(function()
				cframe = Axes.new(not X or Enum.NormalId.Left, not Y or Enum.NormalId.Top, not Z or Enum.NormalId.Front)
			end)
		elseif p == "Faces" then
			local front = data.Front
			local back = data.Back
			local right = data.Right
			local left = data.Left
			local top = data.Top
			local bottom = data.Bottom
			pcall(function()
				cframe = Faces.new(
					not front or Enum.NormalId.Front,
					not back or Enum.NormalId.Back,
					not right or Enum.NormalId.Right,
					not left or Enum.NormalId.Left,
					not top or Enum.NormalId.Top,
					not bottom or Enum.NormalId.Bottom
				)
			end)
		elseif p == "Ray" then
			cframe = Ray.new(
				Vector3.new(data.Origin.X, data.Origin.Y, data.Origin.Z),
				(Vector3.new(data.Direction.X, data.Direction.Y, data.Direction.Z))
			)
		end
	end)
	return cframe
end

function CheckIfTableIsProprietaryTagFormat(list)
	if typeof(list) ~= "table" then
		return false
	end

	local v9 = 0
	pcall(function()
		v9 = #list
	end)

	if v9 == nil or v9 <= 0 then
		return false
	end

	local v10 = false

	for k, _ in pairs(list) do
		if typeof(k) == "number" then
			continue
		end

		v10 = true
		break
	end

	return not v10
end

function CheckIfTableIsProprietaryFormat(data)
	if typeof(data) ~= "table" then
		return nil
	end

	local v9 = GetDictionaryLength(data)

	local function CheckIfTableIsSequence(items)
		if typeof(items) ~= "table" or GetDictionaryLength(items) < 1 then
			return false
		end

		local v10 = true
		local v11 = ""

		for _, item in pairs(items) do
			if typeof(item) == "table" then
				if item.Time then
					if item.Value then
						v11 = "NumberSequence"
					elseif item.R then
						v11 = "ColorSequence"
					else
						v10 = false
					end
				else
					v10 = false
				end
			else
				v10 = false
			end
		end

		return v10 ~= false and v11
	end

	local checkIfTableIsSequence = CheckIfTableIsSequence(data)

	if checkIfTableIsSequence then
		return checkIfTableIsSequence
	end

	if v9 == 1 then
		if typeof(data.BrickColor) == "string" then
			return "BrickColor"
		end
	elseif v9 == 2 then
		if typeof(data.X) == "table" and typeof(data.Y) == "table" then
			return "UDim2"
		end

		if typeof(data.X) == "number" and typeof(data.Y) == "number" then
			return "Vector2"
		end

		if typeof(data.Min) == "table" and typeof(data.Max) == "table" then
			return "Rect"
		end

		if typeof(data.Min) == "number" and typeof(data.Max) == "number" then
			return "NumberRange"
		end

		if typeof(data.Scale) == "number" and typeof(data.Offset) == "number" then
			return "UDim"
		end

		if typeof(data.Name) == "string" and typeof(data.EnumType) == "string" then
			return "EnumItem"
		end

		if typeof(data.Origin) ~= "table" or typeof(data.Direction) ~= "table" then
			return false
		end

		if data.Origin.X and data.Origin.Y and data.Origin.Z and data.Direction.X and data.Direction.Y and data.Direction.Z then
			return "Ray"
		end
	elseif v9 == 3 then
		if typeof(data.X) == "number" and typeof(data.Y) == "number" and typeof(data.Z) == "number" then
			return "Vector3"
		end

		if typeof(data.X) == "boolean" and typeof(data.Y) == "boolean" and typeof(data.Z) == "boolean" then
			return "Axes"
		end

		if typeof(data.FontFamily) == "string" and typeof(data.FontWeight) == "string" and typeof(data.FontStyle) == "string" then
			return "Font"
		end
	elseif v9 == 4 then
		if typeof(data.R) == "number" and typeof(data.G) == "number" and typeof(data.B) == "number" and typeof(data.Scale) == "number" then
			return "Color3"
		end
	elseif v9 == 5 then
		if typeof(data.Density) == "number" and typeof(data.Friction) == "number" and typeof(data.Elasticity) == "number" and typeof(data.FrictionWeight) == "number" and typeof(data.ElasticityWeight) == "number" then
			return "PhysicalProperties"
		end
	elseif v9 == 6 then
		if typeof(data.Top) == "boolean" and typeof(data.Bottom) == "boolean" and typeof(data.Left) == "boolean" and typeof(data.Right) == "boolean" and typeof(data.Front) == "boolean" and typeof(data.Back) == "boolean" then
			return "Faces"
		end
	else
		if v9 ~= 12 then
			return false
		end

		if typeof(data.X) == "number" and typeof(data.Y) == "number" and typeof(data.Z) == "number" and typeof(data.R00) == "number" and typeof(data.R01) == "number" and typeof(data.R02) == "number" and typeof(data.R10) == "number" and typeof(data.R11) == "number" and typeof(data.R12) == "number" and typeof(data.R20) == "number" and typeof(data.R21) == "number" and typeof(data.R22) == "number" then
			return "CFrame"
		end
	end

	return false
end

function SmoothAllSurfaces(part)
	if not (typeof(part) == "Instance" and part:IsA("BasePart")) then
		return
	end

	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.LeftSurface = Enum.SurfaceType.Smooth
	part.RightSurface = Enum.SurfaceType.Smooth
	part.FrontSurface = Enum.SurfaceType.Smooth
	part.BackSurface = Enum.SurfaceType.Smooth
end

function DoForEveryInstanceTable(parent, p, p2, state, list, name)
	if not (typeof(p) == "table" and typeof(p2) == "table" and parent) then
		return
	end

	local className = parent.ClassName
	local specificExcludedProperty = state.SpecificExcludedProperties[className]
	local v9 = typeof(specificExcludedProperty) ~= "table" and {} or specificExcludedProperty

	if state.IncludeProperties == false then
		state.ExcludedProperties = {}
		v9 = {}
	end

	for k, v10 in pairs(p) do
		local v11 = p2[className]

		if typeof(v11) == "table" then
			if table.find(v11, k) then
				local v12 = nil
				local v13 = k
				local success, _ = pcall(function()
					v12 = parent[v13]
				end)

				if success then
					local typeName = typeof(v12)

					if (typeof(v10) == typeName or typeof(v10) == "PhysicalProperties") and not p.EnumType then
						if state.IncludeProperties == true then
							local v14 = k
							local v15 = v10
							local success2, result = pcall(function()
								if not (table.find(v9, v14) or table.find(state.ExcludedProperties, v14)) then
									parent[v14] = v15
								end
							end)

							if not (success2 or string.find(tostring(result), "read only") or string.find(
								tostring(result),
								"write access"
							) or string.find(tostring(result), "cannot write")) then
								warn("Error setting a property. " .. result)
							end
						end
					elseif typeof(v10) == "table" then
						if CheckIfTableIsProprietaryFormat(v10) ~= false then
							local v14 = FormatValue(v10, CheckIfTableIsProprietaryFormat(v10))

							if (typeof(v14) == typeName or typeof(v14) == "PhysicalProperties") and state.IncludeProperties == true then
								local v15 = k
								local v16 = v14
								local success2, result = pcall(function()
									if not (table.find(v9, v15) or table.find(state.ExcludedProperties, v15)) then
										parent[v15] = v16
									end
								end)

								if not (success2 or string.find(tostring(result), "read only") or string.find(
									tostring(result),
									"write access"
								) or string.find(tostring(result), "cannot write")) then
									warn("Error setting a property. " .. result)
								end
							end
						end
					elseif (typeof(parent[k]) == "nil" or typeof(parent[k]) == "Instance") and typeof(v10) == "string" then
						if v10:sub(1, 4) == "game" or v10:sub(1, 4) == "self" then
							if not table.find(v9, k) and not table.find(state.ExcludedProperties, k) and state.IncludeProperties == true then
								table.insert(list, { parent, k, v10 })
							end
						else
							local v14 = k
							local v15 = v10
							local success2, result = pcall(function()
								if state.IncludeAttributes == true then
									parent:SetAttribute(tostring(v14), v15)
								end
							end)

							if not (success2 or string.find(
								string.lower((tostring(result))),
								"instance is not a supported attribute type"
							)) then
								warn("Error setting an attribute. " .. result)
							end
						end
					elseif typeof(parent[k]) == "EnumItem" and typeof(v10) == "string" then
						if not table.find(v9, k) and not table.find(state.ExcludedProperties, k) and state.IncludeProperties == true then
							local v14 = k
							local v15 = tostring(parent[k].EnumType)
							local v16 = v10
							local success2, result = pcall(function()
								parent[v14] = Enum[v15][v16]
							end)

							if not (success2 or string.find(tostring(result), "read only") or string.find(
								tostring(result),
								"write access"
							) or string.find(tostring(result), "cannot write")) then
								warn("Error setting an Enum property. " .. result)
							end
						end
					elseif typeof(parent[k]) == "EnumItem" and typeof(v10) == "number" then
						if not table.find(v9, k) and not table.find(state.ExcludedProperties, k) and state.IncludeProperties == true then
							tostring(parent[k].EnumType)
							local v14 = k
							local v15 = v10
							local success2, result = pcall(function()
								parent[v14] = v15
							end)

							if not (success2 or string.find(tostring(result), "read only") or string.find(
								tostring(result),
								"write access"
							) or string.find(tostring(result), "cannot write")) then
								warn("Error setting an Enum property. " .. result)
							end
						end
					elseif typeof(parent[k]) == "BrickColor" and typeof(v10) == "string" then
						if not table.find(v9, k) and not table.find(state.ExcludedProperties, k) and state.IncludeProperties == true then
							local v14 = k
							local v15 = v10
							local success2, result = pcall(function()
								parent[v14] = BrickColor.new(v15)
							end)

							if not (success2 or string.find(tostring(result), "read only") or string.find(
								tostring(result),
								"write access"
							) or string.find(tostring(result), "cannot write")) then
								warn("Error setting an BrickColor property. " .. result)
							end
						end
					else
						local v14 = v10
						local v15 = k
						local success2, result = pcall(function()
							if v14 ~= nil and state.IncludeAttributes == true then
								parent:SetAttribute(tostring(v15), v14)
							end
						end)

						if not (success2 or string.find(
							string.lower((tostring(result))),
							"instance is not a supported attribute type"
						)) then
							local v16 = {}
							local copy2 = DeepCopy(state)
							state.DataStoreFriendly = true
							SafelyAddToTable(v16, "NewTemporaryMainValue", v10, copy2)

							if typeof(v16.NewTemporaryMainValue) == "table" then
								local v17 = nil
								local v18 = pcall(function()
									v17 = Instance.new(state.DefaultInstanceType)
								end)

								if not (v17 and v18) then
									v17 = Instance.new("Folder")
								end

								v17.Name = tostring(k)
								v17.Parent = parent
								DoForEveryInstanceTable(v17, v16.NewTemporaryMainValue, p2, state, list, (tostring(k)))
							end

							if state.PrintCompatibilityErrors == true then
								warn("Error setting an attribute. " .. result .. " Created an object (DefaultInstanceType) with its attributes set to the original attempt's data.")
							end
						end
					end
				end
			elseif typeof(v10) == "table" then
				if v10.ClassName and k ~= "[TAGS]" then
					local v12 = nil
					local v13 = v10

					if not pcall(function()
						if v13.ClassName == "MeshPart" and state.IncludeProperties == true then
							if v13.MeshId and typeof(state.ReferenceMeshes[v13.MeshId]) == "Instance" then
								local success, result = pcall(function()
									v12 = state.ReferenceMeshes[v13.MeshId]:clone()

									if p2.MeshPart then
										if not meshPart then
											meshPart = Instance.new("MeshPart")
										end

										for k2, v14 in pairs(p2.MeshPart) do
											if not (v14 ~= "MeshId" and typeof(v14) == "string") then
												continue
											end

											local v15 = v14
											local success2, result2 = pcall(function()
												if meshPart[v15] ~= nil and v12[v15] ~= meshPart[v15] then
													v12[v15] = meshPart[v15]
												elseif meshPart[v15] == nil and v12[v15] ~= nil then
													v12[v15] = nil
												end
											end)
										end
									end
								end)

								if not success then
									if typeof(state.ErrorTable) ~= "table" then
										state.ErrorTable = {}
									end

									if not table.find(
										state.ErrorTable,
										"Converter Module: Instance ↔ Table ran into an error cloning one or more MeshParts."
									) then
										table.insert(
											state.ErrorTable,
											"Converter Module: Instance ↔ Table ran into an error cloning one or more MeshParts."
										)
									end

									if state.IncludeProperties == true then
										v12 = Instance.new(v13.ClassName)
									else
										v12 = Instance.new(state.DefaultInstanceType)
									end
								end
							elseif state.AutoConvertMeshParts ~= true then
								v12 = Instance.new(v13.ClassName)
							elseif v13.MeshId and v13.MeshId ~= "" then
								v12 = AssetService:CreateMeshPartAsync(Content.fromUri(v13.MeshId))
							else
								v12 = Instance.new(v13.ClassName)
							end
						elseif state.IncludeProperties == true then
							if v13.ClassName == "SurfaceAppearance" and v7 == false then
								v12 = Instance.new(state.DefaultInstanceType)
							else
								v12 = Instance.new(v13.ClassName)
							end
						else
							v12 = Instance.new(state.DefaultInstanceType)
						end
					end) then
						v12 = Instance.new("Folder")
					end

					if v12 then
						if v10.ClassName == "Script" and v10.RunContext and v10.RunContext.Name and v10.RunContext.Name == "Client" then
							v12 = script:WaitForChild("TemplateRunContextClientScript"):Clone()
							v12.Name = "Script"
						end

						if v12:IsA("BasePart") then
							v12.TopSurface = Enum.SurfaceType.Smooth
							v12.BottomSurface = Enum.SurfaceType.Smooth
						end

						local success, result = pcall(function()
							v12.Parent = parent
						end)

						if not success then
							warn(result, v12.Name, v12.ClassName, v12.Parent, parent:GetFullName(), parent.ClassName)
						end

						if typeof(v10.Name) == "string" then
							v12.Name = v10.Name
						else
							v12.Name = tostring(k)
						end

						if v12:IsA("BasePart") and state.AutoSmoothParts == true then
							SmoothAllSurfaces(v12)
						end

						if state.IncludeProperties == false then
							for k2, _ in pairs(v10) do
								if not (typeof(p2[v10.ClassName]) == "table" and table.find(p2[v10.ClassName], k2) and k2 ~= "ClassName") then
									continue
								end

								v10[k2] = nil
							end
						end

						DoForEveryInstanceTable(v12, v10, p2, state, list, (tostring(k)))
					end
				elseif k == "[TAGS]" then
					if state.IncludeTags == true and CheckIfTableIsProprietaryTagFormat(v10) then
						for _, tag in pairs(v10) do
							if typeof(state.ExcludedTags) ~= "table" then
								state.ExcludedTags = {}
							end

							if not table.find(state.ExcludedTags, tag) then
								CollectionService:AddTag(parent, tag)
							end
						end
					end
				else
					local v12 = v10
					local v13 = k
					local v14 = v10
					local success, result = pcall(function()
						if not table.find(v9, v13) and not table.find(state.ExcludedProperties, v13) and not table.find(
							v4,
							v13
						) and typeof(v14) == "table" then
							v12 = FormatValue(v14, CheckIfTableIsProprietaryFormat(v14))
						end
					end)

					if v12 == v10 or v12 == nil then
						local v15 = nil
						local defaultInstanceType = state.DefaultInstanceType

						if not pcall(function()
							v15 = Instance.new((tostring(defaultInstanceType)))
						end) then
							state.DefaultInstanceType = "Folder"
							v15 = Instance.new("Folder")
						end

						if v15 then
							v15.Parent = parent

							if typeof(v10.Name) == "string" then
								v15.Name = v10.Name
							else
								v15.Name = tostring(k)
							end

							if v15:IsA("BasePart") and state.AutoSmoothParts == true then
								SmoothAllSurfaces(v15)
							end

							DoForEveryInstanceTable(v15, v10, p2, state, list, (tostring(k)))
						end
					else
						local v15 = k
						local success2, _ = pcall(function()
							if state.IncludeAttributes == true then
								parent:SetAttribute(tostring(v15), v12)
							end
						end)

						if not success2 and k ~= "RenderFidelity" and k ~= "CollisionFidelity" then
							local v16 = nil
							local defaultInstanceType = state.DefaultInstanceType

							if not pcall(function()
								v16 = Instance.new((tostring(defaultInstanceType)))
							end) then
								state.DefaultInstanceType = "Folder"
								v16 = Instance.new("Folder")
							end

							if v16 then
								v16.Parent = parent
								v16.Name = tostring(k)
							end

							for k2, item in pairs(v10) do
								if typeof(item) == "table" then
									DoForEveryInstanceTable(v16, item, p2, state, list, (tostring(k2)))
								else
									local v18 = k2
									local v19 = item
									local success3, result2 = pcall(function()
										if state.IncludeAttributes == true then
											v16:SetAttribute(tostring(v18), v19)
										end
									end)

									if not success3 then
										warn("Error setting an attribute. " .. result2)
									end
								end
							end
						end
					end

					if not (success or string.find(
						string.lower((tostring(result))),
						"instance is not a supported attribute type"
					)) then
						warn("Error setting an attribute. " .. result)
					end
				end
			else
				local v12 = k
				local v13 = v10
				local success, result = pcall(function()
					if not table.find(v9, v12) and not table.find(state.ExcludedProperties, v12) and not table.find(
						v4,
						v12
					) and v13 ~= nil and state.IncludeAttributes == true then
						parent:SetAttribute(tostring(v12), v13)
					end
				end)

				if success or string.find(
					string.lower((tostring(result))),
					"instance is not a supported attribute type"
				) then
					if not success and string.find(
						string.lower((tostring(result))),
						"instance is not a supported attribute type"
					) then
						local v14 = ConvertObjectToString(parent, v10, parent)

						if typeof(v14) == "string" then
							parent:SetAttribute(tostring(k), v14)
						end
					end
				else
					local v14 = {}
					local copy2 = DeepCopy(state)
					state.DataStoreFriendly = true
					SafelyAddToTable(v14, "NewTemporaryMainValue", v10, copy2)

					if typeof(v14.NewTemporaryMainValue) == "table" then
						local v15 = nil
						local v16 = pcall(function()
							v15 = Instance.new(state.DefaultInstanceType)
						end)

						if not (v15 and v16) then
							v15 = Instance.new("Folder")
						end

						v15.Name = tostring(k)
						v15.Parent = parent
						DoForEveryInstanceTable(v15, v14.NewTemporaryMainValue, p2, state, list, (tostring(k)))

						if state.PrintCompatibilityErrors == true then
							warn("Error setting an attribute. " .. result .. ". Created a " .. tostring(v15.ClassName) .. " object inside \"" .. tostring(parent.Name) .. "\" with formatted attributes.")
						end
					end
				end
			end
		else
			warn("Error fetching properties for the Class: " .. className)
		end
	end

	if parent.Name == parent.ClassName and typeof(name) == "string" then
		parent.Name = name
	end
end

function DecodeLocation(value, parent, state)
	if typeof(value) ~= "string" or typeof(parent) ~= "Instance" then
		return ""
	end

	if value:sub(1, 5) == "game." then
		while parent.Parent ~= nil do
			parent = parent.Parent
		end
	end

	for i = 2, #value:split(".") do
		local v9 = parent
		local name = parent.Name

		if value:split(".")[i] == "Parent" then
			local success, _ = pcall(function()
				parent = parent.Parent
			end)

			if not success then
				parent = nil
			end
		else
			local v10 = i
			local success, _ = pcall(function()
				parent = parent:FindFirstChild(value:split(".")[v10])
			end)

			if not success then
				parent = nil
			end
		end

		if parent then
			continue
		end

		if state.PrintObjectVariableErrors ~= true or not v9 then
			break
		end

		if typeof(state.VariableErrorTable) ~= "table" then
			state.VariableErrorTable = {}
		end

		if typeof(state.ErroredVariables) ~= "table" then
			state.ErroredVariables = {}
		end

		local v10 = "While attempting to set an object property, the converter could not find an instance called \"" .. value:split(".")[i] .. "\" inside of \"" .. tostring(name) .. "\". Since the object locater uses FindFirstChild(), make sure \"" .. tostring(name) .. "\" is a unique name."
		print(v10)

		if not table.find(state.VariableErrorTable, v10) then
			table.insert(state.VariableErrorTable, v10)
		end

		if table.find(state.ErroredVariables, v9) then
			break
		end

		table.insert(state.ErroredVariables, { v9, value:split(".")[i] })
		break
	end

	return parent
end

function GatherMeshIDs(instance, meshIds)
	if typeof(instance) ~= "table" or typeof(meshIds) ~= "table" then
		return
	end

	if instance.ClassName == "MeshPart" and typeof(instance.MeshId) == "string" and not table.find(
		meshIds,
		instance.MeshId
	) then
		table.insert(meshIds, instance.MeshId)
	end

	for _, v9 in pairs(instance) do
		if typeof(v9) == "table" then
			GatherMeshIDs(v9, meshIds)
		end
	end
end

local meshPart2 = Instance.new("MeshPart")

function GatherMeshes(items, clones, p)
	if typeof(items) ~= "table" or typeof(clones) ~= "table" then
		return
	end

	local descendants = game:GetDescendants()

	for _, item in pairs(items) do
		if not (typeof(item) == "string" and clones[item] == nil) then
			continue
		end

		local folder = Instance.new("Folder")
		local v9 = false

		for _, descendant in pairs(descendants) do
			if v9 == true and p == false then
				break
			else
				local part = descendant
				local v10 = item
				local parent = folder
				local _, _ = pcall(function()
					if part:IsA("MeshPart") and part.MeshId == v10 then
						if clones[v10] == nil then
							local clone = part:clone()
							clone:ClearAllChildren()

							for k, v12 in pairs(clone:GetAttributes()) do
								clone:SetAttribute(k, nil)
							end

							for k, tag in pairs(CollectionService:GetTags(clone)) do
								CollectionService:RemoveTag(clone, tag)
							end

							local meshPart3 = v8.MeshPart

							if typeof(meshPart3) == "table" then
								for k, v12 in pairs(meshPart3) do
									if v12 == "MeshId" then
										continue
									end

									local v13 = v12
									local success, result = pcall(function()
										if meshPart2[v13] ~= clone[v13] then
											clone[v13] = meshPart2[v13]
										end
									end)
								end
							end

							clones[v10] = clone
							v9 = true
						end

						if p == true then
							for i, surfaceAppearance2 in pairs(part:GetDescendants()) do
								if not surfaceAppearance2:IsA("SurfaceAppearance") then
									continue
								end

								local v12 = true
								local v13 = pcall(function()
									local colorMap = surfaceAppearance.ColorMap
								end)

								if v13 == true then
									local v14 = surfaceAppearance2
									local success, result = pcall(function()
										for i2, child in pairs(parent:GetChildren()) do
											if not (child.AlphaMode == v14.AlphaMode and child.ColorMap == v14.ColorMap and child.MetalnessMap == v14.MetalnessMap and child.NormalMap == v14.NormalMap) then
												continue
											end

											if child.RoughnessMap ~= v14.RoughnessMap then
												continue
											end

											v12 = false
											break
										end
									end)
								end

								if not (v12 == true and v13 == true) then
									continue
								end

								local clone_2 = surfaceAppearance2:clone()
								clone_2.Parent = parent
							end
						end
					end
				end)
			end
		end

		if typeof(clones[item]) == "Instance" then
			for _, child in pairs(folder:GetChildren()) do
				child:ClearAllChildren()
				child.Parent = clones[item]
			end
		end

		folder:Destroy()
	end
end

function MainConvertModule:ConvertToInstance(instance, p)
	v7 = pcall(function()
		surfaceAppearance.ColorMap = ""
	end)
	local RunService = game:GetService("RunService")
	local v9 = false
	pcall(function()
		v9 = RunService:IsEdit()
	end)
	local _ = RunService:IsClient() and RunService:IsStudio()

	if typeof(instance) == "table" then
		if typeof(p) ~= "table" and typeof(p) ~= "nil" then
			warn("Recieved ConversionSettings as a " .. string.upper((tostring((typeof(p))))) .. " format. ConversionSettings need to be in a dictionary format. ")
			return nil
		end

		local v10 = FetchSettings(p)
		v10.StartTime = tonumber(fn())

		if v10.IncludeProperties == true then
			if v10.FetchLatestPropertiesOnline == true and v9 == false then
				RecheckIfHTTPEnabled()
			end

			if v10.FetchLatestPropertiesOnline == true and v10.ShowHTTPWarning == true then
				warn("In order for Converter Module: Instance ↔ Table to fetch the latest properties from the API, HTTP service needs to be enabled.")
			end

			v10.FetchLatestPropertiesOnline = false
		end

		local v11 = FetchPreviousProperties({})

		if not v8 then
			v8 = MainConvertModule:FetchProperties(v10.FetchLatestPropertiesOnline, {}, false, true)
		end

		if not v11 then
			v11 = MainConvertModule:FetchProperties(v10.FetchLatestPropertiesOnline, {}, v10.ShowHTTPWarning, true)
			InsertPreviousProperties({}, v11, false)
		end

		local v12 = nil
		local className = nil
		local copy2 = DeepCopy(instance)

		if typeof(v10.CleanupTables) ~= "table" then
			v10.CleanupTables = {}
		end

		if typeof(v10.MeshIDs) ~= "table" then
			v10.MeshIDs = {}
		end

		if typeof(v10.ReferenceMeshes) ~= "table" then
			v10.ReferenceMeshes = copy or {}
		end

		table.insert(v10.CleanupTables, copy2)

		if v10.IncludeProperties == true then
			className = instance.ClassName
		elseif v10.IncludeProperties == false then
			className = v10.DefaultInstanceType
		end

		GatherMeshIDs(copy2, v10.MeshIDs)
		GatherMeshes(v10.MeshIDs, v10.ReferenceMeshes, v10.CarryOverSurfaceAppearances)
		copy = DeepCopy(v10.ReferenceMeshes)

		if className == nil then
			className = v10.DefaultInstanceType
		end

		local v13 = pcall(function()
			if className == "MeshPart" then
				if instance.MeshId and typeof(v10.ReferenceMeshes[instance.MeshId]) == "Instance" then
					local _, _ = pcall(function()
						v12 = v10.ReferenceMeshes[instance.MeshId]:clone()

						if v11.MeshPart then
							if not meshPart then
								meshPart = Instance.new("MeshPart")
							end

							for _, v14 in pairs(v11.MeshPart) do
								if not (v14 ~= "MeshId" and typeof(v14) == "string") then
									continue
								end

								local v15 = v14
								local _, _ = pcall(function()
									if meshPart[v15] ~= nil and v12[v15] ~= meshPart[v15] then
										v12[v15] = meshPart[v15]
									elseif meshPart[v15] == nil and v12[v15] ~= nil then
										v12[v15] = nil
									end
								end)
							end
						end
					end)
				elseif v10.AutoConvertMeshParts ~= true then
					v12 = Instance.new(className)
				elseif instance.MeshId and instance.MeshId ~= "" then
					v12 = AssetService:CreateMeshPartAsync(Content.fromUri(instance.MeshId))
				else
					v12 = Instance.new(className)
				end
			elseif table.find(v3, className) then
				if className ~= "Terrain" then
					v12 = game:GetService(className)
					return
				end

				local Workspace = game:GetService("Workspace")
				v12 = Workspace.Terrain
			elseif className == "SurfaceAppearacne" and v7 == false then
				v12 = Instance.new(v10.DefaultInstanceType)
			else
				v12 = Instance.new(className)
			end
		end)

		if not v12 or v13 == false then
			v12 = Instance.new("Folder")
			v10.DefaultInstanceType = "Folder"
		end

		local v14 = {}

		if typeof(instance.Name) == "string" then
			v12.Name = instance.Name
		end

		if v12:IsA("BasePart") and v10.AutoSmoothParts == true then
			SmoothAllSurfaces(v12)
		end

		DoForEveryInstanceTable(v12, copy2, v11, v10, v14)

		for _, v15 in pairs(v14) do
			if not (typeof(v15) == "table" and v15[1] and v15[2] and v15[3]) then
				continue
			end

			local v16 = DecodeLocation(v15[3], v15[1], v10)
			local v17 = v15
			local success, result = pcall(function()
				v17[1][tostring(v17[2])] = v16

				if v17[3] ~= nil and v17[3] ~= "" and v17[3]:sub(1, 5) ~= "self." then
					if v17[1]:GetAttribute("SL_ObjectProps") then
						v17[1]:SetAttribute(
							"SL_ObjectProps",
							v17[1]:GetAttribute("SL_ObjectProps") .. "," .. tostring(v17[2])
						)
					else
						v17[1]:SetAttribute("SL_ObjectProps", (tostring(v17[2])))
					end
				end
			end)

			if success or string.find(tostring(result), "read only") or string.find(tostring(result), "write access") or string.find(
				tostring(result),
				"cannot write"
			) then
				continue
			end

			warn("Error setting a object property. " .. result, v16:GetFullName(), v16.ClassName)
		end

		if typeof(v10.CleanupTables) == "table" then
			if v10.PrintCleanupAmount == true then
				print("Cleaned up " .. tostring(math.floor(string.len((tostring(game.HttpService:JSONEncode(v10.CleanupTables)))) / 1000) / 1000) .. " MB of conversion background memory.")
			end

			for k, cleanupTable in pairs(v10.CleanupTables) do
				if cleanupTable and typeof(cleanupTable) == "table" then
					local ClearDeepestVal
					local ClearDeepestVal2 = ClearDeepestVal

					ClearDeepestVal = function(cleanupTable2)
						if typeof(cleanupTable2) ~= "table" then
							return
						end

						for k2, item in pairs(cleanupTable2) do
							if typeof(item) == "table" then
								ClearDeepestVal2(item)
							end

							if cleanupTable2 then
								cleanupTable2[k2] = nil
							end
						end
					end

					ClearDeepestVal(cleanupTable)
				end

				v10.CleanupTables[k] = nil
			end
		end

		if typeof(v10.VariableErrorTable) == "table" and v10.PrintObjectVariableErrors == true then
			for _, v15 in ipairs(v10.VariableErrorTable) do
				warn(v15)
			end
		end

		if typeof(v10.ErroredVariables) == "table" and v10.PrintObjectVariableErrors == true and GetDictionaryLength(v10.ErroredVariables) > 0 then
			warn("List of objects (clickable) and the object name that couldn't be found within them: ")
			warn(v10.ErroredVariables)
		end

		local v15 = false
		pcall(function()
			v15 = RunService:IsEdit()
		end)
		local v16 = RunService:IsClient() and not (RunService:IsStudio() and v15) and "client" or RunService:IsStudio() and "Roblox Studio handler" or "server"

		if v10.PrintCompletionTime ~= true or typeof(v10.StartTime) ~= "number" or typeof(v12) ~= "Instance" then
			return v12
		end

		local v17 = math.round((tonumber(fn()) - v10.StartTime) * 10) / 10
		local v18

		if v17 >= 60 then
			v17 = math.round(v17 / 60 * 100) / 100

			if v17 > 1 then
				v18 = "minutes"
			else
				v18 = "minute"
			end
		else
			v18 = "seconds"
		end

		local v19 = tostring(v17)
		print(
			"SL_",
			"It took the " .. v16 .. " " .. v19 .. " " .. v18 .. " to convert \"" .. v12.Name .. "\" into an object."
		)
		return v12
	else
		if not v9 then
			warn("Supplied table is nil or not a dictionary.")
		end

		return nil
	end
end

function MainConvertModule.ConvertToObject(_, p, p2)
	return MainConvertModule:ConvertToInstance(p, p2)
end

function MainConvertModule.TableToObject(_, p, p2)
	return MainConvertModule:ConvertToInstance(p, p2)
end

function MainConvertModule.DictionaryToObject(_, p, p2)
	return MainConvertModule:ConvertToInstance(p, p2)
end

function MainConvertModule.ArrayToObject(_, p, p2)
	return MainConvertModule:ConvertToInstance(p, p2)
end

function MainConvertModule.ConvertToDictionary(_, p, p2)
	return MainConvertModule:ConvertToTable(p, p2)
end

function MainConvertModule.ObjectToDictionary(_, p, p2)
	return MainConvertModule:ConvertToTable(p, p2)
end

function MainConvertModule.ConvertToArray(_, p, p2)
	return MainConvertModule:ConvertToTable(p, p2)
end

function MainConvertModule.ObjectToArray(_, p, p2)
	return MainConvertModule:ConvertToTable(p, p2)
end

function MainConvertModule.ObjectToTable(_, p, p2)
	return MainConvertModule:ConvertToTable(p, p2)
end

function MainConvertModule.Convert(_, value, p)
	if typeof(value) == "table" then
		return MainConvertModule:ConvertToInstance(value, p)
	end

	if typeof(value) == "Instance" then
		return MainConvertModule:ConvertToTable(value, p)
	end

	return nil
end

return MainConvertModule