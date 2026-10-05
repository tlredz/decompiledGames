return {
	Clearance = 1,
	Priority = 2,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "InPlace",
			Name = "InPlace",
			Required = false,
			Suggester = { "true", "false" },
			Completer = function(value: string)
				if value == nil then
					return nil
				end

				local lower = value:lower()

				if lower == "true" then
					return true
				elseif lower == "false" then
					return false
				end

				return nil
			end
		}
	},
	Server = function(_, list, p)
		for _, v in ipairs(list) do
			if p == true then
				local humanoidRootPart

				if v.Character ~= nil then
					humanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart") or nil
				end

				if humanoidRootPart ~= nil then
					v:SetAttribute("RespawnInPlace", humanoidRootPart.Position)
				end
			end

			v:LoadCharacter()
		end
	end
}