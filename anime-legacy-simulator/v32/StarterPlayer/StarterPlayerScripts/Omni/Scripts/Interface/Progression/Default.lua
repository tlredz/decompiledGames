local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local State = require(script.Parent.State)
local color = Color3.new(1, 1, 1)
local progression = module.Interface:WaitForChild("Frames"):WaitForChild("Progression")
progression:WaitForChild("Header")
local close = progression:WaitForChild("Close")
local buttons = progression:WaitForChild("Buttons")
local info = progression:WaitForChild("Info")
local currency = progression:WaitForChild("Currency")
local chance = progression:WaitForChild("Chance")
local perks = progression:WaitForChild("Perks")
local main = buttons:WaitForChild("Upgrade"):WaitForChild("Main")
local main2 = buttons:WaitForChild("StartAutoUpgrade"):WaitForChild("Main")
local main3 = buttons:WaitForChild("StopAutoUpgrade"):WaitForChild("Main")
local perk = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Progression"):WaitForChild("Perk")
local text = nil
local v2 = {}
local v3 = {}
local v4 = nil
local Default = {}

local function Notify(message: string)
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = message,
		Color = Color3.new(1, 1, 0)
	})
end

local function CheckAttempt(flag: boolean)
	if not text then
		return false
	end

	local v5 = State.Get(text)

	if v5.Preview then
		if v5.Completed then
			Notify("You have reached the maximum level for this progression.")
		elseif v5.HasAccess then
			if v5.CanStart and (not flag or v5.Balance ~= nil) then
				if not flag or v5.CanUpgrade then
					return true
				end

				local v7

				if v5.PaymentReason == "InsufficientBalance" then
					v7 = `You need {string.format("%.0f", v5.Price.Amount)} {v5.Price.Name} for this attempt!`
				else
					v7 = module.Shared.MonetizationPolicy.GetPaymentMessage(v5.PaymentReason, v5.Policy)
				end

				Notify(v7)
			else
				Notify("The Progression balance is unavailable.")
			end
		else
			Notify("You don't have access to this progression.")
		end
	else
		Notify("Progression chances are unavailable. Please try again later!")
	end

	return false
end

local function ObserveCurrency(p)
	local name

	if p.PriceType == "Currency" then
		name = p.Price and p.Price.Name
	else
		name = false
	end

	if name == "Gems" then
		name = nil
	end

	if name == v4 then
		return
	end

	if v2.Currency then
		v2.Currency:Disconnect()
		v2.Currency = nil
	end

	v4 = name

	if name then
		v2.Currency = module:OnDataChanged({ name }, Default.Update)
	end
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = perk:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name .. ":"
		self.Instance.Main.Title.TextColor3 = self.Color
		self.Instance.Main.Value.TextColor3 = self.Color
		self.Instance.Main.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, self.Color)
		})
		self.Instance.Parent = perks
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

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

		return true
	end,
	Update = function(p, p2: number, p3: number)
		if p3 > 1 then
			p.Instance.Main.Value.Text = module.Utils.Number:Format(p3) .. "x"
		else
			p.Instance.Main.Value.Text = "+" .. module.Utils.Number:Format(p2)
		end
	end
})

local function UpdatePerks(items)
	local total = 0

	for k, item in items do
		local compileArray, v5 = module.Utils.Multipliers.CompileArray(item)
		local v6 = v3[k]

		if not v6 then
			local innerScope = scope:innerScope()
			innerScope.Name = k
			innerScope.Color = module.Utils.Multipliers.GetColorFromMultiplier(k)

			if innerScope:Build(total) then
				v3[k] = innerScope
				v6 = innerScope
			else
				innerScope:doCleanup()
			end

			total += 0.05
		end

		if v6 then
			v6:Update(compileArray, v5)
		end
	end

	for k, v5 in v3 do
		if items[k] then
			continue
		end

		v5.Instance:Destroy()
		v5:doCleanup()
		v3[k] = nil
	end
end

