local StarterGui = game:GetService("StarterGui")
local Window = require(script.Parent.CmdrInterface.Window)
return function(object)
	object:HandleEvent("Message", function(p)
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = ("[Announcement] %s"):format(p),
			Color = Color3.fromRGB(249, 217, 56)
		})
	end)
	object:HandleEvent("AddLine", function(...)
		Window:AddLine(...)
	end)
end