return function(registry)
	registry:RegisterType("mathOperator", registry.Cmdr.Util.MakeEnumType("Math Operator", {
		{
			Name = "+",
			Perform = function(p, p2)
				return p + p2
			end
		},
		{
			Name = "-",
			Perform = function(p, p2)
				return p - p2
			end
		},
		{
			Name = "*",
			Perform = function(p, p2)
				return p * p2
			end
		},
		{
			Name = "/",
			Perform = function(p, p2)
				return p / p2
			end
		},
		{
			Name = "**",
			Perform = function(p, p2)
				return p ^ p2
			end
		},
		{
			Name = "%",
			Perform = function(p, p2)
				return p % p2
			end
		}
	}))
end