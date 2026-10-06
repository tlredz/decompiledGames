local humanoid = script.Parent:WaitForChild("Humanoid")
game:GetService("RunService")
_G.PU.GetAnimator(humanoid):LoadAnimation(game.ReplicatedStorage.Chest.Animation.PhoenixPhoenix.PhoenixFullIdle):Play()