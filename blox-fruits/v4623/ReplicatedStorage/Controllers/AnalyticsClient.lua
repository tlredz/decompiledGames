local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnalyticsClient = {}

function AnalyticsClient.ReportShoppingStep(_, data)
	ReplicatedStorage.Remotes.RobloxAnalytics.Shop:FireServer({
		funnelId = data.funnelId,
		step = data.step,
		storageName = data.storageName,
		purchaseLocation = data.purchaseLocation
	})
end

function AnalyticsClient.OnStart(_)
	local getPlatform = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetPlatform")

	if getPlatform then
		local LastInput = require(ReplicatedStorage.Modules.LastInput)
		local v = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function platformChanged()
			local v2 = LastInput:Get()

			if v2 == "Gamepad" then
				v = "Console"
			elseif v2 == "MouseKeyboard" then
				v = "PC"
			elseif v2 == "Touch" then
				v = "Mobile"
			else
				v = "Unknown"
			end
		end

		getPlatform.OnClientInvoke = function()
			return v
		end

		if LastInput:Get() then
			platformChanged() -- equivalent call inferred; original call site unknown
		end

		LastInput.Changed:Connect(platformChanged)
	end
end

return AnalyticsClient