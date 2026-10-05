local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local JulyFireworkPaidItem = require(ReplicatedStorage.Modules.Shared.Item.Items.JulyFireworkPaidItem)
ItemRenderer.RegisterRenderer(ItemRenderer.TOOLS_CONTEXT, JulyFireworkPaidItem, function(object, instance)
	local conditionIcon = instance:FindFirstChild("ConditionIcon")

	if conditionIcon and object:ShowCornerIcon() then
		conditionIcon.Visible = true
		conditionIcon.Image = object:GetCornerIcon()
	end

	return true
end)
return {}