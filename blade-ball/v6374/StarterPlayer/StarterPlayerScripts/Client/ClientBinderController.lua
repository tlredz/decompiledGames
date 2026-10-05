local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Utils = require(ReplicatedStorage.Common.Utils)
local BinderCache = require(game.ReplicatedStorage.ClientGameModules.BinderCache)

for _, moduleScript in pairs(script.Parent.ClientBinders:GetChildren()) do
	local module = require(moduleScript)
	local name = moduleScript.Name
	local binder = module.Binder
	task.spawn(function()
		local v3 = "CB_" .. name
		local binder2 = Utils.Binder.new(name, function(instance)
			local maid = Utils.Maid.new()

			local function CheckParent()
				if maid.HasTag then
					if not instance:IsDescendantOf(workspace) and instance:IsDescendantOf(localPlayer) and instance:IsDescendantOf(ReplicatedStorage) then
						maid.HasTag = nil
					end
				elseif instance:IsDescendantOf(workspace) or instance:IsDescendantOf(localPlayer) or instance:IsDescendantOf(ReplicatedStorage) then
					CollectionService:AddTag(instance, v3)

					function maid.HasTag()
						CollectionService:RemoveTag(instance, v3)
					end
				end
			end

			maid:GiveTask(instance.AncestryChanged:Connect(CheckParent))
			CheckParent()
			return maid
		end)
		binder2:Start()
		BinderCache:Add(name, binder2)
		Utils.Binder.new(v3, binder):Start()
	end)

	if module.Start then
		module:Start()
	end
end