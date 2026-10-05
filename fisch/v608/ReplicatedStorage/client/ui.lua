local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local mount = require(script.mount)
local state = require(script.state)
local UI_AutoAdjustCanvasSize = require(script.legacy.UI_AutoAdjustCanvasSize)
local v = {}
return {
	init = function()
		CollectionService:GetInstanceAddedSignal("UI_AutoAdjustCanvasSize"):Connect(function(scrollingFrame)
			assert(typeof(scrollingFrame) == "Instance", "Luau")
			assert(scrollingFrame:IsA("ScrollingFrame"), "Tagged instance is not a ScrollingFrame")
			v[scrollingFrame] = UI_AutoAdjustCanvasSize(scrollingFrame)
		end)
		CollectionService:GetInstanceRemovedSignal("UI_AutoAdjustCanvasSize"):Connect(function(p)
			local v2 = v[p]

			if not v2 then
				return
			end

			v2()
		end)
		state.keyboardEnabled(UserInputService.KeyboardEnabled)
		state.controllerEnabled(UserInputService.GamepadEnabled)
		state.touchscreenEnabled(UserInputService.TouchEnabled)
		mount()
	end
}