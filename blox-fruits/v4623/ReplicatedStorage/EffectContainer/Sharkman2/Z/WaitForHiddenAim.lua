return function(instance, p: number)
	local v = os.clock() + p

	while instance.Parent do
		if instance:GetAttribute("MousePos") ~= nil then
			return true
		end

		if instance:GetAttribute("State") == 2 or v <= os.clock() then
			return false
		else
			task.wait()
		end
	end

	return false
end