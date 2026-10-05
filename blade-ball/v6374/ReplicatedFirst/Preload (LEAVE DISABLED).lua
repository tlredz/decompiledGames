local ContentProvider = game:GetService("ContentProvider")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = {
	"rbxassetid://15025384099",
	"rbxassetid://14785949877",
	"rbxassetid://14777379971",
	"rbxassetid://14776573336",
	"rbxassetid://14777126667",
	"rbxassetid://14777153621",
	"rbxassetid://14777155676",
	"rbxassetid://14122309120",
	"rbxassetid://14122309120",
	"rbxassetid://14158603441",
	"rbxassetid://14782680596",
	"rbxassetid://14777402592",
	"rbxassetid://15021781704",
	"rbxassetid://15039491191",
	"rbxassetid://14503071463",
	"rbxassetid://14503265310",
	"rbxassetid://14503178157"
}
local v2 = {}

for _, v3 in v do
	v2[v3] = true
end

task.spawn(ContentProvider.PreloadAsync, ContentProvider, v)
local _ = workspace.CurrentCamera

local function NeedsPreloading(_)
	return false
end

local function ProcessInstance(p) end

local descendants = {}

for _, descendant in playerGui:GetDescendants() do

end

task.spawn(ContentProvider.PreloadAsync, ContentProvider, descendants)
local lastTime = tick()
game.Loaded:Connect(function()
	if not localPlayer.Character then
		localPlayer.CharacterAdded:Wait()
	end

	local v3 = tick() - lastTime

	if v3 < 3 then
		task.wait(3 - v3)
	end
end)