local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Config = require(script.Parent.Config)
local palePetals = script.PalePetals
local umbrellaPalePetals = script.UmbrellaPalePetals
local PalePetals = {}
PalePetals.Id = 0

function PalePetals.Hold(player)
	v:Clean()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator == nil then
		return
	end

	local track = animator:LoadAnimation(palePetals)
	v:Add(track)
	track:Play()
	local track2 = animator:LoadAnimation(umbrellaPalePetals)
	v:Add(track2)
	track2:Play()
	task.wait(Config.THROW_DURATION)
end

function PalePetals.UnHold(_)
	return true
end

function PalePetals.Cancel(_)
	v:Clean()
end

return PalePetals