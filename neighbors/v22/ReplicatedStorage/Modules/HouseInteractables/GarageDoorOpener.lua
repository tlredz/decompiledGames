local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local BaseInteractable = require(script.Parent.BaseInteractable)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(_) end

	for _, parent in { p.Interactive } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 12
		clickDetector.Parent = parent
		clickDetector.MouseClick:Connect(function()
			Network:fire("ToggleGarageDoor")
		end)
	end

	return v
end