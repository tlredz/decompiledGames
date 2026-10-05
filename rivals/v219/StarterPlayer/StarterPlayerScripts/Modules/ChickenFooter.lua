local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local FunFacts = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("FunFacts"))
local chickenFooter = Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("UserInterface"):WaitForChild("ChickenFooter")
local v = {
	Chicken = "rbxassetid://133917828562858",
	Sensei = "rbxassetid://118135633428557",
	Nosniy = "rbxassetid://132709758724537",
	Neko = "rbxassetid://77873164738983",
	Bandoboy = "rbxassetid://121503061771505"
}
local v2 = { "00bandoboy wuz here", "00nly my followers can play my secret gamemode in Private Servers" }
local ChickenFooter = {}
ChickenFooter.__index = ChickenFooter

function ChickenFooter.new()
	local self = setmetatable({}, ChickenFooter)
	self.Frame = chickenFooter:Clone()
	self.Picture = self.Frame:WaitForChild("Picture")
	self.PictureButton = self.Picture:WaitForChild("Button")
	self.TimerText = self.Frame:WaitForChild("Timer")
	self.StatusText = self.Frame:WaitForChild("Status")
	self.DescriptionFrame = self.Frame:WaitForChild("Description")
	self.DescriptionTitle = self.DescriptionFrame:WaitForChild("Title")
	self.DescriptionBackground = self.DescriptionFrame:WaitForChild("Background")
	self._connections = {}
	self._description_original_size = self.DescriptionFrame.Size
	self._picture_original_size = self.Picture.Size
	self._timer_hash = 0
	self._fun_facts_enabled = false
	self._last_fun_fact = nil
	self._is_shown = nil
	self:_Init()
	return self
end

function ChickenFooter.SetParent(p, parent)
	p.Frame.Parent = parent
end

function ChickenFooter:SetStatus(value)
	self.StatusText.Text = value or ""
end

function ChickenFooter:SetTimer(value)
	self.TimerText.Text = value or ""
end

function ChickenFooter:SetPicture(p2)
	self.Picture.Image = v[p2] or ""
end

function ChickenFooter:SetMessage(value)
	local text = value or ""
	local v4 = text == ""
	self.DescriptionTitle.Text = text
	self.DescriptionFrame.Visible = not v4
	local _description_original_size = self._description_original_size
	local uDim

	if v4 then
		uDim = UDim2.new(0.075, 0, 1.5, 0)
	else
		uDim = UDim2.new(0.075, 0, 1, 0)
	end

	local _picture_original_size = self._picture_original_size

	if self.Frame:IsDescendantOf(Players) then
		self.Picture:TweenPosition(uDim, "Out", "Quint", 0.25, true)

		if not v4 then
			self.Picture.Size = UDim2.new(
				_picture_original_size.X.Scale * 0.8,
				0,
				_picture_original_size.Y.Scale * 1.2,
				0
			)
			self.Picture:TweenSize(_picture_original_size, "Out", "Back", 0.5, true)
			self.DescriptionFrame.Size = UDim2.new(
				_description_original_size.X.Scale * 0.8,
				0,
				_description_original_size.Y.Scale * 1.2,
				0
			)
			self.DescriptionFrame:TweenSize(_description_original_size, "Out", "Back", 0.25, true)
		end
	else
		self.Picture.Position = uDim
		self.Picture.Size = _picture_original_size
		self.DescriptionFrame.Size = _description_original_size
	end

	self:_Update()
end

function ChickenFooter:EnableFunFacts()
	if self._fun_facts_enabled then
		return
	end

	self._fun_facts_enabled = true
	self:_NewFunFact()
end

function ChickenFooter:DisableFunFacts()
	if not self._fun_facts_enabled then
		return
	end

	self._fun_facts_enabled = false
end

function ChickenFooter:EnableTimer()
	task.spawn(function()
		self._timer_hash += 1
		local _timer_hash = self._timer_hash

		for i = 0, 1e999 do
			self:SetTimer(i)
			wait(1)

			if _timer_hash ~= self._timer_hash then
				break
			end
		end
	end)
end

function ChickenFooter:DisableTimer()
	self._timer_hash += 1
end

function ChickenFooter:Show()
	if self._is_shown then
		return
	end

	self._is_shown = true
	self.TimerText.Visible = true
	self.StatusText.Visible = true
end

function ChickenFooter:Hide()
	if not self._is_shown then
		return
	end

	self._is_shown = false
	self:DisableFunFacts()
	self:DisableTimer()
	self:SetMessage(nil)
	self.TimerText.Visible = false
	self.StatusText.Visible = false
end

function ChickenFooter:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self:DisableTimer()
	self.Frame:Destroy()
end

function ChickenFooter:_RandomPicture()
	local v3 = {}

	for k in pairs(v) do
		table.insert(v3, k)
	end

	self:SetPicture(v3[math.random(#v3)])
end

function ChickenFooter:_NewFunFact()
	if not self._fun_facts_enabled then
		return
	end

	local v3 = nil

	for _ = 1, 10 do
		v3 = FunFacts()

		if v3 and v3 ~= self._last_fun_fact then
			break
		end
	end

	if table.find(v2, v3) then
		self:SetPicture("Bandoboy")
	else
		self:SetPicture("Chicken")

		if string.sub(v3, 1, 19) ~= "Thanks for playing," then
			v3 = "" .. v3
		end
	end

	self:SetMessage(v3)
end

function ChickenFooter:_Update()
	task.delay(0, function()
		self.DescriptionBackground.Size = UDim2.new(0.02, self.DescriptionTitle.TextBounds.X, 1, 0)
	end)
end

function ChickenFooter:_Init()
	self.PictureButton.MouseButton1Click:Connect(function()
		self:_NewFunFact()
	end)
	self.DescriptionTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_Update()
	end)
	self.DescriptionTitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self.DescriptionTitle:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_Update()
	end)
	table.insert(self._connections, UserInputService.WindowFocused:Connect(function()
		self:_Update()
	end))
	table.insert(self._connections, UserInputService.WindowFocusReleased:Connect(function()
		self:_Update()
	end))
	self:_Update()
	self:SetPicture("Chicken")
	self:SetMessage(nil)
	self:SetStatus(nil)
	self:SetTimer(nil)
	self:Show()
end

return ChickenFooter