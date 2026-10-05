return {
	Start = function(self)
		for _, child in script.Controllers:GetChildren() do
			local success, result = pcall(require, child)

			if success then
				if result.Start then
					result:Start()
				end
			else
				warn(result)
			end
		end
	end
}