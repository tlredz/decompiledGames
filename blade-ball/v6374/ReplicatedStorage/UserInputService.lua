game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if game.GameId == 4777817887 then
	return UserInputService
end

local module = require("@self/RBXScriptSignal")
local UserInputService2 = {
	InputBegan = module.mock(UserInputService.InputBegan),
	InputChanged = module.mock(UserInputService.InputChanged),
	InputEnded = module.mock(UserInputService.InputEnded),
	LastInputTypeChanged = module.mock(UserInputService.LastInputTypeChanged),
	TouchDrag = module.mock(UserInputService.TouchDrag),
	TouchEnded = module.mock(UserInputService.TouchEnded),
	TouchLongPress = module.mock(UserInputService.TouchLongPress),
	TouchMoved = module.mock(UserInputService.TouchMoved),
	TouchPan = module.mock(UserInputService.TouchPan),
	TouchPinch = module.mock(UserInputService.TouchPinch),
	TouchRotate = module.mock(UserInputService.TouchRotate),
	TouchStarted = module.mock(UserInputService.TouchStarted),
	TouchSwipe = module.mock(UserInputService.TouchSwipe),
	TouchTap = module.mock(UserInputService.TouchTap),
	TouchTapInWorld = module.mock(UserInputService.TouchTapInWorld),
	WindowFocused = module.mock(UserInputService.WindowFocused),
	WindowFocusReleased = module.mock(UserInputService.WindowFocusReleased)
}
setmetatable(UserInputService2, {
	__index = function(_, p)
		local v = UserInputService[p]

		if typeof(v) == "function" then
			return function(_, ...)
				return v(UserInputService, ...)
			end
		end

		return v
	end,
	__newindex = function(_, p, p2)
		UserInputService[p] = p2
	end
})
return UserInputService2