local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local game8Settings = script.Parent:WaitForChild("Game8Settings")
local module = require(game8Settings)
local _ = module.Maxy
local cemeteryRemote = module.CemeteryRemote
local clearTools = module.ClearTools
local mainGUIHandler = playerGui:WaitForChild("MainGUIHandler")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local RequirementBehaviors = require(ReplicatedStorage.Modules.Shared.RequirementBehaviors)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LoadableEntries = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntries)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local noResetGUIHandler = playerGui:WaitForChild("NoResetGUIHandler")
local gunAssaultMenu = noResetGUIHandler:WaitForChild("GunAssaultMenu")
local gunGlockMenu = noResetGUIHandler:WaitForChild("GunGlockMenu")
local gunGlockBrownMenu = noResetGUIHandler:WaitForChild("GunGlockBrownMenu")
local gunShotGunMenu = noResetGUIHandler:WaitForChild("GunShotGunMenu")
local gunSniperMenu = noResetGUIHandler:WaitForChild("GunSniperMenu")
local menu = mainGUIHandler:WaitForChild("Menu")
noResetGUIHandler:WaitForChild("TempMailHouseNumber")
local commercialSigns = menu:WaitForChild("CommercialSigns")
local colorPicks = commercialSigns:WaitForChild("ColorPicks")
local commercialSign = script:WaitForChild("CommercialSign")
local cemeteryName = menu:WaitForChild("CemeteryName")
local codeName = menu:WaitForChild("CodeName")
local constructionName = menu:WaitForChild("ConstructionName")
local graveStoneName = menu:WaitForChild("GraveStoneName")
local bigSign2Name = menu:WaitForChild("BigSign2Name")
local bigSign3Name = menu:WaitForChild("BigSign3Name")
local bigSign4Name = menu:WaitForChild("BigSign4Name")
local powerPassword = menu:WaitForChild("PowerPassword")
local agencyPassword = menu:WaitForChild("AgencyPassword")
local finalColor = colorPicks.Picks:WaitForChild("FinalColor")
local finalColorWords = colorPicks.Picks:WaitForChild("FinalColorWords")
local darknessBar = colorPicks.Picks:WaitForChild("DarknessBar")
local palette = colorPicks.Picks:WaitForChild("Palette")
local uIGradient = colorPicks.Picks:WaitForChild("DarknessBar"):WaitForChild("UIGradient")
local hue = script:WaitForChild("Hue")
local hue2 = script:WaitForChild("Hue")
local saturation = script:WaitForChild("Saturation")
local value = script:WaitForChild("Value")
local color = Color3.new(0, 0, 0)
local v = false
local v2 = false
local v3 = false
local v4 = false
local v5 = false
local v6 = false
local v7 = false
local v8 = false
local v9 = false
local v10 = false
local v11 = false
local v12 = false
local v13 = false
local v14 = false
local v15 = false
local v16 = false
local v17 = false
local v18 = false
local v19 = false
local v20 = false
local v21 = false
local v22 = false
local v23 = false
local v24 = false

function ClientMessage(p: string)
	NotificationController.Notify(p)
end

function ClearCheckMarksGunAssault()
	for _, child in pairs(gunAssaultMenu.Catalog.Container.ScrollingFrame:GetChildren()) do
		if child:isA("ImageButton") then
			child.GreenCheckMark.Visible = false
		end
	end
end

local maid = Janitor.new()

local function setupGunAssaultButton(button)
	if button:IsA("ImageButton") then
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)
		local AssaultGuns = require(ReplicatedStorage.Modules.Client.UI.LoadableEntries.AssaultGuns)
		maid:Add(button.MouseButton1Click:connect(function()
			local name = button.Name

			if v15 == false and button ~= nil then
				v15 = true
				ClearCheckMarksGunAssault()

				if button.Name == "Skins" then
					if button.Name == "Skins" then
						PanelController.Close("NoResetGUIHandler", "GunAssaultMenu")
						PanelController.Open("NoResetGUIHandler", "GunSkinsMenu")
					end
				else
					local v25 = true

					for _, entry in AssaultGuns.Entries do
						if entry.Name ~= button.Name or not entry.RequirementBehaviorData or RequirementBehaviors.PassesRequirementCheck(
							localPlayer,
							entry.RequirementBehaviorData.Behavior,
							unpack(entry.RequirementBehaviorData.Arguments)
						) then
							continue
						end

						v25 = false
						local deniedMessage = RequirementBehaviors.GetDeniedMessage(
							localPlayer,
							entry.RequirementBehaviorData.Behavior,
							unpack(entry.RequirementBehaviorData.Arguments)
						)
						NotificationController.Notify(deniedMessage)
						v15 = false
						break
					end

					if not v25 then
						v15 = false
						return
					end

					clearTools:FireServer("RequestingAssault", name)

					if button.Name ~= "Silencer" and button.Name ~= "Flashlight" then
						button.GreenCheckMark.Visible = true
					end
				end

				wait(0.7)
				v15 = false
			end
		end))
	end
