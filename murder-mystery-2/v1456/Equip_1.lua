local _ = script.Parent.Parent
local ContextActionService = game:GetService("ContextActionService")

local function toggleShiftLock(_: string, p, _)
	if p ~= Enum.UserInputState.Begin then
		return
	end

	game.Players.LocalPlayer.PlayerScripts.MouseLock:Invoke()
end

ContextActionService:BindAction("ShiftLock", toggleShiftLock, false, Enum.KeyCode.DPadDown)

local function fn()
	for _, tool in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
		if not tool:IsA("Tool") then
			continue
		end

		tool.Parent = game.Players.LocalPlayer.Backpack

		if tool.Name == "GiftTool" then
			return
		end
	end

	for _, child in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
		if child.Name ~= "GiftTool" then
			continue
		end

		child.Parent = game.Players.LocalPlayer.Character
		break
	end
end

ContextActionService:BindAction("EquipGifter", function(_, p)
	if p == Enum.UserInputState.Begin and not _G.PauseBinds then
		fn()
	end
end, false, Enum.KeyCode.DPadLeft)
game.Players.LocalPlayer.Backpack.ChildAdded:connect(function(_)
	for _ = 1, 50 do
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		wait()
	end
end)