function Default.Update()
	if not text then
		return
	end

	local v5 = State.Get(text)
	local preview = v5.Preview
	local info2 = v5.Info
	local v6 = preview and module.Shared.Progression.GetLevelInformation(text, preview.CurrentLevel)
	local v7 = {}

	for k, v8 in v6 and v6.Perks or {} do
		v7[k] = { v8 }
	end

	ObserveCurrency(v5)
	UpdatePerks(v7)
	info.Title.Value.Text = text
	info.Slot.Main.Icon.Image = typeof(info2.Icon) ~= "string" and "" or info2.Icon
	info.Level.Value.Text = not preview and "Unavailable" or `Level: {preview.CurrentLevel}/{preview.MaxLevel}`
	local v8 = v5.PriceType and module.Utils.Info:Get(v5.PriceType, v5.Price.Name)
	currency.Icon.Image = v8 and v8.Icon or ""
	currency.Title.Text = v5.Balance == nil and "Unavailable" or module.Utils.Number:Format(v5.Balance)
	chance.Title.Text = "Success:"

	if v5.Completed then
		info.Price.Value.Text = "MAXED"
		chance.Value.Text = "MAXED"
	elseif preview then
		info.Price.Value.Text = `{string.format("%.0f", preview.Price.Amount)} {preview.Price.Name} / attempt (spent even on failure)`
		chance.Value.Text = module.Utils.Probability.FormatPercentage(preview.SuccessChance) or "Unavailable"
	else
		info.Price.Value.Text = "Unavailable"
		chance.Value.Text = "Unavailable"
	end

	main.Title.Text = preview and "Upgrade" or "Unavailable"
	buttons.Upgrade.Visible = not v5.Completed
	buttons.StartAutoUpgrade.Visible = not (v5.Completed or v5.Auto)
	buttons.StopAutoUpgrade.Visible = v5.Auto
end

function Default.Start(p: string)
	Default.Stop()
	text = p

	for _, v5 in { "Progression", "Items", "Maps" } do
		v2[v5] = module:OnDataChanged({ v5 }, Default.Update)
	end

	v2.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Identifier = "ProgressionPanelRefresh",
		Callback = Default.Update
	})
	module.Frame:Open(progression)
	Default.Update()
end

function Default.Stop()
	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
	v4 = nil

	for _, v5 in v3 do
		v5.Instance:Destroy()
		v5:doCleanup()
	end

	table.clear(v3)
	text = nil
end

module.Button:Create(main, "Default"):BindFunction("Click", function()
	if not CheckAttempt(true) then
		return
	end

	module.Signal:Fire("General", "Progression", "Upgrade", text)
end)
module.Button:Create(main2, "Default"):BindFunction("Click", function()
	local v5

	if text then
		local v6 = State.Get(text)

		if v6.Preview then
			if v6.Completed then
				Notify("You have reached the maximum level for this progression.")
				v5 = false
			elseif v6.HasAccess then
				if v6.CanStart then
					v5 = true
				else
					Notify("The Progression balance is unavailable.")
					v5 = false
				end
			else
				Notify("You don't have access to this progression.")
				v5 = false
			end
		else
			Notify("Progression chances are unavailable. Please try again later!")
			v5 = false
		end
	else
		v5 = false
	end

	if not v5 or State.Get(text).Auto then
		return
	end

	module.Signal:Fire("General", "Progression", "Auto", text)
end)
module.Button:Create(main3, "Default"):BindFunction("Click", function()
	if not (text and State.Get(text).Auto) then
		return
	end

	module.Signal:Fire("General", "Progression", "Auto", text)
end)

if not close:FindFirstChild("Main") then
	local button = close:FindFirstChild("Button")

	if button and button:IsA("GuiButton") then
		module.Button:Create(button, "Close"):BindFunction("Click", function()
			module.Frame:Close(progression)
		end)
	end
end

module.Frame:OnFrameClosed(progression, function()
	module.Signal:FireSelf("Interface", "Progression", "Stop")
end)
script.Destroying:Connect(Default.Stop)
return Default