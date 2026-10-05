local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local parent = script.Parent
local currency = parent:WaitForChild("Currency")
local currencyMobile = parent:WaitForChild("CurrencyMobile")

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateVisibility()
	local visible = not GuiService:IsTenFootInterface() and UserInputService.TouchEnabled and not UserInputService.MouseEnabled
	currencyMobile.Visible = visible
	currency.Visible = not visible
end

UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(UpdateVisibility)
UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(UpdateVisibility)
UpdateVisibility() -- equivalent call inferred; original call site unknown