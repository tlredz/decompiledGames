local TweenService = game:GetService("TweenService")
local sine = Enum.EasingStyle.Sine
return {
	Bind = function(guiObject)
		assert(guiObject:IsA("GuiObject"), (`{guiObject:GetFullName()} must be a GuiObject to hover bob`))
		local hoverBobDistance = guiObject:GetAttribute("HoverBobDistance") or 6
		local hoverBobSeconds = guiObject:GetAttribute("HoverBobSeconds") or 1.4
		local hoverBobSway = guiObject:GetAttribute("HoverBobSway") or 0
		local hoverBobSwaySeconds = guiObject:GetAttribute("HoverBobSwaySeconds") or 1.9
		local position = guiObject.Position
		local rotation = guiObject.Rotation
		local tweens = {}
		local tween = TweenService:Create(
			guiObject,
			TweenInfo.new(hoverBobSeconds / 2, sine, Enum.EasingDirection.Out),
			{
				Position = position - UDim2.fromOffset(0, hoverBobDistance)
			}
		)
		table.insert(tweens, tween)
		tween.Completed:Connect(function(p)
			if p ~= Enum.PlaybackState.Completed then
				return
			end

			local tween2 = TweenService:Create(
				guiObject,
				TweenInfo.new(hoverBobSeconds, sine, Enum.EasingDirection.InOut, -1, true),
				{
					Position = position + UDim2.fromOffset(0, hoverBobDistance)
				}
			)
			table.insert(tweens, tween2)
			tween2:Play()
		end)
		tween:Play()

		if hoverBobSway > 0 then
			guiObject.Rotation = rotation - hoverBobSway
			local tween2 = TweenService:Create(
				guiObject,
				TweenInfo.new(hoverBobSwaySeconds, sine, Enum.EasingDirection.InOut, -1, true),
				{
					Rotation = rotation + hoverBobSway
				}
			)
			table.insert(tweens, tween2)
			tween2:Play()
		end

		return function()
			for _, v in tweens do
				v:Cancel()
				v:Destroy()
			end

			table.clear(tweens)
			guiObject.Position = position
			guiObject.Rotation = rotation
		end
	end
}