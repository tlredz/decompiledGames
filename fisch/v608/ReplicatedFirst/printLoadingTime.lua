local lastTime = os.clock()
local loading = script.Parent:WaitForChild("loading")
local Players = game:GetService("Players")
loading.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
game.Loaded:Wait()
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	print((`game took {string.format("%.2f", (os.clock() - lastTime) * 1000)} to load`))
end