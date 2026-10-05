local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local vide = require(packages.vide)
local ABTests = require(ReplicatedStorage.UserGenerated.ABTests)
local shopUI = ReplicatedStorage:WaitForChild("UI"):WaitForChild("ShopUI")
local App = require(shopUI.App)
local Layout = require(shopUI.Layout)
local Prices = require(shopUI.Prices)
local root = vide.root
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local toggleGiftSignal = Signal.new()
local remoteEvent = Net:RemoteEvent("ShopController/ToggleLayout")
local giftPlayer = playerGui:WaitForChild("GiftPlayer"):WaitForChild("GiftPlayer")
local v2 = nil
local v3 = nil
local v4 = {}
local ShopController = {
	GiftFrame = giftPlayer,
	ToggleGiftSignal = toggleGiftSignal
}

local function selectArm()
	if not ABTests.IsLoaded() then
		local v5 = os.clock() + 10

		while not ABTests.IsLoaded() and os.clock() < v5 do
			task.wait()
		end

		if not ABTests.IsLoaded() then
			warn((`ShopController: AB tests did not load within {10}s, serving the legacy shop`))
		end
	end

	local attribute = ABTests.GetAttribute(localPlayer, "Shop.NewUI", false)

	if type(attribute) ~= "boolean" then
		attribute = false
	end

	if attribute then
		return Layout.New
	end

	return Layout.Legacy
end

local function mountArm(data)
	local child = playerGui:WaitForChild(data.GuiName, 10)

	if not (child and Layout.Resolve(child, data.Root) and Layout.Resolve(child, data.Close)) then
		warn((`ShopController: failed to mount {data.GuiName}`))
		return false
	end

	local v5 = v2
	local v6

	if v5 == nil then
		v6 = false
	else
		v6 = v5.Interface:IsOpened()
	end

	if v5 then
		v5.Destroy()
		v2 = nil
	end

	local v7

	if data == Layout.New then
		v7 = Layout.Legacy.GuiName
	else
		v7 = Layout.New.GuiName
	end

	local screenGui = playerGui:FindFirstChild(v7)

	if screenGui and screenGui:IsA("ScreenGui") then
		screenGui.Enabled = false
	end

	local v8 = App.Mount(data, toggleGiftSignal)

	if not v8 then
		warn((`ShopController: failed to mount {data.GuiName}`))
		return false
	end

	v2 = v8
	v3 = data

	if v6 then
		v8.Interface:Open()
	end

	return true
end

function ShopController:ToggleLayout()
	local v5

	if v3 == Layout.New then
		v5 = Layout.Legacy
	else
		v5 = Layout.New
	end

	return (mountArm(v5))
end

function ShopController.Start(_)
	mountArm(selectArm())
	remoteEvent.OnClientEvent:Connect(function()
		ShopController:ToggleLayout()
	end)
end

function ShopController.OpenGiftingScreen(_)
	if giftPlayer:IsA("GuiObject") then
		giftPlayer.Visible = true
	end
end

function ShopController.CloseGiftingScreen(_)
	if giftPlayer:IsA("GuiObject") then
		giftPlayer.Visible = false
	end
end

function ShopController.RemoveGiftingTarget(_)
	local v5 = v2

	if v5 then
		v5.State:SetGiftTarget(nil)
	end
end

function ShopController.GetGiftingTarget(_)
	local v5 = v2

	if v5 then
		return (v5.State.GiftTarget())
	end

	return nil
end

function ShopController:BindLabelToProductPrice(instance, p: number, p2: string?, p3: number?, flag: boolean?)
	self:UnbindLabelProductPrice(instance)
	v4[instance] = root(function()
		local text = Prices.Text(p, p2, p3, flag)
		vide.apply(instance)({
			Text = text
		})
	end)
	local destroyingConnection = nil
	destroyingConnection = instance.Destroying:Connect(function()
		destroyingConnection:Disconnect()
		ShopController:UnbindLabelProductPrice(instance)
	end)
end

function ShopController:UnbindLabelProductPrice(p)
	local v5 = v4[p]

	if v5 then
		v4[p] = nil
		v5()
	end
end

return ShopController