local StarterGui = game:GetService("StarterGui")
local v = { "OverlayUI", "ScreenGui", "ShiftLockButton" }
return {
	Start = function()
		task.wait(3)

		for _, screenGui in StarterGui:GetChildren() do
			if table.find(v, screenGui.Name) or not screenGui:IsA("ScreenGui") or not screenGui.ResetOnSpawn then
				continue
			end

			error("ScreenGui '" .. screenGui.Name .. "' has ResetOnSpawn enabled, which is not allowed.")
		end
	end
}