end

local component = ComponentUtil.GetComponentFromInstance(
	gunAssaultMenu.Catalog.Container.ScrollingFrame,
	LoadableEntries
)
component.Loaded:Connect(function()
	for _, child in gunAssaultMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		setupGunAssaultButton(child)
	end
end)

if component:IsLoaded() then
	for _, child in gunAssaultMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
		setupGunAssaultButton(child)
	end
end

component.Added:Connect(function(items)
	for _, item in items do
		setupGunAssaultButton(item)
	end
end)
component.Unloaded:Connect(function()
	maid:Cleanup()

	for _, child in gunAssaultMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
	end
end)
gunAssaultMenu.Catalog.Header.CategoryTabs.Close.MouseButton1Click:connect(function()
	if v16 == false then
		v16 = true
		PanelController.Close("NoResetGUIHandler", "GunAssaultMenu")
		wait(0.5)
		v16 = false
	end
end)

function ClearCheckMarksGunSkins()
	for _, child in pairs(noResetGUIHandler.GunSkinsMenu.Catalog.Container.Skins:GetChildren()) do
		if child:isA("ImageButton") then
			child.GreenCheckMark.Visible = false
		end
	end
end

noResetGUIHandler.GunSkinsMenu.Catalog.Header.CategoryTabs.BackButton.MouseButton1Click:connect(function()
	if v12 == false then
		v12 = true

		if noResetGUIHandler.GunUI.Value == "Assault" then
			PanelController.Open("NoResetGUIHandler", "GunAssaultMenu")
		elseif noResetGUIHandler.GunUI.Value == "Glock" then
			PanelController.Open("NoResetGUIHandler", "GunGlockMenu")
		elseif noResetGUIHandler.GunUI.Value == "GlockBrown" then
			PanelController.Open("NoResetGUIHandler", "GunGlockBrownMenu")
		elseif noResetGUIHandler.GunUI.Value == "Shotgun" then
			PanelController.Open("NoResetGUIHandler", "GunShotGunMenu")
		elseif noResetGUIHandler.GunUI.Value == "Sniper" then
			PanelController.Open("NoResetGUIHandler", "GunSniperMenu")
		end

		PanelController.Close("NoResetGUIHandler", "GunSkinsMenu")
		ClearCheckMarksGunSkins()
		wait(0.5)
		v12 = false
	end
end)
noResetGUIHandler.GunSkinsMenu.Catalog.Header.CategoryTabs.Close.MouseButton1Click:connect(function()
	if v13 == false then
		v13 = true
		PanelController.Close("NoResetGUIHandler", "GunSkinsMenu")
		ClearCheckMarksGunSkins()
		wait(0.5)
		v13 = false
	end
end)
local maid2 = Janitor.new()

local function setupGunSkinsButton(button)
	if button:IsA("ImageButton") then
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)
		maid2:Add(button.MouseButton1Click:Connect(function()
			local name = button.Name

			if v15 == false and button ~= nil and button.Name ~= "RemoveSkin" then
				v15 = true
				ClearCheckMarksGunSkins()

				if button:FindFirstChild("VIP") == nil then
					if button:FindFirstChild("VIP") == nil then
						clearTools:FireServer("RequestingGunSkins", name)
						button.GreenCheckMark.Visible = true
					end
				else
					local formatted = `GunSkin_${name}`

					if UnlockableController.IsFeatureUnlocked(formatted, Gamepasses.VIP) then
						clearTools:FireServer("RequestingGunSkins", name)
						button.GreenCheckMark.Visible = true
					else
						GamepassController.Show(Gamepasses.VIP, button.Icon.Image, "gun skin", nil, {
							id = formatted
						}, nil, "Gun Skin Inventory", name, function()
							if button.Parent == nil or not PanelController.IsOpen("NoResetGUIHandler", "GunSkinsMenu") then
								return
							end

							ClearCheckMarksGunSkins()
							clearTools:FireServer("RequestingGunSkins", name)
							button.GreenCheckMark.Visible = true
						end)
					end
				end

				wait(0.4)
				v15 = false
			end
		end))
	end
