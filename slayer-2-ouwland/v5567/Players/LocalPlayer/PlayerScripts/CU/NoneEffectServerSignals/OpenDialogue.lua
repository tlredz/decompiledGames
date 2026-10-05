local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dialogue = require(ReplicatedStorage.CAM.Client.Modules.GamePlay.Dialogue)
return function(value: string)
	if typeof(value) ~= "string" then
		return
	end

	Dialogue.OpenDialogue:Fire(value)
end