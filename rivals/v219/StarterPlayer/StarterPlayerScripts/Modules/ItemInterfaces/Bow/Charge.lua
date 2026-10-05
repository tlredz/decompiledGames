local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local bowCharge = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BowCharge")
local Charge = {}
Charge.__index = Charge

function Charge.new(itemInterface)
	local self = setmetatable({}, Charge)
	self.ItemInterface = itemInterface
	self.Frame = bowCharge:Clone()
	self.DamageText = self.Frame:WaitForChild("Damage")
	self.Background = self.Frame:WaitForChild("Background")
	self.BackgroundDivider2 = self.Background:WaitForChild("Divider2")
	self.BackgroundDivider3 = self.Background:WaitForChild("Divider3")
	self.BackgroundBar = self.Background:WaitForChild("Bar")
	self.BackgroundEffect = self.Background:WaitForChild("Effect")
	self.BackgroundEffectUIStroke = self.BackgroundEffect:WaitForChild("UIStroke")
	self.KeyWhiteFrame = self.Background:WaitForChild("KeyWhite")
	self.KeyColorFrame = self.Background:WaitForChild("KeyColor")
	self.KeyColorCircleStroke = self.KeyColorFrame:WaitForChild("Circle"):WaitForChild("UIStroke")
	self._destroyed = false
	self._start_time = nil
	self._charge_hash = 0
	self._max_charge_connection = nil
	self:_Init()
	return self
end

function Charge:Set(p)
	if self._destroyed then
		return
	end

	if self._max_charge_connection then
		self._max_charge_connection:Disconnect()
		self._max_charge_connection = nil
	end

	local chargeColor = self.ItemInterface.ClientItem.ViewModel:GetChargeColor(p)
	local chargeLevelDamageMultipliers = self.ItemInterface.ClientItem.Info.ChargeLevelDamageMultipliers
	self.Frame.Position = UDim2.new(0.5, 24, 0.5, 24)
	self.DamageText.Text = "<font family=\"12187365977\"><stroke color=\"rgb(255,255,255)\" joins=\"miter\" thickness=\"3\">" .. math.floor(chargeLevelDamageMultipliers[p] * 100) .. "%</stroke></font>"
	self.DamageText.TextColor3 = chargeColor
	self.DamageText.Size = UDim2.new(1, 0, p == 1 and 0.5 or 0.75, 0)
	self.DamageText:TweenSize(UDim2.new(1, 0, 0.5, 0), "Out", "Quint", 0.5, true)
	self.BackgroundEffectUIStroke.Color = chargeColor
	self.BackgroundBar.BackgroundColor3 = chargeColor
	self.KeyColorCircleStroke.Color = chargeColor

	if #chargeLevelDamageMultipliers <= p then
		self._max_charge_connection = RunService.RenderStepped:Connect(function(_)
			self.Frame.Position = UDim2.new(0.5, 24 + 8 * (math.random() - 0.5), 0.5, 24 + 8 * (math.random() - 0.5))
		end)
	end
end

function Charge:Start(list)
	if self._destroyed then
		return
	end

	assert(typeof(list) == "table", "Argument 1 invalid, expected a table")
	self._charge_hash += 1
	self._start_time = tick()
	self.Frame.Visible = true
	self.BackgroundBar.Size = UDim2.new(0, 8, 1, 0)
	self.BackgroundBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", list[#list], true)
	self.BackgroundEffect.Size = UDim2.new(1, 0, 1, 0)
	self.BackgroundEffect.Visible = false
	local v = {}

	for k, v2 in pairs(list) do
		local v3 = v2 / list[#list]
		local chargeColor = self.ItemInterface.ClientItem.ViewModel:GetChargeColor(k)
		table.insert(v, ColorSequenceKeypoint.new(v3, chargeColor))

		if k ~= 1 and k ~= #list then
			self["BackgroundDivider" .. k].Position = UDim2.new(v2 / list[#list], 0, 0, 0)
		end
	end
end

function Charge:Play()
	if self._destroyed then
		return
	end

	self.Background.Size = UDim2.new(1, 0, 0.375, 0)
	self.Background:TweenSize(UDim2.new(1, 0, 0.25, 0), "Out", "Quint", 0.5, true)
end

function Charge:Stop(p)
	if self._destroyed then
		return
	end

	if self._max_charge_connection then
		self._max_charge_connection:Disconnect()
		self._max_charge_connection = nil
	end

	if p then
		self.Frame.Visible = false
	else
		local _charge_hash = self._charge_hash
		self.BackgroundBar:TweenSize(self.BackgroundBar.Size, "Out", "Linear", 0, true)
		self.BackgroundEffect.Visible = true
		self.BackgroundEffect:TweenSize(UDim2.new(1, 8, 1, 8), "Out", "Linear", 0.5, true, function()
			wait(0.5)

			if self._charge_hash ~= _charge_hash then
				return
			end

			self.Frame.Visible = false
		end)
	end

	if not self._start_time then
		return
	end

	self._start_time = nil
end

function Charge:Destroy()
	self._destroyed = true
	self.Frame:Destroy()

	if self._max_charge_connection then
		self._max_charge_connection:Disconnect()
		self._max_charge_connection = nil
	end
end

function Charge:_Setup()
	local visible = self.ItemInterface.ClientItem.ViewModel.Name == "Key Bow"
	self.Frame.Position += visible and UDim2.new(0, 18, 0, 0) or UDim2.new(0, 0, 0, 0)
	self.KeyWhiteFrame.Visible = visible
	self.KeyColorFrame.Visible = visible
	self.Frame.Parent = self.ItemInterface.Mouse.Frame
end

function Charge:_Init()
	self.BackgroundEffect:GetPropertyChangedSignal("Size"):Connect(function()
		self.BackgroundEffectUIStroke.Thickness = 4 - self.BackgroundEffect.Size.X.Offset / 2
	end)
	self:_Setup()
	self:Set(1)
end

return Charge