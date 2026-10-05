local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local sounds = nil

local function generalSounds()
	if sounds == nil then
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		sounds = assets ~= nil and assets:FindFirstChild("Sounds") or false
	end

	return sounds or nil
end

return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local playSound = vfxUtility.PlaySound

	if sounds == nil then
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		sounds = assets ~= nil and (assets:FindFirstChild("Sounds") or false)
	end

	playSound(sounds or nil, "PS2breath", humanoidRootPart, true)
	local head = instance:FindFirstChild("Head")

	if head == nil then
		return
	end

	local clone = script.Breathing:Clone()
	clone.Parent = head
	DebrisModule:AddItem(clone, 3.5)
	Ouwmit.Emit(clone, Ouwmit.Owned(instance))
end