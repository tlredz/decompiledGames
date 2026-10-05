local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local HoverInfoController = require(ReplicatedStorage.Controllers.HoverInfoController)
return Observers.observeTagNoAncestry("HoverInfo", function(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateInfo()
		local itemKey = instance:GetAttribute("ItemKey")
		local itemType = instance:GetAttribute("ItemType")

		if itemKey and itemType then
			HoverInfoController:Add(instance, itemType, nil, itemKey)
		else
			HoverInfoController:Remove(instance)
		end
	end

	local thread = nil

	local function requestUpdateInfo()
		if thread then
			return
		end

		thread = task.defer(function()
			thread = nil
			updateInfo() -- equivalent call inferred; original call site unknown
		end)
	end

	local itemKeyChangedConnection = instance:GetAttributeChangedSignal("ItemKey"):Connect(requestUpdateInfo)
	local itemTypeChangedConnection = instance:GetAttributeChangedSignal("ItemType"):Connect(requestUpdateInfo)

	if not thread then
		thread = task.defer(function()
			thread = nil
			updateInfo() -- equivalent call inferred; original call site unknown
		end)
	end

	return function()
		itemTypeChangedConnection:Disconnect()
		itemKeyChangedConnection:Disconnect()
		HoverInfoController:Remove(instance)
	end
end)