local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Synchronizer)
local FFlags = require(packages.FFlags)
require(packages.Signal)
local Timer = require(packages.Timer)
local Net = require(packages.Net)
local vide = require(packages.vide)
require(ReplicatedStorage.Controllers.InterfaceController)
local Mutations = require(ReplicatedStorage.Shared.Mutations)
local Updates = require(ReplicatedStorage.Shared.Updates)
local Policy = require(ReplicatedStorage.Shared.Policy)
local Shop = require(ReplicatedStorage.Datas.Shop)
local Reactive = require(script.Parent.Reactive)
local source = vide.source
local _ = vide.derive
local read = vide.read
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("ShopService/Purchase")
return table.freeze({
	new = function(interface, toggleGiftSignal)
		local v = {
			Interface = interface,
			ToggleGiftSignal = toggleGiftSignal,
			Opened = Reactive.FromSubscription(function(p2)
				local maid = Reactive.Trove()
				maid:Add(interface.OnOpen:Connect(p2))
				maid:Add(interface.OnClose:Connect(p2))
				return maid
			end, function()
				return interface:IsOpened()
			end),
			Mutation = Reactive.FromSubscription(function(p2)
				return Mutations.watch(p2)
			end, function()
				return Mutations.get()
			end)
		}
		local updatesRevision = source(0)
		local maid = Reactive.Trove()

		local function bump()
			updatesRevision(updatesRevision() + 1)
		end

		maid:Add(Updates.OnUpdateEnabled:Connect(bump))
		maid:Add(Updates.OnUpdateDisabled:Connect(bump))
		v.UpdatesRevision = updatesRevision
		v.Clock = Reactive.Clock(1)
		local refresh = source(0)
		Reactive.Trove():Add(Timer.Simple(300, function()
			refresh(refresh() + 1)
		end))
		v.Refresh = refresh
		v.GiftTarget = source(nil)
		v.RegionalGifts = source(nil)
		local policy2 = source(nil)
		v.Policy = policy2
		local flag = true
		Reactive.Trove():Add(function()
			flag = false
		end)
		task.spawn(function()
			while flag and localPlayer:IsDescendantOf(Players) do
				local policy = Policy.getPolicy(localPlayer)

				if policy then
					if flag then
						policy2(policy)
					end

					break
				else
					task.wait(5)
				end
			end
		end)

		function v.SetGiftTarget(data, p2: number?)
			if data.GiftTarget() == p2 then
				return
			end

			data.GiftTarget(p2)
			data.RegionalGifts(nil)
			data.ToggleGiftSignal:Fire(p2 ~= nil)

			if p2 == nil or FFlags:Get("DevProductRegionalPricingDisabled", false) then
				return
			end

			task.spawn(function()
				local v5 = Net:Invoke("ShopService/UseRegionalPriceGifts", p2)

				if data.GiftTarget() == p2 then
					data.RegionalGifts(v5)
				end
			end)
		end

		function v:ResolveProductId(p3)
			local v5 = read(p3)

			if self.GiftTarget() == nil then
				return v5
			end

			local regionalGifts = self.RegionalGifts()

			if regionalGifts == nil then
				return v5
			end

			local v6 = Shop[v5]

			if not v6 then
				return v5
			end

			local v7

			if regionalGifts then
				v7 = v6.GiftProduct
			else
				v7 = v6.GiftProductNoRegional or v6.GiftProduct
			end

			return v7 or v5
		end

		function v:Buy(p2)
			remoteEvent:FireServer(self:ResolveProductId(p2), self.GiftTarget())
		end

		function v.BuyDirect(_, p2: number)
			remoteEvent:FireServer(p2)
		end

		function v.Owns(_, p2: number)
			local v5 = Shop[p2]

			if not v5 then
				return source(false)
			end

			local path = v5.Type == "Gamepass" and "Gamepass" or "Items"
			local display = v5.Display
			return Reactive.FromChannel(function(object2)
				return object2:Get((`{path}.{display}`)) == true
			end, false, {
				{
					Method = "OnDictionaryInserted",
					Path = path
				},
				{
					Method = "OnChanged",
					Path = { path, display }
				}
			})
		end

		return v
	end,
	PaidRandomRestricted = function(p)
		local policy = p.Policy()
		return not policy or policy.ArePaidRandomItemsRestricted == true
	end
})