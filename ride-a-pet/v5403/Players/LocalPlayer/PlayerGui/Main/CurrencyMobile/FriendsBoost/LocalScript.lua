local parent = script.Parent
local friendsPlaying = game.Players.LocalPlayer:WaitForChild("NoSaveData"):WaitForChild("FriendsPlaying")

function Update()
	parent.Text = string.format("Friend Boost: +%i%%", friendsPlaying.Value * 10)
end

Update()
friendsPlaying:GetPropertyChangedSignal("Value"):Connect(Update)