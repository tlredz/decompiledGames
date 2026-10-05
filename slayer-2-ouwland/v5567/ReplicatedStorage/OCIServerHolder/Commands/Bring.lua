local OCIEnums = require(script.Parent.Parent.Utilities.OCIEnums)
return {
	Clearance = 1,
	Keys = {
		{
			Type = OCIEnums.Players,
			Required = true
		},
		{
			Type = OCIEnums.Player,
			Name = "To",
			Required = false
		}
	},
	Server = function(_, items, player)
		if player == nil or player.Character == nil or player.Character.PrimaryPart == nil then
			error((`{player}, is invalid or just died`))
			return
		end

		local position = player.Character.PrimaryPart.Position

		for _, item in pairs(items) do
			if item.Character ~= nil and item.Character.PrimaryPart ~= nil then
				item.Character:MoveTo(position)
			end
		end
	end
}