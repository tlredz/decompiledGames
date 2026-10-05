local Journal = {}
Journal.__index = Journal

function Journal.Init(_, helpers)
	local self = setmetatable({}, Journal)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Journal:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections
	local Debris = game:GetService("Debris")

	local function playSound(instance, options)
		local clone = instance:Clone()
		clone.Name = "Temp" .. clone.Name
		clone.Parent = instance.Parent

		for k, v in pairs(options or {}) do
			if tweens.hasProperty(clone, k) then
				clone[k] = v
			end
		end

		clone:Play()
		Debris:AddItem(clone, instance.TimeLength or 5)
	end

	local v = {
		StarterQuests = "Starter Tasks",
		Overview = "Home"
	}
	local v2 = {
		StarterQuests = true,
		Profiles = true
	}

	function Journal.base(instance, _)
		tweens.saveInitials(instance)

		local function updateCurrentPage()
			local currentPage = instance:GetAttribute("CurrentPage")
			local text = currentPage or ""

			if v[text] then
				text = v[text]
			end

			instance.Margin.headerTitle.Text = text
			local visible = (instance.Margin.Pages:FindFirstChild(currentPage or "") and true or false) and not v2[currentPage]
			instance.Margin.headerTitle.Visible = visible
			instance.Margin.Display.headerTop.Visible = visible
			instance.Margin.Display.headerBottom.Visible = visible

			if not instance.Visible then
				return
			end

			local display = instance.Margin.Display
			instance:GetAttribute("CurrentCategory")
			local random = Random.new(tick())

			if currentPage == "Stickers" then
				playSound(game.SoundService.UI.book3, {
					PlaybackSpeed = random:NextNumber(1, 1.15),
					TimePosition = 0.75
				})
			else
				playSound(game.SoundService.UI.book4, {
					PlaybackSpeed = random:NextNumber(1, 1.5)
				})
			end

			tweens.playTween(display.pages, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = tweens.getInitial(display.pages, "Size") + UDim2.fromScale(-0.05, 0.1)
			})
			tweens.playTween(display.bookmarks, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = tweens.getInitial(display.bookmarks, "Size") + UDim2.fromScale(-0.05, 0.1)
			})
			tweens.playTween(
				instance.Margin.Pages,
				TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Position = UDim2.fromScale(0, 0.475)
				}
			)
			task.wait(0.15)
			tweens.playTween(display.pages, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = tweens.getInitial(display.pages, "Size")
			})
			tweens.playTween(display.bookmarks, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Size = tweens.getInitial(display.bookmarks, "Size")
			})
			tweens.playTween(
				instance.Margin.Pages,
				TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Position = tweens.getInitial(instance.Margin.Pages, "Position")
				}
			)
		end

		instance:GetAttributeChangedSignal("CurrentPage"):Connect(function()
			updateCurrentPage()
		end)
		updateCurrentPage()
		instance:GetPropertyChangedSignal("Visible"):Connect(function()
			Random.new(tick())

			if instance.Visible then
				playSound(game.SoundService.UI.book1, {
					PlaybackSpeed = 1.25
				})
			else
				playSound(game.SoundService.UI.book2, {
					PlaybackSpeed = 2,
					TimePosition = 0.5
				})
			end
		end)
	end

	Journal.states = {
		templateState = function(_, _) end
	}
	Journal.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Journal