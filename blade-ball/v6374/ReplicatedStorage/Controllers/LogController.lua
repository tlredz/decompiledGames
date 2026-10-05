local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("LogService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TestService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Conch)
local _ = { "Info", "Warnings", "Errors" }
local v3 = {
	[Enum.MessageType.MessageInfo] = 34,
	[Enum.MessageType.MessageError] = 31,
	[Enum.MessageType.MessageWarning] = 33
}

local function paint(p: string, ...)
	return (("\27[%*m%*\27[0;0m"):format(table.concat({ ... }, ";"), p))
end

return {
	Start = function(_)
		v:Connect("LogsCommand", function(items, p)
			print()
			print()
			print("----------- Server Logs Start -----------")

			for _, item in items do
				if item.messageType == Enum.MessageType.MessageInfo then
					continue
				end

				if item.messageType == Enum.MessageType.MessageWarning then
					warn(item.message)
				elseif item.messageType == Enum.MessageType.MessageError then
					task.spawn(error, item.message, 0)
				elseif item.messageType == Enum.MessageType.MessageOutput then
					print(item.message)
				end
			end

			print("----------- Server Logs End -----------")
			print()
			print()

			if not p then
				return
			end

			local v4 = nil
			local count = 0
			local timestamp = nil
			local v5 = {}

			for _, item in items do
				local messageType = item.messageType
				local message = item.message
				local v6 = v3[messageType]

				if v6 then
					message = paint(message, v6)
				end

				if message == v4 then
					count += 1
					timestamp = item.timestamp
				else
					if v4 then
						if count > 0 then
							table.insert(v5, (`{os.date("%X", timestamp)}  (x{count + 1})  {v4}`))
							count = 0
						else
							table.insert(v5, (`{os.date("%X", timestamp)}  {v4}`))
						end
					end

					timestamp = item.timestamp
					v4 = message
				end
			end

			if v4 then
				if count > 0 then
					table.insert(v5, (`{os.date("%X", timestamp)}  (x{count + 1})  {v4}`))
				else
					table.insert(v5, (`{os.date("%X", timestamp)}  {v4}`))
				end
			end

			v2.ui.opened(false)
			v2.ui.focused(false)
			local formatted = `\`\`\`ansi\n{paint(
				`Logs captured at {os.date("%c", os.time())} | Place ID: {game.PlaceId} | Job ID: {game.JobId} | User ID: {game.Players.LocalPlayer.UserId}`,
				37,
				41
			)}\n\n{table.concat(v5, "\n")}\n\`\`\``
			local textBox = Instance.new("TextBox", game.Players.LocalPlayer.PlayerGui.HUD)
			textBox.Size = UDim2.fromOffset(200, 100)
			textBox.ClearTextOnFocus = false
			textBox.Text = formatted
			textBox.TextEditable = false
			textBox.FocusLost:Once(function()
				textBox:Destroy()
			end)
			task.wait(0.1)
			textBox:CaptureFocus()
			textBox.SelectionStart = 1
			textBox.CursorPosition = #formatted + 1
		end)
	end
}