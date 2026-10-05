local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Utils = require(ReplicatedStorage.Common.Utils)
local Statable = require(ReplicatedStorage.Shared.Statable)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local GachaItemsData = require(ReplicatedStorage.Common.GachaItemsData)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
local client = Inventory.Client
local remoteEvent = Net:RemoteEvent("GachaUpdateBestAbilityPrize")
local BattlepassViewController = require(ReplicatedStorage.Controllers.Battlepass.BattlepassViewController)
local match = script.Parent.Name:match("_(.+)$")
local v = match:gsub("%s+", "")
local abilityIcon = Utils.Icons:GetAbilityIcon(match)
local gachaToken = GachaItemsData.GachaTokens[v]
local formatted = `{v}Upgrade`
local frame = script.Parent.Frame
frame.Label.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2.5">{match} <font color="rgb(255, 204, 34)">Level 2</font></stroke>`
frame.Title.Text = `{match} Ability Upgrade`
frame.Item1.Icon.Image = abilityIcon
frame.Item2.Icon.Image = (GachaItemsData.GachaTokens[v] or {}).UpgradeIcon or ""
frame.Lv1.Label.Text = `<stroke color="rgb(0, 0, 0)" joins="round" thickness="2.5">{match} <font color="rgb(42, 255, 0)">LV. 1</font></stroke>`
frame.Lv1.Vector.Image = abilityIcon
frame.Lv2.Label.Text = `<stroke color="rgb(0, 0, 0)" joins="round" thickness="2.5">{match} <font color="rgb(42, 255, 0)">LV. 2</font></stroke>`
local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(match)
frame.Lv2.Vector.Image = child:GetAttribute("Icon1") or abilityIcon
local v2 = Replion.Client:WaitReplion("Data")

local function updateOwned()
	local count = #client:FindItems("Ability", match)

	if count >= 1 then
		frame.Item1.Label.Text = `<stroke color="rgb(0, 0, 0)" thickness="2"><font color="#14ff00">{count}</font>/{1}</stroke>`
	else
		frame.Item1.Label.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2.5">{count}/{1}</stroke>`
	end

	frame.Item1.Check.Visible = count >= 1
	return nil
end

client:OnChange("Ability", updateOwned)
task.spawn(updateOwned)
Statable.Computed(function(callback)
	local v3 = callback((Statable.getReplionPathState(v2, { "BattlepassGacha", "AbilitiesToken", gachaToken.ItemName }))) and 1 or 0

	if v3 >= 1 then
		frame.Item2.Label.Text = `<stroke color="rgb(0, 0, 0)" thickness="2"><font color="#14ff00">{v3}</font>/{1}</stroke>`
	else
		frame.Item2.Label.Text = `<stroke color="rgb(0,0,0)" joins="round" thickness="2.5">{v3}/{1}</stroke>`
	end

	frame.Item2.Check.Visible = v3 >= 1
	return nil
end)
local flag = false
frame.Upgrade.Activated:Connect(function()
	if flag or v2:Get({ "BattlepassGacha", "AbilitiesToken", v }) then
		return
	end

	flag = true
	Utils.Network:Invoke("ClaimUpgrade", v)
	task.delay(1, function()
		flag = false
	end)
end)
frame.Go.Activated:Connect(function()
	remoteEvent:FireServer(v)
	BattlepassViewController:OpenView("SpinGacha")
	BattlepassViewController:Open()
end)
frame.Close.Activated:Connect(function()
	GuiHandler:Close(script.Parent.Name)
end)

local function OnTokenReceived(flag2: boolean?)
	frame.LockedFrame.Visible = flag2 and true or false
end

v2:OnChange(formatted, OnTokenReceived)
local visible = v2:Get(formatted) and true or false
frame.LockedFrame.Visible = visible