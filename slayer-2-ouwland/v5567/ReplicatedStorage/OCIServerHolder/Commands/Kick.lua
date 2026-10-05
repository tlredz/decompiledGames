game:GetService("Workspace")
local OCIEnums = require(script.Parent.Parent.Utilities.OCIEnums)
return {
	Clearance = 1,
	Keys = {
		{
			Type = OCIEnums.Players,
			Required = true
		},
		{
			Type = OCIEnums.String
		}
	},
	Server = function(p, list, value: string?)
		local v = value or "no given reason "

		for _, v2 in ipairs(list) do
			v2:Kick((`Kicked by {p.Name} for {v}`))
		end
	end
}