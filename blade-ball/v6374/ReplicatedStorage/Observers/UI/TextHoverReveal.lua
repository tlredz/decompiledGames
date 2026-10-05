local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("TextHoverReveal", function(instance)
	local flag = false

	local function update()
		local textPreview = instance:GetAttribute("TextPreview") or ""
		local textReveal = instance:GetAttribute("TextReveal") or textPreview
		local revealFormat = instance:GetAttribute("RevealFormat") or "%s"

		if flag then
			instance.Text = revealFormat:format(textReveal)
		else
			instance.Text = revealFormat:format(textPreview)
		end
	end

	update()
	local mouseEnterConnection = instance.MouseEnter:Connect(function()
		flag = true
		update()
	end)
	local mouseLeaveConnection = instance.MouseLeave:Connect(function()
		flag = false
		update()
	end)
	local v = {
		instance:GetAttributeChangedSignal("TextPreview"):Connect(update),
		instance:GetAttributeChangedSignal("TextReveal"):Connect(update),
		instance:GetAttributeChangedSignal("RevealFormat"):Connect(update)
	}
	return function()
		mouseEnterConnection:Disconnect()
		mouseLeaveConnection:Disconnect()
		local v2, connection = next(v)

		while v2 do
			connection:Disconnect()
			v[v2] = nil
			v2, connection = next(v)
		end
	end
end)