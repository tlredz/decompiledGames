local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local uIBindersLegacy = script.Parent.UIBindersLegacy
local Utils = require(ReplicatedStorage.Common.Utils)
local BinderCache = require(ReplicatedStorage.ClientGameModules.BinderCache)
local featuresToggle = ReplicatedStorage.FeaturesToggle
local UIManager = {}

for _, child in pairs(uIBindersLegacy:GetChildren()) do
	local featureEnvironment = child:GetAttribute("FeatureEnvironment")

	if featureEnvironment then
		local child2 = featuresToggle:FindFirstChild(featureEnvironment)

		if child2 and not child2.Value then
			continue
		end
	end

	local module = require(child)

	if not module then
		continue
	end

	setmetatable(module, (getmetatable(UIManager)))
	local name = child.Name
	local binder = module.Binder

	if name and binder then
		local v = child
		local name2 = name
		local binder3 = binder
		task.spawn(function()
			if v:GetAttribute("WaitForSpawn") then
				workspace:WaitForChild("Spawn", 1000000)
			end

			local v4 = "UIN__" .. name2
			local v5 = "UI_" .. name2
			local binder2 = Utils.Binder.new(v5, function(instance)
				local maid = Utils.Maid.new()

				local function CheckParent()
					if maid.HasTag or not (instance:IsDescendantOf(workspace) or instance:IsDescendantOf(localPlayer)) then
						if maid.HasTag and not (instance:IsDescendantOf(workspace) or instance:IsDescendantOf(localPlayer)) then
							maid.HasTag = nil
						end
					else
						CollectionService:AddTag(instance, v4)

						function maid.HasTag()
							CollectionService:RemoveTag(instance, v4)
						end
					end
				end

				maid:GiveTask(instance.AncestryChanged:Connect(CheckParent))
				CheckParent()
				return maid
			end)
			binder2:Start()
			BinderCache:Add(v5, binder2)
			Utils.Binder.new(v4, binder3):Start()
		end)
	else
		warn((`UIBinder without Tag or Constructor: {child}`))
	end
end

local Observers = require(ReplicatedStorage.Packages.Observers)

local function clean(connection)
	if connection == nil then
		return
	end

	local typeName = typeof(connection)

	if typeName == "function" then
		return connection()
	elseif typeName == "thread" then
		return task.cancel(connection)
	elseif typeName == "Instance" then
		return connection:Destroy()
	elseif typeName == "RBXScriptConnection" then
		return connection:Disconnect()
	end

	if typeName == "table" then
		if typeof(connection.Destroy) == "function" then
			return connection:Destroy()
		end

		if typeof(connection.Disconnect) == "function" then
			return connection:Disconnect()
		end
	end

	error("Failed to get cleanup function for object " .. typeName .. ": " .. tostring(connection), 3)
end

local uIBinders = script.Parent:WaitForChild("UIBinders", 5)

if not uIBinders then
	return UIManager
end

for _, child in uIBinders:GetChildren() do
	local featureEnvironment = child:GetAttribute("FeatureEnvironment")

	if featureEnvironment then
		local child2 = featuresToggle:FindFirstChild(featureEnvironment)

		if child2 and not child2.Value then
			continue
		end
	end

	local v = child
	task.spawn(function()
		local success, result = pcall(require, v)

		if not (success and type(result) == "table") then
			return
		end

		Observers.observeTag(`UI_{v.Name}`, function(p)
			local binder = result.Binder(p)
			return function()
				clean(binder)
			end
		end)
	end)
end

return UIManager