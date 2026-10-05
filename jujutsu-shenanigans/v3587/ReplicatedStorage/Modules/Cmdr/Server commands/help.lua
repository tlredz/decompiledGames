return {
	Name = "help",
	Description = "Displays a list of all commands, or inspects one command.",
	Group = "Help",
	Args = {
		{
			Type = "command",
			Name = "Command",
			Description = "The command to view information on",
			Optional = true
		}
	},
	ClientRun = function(object, p)
		if p then
			local command = object.Cmdr.Registry:GetCommand(p)
			object:Reply(`Command: {command.Name}`, Color3.fromRGB(230, 126, 34))

			if command.Aliases and #command.Aliases > 0 then
				object:Reply(`Aliases: {table.concat(command.Aliases, ", ")}`, Color3.fromRGB(230, 230, 230))
			end

			object:Reply(command.Description, Color3.fromRGB(230, 230, 230))

			for i, arg in ipairs(command.Args) do
				object:Reply((`#{i} {arg.Name}{arg.Optional == true and "?" or ""}: {arg.Type} - {arg.Description}`))
			end
		else
			object:Reply([[
Argument Shorthands
-------------------
.   Me/Self
*   All/Everyone
**  Others
?   Random
?N  List of N random values
]])
			object:Reply([[
Tips
----
• Utilize the Tab key to automatically complete commands
• Easily select and copy command output
]])
			local commands = object.Cmdr.Registry:GetCommands()
			table.sort(commands, function(a, b)
				if a.Group and b.Group then
					return a.Group < b.Group
				end

				return a.Group
			end)
			local group = nil

			for _, command in ipairs(commands) do
				command.Group = command.Group or "No Group"

				if group ~= command.Group then
					object:Reply((`\n{command.Group}\n{string.rep("-", #command.Group)}`))
					group = command.Group
				end

				local v

				if command.Description then
					v = `{command.Name} - {command.Description}`
				else
					v = command.Name
				end

				object:Reply(v)
			end
		end

		return ""
	end
}