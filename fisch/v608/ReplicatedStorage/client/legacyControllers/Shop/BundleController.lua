local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Signal = require(packages:WaitForChild("Signal"))
local Timer = require(packages:WaitForChild("Timer"))
local modules = ReplicatedStorage.shared.modules
local Bundles = require(modules:WaitForChild("Bundles"))
local v = {}
local v2 = Timer.new(1)
local BundleController = {
	OnBundleDisabled = Signal.new(),
	RequestState = function(_, value: string)
		if not value or typeof(value) ~= "string" or not Bundles[value] then
			return false
		end

		if v[value] then
			return true
		end

		return false
	end,
	Purchase = function(_, _: string, _: boolean?) end
}

function BundleController:Start()
	v2.Tick:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()

		for k, bundle in Bundles do
			if not bundle.LimitedDate then
				continue
			end

			local min = bundle.LimitedDate.Min
			local max = bundle.LimitedDate.Max

			if serverTimeNow < min.UnixTimestamp or max.UnixTimestamp < serverTimeNow then
				v[k] = nil
				BundleController.OnBundleDisabled:Fire(k)
			else
				v[k] = true
			end

			local v3 = max.UnixTimestamp - serverTimeNow

			if v3 <= 0 then
				for _, v4 in CollectionService:GetTagged("BundleTimer") do
					if v4:GetAttribute("Bundle") == k then
						v4.Text = "Expired"
					end
				end
			else
				local universalTime = DateTime.fromUnixTimestamp(v3):ToUniversalTime()
				local day = universalTime.Day
				local hour = universalTime.Hour
				local minute = universalTime.Minute
				local second = universalTime.Second
				local text = "Leaving in:"

				if day >= 1 then
					text ..= ` {day}d`
				end

				if hour >= 1 or day >= 1 then
					text ..= ` {hour}h`
				end

				if minute >= 1 or hour >= 1 then
					text ..= ` {minute}m`
				end

				if minute < 1 then
					text ..= ` {second}s`
				end

				for _, v5 in CollectionService:GetTagged("BundleTimer") do
					if v5:GetAttribute("Bundle") == k then
						v5.Text = text
					end
				end
			end
		end
	end)
	v2:Start()
end

local serverTimeNow = workspace:GetServerTimeNow()

for k, bundle in Bundles do
	if bundle.LimitedDate then
		local min = bundle.LimitedDate.Min
		local max = bundle.LimitedDate.Max

		if serverTimeNow < min.UnixTimestamp or max.UnixTimestamp < serverTimeNow then
			continue
		end
	end

	v[k] = true
end

return BundleController