local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mutations = require(ReplicatedStorage.Datas.Mutations)
local v = {
	{
		Price = 25,
		Zone = "Spawn",
		IslandIcon = "rbxassetid://77579120948430",
		JumpIcon = "rbxassetid://77579120948430"
	},
	{
		Price = 50,
		Zone = "Normal",
		IslandIcon = Mutations.Rainbow.Icon,
		JumpIcon = "rbxassetid://77579120948430"
	},
	{
		Price = 100,
		Zone = "Candy",
		IslandIcon = Mutations.Candy.Icon,
		JumpIcon = "rbxassetid://77579120948430"
	},
	{
		Price = 250,
		Zone = "Lava",
		IslandIcon = Mutations.Lava.Icon,
		JumpIcon = "rbxassetid://77579120948430"
	},
	{
		Price = 500,
		Zone = "Galaxy",
		IslandIcon = Mutations.Galaxy.Icon,
		JumpIcon = "rbxassetid://77579120948430"
	},
	{
		Price = 750,
		Zone = "Divine",
		IslandIcon = Mutations.Divine.Icon,
		JumpIcon = "rbxassetid://77579120948430"
	}
}
return table.freeze(v)