return function()
	local _ = game.ReplicatedStorage
	local _ = {
		"rbxassetid://9124108705",
		"rbxassetid://9124108519",
		"rbxassetid://9124108233",
		"rbxassetid://9124107993",
		"rbxassetid://9124107862",
		"rbxassetid://9124107682",
		"rbxassetid://9124107682",
		"rbxassetid://9124107682",
		"rbxassetid://9124106995",
		"rbxassetid://9124106734"
	}
	script.Parent.big:Emit(1)
	script.Parent.Ring:Emit(1)
	script.Parent.Spark:Emit(2)
	script.Parent.Ball:Emit(1)
end