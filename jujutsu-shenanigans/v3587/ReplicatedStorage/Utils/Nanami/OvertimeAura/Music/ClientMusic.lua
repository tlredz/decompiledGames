local character = game.Players.LocalPlayer.Character

if not (character and script.Parent:IsDescendantOf(character)) then
	script.Parent.RollOffMinDistance = 0
	script.Parent.RollOffMaxDistance = 0
end