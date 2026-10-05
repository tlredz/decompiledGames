local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)

-- equivalent calls inferred from this helper; original call sites unknown
local function drawsOn(instance, value: string)
	local onlyOn = instance:GetAttribute("OnlyOn")
	return onlyOn == nil or string.find(tostring(onlyOn), value, 1, true) ~= nil
end

local Gamepad = require(script.Platforms.Gamepad)
local v = {
	PC = require(script.Platforms.PC),
	Xbox = Gamepad,
	Playstation = Gamepad
}

function doKey(instance)
	if instance == nil then
		return
	end

	local value = Platform_Handler.Platform.Value
	local keyLabel = instance:FindFirstChild("KeyLabel")

	if keyLabel ~= nil then
		if keyLabel:GetAttribute("Platform") == value then
			return
		else
			keyLabel:Destroy()
		end
	end

	if not drawsOn(instance, value) then
		return
	end

	local v2 = v[value]

	if v2 == nil then
		return
	end

	local v3 = v2(instance)

	if typeof(v3) == "Instance" then
		v3.Name = "KeyLabel"
		v3:SetAttribute("Platform", value)
	end
end

function updatePlatform()
	for _, v2 in ipairs(CollectionService:GetTagged("UIkey")) do
		doKey(v2)
	end
end

local function relabel()
	for _, v2 in ipairs(CollectionService:GetTagged("UIkey")) do
		local keyLabel = v2:FindFirstChild("KeyLabel")

		if keyLabel ~= nil then
			keyLabel:Destroy()
		end

		doKey(v2)
	end
end

updatePlatform()
Platform_Handler.Platform.Changed.Event:Connect(updatePlatform)
InputHandler.Rebound:Connect(relabel)
CollectionService:GetInstanceAddedSignal("UIkey"):Connect(doKey)