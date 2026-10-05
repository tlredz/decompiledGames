return function(instance, p: number)
	instance:Emit(p)
	instance:SetAttribute("emitEnabledFixScheduleDestruct", time())
	task.delay(instance.Lifetime.Max, function()
		if time() - instance:GetAttribute("emitEnabledFixScheduleDestruct") >= instance.Lifetime.Max - 0.01 then
			instance:Clear()
		end
	end)
end