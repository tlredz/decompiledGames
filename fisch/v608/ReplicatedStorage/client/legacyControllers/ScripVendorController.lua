local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local legacyControllers = ReplicatedStorage.client.legacyControllers
local utils = ReplicatedStorage.shared.utils
local modules = ReplicatedStorage.shared.modules
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local HudController = require(legacyControllers.HudController)
local NumberUtils = require(utils.NumberUtils)
local Worlds = require(modules.Worlds)
local LocalCurrencies = require(modules.LocalCurrencies)
local remoteFunction = Net:RemoteFunction("ScripVendor/Exchange")
local remoteEvent = Net:RemoteEvent("ScripVendor/Load")
local scripVendor = HudController:GetSafeZone().ScripVendor
local container = scripVendor.Container
local textBox = container.Amount.TextBox
local purchaseLabel = container.PurchaseLabel
local button = container.Button
local v = 100000
local maid = Trove.new()
local ScripVendorController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getCoinTag()
	return Worlds.Currencies.Coins.Display or "C$"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getScripTag()
	return LocalCurrencies["Shady Scrip"].DisplayName or "S$"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCoinColor()
	return Worlds.Currencies.Coins.LabelProperties.TextColor3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getScripColor()
	return LocalCurrencies["Shady Scrip"].Color
end

local function snapToRate(p: number)
	return (math.max(0, math.floor(p / 100000) * 100000))
end

local function parseInput(text: string)
	local v2 = string.gsub(text, ",", "")
	local v3 = string.gsub(v2, "%s+", "")
	local v4 = string.match(v3, "^([%d%.]+)")

	if not v4 then
		return 0
	end

	local v5 = tonumber(v4) or 0
	local v6 = string.lower((string.sub(v3, #v4 + 1)))
	local v7 = {
		k = 1000,
		m = 1000000,
		b = 1000000000,
		t = 1000000000000
	}
	local v8 = string.sub(v6, 1, 1)

	if v7[v8] then
		v5 *= v7[v8]
		v6 = string.sub(v6, 2)
	end

	if v6 == "s$" then
		return (math.floor(v5 * 100000))
	end

	return (math.floor(v5))
end

local function sanitizeText(value: string)
	local v2 = string.match(value, "^([%d,]+)") or ""
	local v3 = string.gsub(v2, ",", "")

	if v3 == "" then
		return ""
	end

	local v4 = string.sub(value, #v2 + 1)
	local v5 = string.gsub(v4, "%s+", "")
	local v6 = string.lower(v5)
	local v7

	if v6:sub(1, 2) == "c$" then
		v7 = " C$"
	elseif v6:sub(1, 2) == "s$" then
		v7 = " S$"
	elseif v6:sub(1, 1) == "c" then
		v7 = " C"
	elseif v6:sub(1, 1) == "s" then
		v7 = " S"
	else
		v7 = ""
	end

	return NumberUtils:Comma(tonumber(v3) or 0) .. v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatFinalText(p: number)
	textBox.Text = string.format("%s %s", NumberUtils:Comma(p), getCoinTag())
end

local function updatePurchaseLabel()
	purchaseLabel.RichText = true
	local v2 = math.floor(v / 100000)
	purchaseLabel.Text = string.format(
		"I'll exchange <font color=\"#%s\">%s %s</font> for <font color=\"#%s\">%s %s</font>",
		(getCoinColor()):ToHex(),
		NumberUtils:Comma(v),
		getCoinTag(),
		(getScripColor()):ToHex(),
		NumberUtils:Comma(v2),
		getScripTag()
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function commitFromTextBox()
	v = math.max(0, math.floor(parseInput(textBox.Text) / 100000) * 100000)

	if v <= 0 or v == 1e999 then
		v = 100000
	end

	formatFinalText(v) -- equivalent call inferred; original call site unknown
	updatePurchaseLabel()
end

function ScripVendorController:Open()
	maid:Clean()
	v = 100000
	formatFinalText(v) -- equivalent call inferred; original call site unknown
	updatePurchaseLabel()
	maid:Add(textBox.FocusLost:Connect(function()
		commitFromTextBox() -- equivalent call inferred; original call site unknown
	end))
	maid:Add(button.Activated:Connect(function()
		ScripVendorController:Exchange()
	end))
	scripVendor.Visible = true
end

function ScripVendorController:Close()
	maid:Clean()
end

function ScripVendorController:Exchange()
	local v2 = v

	if v2 <= 0 then
		return
	end

	task.spawn(function()
		local success, result = pcall(function()
			return remoteFunction:InvokeServer(v2)
		end)

		if success and result == true then
			formatFinalText(v) -- equivalent call inferred; original call site unknown
			updatePurchaseLabel()
		end
	end)
end

function ScripVendorController.Start(_)
	scripVendor.Visible = false
	remoteEvent.OnClientEvent:Connect(function()
		ScripVendorController:Open()
	end)
	scripVendor:GetPropertyChangedSignal("Visible"):Connect(function()
		if scripVendor.Visible then
			return
		end

		ScripVendorController:Close()
	end)
end

return ScripVendorController