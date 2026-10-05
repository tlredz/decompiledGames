return {
	Name = "unbind",
	Aliases = {},
	Description = "Unbinds an input previously bound with Bind",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput ! bindableResource @ player",
			Name = "Input/Key",
			Description = "The key or input type you'd like to unbind."
		}
	},
	ClientRun = function(object, p)
		local store = object:GetStore("CMDR_Binds")

		if not store[p] then
			return "That input wasn't bound."
		end

		store[p]:Disconnect()
		store[p] = nil
		return "Unbound command from input."
	end
}