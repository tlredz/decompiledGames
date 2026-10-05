local Bookmarks = {}
Bookmarks.__index = Bookmarks

function Bookmarks.Init(_, helpers)
	local self = setmetatable({}, Bookmarks)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Bookmarks:LoadStylesheet()
	local tweens = self.tweens
	local _ = self.helpers.isState
	local _ = self.helpers.getState
	local _ = self.helpers.addConnection
	local _ = self.helpers.clearConnections

	function Bookmarks.base(instance, object)
		local function absoluteToScalePos(p2, p3)
			local v = (p2.AbsolutePosition - p3.AbsolutePosition) / p3.AbsoluteSize
			return UDim2.fromScale(v.X, v.Y)
		end

		local function absoluteToScaleSize(p2, p3)
			local v = (p2.AbsolutePosition - p3.AbsolutePosition) / p3.AbsoluteSize
			return UDim2.fromScale(v.X, v.Y)
		end

		local v = {}

		for _, button in pairs(instance:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			local parent = instance.Parent
			local v3 = (button.AbsolutePosition - parent.AbsolutePosition) / parent.AbsoluteSize
			local v2 = {
				Position = UDim2.fromScale(v3.X, v3.Y),
				Scale = 0
			}
			local parent2 = instance.Parent
			local v4 = (button.AbsolutePosition - parent2.AbsolutePosition) / parent2.AbsoluteSize
			v2.Scale = UDim2.fromScale(v4.X, v4.Y)
			v[button] = v2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function reparentPreserveSize(button, parent)
			local absoluteSize = button.AbsoluteSize
			local absoluteSize2 = parent.AbsoluteSize
			local v2 = absoluteSize.X / absoluteSize2.X
			local v3 = absoluteSize.Y / absoluteSize2.Y
			button.Size = UDim2.fromScale(v2, v3)
			button.Parent = parent
		end

		for _, button in pairs(instance:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			button.Position = v[button].Position
			reparentPreserveSize(button, instance.Parent) -- equivalent call inferred; original call site unknown
			object:Apply(button, "Shared.Journal.bookmarkButton")
			local v2 = button
			button.MouseButton1Click:Connect(function()
				object:SetState(v2, "selected")
			end)

			if button.Name == object.gui:GetAttribute("CurrentCategory") then
				object:SetState(button, "selected")
			end
		end

		object.gui:GetAttributeChangedSignal("CurrentCategory"):Connect(function()
			local currentCategory = object.gui:GetAttribute("CurrentCategory")
			local child = instance.Parent:FindFirstChild(currentCategory)

			if child then
				object:SetState(child, "selected")
			end
		end)
		tweens.saveInitials(instance)
	end

	Bookmarks.states = {
		templateState = function(_, _) end
	}
	Bookmarks.flags = {
		templateFlag = function(_, _, _) end
	}
end

return Bookmarks