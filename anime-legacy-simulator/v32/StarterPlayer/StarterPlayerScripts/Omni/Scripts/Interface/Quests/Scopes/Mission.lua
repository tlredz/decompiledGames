local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
require("./../Controller")
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("Quests"):WaitForChild("RightFrame"):WaitForChild("Missions"):WaitForChild("Scroll")
local quests = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Quests")
return fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.NeededText = module.Utils.Number:Format(self.Info.Amount)
		self.Progress = self:Value(0)
		self.ProgressSpring = self:Spring(self.Progress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = quests.Mission:Clone()
		self.Instance.Name = self.Index
		self.Instance.Main.Title.Text = self.Info.Title
		self.Instance.Main.Desc.Text = self.Info.Description
		self.Instance.LayoutOrder = self.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.ProgressSpring):onBind(function()
			local progressSpring = self.peek(self.ProgressSpring)

			if not progressSpring then
				return
			end

			local rounded = module.Utils.Number:Round(self.Info.Amount * progressSpring)
			local formatted = module.Utils.Number:Format(rounded)
			self.Instance.Main.Progress.Value.Text = formatted .. " / " .. self.NeededText

			if progressSpring == 1 then
				self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0)
				})
				return
			elseif progressSpring == 0 then
				self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
				return
			end

			local numberSequenceKeypoints = {}
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(progressSpring, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, progressSpring + 0.1), 1))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
			self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
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
		self.Progress:set(self.Amount / self.Info.Amount)
	end
})