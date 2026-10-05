local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local AdFeatures = require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "ThemesMenu"
})
local v2 = Signal.new()
local flag = false
local v3 = false

local function initializeSharedHandlers()
	if flag then
		return
	end

	flag = true
	local localPlayer = Players.LocalPlayer
	local themeRemote = LegacyGame8Settings.ThemeRemote
	local localThemes = Workspace:WaitForChild("WorkspaceCom"):WaitForChild("LocalThemes")
	local houseSpinner = localPlayer.PlayerGui:WaitForChild("MainGUIHandler"):WaitForChild("HouseSpinner")
	local loadingBool = localPlayer.PlayerGui:WaitForChild("Player8Handler"):WaitForChild("LoadingBool")
	local spinner = houseSpinner:WaitForChild("Spinner")

	local function LoadingGui()
		while loadingBool.Value ~= false do
			wait(0.05)
			spinner.Rotation += 30
		end
	end

	local function trackCharacter(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			humanoid = character:WaitForChild("Humanoid", 5)
		end

		if humanoid == nil then
			return
		end

		humanoid.Died:Connect(function()
			v3 = true
		end)
	end

	if localPlayer.Character ~= nil then
		v3 = false
		task.spawn(trackCharacter, localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(function(character)
		v3 = false
		trackCharacter(character)
	end)
	themeRemote.OnClientEvent:Connect(function(p, p2)
		if p == "ThemeReady" then
			if game.ReplicatedStorage.TempThemes:FindFirstChild(localPlayer.Name) ~= nil and not game.Workspace.WorkspaceCom.LocalThemes:FindFirstChild(localPlayer.Name) then
				local child = game.ReplicatedStorage.TempThemes:FindFirstChild(localPlayer.Name)
				local model = Instance.new("Model", localThemes)
				model.Name = localPlayer.Name

				if loadingBool.Value == false then
					loadingBool.Value = true
					houseSpinner.Visible = true
					task.spawn(LoadingGui)
				end

				for _, child2 in child:GetChildren(), nil, nil do
					local clone = child2:Clone()
					clone.Parent = model

					if not v3 then
						wait(0.2)
					end
				end

				loadingBool.Value = false
				houseSpinner.Visible = false
				themeRemote:FireServer("DeleteThemeR")
				wait(1)
				v2:Fire("ThemeReady", p2)
			end
		elseif p == "ServerThemeReady" then
			if localThemes:FindFirstChild(localPlayer.Name) then
				localThemes:FindFirstChild(localPlayer.Name):Destroy()
				themeRemote:FireServer("ThemeRemoved")
				v2:Fire("ThemeRemoved")
			end

			local server = game.ReplicatedStorage.TempThemes:FindFirstChild("Server")
			local model = Instance.new("Model", localThemes)
			model.Name = localPlayer.Name
			model:SetAttribute("IsServerTheme", true)

			if loadingBool.Value == false then
				loadingBool.Value = true
				houseSpinner.Visible = true
				task.spawn(LoadingGui)
			end

			local v4 = false

			for _, child in server:GetChildren(), nil, nil do
				v4 = server.Parent ~= game.ReplicatedStorage.TempThemes or (not model or model.Parent ~= localThemes)

				if v4 then
					continue
				end

				child.Parent = model

				if not v3 then
					task.wait(0.2)
				end
			end

			if v4 then
				Debris:AddItem(model, 0)
				return
			end

			loadingBool.Value = false
			houseSpinner.Visible = false
			task.wait(1)
			v2:Fire("ServerThemeReady", p2)
		elseif p == "DeleteServerTheme" then
			local child = localThemes:FindFirstChild(localPlayer.Name)

			if child and child:GetAttribute("IsServerTheme") then
				child:Destroy()
				loadingBool.Value = false
				houseSpinner.Visible = false
				v2:Fire("DeleteServerTheme")
			end
		end
	end)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	initializeSharedHandlers()
	local instance = self.Instance
	local localThemes = Workspace:WaitForChild("WorkspaceCom"):WaitForChild("LocalThemes")
	local localPlayer = Players.LocalPlayer
	local themeRemote = LegacyGame8Settings.ThemeRemote

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hideAllGreenCheckMarks()
		for _, descendant in instance:GetDescendants(), nil, nil do
			if descendant.Name == "GreenCheckMark" then
				descendant.Visible = false
			end
		end
	end

	local function showGreenCheckMarkFor(p2: string?)
		if p2 == nil then
			return
		end

		for _, child in instance:GetChildren(), nil, nil do
			if not (child:isA("ImageButton") and child.Name == p2 and child:FindFirstChild("GreenCheckMark") ~= nil) then
				continue
			end

			child.GreenCheckMark.Visible = true
		end
	end

	local v4 = false
	self._Janitor:Add(instance.Delete.MouseButton1Click:connect(function()
		if v4 == false and localThemes:FindFirstChild(localPlayer.Name) ~= nil then
			v4 = true
			task.delay(1, function()
				v4 = false
			end)
			localThemes:FindFirstChild(localPlayer.Name):Destroy()
			themeRemote:FireServer("ThemeRemoved")
			v2:Fire("ThemeRemoved")
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function requestTheme(p2)
		themeRemote:FireServer(
			GameUtil.IsPrivateServerOwner(localPlayer) and "AskForServerSidedThemeChange" or "AskForThemePass",
			p2
		)
	end

	local v5 = false

	for _, child in instance:GetChildren() do
		if not child:isA("ImageButton") then
			continue
		end

		local v6 = child
		self._Janitor:Add(child.MouseButton1Click:Connect(function()
			local name = v6.Name

			if v5 == false then
				v5 = true

				if name == "Delete" or name == "Open" or not v6:FindFirstChild("ThemePass") or localThemes:FindFirstChild(localPlayer.Name) then
					if name == "Delete" or name == "Open" or localThemes:FindFirstChild(localPlayer.Name) then
						if name ~= "Delete" and name ~= "Open" and localThemes:FindFirstChild(localPlayer.Name) then
							NotificationController.Notify("Select trash bin.")
						end
					else
						themeRemote:FireServer(
							GameUtil.IsPrivateServerOwner(localPlayer) and "AskForServerSidedThemeChange" or "AskForTheme",
							name
						)
					end
				elseif UnlockableController.IsFeatureUnlocked("ThemePass" .. v6.Name, Gamepasses.THEME_PASS) then
					requestTheme(name) -- equivalent call inferred; original call site unknown
				else
					GamepassController.Show(
						Gamepasses.THEME_PASS,
						v6.Icon.Image,
						"theme",
						nil,
						AdFeatures.Themes()["ThemePass" .. v6.Name],
						nil,
						"Themes Inventory",
						v6.Name,
						function()
							if v6.Parent ~= nil and self.Instance.Visible and not localThemes:FindFirstChild(localPlayer.Name) then
								requestTheme(name) -- equivalent call inferred; original call site unknown
							end
						end
					)
				end

				wait(0.5)
				v5 = false
			end
		end))
	end

	self._Janitor:Add(v2:Connect(function(p2: string, p3: string?)
		if p2 == "ThemeReady" then
			instance.Delete.Visible = false
			showGreenCheckMarkFor(p3)
			instance.Delete.Visible = true
		elseif p2 == "ServerThemeReady" then
			hideAllGreenCheckMarks() -- equivalent call inferred; original call site unknown
			instance.Delete.Visible = false
			showGreenCheckMarkFor(p3)
			instance.Delete.Visible = true
		elseif p2 == "DeleteServerTheme" then
			hideAllGreenCheckMarks() -- equivalent call inferred; original call site unknown
			instance.Delete.Visible = true
		elseif p2 == "ThemeRemoved" then
			hideAllGreenCheckMarks() -- equivalent call inferred; original call site unknown
			instance.Delete.Visible = false
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v