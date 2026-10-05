local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local packages = ReplicatedStorage.packages
require(packages.Signal)
local UIDialog = {}
UIDialog.__index = UIDialog

function UIDialog.new(_)
	local v = {}
	setmetatable(v, UIDialog)
	local clone = script.Dialog:Clone()
	clone.Enabled = false
	v.UI = clone
	v.Active = false
	v.CurrentOutput = nil
	return v
end

function UIDialog:Visibility(flag: boolean?)
	if self.UI then
		self.UI.Enabled = flag or not self.UI.Enabled
	end
end

function UIDialog:StartDialog(p)
	local UserInputService = game:GetService("UserInputService")
	self:Visibility(true)
	local frame = self.UI.Frame
	local text = frame.Text
	local options = frame.Options
	local more = frame.More

	local function clicked(p2)
		if table.find({ Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1 }, p2.UserInputType) and p2.KeyCode == Enum.KeyCode.ButtonA then
			return true
		end

		return false
	end

	task.spawn(function()
		local v = next(p)
		local inputBeganConnection = nil
		self.Active = true

		while true do
			local v2 = v and self.Active and p[v]

			if not v2 then
				break
			end

			if type(v2) == "function" then
				v2()
				v += 1
				return
			else
				frame.Speaker.Text = p.Speaker or "???"
				more.Visible = false

				for _, button in options:GetChildren() do
					if button:IsA("GuiButton") then
						button:Destroy()
					end
				end

				local text2 = v2.text or ""
				local t = v2.t or 0.05
				text.MaxVisibleGraphemes = 0
				text.Text = text2
				local v3 = false
				inputBeganConnection = UserInputService.InputBegan:Connect(function(_)
					if not clicked then
						return
					end

					v3 = true
				end)

				for i = 1, #text.ContentText do
					if self.Active and not v3 then
						text.MaxVisibleGraphemes = i
						local lastTime = tick()

						while task.wait() and not (t <= tick() - lastTime) and self.Active and not v3 do

						end
					else
						break
					end
				end

				text.MaxVisibleGraphemes = -1

				if inputBeganConnection then
					inputBeganConnection:Disconnect()
				end

				local nextline = nil
				local v4 = nil

				if next(v2.choices) then
					for k, choice in v2.choices do
						local clone = script.OptionSample:Clone()
						clone.Name = k
						clone.Text = choice.text
						clone.Parent = options
						local buttonColor = choice.buttonColor

						if buttonColor then
							clone.TextColor3 = buttonColor
							clone.UIStroke.Color = buttonColor
						end

						local buttonSize = choice.buttonSize

						if buttonSize then
							clone.UIAspectRatioConstraint.AspectRatio = buttonSize
						end

						local v5 = k
						local v6 = choice
						clone.MouseButton1Click:Once(function()
							if nextline then
								return
							end

							v4 = v5
							nextline = v6.nextline or 0
						end)
					end
				else
					more.Visible = true
					task.wait(0.25)
					inputBeganConnection = UserInputService.InputBegan:Connect(function(_)
						if not clicked then
							return
						end

						nextline = true
						inputBeganConnection:Disconnect()
					end)
				end

				while task.wait() and not nextline and self.Active do

				end

				more.Visible = false
				v4 = next(v2.choices) and v2.choices[v4]

				if v4 and v4.run then
					v4.run()
				end

				v = nextline ~= true and nextline or v2.nextline or v + 1
			end
		end

		self.Active = false

		if self and self.Visibility then
			self:Visibility(false)
		end
	end)
end

function UIDialog:Destroy()
	self.Active = false

	if self.UI then
		self.UI:Destroy()
	end

	if self.OnDialogEnd then
		self.OnDialogEnd:Destroy()
	end

	setmetatable(self, nil)
end

return UIDialog