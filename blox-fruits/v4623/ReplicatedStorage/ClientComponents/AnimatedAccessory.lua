local Component = require(game.ReplicatedStorage.Modules.Component)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local v = Component.new({
	Tag = "AnimatedAccessory"
})

function v:Construct()
	self._trove = Trove.new()
end

function v.Start(p)
	local name = p.Instance.Name
	local effectType = p.Instance:GetAttribute("EffectType")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tryLoadModule(name2)
		local child = script:FindFirstChild(name2)

		if child then
			local module = require(child)

			if module and type(module) == "table" and module.Start then
				task.defer(module.Start, p)
			end
		end
	end

	tryLoadModule(name) -- equivalent call inferred; original call site unknown
	local child = typeof(effectType) == "string" and script:FindFirstChild(effectType)

	if child then
		local module = require(child)

		if module and type(module) == "table" and module.Start then
			task.defer(module.Start, p)
		end
	end
end

function v:Stop()
	if self._trove then
		self._trove:Destroy()
		self._trove = nil
	end
end

return v