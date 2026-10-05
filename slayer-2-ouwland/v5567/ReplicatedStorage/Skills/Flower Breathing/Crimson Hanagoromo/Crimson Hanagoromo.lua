local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local startup = script.Startup
local v2 = script.End

-- equivalent calls inferred from this helper; original call sites unknown
local function animatorOf(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid:FindFirstChildOfClass("Animator")
end

local CrimsonHanagoromo = {}
CrimsonHanagoromo.Id = 0

function CrimsonHanagoromo.Hold(player)
	v:Clean()
	local animator = animatorOf(player) -- equivalent call inferred; original call site unknown

	if animator == nil then
		return
	end

	local track = animator:LoadAnimation(startup)
	v:Add(track)
	track:Play()
end

function CrimsonHanagoromo.UnHold(player)
	v:Clean()
	local animator = animatorOf(player) -- equivalent call inferred; original call site unknown

	if animator ~= nil then
		local track = animator:LoadAnimation(v2)
		v:Add(track)
		track:Play()
	end

	return true
end

function CrimsonHanagoromo.Cancel(_)
	v:Clean()
end

return CrimsonHanagoromo