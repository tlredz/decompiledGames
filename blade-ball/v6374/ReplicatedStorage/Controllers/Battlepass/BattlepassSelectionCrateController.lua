local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Common.RewardInfo)
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.Battlepass.BattlepassSelectionCrate)
local v6 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local v7 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v8 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v9 = require3(ReplicatedStorage2.Shared.InfiniteBattlepass.InfiniteBattlepassData)
local v10 = require3(ReplicatedStorage2.ServerInfo)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
playerGui:WaitForChild("Battlepass")
local battlepassSelectionCrate = playerGui:WaitForChild("BattlepassSelectionCrate")
local remoteFunction = v3:RemoteFunction("ClaimSelectionCrateRewards")
local v11 = nil
local v12 = {
	Normal = "SelectionCrate",
	Premium = "PremiumSelectionCrate"
}
local BattlepassSelectionCrateController = {}
BattlepassSelectionCrateController._trove = v2.new()
BattlepassSelectionCrateController._currentPage = "Normal"
BattlepassSelectionCrateController._selection = {
	Normal = {},
	Premium = {}
}

function BattlepassSelectionCrateController:_select(p, p2)
	local battlepassSelectionCrate2 = v11:Get("BattlepassSelectionCrate")

	if not battlepassSelectionCrate2 then
		return
	end

	local v13 = self._selection[p]
	local index = table.find(v13, p2)
	local v14 = battlepassSelectionCrate2.TotalUnlocked[p] - #battlepassSelectionCrate2.Selected[p]

	if index then
		table.remove(v13, index)
	else
		table.insert(v13, p2)

		if v14 < #v13 then
			table.remove(v13, 1)
		end
	end

	self:_update()
end

function BattlepassSelectionCrateController:_openPage(currentPage)
	self._currentPage = currentPage
	self._trove:Clean()

	for _, list in self._selection do
		table.clear(list)
	end

	for _, guiObject in battlepassSelectionCrate:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject.Name == v12[currentPage]
		end
	end

	self:_update()
end

