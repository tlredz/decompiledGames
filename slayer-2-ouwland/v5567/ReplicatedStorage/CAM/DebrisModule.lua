local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
return {
	AddItem = function(_, instance, duration: number, _: string?)
		if instance == nil then
			return
		end

		if duration == 0 and instance.ClassName == "Sound" then
			task.delay(0.5, function()
				if instance == nil or instance.Parent == nil then
					return
				end

				local v = instance.TimeLength - 0.5

				if v > 0 then
					task.wait(v)
				end

				if instance == nil or instance.Parent == nil then
					return
				end

				instance:Destroy()
				instance = nil
			end)
			return
		end

		if isServer and typeof(instance) == "Instance" then
			instance:AddTag("OuwDebris")
			instance:SetAttribute("_OuwDebrisAt", workspace:GetServerTimeNow() + duration)
		end

		task.delay(duration, instance.Destroy, instance)
	end
}