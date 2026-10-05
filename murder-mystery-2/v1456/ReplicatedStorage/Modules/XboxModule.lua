local ContextActionService = game:GetService("ContextActionService")
local XboxModule = {}

function XboxModule.Bind(p, p2, callback)
	ContextActionService:BindAction(p, function(_, p3)
		if p3 == Enum.UserInputState.Begin and not _G.PauseBinds then
			callback()
		end
	end, false, p2)
end

function XboxModule.Unbind(p, _, _)
	ContextActionService:UnbindAction(p)
end

return XboxModule