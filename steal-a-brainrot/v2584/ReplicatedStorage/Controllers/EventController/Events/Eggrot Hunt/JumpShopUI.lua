local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local JumpShopData = require(ReplicatedStorage.Datas.JumpShopData)
local EggrotZoneNames = require(ReplicatedStorage.Datas.EggrotZoneNames)
local remoteFunction = Net:RemoteFunction("EggrotHunt/JumpShop/Buy")
local localPlayer = Players.LocalPlayer
local jumpShop = localPlayer.PlayerGui:WaitForChild("JumpShop"):FindFirstChild("JumpShop")

if not jumpShop then
	return function() end
end

local v = InterfaceController:Register("EggrotJumpShop", jumpShop, "TopQuint")
v:AttachCloseButton(jumpShop.Header.Close)
v:Close()
return {
	Start = function(_)
		local maid = Trove.new()
		local scrollingFrame = jumpShop.ScrollingFrame
		local template = scrollingFrame:FindFirstChild("Template")

		if not template then
			return function()
				maid:Destroy()
			end
		end

		template.Visible = false
		local maid2 = Trove.new()
		maid:Add(maid2)
		local v2 = {}

		local function getOwnedCount()
			local v3 = Synchronizer:Get(localPlayer)

			if not v3 then
				return 0
			end

			local v4 = v3:Get({ "EasterEvent", "JumpShop" })

			if typeof(v4) == "number" then
				return v4
			end

			return 0
		end

		local function hasVisitedZone(p: string)
			local v3 = Synchronizer:Get(localPlayer)

			if v3 then
				return v3:Get({ "EasterEvent", "VisitedZones", p }) == true
			end

			return false
		end

		local function refresh()
			local ownedCount = getOwnedCount()

			for _, v3 in v2 do
				local v4 = JumpShopData[v3.Tier]
				local visible = v3.Tier <= ownedCount
				local v6 = v3.Tier == ownedCount + 1
				local v7 = not v4.Zone

				if not v7 then
					local zone = v4.Zone
					local v8 = Synchronizer:Get(localPlayer)

					if v8 then
						v7 = v8:Get({ "EasterEvent", "VisitedZones", zone }) == true
					else
						v7 = false
					end
				end

				if v3.InfoLabel then
					v3.InfoLabel.Visible = visible
				end

				if v3.ClaimButton then
					v3.ClaimButton.Visible = v6 and v7
				end

				if v3.LockedLabel then
					if visible then
						v3.LockedLabel.Visible = false
					elseif v7 or not v4.Zone then
						if v6 or visible then
							v3.LockedLabel.Visible = false
						else
							v3.LockedLabel.Visible = true
							v3.LockedLabel.Text = `Buy Jump {v3.Tier} first!`
						end
					else
						v3.LockedLabel.Visible = true
						local v8 = EggrotZoneNames[v4.Zone] or v4.Zone
						v3.LockedLabel.Text = `Reach {v8} Island first!`
					end
				end

				if not v3.Icon then
					continue
				end

				local icon = v3.Icon
				local image

				if v7 or visible then
					image = v4.JumpIcon
				else
					image = v4.IslandIcon
				end

				icon.Image = image
			end
		end

		for k, v3 in JumpShopData do
			local clone = template:Clone()
			clone.Name = `Jump_{k}`
			clone.LayoutOrder = k
			clone.Visible = true
			local spacer = clone:FindFirstChild("Spacer")

			if spacer then
				local title = spacer:FindFirstChild("Title")

				if title and title:IsA("TextLabel") then
					title.Text = `{k + 1} Jumps`
				end

				local info = spacer:FindFirstChild("Info")
				local claim = spacer:FindFirstChild("Claim")
				local locked = spacer:FindFirstChild("Locked")
				local icon = spacer:FindFirstChild("Icon")

				if info and info:IsA("TextLabel") then
					info.Text = "Owned"
				end

				if claim and claim:IsA("GuiButton") then
					local txt = claim:FindFirstChild("Txt")

					if txt and txt:IsA("TextLabel") then
						txt.Text = tostring(v3.Price)
					end

					local v4 = AnimatedButton.new(claim)
					v4:Animate()
					maid2:Add(v4.OnActivated:Connect(function()
						local v5, v6 = remoteFunction:InvokeServer()

						if v5 then
							NotificationController:Success(v6 or "Purchased!")
							SoundController:PlaySound("Sounds.Sfx.Success")
							refresh()
						else
							NotificationController:Error(v6 or "Purchase failed.")
							SoundController:PlaySound("Sounds.Sfx.Error")
						end
					end))
				end

				if not (info and info:IsA("TextLabel")) then
					info = nil
				end

				if not (claim and claim:IsA("GuiButton")) then
					claim = nil
				end

				if not (locked and locked:IsA("TextLabel")) then
					locked = nil
				end

				if not (icon and icon:IsA("ImageLabel")) then
					icon = nil
				end

				table.insert(v2, {
					Clone = clone,
					InfoLabel = info,
					ClaimButton = claim,
					LockedLabel = locked,
					Icon = icon,
					Tier = k
				})
				clone.Parent = scrollingFrame
				maid:Add(clone)
			else
				clone:Destroy()
			end
		end

		Synchronizer:WaitAndCall(localPlayer, function(object)
			maid:Add(object:OnChanged({ "EasterEvent", "JumpShop" }, refresh))
			maid:Add(object:OnChanged({ "EasterEvent", "VisitedZones" }, refresh))
			maid:Add(object:OnDictionaryInserted({ "EasterEvent", "VisitedZones" }, refresh))
			task.spawn(refresh)
		end)
		maid:Add(Observers.observeTag("EggrotJumpShopPrompt", function(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return nil
			end

			local triggeredConnection = proximityPrompt.Triggered:Connect(function()
				InterfaceController:Toggle("EggrotJumpShop")
			end)
			return function()
				triggeredConnection:Disconnect()
			end
		end, { workspace }))
		return function()
			maid:Destroy()
		end
	end
}