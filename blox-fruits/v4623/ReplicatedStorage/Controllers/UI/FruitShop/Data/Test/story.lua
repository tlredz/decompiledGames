local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local Display = require(game.ReplicatedStorage.Packages.Display)
local PriceService = require(game.ReplicatedStorage.PriceService)
local EconomyItem = require(game.ReplicatedStorage.Economy.EconomyItem)
return function(_)
	local v = {}
	task.spawn(function()
		table.insert(v, PriceService.init())
		local parentModule = require(script.Parent)
		print(Display.JSON.new():setUseMetatable(false):setOverride(function(p)
			local v2, _ = EconomyItem.Type.check(p)

			if v2 then
				return "\"EconomyItem\""
			end

			return nil
		end):setIndentWith("  "):build():display(parentModule["Dragon-Dragon"]))
	end)
	return function()
		for _, v2 in v do
			v2()
		end
	end
end