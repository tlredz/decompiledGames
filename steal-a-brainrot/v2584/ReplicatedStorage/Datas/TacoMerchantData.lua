local v = {
	Brainrots = {
		{
			Brainrot = "Burrito Bat",
			TacoPrice = 100,
			ProductId = 3708675876
		},
		{
			Brainrot = "Tacoturbo Tacorito",
			TacoPrice = 1000,
			ProductId = 3708675878
		},
		{
			Brainrot = "Nachorilla",
			TacoPrice = 5000,
			ProductId = 3708675879
		},
		{
			Brainrot = "Sammyni Truckini",
			TacoPrice = 10000,
			ProductId = 3708675880
		}
	}
}
table.freeze(v.Brainrots)
return table.freeze(v)