return {
	Get = function(childName: string?)
		local moduleScript = childName and script:FindFirstChild(childName)

		if moduleScript and moduleScript:IsA("ModuleScript") then
			return require(moduleScript)
		end

		return nil
	end
}