local v = {}
local RunService = game:GetService("RunService")
local enums = script:WaitForChild("Enums")
local flag = false
local EnumHandler = {
	Add = function(name, ...)
		if not RunService:IsServer() then
			error("Enum.Add is server usage only")
			return
		end

		if v[name] == nil then
			v[name] = {}
		end

		for _, v2 in pairs({ ... }) do
			if table.find(v[name], v2) == nil then
				table.insert(v[name], v2)
			end
		end

		if enums:FindFirstChild(name) == nil then
			local folder = Instance.new("Folder")
			folder.Name = name
			folder.Parent = enums
		end

		if flag then
			ReplicateEnum(name)
		end
	end
}

function ReplicateEnum(childName)
	local joined = table.concat(v[childName], "\\")
	enums:FindFirstChild(childName):SetAttribute("EnumValues", joined)
end

function EnumHandler.Remove(p, p2)
	if not RunService:IsServer() then
		error("Enum.Remove is server usage only")
		return
	end

	if v[p] == nil then
		return
	end

	local index = table.find(v[p], p2)

	if index then
		table.remove(v[p], index)

		if flag then
			ReplicateEnum(p)
		end
	end
end

local function IsWordStart(value, p)
	if p == 1 then
		return true
	end

	local v2 = string.sub(value, p - 1, p - 1)
	local v3 = string.sub(value, p, p)

	if string.match(v2, "[^%w]") == nil then
		if string.match(v2, "%l") == nil then
			return false
		else
			return string.match(v3, "%u") ~= nil
		end
	else
		return true
	end
end

local function WithinOneEdit(value, value2)
	local v2 = string.len(value)
	local v3 = string.len(value2)

	if math.abs(v2 - v3) > 1 then
		return false
	end

	local v4 = math.min(v2, v3)
	local v5 = 1

	while v5 <= v4 and string.byte(value, v5) == string.byte(value2, v5) do
		v5 += 1
	end

	if v4 < v5 then
		return true
	end

	if v2 == v3 then
		if string.sub(value, v5 + 1) == string.sub(value2, v5 + 1) then
			return true
		end

		return string.sub(value, v5, v5) == string.sub(value2, v5 + 1, v5 + 1) and string.sub(value, v5 + 1, v5 + 1) == string.sub(
			value2,
			v5,
			v5
		) and string.sub(value, v5 + 2) == string.sub(value2, v5 + 2)
	elseif v3 < v2 then
		return string.sub(value, v5 + 1) == string.sub(value2, v5)
	else
		return string.sub(value, v5) == string.sub(value2, v5 + 1)
	end
end

local function ScoreMatch(value, value2, value3)
	local v2 = string.len(value3)
	local v3 = string.find(value2, value3, 1, true)

	if v3 == 1 then
		return 1
	end

	if v2 < 2 then
		return nil
	end

	if v3 then
		while v3 do
			if IsWordStart(value, v3) then
				return 2
			else
				v3 = string.find(value2, value3, v3 + 1, true)
			end
		end

		return 3
	else
		if v2 < 4 then
			return nil
		end

		for i = 1, string.len(value) do
			if IsWordStart(value, i) and (WithinOneEdit(value3, string.sub(value2, i, i + v2 - 2)) or WithinOneEdit(
				value3,
				string.sub(value2, i, i + v2 - 1)
			) or WithinOneEdit(value3, string.sub(value2, i, i + v2))) then
				return 4
			end
		end

		return nil
	end
end

function EnumHandler.Match(p, value)
	if v[p] == nil then
		return nil
	end

	local v2 = string.lower(value)
	local v3 = {}

	for _, v4 in pairs(v[p]) do
		local rank = ScoreMatch(v4, string.lower(v4), v2)

		if rank then
			table.insert(v3, {
				Value = v4,
				Rank = rank
			})
		end
	end

	table.sort(v3, function(a, b)
		if a.Rank ~= b.Rank then
			return a.Rank < b.Rank
		end

		if string.len(a.Value) == string.len(b.Value) then
			return a.Value < b.Value
		end

		return string.len(a.Value) < string.len(b.Value)
	end)
	local result = {}

	for i, v4 in ipairs(v3) do
		result[i] = v4.Value
	end

	return result
end

function EnumHandler.List(p)
	return v[p]
end

function EnumHandler.ServerLoaded()
	return enums:GetAttribute("Loaded")
end

function EnumHandler.Load()
	if RunService:IsServer() then
		for k in pairs(v) do
			ReplicateEnum(k)
		end

		flag = true
		enums:SetAttribute("Loaded", true)
	else
		-- equivalent calls inferred from this helper; original call sites unknown
		local function parseEnum(instance)
			local name = instance.Name
			local enumValues = instance:GetAttribute("EnumValues")

			if enumValues then
				v[name] = string.split(enumValues, "\\")
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addFolder(child)
			parseEnum(child) -- equivalent call inferred; original call site unknown
			child:GetAttributeChangedSignal("EnumValues"):Connect(function()
				parseEnum(child) -- equivalent call inferred; original call site unknown
			end)
		end

		enums.ChildAdded:Connect(addFolder)

		for _, child in pairs(enums:GetChildren()) do
			addFolder(child) -- equivalent call inferred; original call site unknown
		end
	end
end

return EnumHandler