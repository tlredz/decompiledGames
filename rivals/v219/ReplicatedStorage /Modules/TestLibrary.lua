local TestService = game:GetService("TestService")
local RunService = game:GetService("RunService")
return {
	GetTestAttribute = function(_, attributeName)
		if not RunService:IsStudio() then
			return nil
		end

		local attribute

		while true do
			attribute = TestService:GetAttribute(attributeName)

			if attribute ~= nil then
				break
			end

			warn("TestService attribute not found, waiting for", attributeName)
			wait(1)
		end

		if attribute == "" then
			return nil
		end

		return attribute
	end
}