local main = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main")
local guiObjects = {}

for _, childName in {
	"Shop",
	"Products",
	"Rebirth",
	"Index",
	"EggTracker",
	"Gifting",
	"OldShop",
	"OfflineEarnings",
	"Settings",
	"Sell"
} do
	local guiObject = main:WaitForChild(childName, 10)

	if guiObject and guiObject:IsA("GuiObject") then
		table.insert(guiObjects, guiObject)
	end
end

local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function CloseOthers(p)
	if flag then
		return
	end

	flag = true

	for _, v in guiObjects do
		if v ~= p and v.Visible then
			v.Visible = false
		end
	end

	flag = false
end

for _, v in guiObjects do
	local v2 = v
	v:GetPropertyChangedSignal("Visible"):Connect(function()
		if v2.Visible then
			CloseOthers(v2) -- equivalent call inferred; original call site unknown
		end
	end)
end

local v = nil

for _, v2 in guiObjects do
	if v2.Visible then
		v = v2
	end
end

if v and not flag then
	flag = true

	for _, v2 in guiObjects do
		if v2 ~= v and v2.Visible then
			v2.Visible = false
		end
	end

	flag = false
end