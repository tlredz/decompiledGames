local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(items)
	for _, item in items do
		local _, v = Utility.GetData(item)

		if v == nil then
			continue
		end

		for _, child in v.slots:GetChildren() do
			local misc = child:FindFirstChild("Misc")
			local onboarding

			if misc ~= nil then
				onboarding = misc:FindFirstChild("Onboarding")
			end

			if onboarding ~= nil then
				onboarding:Destroy()
			end
		end
	end
end