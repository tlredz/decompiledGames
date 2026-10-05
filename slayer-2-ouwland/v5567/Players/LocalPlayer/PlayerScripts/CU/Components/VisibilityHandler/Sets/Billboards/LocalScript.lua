local parent = script.Parent
local CollectionService = game:GetService("CollectionService")

function Individual(instance)
	local enabled = instance:FindFirstChild("Enabled")

	if enabled == nil then
		instance.Enabled = parent.Value
	else
		enabled.Value = parent.Value
	end
end

function upd()
	for _, v in pairs(CollectionService:GetTagged("Billboards")) do
		Individual(v)
	end
end

upd()
parent.Changed:Connect(upd)
CollectionService:GetInstanceAddedSignal("Billboards"):Connect(Individual)