function BattlepassSelectionCrateController:_update()
	local battlepassSelectionCrate2 = v11:Get("BattlepassSelectionCrate")

	if not battlepassSelectionCrate2 then
		return
	end

	local child = battlepassSelectionCrate:FindFirstChild(v12[self._currentPage])

	if not child then
		return
	end

	local main = child.Main
	local v13 = { "Normal" }

	if self._currentPage == "Premium" then
		table.insert(v13, "Premium")
	end

	for _, childName in v13 do
		local child2 = main:FindFirstChild(childName)

		if not child2 then
			continue
		end

		for childName2, v14 in v5[childName] do
			if typeof(v14) == "function" then
				v14 = v14(Players.LocalPlayer)
			end

			local child3 = child2:FindFirstChild(childName2)

			if not child3 then
				continue
			end

			child3.Icon.Image = v14.Icon or ""
			child3.ItemName.Text = v14.DisplayName:gsub("Explosion Explosion", "Explosion"):gsub("Emote Emote", "Emote")
			child3.Inspect.Visible = v8:CanPreview(v14)

			if v7:CanShowRewardInfo(v14) then
				v7:AddFromRewardInfo(child3, v14)
			else
				v7:Remove(child3)
			end

			local visible = table.find(battlepassSelectionCrate2.Selected[childName], childName2) ~= nil
			child3.Collected.Visible = visible
			local v16 = table.find(self._selection[childName], childName2) ~= nil
			child3.Check.Visible = v16 and not visible
		end

		local count = #battlepassSelectionCrate2.Selected[childName]
		local count2 = #v5[childName]
		local child3 = child2:FindFirstChild(count2)

		if child3 then
			local locked = child3:FindFirstChild("Locked")
			locked.Visible = count < count2 - 1
		end

		local child4 = main:FindFirstChild(`SelectedLabel{childName}`, true)

		if not child4 then
			continue
		end

		local v14 = (battlepassSelectionCrate2.TotalUnlocked[childName] or 0) - count

		if v14 > 0 then
			child4.Text = string.format(
				"<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">Selected: <font color=\"rgb(0, 255, 58)\">%s</font>/%s</stroke>",
				tostring(#self._selection[childName]),
				(tostring(v14))
			)
		else
			child4.Text = "<stroke color=\"rgb(0,0,0)\" joins=\"round\" thickness=\"2\">0 Selections Left</stroke>"
		end
	end
end

function BattlepassSelectionCrateController:Start()
	local v13 = false

	for _, child in battlepassSelectionCrate:GetChildren() do
		local main = child:FindFirstChild("Main")

		if not main then
			continue
		end

		main.Close.Activated:Connect(function()
			v4:Close("BattlepassSelectionCrate")

			if not v13 then
				v6:OpenView("Battlepass")
			end

			v13 = false
		end)
		local v14 = { "Normal" }

		if (child.Name:find("Premium") and "Premium" or "Normal") == "Premium" then
			table.insert(v14, "Premium")
		end

		for _, childName in v14 do
			local child2 = main:FindFirstChild(childName)

			if not child2 then
				continue
			end

			for childName2, _ in v5[childName] do
				local child3 = child2:FindFirstChild(childName2)

				if not child3 then
					continue
				end

				local v15 = child3
				local v16 = childName
				local v17 = childName2
				child3.Select.Activated:Connect(function()
					local collected = v15:FindFirstChild("Collected")
					local locked = v15:FindFirstChild("Locked")

					if collected and collected.Visible or locked and locked.Visible then
						return
					end

					self:_select(v16, v17)
				end)
				local v18 = childName
				local v19 = childName2
				child3.Inspect.Activated:Connect(function()
					local v20 = v5[v18][v19]

					if typeof(v20) == "function" then
						v20 = v20(Players.LocalPlayer)
					end

					if not v8:CanPreview(v20) then
						return
					end

					v4:Close(battlepassSelectionCrate.Name)
					v8:PreviewReward(v20, battlepassSelectionCrate.Name)
				end)
			end
		end

		child.Main.Collect.Activated:Connect(function()
			for k, v16 in v14 do
				if #self._selection[v16] <= 0 then
					continue
				end

				local v17 = v16
				task.defer(function()
					local v18, v19 = remoteFunction:InvokeServer(v17, self._selection[v17])

					if v18 then
						ReplicatedStorage2.Misc.BattlepassReward:Play()
					else
						ReplicatedStorage2.Misc.error:Play()
					end

					if _G.SendNotification and v19 then
						_G.SendNotification(v19, nil, true)
					end
				end)
			end
		end)
	end

	v11 = v.Client:WaitReplion("Data")

	local function updatePremium()
		self:_openPage(v11:Get("InfiniteBattlepass.Premium") and "Premium" or "Normal")
	end

	v4:OnGuiOpen("BattlepassSelectionCrate", updatePremium)
	v11:OnChange("InfiniteBattlepass.Premium", updatePremium)
	task.spawn(updatePremium)

	if v10.isRhythmServer() then
		return
	end

	local lastTime = os.clock()

	local function update()
		if not v9.isEnabled() then
			return
		end

		local battlepassSelectionCrate2 = v11:Get("BattlepassSelectionCrate")

		if not battlepassSelectionCrate2 then
			return
		end

		local total = 0
		local total2 = 0

		for k, v14 in battlepassSelectionCrate2.TotalUnlocked do
			total += math.min(v14, #v5[k])
			total2 += #battlepassSelectionCrate2.Selected[k]
		end

		if total - total2 > 0 then
			local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

			while character and character.Parent == workspace.Alive do
				task.wait(1)
			end

			while v4._currentGui and v4._currentGui ~= battlepassSelectionCrate do
				task.wait(1)
			end

			if os.clock() - lastTime < 30 then
				v13 = true
			end

			v4:Open("BattlepassSelectionCrate")
		end

		self:_update()
	end

	client:OnChange("Ability", update)
	v11:OnChange("BattlepassSelectionCrate.TotalUnlocked", update)
	v11:OnChange("BattlepassSelectionCrate.Selected", update)
	v11:OnDescendantChange("BattlepassSelectionCrate", update)
	task.spawn(update)
end

return BattlepassSelectionCrateController