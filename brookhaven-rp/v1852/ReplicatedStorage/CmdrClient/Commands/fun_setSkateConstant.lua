local Players = game:GetService("Players")
return {
	Name = "fun_setSkateConstant",
	Aliases = {},
	Description = "Set a constant value for the ice skating system",
	Group = "Fun",
	Args = {
		{
			Type = "string",
			Name = "Constant Name",
			Description = "Constant to set(there are a lot of them, look at script/ask a programmer for a list)"
		},
		{
			Type = "number",
			Name = "Constant Value",
			Description = "Value to set the constant to"
		}
	},
	ClientRun = function(_, p: string, p2: number)
		local character = Players.LocalPlayer.Character

		if not character then
			return "Player has no character"
		end

		character:SetAttribute(p, p2)
		return "Constant set successfully 🫡"
	end
}