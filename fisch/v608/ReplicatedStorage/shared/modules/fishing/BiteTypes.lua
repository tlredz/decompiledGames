local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Signal"))
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require("./FishInstance/Types")
return {
	RodState = {
		Destroyed = 0,
		Unequipped = 1,
		Equipping = 2,
		Equipped = 3,
		Casting = 4,
		Searching = 5,
		Luring = 6,
		PreReel = 7,
		Reeling = 8,
		CatchFinished = 9
	}
}