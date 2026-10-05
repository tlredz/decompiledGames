local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = nil
local tweenInfo = TweenInfo.new(1)

function UpdateAmbience()
	local v3 = localPlayer.Character ~= nil and localPlayer.Character:GetAttribute("CameraInSwimPart") and "Underwater" or nil

	if v3 ~= v then
		v = v3

		if v2 ~= nil then
			TweenService:Create(v2, tweenInfo, {
				Volume = 0
			}):Play()
			DebrisModule:AddItem(v2, 1)
			v2 = nil
		end

		local child = v3 ~= nil and script:FindFirstChild(v3) or nil

		if child ~= nil then
			local clone = child:Clone()
			v2 = clone
			local volume = clone.Volume
			clone.Parent = script
			clone.Volume = 0
			clone:Play()
			TweenService:Create(clone, tweenInfo, {
				Volume = volume
			}):Play()
		end
	end
end

local maid = cleanit.new()

function updCharacter(object)
	maid:Clean()
	maid:Add(object:GetAttributeChangedSignal("CameraInSwimPart"):Connect(UpdateAmbience))
end

if localPlayer.Character ~= nil then
	updCharacter(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(updCharacter)