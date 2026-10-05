local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")

if UserInputService.GamepadEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled) then
	local parent = script.Parent

	local function updateGamepad()
		if #parent:GetChildren() == 2 then
			GamepadService:DisableGamepadCursor()
			return
		end

		GamepadService:EnableGamepadCursor((parent:FindFirstChildWhichIsA("Frame")))
	end

	parent.ChildAdded:Connect(function()
		if #parent:GetChildren() == 2 then
			GamepadService:DisableGamepadCursor()
			return
		end

		GamepadService:EnableGamepadCursor((parent:FindFirstChildWhichIsA("Frame")))
	end)
	parent.ChildRemoved:Connect(function()
		if #parent:GetChildren() == 2 then
			GamepadService:DisableGamepadCursor()
			return
		end

		GamepadService:EnableGamepadCursor((parent:FindFirstChildWhichIsA("Frame")))
	end)
end