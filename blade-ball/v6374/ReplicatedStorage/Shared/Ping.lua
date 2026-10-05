local Players = game:GetService("Players")
local v = {}
local Ping = {
	Get = function(p)
		if p == Players.LocalPlayer then
			return script:GetAttribute("LocalPlayerPing") or 0
		end

		return v[p] or 0
	end,
	_Set = function(p, localPlayerPing: number)
		v[p] = localPlayerPing

		if p == Players.LocalPlayer then
			script:SetAttribute("LocalPlayerPing", localPlayerPing)
		end
	end,
	IsKnown = function(p)
		return v[p] ~= nil
	end
}
script.GetPing.OnInvoke = Ping.Get
Players.PlayerRemoving:Connect(function(player)
	v[player] = nil
end)
return Ping