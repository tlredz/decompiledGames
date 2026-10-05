local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local Utility = require(CAM.Global.Utility)
local v = {
	Demon = true,
	Hybrid = true
}
return {
	Activate = function(p, _, instance, _)
		if p ~= nil then
			local data = Utility.GetData(p)
			local race

			if data ~= nil then
				race = data:FindFirstChild("Race") or nil
			end

			if race == nil or v[race.Value] ~= true then
				return
			end
		end

		for _, child in instance:GetChildren() do
			if child.Name == "Health Regen Speed" and child:GetAttribute("_RegenAdrenal") == true then
				child:Destroy()
			end
		end

		local v2 = Utility.AddTimedValue(instance, "Health Regen Speed", 7, "NumberValue", 0.14)
		v2:SetAttribute("_RegenAdrenal", true)
		v2:SetAttribute("Skill", "Regen Adrenal")
	end
}