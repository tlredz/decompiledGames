local v = {
	ContextAction = game:GetService("ContextActionService"),
	UserInput = game:GetService("UserInputService")
}
return table.freeze({
	bindSkip = function(p: string, list, data, callback)
		local flag = false
		local touchEnabled = data.Enabled and v.UserInput.TouchEnabled
		v.ContextAction:BindActionAtPriority(p, function(_: string, p2)
			if p2 == Enum.UserInputState.Begin then
				callback()
			end

			return Enum.ContextActionResult.Sink
		end, touchEnabled, Enum.ContextActionPriority.High.Value + 1, table.unpack(list))

		if touchEnabled then
			v.ContextAction:SetTitle(p, data.Title)
			v.ContextAction:SetPosition(p, data.Position)

			if data.Description then
				v.ContextAction:SetDescription(p, data.Description)
			end

			if data.Image then
				v.ContextAction:SetImage(p, data.Image)
			end
		end

		return {
			Destroy = function(_)
				if flag then
					return
				end

				flag = true
				v.ContextAction:UnbindAction(p)
			end
		}
	end
})