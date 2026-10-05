local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
require(ReplicatedStorage.Modules.Network)
return function(p)
	local v = BaseInteractable.new()

	function v.Run(p2)
		local _ = p2.State
		p.Zap:Play()
		p.Lever:Play()
	end

	for _, parent in { p } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v:ToggleState()
		end)
	end

	return v
end