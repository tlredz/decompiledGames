local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.CUI)
local SpectateActions = require(ReplicatedStorage.Cmdr.Menus.AdminMenu.SpectateActions)
require(ReplicatedStorage.Cmdr.Menus.AdminMenu.Types)
return {
	DisplayName = "Spectate",
	Permission = "cui.admin.spectate",
	Order = 20,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local localPlayer = Players.LocalPlayer
		local spectateFollow = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SpectateFollow")
		local v = nil
		local thread = nil
		local characterAddedConnection = nil

		local function onPlayerAdded() end

		local v2 = ""
		local v3 = SpectateActions.new()
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search players..."):SetValue(""):SetOnChangedRaw(function(value)
				v2 = string.lower(value)
				onPlayerAdded()
			end)
		end)
		local v4 = object:AddList(function(object2)
			object2:SetSizeY(210)
		end)

		local function StopSpectate()
			v = nil
			v3:SetTarget(nil)
			spectateFollow:FireServer(nil)

			if thread then
				task.cancel(thread)
				thread = nil
			end

			if characterAddedConnection then
				characterAddedConnection:Disconnect()
				characterAddedConnection = nil
			end

			local currentCamera = Workspace.CurrentCamera
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if currentCamera and humanoid then
				currentCamera.CameraSubject = humanoid
			end
		end

		local function Spectate(player)
			v = player
			v3:SetTarget(player)
			spectateFollow:FireServer(player.UserId)

			if thread then
				task.cancel(thread)
				thread = nil
			end

			if characterAddedConnection then
				characterAddedConnection:Disconnect()
				characterAddedConnection = nil
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function AttachCamera()
				if thread then
					task.cancel(thread)
				end

				thread = task.spawn(function()
					while v == player and player.Parent == Players do
						local character = player.Character
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")
						local currentCamera = Workspace.CurrentCamera

						if humanoid and currentCamera then
							currentCamera.CameraSubject = humanoid
							thread = nil
							break
						else
							task.wait(0.1)
						end
					end
				end)
			end

			characterAddedConnection = player.CharacterAdded:Connect(function()
				if v == player then
					AttachCamera() -- equivalent call inferred; original call site unknown
				end
			end)

			if thread then
				task.cancel(thread)
			end

			thread = task.spawn(function()
				while v == player and player.Parent == Players do
					local character = player.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					local currentCamera = Workspace.CurrentCamera

					if humanoid and currentCamera then
						currentCamera.CameraSubject = humanoid
						thread = nil
						break
					else
						task.wait(0.1)
					end
				end
			end)
		end

		onPlayerAdded = function()
			for _, v5 in v4.Components:GetAll() do
				v5:Destroy()
			end

			local players = Players:GetPlayers()
			table.sort(players, function(a, b)
				return string.lower(a.Name) < string.lower(b.Name)
			end)

			for _, player in players do
				local v5 = string.lower((`{player.Name}_{player.UserId}`))

				if not (v2 == "" or string.find(v5, v2, 1, true)) then
					continue
				end

				local v6 = player
				v4.Components:AddButton(function(object2)
					object2:SetButtonText((`{v6.Name}_{v6.UserId}`)):SetYSize(22):SetEnabledPermission("cui.admin.spectate"):SetButtonCallback(function()
						Spectate(v6)
					end)
				end)
			end
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Refresh players"):SetYSize(22):SetEnabledPermission("cui.admin.spectate"):SetButtonCallback(onPlayerAdded)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Stop spectate"):SetYSize(22):SetEnabledPermission("cui.admin.spectate"):SetButtonCallback(StopSpectate)
			end)
		end)
		local playerAddedConnection = Players.PlayerAdded:Connect(onPlayerAdded)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
			if v == player then
				StopSpectate()
			end

			task.defer(onPlayerAdded)
		end)
		v4:GetUI().Destroying:Connect(function()
			playerAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
			StopSpectate()
			v3:Destroy()
		end)
		onPlayerAdded()
	end
}