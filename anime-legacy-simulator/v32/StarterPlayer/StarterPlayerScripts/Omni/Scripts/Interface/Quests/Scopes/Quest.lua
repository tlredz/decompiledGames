local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local module2 = require("./../Controller")
local scroll = module.Interface:WaitForChild("Frames"):WaitForChild("Quests"):WaitForChild("Quests"):WaitForChild("Scroll")
local quests = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Quests")
return fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Transparency = self:Value(0)
		self.TransparencySpring = self:Spring(self.Transparency, 10, 1)
		self.Progress = self:Value(0)
		self.ProgressSpring = self:Spring(self.Progress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = quests.Quest:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Info.Title.Text = self.Name
		self.Instance.Main.Info.Desc.Text = self.Description
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			module2.SetQuest(self.Name)
		end)
		module.Button:Create(self.Instance.Main.Pin.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Quests", "Pin", self.Class, self.Name)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance)({
			GroupTransparency = self.TransparencySpring
		})
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.ProgressSpring):onBind(function()
			local progressSpring = self.peek(self.ProgressSpring)

			if not progressSpring then
				return
			end

			self.Instance.Main.Progress.Value.Text = module.Utils.Number:Round(progressSpring * 100) .. "%"

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
		local visible = module2.CurrentQuest == self.Name
		local enabled = module.Data.Quests.Pinned and module.Data.Quests.Pinned.Name == self.Name
		local questProgress = module.Shared.Quests.GetQuestProgress(self.Name, self.Class, module.Data)
		self.Instance.Main.Hover.Visible = visible
		self.Instance.Main.Pin.Main.UIGradient.Enabled = enabled
		self.Instance.Main.Claimed.Visible = self.Claimed
		self.Instance.Main.SelectedFrame.Claimed.Enabled = self.Claimed
		self.Instance.Main.SelectedFrame.Claimable.Enabled = not self.Claimed and questProgress == 1
		self.Progress:set(questProgress)
		self.Transparency:set(visible and 0 or 0.4)
	end
})