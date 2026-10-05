local Component = require(game.ReplicatedStorage.Modules.Component)
local Effect = require(game.ReplicatedStorage.Effect)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local v = Component.new({
	Tag = "BannerItemAura",
	Ancestors = { workspace }
})

function v:Construct()
	self.Maid = Trove.new()
end

function v.Start(p)
	p.Maid:Add(function()
		Effect.new("Auras.PurpleAura"):play({
			Stage = 0,
			Character = p.Instance,
			Player = p.Instance
		})
	end)
	Effect.new("Auras.PurpleAura"):play({
		Stage = 1,
		Character = p.Instance,
		Player = p.Instance
	})
end

function v.Stop(p)
	p.Maid:Destroy()
end

return v