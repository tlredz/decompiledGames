local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local ShowRoomController = require(ReplicatedStorage.Controllers.ShowRoomController)
local NewShowcaseController = require(ReplicatedStorage.Controllers.UI.NewShowcaseController)
local localPlayer = Players.LocalPlayer
return Observers.observeTagNoAncestry("UIPromptNPC", function(instance)
	local windowName = instance:GetAttribute("WindowName")

	if not windowName or windowName == "" then
		warn("UIPromptNPC is missing WindowName attribute:", instance:GetFullName())
	end

	local idleAnimation = instance:FindFirstChild("IdleAnimation")
	local animator = instance:FindFirstChildWhichIsA("Animator", true)
	local track

	if idleAnimation and animator then
		track = animator:LoadAnimation(idleAnimation)
		track:Play()
	else
		track = nil
	end

	local now = 0

	local function onTouch(p)
		local windowName2 = instance:GetAttribute("WindowName")
		local playerFromCharacter = Players:GetPlayerFromCharacter(p.Parent)

		if playerFromCharacter and playerFromCharacter == localPlayer and not GuiHandler._currentGui and not GuiHandler._lockId and tick() - now > 1 and not GuiHandler:IsOpen(windowName2) then
			if windowName == NewShowcaseController.LegacyWindowName then
				ShowRoomController:Open(NewShowcaseController:GetWindowName(), "SwordPacks", true)
			else
				GuiHandler:Open(windowName2)
			end
		end
	end

	GuiHandler:OnGuiClose(windowName, function()
		now = tick()
	end)
	local touchedConnection = nil
	task.spawn(function()
		local hitbox = instance:WaitForChild("Hitbox", 60)

		if not hitbox then
			return
		end

		touchedConnection = hitbox.Touched:Connect(onTouch)
	end)
	return function()
		if touchedConnection then
			touchedConnection:Disconnect()
			touchedConnection = nil
		end

		if track then
			track:Stop()
			track:Destroy()
			track = nil
		end
	end
end)