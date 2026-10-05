local SkillStats = require(script.Parent.Parent.Parent.Modules.SkillStats)
return {
	GetCounter = function(instance, instance2)
		local counter

		if instance2 ~= nil then
			counter = instance2:FindFirstChild("Counter") or nil
		end

		if counter ~= nil and counter:IsA("StringValue") and #counter.Value > 0 then
			return counter:GetAttribute("Type"), counter.Value, counter
		end

		local SHC = instance:FindFirstChild("SHC") or instance:FindFirstChild("SHCS")

		if not SHC or not (#SHC.Value > 0) or instance2 ~= nil and instance2:FindFirstChild("CounterWindup") ~= nil then
			return nil
		end

		local value = SHC.Value
		local v = SkillStats.Get(value)
		return v and v.counter or nil, value
	end
}