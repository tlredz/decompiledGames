local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local amountSelector = module.Interface:WaitForChild("Frames"):WaitForChild("AmountSelector")
local main = amountSelector:WaitForChild("Main")
local buttons = main:WaitForChild("Buttons")
local amount = main:WaitForChild("Amount")
local percentages = main:WaitForChild("Percentages")
local slider = main:WaitForChild("Slider")
local slider2 = slider:WaitForChild("Bar"):WaitForChild("Slider")
local point = slider:WaitForChild("Point")
local scope = fusion.scoped(fusion)
local value = scope:Value(0)
local spring = scope:Spring(value, 10, 1)
local amount2 = nil
local v = nil
local AmountSelector = {}

local function ClampAmount(p: number)
	local v2 = math.floor(p)

	if v.Minimum then
		v2 = math.max(v.Minimum, v2)
	end

	if v.Maximum then
		return (math.min(v.Maximum, v2))
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetProgress(amount3: number)
	if not v.Maximum then
		return 0
	end

	local minimum = v.Minimum or 0
	local v2 = v.Maximum - minimum

	if v2 <= 0 then
		return 1
	end

	return (math.clamp((amount3 - minimum) / v2, 0, 1))
end

local function ParseAmount(text: string)
	local v2 = string.gsub(text, "%s", "")
	local v3 = string.gsub(v2, "[xX]$", "")

	if not string.find(v3, "%d") then
		return nil
	end

	local v4 = tonumber(v3) or module.Utils.Number:Unformat(v3)

	if v4 ~= v4 or math.abs(v4) == 1e999 or v4 == 0 and not tonumber(v3) then
		return nil
	end

	return v4
end

local function SetAmount(p: number)
	if not v or (p ~= p or math.abs(p) == 1e999) then
		return
	end

	local v2 = v
	local amount3 = math.floor(p)

	if v.Minimum then
		amount3 = math.max(v.Minimum, amount3)
	end

	if v.Maximum then
		amount3 = math.min(v.Maximum, amount3)
	end

	v2.Amount = amount3
	local progress = GetProgress(v.Amount) -- equivalent call inferred; original call site unknown
	value:set(progress)
	AmountSelector.Update()
end

function AmountSelector.Update()
	if not v then
		return
	end

	if module.Services.UserInputService:GetFocusedTextBox() ~= amount.TextBox then
		amount.TextBox.Text = module.Utils.Number:Format(v.Amount) .. "x"
	end
end

function AmountSelector.Start(data)
	if v then
		return
	end

	v = {
		Amount = data.Minimum or 1,
		Minimum = data.Minimum,
		Maximum = data.Maximum,
		Callback = data.Callback,
		Connections = {
			Loop = module.Utils.Loop:Connect({
				Time = 1,
				Callback = AmountSelector.Update
			})
		}
	}
	local visible = v.Maximum ~= nil
	slider.Visible = visible
	percentages.Visible = visible
	local start = data.Start or amount2 or data.Minimum or 1

	if v and start == start and math.abs(start) ~= 1e999 then
		local v3 = v
		local amount3 = math.floor(start)

		if v.Minimum then
			amount3 = math.max(v.Minimum, amount3)
		end

		if v.Maximum then
			amount3 = math.min(v.Maximum, amount3)
		end

		v3.Amount = amount3
		local progress = GetProgress(v.Amount) -- equivalent call inferred; original call site unknown
		value:set(progress)
		AmountSelector.Update()
	end

	spring:setPosition(scope.peek(value))
	module.Frame:Open(amountSelector)
end

function AmountSelector.Stop()
	if v then
		amount2 = v.Amount

		for _, connection in v.Connections do
			connection:Disconnect()
		end

		table.clear(v.Connections)
		v = nil
	end

	module.Frame:Close(amountSelector)
end

