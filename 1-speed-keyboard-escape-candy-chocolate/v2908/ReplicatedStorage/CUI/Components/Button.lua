require(script.Parent.Parent.Types)
return function(_, p)
	local extended = p.extend("Button", "Button")

	function extended:Init()
		function self.Callback() end

		self.NeedConfirmation = false
		self.ButtonText = ""
		local thread = nil
		self.UI.Btn.MouseButton1Click:Connect(function()
			if not self:GetEnabled() then
				return
			end

			if not self.NeedConfirmation then
				self.Callback()
			elseif thread then
				task.cancel(thread)
				thread = nil
				self.UI.Btn.Text = self.ButtonText
				self.Callback()
			else
				self.UI.Btn.Text = "Confirm?"
				thread = task.delay(2, function()
					self.UI.Btn.Text = self.ButtonText
					thread = nil
				end)
			end
		end)
	end

	function extended:SetButtonText(p3: string)
		if self.UI and self.UI.Parent then
			self.ButtonText = p3
			self.UI.Btn.Text = p3
		end

		return self
	end

	function extended.GetButtonText(p2)
		return p2.ButtonText
	end

	function extended:SetButtonCallback(callback)
		self.Callback = callback
		return self
	end

	function extended.SetYSize(p2, p3: number)
		p2.UI.Size = UDim2.new(1, 0, 0, p3)
		return p2
	end

	function extended:DoNeedConfirmation(needConfirmation: boolean)
		self.NeedConfirmation = needConfirmation
		return self
	end

	function extended.SetButtonColor(p2, backgroundColor: Color3)
		p2.UI.Btn.BackgroundColor3 = backgroundColor
		return p2
	end

	function extended.GetButtonColor(p2)
		return p2.UI.Btn.BackgroundColor3
	end

	function extended.GetButtonOriginalColor(p2)
		return p2.OriginalUI.Btn.BackgroundColor3
	end

	function extended.UpdateEnabledDisplay(object)
		local enabled = object:GetEnabled()
		object.UI.Btn.AutoButtonColor = enabled
		local btn = object.UI.Btn
		local backgroundColor

		if enabled then
			backgroundColor = object.OriginalUI.Btn.BackgroundColor3
		else
			backgroundColor = Color3.fromRGB(110, 110, 110)
		end

		btn.BackgroundColor3 = backgroundColor
		local btn2 = object.UI.Btn
		local textColor

		if enabled then
			textColor = object.OriginalUI.Btn.TextColor3
		else
			textColor = Color3.fromRGB(191, 191, 191)
		end

		btn2.TextColor3 = textColor
	end

	return extended
end