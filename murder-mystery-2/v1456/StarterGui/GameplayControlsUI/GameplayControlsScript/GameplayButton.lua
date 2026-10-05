local gameplayContext = game.Players.LocalPlayer.PlayerGui:WaitForChild("InputContext"):WaitForChild("GameplayContext")
return {
	new = function(self)
		local v = {}
		local child = gameplayContext:WaitForChild(self.Name)
		v.Enabled = true
		v.ImageButton = self
		v.Activated = Instance.new("BindableEvent")

		function v.SetEnabled(_, flag: boolean)
			if flag == true then
				self.ControlText.TextTransparency = 0
				self.ControlIcon.ImageTransparency = 0
				self.ImageTransparency = 0
			else
				self.ControlText.TextTransparency = 0.7
				self.ControlIcon.ImageTransparency = 0.7
				self.ImageTransparency = 0.7
				self.ImageColor3 = Color3.fromRGB(0, 0, 0)
			end

			v.Enabled = flag == true
		end

		if not child then
			return v
		end

		child.TouchBinding.UIButton = self

		local function onPressed()
			if not v.Enabled then
				return
			end

			self.ImageColor3 = Color3.fromRGB(170, 170, 170)
			v.Activated:Fire()
		end

		local function onReleased()
			self.ImageColor3 = Color3.fromRGB(0, 0, 0)
		end

		child.Pressed:Connect(onPressed)
		child.Released:Connect(onReleased)
		self.MouseLeave:Connect(function()
			child:Fire(false)
		end)
		return v
	end
}