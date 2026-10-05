local Menu = {}
local TweenService = game:GetService("TweenService")
local styleController = require(game.ReplicatedStorage.SharedUtils.styleController)

function Menu.SetVisible(p, flag: boolean)
	p.Frame:SetAttribute("Visible", flag == true)
end

function Menu:new(params)
	local object = setmetatable({}, {
		__index = Menu
	})
	object.Connections = {}
	object.styleController = styleController.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function disconnect()
		for _, connection in pairs(object.Connections) do
			connection:Disconnect()
		end
	end

	object.Frame = self
	object.Params = params
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	self:SetAttribute("Visible", false)
	object.Connections[#object.Connections + 1] = self:GetAttributeChangedSignal("Visible"):Connect(function()
		local visible = self:GetAttribute("Visible") == true
		TweenService:Create(self, tweenInfo, {
			Position = UDim2.fromScale(0.5, visible and 0.5 or 1.5)
		}):Play()
	end)
	object.Connections[#object.Connections + 1] = self.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			disconnect() -- equivalent call inferred; original call site unknown
		end
	end)
	self.Position = UDim2.fromScale(0.5, 1.5)
	self.Visible = true

	if not params.MenuOptions then
		return object
	end

	local options = self:FindFirstChild("Options")
	local list = options and options:FindFirstChild("List")

	if options then
		object.styleController:Apply(options, "Shared.SwimmyBarnaby.options")
	end

	if not list then
		return object
	end

	for childName, menuOption in pairs(params.MenuOptions) do
		local child = list:FindFirstChild(childName)

		if not child then
			continue
		end

		object.styleController:Apply(child, "Shared.SwimmyBarnaby.button")
		local imageButton = child:FindFirstChildWhichIsA("ImageButton")

		if not imageButton then
			continue
		end

		local v = menuOption
		imageButton.MouseButton1Click:Connect(function()
			v(self)
		end)
	end

	return object
end

return Menu