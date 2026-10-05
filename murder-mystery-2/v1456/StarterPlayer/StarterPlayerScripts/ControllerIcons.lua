local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local v = {
	ButtonA = true,
	ButtonB = true,
	ButtonX = true,
	ButtonY = true,
	ButtonL1 = true,
	ButtonL2 = true,
	ButtonR1 = true,
	ButtonR2 = true,
	ButtonSelect = true
}
local v2 = {
	ButtonA = "http://www.roblox.com/asset/?id=15026911220",
	ButtonCross = "http://www.roblox.com/asset/?id=15026902225",
	ButtonB = "http://www.roblox.com/asset/?id=15026912025",
	ButtonCircle = "http://www.roblox.com/asset/?id=15026903433",
	ButtonX = "http://www.roblox.com/asset/?id=15026867363",
	ButtonSquare = "http://www.roblox.com/asset/?id=15026893733",
	ButtonY = "http://www.roblox.com/asset/?id=15026912593",
	ButtonTriangle = "http://www.roblox.com/asset/?id=15026902848",
	ButtonLB = "http://www.roblox.com/asset/?id=15027131598",
	ButtonL1 = "http://www.roblox.com/asset/?id=15027138014",
	ButtonLT = "http://www.roblox.com/asset/?id=15027130434",
	ButtonL2 = "http://www.roblox.com/asset/?id=15027139880",
	ButtonRB = "http://www.roblox.com/asset/?id=15027131051",
	ButtonR1 = "http://www.roblox.com/asset/?id=15027138772",
	ButtonRT = "http://www.roblox.com/asset/?id=15027129964",
	ButtonR2 = "http://www.roblox.com/asset/?id=15027140259",
	ButtonSelect = "http://www.roblox.com/asset/?id=285737050",
	ButtonShare = "http://www.roblox.com/asset/?id=15027162581",
	ButtonTouchpad = "http://www.roblox.com/asset/?id=15027162581"
}

function _G.GetButtonIcon(p)
	return v2[UserInputService:GetStringForKeyCode(p)]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onButtonIconAdded(p: string, p2)
	p2.Image = v2[UserInputService:GetStringForKeyCode(p)]
end

local function onInitialize()
	for k, _ in v do
		local v3 = "ButtonIcon_" .. k

		for _, v4 in CollectionService:GetTagged(v3) do
			onButtonIconAdded(k, v4) -- equivalent call inferred; original call site unknown
		end

		local v4 = k
		CollectionService:GetInstanceAddedSignal(v3):Connect(function(p)
			onButtonIconAdded(v4, p) -- equivalent call inferred; original call site unknown
		end)
	end
end

repeat
	task.wait()
until game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainGUI")

onInitialize()