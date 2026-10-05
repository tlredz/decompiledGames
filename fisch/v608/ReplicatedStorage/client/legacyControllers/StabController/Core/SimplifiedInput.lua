local UserInputService = game:GetService("UserInputService")
game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Trove)
local Signal = require(ReplicatedStorage.packages.Signal)
require("../Types")
local SimplifiedInput = {}
SimplifiedInput.__index = SimplifiedInput

function SimplifiedInput.new(current)
	local object = setmetatable({}, SimplifiedInput)
	object.current = current
	object.trove = current.trove:Extend()
	object.Disabled = false
	object.ExpectedSide = "left"
	object.AcceptAny = false
	object.LastCorrectInput = 0
	object.OnCorrectInput = object.trove:Add(Signal.new())
	object.OnIncorrectInput = object.trove:Add(Signal.new())
	return object
end

function SimplifiedInput:Start()
	if not self.current.isSimplified then
		self:Disable()
		return
	end

	self:SetupInputGuides()
	self.trove:Add(UserInputService.InputBegan:Connect(function(input, _)
		if self.Disabled or not self.current.active then
			return
		end

		local v

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v = "left"
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			v = "right"
		elseif input.KeyCode == Enum.KeyCode.ButtonA then
			v = "left"
		elseif input.KeyCode == Enum.KeyCode.ButtonB then
			v = "right"
		else
			v = nil
		end

		if v then
			self:ProcessInput(v)
		end
	end))
	self.trove:Add(UserInputService.TouchStarted:Connect(function(p, p2)
		if self.Disabled or not self.current.active or p2 then
			return
		end

		local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		self:ProcessInput(p.Position.X < viewportSize.X / 2 and "left" or "right")
	end))
	self.current.OnReady:Once(function()
		self.LastCorrectInput = tick()
	end)
	self:UpdateArrows()
end

function SimplifiedInput:SetupInputGuides()
	local pc = self.current.reel_bar:FindFirstChild("pc")
	local text = pc and pc:FindFirstChild("text")

	if text then
		text.Text = "LMB / RMB"
	end

	local mobile = self.current.reel_bar:FindFirstChild("mobile")
	local text2 = mobile and mobile:FindFirstChild("text")

	if text2 then
		text2.Text = "Tap Left / Right"
	end

	local xboxcontrol = self.current.reel_playerbar:FindFirstChild("xboxcontrol")

	if xboxcontrol and xboxcontrol:IsA("ImageLabel") then
		xboxcontrol.Image = "rbxasset://textures/ui/Controls/xboxB.png"
	end
end

function SimplifiedInput:UpdateInputGuide()
	if UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
		return
	end

	local xboxcontrol = self.current.reel_playerbar:FindFirstChild("xboxcontrol")

	if xboxcontrol and xboxcontrol:IsA("ImageLabel") then
		xboxcontrol.Image = self.ExpectedSide == "left" and "rbxasset://textures/ui/Controls/xboxA.png" or "rbxasset://textures/ui/Controls/xboxB.png"
	end
end

function SimplifiedInput:UpdateArrows()
	self:UpdateInputGuide()
	local left = self.current.reel_playerbar:FindFirstChild("left")
	local right = self.current.reel_playerbar:FindFirstChild("right")

	if left then
		left.Visible = self.ExpectedSide == "left"
	end

	if right then
		right.Visible = self.ExpectedSide == "right"
	end
end

function SimplifiedInput:ProcessInput(p: string)
	if self.ExpectedSide ~= p and not self.AcceptAny then
		self.OnIncorrectInput:Fire(p, self.ExpectedSide)
		return false
	end

	local expectedSide = self.ExpectedSide
	self.ExpectedSide = p == "left" and "right" or "left"
	self.current.OnBarDirectionChange:Fire(p == "right" and 1 or -1)
	self:UpdateArrows()

	if tick() - self.LastCorrectInput < 0.01 then
		return true
	end

	self.LastCorrectInput = tick()
	self.OnCorrectInput:Fire(p, expectedSide)
	return true
end

function SimplifiedInput:Disable()
	self.Disabled = true
end

function SimplifiedInput.Stop(p)
	p.trove:Clean()
end

function SimplifiedInput.Tick(_, _: number) end

return SimplifiedInput