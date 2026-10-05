local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local LocalCharacter = {
	currentCFrame = CFrame.identity,
	currentCharacter = nil
}

function LocalCharacter.init()
	if localPlayer.Character then
		LocalCharacter._onCharacterAdded(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(LocalCharacter._onCharacterAdded)
	localPlayer.CharacterRemoving:Connect(LocalCharacter._onCharacterRemoved)
end

function LocalCharacter._onCharacterAdded(currentCharacter)
	currentCharacter:WaitForChild("HumanoidRootPart")
	LocalCharacter.currentCharacter = currentCharacter
end

function LocalCharacter._onCharacterRemoved()
	LocalCharacter.currentCharacter = nil
end

function LocalCharacter.updatePosition()
	if not LocalCharacter.currentCharacter then
		LocalCharacter.currentCFrame = CFrame.identity
		return
	end

	local humanoidRootPart = LocalCharacter.currentCharacter:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		LocalCharacter.currentCFrame = humanoidRootPart.CFrame
	else
		LocalCharacter.currentCFrame = CFrame.identity
	end
end

return LocalCharacter