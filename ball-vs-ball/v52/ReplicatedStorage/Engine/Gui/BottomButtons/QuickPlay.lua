local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Packages.Net)
local ButtonAnimator = require(script.Parent.ButtonAnimator)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local GameModeRegistry = require(ReplicatedStorage.Engine.Service.GameModeRegistry)
local ExperienceService = require(ReplicatedStorage.Engine.Service.ExperienceService)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonActions = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local LobbyShortcuts = require(ReplicatedStorage.Engine.Service.GamepadSupport.LobbyShortcuts)
local PartyStrip = require(script.Parent.PartyStrip)
local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)
local ServerTypeService = require(ReplicatedStorage.Engine.Service.ServerTypeService)
local flag = false
return {
	Init = function()
		if flag then
			return
		end

		flag = true
		local localPlayer = Players.LocalPlayer
		local v = localPlayer:WaitForChild("PlayerGui"):WaitForChild("下方按钮区"):WaitForChild("区域"):WaitForChild("下方区域")
		local v2 = v:WaitForChild("快速游戏按钮")
		local v3 = v:WaitForChild("切换模式按钮")
		local textLabel = v3:WaitForChild("TextLabel")
		task.spawn(function()
			local serverType = ServerTeleport.getServerType()

			if serverType == ServerTypeService.TWO_V_TWO_POOL_NAME then
				textLabel.Text = "1V1"
			elseif serverType == "standard" then
				textLabel.Text = "2V2"
			end
		end)
		GamepadSupport.WatchRoot(v3)
		GamepadSupport.WatchRoot(v2)
		local v4 = ButtonAnimator.new(v2, v2)
		local v5 = ButtonAnimator.new(v3, v3)
		local v6 = PartyStrip.new(v)
		local v7 = {}
		local v8 = false
		local count = 0
		local v9 = nil
		local healthChangedConnection = nil
		local count2 = 0

		local function hasAvailableSeat(data, p)
			local table = data.table

			if not table or not table:IsDescendantOf(workspace) or data.state ~= "Waiting" then
				return false
			end

			local v10 = GameModeRegistry.getForTable(table)

			if GameModeRegistry.isTeamMode(v10) ~= p then
				return false
			end

			for _, seat in v10.seats do
				local seatName = seat.seatName
				local v11 = data.seats and data.seats[seatName]
				local child = table:FindFirstChild(seatName)
				local part = child and child:FindFirstChild("站立点")

				if (not v11 or v11.userId == nil) and part and part:IsA("BasePart") then
					return true
				end
			end

			return false
		end

		local function sync()
			local inDuelTable = localPlayer:GetAttribute("InDuelTable") == true
			local v10 = false
			local v11 = false

			for _, v13 in v7 do
				v10 = hasAvailableSeat(v13, false) and true or v10
				v11 = hasAvailableSeat(v13, true) and true or v11

				if v10 and v11 then
					break
				end
			end

			local featureUnlocked = ExperienceService.isFeatureUnlocked(client.exp.total(), "2v2模式")
			local v13 = v11 and featureUnlocked
			local v14

			if v9 == nil or not (v9.Health > 0) then
				v14 = false
			else
				v14 = not inDuelTable and (v10 or v13)
			end

			v4:SetEnabled(v14 and not v8)
			v4:SetVisible(v14)
			v6:SetVisible(v14 and featureUnlocked)
			v6:SetEnabled(v14 and featureUnlocked and not v8)
			local v15 = v14 and featureUnlocked
			v5:SetEnabled(v15 and not v8)
			v5:SetVisible(v15)
		end

		local function trackCharacter(instance)
			count2 += 1
			local v10 = count2

			if healthChangedConnection then
				healthChangedConnection:Disconnect()
				healthChangedConnection = nil
			end

			v9 = nil
			sync()
			local humanoid = instance:WaitForChild("Humanoid", 10)

			if v10 ~= count2 or localPlayer.Character ~= instance then
				return
			end

			if humanoid and humanoid:IsA("Humanoid") then
				v9 = humanoid
				healthChangedConnection = humanoid.HealthChanged:Connect(sync)
			end

			sync()
		end

		localPlayer.CharacterAdded:Connect(trackCharacter)
		localPlayer.CharacterRemoving:Connect(function()
			count2 += 1
			v9 = nil

			if healthChangedConnection then
				healthChangedConnection:Disconnect()
				healthChangedConnection = nil
			end

			sync()
		end)
		localPlayer:GetAttributeChangedSignal("InDuelTable"):Connect(sync)
		client.exp.total.Changed(sync)
		Net:RemoteEvent("DuelTableState").OnClientEvent:Connect(function(p)
			if type(p) ~= "table" then
				return
			end

			if type(p.tables) == "table" then
				v7 = {}

				for _, table in p.tables do
					if not (type(table) == "table" and typeof(table.table) == "Instance") then
						continue
					end

					v7[table.table] = table
				end
			elseif typeof(p.table) == "Instance" then
				v7[p.table] = p
			end

			sync()
		end)
		Net:RemoteEvent("DuelQuickPlayResult").OnClientEvent:Connect(function()
			v8 = false
			count += 1
			sync()
		end)

		local function activateQuickPlay()
			if v8 or not GamepadSupport.CanActivate(v2) then
				return
			end

			v8 = true
			count += 1
			local v10 = count
			sync()
			Net:RemoteEvent("DuelQuickPlayRequest"):FireServer()
			task.delay(8, function()
				if count ~= v10 then
					return
				end

				v8 = false
				sync()
				Net:RemoteEvent("DuelTableStateRequest"):FireServer()
			end)
		end

		ButtonActions.Bind(v2, activateQuickPlay)
		GamepadPages.Open(v2, {
			base = true,
			available = function()
				return LobbyShortcuts.IsAvailable(v)
			end
		})
		workspace.DescendantRemoving:Connect(function(descendant)
			if v7[descendant] then
				v7[descendant] = nil
				sync()
			end
		end)

		if localPlayer.Character then
			task.spawn(trackCharacter, localPlayer.Character)
		end

		Net:RemoteEvent("DuelTableStateRequest"):FireServer()
		sync()
	end
}