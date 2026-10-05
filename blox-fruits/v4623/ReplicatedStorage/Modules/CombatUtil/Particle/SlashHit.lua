local _ = {
	Strike = {
		"rbxassetid://2453604562",
		"rbxassetid://2453604851",
		"rbxassetid://2453605107",
		"rbxassetid://2453605387",
		"rbxassetid://2453605589"
	}
}
return {
	playAt = function(position, p2)
		local effect = game.ReplicatedStorage:FindFirstChild("Effect")

		if effect then
			local module = require(effect)
			module.new("Hit.Combat"):replicate({
				Position = position,
				Type = p2
			})
		end
	end
}