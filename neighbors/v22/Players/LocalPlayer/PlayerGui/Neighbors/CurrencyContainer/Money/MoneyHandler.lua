local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local UI = require(game.ReplicatedStorage.Modules.UI)
local Money = require(game.ReplicatedStorage.Modules.Money)
local Tip = require(game.ReplicatedStorage.Modules.Tip)
local label = script.Parent.Label
local add = script.Parent.Add

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	label.Text = `${Money(localPlayer:GetAttribute("Credits") or 0, true)}`
end

local function shouldBeVisible()
	return not playerGui:FindFirstChild("Graffiti")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisibility()
	script.Parent.Visible = not playerGui:FindFirstChild("Graffiti")
end

add.Button.MouseButton1Click:connect(function()
	local shop = localPlayer.PlayerGui.Neighbors.Shop
	shop.Visible = true
	shop.Pages.SetPage:Fire(shop.Pages.Robux)
	shop.Pages.Robux.CanvasPosition = Vector2.new(0, 0)
end)
UI:Bind(add.Button)
UI:AddShadowOnHover(add)

if UserInputService.TouchEnabled then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAddVisibility()
		local v = localPlayer:GetAttribute("State") == 1
		add.Visible = v
		script.Parent.UIPadding.PaddingRight = UDim.new(0, v and 3 or 7)
		script.Parent.Active = v
	end

	updateAddVisibility() -- equivalent call inferred; original call site unknown
	localPlayer:GetAttributeChangedSignal("State"):Connect(updateAddVisibility)
else
	Tip:connect(script.Parent.Label, function()
		return {
			Title = "Credits",
			Description = `You earn {localPlayer:GetAttribute("Verified") and 2 or 1} credit(s) every minute!`
		}
	end)
	script.Parent.Active = true
end

UI:RegisterConstantUIScale(script.Parent.UIScale, {
	PC = 1,
	Mobile = 1.3,
	Tablet = 1.3
})
update() -- equivalent call inferred; original call site unknown
updateVisibility() -- equivalent call inferred; original call site unknown
playerGui.ChildAdded:Connect(updateVisibility)
playerGui.ChildRemoved:Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal("Credits"):Connect(update)
update() -- equivalent call inferred; original call site unknown