local RunService = game:GetService("RunService")
return {
	Get = function(object)
		if RunService:IsStudio() then
			return 255
		end

		return object:GetRankInGroupAsync(14223953)
	end
}