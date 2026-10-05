local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local VitalDraw = {}
VitalDraw.Id = 0

function VitalDraw.Hold(player)
	if player == nil then
		return false
	end

	local character = player.Character

	if character == nil then
		return false
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid == nil then
		return false
	end

	v:Clean()
	local vitalDraw = script:FindFirstChild("VitalDraw") or script:FindFirstChild("Animation")
	local animator = humanoid:FindFirstChild("Animator")

	if vitalDraw ~= nil and animator ~= nil then
		local track = animator:LoadAnimation(vitalDraw)
		v:Add(track)
		track:Play()
	end

	return true
end

function VitalDraw.Cancel(_)
	v:Clean()
end

return VitalDraw