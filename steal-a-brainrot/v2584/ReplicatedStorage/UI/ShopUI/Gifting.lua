local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Synchronizer)
local vide = require(packages.vide)
local Layout = require(script.Parent.Layout)
local Reactive = require(script.Parent.Reactive)
require(script.Parent.State)
local effect = vide.effect
local root = vide.root
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function headshotFor(p: number)
	local userThumbnailAsync = ""
	pcall(function()
		userThumbnailAsync = Players:GetUserThumbnailAsync(
			p,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)
	return userThumbnailAsync
end

return table.freeze({
	MountPlayerList = function(self, object)
		local resolved = Layout.Resolve(self, { "Main", "List" })
		local template = resolved and resolved:FindFirstChild("Template")

		if not (resolved and template and template:IsA("GuiObject")) then
			return
		end

		local resolved2 = Layout.Resolve(self, { "Header", "Close" })

		if resolved2 and resolved2:IsA("GuiButton") and self:IsA("GuiObject") then
			Reactive.Button(resolved2, function()
				self.Visible = false
				object.ToggleGiftSignal:Fire(false)
			end)
		end

		local maid = Reactive.Trove()
		local v2 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removePlayer(k)
			local v3 = v2[k]

			if v3 then
				v2[k] = nil
				v3()
			end

			local child = resolved:FindFirstChild(k.Name)

			if child then
				child:Destroy()
			end
		end

		local function addPlayer(instance)
			if instance == localPlayer or v2[instance] then
				return
			end

			local clone = template:Clone()
			clone.Name = instance.Name
			clone.PlayerName.Text = instance.Name
			local v3 = true

			local function destroyPendingEntry()
				v3 = false
				clone:Destroy()
			end

			v2[instance] = destroyPendingEntry
			local image = headshotFor(instance.UserId) -- equivalent call inferred; original call site unknown

			if not v3 or not instance:IsDescendantOf(Players) or v2[instance] ~= destroyPendingEntry then
				return
			end

			clone.PlayerImage.Headshot.Image = image
			local gift = clone:FindFirstChild("Gift")
			local v5

			if gift and gift:IsA("GuiButton") then
				v5 = root(function()
					Reactive.Button(gift, function()
						object:SetGiftTarget(instance.UserId)

						if self:IsA("GuiObject") then
							self.Visible = false
						end
					end)
				end)
			else
				v5 = nil
			end

			v2[instance] = function()
				if v5 then
					v5()
				end

				clone:Destroy()
			end

			clone.Visible = true
			clone.Parent = resolved
		end

		maid:Add(function()
			for k in v2 do
				removePlayer(k) -- equivalent call inferred; original call site unknown
			end
		end)
		maid:Add(Players.PlayerAdded:Connect(addPlayer))
		maid:Add(Players.PlayerRemoving:Connect(removePlayer))

		for _, v3 in Players:GetPlayers() do
			task.spawn(addPlayer, v3)
		end
	end,
	MountSelect = function(p, p2, guiObject, object)
		local resolved = Layout.Resolve(p, p2.GiftPlayerSelect)

		if not resolved then
			return
		end

		local buttons = resolved:FindFirstChild("Buttons")
		local playerSelected = resolved:FindFirstChild("PlayerSelected")
		local giftButton = buttons and buttons:FindFirstChild("GiftButton")

		if giftButton and giftButton:IsA("GuiButton") then
			Reactive.Button(giftButton, function()
				if object.GiftTarget() then
					object:SetGiftTarget(nil)
				elseif guiObject:IsA("GuiObject") then
					guiObject.Visible = not guiObject.Visible
				end
			end)
			local txt = giftButton:FindFirstChild("Txt")

			if txt and txt:IsA("TextLabel") then
				Reactive.Hydrate(txt, {
					Text = function()
						if object.GiftTarget() then
							return "Back"
						end

						return "Gift Player"
					end
				})
			end
		end

		if playerSelected and playerSelected:IsA("GuiObject") then
			Reactive.Hydrate(playerSelected, {
				Visible = function()
					return object.GiftTarget() ~= nil
				end
			})
			local playerName = playerSelected:FindFirstChild("PlayerName")
			local playerImage = playerSelected:FindFirstChild("PlayerImage")
			local headshot = playerImage and playerImage:FindFirstChild("Headshot")
			effect(function()
				local giftTarget = object.GiftTarget()

				if not giftTarget then
					return
				end

				local playerByUserId = Players:GetPlayerByUserId(giftTarget)

				if playerName and playerName:IsA("TextLabel") and playerByUserId then
					playerName.Text = `@{playerByUserId.Name}`
				end

				if headshot and headshot:IsA("ImageLabel") then
					task.spawn(function()
						local image = headshotFor(giftTarget) -- equivalent call inferred; original call site unknown

						if object.GiftTarget() == giftTarget then
							headshot.Image = image
						end
					end)
				end
			end)
		end

		local giftInventoryButton = buttons and buttons:FindFirstChild("GiftInventoryButton")

		if giftInventoryButton and giftInventoryButton:IsA("GuiButton") then
			local ValentinesShopController = require(ReplicatedStorage.Controllers.ValentinesShopController)
			local v2 = Reactive.FromChannel(function(object2)
				local v3 = object2:Get({ "ValentinesEvent", "GiftInventory" })

				if v3 then
					return #v3
				end

				return 0
			end, 0, {
				{
					Method = "OnChanged",
					Path = { "ValentinesEvent", "GiftInventory" }
				},
				{
					Method = "OnArrayInserted",
					Path = { "ValentinesEvent", "GiftInventory" }
				},
				{
					Method = "OnArrayRemoved",
					Path = { "ValentinesEvent", "GiftInventory" }
				}
			})
			Reactive.Hydrate(giftInventoryButton, {
				Visible = function()
					object.UpdatesRevision()
					return v2() > 0 and not ValentinesShopController:IsEnabled()
				end
			})
			Reactive.Button(giftInventoryButton, function()
				ValentinesShopController:Open("Gifts", "Shop")
			end)
		end
	end
})