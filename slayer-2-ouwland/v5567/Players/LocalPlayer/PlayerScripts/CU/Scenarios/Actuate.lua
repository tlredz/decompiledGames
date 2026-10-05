local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local cleanit = require(ReplicatedStorage.Packages.cleanit)
require(ReplicatedStorage.CAM.Global.Types.ScenariosType)
local insert = table.insert
local find = table.find
local remove = table.remove
local v = {}

for _, moduleScript in ipairs(script.Scenarios:QueryDescendants("ModuleScript:not([$ignore])")) do
	insert(v, require(moduleScript))
end

local v2 = cleanit.new()
local v3 = {}
local diedConnection = nil

function updCharacter(instance)
	v2:Clean()

	if diedConnection ~= nil then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function IsReady(child)
		local function updateScenarios()
			local v4 = {}

			for _, v5 in ipairs(v) do
				if not (v5.Activators == nil or v5.Activators.EquippedAccessory == nil or child:FindFirstChild(v5.Activators.EquippedAccessory) ~= nil) then
					continue
				end

				insert(v4, v5)
				v5.Do(localPlayer, instance)
			end

			for _, v5 in ipairs(v3) do
				local index = find(v4, v5)

				if index ~= nil then
					continue
				end

				v5.Stop(localPlayer, instance)
				remove(v4, nil)
			end

			v3 = v4
		end

		v2:Connect(child.ChildAdded, updateScenarios)
		v2:Connect(child.ChildRemoved, updateScenarios)
		updateScenarios()
	end

	local tool_Accessories = instance:FindFirstChild("Tool_Accessories")

	if tool_Accessories == nil then
		local childAddedConnection = nil
		childAddedConnection = instance.ChildAdded:Connect(function(child)
			if child.Name == "Tool_Accessories" then
				IsReady(child) -- equivalent call inferred; original call site unknown
				v2:Remove(childAddedConnection)
				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end
		end)
		v2:Add(childAddedConnection)
	else
		local function updateScenarios()
			local v4 = {}

			for _, v5 in ipairs(v) do
				if not (v5.Activators == nil or v5.Activators.EquippedAccessory == nil or tool_Accessories:FindFirstChild(v5.Activators.EquippedAccessory) ~= nil) then
					continue
				end

				insert(v4, v5)
				v5.Do(localPlayer, instance)
			end

			for _, v5 in ipairs(v3) do
				local index = find(v4, v5)

				if index ~= nil then
					continue
				end

				v5.Stop(localPlayer, instance)
				remove(v4, nil)
			end

			v3 = v4
		end

		v2:Connect(tool_Accessories.ChildAdded, updateScenarios)
		v2:Connect(tool_Accessories.ChildRemoved, updateScenarios)
		updateScenarios()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updHumanoid(child)
		if diedConnection ~= nil then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		diedConnection = child.Died:Connect(function()
			for _, v4 in ipairs(v3) do
				v4.Stop(localPlayer, instance)
			end

			v2:Clean()
		end)
	end

	if not instance:FindFirstChild("Humanoid") then
		diedConnection = instance.ChildAdded:Connect(function(child)
			if child.Name == "Humanoid" then
				updHumanoid(child) -- equivalent call inferred; original call site unknown
			end
		end)
		return
	end

	local humanoid = instance.Humanoid

	if diedConnection ~= nil then
		diedConnection:Disconnect()
		diedConnection = nil
	end

	diedConnection = humanoid.Died:Connect(function()
		for _, v4 in ipairs(v3) do
			v4.Stop(localPlayer, instance)
		end

		v2:Clean()
	end)
end

if localPlayer.Character ~= nil then
	updCharacter(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(updCharacter)