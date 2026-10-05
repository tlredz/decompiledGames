local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage.Common.Utils)
return {
	Binder = function(instance)
		local maid = Utils.Maid.new()
		local v = nil

		local function updateParent()
			local parent = instance.Parent

			if not (parent.Name ~= "BinderObjectContainer" and parent ~= v) then
				return
			end

			v = parent
			local attributeNames = {}

			function maid.ClearCurrentTagsAndAttributes()
				parent:RemoveTag(instance.Name)

				for _, v2 in pairs(attributeNames) do
					parent:SetAttribute(v2, nil)
				end
			end

			parent:AddTag(instance.Name)

			for attributeName, v2 in pairs(instance:GetAttributes()) do
				if parent:GetAttribute(attributeName) ~= nil then
					break
				end

				parent:SetAttribute(attributeName, v2)
				table.insert(attributeNames, attributeName)
			end
		end

		maid:GiveTask(instance:GetAttributeChangedSignal("Parent"):Connect(updateParent))
		updateParent()
		return maid
	end
}