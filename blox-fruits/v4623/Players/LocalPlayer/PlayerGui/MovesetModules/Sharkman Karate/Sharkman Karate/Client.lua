require(game.ReplicatedStorage.MovesetTypes)
local RunService = game:GetService("RunService")
local Anims = require(game.ReplicatedStorage.Util.Anims)

if RunService:IsClient() then
	for _, v in pairs({
		"SK_ZWindup",
		"SK_ZHold",
		"SK_ZDash",
		"SK_ZAttackLoop",
		"SK_CCharge",
		"SK_CFire",
		"SK_CSuccess",
		"SK_XLaunch",
		"SK_XLaunchLoop",
		"SK_XEnd"
	}) do
		Anims:Preload(v)
	end
end

return {}