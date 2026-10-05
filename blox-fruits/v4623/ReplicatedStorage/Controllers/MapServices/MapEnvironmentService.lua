local function fn(instance)
	local mET_TargetColor = instance:GetAttribute("MET_TargetColor")
	local mET_FinishTime = instance:GetAttribute("MET_FinishTime")

	if not (mET_TargetColor and mET_FinishTime) then
		return
	end

	local color = instance.Color
	local serverTimeNow = workspace:GetServerTimeNow()
	local v = mET_FinishTime - serverTimeNow
	task.spawn(function()
		while true do
			local serverTimeNow2 = workspace:GetServerTimeNow()

			if mET_FinishTime <= serverTimeNow2 or not instance:HasTag("MapEnvironmentTween") then
				break
			end

			instance.Color = color:Lerp(mET_TargetColor, (serverTimeNow2 - serverTimeNow) / v)
			task.wait(0.1)
		end

		instance.Color = mET_TargetColor
		instance:RemoveTag("MapEnvironmentTween")
	end)
end

return {
	OnStart = function()
		local CollectionService = game:GetService("CollectionService")
		local tagged = CollectionService:GetTagged("MapEnvironmentTween")

		for _, v in pairs(tagged) do
			task.spawn(fn, v)
		end

		local CollectionService2 = game:GetService("CollectionService")
		CollectionService2:GetInstanceAddedSignal("MapEnvironmentTween"):Connect(function(p)
			fn(p)
		end)
	end
}