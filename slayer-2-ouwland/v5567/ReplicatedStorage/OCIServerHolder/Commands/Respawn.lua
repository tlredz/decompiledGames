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
			Type = OCIEnums.Boolean,
			Required = false
		}
	},
	Server = function(_, list, flag: boolean)
		for _, v in ipairs(list) do
			if not (v.Character ~= nil and v.Character.PrimaryPart ~= nil) then
				continue
			end

			local cFrame = v.Character.PrimaryPart.CFrame
			v:LoadCharacter()

			if flag then
				v.Character:PivotTo(cFrame)
			end
		end
	end
}