end

local component2 = ComponentUtil.GetComponentFromInstance(
	noResetGUIHandler.GunSkinsMenu.Catalog.Container.Skins,
	LoadableEntries
)
component2.Loaded:Connect(function()
	for _, child in noResetGUIHandler.GunSkinsMenu.Catalog.Container.Skins:GetChildren() do
		setupGunSkinsButton(child)
	end
end)

if component2:IsLoaded() then
	for _, child in noResetGUIHandler.GunSkinsMenu.Catalog.Container.Skins:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
		setupGunSkinsButton(child)
	end
end

component2.Added:Connect(function(items)
	for _, item in items do
		setupGunSkinsButton(item)
	end
end)
component2.Unloaded:Connect(function()
	maid2:Cleanup()

	for _, child in noResetGUIHandler.GunSkinsMenu.Catalog.Container.Skins:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
	end
end)
noResetGUIHandler.GunSkinsMenu.Catalog.Container.Skins.RemoveSkin.MouseButton1Click:connect(function()
	if v14 == false then
		v14 = true
		ClearCheckMarksGunSkins()
		clearTools:FireServer("RemoveGunSkins")
		ClearCheckMarksGunSkins()
		wait(0.5)
		v14 = false
	end
end)

function ClearCheckMarksGunGlock()
	for _, child in pairs(gunGlockMenu.Catalog.Container.ScrollingFrame:GetChildren()) do
		if child:isA("ImageButton") then
			child.GreenCheckMark.Visible = false
		end
	end
end

local maid3 = Janitor.new()

local function setupGunGlockButton(button)
	if button:IsA("ImageButton") then
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)
		maid3:Add(button.MouseButton1Click:connect(function()
			local name = button.Name

			if v17 == false and button ~= nil then
				v17 = true
				ClearCheckMarksGunGlock()

				if button.Name == "Skins" then
					if button.Name == "Skins" then
						PanelController.Close("NoResetGUIHandler", "GunGlockMenu")
						PanelController.Open("NoResetGUIHandler", "GunSkinsMenu")
					end
				else
					clearTools:FireServer("RequestingGlock", name)

					if button.Name ~= "Silencer" and button.Name ~= "Flashlight" then
						button.GreenCheckMark.Visible = true
					end
				end

				wait(0.7)
				v17 = false
			end
		end))
	end
end

local component3 = ComponentUtil.GetComponentFromInstance(
	gunGlockMenu.Catalog.Container.ScrollingFrame,
	LoadableEntries
)
component3.Loaded:Connect(function()
	for _, child in gunGlockMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		setupGunGlockButton(child)
	end
end)

if component3:IsLoaded() then
	for _, child in gunGlockMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
		setupGunGlockButton(child)
	end
end

component3.Added:Connect(function(items)
	for _, item in items do
		setupGunGlockButton(item)
	end
end)
component3.Unloaded:Connect(function()
	maid3:Cleanup()

	for _, child in gunGlockMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
	end
end)
gunGlockMenu.Catalog.Header.CategoryTabs.Close.MouseButton1Click:connect(function()
	if v18 == false then
		v18 = true
		PanelController.Close("NoResetGUIHandler", "GunGlockMenu")
		wait(0.5)
		v18 = false
	end
end)

function ClearCheckMarksGunGlockBrown()
	for _, child in pairs(gunGlockBrownMenu.Catalog.Container.ScrollingFrame:GetChildren()) do
		if child:isA("ImageButton") then
			child.GreenCheckMark.Visible = false
		end
	end
end

local maid4 = Janitor.new()

