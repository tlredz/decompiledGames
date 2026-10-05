local TopText = require(game.ReplicatedStorage.Client.UI.TopText)
task.wait(math.random(8, 12) * 0.2)

if script and script.Parent and script.Parent ~= nil then
	TopText.FadeOut(script.Parent.Parent.Parent, game.Players.LocalPlayer)
end