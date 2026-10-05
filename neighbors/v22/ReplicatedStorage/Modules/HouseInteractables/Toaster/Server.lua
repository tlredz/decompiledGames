local Toaster = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Types)

function Toaster.Action(p)
	if p.State == true then
		task.wait(5)
		p.SetState(false)
	end
end

return Toaster