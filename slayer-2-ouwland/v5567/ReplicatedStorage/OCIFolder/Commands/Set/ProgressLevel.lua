local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerProgression = require(ReplicatedStorage.CAM.Global.PlayerProgression)
return function(list, p: string, p2)
	local side = PlayerProgression.ResolveSide(p)

	if side == nil then
		warn((`Set/ProgressLevel: no progression side named "{p}" (Slayer or Demon)`))
		return
	end

	local v = tonumber(p2)

	if v == nil then
		warn((`Set/ProgressLevel: "{p2}" is not a level (1 to {PlayerProgression.MaxLevel()})`))
		return
	end

	for _, v2 in ipairs(list) do
		PlayerProgression.SetLevel(v2, side, v)
	end
end