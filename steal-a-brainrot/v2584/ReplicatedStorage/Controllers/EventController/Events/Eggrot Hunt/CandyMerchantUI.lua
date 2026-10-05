local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Net = require(ReplicatedStorage.Packages.Net)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local eggrotCandyStock = ReplicatorClient.get("EggrotCandyStock")
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local CandyMerchantData = require(ReplicatedStorage.Datas.CandyMerchantData)
local remoteFunction = Net:RemoteFunction("EggrotHunt/CandyMerchant/Buy")
local localPlayer = Players.LocalPlayer
local candyShop = localPlayer.PlayerGui:WaitForChild("CandyShop").CandyShop
local v = InterfaceController:Register("EggrotCandyShop", candyShop, "TopQuint")
v:AttachCloseButton(candyShop.Header.Close)
v:Close()
return {
	Start = function(_)
		local maid = Trove.new()
		local main = candyShop.Main
		local template = main:FindFirstChild("Template")
		local v2 = nil

		local function updateStock()
			if v2 then
				v2:Destroy()
			end

			local maid2 = Trove.new()
			v2 = maid2
			maid:Add(maid2)
			local v3 = eggrotCandyStock:TryIndex({ "stock" })

			if type(v3) ~= "table" or #v3 == 0 then
				return
			end

			Synchronizer:Get(localPlayer)

			for _, v4 in v3 do
				if not template then
					continue
				end

				local v5 = CandyMerchantData[v4]

				if not v5 then
					continue
				end

				local clone = template:Clone()
				clone.Name = v4
				clone.Visible = true
				local name = clone:FindFirstChild("Name")

				if name and name:IsA("TextLabel") then
					name.Text = v4
				end

				local icon = clone:FindFirstChild("Icon")

				if icon and icon:IsA("ImageLabel") then
					icon.Image = v5.Icon
				end

				local buy = clone:FindFirstChild("Buy")

				if buy and buy:IsA("GuiButton") then
					local label = buy:FindFirstChild("Function")

					if label and label:IsA("TextLabel") then
						label.Text = `${NumberUtils:ToString(v5.Price, 2)}`
					end

					local v6 = AnimatedButton.new(buy)
					v6:Animate()
					local v7 = v4
					maid2:Add(v6.OnActivated:Connect(function()
						local v8, v9 = remoteFunction:InvokeServer(v7)

						if v8 then
							NotificationController:Success(v9 or "Purchased!")
							SoundController:PlaySound("Sounds.Sfx.Success")
						else
							NotificationController:Error(v9 or "Purchase failed.")
							SoundController:PlaySound("Sounds.Sfx.Error")
						end
					end))
				end

				clone.Parent = main
				maid2:Add(clone)
			end
		end

		maid:Add(eggrotCandyStock:Listen({ "stock" }, updateStock))
		task.spawn(updateStock)
		local title = candyShop:FindFirstChild("Title")

		if title and title:IsA("TextLabel") then
			maid:Add(Timer.Simple(1, function()
				local v3 = 300 - workspace:GetServerTimeNow() % 300
				title.Text = `Shop refreshes in <font color="rgb(250, 111, 255)">{TimeUtils:E((math.max(v3 // 1, 0)))}</font>`
			end, true))
		end

		maid:Add(Observers.observeTag("EggrotCandyMerchantPrompt", function(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return nil
			end

			local triggeredConnection = proximityPrompt.Triggered:Connect(function()
				InterfaceController:Toggle("EggrotCandyShop")
			end)
			return function()
				triggeredConnection:Disconnect()
			end
		end, { workspace }))
		return function()
			if v2 then
				v2:Destroy()
			end

			maid:Destroy()
		end
	end
}