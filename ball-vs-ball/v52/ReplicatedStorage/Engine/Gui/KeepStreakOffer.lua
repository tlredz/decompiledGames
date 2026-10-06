local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local DevProductService = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Market"):WaitForChild("DevProductService"))
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local flag = false
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function dismissActive()
	if v then
		ConfirmDialogController.Complete(v)
		v = nil
	end
end

local function showPanel(p: number)
	dismissActive() -- equivalent call inferred; original call site unknown
	v = ConfirmDialogController.Enqueue("购买连胜保护面板", {
		category = "KeepStreakOffer",
		onShown = function(instance, callback)
			local waitForChild = instance:WaitForChild("连胜数量")
			waitForChild.Text = "🔥" .. tostring(p)
			local R = instance:WaitForChild("R币购买")
			local v2 = R:WaitForChild("价格")
			local keepStreak = DevProductService.products.byProductKey["Keep Streak"]
			v2.Text = DevProductService.robuxEmoji .. tostring(keepStreak and keepStreak.PriceInRobux or "?")
			local v3 = instance:WaitForChild("关闭按钮")
			R.Active = true
			v3.Active = true
			local flag2 = false
			local v4 = nil
			local connection = nil
			local connection2 = nil

			local function finish()
				if flag2 then
					return
				end

				flag2 = true

				if v4 then
					v4()
				end

				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				R.Active = false
				v3.Active = false
				v = nil
				callback()
			end

			v4 = DevProductService.client.onPurchaseGranted("Keep Streak", function()
				if flag2 then
					return
				end

				flag2 = true

				if v4 then
					v4()
				end

				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				R.Active = false
				v3.Active = false
				v = nil
				callback()
			end)
			connection = ConfirmDialogController.BindButton(R, "A", function()
				DevProductService.client.promptPurchase("Keep Streak")
			end)
			connection2 = ConfirmDialogController.BindButton(v3, "B", function()
				if flag2 then
					return
				end

				flag2 = true

				if v4 then
					v4()
				end

				if connection then
					connection:Disconnect()
				end

				if connection2 then
					connection2:Disconnect()
				end

				R.Active = false
				v3.Active = false
				v = nil
				callback()
			end)
		end
	})
end

return {
	Init = function()
		if flag then
			return
		end

		flag = true
		ConfirmDialogController.Init()
		Net:RemoteEvent("KeepStreakOffer").OnClientEvent:Connect(showPanel)
	end
}