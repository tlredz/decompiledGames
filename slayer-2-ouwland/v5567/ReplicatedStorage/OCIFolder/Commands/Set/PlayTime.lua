local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
return function(items, p)
	local v = tonumber(p)

	if v == nil then
		warn((`Set/PlayTime: "{p}" is not a number of minutes`))
		return
	end

	local v2 = math.max(v, 0) * 60
	local v3 = gameSettings.NewPlayerPlayTime <= v2

	for _, item in items do
		local _, parent = Utility.GetData(item)

		if parent == nil then
			continue
		end

		local v5 = parent:FindFirstChild("PlayTime")

		if v3 then
			if v5 ~= nil then
				v5:Destroy()
			end

			item:SetAttribute("PlayTime", nil)
		else
			if v5 == nil then
				v5 = Instance.new("NumberValue")
				v5.Name = "PlayTime"
				v5.Parent = parent
			end

			v5.Value = v2
			item:SetAttribute("PlayTime", v2)
		end
	end
end