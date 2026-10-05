local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Signal = require(game.ReplicatedStorage.Util.Signal)
local parentModule = require(script.Parent)
local Presets = require(script.Parent.Presets)
local v = {
	"construction",
	"presets",
	"execution",
	"duplicateSwap",
	"missingSwap"
}
return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v) }, function(p: string)
	local token = nil
	local v2 = false
	local v3 = {}
	local v4 = parentModule.new():Run(function(maid, p2)
		token = p2.Token
		maid:GiveTask(function()
			v2 = true
		end)

		if p == "missingSwap" then
			return
		end

		assert(maid:SwapEnvironment() == v3, "Transition returned the wrong environment")

		if p == "duplicateSwap" then
			maid:SwapEnvironment()
		end
	end)

	if p == "construction" then
		return parentModule.is(v4)
	end

	if p == "presets" then
		local default = Presets.get("Default")
		return default == Presets.get("FadeToBlack") and default == Presets.get("Fade to black")
	else
		local v5 = Maid.new()
		local signal = Signal()
		local success, result = pcall(function()
			return v4:_execute(function()
				return v3
			end, {
				Token = "runtime"
			}, signal.Event, v5)
		end)
		signal:Destroy()
		v5:DoCleaning()

		if p ~= "execution" then
			return not success and v2
		end

		if success then
			if result == v3 and token == "runtime" then
				success = v2
			else
				success = false
			end
		end

		return success
	end
end, #v + 1)