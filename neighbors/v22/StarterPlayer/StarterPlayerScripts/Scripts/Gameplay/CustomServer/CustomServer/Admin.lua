local TextChatService = game:GetService("TextChatService")
local Server = require(game.ReplicatedStorage.Modules.Server)
local Network = require(game.ReplicatedStorage.Modules.Network)
local localPlayer = game.Players.LocalPlayer
TextChatService:WaitForChild("TextChatCommands")
TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local v = {
	System = Color3.fromRGB(255, 239, 67),
	Command = Color3.fromRGB(128, 255, 128),
	Argument = Color3.fromRGB(199, 240, 255),
	Result = Color3.fromRGB(204, 204, 204)
}

local function color(p: string, color2: Color3)
	return (`<font color="#{color2:ToHex()}">{p}</font>`)
end

local function makeMessage(p: string)
	TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage((`{`<font color="#{v.System:ToHex()}">[SYSTEM]</font>`}: {p}`))
end

if Server:IsCustomServer() then
	local function displayCommands()
		local v2 = Network:invoke("GetServerCommands")
		TextChatService.ChatWindowConfiguration.Enabled = true
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage((`{`<font color="#{v.System:ToHex()}">[SYSTEM]</font>`}: You are a server admin!`))
		local formatted = `{`<font color="#{v.System:ToHex()}">Command List</font>`}\n`

		for k, v3 in next, v2, nil do
			local joined = table.concat(v3.Arguments, " ")
			local formatted2 = `/{k}`
			formatted ..= `- {`<font color="#{v.Command:ToHex()}">{formatted2}</font>`} {`<font color="#{v.Argument:ToHex()}">{joined}</font>`}: {v3.Description}\n`
		end

		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(formatted)
	end

	Network:listen("ServerCommandResult", function(p: string)
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage((`<font color="#{v.Result:ToHex()}">{p}</font>`))
	end)
	localPlayer:GetAttributeChangedSignal("CustomServerAdmin"):Connect(function()
		if localPlayer:GetAttribute("CustomServerAdmin") then
			displayCommands()
		else
			TextChatService.ChatWindowConfiguration.Enabled = false
		end
	end)

	if localPlayer:GetAttribute("CustomServerAdmin") then
		displayCommands()
	else
		TextChatService.ChatWindowConfiguration.Enabled = false
	end
end