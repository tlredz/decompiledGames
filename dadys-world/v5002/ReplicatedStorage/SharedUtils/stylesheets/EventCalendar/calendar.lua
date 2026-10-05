local Calendar = {}
Calendar.__index = Calendar

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p: string, p2)
	task.spawn(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		require(ReplicatedStorage.SharedUtils.Audio):Play("Sounds.UI.EventCalendar." .. p, p2)
	end)
end

function Calendar.Init(_, helpers)
	local self = setmetatable({}, Calendar)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Calendar:LoadStylesheet()
	local tweens = self.tweens

	function Calendar.base(p2)
		tweens.saveInitials(p2.Parent)
	end

	Calendar.states = {
		closed = function(_, _) end,
		open = function(_, _) end,
		opening = function(state, object)
			local parent = state.Parent
			local display = state.Display
			local claim = parent.Claim
			object.gui.ExitButton.Visible = false
			display.calendar.Visible = false
			claim.Visible = false
			parent.QuestTab.Visible = false
			parent.Sticky.Visible = false
			state.Key.Visible = false
			state.Visible = false
			state.Calendar.Visible = false
			state.Calendar.ZIndex = -4
			display.calendar.ZIndex = -5
			playSound("paper1", nil) -- equivalent call inferred; original call site unknown
			playSound("paper3", nil) -- equivalent call inferred; original call site unknown
			state.Visible = true
			task.wait()
			display.background.UIScale.Scale = 1.6
			tweens.fadeIn(display.background, TweenInfo.new(0.15))
			tweens.playTween(
				display.background.UIScale,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Scale = 1
				}
			)
			task.wait(0.5)
			tweens.fadeIn(display.calendar, TweenInfo.new(0.5))
			claim.Rotation = 50
			claim.Position = UDim2.fromScale(1, -0.2)
			state.Visible = true
			state.Calendar.Visible = true
			display.calendar.ZIndex = -5
			state.Calendar.ZIndex = -4
			tweens.playTween(state.Calendar, TweenInfo.new(0.5, Enum.EasingStyle.Circular), {
				Position = UDim2.fromScale(0.502, -0.075)
			})
			tweens.playTween(display.background, TweenInfo.new(0.5, Enum.EasingStyle.Circular), {
				Position = UDim2.fromScale(0.5, 0.7)
			})
			tweens.playTween(display.calendar, TweenInfo.new(0.5, Enum.EasingStyle.Circular), {
				Position = UDim2.fromScale(0.5, 0)
			})
			task.wait(0.5)
			playSound("paper2", nil) -- equivalent call inferred; original call site unknown
			display.calendar.ZIndex = 0
			state.Calendar.ZIndex = 1
			tweens.playTween(state.Calendar, TweenInfo.new(0.5, Enum.EasingStyle.Circular), {
				Position = state.Calendar:GetAttribute("start_Position")
			})
			tweens.playTween(display.background, TweenInfo.new(0.5, Enum.EasingStyle.Circular), {
				Position = UDim2.fromScale(0.5, 0.485)
			})
			tweens.playTween(display.calendar, TweenInfo.new(0.5, Enum.EasingStyle.Circular), {
				Position = UDim2.fromScale(0.504, 0.574)
			})
			tweens.fadeIn(parent.Sticky, TweenInfo.new(0.5))
			tweens.fadeIn(state.Key, TweenInfo.new(0.5))
			tweens.fadeIn(parent.QuestTab, TweenInfo.new(0.5))
			tweens.fadeIn(claim, TweenInfo.new(0.5))
			tweens.playTween(claim, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
				Position = claim:GetAttribute("start_Position"),
				Rotation = 2
			})
			task.wait(2)
			object:SetState(state, "open")
			tweens.playTween(claim, TweenInfo.new(10, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, -1, true), {
				Rotation = -2
			})
		end
	}
	Calendar.flags = {}
end

return Calendar