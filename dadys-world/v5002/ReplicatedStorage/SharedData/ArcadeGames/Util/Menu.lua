local Menu = {}
local TweenService = game:GetService("TweenService")
local styleController = require(game.ReplicatedStorage.SharedUtils.styleController)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

function Menu:SetVisible(flag: boolean)
	local v = flag == true
	self.Frame:SetAttribute("Visible", v)
	self.Frame.Interactable = false
	self._transitionToken = (self._transitionToken or 0) + 1
	local _transitionToken = self._transitionToken
	local tween = TweenService:Create(self.Frame, tweenInfo, {
		Position = UDim2.fromScale(0.5, v and 0.5 or 1.5)
	})

	if v then
		tween.Completed:Connect(function()
			if self._transitionToken == _transitionToken and self.Frame:GetAttribute("Visible") == true then
				self.Frame.Interactable = true
			end
		end)
	end

	tween:Play()
end

function Menu:new(params, object)
	local object2 = setmetatable({}, {
		__index = Menu
	})
	object2.Connections = {}
	object2.styleController = styleController.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect()
		for _, connection in pairs(object2.Connections) do
			connection:Disconnect()
		end
	end

	object2.Frame = self
	object2.Params = params
	self:SetAttribute("Visible", false)
	self.Position = UDim2.fromScale(0.5, 1.5)
	self.Interactable = false
	self.Visible = true
	object2.Connections[#object2.Connections + 1] = self.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			disconnect() -- equivalent call inferred; original call site unknown
		end
	end)

	if not params.MenuOptions then
		return object2
	end

	local options = self:FindFirstChild("Options")
	local list = options and options:FindFirstChild("List")

	if options then
		object2.styleController:Apply(options, "Shared.SwimmyBarnaby.options")
	end

	if not list then
		return object2
	end

	for childName, menuOption in pairs(params.MenuOptions) do
		local child = list:FindFirstChild(childName)

		if not child then
			continue
		end

		object2.styleController:Apply(child, "Shared.SwimmyBarnaby.button")
		local imageButton = child:FindFirstChildWhichIsA("ImageButton")

		if not imageButton then
			continue
		end

		local v = menuOption
		imageButton.MouseButton1Click:Connect(function()
			if object then
				object:RunMenuOption(v, self)
			else
				v(self)
			end
		end)
	end

	return object2
end

return Menu