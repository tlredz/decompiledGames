local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Common.Utils)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.ServerInfo)
local v4 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v5 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local v6 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local localPlayer = Players.LocalPlayer
local duelQuickPlay = localPlayer.PlayerGui:WaitForChild("DuelQuickPlay")
local players = duelQuickPlay.Party.Players
local modeSelect = duelQuickPlay.ModeSelect
local v7 = {
	["1v1"] = 1,
	["2v2"] = 2,
	["4v4"] = 4
}
local v8 = 0

for _, v9 in pairs(v7) do
	v8 = math.max(v8, v9)
end

return {
	Start = function(_)
		if not v3.isDuelLobbyServer() then
			return
		end

		duelQuickPlay.ModeSelect.Visible = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function toggleHotbarVisibility(flag: boolean)
			v5.HotBarHidden:SetTag("DuelQuickPlay", flag)
			v6.HideHotbar:SetTag("DuelQuickPlay", flag)
		end

		local function updateVisibility()
			local enabled = v4:GetKey("DuelQuickPlayEnabled") == true
			duelQuickPlay.Enabled = enabled
			toggleHotbarVisibility(enabled) -- equivalent call inferred; original call site unknown
		end

		v4.DataUpdatedEvent:Connect(updateVisibility)
		task.spawn(updateVisibility)
		players.Player1.PlayerImage.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=150&h=150`
		players.Invite.Activated:Connect(function()
			v2:Open("DuelParty")
		end)
		duelQuickPlay.Party.Play.Activated:Connect(function()
			modeSelect.Visible = not modeSelect.Visible

			if modeSelect.Visible and v2._currentGui then
				v2:CloseCurrent()
			end
		end)
		modeSelect.Close.Activated:Connect(function()
			modeSelect.Visible = false
		end)

		for _, guiObject in modeSelect.Types:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local name = guiObject.Name
			guiObject.Play.Activated:Connect(function()
				ReplicatedStorage2.Remotes.JoinQueue:FireServer("Duel", name, "Normal")
				modeSelect.Visible = false
			end)
		end

		local v9 = v.Client:WaitReplion("DuelParties")

		local function updateParty()
			local inDuelParty = localPlayer:GetAttribute("InDuelParty")
			local v10 = inDuelParty and inDuelParty == tostring(localPlayer.UserId)
			local parties = v9:Get("Parties")
			local v11 = inDuelParty and parties[inDuelParty] or parties[tostring(localPlayer.UserId)]

			if not v11 then
				v11 = {
					Members = 0
				}
				v11.Members = {
					[localPlayer.UserId] = 1
				}
			end

			local v12 = {}
			table.insert(v12, (tonumber(inDuelParty or localPlayer.UserId)))

			for k, _ in pairs(v11.Members) do
				local v13 = tonumber(k)

				if not table.find(v12, v13) then
					table.insert(v12, v13)
				end
			end

			table.sort(v12, function(a, b)
				return a == inDuelParty or a < b
			end)
			local visible = (v10 or not inDuelParty) and #v12 < v8
			local v14

			if visible then
				v14 = math.max(#v12, v8 - 1)
			else
				v14 = v8
			end

			for i = 1, v8 do
				local child = players:FindFirstChild((`Player{i}`))

				if not child then
					continue
				end

				child.Visible = i <= v14
				local v15 = v12[i]
				child.PlayerImage.Image = not v15 and "" or `rbxthumb://type=AvatarHeadShot&id={v15}&w=150&h=150`
			end

			for _, guiObject in modeSelect.Types:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local v15

				if v7[guiObject.Name] >= #v12 then
					v15 = v10 or not inDuelParty
				else
					v15 = false
				end

				guiObject.Play.Active = v15
				guiObject.Play.Selectable = v15
				guiObject.Play.ImageColor3 = v15 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(85, 85, 85)
			end

			players.Invite.Visible = visible
		end

		localPlayer:GetAttribute("InDuelParty")
		localPlayer:GetAttributeChangedSignal("InDuelParty"):Connect(updateParty)
		v9:OnChange("Parties", updateParty)
		updateParty()
	end
}