local function setupGunGlockBrownButton(button)
	if button:IsA("ImageButton") then
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)
		maid4:Add(button.MouseButton1Click:connect(function()
			local name = button.Name

			if v19 == false and button ~= nil then
				v19 = true
				ClearCheckMarksGunGlockBrown()

				if button.Name == "Skins" then
					if button.Name == "Skins" then
						PanelController.Close("NoResetGUIHandler", "GunGlockBrownMenu")
						PanelController.Open("NoResetGUIHandler", "GunSkinsMenu")
					end
				else
					clearTools:FireServer("RequestingGlockBrown", name)

					if button.Name ~= "Silencer" and button.Name ~= "Flashlight" then
						button.GreenCheckMark.Visible = true
					end
				end

				wait(0.7)
				v19 = false
			end
		end))
	end
end

local component4 = ComponentUtil.GetComponentFromInstance(
	gunGlockBrownMenu.Catalog.Container.ScrollingFrame,
	LoadableEntries
)
component4.Loaded:Connect(function()
	for _, child in gunGlockBrownMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		setupGunGlockBrownButton(child)
	end
end)

if component4:IsLoaded() then
	for _, child in gunGlockBrownMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
		setupGunGlockBrownButton(child)
	end
end

component4.Added:Connect(function(items)
	for _, item in items do
		setupGunGlockBrownButton(item)
	end
end)
component4.Unloaded:Connect(function()
	maid4:Cleanup()

	for _, child in gunGlockBrownMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
	end
end)
gunGlockBrownMenu.Catalog.Header.CategoryTabs.Close.MouseButton1Click:connect(function()
	if v20 == false then
		v20 = true
		PanelController.Close("NoResetGUIHandler", "GunGlockBrownMenu")
		wait(0.5)
		v20 = false
	end
end)

function ClearCheckMarksShotGun()
	for _, child in pairs(gunShotGunMenu.Catalog.Container.ScrollingFrame:GetChildren()) do
		if child:isA("ImageButton") then
			child.GreenCheckMark.Visible = false
		end
	end
end

local maid5 = Janitor.new()

local function setupShotgunButton(button)
	if button:IsA("ImageButton") then
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)
		maid5:Add(button.MouseButton1Click:connect(function()
			local name = button.Name

			if v21 == false and button ~= nil then
				v21 = true
				ClearCheckMarksShotGun()

				if button.Name == "Skins" then
					if button.Name == "Skins" then
						PanelController.Close("NoResetGUIHandler", "GunShotGunMenu")
						PanelController.Open("NoResetGUIHandler", "GunSkinsMenu")
					end
				else
					clearTools:FireServer("RequestingShotgun", name)

					if button.Name ~= "Silencer" and button.Name ~= "Flashlight" then
						button.GreenCheckMark.Visible = true
					end
				end

				wait(0.7)
				v21 = false
			end
		end))
	end
end

local component5 = ComponentUtil.GetComponentFromInstance(
	gunShotGunMenu.Catalog.Container.ScrollingFrame,
	LoadableEntries
)
component5.Loaded:Connect(function()
	for _, child in gunShotGunMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		setupShotgunButton(child)
	end
end)

if component5:IsLoaded() then
	for _, child in gunShotGunMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
		setupShotgunButton(child)
	end
end

component5.Added:Connect(function(items)
	for _, item in items do
		setupShotgunButton(item)
	end
end)
component5.Unloaded:Connect(function()
	maid5:Cleanup()

	for _, child in gunShotGunMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
	end
end)
gunShotGunMenu.Catalog.Header.CategoryTabs.Close.MouseButton1Click:connect(function()
	if v22 == false then
		v22 = true
		PanelController.Close("NoResetGUIHandler", "GunShotGunMenu")
		wait(0.5)
		v22 = false
	end
end)

function ClearCheckMarksGunSniper()
	for _, child in pairs(gunSniperMenu.Catalog.Container.ScrollingFrame:GetChildren()) do
		if child:isA("ImageButton") then
			child.GreenCheckMark.Visible = false
		end
	end
end

local maid6 = Janitor.new()

local function setupGunSniperButton(button)
	if button:IsA("ImageButton") then
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)
		maid6:Add(button.MouseButton1Click:connect(function()
			local name = button.Name

			if v23 == false and button ~= nil then
				v23 = true
				ClearCheckMarksGunSniper()

				if button.Name == "Skins" then
					if button.Name == "Skins" then
						PanelController.Close("NoResetGUIHandler", "GunSniperMenu")
						PanelController.Open("NoResetGUIHandler", "GunSkinsMenu")
					end
				else
					clearTools:FireServer("RequestingSniper", name)

					if button.Name ~= "Silencer" and button.Name ~= "Flashlight" then
						button.GreenCheckMark.Visible = true
					end
				end

				wait(0.7)
				v23 = false
			end
		end))
	end
