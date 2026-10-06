local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 162, 0)
local color3 = Color3.fromRGB(255, 83, 83)
local fusion = module.Libs.Fusion
local module2 = require("./../Controller")
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("Quests"):WaitForChild("Categories"):WaitForChild("Scroll")
local quests = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Quests")
return fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.SelectionProgress = self:Value(0)
		self.SelectionProgressSpring = self:Spring(self.SelectionProgress, 10, 1)
		self.Instance = quests.Category:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			module2.SetCategory(self.Name)
		end)
		self.Instance.LayoutOrder = self.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance)({
			GroupTransparency = self.TransparencySpring
		})
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.SelectionProgressSpring):onBind(function()
			local selectionProgressSpring = self.peek(self.SelectionProgressSpring)

			if not selectionProgressSpring then
				return
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color:Lerp(color2, selectionProgressSpring)),
				ColorSequenceKeypoint.new(1, color:Lerp(color3, selectionProgressSpring))
			})
			self.Instance.Main.UIGradient.Color = colorSequence
			self.Instance.Main.Title.UIGradient.Color = colorSequence
		end)

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		self.SelectionProgress:set(module2.CurrentCategory == self.Name and 1 or 0)
	end
})