local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local plastic = Enum.Material.Plastic
local v = false
local descendantAddedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function flatten(part)
	if part.Material == plastic and part:GetAttribute("OuwSavedMaterial") == nil then
		return
	end

	if part:GetAttribute("OuwSavedMaterial") == nil then
		part:SetAttribute("OuwSavedMaterial", part.Material.Name)
	end

	part.Material = plastic
end

local function restore(instance)
	local ouwSavedMaterial = instance:GetAttribute("OuwSavedMaterial")

	if ouwSavedMaterial == nil then
		return
	end

	instance:SetAttribute("OuwSavedMaterial", nil)

	if typeof(ouwSavedMaterial) ~= "string" then
		return
	end

	local success, result = pcall(function()
		return Enum.Material[ouwSavedMaterial]
	end)

	if success and typeof(result) == "EnumItem" then
		instance.Material = result
	end
end

local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function sweep(folder, callback, p: number)
	task.spawn(function()
		local descendants = folder:GetDescendants()

		for i = 1, #descendants do
			if count ~= p then
				break
			end

			local part = descendants[i]

			if part:IsA("BasePart") then
				callback(part)
			end

			if i % 2500 == 0 then
				task.wait()
			end
		end
	end)
end

local function set(flag: boolean)
	local map = workspace:FindFirstChild("Map")

	if map == nil then
		return
	end

	local v2 = not flag

	if v2 == v then
		return
	end

	v = v2
	count += 1
	local v3 = count

	if descendantAddedConnection ~= nil then
		descendantAddedConnection:Disconnect()
		descendantAddedConnection = nil
	end

	if v2 then
		sweep(map, flatten, v3) -- equivalent call inferred; original call site unknown
		descendantAddedConnection = map.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				flatten(part) -- equivalent call inferred; original call site unknown
			end
		end)
	else
		sweep(map, restore, v3) -- equivalent call inferred; original call site unknown
	end
end

return {
	Start = function()
		if not RunService:IsClient() then
			return
		end

		local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
		local v2 = DataValue.new(SettingsKeys.Materials.Path, SettingsKeys.Materials.Default, SettingsKeys.Scope)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function push()
			set(v2:Get() ~= false)
		end

		v2.Changed:Connect(push)

		if workspace:FindFirstChild("Map") == nil then
			local childAddedConnection = nil
			childAddedConnection = workspace.ChildAdded:Connect(function(child)
				if child.Name ~= "Map" then
					return
				end

				childAddedConnection:Disconnect()
				push() -- equivalent call inferred; original call site unknown
			end)
		end

		push() -- equivalent call inferred; original call site unknown
	end
}