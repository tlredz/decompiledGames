local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local localPlayer = Players.LocalPlayer
local v = false
local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function AllowRetry()
	v = false
	v2 = os.clock() + 30
end

localPlayer.OnTeleport:Connect(function(p)
	if p ~= Enum.TeleportState.Failed then
		v = true
		return
	end

	AllowRetry() -- equivalent call inferred; original call site unknown
end)
TeleportService.TeleportInitFailed:Connect(function(p, p2)
	if p == localPlayer and p2 ~= Enum.TeleportResult.IsTeleporting then
		AllowRetry() -- equivalent call inferred; original call site unknown
	end
end)
localPlayer.Idled:Connect(function(p)
	if p < 1100 or v or os.clock() < v2 then
		return
	end

	v = true
	local success, result = pcall(function()
		TeleportService:Teleport(game.PlaceId, localPlayer)
	end)

	if not success then
		AllowRetry() -- equivalent call inferred; original call site unknown
		warn("[AFK] Rejoin failed: " .. tostring(result))
	end
end)