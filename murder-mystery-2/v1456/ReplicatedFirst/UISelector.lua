local value = script:WaitForChild("TestUI").Value
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local v = game.PlaceId == 119460199
local v2 = isStudio or game.Players.LocalPlayer.UserId == 1848960

if not (value and v2) then
	script.Loading.Enabled = true
	return
end

if v then
	if game.StarterGui:FindFirstChild("NewUI2025") then
		game.StarterGui.NewUI2025:Destroy()
	end

	if game.Players.LocalPlayer.PlayerGui:FindFirstChild("NewUI2025") then
		game.Players.LocalPlayer.PlayerGui.NewUI2025:Destroy()
	end
end

script.LoadingS2.Enabled = true