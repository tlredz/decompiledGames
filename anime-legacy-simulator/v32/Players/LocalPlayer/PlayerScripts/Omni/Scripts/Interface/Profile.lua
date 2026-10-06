local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 214, 25)
local color3 = Color3.fromRGB(255, 76, 190)
local uDim = UDim2.fromScale(0.639, -0.078)
local uDim2 = UDim2.fromScale(0.639, 0.1)
local v = { "Profile", "Leaderboards" }
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local Controller = require(script.Controller)
local profile = module.Interface:WaitForChild("Frames"):WaitForChild("Profile")
local topButtons = profile:WaitForChild("TopButtons")
local frameOptions = profile:WaitForChild("FrameOptions")
local profile2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Profile")
local innerScopes = {}
local value = scope:Value(uDim2)
local spring = scope:Spring(value, 10, 1)
local Profile = {}
local scope2 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.SelectionProgress = self:Value(0)
		self.SelectionProgressSpring = self:Spring(self.SelectionProgress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = profile2.Main.FrameOption:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Controller.OpenFrame(self.Name)
		end)
		self.Instance.Parent = frameOptions
		self.Instance.Visible = true
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
		local v2 = self.Name == Controller.CurrentFrame
		self.SelectionProgress:set(v2 and 1 or 0)
	end
})

function Profile.GetController()
	return Controller
end

function Profile.SetupTopButtons()
	scope:Hydrate(topButtons)({
		Position = spring
	})

	for _, frame in topButtons:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v2 = frame
		module.Button:Create(frame.Main, "Small"):BindFunction("Click", function()
			Controller.OpenFrame(v2.Name)
		end)
	end
end

function Profile.CreateFrameButtons()
	local total = 0

	for _, name in v do
		if innerScopes[name] then
			continue
		end

		local innerScope = scope2:innerScope()
		innerScope.Name = name

		if innerScope:Build(total) then
			innerScopes[name] = innerScope
			total += 0.05
		else
			innerScope:doCleanup()
		end
	end
end

function Profile.RemoveFrameButtons()
	for _, v2 in innerScopes do
		v2.Instance:Destroy()
		v2:doCleanup()
	end

	table.clear(innerScopes)
end

function Profile.Init()
	Profile.SetupTopButtons()
	Controller.FrameChanged:Connect(function()
		for _, v2 in innerScopes do
			v2:Update()
		end
	end)
	Controller.ProfileOpened:Connect(function()
		Profile.CreateFrameButtons()
		value:set(uDim)
	end)
	Controller.ProfileClosed:Connect(function()
		Profile.RemoveFrameButtons()
		value:set(uDim2)
	end)

	for _, moduleScript in script.Frames:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local module2 = require(moduleScript)

		if not module2 then
			continue
		end

		Controller.FrameModules[moduleScript.Name] = module2

		if module2.Init then
			module2.Init()
		end
	end
end

return Profile