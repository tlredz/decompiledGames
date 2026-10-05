local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local v = nil
local v2 = nil
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return function(p, _, p2: string, value: number?, data)
	if not p then
		return false, "No player"
	end

	v = v or require(ServerStorage.SAM.Services.Adders.Item)
	v2 = v2 or require(ReplicatedStorage.CAM.Global.Collectibles.Items)
	local v3 = v2[p2]

	if v3 == nil or v3.PackContents == nil then
		if v3 ~= nil and (v3.Skills ~= nil or v3.HasCombat) then
			value = nil
		end

		local v4 = v
		local v5 = data ~= nil and data.AutoEquip == true or nil
		local v9

		if data == nil then
			v9 = false
		else
			v9 = data.NoSave == true
		end

		local v10, v11 = v4(p, p2, value, v5, nil, nil, "Shop", v9)

		if v10 and data ~= nil and typeof(data.Shout) == "table" then
			SignalEvent.ToClient(p, "NpcNotify", data.Shout)
		end

		return v10, v11
	else
		local v4 = math.max(math.floor(value or 1), 1)
		local v5 = true

		for k, packContent in v3.PackContents do
			v5 = v(p, k, packContent * v4, nil, nil, nil, "Shop") and v5
		end

		return v5
	end
end