module.Button:Create(amount.Plus.Main, "Small"):BindFunction("Click", function()
	if not v then
		return
	end

	local v2 = v.Amount + 1

	if not v then
		return
	end

	if v2 == v2 then
		if math.abs(v2) == 1e999 then
			return
		end

		local v3 = v
		local amount3 = math.floor(v2)

		if v.Minimum then
			amount3 = math.max(v.Minimum, amount3)
		end

		if v.Maximum then
			amount3 = math.min(v.Maximum, amount3)
		end

		v3.Amount = amount3
		local progress = GetProgress(v.Amount) -- equivalent call inferred; original call site unknown
		value:set(progress)
		AmountSelector.Update()
	end
end)
module.Button:Create(amount.Minus.Main, "Small"):BindFunction("Click", function()
	if not v then
		return
	end

	local v2 = v.Amount - 1

	if not v then
		return
	end

	if v2 == v2 then
		if math.abs(v2) == 1e999 then
			return
		end

		local v3 = v
		local amount3 = math.floor(v2)

		if v.Minimum then
			amount3 = math.max(v.Minimum, amount3)
		end

		if v.Maximum then
			amount3 = math.min(v.Maximum, amount3)
		end

		v3.Amount = amount3
		local progress = GetProgress(v.Amount) -- equivalent call inferred; original call site unknown
		value:set(progress)
		AmountSelector.Update()
	end
end)

for childName, v2 in {
	P25 = 0.25,
	P50 = 0.5,
	P75 = 0.75,
	P100 = 1
} do
	local v3 = v2
	module.Button:Create(percentages:WaitForChild(childName):WaitForChild("Main"), "Small"):BindFunction(
		"Click",
		function()
			if not (v and v.Maximum) then
				return
			end

			local v4 = v.Maximum * v3

			if not v then
				return
			end

			if v4 == v4 then
				if math.abs(v4) == 1e999 then
					return
				end

				local v5 = v
				local amount3 = math.floor(v4)

				if v.Minimum then
					amount3 = math.max(v.Minimum, amount3)
				end

				if v.Maximum then
					amount3 = math.min(v.Maximum, amount3)
				end

				v5.Amount = amount3
				local progress = GetProgress(v.Amount) -- equivalent call inferred; original call site unknown
				value:set(progress)
				AmountSelector.Update()
			end
		end
	)
end

module.Button:Create(buttons.Cancel.Main, "Small"):BindFunction("Click", function()
	AmountSelector.Stop()
end)
module.Button:Create(buttons.Confirm.Main, "Small"):BindFunction("Click", function()
	if not v then
		return
	end

	v.Callback(v.Amount)
	AmountSelector.Stop()
end)
module.Slider:Create(slider, 4):BindFunction("Amount", function(p: number)
	if not (v and v.Maximum) then
		return
	end

	local minimum = v.Minimum or 0
	local v2 = minimum + math.floor((v.Maximum - minimum) * p + 0.5)

	if not v then
		return
	end

	if v2 == v2 then
		if math.abs(v2) == 1e999 then
			return
		end

		local v3 = v
		local amount3 = math.floor(v2)

		if v.Minimum then
			amount3 = math.max(v.Minimum, amount3)
		end

		if v.Maximum then
			amount3 = math.min(v.Maximum, amount3)
		end

		v3.Amount = amount3
		local progress = GetProgress(v.Amount) -- equivalent call inferred; original call site unknown
		value:set(progress)
		AmountSelector.Update()
	end
end)
scope:Observer(spring):onBind(function()
	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	slider2.Size = UDim2.fromScale(currentSpring, 1)
	point.Position = UDim2.fromScale(currentSpring, 0.5)
end)
amount.TextBox.FocusLost:Connect(function()
	if not v then
		return
	end

	local parseAmount = ParseAmount(amount.TextBox.Text)

	if parseAmount then
		if not v then
			return
		end

		if parseAmount == parseAmount then
			if math.abs(parseAmount) == 1e999 then
				return
			end

			local v3 = v
			local amount3 = math.floor(parseAmount)

			if v.Minimum then
				amount3 = math.max(v.Minimum, amount3)
			end

			if v.Maximum then
				amount3 = math.min(v.Maximum, amount3)
			end

			v3.Amount = amount3
			local progress = GetProgress(v.Amount) -- equivalent call inferred; original call site unknown
			value:set(progress)
			AmountSelector.Update()
		end
	else
		AmountSelector.Update()
	end
end)
module.Frame:OnFrameClosed(amountSelector, function()
	AmountSelector.Stop()
end)
return AmountSelector