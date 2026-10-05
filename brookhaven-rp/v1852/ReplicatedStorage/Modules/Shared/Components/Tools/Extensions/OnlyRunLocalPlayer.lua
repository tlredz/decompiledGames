local Players = game:GetService("Players")
return {
	ShouldConstruct = function(p)
		local now = os.time()
		p.Instance:GetAttribute("OwnerUserId")
		local ownerUserId

		repeat
			ownerUserId = p.Instance:GetAttribute("OwnerUserId")
			local now2 = os.time()
			task.wait(0.1)
		until ownerUserId == Players.LocalPlayer.UserId or now2 - now > 5

		return ownerUserId == Players.LocalPlayer.UserId
	end
}