local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
local localPlayer = Players.LocalPlayer

local function onCharacterAdded(character)
	local v = nil

	local function sync()
		local transformationCameraLock = character:GetAttribute("TransformationCameraLock") == true

		if transformationCameraLock and not v then
			v = CameraAuthority.claim("TransformationCameraLock", {
				priority = 50
			})
		elseif not transformationCameraLock and v then
			v:release()
			v = nil
		end
	end

	character:GetAttributeChangedSignal("TransformationCameraLock"):Connect(sync)
	character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(game) then
			CameraAuthority.releaseOwner("TransformationCameraLock")
			v = nil
		end
	end)
	sync()
end

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)