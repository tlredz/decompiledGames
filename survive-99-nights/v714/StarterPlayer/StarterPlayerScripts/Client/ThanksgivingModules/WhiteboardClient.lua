game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = nil
local count = 0
local boardSpinAnimation = nil
local track = nil
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.K then
		Client.Events.DebugThanksgiving:FireServer("left")
	elseif input.KeyCode == Enum.KeyCode.L then
		Client.Events.DebugThanksgiving:FireServer("right")
	end
end)

function SpinBoard(p)
	if not v then
		if not p then
			return
		end

		v = p
	end

	v.PrimaryPart.Sound:Play()
	count += 1

	if not boardSpinAnimation then
		boardSpinAnimation = v.AnimationController.BoardSpinAnimation
	end

	if track then
		track:Stop()
	end

	track = v.AnimationController.Animator:LoadAnimation(boardSpinAnimation)
	track:Play()
end

Client.Events.FlipThanksgivingWhiteboard:Connect(function(p)
	SpinBoard(p)
end)

function WhiteboardAdded(instance)
	if v then
		return
	end

	instance:WaitForChild("HumanoidRootPart")

	if not (instance.PrimaryPart and instance:IsDescendantOf(workspace.Map.Landmarks)) then
		return
	end

	v = instance
	local _ = instance.PrimaryPart
	task.spawn(function()
		local tamingImages = {}

		for _, tamingImage in pairs(Client.Databases.FoodIcons.TamingImages) do
			table.insert(tamingImages, tamingImage)
		end

		Client.UtilityAlec.preload(tamingImages)
	end)
end

Client.Utility.ForAllTagged("ThanksgivingWhiteboard", WhiteboardAdded)
return {}