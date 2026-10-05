local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local clans = ReplicatedStorage2.Controllers.Clans
local v5 = require3(clans.ClanController)
local v6 = require3(clans.ClanPageController)
local v7 = require3(clans.UI.ClanPopupController)
local v8 = require3(ReplicatedStorage2.Shared.ClansData)
local v9 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v10 = require3(ReplicatedStorage2.Shared.ClansLeagueData)
local v11 = require3(ReplicatedStorage2.Shared.ReplionUtils)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local clanGUI = v6.ClanGUI
local maid = v3.new()
local v12 = nil
local create = clanGUI.Pages.NoClan.Views.Create
local rightSide = create.RightSide
local _ = rightSide.Restrictions
local _ = rightSide.RequestAccess
local clanNameType = rightSide.ClanNameType
local clanTagType = rightSide.ClanTagType
local clanNoticeScroll = rightSide.ClanNoticeScroll
local type = clanNoticeScroll.Type
local createButtons = create.CreateButtons
local remoteFunction = v:RemoteFunction("CreateClan")
local remoteFunction2 = v:RemoteFunction("RequestRobuxCreation")
local v13 = {
	Title = "",
	Tag = "",
	Description = "This is a clan description!"
}
local clone = table.clone(v13)

-- equivalent calls inferred from this helper; original call sites unknown
local function textBoxItalicOnPlaceholder(instance)
	local function update()
		local v14 = instance
		local family = instance.FontFace.Family
		local weight = instance.FontFace.Weight
		local v15

		if #instance.Text > 0 then
			v15 = Enum.FontStyle.Normal
		else
			v15 = Enum.FontStyle.Italic
		end

		v14.FontFace = Font.new(family, weight, v15)
	end

	local _ = instance.FontFace
	local family = instance.FontFace.Family
	local weight = instance.FontFace.Weight
	local v14

	if #instance.Text > 0 then
		v14 = Enum.FontStyle.Normal
	else
		v14 = Enum.FontStyle.Italic
	end

	instance.FontFace = Font.new(family, weight, v14)
	instance:GetPropertyChangedSignal("Text"):Connect(update)
end

local ClanCreateController = {
	Init = function(_) end,
	UpdateUI = function(self)
		create.LeftSide.Icon.Image = v10.getEmblemFromElo(v10.INITIAL_ELO)
		clanNameType.Text = clone.Title
		type.Text = clone.Description
		clanTagType.Text = clone.Tag
	end,
	UpdateCreationData = function(self)
		clone.Title = clanNameType.Text
		clone.Description = type.Text
		clone.Tag = clanTagType.Text
	end,
	Setup = function(_) end
}

function ClanCreateController:Enable()
	if v12:Get("ClanId") ~= nil then
		maid:Clean()
		return
	end

	rightSide.ClanNameType.PlaceholderText = `Enter Name... (Max {v8.MaxTitleLength} characters)`
	create.Lock.Label.Text = `Reach {v8.CreationRequirements.Wins} Wins\nor {v8.CreationRequirements.TotalRobuxSpent} Robux spent`

	local function updateCreateButton()
		local v14 = (v12:Get("TotalStats.Wins") or 0) >= v8.CreationRequirements.Wins or (v12:Get("TotalRobuxSpent") or 0) >= v8.CreationRequirements.TotalRobuxSpent
		create.Lock.Visible = not v14
	end

	maid:Add(v12:OnChange("TotalStats.Wins", updateCreateButton))
	maid:Add(v12:OnChange("TotalRobuxSpent", updateCreateButton))
	task.defer(updateCreateButton)
	textBoxItalicOnPlaceholder(clanNameType) -- equivalent call inferred; original call site unknown
	textBoxItalicOnPlaceholder(type) -- equivalent call inferred; original call site unknown
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Font = type.FontFace

	local function update()
		local v16 = math.floor(clanNoticeScroll.AbsoluteSize.Y * 0.25)
		type.TextSize = v16
		local v17 = getTextBoundsParams
		local text

		if #type.Text > 0 then
			text = type.Text
		else
			text = type.PlaceholderText
		end

		v17.Text = text
		getTextBoundsParams.Size = v16
		getTextBoundsParams.Width = math.floor(type.AbsoluteSize.X)
		local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)
		type.Size = UDim2.new(0.9, 0, 0, (math.max(textBoundsAsync.Y, clanNoticeScroll.AbsoluteSize.Y)))
	end

	maid:Add(type:GetPropertyChangedSignal("Text"):Connect(update))
	maid:Add(clanNoticeScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
	task.defer(update)
	local v16 = nil
	local coins = createButtons.Coins
	maid:Add(coins.Coins.Activated:Connect(function()
		if not v7:Prompt({
			title = "Create Clan",
			text = `Spend {v4.ValueConvertor:AddCommas(v8.CreationPrice)} Coins to create a clan?`
		}) then
			return
		end

		self:UpdateCreationData()
		local v17, text = remoteFunction:InvokeServer(clone)

		if v17 then
			return
		end

		ReplicatedStorage2.Misc.error:Play()
		rightSide.ClanCreateError.Text = text
		local v19 = math.random()
		v16 = v19
		task.delay(5, function()
			if v16 == v19 then
				rightSide.ClanCreateError.Text = ""
			end
		end)
	end))

	local function robuxButtonClicked()
		self:UpdateCreationData()
		local v17, v18 = remoteFunction2:InvokeServer(clone)

		if v17 then
			return
		end

		ReplicatedStorage2.Misc.error:Play()
		rightSide.ClanCreateError.Text = v18 or ""
		local v19 = math.random()
		v16 = v19
		task.delay(5, function()
			if v16 == v19 then
				rightSide.ClanCreateError.Text = ""
			end
		end)
	end

	maid:Add(createButtons.Robux.Activated:Connect(robuxButtonClicked))
	maid:Add(createButtons.Free.Activated:Connect(robuxButtonClicked))
	v9(createButtons.Robux.Amount, 1701875588, "DevProduct", " %s")
	maid:Add(v11.observeReplionPath(v12, "FreeClanCreations", function(value)
		local v17 = value or 0
		createButtons.Free.Visible = v17 > 0
		createButtons.Robux.Visible = v17 <= 0
	end))
	maid:Add(v11.observeReplionPath(v12, "Credits", function(p)
		local active = p >= 10000
		coins.GroupTransparency = active and 0 or 0.75
		coins.Coins.Active = active
	end))
	maid:Add(v5:ObserveClan(function(_, _, p)
		if p then
			v6:OpenPage("Overview")
		end

		return function()
			clone = table.clone(v13)
			ClanCreateController:UpdateUI()
		end
	end))

	if create:FindFirstChild("CloseButton") then
		maid:Add(create.CloseButton.Activated:Connect(function()
			v6:Close()
		end))
	end

	ClanCreateController:UpdateUI()
end

function ClanCreateController:Start()
	v12 = v2.Client:WaitReplion("Data")
	v5:BindToVersion(v5.Versions.new, self.Enable, self)
	v11.observeReplionPath(v12, "ClanId", function()
		self:Enable()
	end)
end

return ClanCreateController