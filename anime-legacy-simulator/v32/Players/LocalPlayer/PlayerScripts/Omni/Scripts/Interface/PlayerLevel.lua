local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 8, 204)
local color3 = Color3.fromRGB(255, 0, 4)
local v = { "Stats", "Rewards" }
local fusion = module.Libs.Fusion
local Controller = require(script.Controller)
local frameOptions = module.Interface:WaitForChild("Frames"):WaitForChild("PlayerLevel"):WaitForChild("FrameOptions")
local profile = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Profile")
local innerScopes = {}
local PlayerLevel = {}
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.SelectionProgress = self:Value(0)
		self.SelectionProgressSpring = self:Spring(self.SelectionProgress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = profile.Main.FrameOption:Clone()
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

function PlayerLevel.CreateFrameButtons()
	local total = 0

	for _, name in v do
		if innerScopes[name] then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Name = name

		if innerScope:Build(total) then
			innerScopes[name] = innerScope
			total += 0.05
		else
			innerScope:doCleanup()
		end
	end
end

function PlayerLevel.RemoveFrameButtons()
	for _, v2 in innerScopes do
		v2.Instance:Destroy()
		v2:doCleanup()
	end

	table.clear(innerScopes)
end

function PlayerLevel.Init()
	Controller.InterfaceOpened:Connect(PlayerLevel.CreateFrameButtons)
	Controller.InterfaceClosed:Connect(PlayerLevel.RemoveFrameButtons)
	Controller.FrameChanged:Connect(function()
		for _, v2 in innerScopes do
			v2:Update()
		end
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

return PlayerLevel