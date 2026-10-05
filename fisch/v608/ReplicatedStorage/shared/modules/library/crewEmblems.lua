local v = {
	{
		Id = "Fisch",
		Name = "Fisch",
		Icon = "rbxassetid://73496497242690"
	},
	{
		Id = "Heart",
		Name = "Heart",
		Icon = "rbxassetid://70822794044383"
	},
	{
		Id = "Cat Thing",
		Name = "Cat Thing",
		Icon = "rbxassetid://127681659622953"
	},
	{
		Id = "Crown",
		Name = "Crown",
		Icon = "rbxassetid://117357333504210"
	},
	{
		Id = "Shark",
		Name = "Shark",
		Icon = "rbxassetid://126474512279198"
	},
	{
		Id = "Skull n Bones",
		Name = "Skull n' Bones",
		Icon = "rbxassetid://95084778001301"
	},
	{
		Id = "Skeleton Fish",
		Name = "Skeleton Fish",
		Icon = "rbxassetid://72589762104093"
	},
	{
		Id = "Sailing Ship",
		Name = "Sailing Ship",
		Icon = "rbxassetid://113389978641683"
	},
	{
		Id = "Steering Wheel",
		Name = "Steering Wheel",
		Icon = "rbxassetid://105593729981917"
	},
	{
		Id = "Whale",
		Name = "Whale",
		Icon = "rbxassetid://121778319986315"
	},
	{
		Id = "Tsunami",
		Name = "Tsunami",
		Icon = "rbxassetid://81984209103600"
	},
	{
		Id = "Vortex",
		Name = "Vortex",
		Icon = "rbxassetid://90652884983642"
	},
	{
		Id = "Turtle",
		Name = "Turtle",
		Icon = "rbxassetid://80913440029361"
	},
	{
		Id = "Treasure Chest",
		Name = "Treasure Chest",
		Icon = "rbxassetid://122725363154729"
	},
	{
		Id = "Hook",
		Name = "Hook",
		Icon = "rbxassetid://89926366075611"
	},
	{
		Id = "Balloonfish",
		Name = "Balloonfish",
		Icon = "rbxassetid://115740165322997"
	},
	{
		Id = "Ghost",
		Name = "Ghost",
		Icon = "rbxassetid://74311369597312"
	},
	{
		Id = "Pirate Ship",
		Name = "Pirate Ship",
		Icon = "rbxassetid://114357616981771"
	},
	{
		Id = "Jellyfish",
		Name = "Jellyfish",
		Icon = "rbxassetid://101354440447515"
	},
	{
		Id = "Star",
		Name = "Star",
		Icon = "rbxassetid://137454120412305"
	},
	{
		Id = "Butterfly",
		Name = "Butterfly",
		Icon = "rbxassetid://89336651217287"
	},
	{
		Id = "Anchor",
		Name = "Anchor",
		Icon = "rbxassetid://115088888003782"
	},
	{
		Id = "Rubber Duck",
		Name = "Rubber Duck",
		Icon = "rbxassetid://80885692579991"
	},
	{
		Id = "Crab",
		Name = "Crab",
		Icon = "rbxassetid://81648753744534"
	},
	{
		Id = "Dino",
		Name = "Dino",
		Icon = "rbxassetid://88698537026739"
	},
	{
		Id = "Bat",
		Name = "Bat",
		Icon = "rbxassetid://80391013058244"
	},
	{
		Id = "Snail",
		Name = "Snail",
		Icon = "rbxassetid://75342388672186"
	},
	{
		Id = "Dove",
		Name = "Dove",
		Icon = "rbxassetid://97182727419583"
	},
	{
		Id = "Pelican",
		Name = "Pelican",
		Icon = "rbxassetid://127971390580417"
	},
	{
		Id = "Cheese",
		Name = "Cheese",
		Icon = "rbxassetid://106508611207865"
	},
	{
		Id = "Burger",
		Name = "Burger",
		Icon = "rbxassetid://119956497705216"
	},
	{
		Id = "Conch",
		Name = "Conch",
		Icon = "rbxassetid://113698715110076"
	}
}
local v2 = {}
local CrewEmblems = {}

for _, v3 in ipairs(v) do
	v2[v3.Id] = v3
end

CrewEmblems.DEFAULT_ID = v[1].Id

function CrewEmblems.GetAll()
	return v
end

function CrewEmblems.Get(p: string)
	return v2[p]
end

function CrewEmblems.IsValid(p: string)
	return v2[p] ~= nil
end

return CrewEmblems