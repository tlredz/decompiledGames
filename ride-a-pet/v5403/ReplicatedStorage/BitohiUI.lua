local BitohiUI = {
	Version = "1.4.0"
}
local modulesByChildName = {}
setmetatable(BitohiUI, {
	__index = function(_, childName)
		local v = modulesByChildName[childName]

		if v ~= nil then
			return v
		end

		local moduleScript = script:FindFirstChild(childName)

		if moduleScript and moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			modulesByChildName[childName] = module
			return module
		else
			return nil
		end
	end
})

function BitohiUI.loadAll()
	for _, moduleScript in ipairs(script:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local _ = BitohiUI[moduleScript.Name]
		end
	end

	return BitohiUI
end

return BitohiUI