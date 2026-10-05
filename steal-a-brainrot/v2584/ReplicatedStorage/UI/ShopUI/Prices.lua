local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Synchronizer = require(packages.Synchronizer)
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
local vide = require(packages.vide)
local Marketplace = require(ReplicatedStorage.Shared.Marketplace)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local Reactive = require(script.Parent.Reactive)
local source = vide.source
local effect = vide.effect
local derive = vide.derive
local cleanup = vide.cleanup
local read = vide.read
local localPlayer = Players.LocalPlayer
local v = utf8.char(57346)
local v2 = source(0)
Timer.Simple(300, function()
	v2(v2() + 1)
end)
local v3 = {
	Format = function(p: number?)
		if p == nil or p == 999999999 then
			return "???"
		end

		return NumberUtils:Comma(p)
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function failedGiftCount(p)
	local v4 = source(0)
	effect(function()
		local v5 = read(p)
		local maid = Trove.new()
		cleanup(function()
			maid:Destroy()
		end)
		local v6 = true
		maid:Add(function()
			v6 = false
		end)
		task.spawn(function()
			local v7 = Synchronizer:Wait(localPlayer)

			if not (v7 and v6) then
				return
			end

			local v8 = { "FailedGifts", (tostring(v5)) }

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				local v9 = v7:Get(v8)
				v4(v9 and #v9 or 0)
			end

			maid:Add(v7:OnChanged(v8, update))
			maid:Add(v7:OnArrayInserted(v8, update))
			maid:Add(v7:OnArrayRemoved(v8, update))
			update() -- equivalent call inferred; original call site unknown
		end)
	end)
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function marketplacePrice(p, p2)
	local v4 = source(nil)
	local v5 = Reactive.FromFlag("RefreshClientDisplayedPrices", false)
	local v6 = nil
	effect(function()
		local v7 = read(p)
		local v8 = read(p2)
		local v9 = v5()
		v2()
		local v10 = true
		cleanup(function()
			v10 = false
		end)
		task.spawn(function()
			if v6 ~= nil and v9 ~= v6 then
				Marketplace:RemoveCache(v7)
			end

			v6 = v9
			local success, result = pcall(function()
				return Marketplace:GetProductInfo(v7, v8)
			end)

			if not v10 then
				return
			end

			local v12

			if success then
				v12 = result.PriceInRobux
			end

			v4(v12)
		end)
	end)
	return v4
end

function v3.Text(p, value, p2: number?, flag: boolean?)
	local v5

	if p2 then
		v5 = `<font weight="{p2}">{v}</font>`
	else
		v5 = `{v}`
	end

	local v6 = failedGiftCount(p) -- equivalent call inferred; original call site unknown
	local v7 = marketplacePrice(p, value or "Product") -- equivalent call inferred; original call site unknown
	local v8 = Reactive.FromFlag("CustomProductPrices", {})
	local v9 = flag and " " or ""
	return derive(function()
		local v10 = v6()

		if v10 > 0 then
			return (`FREE ({v10})`)
		end

		local v11 = read(p)
		local v12 = v8()[tostring(v11)] or v7()

		if v12 then
			return (`{v5}{v9}{v3.Format(v12)}`)
		end

		return (`{v5}{v9}???`)
	end)
end

return table.freeze(v3)