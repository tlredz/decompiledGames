local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ConceptsLibrary = require(ReplicatedStorage.Modules.ConceptsLibrary)
require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local creditsPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("CreditsPlayerSlot")
local v = {
	{ "Tester", Color3.fromRGB(255, 215, 0) },
	{ "Moderator", Color3.fromRGB(255, 127, 0) },
	{ "Community Staff", Color3.fromRGB(127, 110, 255) }
}
local color = Color3.fromRGB(159, 25, 255)
Color3.fromRGB(46, 204, 113)
local v2 = {
	{
		20349956,
		"Nosniy",
		"Owner, 3D Artist",
		color
	},
	{
		15941965,
		"SenseiWarrior",
		"Owner, Programmer, UI/UX, SFX",
		color
	},
	{ 780350915, "nekoanims", "Animation" },
	{ 8034104, "GreatGuyBoom", "3D Artist, 2D Artist" },
	{ 1730213868, "Brian1KB", "Matchmaking, Technical Advisor" },
	{ 13108868, "ShadowTrojan", "3D Artist, 2D Artist, Wraps Artist" },
	{ 25056711, "PrimeVoxel", "Particles" },
	{ 42477697, "D_reamz", "Renders" },
	{ 945382833, "himochu", "2D Artist" },
	{ 113947873, "LiamGame09", "Wraps Artist" },
	{ 182316511, "BSlickMusic", "Music, SFX" },
	{ 1080973296, "xlISinner", "Anticheat" },
	{ 424377859, "Kurookku", "Technical Advisor" },
	{ 4444072910, "FluxxyBoiOfficial", "Bot Developer" },
	{ 274029164, "StaredSystemized", "Graphics" },
	{ 167445091, "SoftGB", "Graphics" }
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.PageContainer = self.PageFrame:WaitForChild("Container")
	self.CloseButton = self.PageContainer:WaitForChild("Close")
	self.List = self.PageContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.ConceptorsFrame = self.Container:WaitForChild("Conceptors")
	self.ConceptorsContainer = self.ConceptorsFrame:WaitForChild("Container")
	self.ConceptorsPlayersFrame = self.ConceptorsContainer:WaitForChild("Players")
	self.ConceptorsPlayersLayout = self.ConceptorsPlayersFrame:WaitForChild("Layout")
	self.ConceptorsRewardFrame = self.ConceptorsContainer:WaitForChild("Reward")
	self.TeamFrame = self.Container:WaitForChild("Team")
	self.TeamEmptyFrame = self.TeamFrame:WaitForChild("Empty")
	self.TeamContainer = self.TeamFrame:WaitForChild("Container")
	self.TeamPlayersFrame = self.TeamContainer:WaitForChild("Players")
	self.TeamPlayersLayout = self.TeamPlayersFrame:WaitForChild("Layout")
	self.ContributorsFrame = self.Container:WaitForChild("Contributors")
	self.ContributorsEmptyFrame = self.ContributorsFrame:WaitForChild("Empty")
	self.ContributorsContainer = self.ContributorsFrame:WaitForChild("Container")
	self.ContributorsPlayersFrame = self.ContributorsContainer:WaitForChild("Players")
	self.ContributorsPlayersLayout = self.ContributorsPlayersFrame:WaitForChild("Layout")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self:_Init()
	return self
end

function object:_Update()
	self.List.Size = UDim2.new(0.85, 0, 0, self.PageFrame.AbsoluteSize.Y * 0.75)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.ConceptorsFrame.Size = UDim2.new(1, 0, 0.1325, self.ConceptorsPlayersLayout.AbsoluteContentSize.Y)
end

function object._Generate(p)
	local v3 = ReplicatedStorage.Remotes.Misc.RequestGroupMembers:InvokeServer()
	local v4 = {}

	for _, v5 in pairs(v2) do
		table.insert(v4, v5[1])
	end

	for _, v5 in pairs(v) do
		for _, v6 in pairs(v3[v5[1]] or {}) do
			table.insert(v4, v6)
		end
	end

	for _, v5 in pairs(ConceptsLibrary.Leaderboard) do
		table.insert(v4, (tonumber(v5.key)))
	end

	local userInfos = ComplianceController:GetUserInfos(v4)
	local count = 0

	local function create_slot(p2, text, text2, imageColor, parent, p3)
		count += 1
		local clone = creditsPlayerSlot:Clone()
		clone.LayoutOrder = count
		clone.Description.Text = text2
		clone.Username.Text = text
		clone.Headshot.Image = p3 or string.format(CONSTANTS.HEADSHOT_IMAGE, p2)
		clone.Background.ImageColor3 = imageColor
		clone.Parent = parent
		return clone
	end

	for k, v5 in pairs(ConceptsLibrary.Leaderboard) do
		local userInfo = userInfos[v5.key]
		local text = userInfo and userInfo.Username and "@" .. userInfo.Username or "• • •"
		local text2 = string.format("%.1f", v5.value) .. " points"
		local key = v5.key
		local color2 = Color3.fromRGB(0, 0, 0)
		local conceptorsPlayersFrame = p.ConceptorsPlayersFrame
		count += 1
		local clone = creditsPlayerSlot:Clone()
		clone.LayoutOrder = count
		clone.Description.Text = text2
		clone.Username.Text = text
		clone.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, key)
		clone.Background.ImageColor3 = color2
		clone.Parent = conceptorsPlayersFrame
		clone.LayoutOrder = k
		clone.Button.Visible = true
		local v8 = v5
		clone.Button.MouseButton1Click:Connect(function()
			p.PromptSystem:Open("InspectConceptor", tonumber(v8.key), text)
		end)
		ButtonEffect:Add(clone.Button)
	end
end

function object:_Setup()
	self.TeamEmptyFrame.Visible = true
	self.TeamPlayersFrame.Visible = false
	self.ContributorsEmptyFrame.Visible = true
	self.ContributorsPlayersFrame.Visible = false
	RewardSlot.new({
		Name = ConceptsLibrary.CONCEPT_REWARD_NAME,
		Weapon = "IsRandom"
	}):SetParent(self.ConceptorsRewardFrame)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.PageFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_Update()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.ContributorsPlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self.ConceptorsPlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update()
	task.defer(self._Generate, self)
	ButtonEffect:Add(self.CloseButton)
end

return object._new()