end

local component6 = ComponentUtil.GetComponentFromInstance(
	gunSniperMenu.Catalog.Container.ScrollingFrame,
	LoadableEntries
)
component6.Loaded:Connect(function()
	for _, child in gunSniperMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		setupGunSniperButton(child)
	end
end)

if component6:IsLoaded() then
	for _, child in gunSniperMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
		setupGunSniperButton(child)
	end
end

component6.Added:Connect(function(items)
	for _, item in items do
		setupGunSniperButton(item)
	end
end)
component6.Unloaded:Connect(function()
	maid6:Cleanup()

	for _, child in gunSniperMenu.Catalog.Container.ScrollingFrame:GetChildren() do
		child:SetAttribute("AttachedConnection", nil)
	end
end)
gunSniperMenu.Catalog.Header.CategoryTabs.Close.MouseButton1Click:connect(function()
	if v24 == false then
		v24 = true
		PanelController.Close("NoResetGUIHandler", "GunSniperMenu")
		wait(0.5)
		v24 = false
	end
end)
cemeteryRemote.OnClientEvent:Connect(function(p, p2)
	if p == "AskTombStoneNameGUI" then
		cemeteryName.Visible = true
		cemeteryName.A.B.C.D.FocusLost:connect(function()
			if v == false then
				v = true
				cemeteryRemote:FireServer("ReturningTombStoneName", p2, cemeteryName.A.B.C.D.Text)
				cemeteryName.Visible = false
				cemeteryName.A.B.C.D.Text = ""
				wait(0.5)
				v = false
			end
		end)
	elseif p == "AskCommercialSignUI" then
		commercialSigns.Visible = true
		commercialSign.Value = p2
		colorPicks.Picks.D.FocusLost:connect(function()
			if v9 == false then
				v9 = true
				commercialSign.Value = p2
				cemeteryRemote:FireServer("ReturningCommercialWords", p2, nil, colorPicks.Picks.D.Text)
				colorPicks.Picks.D.Text = ""
				wait(0.5)
				v9 = false
			end
		end)
	elseif p == "AskPowerPasswordGUI" then
		if localPlayer.PlayersBag:FindFirstChild("PowerStation") ~= nil then
			if localPlayer.PlayersBag:FindFirstChild("PowerStation").Value ~= false then
				spawn(function()
					ClientMessage("Access has been approved...")
				end)
				return
			end

			powerPassword.A.B.C.D.Text = ""
			powerPassword.Visible = true
			powerPassword.A.B.C.D.FocusLost:connect(function()
				if v8 == false then
					v8 = true
					local text = powerPassword.A.B.C.D.Text

					if text == localPlayer.Name then
						cemeteryRemote:FireServer("PowerPasswordCheck", text)
						powerPassword.A.B.C.D.Text = "Password Approved!"
					else
						powerPassword.A.B.C.D.Text = "Incorrect Password"
					end

					wait(1)
					powerPassword.Visible = false
					wait(0.2)
					v8 = false
				end
			end)
		end
	elseif p == "AskRVNameGUI" then
		PanelController.Open("MainGUIHandler", "ModalRVName")
	elseif p == "AskAgencyPasswordGUI" then
		if localPlayer.PlayersBag:FindFirstChild("AgencyBunkerPassword") ~= nil then
			local agencyBunkerPassword = localPlayer.PlayersBag:FindFirstChild("AgencyBunkerPassword")

			if agencyBunkerPassword.Value ~= false and agencyBunkerPassword.Value ~= true then
				spawn(function()
					ClientMessage("Access has been approved...")
				end)
				return
			end

			agencyPassword.A.B.C.D.Text = ""
			agencyPassword.Visible = true
			agencyPassword.A.B.C.D.FocusLost:connect(function()
				if v8 == false then
					v8 = true
					local text = agencyPassword.A.B.C.D.Text

					if text == ("nevahkoorB sucraM"):reverse() then
						cemeteryRemote:FireServer("AgencyBunkerPasswordCheck", text)
						agencyPassword.A.B.C.D.Text = "Password Approved!"
					else
						agencyPassword.A.B.C.D.Text = "Incorrect Password"
					end

					wait(1)
					agencyPassword.Visible = false
					wait(0.2)
					v8 = false
				end
			end)
		end
	elseif p == "AskFurneralName" then
		cemeteryName.Visible = true
		cemeteryName.A.B.C.D.FocusLost:connect(function()
			if v2 == false then
				v2 = true
				cemeteryRemote:FireServer("ReturningFuneralName", cemeteryName.A.B.C.D.Text)
				wait(0.5)
				v2 = false
			end
		end)
	elseif p == "ConstuctionMessageGUI" then
		constructionName.Visible = true
		constructionName.A.B.C.D.FocusLost:connect(function()
			if v3 == false then
				v3 = true
				cemeteryRemote:FireServer("ReturningConstuctionName", p2, constructionName.A.B.C.D.Text)
				constructionName.A.B.C.D.Text = ""
				constructionName.Visible = false
				wait(0.5)
				v3 = false
			end
		end)
	elseif p == "GraveStoneMessageGUI" then
		graveStoneName.Visible = true
		graveStoneName.A.B.C.D.FocusLost:connect(function()
			if v4 == false then
				v4 = true
				cemeteryRemote:FireServer("ReturningGraveStoneName", p2, graveStoneName.A.B.C.D.Text)
				graveStoneName.A.B.C.D.Text = ""
				graveStoneName.Visible = false
				wait(0.5)
				v4 = false
			end
		end)
	elseif p == "BigSign2MessageGUI" then
		bigSign2Name.Visible = true
		bigSign2Name.A.B.C.D.FocusLost:connect(function()
			if v5 == false then
				v5 = true
				cemeteryRemote:FireServer("ReturningBigSign2Name", p2, bigSign2Name.A.B.C.D.Text)
				bigSign2Name.A.B.C.D.Text = ""
				bigSign2Name.Visible = false
				wait(0.5)
				v5 = false
			end
		end)
	elseif p == "BigSign3MessageGUI" then
		bigSign3Name.Visible = true
		bigSign3Name.A.B.C.D.FocusLost:connect(function()
			if v6 == false then
				v6 = true
				cemeteryRemote:FireServer("ReturningBigSign3Name", p2, bigSign3Name.A.B.C.D.Text)
				bigSign3Name.A.B.C.D.Text = ""
				bigSign3Name.Visible = false
				wait(0.5)
				v6 = false
			end
		end)
	elseif p == "BigSign4MessageGUI" then
		bigSign4Name.Visible = true
		bigSign4Name.A.B.C.D.FocusLost:connect(function()
			if v7 == false then
				v7 = true
				cemeteryRemote:FireServer("ReturningBigSign4Name", p2, bigSign4Name.A.B.C.D.Text)
				bigSign4Name.A.B.C.D.Text = ""
				bigSign4Name.Visible = false
				wait(0.5)
				v7 = false
			end
		end)
	end
end)
bigSign2Name.A.B.C.Close.MouseButton1Click:connect(function()
	bigSign2Name.Visible = false
end)
bigSign3Name.A.B.C.Close.MouseButton1Click:connect(function()
	bigSign3Name.Visible = false
end)
bigSign4Name.A.B.C.Close.MouseButton1Click:connect(function()
	bigSign4Name.Visible = false
end)
graveStoneName.A.B.C.Close.MouseButton1Click:connect(function()
	graveStoneName.Visible = false
end)
constructionName.A.B.C.Close.MouseButton1Click:connect(function()
	constructionName.Visible = false
end)
cemeteryName.A.B.C.Close.MouseButton1Click:connect(function()
	cemeteryName.Visible = false
end)
powerPassword.A.B.C.Close.MouseButton1Click:connect(function()
	powerPassword.Visible = false
end)
agencyPassword.A.B.C.Close.MouseButton1Click:connect(function()
	agencyPassword.Visible = false
end)
codeName.A.B.C.Close.MouseButton1Click:connect(function()
	codeName.Visible = false
end)
colorPicks.Picks.Close.MouseButton1Click:connect(function()
	commercialSigns.Visible = false
end)

