local PageTemplate = {}
PageTemplate.__index = PageTemplate

function PageTemplate.Init(_, helpers)
	local self = setmetatable({}, PageTemplate)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function PageTemplate:LoadStylesheet()
	local tweens = self.tweens

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tint(margin, color: Color3)
		margin.Preview.ToonThumbnail.Thumbnail.ImageColor3 = color
		margin.ProgressFrame.fill.ImageColor3 = color
		margin.ProgressFrame.empty.ImageColor3 = color
		margin.ProgressFrame.highlight.ImageColor3 = color
	end

	function PageTemplate.base(p2)
		tweens.saveInitials(p2)
	end

	PageTemplate.states = {
		locked = function(p2, object)
			object:ClearConnections(p2, "state")
			local margin = p2.Margin
			margin.Locked.Visible = true
			tint(margin, Color3.fromRGB(0, 0, 0)) -- equivalent call inferred; original call site unknown
			margin.ProgressFrame.TextLabel.Visible = false
			margin.TextButton.Title.Text = "LOCKED"
			object:SetState(margin.TextButton, "inactive")
		end,
		unlocked = function(data, object)
			object:ClearConnections(data, "state")
			local margin = data.Margin
			margin.Locked.Visible = false
			tint(margin, Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
			margin.ProgressFrame.TextLabel.Visible = true
			margin.TextButton.Title.Text = "VIEW QUEST"
			object:SetState(margin.TextButton, "active")
			object:AddConnection(data, "state", data.MouseEnter:Connect(function()
				tweens.playTween(margin.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 0.9
				})
			end))
			object:AddConnection(data, "state", data.MouseLeave:Connect(function()
				tweens.playTween(margin.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
					Scale = 1
				})
			end))
		end
	}
	PageTemplate.flags = {}
end

return PageTemplate