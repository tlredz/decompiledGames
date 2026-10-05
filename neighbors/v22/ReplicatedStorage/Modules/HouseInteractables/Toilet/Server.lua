local Toilet = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Types)

function Toilet.Action(p)
	if p.State == true then
		task.wait(4)
		p.SetState(false)
	end
end

return Toilet