local Mail = {}
Mail.__index = Mail

function Mail.Init(_, helpers)
	local self = setmetatable({}, Mail)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Mail:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function Mail:base(object)
		tweens.saveInitials(self)

		local function updateSortIndex()
			local sortIndex = self:GetAttribute("SortIndex")

			if not sortIndex then
				return
			end

			self.BackgroundTransparency = sortIndex % 2 == 0 and 0.86 or 0.96
		end

		local sortIndex = self:GetAttribute("SortIndex")

		if sortIndex then
			self.BackgroundTransparency = sortIndex % 2 == 0 and 0.86 or 0.96
		end

		object:AddConnection(self, "sortindex", self:GetAttributeChangedSignal("SortIndex"):Connect(function()
			local sortIndex2 = self:GetAttribute("SortIndex")

			if not sortIndex2 then
				return
			end

			self.BackgroundTransparency = sortIndex2 % 2 == 0 and 0.86 or 0.96
		end))
	end

	Mail.states = {
		templateState = function(_, _) end
	}
	Mail.flags = {
		Selected = function(_, _, _) end,
		Hovered = function(instance, p2, _)
			local canvasGroup = instance:FindFirstChild("CanvasGroup")

			if not canvasGroup then
				return
			end

			if p2 then
				tweens.playTween(canvasGroup, TweenInfo.new(0.25), {
					GroupColor3 = Color3.fromRGB(220, 223, 201)
				})
				return
			end

			local color = instance:GetAttribute("Read") and Color3.fromRGB(185, 190, 160) or Color3.fromRGB(
				255,
				255,
				255
			)
			tweens.playTween(canvasGroup, TweenInfo.new(0.25), {
				GroupColor3 = color
			})
		end,
		Read = function(instance, p2, _)
			local unread = instance:FindFirstChild("Unread", true)

			if unread then
				unread.Visible = not p2
			end

			local icon = instance:FindFirstChild("Icon", true)

			if icon then
				icon.ImageTransparency = p2 and 0.82 or 0
			end

			if p2 then
				for _, label in pairs(instance:GetChildren()) do
					if not (label:IsA("TextLabel") and label.TextColor3 ~= Color3.fromRGB(255, 255, 255)) then
						continue
					end

					label.TextColor3 = Color3.fromRGB(37, 152, 95)
					local uIScale = label:FindFirstChild("UIScale")

					if uIScale then
						uIScale.Scale = 1
					end
				end
			else
				for _, label in pairs(instance:GetChildren()) do
					if not (label:IsA("TextLabel") and label.TextColor3 ~= Color3.fromRGB(255, 255, 255)) then
						continue
					end

					label.TextColor3 = Color3.fromRGB(139, 255, 130)
					local uIScale = label:FindFirstChild("UIScale")

					if uIScale then
						uIScale.Scale = 1.2
					end
				end
			end
		end
	}
end

return Mail