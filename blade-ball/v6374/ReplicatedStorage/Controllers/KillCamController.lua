local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("RunService")
local v = require3("@game/ReplicatedStorage/Packages/Charm")
local v2 = require3("@game/ReplicatedStorage/Packages/Chroma")
local v3 = require3("@game/ReplicatedStorage/Packages/Trove")
local v4 = require3("@game/ReplicatedStorage/Packages/Net")
local v5 = require3("@game/ReplicatedStorage/Common/Utils")
require3("@game/ReplicatedStorage/Common/ItemsUtil")
local v6 = require3("@game/ReplicatedStorage/UserGenerated/ABTests")
local v7 = require3("@game/ReplicatedStorage/Shared/PlayerData/CountryIcons")
local v8 = require3("@game/ReplicatedStorage/Shared/TitleData")
require3("@game/ReplicatedStorage/Shared/PlayerProfile")
local v9 = require3("./UI/HUDController")
local v10 = require3("@game/ReplicatedStorage/ServerInfo")
local spring = v5.Spring
local KillCamController = {}
local localPlayer = Players.LocalPlayer
local playerCard = localPlayer.PlayerGui.KillCamCard.PlayerCard
local atom = v.atom(nil)
local atom2 = v.atom(nil)
local camera = workspace.Camera
local v11 = nil

function KillCamController:Show(player, p)
	if v11 then
		v11:Destroy()
	end

	v.batch(function()
		atom2(player)
		atom(p)
	end)
	v9:Hide("KillCam")
	local maid = v3.new()
	v11 = maid
	local character = player.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	camera.CameraSubject = humanoid
	maid:Add(task.delay(Players.RespawnTime, function()
		maid:Destroy()
		v11 = nil
		v9:Show("KillCam")
	end))
	maid:Add(function()
		v.batch(function()
			atom2(nil)
			atom(nil)
		end)
		local character2 = localPlayer.Character or localPlayer.CharacterAdded:Wait()
		local humanoid2 = character2 and character2:WaitForChild("Humanoid", 20)

		if not humanoid2 then
			return
		end

		camera.CameraSubject = humanoid2
	end)
end

function KillCamController.Start(_)
	v4:Connect("KillCam/Show", function(p, p2)
		if v10.isTestGame() or v6.GetAttribute(localPlayer, "KillCam", false) then
			KillCamController:Show(p, p2)
		end
	end)
	v.effect(function()
		local v12 = atom()
		local v13 = atom2()

		if not (v12 and v13) then
			spring.target(playerCard, 0.85, 3.5, {
				Position = UDim2.fromScale(1.5, 0.5)
			})
			return
		end

		local abilityOverride = v13:GetAttribute("AbilityOverride") or v13:GetAttribute("EquippedAbility")
		playerCard.Ability.Ability.Image = abilityOverride and v5.Icons:GetAbilityIcon(abilityOverride) or v5.Icons:GetIcon("DEFAULT_MISSING")
		local v14 = nil

		if v12.Title then
			for _, v16 in v8 do
				if v16.Name ~= v12.Title then
					continue
				end

				v14 = v16
				break
			end
		end

		playerCard.Title.Text = not v14 and "" or v14.Tag.Text or ""
		playerCard.Title.TextColor3 = v14 and v14.Tag.Color or Color3.fromRGB(255, 255, 255)
		playerCard.Title.UIStroke.Color = v14 and v2.roblox(v14.Tag.Color):darken(1):roblox() or Color3.fromRGB(
			255,
			255,
			255
		)
		playerCard.Username.Text = v13.DisplayName
		playerCard.PlayerThumbnail.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={v13.UserId}&w=150&h=150`
		playerCard.Kills.Visible = v12.Kills ~= nil
		playerCard.Kills.Amount.Text = `{v5.ValueConvertor:AddCommas(v12.Kills or 0)} Elims`
		playerCard.Kills.Shadow.Text = playerCard.Kills.Amount.Text
		playerCard.Wins.Visible = v12.Wins ~= nil
		playerCard.Wins.Amount.Text = `{v5.ValueConvertor:AddCommas(v12.Wins or 0)} Wins`
		playerCard.Wins.Shadow.Text = playerCard.Wins.Amount.Text
		playerCard.Icons.Device.Visible = v12.Device ~= nil
		playerCard.Icons.Device.Image = v5.Icons:GetIcon(v12.Device or "DEFAULT_MISSING")
		local v15 = v12.Country and v7[v12.Country]
		playerCard.Icons.Country.Text = not v15 and "" or v15.Emoji
		spring.target(playerCard, 0.85, 3.5, {
			Position = UDim2.fromScale(0.95, 0.5)
		})
	end)
end

return KillCamController