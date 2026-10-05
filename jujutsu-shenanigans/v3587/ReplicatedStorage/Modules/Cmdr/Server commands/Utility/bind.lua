local UserInputService = game:GetService("UserInputService")
return {
	Name = "bind",
	Aliases = {},
	Description = "Binds a command string to a key or mouse input.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "userInput ! bindableResource @ player",
			Name = "Input",
			Description = "The key or input type you'd like to bind the command to."
		},
		{
			Type = "command",
			Name = "Command",
			Description = "The command you want to run on this input"
		},
		{
			Type = "string",
			Name = "Arguments",
			Description = "The arguments for the command",
			Default = ""
		}
	},
	ClientRun = function(object, p, p2, p3)
		local store = object:GetStore("CMDR_Binds")
		local v = p2 .. " " .. p3

		if store[p] then
			store[p]:Disconnect()
		end

		local name = object:GetArgument(1).Type.Name

		if name == "userInput" then
			store[p] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == p or input.KeyCode == p then
					object:Reply(object.Dispatcher:EvaluateAndRun(object.Cmdr.Util.RunEmbeddedCommands(
						object.Dispatcher,
						v
					)))
				end
			end)
		else
			if name == "bindableResource" then
				return "Unimplemented..."
			end

			if name == "player" then
				store[p] = p.Chatted:Connect(function(p4)
					local v2 = object.Cmdr.Util.RunEmbeddedCommands(
						object.Dispatcher,
						object.Cmdr.Util.SubstituteArgs(v, { p4 })
					)
					object:Reply(
						("%s $ %s : %s"):format(p.Name, v2, object.Dispatcher:EvaluateAndRun(v2)),
						Color3.fromRGB(244, 92, 66)
					)
				end)
			end
		end

		return "Bound command to input."
	end
}