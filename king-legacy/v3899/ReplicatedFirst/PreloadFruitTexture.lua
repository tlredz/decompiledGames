local ContentProvider = game:GetService("ContentProvider")
local FruitList = require(game.ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules").FruitList)

for _, v in pairs(FruitList) do
	ContentProvider:Preload(v)
end

local v = {
	"rbxassetid://136813968054338",
	"rbxassetid://71244686317412",
	"rbxassetid://117627008120967",
	"rbxassetid://127597031167791",
	"rbxassetid://118235939616382",
	"rbxassetid://98739255126595",
	"rbxassetid://102724678641999",
	"rbxassetid://139110118389017",
	"rbxassetid://82989554925438",
	"rbxassetid://116225187246481",
	"rbxassetid://122731425590847",
	"rbxassetid://102415743031508",
	"rbxassetid://101580958812781",
	"rbxassetid://101870918672840"
}

for _, v2 in pairs(v) do
	ContentProvider:Preload(v2)
end

table.clear(v)