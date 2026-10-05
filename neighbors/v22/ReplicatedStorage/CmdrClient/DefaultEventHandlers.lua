local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
game:GetService("StarterGui")
local Window = require(script.Parent.CmdrInterface.Window)
return function(object)
	object:HandleEvent("Message", function(text, p, p2)
		local clone = script.Message:Clone()
		clone.Parent = Players.LocalPlayer.PlayerGui
		clone.Title.Text = `{p2 and "Private Message" or "Message"} from {p.Name}`
		clone.Message.Text = text
		Debris:AddItem(clone, 5)
	end)
	object:HandleEvent("AddLine", function(...)
		Window:AddLine(...)
	end)
end