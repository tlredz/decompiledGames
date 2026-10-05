local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
return {
	Name = "Eggcelent Decorator",
	TowerName = "Brusha",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Easter2026_W3,
	Easter = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://87021638210313",
		Run = "rbxassetid://92652433020704",
		Quirk = "rbxassetid://140672190679079",
		PaintStart = "rbxassetid://97174260659481",
		PaintEnd = "rbxassetid://129092207051880",
		Paint = "rbxassetid://136989683733742",
		Idle = "rbxassetid://120995305446330",
		Decode = "rbxassetid://137606735770200"
	},
	FaceTextures = {
		Normal = "rbxassetid://109687209534598",
		Blink = "rbxassetid://118895067492689",
		Hurt = "rbxassetid://117555421503312"
	},
	PaintInfo = {
		Colors = { Color3.fromRGB(255, 179, 179), Color3.fromRGB(134, 231, 223), Color3.fromRGB(208, 240, 114) },
		Sequence = {
			{
				Image = "rbxassetid://115375374041850",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://79935902558187",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://76483377131033",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://94618820036001",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://85529881803035",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://135291642950117",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://122372255877311",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://128256375520404",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(parent, instance)
		parent:SetAttribute("PaintingTexture", "rbxassetid://87556173251321")
		local Universe = require(ReplicatedStorage.SharedUtils.Universe)

		if Universe:IsLobby() then
			return
		end

		local clone = instance:WaitForChild("RingRangerParent"):Clone()
		local clone2 = instance:WaitForChild("QuickLinks"):Clone()
		local clone3 = instance:WaitForChild("RingRanger"):Clone()
		local clone4 = instance:WaitForChild("Notebook_Geo"):WaitForChild("Decal"):Clone()
		local primaryPart = instance.PrimaryPart
		local objectSpace = clone:GetPivot():ToObjectSpace(primaryPart.CFrame)
		local objectSpace2 = clone3:GetPivot():ToObjectSpace(primaryPart.CFrame)
		local clone5 = primaryPart:WaitForChild("RootPartAttachment"):Clone()
		local primaryPart2 = parent.PrimaryPart
		clone:PivotTo(primaryPart2.CFrame * objectSpace)
		clone3:PivotTo(primaryPart2.CFrame * objectSpace2)
		clone5.Parent = primaryPart2
		clone4.Parent = parent:WaitForChild("Notebook_Geo")
		clone4.Texture = "rbxassetid://87556173251321"
		clone.RingRanger.WeldConstraint.Part1 = primaryPart2
		clone3.WeldConstraint.Part1 = primaryPart2
		clone3.AlignPosition.Attachment1 = clone5
		clone.Parent = parent
		clone3.Parent = parent
		local ringRangerModel = clone2:WaitForChild("RingRangerModel")
		ringRangerModel.Value = clone3
		local notebookArtImage = clone2:WaitForChild("NotebookArtImage")
		notebookArtImage.Value = clone4
		clone2.Parent = parent
	end
}