if UserInputService.GamepadEnabled then
	palette.InputBegan:connect(function(p, _)
		local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

		for _, v25 in gamepadState do
			if not (v25.KeyCode == Enum.KeyCode.ButtonA and v25.UserInputState == Enum.UserInputState.Begin) then
				continue
			end

			local v26 = (p.Position.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X
			local v27 = (p.Position.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y
			local v28 = math.sqrt((v26 - 0.5) ^ 2 + (v27 - 0.5) ^ 2)

			if v28 > 0.5 then
				v26 = (v26 - 0.5) / v28 * 0.5 + 0.5
				v27 = (v27 - 0.5) / v28 * 0.5 + 0.5
				v28 = 0.5
			end

			local v29 = math.atan2(v27 - 0.5, v26 - 0.5)
			local v30 = (3.141592653589793 - v29) / 6.283185307179586
			hue2.Value = v30
			saturation.Value = v28 * 2
			finalColor.BackgroundColor3 = Color3.fromHSV(v30, v28 * 2, value.Value)
			finalColorWords.BackgroundColor3 = Color3.fromHSV(v30, v28 * 2, value.Value)
			uIGradient.Color = ColorSequence.new(color, Color3.fromHSV(v30, v28 * 2, 1))
		end
	end)
end

if UserInputService.GamepadEnabled then
	darknessBar.InputBegan:connect(function(p, _)
		local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

		for _, v25 in gamepadState do
			if not (v25.KeyCode == Enum.KeyCode.ButtonA and v25.UserInputState == Enum.UserInputState.Begin) then
				continue
			end

			value.Value = 1 - math.clamp(
				(p.Position.Y - darknessBar.AbsolutePosition.Y) / darknessBar.AbsoluteSize.Y,
				0,
				1
			)
			finalColor.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
			finalColorWords.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
		end
	end)
end

palette.MouseButton1Down:Connect(function()
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local v25 = (input.Position.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X
		local v26 = (input.Position.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y
		local v27 = math.sqrt((v25 - 0.5) ^ 2 + (v26 - 0.5) ^ 2)

		if v27 > 0.5 then
			v25 = (v25 - 0.5) / v27 * 0.5 + 0.5
			v26 = (v26 - 0.5) / v27 * 0.5 + 0.5
			v27 = 0.5
		end

		local v28 = math.atan2(v26 - 0.5, v25 - 0.5)
		local v29 = (3.141592653589793 - v28) / 6.283185307179586
		hue2.Value = v29
		saturation.Value = v27 * 2
		finalColor.BackgroundColor3 = Color3.fromHSV(v29, v27 * 2, value.Value)
		finalColorWords.BackgroundColor3 = Color3.fromHSV(v29, v27 * 2, value.Value)
		uIGradient.Color = ColorSequence.new(color, Color3.fromHSV(v29, v27 * 2, 1))
	end)
	local inputEndedConnection = nil
	inputEndedConnection = UserInputService.InputEnded:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
		inputEndedConnection:Disconnect()
		inputEndedConnection = nil
	end)
end)
darknessBar.MouseButton1Down:Connect(function()
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		value.Value = 1 - math.clamp(
			(input.Position.Y - darknessBar.AbsolutePosition.Y) / darknessBar.AbsoluteSize.Y,
			0,
			1
		)
		finalColor.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
		finalColorWords.BackgroundColor3 = Color3.fromHSV(hue.Value, saturation.Value, value.Value)
	end)
	local inputEndedConnection = nil
	inputEndedConnection = UserInputService.InputEnded:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		inputChangedConnection:Disconnect()
		inputChangedConnection = nil
		inputEndedConnection:Disconnect()
		inputEndedConnection = nil
	end)
end)
finalColor.MouseButton1Click:Connect(function()
	if v10 == false then
		v10 = true
		local backgroundColor3 = finalColor.BackgroundColor3
		cemeteryRemote:FireServer("CommercialBackGround", commercialSign.Value, backgroundColor3, nil)
		wait(1)
		v10 = false
	end
end)
finalColorWords.MouseButton1Click:Connect(function()
	if v11 == false then
		v11 = true
		local backgroundColor3 = finalColorWords.BackgroundColor3
		cemeteryRemote:FireServer("CommercialWordColor", commercialSign.Value, backgroundColor3, nil)
		wait(1)
		v11 = false
	end
end)