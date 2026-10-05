local warn2 = warn

local function fn(...) end

local function fn2(...) end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function isliveserver()
	local RunService = game:GetService("RunService")

	if RunService:IsStudio() or game.PrivateServerOwnerId ~= 0 then
		return true
	end

	return workspace:GetAttribute("CustomServerOwnerId") ~= nil or workspace:GetAttribute("VIPServer") ~= nil
end

if not isliveserver() then
	local v = os.clock() + 10

	repeat
		task.wait(1)
	until isliveserver() or v < os.clock()

	if not isliveserver() then
		task.delay(15, function()
			script.Parent:Destroy()
		end)
		return
	end
end

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local globalCatalogueHandler = ReplicatedStorage:WaitForChild("Ranked", 10):FindFirstChild("GlobalCatalogueHandler")
local receiver = ReplicatedStorage:WaitForChild("Ranked", 10):FindFirstChild("Receiver")
local __TSB_GLOBAL_CATALOGUE_BIND_SCRIPT = _G.__TSB_GLOBAL_CATALOGUE_BIND_SCRIPT

if __TSB_GLOBAL_CATALOGUE_BIND_SCRIPT == script or typeof(__TSB_GLOBAL_CATALOGUE_BIND_SCRIPT) == "Instance" and __TSB_GLOBAL_CATALOGUE_BIND_SCRIPT.Parent ~= nil then
	return
end

_G.__TSB_GLOBAL_CATALOGUE_BIND_SCRIPT = script
_G.__TSB_GLOBAL_CATALOGUE_BIND_ACTIVE = true
_G.__TSB_GLOBAL_CATALOGUE_UI_OPEN = false
local parent = script.Parent
task.delay(44, function()
	if game.PrivateServerOwnerId == 0 and workspace:GetAttribute("CustomServerOwnerId") == nil and workspace:GetAttribute("VIPServer") == nil then
		local RunService = game:GetService("RunService")

		if not RunService:IsStudio() then
			parent:Destroy()
		end
	end
end)
local mainPanel = parent:WaitForChild("MainPanel")
local header = mainPanel:WaitForChild("Header")
local countBadge = header:WaitForChild("CountBadge")
countBadge.Visible = false
local closeBtn = header:WaitForChild("CloseBtn")
local refresh = header:WaitForChild("Refresh")
local refreshBtn = header:FindFirstChild("RefreshBtn")

if refreshBtn and refreshBtn ~= refresh then
	refreshBtn:Destroy()
end

local tabBar = mainPanel:WaitForChild("TabBar")
local contentArea = mainPanel:WaitForChild("ContentArea")
local v = tonumber(localPlayer.UserId) == 3350014406
local v2 = ({
	[77342385] = true,
	[9684094059] = true,
	[41022405] = true,
	[60862201] = true,
	[117723419] = true,
	[156112298] = true,
	[38307780] = true,
	[747447782] = true,
	[56721213] = true,
	[1974829690] = true,
	[292707170] = true,
	[1526501409] = true,
	[422755031] = true,
	[971193650] = true,
	[1266437961] = true,
	[66105529] = true,
	[221681529] = true,
	[1001242712] = true,
	[2544664287] = true,
	[1446694201] = true,
	[3350014406] = true,
	[1259898795] = true,
	[123755248] = true,
	[111471062] = true,
	[190568694] = true,
	[2480843106] = true
})[tonumber(localPlayer.UserId) or 0] == true
refreshBtn = {
	"BROWSE",
	"LEADERBOARD",
	"VERIFIED",
	"ADDED_TO_PS",
	"UPLOAD",
	"MY_UPLOADS"
}
local tabs = {}

for _, v4 in ipairs(refreshBtn) do
	tabs[v4] = {
		btn = tabBar:WaitForChild("Tab_" .. v4),
		frame = nil
	}
end

function applyPanelTabBarCanvasPreset()
	if not (tabBar and tabBar:IsA("ScrollingFrame") and (tabs and tabs.PANEL)) then
		return
	end

	tabBar.ScrollingDirection = Enum.ScrollingDirection.X
	tabBar.AutomaticCanvasSize = Enum.AutomaticSize.None
	tabBar.CanvasSize = UDim2.new(1.15, 0, 0, 0)
end

if tabBar and tabBar:IsA("ScrollingFrame") then
	tabBar.ScrollBarImageTransparency = 1
	tabBar.ScrollBarThickness = 0
	tabBar.VerticalScrollBarInset = Enum.ScrollBarInset.None
	tabBar.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	tabBar:GetPropertyChangedSignal("ScrollBarImageTransparency"):Connect(function()
		if tabBar.ScrollBarImageTransparency ~= 1 then
			tabBar.ScrollBarImageTransparency = 1
		end
	end)
end

tabs.BROWSE.frame = contentArea:WaitForChild("BrowseTab")
tabs.LEADERBOARD.frame = contentArea:WaitForChild("LeaderboardTab")
tabs.VERIFIED.frame = contentArea:WaitForChild("VerifiedTab")
tabs.ADDED_TO_PS.frame = contentArea:WaitForChild("AddedToPSTab")
tabs.UPLOAD.frame = contentArea:WaitForChild("UploadTab")
tabs.MY_UPLOADS.frame = contentArea:WaitForChild("MyUploadsTab")

function ensurePanelTabButton()
	local tab_PANEL = tabBar:FindFirstChild("Tab_PANEL")

	if tab_PANEL and tab_PANEL:IsA("TextButton") then
		return tab_PANEL
	end

	local btn = tabs.MY_UPLOADS.btn
	local clone = btn:Clone()
	clone.Name = "Tab_PANEL"
	clone.Text = "PANEL"
	clone.LayoutOrder = (tonumber(btn.LayoutOrder) or 0) + 1
	local uploadCount = clone:FindFirstChild("UploadCount")

	if uploadCount then
		uploadCount:Destroy()
	end

	clone.Parent = tabBar
	task.defer(applyPanelTabBarCanvasPreset)
	return clone
end

function ensurePanelTabFrame()
	local panelTab = contentArea:FindFirstChild("PanelTab")

	if panelTab and panelTab:IsA("Frame") then
		return panelTab
	end

	local frame = Instance.new("Frame")
	frame.Name = "PanelTab"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = contentArea
	return frame
end

if v then
	tabs.PANEL = {
		btn = ensurePanelTabButton(),
		frame = ensurePanelTabFrame()
	}
	table.insert(refreshBtn, "PANEL")
	applyPanelTabBarCanvasPreset()
end

searchInput = tabs.BROWSE.frame:WaitForChild("SearchInput")
sortRow = tabs.BROWSE.frame:WaitForChild("SortRow")
catRow = tabs.BROWSE.frame:WaitForChild("CatRow")
resultsRow = tabs.BROWSE.frame:WaitForChild("ResultsRow")
resultsCount = resultsRow:WaitForChild("ResultsCount")
pageInfoLabel = resultsRow:WaitForChild("PageInfo")
cardGrid = tabs.BROWSE.frame:WaitForChild("CardGrid")
local uIListLayout = cardGrid:FindFirstChildOfClass("UIListLayout") or cardGrid:FindFirstChildOfClass("UIGridLayout")

if cardGrid:IsA("ScrollingFrame") and uIListLayout then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCardGridCanvas()
		cardGrid.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y)
	end

	updateCardGridCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCardGridCanvas)
end

noResults = tabs.BROWSE.frame:WaitForChild("NoResults")
clearAllBtn = noResults:WaitForChild("ClearAllBtn")
pageBar = tabs.BROWSE.frame:WaitForChild("PageBar")
pageInner = pageBar:WaitForChild("PageInner")
pgFirst = pageInner:WaitForChild("PgFirst")
pgPrev = pageInner:WaitForChild("PgPrev")
pgNext = pageInner:WaitForChild("PgNext")
pgLast = pageInner:WaitForChild("PgLast")
pgJumpInput = pageInner:WaitForChild("PgJumpInput")
local lbSubBar = tabs.LEADERBOARD.frame:WaitForChild("LbSubBar")
local lbSub_TOP_CREATORS = lbSubBar:WaitForChild("LbSub_TOP_CREATORS")
local lbSub_TOP_CHARS = lbSubBar:WaitForChild("LbSub_TOP_CHARS")
local lbScroll = tabs.LEADERBOARD.frame:WaitForChild("LbScroll")
local uIListLayout2 = lbScroll:FindFirstChildOfClass("UIListLayout")

if lbScroll:IsA("ScrollingFrame") and uIListLayout2 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateLbCanvas()
		lbScroll.CanvasSize = UDim2.new(0, 0, 0, uIListLayout2.AbsoluteContentSize.Y)
	end

	updateLbCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLbCanvas)
end

local verifiedScroll = tabs.VERIFIED.frame:WaitForChild("VerifiedScroll")
local uIListLayout3 = verifiedScroll:FindFirstChildOfClass("UIListLayout")

if verifiedScroll:IsA("ScrollingFrame") and uIListLayout3 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVCanvas()
		verifiedScroll.CanvasSize = UDim2.new(0, 0, 0, uIListLayout3.AbsoluteContentSize.Y)
	end

	updateVCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout3:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateVCanvas)
end

local verifiedTemplate = script:WaitForChild("VerifiedTemplate")
local addedTitle = tabs.ADDED_TO_PS.frame:WaitForChild("AddedHeader"):WaitForChild("AddedTitle")
local searchbox = tabs.ADDED_TO_PS.frame:FindFirstChild("Searchbox", true)
local addedScroll = tabs.ADDED_TO_PS.frame:WaitForChild("AddedScroll")
local uIListLayout4 = addedScroll:FindFirstChildOfClass("UIListLayout")

if addedScroll:IsA("ScrollingFrame") and uIListLayout4 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAddedScrollCanvas()
		addedScroll.CanvasSize = UDim2.new(0, 0, 0, uIListLayout4.AbsoluteContentSize.Y)
	end

	updateAddedScrollCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout4:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateAddedScrollCanvas)
end

local addedEmpty = addedScroll:WaitForChild("AddedEmpty")
local addedtemplate = script:WaitForChild("addedtemplate")
local templateadd2 = script:WaitForChild("templateadd2")
local uploadSelect = tabs.UPLOAD.frame:WaitForChild("UploadSelect")
local uploadCharScroll = uploadSelect:WaitForChild("UploadCharScroll")
local uIListLayout5 = uploadCharScroll:FindFirstChildOfClass("UIListLayout")

if uploadCharScroll:IsA("ScrollingFrame") and uIListLayout5 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateUploadCharScrollCanvas()
		uploadCharScroll.CanvasSize = UDim2.new(0, 0, 0, uIListLayout5.AbsoluteContentSize.Y)
	end

	updateUploadCharScrollCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout5:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateUploadCharScrollCanvas)
end

local dropdownHolder = uploadCharScroll:FindFirstChild("DropdownHolder")
lbSubBar = dropdownHolder and dropdownHolder:FindFirstChild("dropdownholdertemplate")

if lbSubBar then
	lbSubBar.Visible = false
	lbSubBar.Parent = script
end

local uIListLayout6 = dropdownHolder and dropdownHolder:IsA("ScrollingFrame") and (dropdownHolder:FindFirstChildOfClass("UIListLayout") or dropdownHolder:FindFirstChildOfClass("UIGridLayout"))

if uIListLayout6 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateDropdownHolderCanvas()
		dropdownHolder.CanvasSize = UDim2.new(0, 0, 0, uIListLayout6.AbsoluteContentSize.Y)
	end

	updateDropdownHolderCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropdownHolderCanvas)
end

local uploadConfirm = tabs.UPLOAD.frame:WaitForChild("UploadConfirm")
backBtn = uploadConfirm:WaitForChild("BackBtn")
uploadPreviewCard = uploadConfirm:FindFirstChild("CardTemplate")
descInput = uploadConfirm:WaitForChild("DescInput")
uploadImageInput = nil
publishBtn = uploadConfirm:WaitForChild("PublishBtn")
confirmWarn = uploadConfirm:WaitForChild("ConfirmWarning")
confirmPublishBtn = uploadConfirm:FindFirstChild("ConfirmPublishBtn")
cancelPublishBtn = uploadConfirm:FindFirstChild("CancelPublishBtn")
uploadCharTemplate = script:FindFirstChild("MyUploadTemplate") or tabs.UPLOAD.frame:WaitForChild("UploadCharTemplate")
leaderboardProfileTemplate = script:WaitForChild("LeaderboardTemplate", 10)
local extratemplate = script:WaitForChild("extratemplate")
local lbItemTemplate = script:WaitForChild("LbItemTemplate")
local myUploadsTitle = tabs.MY_UPLOADS.frame:WaitForChild("MyUploadsHeader"):WaitForChild("MyUploadsTitle")
local myUploadsScroll = tabs.MY_UPLOADS.frame:WaitForChild("MyUploadsScroll")
local uIListLayout7 = myUploadsScroll:FindFirstChildOfClass("UIListLayout") or myUploadsScroll:FindFirstChildOfClass("UIGridLayout")

if myUploadsScroll:IsA("ScrollingFrame") and uIListLayout7 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateMyUploadsScrollCanvas()
		myUploadsScroll.CanvasSize = UDim2.new(0, 0, 0, uIListLayout7.AbsoluteContentSize.Y)
	end

	updateMyUploadsScrollCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout7:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateMyUploadsScrollCanvas)
end

script:FindFirstChild("myuploadscardtemplate")
local cardTemplate = script:WaitForChild("CardTemplate")
local userTemplate = script:FindFirstChild("UserTemplate") or cardTemplate
local charDetailOverlay = mainPanel:WaitForChild("CharDetailOverlay")
local RequestHelper = require(script.RequestHelper)
local detailCardApi = RequestHelper.newDetailCardApi({
	overlay = charDetailOverlay,
	warnFn = fn
})
detailCard = detailCardApi.defaultCard
characterDetailCard = detailCardApi.characterCard
local dataHolder = characterDetailCard and characterDetailCard:FindFirstChild("DataHolder")
local uIListLayout8 = dataHolder and dataHolder:FindFirstChildOfClass("UIListLayout")

if dataHolder and dataHolder:IsA("ScrollingFrame") and uIListLayout8 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCharacterDetailDataHolderCanvas()
		dataHolder.CanvasSize = UDim2.new(0, 0, 0, uIListLayout8.AbsoluteContentSize.Y)
	end

	updateCharacterDetailDataHolderCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout8:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCharacterDetailDataHolderCanvas)
end

detClose = nil
detFav = nil
detAddedBadge = nil
detScroll = nil
detTitleSec = nil
detTypeBadge = nil
detCharName = nil
detSubtitle = nil
detCreatorRow = nil
detCreatorBtn = nil
detTimeLabel = nil
detRobuxLabel = nil
detTagRow = nil
detDesc = nil
detStats = nil
detVoteRow = nil
detLikeBtn = nil
detDislikeBtn = nil
detActSec = nil
detAddPSBtn = nil
detRemovePSBtn = nil
detReportBtn = nil
detConfirmReport = nil
detMovesSec = nil
local creatorProfileOverlay = mainPanel:WaitForChild("CreatorProfileOverlay")
creatorCard = creatorProfileOverlay:WaitForChild("CreatorCard")
crHeader = creatorCard:WaitForChild("CreatorHeader")
crHeaderFrame = crHeader:FindFirstChild("Frame") or crHeader:FindFirstChildWhichIsA("Frame")

if crHeaderFrame then
	lbSubBar = crHeaderFrame:FindFirstChild("ImageLabel", true) or crHeaderFrame:FindFirstChildWhichIsA("ImageLabel") or nil
else
	lbSubBar = nil
end

crSnapshotImage = lbSubBar
crNameLabel = crHeaderFrame and crHeaderFrame:FindFirstChild("CreatorName", true) or crHeader:FindFirstChild(
	"CreatorName",
	true
)
crExtraData = crHeader:FindFirstChild("extradata", true)
crStatsRow = crHeader:FindFirstChild("CreatorStats") or creatorCard:FindFirstChild("CreatorStats", true)

function crStatValue(childName)
	local child = crStatsRow and crStatsRow:FindFirstChild(childName)
	return child and child:FindFirstChild("value") or nil
end

crCreationsLabel = crStatValue("creations")
crDownloadsLabel = crStatValue("downloads")
crFavouritesLabel = crStatValue("favourites")
crLikesLabel = crStatValue("likes")
crClose = crHeader:WaitForChild("closebtn")
crCharScroll = creatorCard:FindFirstChild("realframe")
local uIListLayout9 = crCharScroll and crCharScroll:FindFirstChildOfClass("UIListLayout")

if crCharScroll and crCharScroll:IsA("ScrollingFrame") and uIListLayout9 then
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCrCanvas()
		crCharScroll.CanvasSize = UDim2.new(0, 0, 0, uIListLayout9.AbsoluteContentSize.Y)
	end

	updateCrCanvas() -- equivalent call inferred; original call site unknown
	uIListLayout9:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCrCanvas)
end

creatorCardTemplate = script:FindFirstChild("CREATORCARDTEMPLATE") or cardTemplate
crCatRow = creatorCard:FindFirstChild("Frame")
crSearchBox = creatorCard:FindFirstChild("Searchbox", true)
local tagPickerOverlay = mainPanel:WaitForChild("TagPickerOverlay")
tagPickerCard = tagPickerOverlay:WaitForChild("TagPickerCard")
tagPickerSearch = tagPickerCard:WaitForChild("TagPickerSearch")
tagPickerScroll = tagPickerCard:WaitForChild("TagPickerScroll")
tagPickerDone = tagPickerCard:WaitForChild("TagPickerDone")
local toast = mainPanel:WaitForChild("Toast")

function rgb(p, p2, p3)
	return Color3.fromRGB(p, p2, p3)
end

local v4 = { rgb(255, 200, 60), rgb(192, 192, 192), rgb(180, 120, 60) }
local categoryColors = {
	Character = rgb(200, 60, 60),
	Map = rgb(76, 152, 112),
	Move = rgb(91, 142, 240),
	AwakenMove = rgb(120, 100, 255),
	SpawnAnim = rgb(180, 130, 50),
	AwakenAnim = rgb(200, 60, 60),
	M1Style = rgb(160, 80, 200),
	WallCombo = rgb(60, 170, 170),
	ForwardDash = rgb(224, 120, 48),
	Effect = rgb(255, 120, 120),
	CreatedAnim = rgb(110, 190, 220)
}

if not shared._catSfx then
	function shared._catSfx(p)
		if type(shared.sfx) == "function" then
			pcall(function()
				shared.sfx({
					SoundId = "rbxassetid://" .. tostring(p),
					Parent = workspace,
					Volume = 0.5
				}):Play()
			end)
		end
	end
end

local v6 = 0
local object = setmetatable({}, {
	__mode = "k"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function playSfx()
	local now = tick()

	if now - v6 < 0.06 then
		return
	end

	v6 = now
	shared._catSfx(6895079853)
end

local function hookSfx(guiObject)
	if object[guiObject] then
		return
	end

	if guiObject:IsA("TextButton") or guiObject:IsA("ImageButton") then
		object[guiObject] = true
		guiObject.MouseButton1Click:Connect(playSfx)
	elseif guiObject:IsA("Frame") and guiObject.Active then
		object[guiObject] = true
		guiObject.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				playSfx() -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

for _, descendant in ipairs(mainPanel:GetDescendants()) do
	hookSfx(descendant)
end

mainPanel.DescendantAdded:Connect(hookSfx)
local v7 = "BROWSE"
local v8 = "liked"
local v9 = "ALL"
local tags = {}
local page = 1
local v12 = 1
local v13 = 0
local v14 = {}
local creators = {}
local addedToPS = {}
local v16 = {}
local v17 = {}
local v18 = {}
local v19 = {}
local v20 = ""
local v21 = {}
local text = nil
local entryById = nil
local ids = {}
local v23 = {}
local v24 = nil
local v25 = "TOP_CREATORS"
local flag = false
local fn3
local v26 = nil
local fn4
local flag2 = false
local count = 0
local v27 = {
	panel = nil,
	editToggleBtn = nil,
	editToggleBtnOnTextColor = nil,
	importCodeLabel = nil,
	allowEditing = true,
	latestImportCode = "",
	importCodePending = false,
	importCodeRequestToken = 0,
	importCodesBySourceKey = {},
	publishBtnIdleText = nil,
	publishBtnIdleAutoButtonColor = nil
}
local v28 = rgb(200, 60, 60)
local fn5
local count2 = 0
local addInFlight = {}
local v30 = {}
local v31 = {}
local v32 = {}
local v33 = {}
local v34 = {}
local v35 = {}
local v36 = {}
local v37 = {}
local v38 = {}
local v39 = 0
local v40 = {}
local v41 = {
	browse = 0,
	browseStats = 0,
	leaderboard = 0,
	added = 0,
	verified = 0,
	mine = 0,
	openLoop = 0
}
local listCacheState = {
	timestamps = {
		mine = 0,
		added = 0,
		verified = 0
	},
	ttls = {
		mine = 5,
		added = 5,
		verified = 5
	},
	signatures = {
		mine = "",
		added = "",
		verified = ""
	},
	lastRendered = {
		mine = nil,
		added = nil,
		verified = nil
	},
	addedEntries = {},
	verifiedRows = {},
	localCharactersRaw = nil,
	localCharactersDecoded = {}
}
local v43 = {}
local rows = {}
local v44 = {}
local v45 = nil
local v46 = ""
local now = 0
local v47 = 0
local v48 = {
	items = 0,
	creators = 0,
	tips = 0
}
local v49 = {
	activeItemsSectionType = nil,
	lastRenderedItemsSectionType = nil,
	itemsLimitPerType = 300,
	itemsRenderLimit = 250,
	creatorsLimit = 1000,
	verifiedLimit = 500
}
setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local v50 = {}
local v51 = {}
local v52 = {}
local v53 = {}

function rememberEntryById(p)
	if typeof(p) ~= "table" then
		return
	end

	local id = tostring(p.id or "")

	if id == "" then
		return
	end

	entryById[id] = p

	if v23[id] ~= true then
		v23[id] = true
		table.insert(ids, id)
	end

	while #ids > RequestHelper.ENTRY_BY_ID_MAX do
		local v54 = table.remove(ids, 1)

		if not (v54 and v23[v54] == true) then
			continue
		end

		v23[v54] = nil
		entryById[v54] = nil
		v17[v54] = nil
		addedToPS[v54] = nil
		v18[v54] = nil
	end
end

function hasFreshListCache(p)
	local v54 = tonumber(listCacheState.timestamps[p]) or 0
	local v55 = tonumber(listCacheState.ttls[p]) or 0
	return v54 > 0 and v55 > 0 and os.clock() - v54 < v55
end

function invalidateListCache(p)
	if p == nil then
		for k in pairs(listCacheState.timestamps) do
			invalidateListCache(k)
		end
	else
		listCacheState.timestamps[p] = 0
		listCacheState.lastRendered[p] = nil
	end
end

function createSignatureState()
	return {
		hashA = 2166136261,
		hashB = 16777619,
		count = 0
	}
end

function finishSignatureState(data)
	local v54 = math.floor(tonumber(data and data.hashA) or 0) % 4294967296
	local v55 = math.floor(tonumber(data and data.hashB) or 0) % 4294967296
	local v56 = math.max(0, (math.floor(tonumber(data and data.count) or 0)))
	return string.format("%08x%08x:%d", v54, v55, v56)
end

function appendSignaturePart(state, p)
	if typeof(state) ~= "table" then
		return
	end

	local v54 = p == nil and "\0" or typeof(p) == "boolean" and (p and "\1" or "\2") or tostring(p)
	state.count = (tonumber(state.count) or 0) + 1
	local hashA = tonumber(state.hashA) or 2166136261
	local hashB = tonumber(state.hashB) or 16777619

	for i = 1, #v54 do
		local v55 = string.byte(v54, i) or 0
		hashA = (hashA * 131 + v55) % 4294967296
		hashB = (hashB * 137 + v55 + i) % 4294967296
	end

	state.hashA = (hashA * 131 + 124) % 4294967296
	state.hashB = (hashB * 137 + 31) % 4294967296
end

function buildTagSignature(list)
	local signatureState = createSignatureState()

	if typeof(list) == "table" then
		for _, v54 in ipairs(list) do
			appendSignaturePart(signatureState, v54)
		end
	end

	return finishSignatureState(signatureState)
end

function buildEntryCollectionSignature(options)
	local signatureState = createSignatureState()

	for _, v54 in ipairs(options or {}) do
		appendSignaturePart(signatureState, v54 and v54.id)
		appendSignaturePart(signatureState, v54 and v54.name)
		appendSignaturePart(signatureState, v54 and v54.likes)
		appendSignaturePart(signatureState, v54 and v54.dislikes)
		appendSignaturePart(signatureState, v54 and v54.downloads)
		appendSignaturePart(signatureState, v54 and (v54.favourites or v54.favorites))
		appendSignaturePart(signatureState, v54 and v54.importCode)
		appendSignaturePart(signatureState, v54 and v54.uploadedTs)
		appendSignaturePart(signatureState, buildTagSignature(v54 and v54.tags))
	end

	return finishSignatureState(signatureState)
end

function buildCreatorCollectionSignature(options)
	local signatureState = createSignatureState()

	for _, v54 in ipairs(options or {}) do
		appendSignaturePart(signatureState, v54 and v54.userId)
		appendSignaturePart(signatureState, v54 and v54.name)
		appendSignaturePart(signatureState, v54 and v54.uploads)
		appendSignaturePart(signatureState, v54 and (v54.totalLikes or v54.stat))
		appendSignaturePart(signatureState, v54 and v54.verified == true)
	end

	return finishSignatureState(signatureState)
end

function buildBrowseStructureSignature(p, p2, p3, options, options2)
	local signatureState = createSignatureState()
	appendSignaturePart(signatureState, p)
	appendSignaturePart(signatureState, p2)
	appendSignaturePart(signatureState, p3)
	appendSignaturePart(signatureState, #(options or {}))
	appendSignaturePart(signatureState, #(options2 or {}))

	for i, v54 in ipairs(options or {}) do
		appendSignaturePart(signatureState, "creator")
		appendSignaturePart(signatureState, i)
		appendSignaturePart(signatureState, v54 and v54.userId)
		appendSignaturePart(signatureState, v54 and v54.name)
		appendSignaturePart(signatureState, v54 and v54.verified == true)
		appendSignaturePart(signatureState, v54 and v54.totalUploads)
		appendSignaturePart(signatureState, v54 and v54.totalLikes)
		appendSignaturePart(signatureState, v54 and v54.totalDislikes)
		appendSignaturePart(signatureState, v54 and v54.totalFavorites)
		appendSignaturePart(signatureState, v54 and v54.totalDownloads)
	end

	for i, v54 in ipairs(options2 or {}) do
		appendSignaturePart(signatureState, i)
		appendSignaturePart(signatureState, v54 and v54.id)
		appendSignaturePart(signatureState, v54 and v54.name)
		appendSignaturePart(signatureState, v54 and v54.category)
		appendSignaturePart(signatureState, v54 and v54.creator)
		appendSignaturePart(signatureState, v54 and (v54.uploadedTs or v54.uploadedAt))
		appendSignaturePart(signatureState, v54 and v54.importCode)
		appendSignaturePart(signatureState, v54 and v54.thumbnail)
		appendSignaturePart(signatureState, v54 and (v54.thumbnailRaw or v54.imageId))
		appendSignaturePart(signatureState, v54 and v54.thumbnailIsDefault == true)
	end

	return finishSignatureState(signatureState)
end

function hasVisibleNamedRows(instance, options)
	if not instance then
		return false
	end

	for _, guiObject in ipairs(instance:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		for _, v54 in ipairs(options or {}) do
			if guiObject.Name:find(v54) == 1 then
				return true
			end
		end
	end

	return false
end

local v54 = 0

function sweepVerifiedAvatarThumbCache(p)
	if p - v54 < RequestHelper.VERIFIED_AVATAR_CACHE_SWEEP_INTERVAL then
		return
	end

	v54 = p
	local count3 = 0

	for k, v55 in pairs(v50) do
		if (tonumber(v55 and v55.expiresAt) or 0) <= p then
			v50[k] = nil
		else
			count3 += 1
		end
	end

	if count3 <= RequestHelper.VERIFIED_AVATAR_CACHE_MAX_SIZE then
		return
	end

	local v55 = {}

	for k, v56 in pairs(v50) do
		v55[#v55 + 1] = {
			uid = k,
			expiry = tonumber(v56 and v56.expiresAt) or 0
		}
	end

	table.sort(v55, function(a, b)
		return a.expiry < b.expiry
	end)

	for i = 1, math.min(math.max(1, (math.floor(count3 * 0.1))), #v55) do
		v50[v55[i].uid] = nil
	end
end

local v55 = {
	root = nil,
	summary = nil,
	status = nil,
	targetUserInput = nil,
	reasonInput = nil,
	creatorNameInput = nil,
	includeDeletedBtn = nil,
	includeDeleted = false,
	listScroll = nil,
	listings = {},
	mapSaves = {},
	activeCreatorUserId = 0,
	activeMapTargetUserId = 0
}
local textColor = rgb(145, 235, 165)
local backgroundColor = rgb(38, 108, 62)
local color3 = rgb(120, 225, 150)
local v59 = {}
entryById = {}
local sources = {}
local uploadListState = {
	groupedByType = {},
	typeList = {},
	activeType = nil
}
local searchbox2 = uploadSelect and uploadSelect:FindFirstChild("Searchbox", true)
local v61 = ""
local v62 = nil
local typeToCategory = {
	characters = "Character",
	maps = "Map",
	moves = "Move",
	awaken_moves = "AwakenMove",
	spawn_animations = "SpawnAnim",
	awakening_animations = "AwakenAnim",
	m1_styles = "M1Style",
	wall_combos = "WallCombo",
	forward_dashes = "ForwardDash",
	effects = "Effect",
	created_anims = "CreatedAnim"
}
local v64 = {
	ALL = "all",
	Character = "characters",
	CHARACTER = "characters",
	CHARACTERS = "characters",
	Map = "maps",
	Maps = "maps",
	MAP = "maps",
	MAPS = "maps",
	Animations = "created_anims",
	Animation = "created_anims",
	["Created Anim"] = "created_anims",
	["Created Anims"] = "created_anims",
	CreatedAnimations = "created_anims",
	["Created Animations"] = "created_anims",
	ANIMATION = "created_anims",
	ANIMATIONS = "created_anims",
	CreatedAnim = "created_anims",
	CreatedAnims = "created_anims",
	CREATEDANIMS = "created_anims",
	CREATEDANIMATIONS = "created_anims",
	CREATEDANIM = "created_anims",
	Move = "moves",
	MOVE = "moves",
	MOVES = "moves",
	AwakenMove = "awaken_moves",
	SpawnAnim = "spawn_animations",
	SPAWN = "spawn_animations",
	AwakenAnim = "awakening_animations",
	AWAKEN = "awakening_animations",
	M1Style = "m1_styles",
	M1 = "m1_styles",
	WallCombo = "wall_combos",
	WALL = "wall_combos",
	ForwardDash = "forward_dashes",
	DASH = "forward_dashes",
	Effect = "effects"
}
local v65 = {
	spawn_animations = true,
	awakening_animations = true,
	m1_styles = true,
	wall_combos = true,
	forward_dashes = true,
	created_anims = true
}
local v66 = {
	SpawnAnim = true,
	AwakenAnim = true,
	M1Style = true,
	WallCombo = true,
	ForwardDash = true,
	CreatedAnim = true
}

local function isDisabledLegacyEntry(p)
	return typeof(p) == "table" and v65[tostring(p.type)] == true
end

local function filterDisabledLegacyEntries(list)
	if typeof(list) ~= "table" then
		return list
	end

	local result = {}

	for _, v67 in ipairs(list) do
		local v68

		if typeof(v67) == "table" then
			v68 = v65[tostring(v67.type)] == true
		else
			v68 = false
		end

		if not v68 then
			result[#result + 1] = v67
		end
	end

	return result
end

_G.__TSB_CATALOGUE_BLOCKED_READ_ACTIONS = {
	BrowseQuery = true,
	LeaderboardQuery = true,
	VerifiedQuery = true,
	CreatorProfile = true,
	GetMine = true,
	GetAdded = true,
	GetFavourites = true,
	GetUploadSources = true,
	AdminPanelSummary = true,
	AdminGetCreatorListings = true,
	AdminGetUserMapSaves = true,
	AdminGetRandomMapSaves = true
}
local requestApi = RequestHelper.newRequestApi({
	remoteFunction = globalCatalogueHandler,
	httpService = HttpService,
	warnFn = fn,
	blockedReadActions = _G.__TSB_CATALOGUE_BLOCKED_READ_ACTIONS
})

function purgeMissingCatalogueEntry(value)
	local v67 = tostring(value or "")

	if v67 == "" then
		return
	end

	if entryById then
		entryById[v67] = nil
	end

	v23[v67] = nil

	if type(v14) == "table" then
		for i = #v14, 1, -1 do
			local v68 = v14[i]

			if v68 and tostring(v68.id) == v67 then
				table.remove(v14, i)
			end
		end
	end

	addedToPS[v67] = nil
	local child = cardGrid and cardGrid:FindFirstChild("Card_" .. v67)

	if child then
		child:Destroy()
	end

	local child2 = addedScroll and addedScroll:FindFirstChild("Added_" .. v67)

	if child2 then
		child2:Destroy()
	end

	if v24 and tostring(v24.id) == v67 then
		closeDetail(true)
	end

	updateTabCounts()
	refreshBrowse(true)
	refreshAddedTabImmediatelyIfVisible()
	showToast("This item no longer exists, removed it")
end

local function req(...)
	local req2 = requestApi.req(...)
	local _, v67 = ...

	if type(req2) == "table" and req2.ok == false and req2.error == "entry-not-found" and type(v67) == "table" then
		local entryId = v67.entryId or v67.entryID or v67.id

		if entryId ~= nil and tostring(entryId) ~= "" then
			purgeMissingCatalogueEntry(entryId)
		end
	end

	return req2
end

local reqAllPagedEntries = requestApi.reqAllPagedEntries
local notifyCharCreatorCatalogueRefresh = requestApi.notifyCharCreatorCatalogueRefresh
local describeCatalogueError = requestApi.describeCatalogueError
local decodeConfigTable = requestApi.decodeConfigTable
local deriveEntryContentMeta = requestApi.deriveEntryContentMeta
local detailReturnApi = RequestHelper.newDetailReturnApi()
local addedImportApi = RequestHelper.newAddedImportApi({
	addedScroll = addedScroll,
	addedSearchBox = searchbox,
	addedRowTemplate = addedtemplate,
	req = req,
	showToast = function(p)
		showToast(p)
	end,
	describeCatalogueError = describeCatalogueError,
	notifyCharCreatorCatalogueRefresh = function(p)
		notifyCharCreatorCatalogueRefresh(p)
	end,
	schedulePsMutationRefresh = function()
		schedulePsMutationRefresh()
	end,
	updateTabCounts = function()
		updateTabCounts()
	end,
	syncAdded = function(p)
		return syncAdded(p)
	end,
	refreshAddedToPS = function(p)
		refreshAddedToPS(p)
	end,
	getActiveTab = function()
		return v7
	end,
	claimActionDebounce = function(p, p2, p3)
		return claimActionDebounce(p, p2, p3)
	end,
	warnFn = fn
})

function emojiThumbsUp()
	return utf8.char(128077)
end

function emojiThumbsDown()
	return utf8.char(128078)
end

function emojiStar()
	return utf8.char(9733)
end

local v67 = rgb(240, 192, 64)
local v68 = rgb(12, 12, 12)

function applyFavouriteVisual(guiObject, p)
	if not guiObject then
		return
	end

	if guiObject:IsA("TextButton") then
		guiObject.AutoButtonColor = false
		guiObject.Text = emojiStar()
		guiObject.TextColor3 = p and v67 or v68
		guiObject.TextTransparency = 0
		guiObject.BackgroundColor3 = rgb(30, 30, 30)
		guiObject.BackgroundTransparency = 1
	elseif guiObject:IsA("ImageButton") then
		guiObject.AutoButtonColor = false
		guiObject.ImageColor3 = p and v67 or v68
	elseif guiObject:IsA("ImageLabel") then
		guiObject.ImageColor3 = p and v67 or v68
	elseif guiObject:IsA("TextLabel") then
		guiObject.Text = emojiStar()
		guiObject.TextColor3 = p and v67 or v68
		guiObject.TextTransparency = 0
	end

	local uIStroke = guiObject:FindFirstChildWhichIsA("UIStroke")

	if uIStroke then
		uIStroke.Color = p and v67 or rgb(255, 255, 255)
		uIStroke.Transparency = p and 0.45 or 0.85
	end
end

function applyVoteVisual(button, button2, p)
	if button and button:IsA("TextButton") then
		local v69 = p == "up"
		button.Text = emojiThumbsUp()
		button.TextColor3 = v69 and rgb(180, 255, 180) or rgb(170, 170, 170)
		button.BackgroundColor3 = v69 and rgb(70, 145, 85) or rgb(35, 90, 45)
		button.BackgroundTransparency = v69 and 0.42 or 0.8
		local uIStroke = button:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = v69 and rgb(120, 220, 130) or rgb(90, 140, 95)
			uIStroke.Transparency = v69 and 0.35 or 0.78
		end
	end

	if button2 and button2:IsA("TextButton") then
		local v69 = p == "down"
		button2.Text = emojiThumbsDown()
		button2.TextColor3 = v69 and rgb(255, 185, 185) or rgb(170, 170, 170)
		button2.BackgroundColor3 = v69 and rgb(150, 60, 60) or rgb(95, 35, 35)
		button2.BackgroundTransparency = v69 and 0.42 or 0.8
		local uIStroke = button2:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = v69 and rgb(230, 95, 95) or rgb(145, 90, 90)
			uIStroke.Transparency = v69 and 0.35 or 0.78
		end
	end
end

function moveAddedTopStatsToBottom(guiObject)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local v69 = nil

	for _, childName in ipairs({
		"StatsOverlay",
		"StatsBar",
		"StatsRow",
		"HeaderStats",
		"TopStats"
	}) do
		local guiObject2 = guiObject:FindFirstChild(childName, true)

		if not (guiObject2 and guiObject2:IsA("GuiObject")) then
			continue
		end

		v69 = guiObject2
		break
	end

	if not v69 then
		for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
			if not guiObject2:IsA("GuiObject") then
				continue
			end

			local name = string.lower(guiObject2.Name or "")

			if not string.find(name, "stat", 1, true) then
				continue
			end

			if not (guiObject2:FindFirstChild("LikeStat", true) or guiObject2:FindFirstChild("LikesStat", true) or guiObject2:FindFirstChild(
				"DislikeStat",
				true
			) or guiObject2:FindFirstChild("DlStat", true)) then
				continue
			end

			v69 = guiObject2
			break
		end
	end

	if not v69 then
		return
	end

	local position = v69.Position
	v69.AnchorPoint = Vector2.new(v69.AnchorPoint.X, 1)
	v69.Position = UDim2.new(position.X.Scale, position.X.Offset, 1, -2)
end

function escapeRichText(value)
	return (tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"))
end

function formatCreatorLine(p, value, p2, value2)
	local v69 = escapeRichText(p)
	local v70 = escapeRichText(value or "")
	local v71 = "<font color=\"#FFFFFF\">" .. v69 .. "</font>"
	local v72 = p2 == false and "" or "<font color=\"" .. tostring(value2 or "#A0A0A0") .. "\">by </font>"

	if v70 == "" then
		return v72 .. v71
	end

	return v72 .. v71 .. "<font color=\"#A0A0A0\"> | " .. v70 .. "</font>"
end

function applyNameStroke(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
		guiObject.TextStrokeColor3 = rgb(0, 0, 0)
		guiObject.TextStrokeTransparency = tonumber(p) or 0.25
	end
end

function setStatTextPreservePrefix(guiObject, p, p2)
	if not (guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton"))) then
		return
	end

	local match = tostring(guiObject.Text or ""):match("^(.-)%s*[%+%-]?[%d,%.]+%s*$")

	if match then
		if match ~= "" and not match:match("%s$") then
			match ..= " "
		end
	else
		match = p2 and p2 .. " " or ""
	end

	guiObject.Text = match .. formatNum(tonumber(p) or 0)
	guiObject.TextColor3 = rgb(255, 255, 255)
end

function findStatsOverlayNode(guiObject)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return nil
	end

	for _, childName in ipairs({
		"StatsOverlay",
		"StatsBar",
		"StatsRow",
		"HeaderStats",
		"TopStats"
	}) do
		local guiObject2 = guiObject:FindFirstChild(childName, true)

		if guiObject2 and guiObject2:IsA("GuiObject") then
			return guiObject2
		end
	end

	for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
		if not guiObject2:IsA("GuiObject") then
			continue
		end

		local name = string.lower(guiObject2.Name or "")

		if string.find(name, "stat", 1, true) and (guiObject2:FindFirstChild("LikeStat", true) or guiObject2:FindFirstChild(
			"LikesStat",
			true
		) or guiObject2:FindFirstChild("DislikeStat", true) or guiObject2:FindFirstChild("FavouriteStat", true) or guiObject2:FindFirstChild(
			"FavStat",
			true
		) or guiObject2:FindFirstChild("DlState", true) or guiObject2:FindFirstChild("DlStat", true)) then
			return guiObject2
		end
	end

	return nil
end

function actionKey(p, value)
	return tostring(p) .. ":" .. tostring(value or "")
end

function claimActionDebounce(p, p2, p3)
	local v69 = actionKey(p, p2)
	local now2 = os.clock()

	if now2 < (v40[v69] or 0) then
		return false
	end

	v40[v69] = now2 + (tonumber(p3) or 0.45)
	return true
end

function getCommRemote(p)
	local v69 = os.clock() + (tonumber(p) or 0)
	local communicate

	while true do
		local character = localPlayer.Character
		communicate = character and character:FindFirstChild("Communicate")

		if communicate and communicate:IsA("RemoteEvent") then
			break
		end

		if p == nil or p <= 0 or v69 <= os.clock() then
			return nil
		else
			task.wait(0.1)
		end
	end

	return communicate
end

function buildImportCompactConfig(p)
	local c = decodeConfigTable(p)

	if not c then
		return nil
	end

	if typeof(c.c) == "table" then
		c = c.c
	end

	local function readString(...)
		for _, v69 in ipairs({ ... }) do
			local name = c[v69]

			if typeof(name) == "table" then
				name = name.name or name.Name or name.id or name.Id
			end

			if typeof(name) ~= "string" then
				continue
			end

			local v70 = name:gsub("^%s+", ""):gsub("%s+$", "")

			if v70 ~= "" then
				return v70
			end
		end

		return nil
	end

	local function readArrayValue(p2, p3)
		local v69 = c[p2]

		if typeof(v69) ~= "table" then
			return nil
		end

		local name = v69[p3]

		if typeof(name) == "table" then
			name = name.name or name.Name or name.id or name.Id
		end

		if typeof(name) == "string" then
			local v70 = name:gsub("^%s+", ""):gsub("%s+$", "")

			if v70 ~= "" then
				return v70
			end
		end

		return nil
	end

	local v69 = {}
	local b1 = readString("base1", "b1") or readArrayValue("base", 1)
	local b2 = readString("base2", "b2") or readArrayValue("base", 2)
	local b3 = readString("base3", "b3") or readArrayValue("base", 3)
	local b4 = readString("base4", "b4") or readArrayValue("base", 4)
	local a1 = readString("awaken1", "a1") or readArrayValue("awaken", 1)
	local a2 = readString("awaken2", "a2") or readArrayValue("awaken", 2)
	local a3 = readString("awaken3", "a3") or readArrayValue("awaken", 3)
	local a4 = readString("awaken4", "a4") or readArrayValue("awaken", 4)
	local v78 = readString("spawnAnim", "s")
	local v79 = readString("awakenAnim", "u", "ultAnim", "l")
	local v80 = readString("customM1", "m")
	local v81 = readString("wallCombo", "w")
	local v82 = readString("forwardDash", "f")

	if b1 then
		v69.b1 = b1
	end

	if b2 then
		v69.b2 = b2
	end

	if b3 then
		v69.b3 = b3
	end

	if b4 then
		v69.b4 = b4
	end

	if a1 then
		v69.a1 = a1
	end

	if a2 then
		v69.a2 = a2
	end

	if a3 then
		v69.a3 = a3
	end

	if a4 then
		v69.a4 = a4
	end

	if v78 then
		v69.s = v78
	end

	if v79 then
		v69.u = v79
	end

	if v80 then
		v69.m = v80
	end

	if v81 then
		v69.w = v81
	end

	if v82 then
		v69.f = v82
	end

	return v69
end

function fireCustomCharacterAction(action, value, p2)
	local characterId = tostring(value or "")

	if characterId == "" then
		return false, "missing-character-id"
	end

	local commRemote = getCommRemote(4)

	if not commRemote then
		return false, "communicate-remote-missing"
	end

	local v70 = {
		Goal = "Custom Character",
		Action = action,
		CharacterId = characterId
	}

	if p2 and p2.suppressNotification == true then
		v70.SuppressNotification = true
	end

	commRemote:FireServer({
		Goal = v70.Goal,
		Action = v70.Action,
		CharacterId = v70.CharacterId,
		SuppressNotification = v70.SuppressNotification
	})
	return true
end

function toDateString(p)
	local v69 = tonumber(p)

	if v69 and not (v69 <= 0) then
		return os.date("%Y-%m-%d", v69)
	end

	return os.date("%Y-%m-%d")
end

function asMoveLabel(value)
	if typeof(value) == "string" then
		local v69 = value:gsub("^%s+", ""):gsub("%s+$", "")
		return (v69 == "" or not v69) and "-" or v69
	end

	if typeof(value) == "table" then
		local name = value.name or value.Name or value.id or value.Id

		if typeof(name) == "string" and name ~= "" then
			return name
		end
	end

	return "-"
end

function lowerTrim(value)
	local v69 = tostring(value or "")
	local v70 = string.gsub(v69, "^%s+", "")
	local v71 = string.gsub(v70, "%s+$", "")
	return string.lower(v71)
end

function trimString(value)
	local v69 = tostring(value or "")
	local v70 = string.gsub(v69, "^%s+", "")
	return (string.gsub(v70, "%s+$", ""))
end

function normalizeCatalogueImage(p)
	local v69 = trimString(p)

	if v69 == "" then
		return nil
	end

	local v70 = string.lower(v69)

	if string.find(v70, "rbxassetid://", 1, true) == 1 then
		local v71 = string.match(v69, "%d+")
		return v71 and "rbxassetid://" .. v71 or nil
	end

	if string.find(v70, "rbxthumb://", 1, true) == 1 or string.find(v70, "https://", 1, true) == 1 or string.find(
		v70,
		"http://",
		1,
		true
	) == 1 then
		return v69
	end

	if string.match(v69, "^%d+$") then
		return "rbxassetid://" .. v69
	end

	local v71 = string.match(v69, "%d+")

	if v71 then
		return "rbxassetid://" .. v71
	end

	return nil
end

function findUploadImageInput()
	if uploadImageInput and uploadImageInput.Parent == uploadConfirm and uploadImageInput:IsA("TextBox") then
		return uploadImageInput
	end

	uploadImageInput = uploadConfirm:WaitForChild("ThumbnailInput")
	return uploadImageInput
end

function resolveUploadThumbnail(data, p)
	if p == true then
		local uploadImageInput2 = findUploadImageInput()
		local v69 = uploadImageInput2 and normalizeCatalogueImage(uploadImageInput2.Text)

		if v69 then
			return v69
		end
	end

	if typeof(data) == "table" then
		return normalizeCatalogueImage(data.thumbnail or data.thumbnailRaw or data.imageId or data.ImageId or data.m)
	end

	return nil
end

function inferTypeFromSource(data)
	local v69 = lowerTrim(data and data.sourceType)
	local v70 = lowerTrim(data and data.sourceSubtype)
	local v71 = lowerTrim(data and data.name)
	local config

	if data and typeof(data.config) == "table" then
		config = data.config or nil
	end

	local v72 = lowerTrim(data and (data.sourceRef or data.sourceId))

	if v69 == "build_map_save" or v69 == "map_save" or v69 == "map" or string.find(v72, "psmap:", 1, true) == 1 then
		return "maps"
	end

	if v69 == "created_animation_save" or v69 == "created_anim" then
		return "created_anims"
	end

	if v69 == "custom_character" then
		return "characters"
	end

	if v69 == "custom_character_slot" then
		if string.find(v70, "awaken", 1, true) then
			return "awaken_moves"
		end

		if string.find(v70, "spawn", 1, true) then
			return "spawn_animations"
		end

		if string.find(v70, "m1", 1, true) or string.find(v70, "style", 1, true) then
			return "m1_styles"
		end

		if string.find(v70, "forward", 1, true) and string.find(v70, "dash", 1, true) then
			return "forward_dashes"
		end

		if string.find(v70, "wall", 1, true) and string.find(v70, "combo", 1, true) then
			return "wall_combos"
		end

		return "moves"
	elseif v69 == "move_save" or string.find(v69, "move", 1, true) then
		if string.find(v70, "awaken", 1, true) then
			return "awaken_moves"
		end

		if string.find(v70, "spawn", 1, true) then
			return "spawn_animations"
		end

		if string.find(v70, "m1", 1, true) or string.find(v70, "style", 1, true) then
			return "m1_styles"
		end

		if string.find(v70, "forward", 1, true) and string.find(v70, "dash", 1, true) then
			return "forward_dashes"
		end

		if string.find(v70, "wall", 1, true) and string.find(v70, "combo", 1, true) then
			return "wall_combos"
		end

		if string.find(v70, "awaken", 1, true) then
			return "awakening_animations"
		end

		if string.find(v71, "spawn", 1, true) then
			return "spawn_animations"
		end

		if string.find(v71, "awaken", 1, true) then
			return "awakening_animations"
		end

		if string.find(v71, "m1", 1, true) or string.find(v71, "style", 1, true) then
			return "m1_styles"
		end

		if string.find(v71, "forward", 1, true) and string.find(v71, "dash", 1, true) then
			return "forward_dashes"
		end

		if string.find(v71, "wall", 1, true) and string.find(v71, "combo", 1, true) then
			return "wall_combos"
		end

		if string.find(v71, "_anim_", 1, true) or string.find(v71, "anim", 1, true) or string.find(v70, "anim", 1, true) then
			return "created_anims"
		end

		return "moves"
	else
		if not config then
			return nil
		end

		if typeof(config.c) == "table" then
			config = config.c
		end

		if config.base1 or config.b1 or config.base2 or config.b2 or config.base3 or config.b3 or config.base4 or config.b4 or config.awaken1 or config.a1 or config.awaken2 or config.a2 or config.awaken3 or config.a3 or config.awaken4 or config.a4 then
			return "characters"
		end

		return nil
	end
end

function normalizeEntryType(data)
	local v69 = lowerTrim(data and data.type)
	local v70 = lowerTrim(data and data.sourceType)
	local v71 = lowerTrim(data and (data.sourceRef or data.sourceId))
	local v72

	if v69 == "character" or v69 == "char" then
		v72 = "characters"
	elseif v69 == "map" then
		v72 = "maps"
	elseif v69 == "animation" or v69 == "animations" or v69 == "created_anim" then
		v72 = "created_anims"
	elseif v69 == "move" then
		v72 = "moves"
	elseif v69 == "awaken_move" then
		v72 = "awaken_moves"
	elseif v69 == "spawn_anim" then
		v72 = "spawn_animations"
	elseif v69 == "awaken_anim" then
		v72 = "awakening_animations"
	elseif v69 == "m1_style" then
		v72 = "m1_styles"
	elseif v69 == "wall_combo" then
		v72 = "wall_combos"
	elseif v69 == "forward_dash" then
		v72 = "forward_dashes"
	else
		v72 = v69
	end

	local v73 = (v70 == "build_map_save" or v70 == "map_save" or v70 == "map") and "maps" or string.find(
		v71,
		"psmap:",
		1,
		true
	) == 1 and "maps" or v72

	if v73 == "characters" and v70 ~= "custom_character" and v70 ~= "" then
		local v74 = inferTypeFromSource(data)

		if v74 and v74 ~= "characters" then
			v73 = v74
		end
	end

	if typeToCategory[v73] then
		return v73
	end

	local v74 = inferTypeFromSource(data)

	if v74 and typeToCategory[v74] then
		return v74
	end

	return "moves"
end

function buildMovesFromConfig(p)
	local c = decodeConfigTable(p) or {}

	if typeof(c.c) == "table" then
		c = c.c
	end

	local function readSlot(p2, p3, p4, p5)
		local v69 = c[p2]

		if v69 == nil and p3 then
			v69 = c[p3]
		end

		if v69 == nil and p4 and typeof(c[p4]) == "table" then
			v69 = c[p4][p5]
		end

		return asMoveLabel(v69)
	end

	local base1 = c.base1

	if base1 == nil then
		base1 = c.b1
	end

	if base1 == nil and typeof(c.base) == "table" then
		base1 = c.base[1]
	end

	local v70 = asMoveLabel(base1)
	local base2 = c.base2

	if base2 == nil then
		base2 = c.b2
	end

	if base2 == nil and typeof(c.base) == "table" then
		base2 = c.base[2]
	end

	local v71 = asMoveLabel(base2)
	local base3 = c.base3

	if base3 == nil then
		base3 = c.b3
	end

	if base3 == nil and typeof(c.base) == "table" then
		base3 = c.base[3]
	end

	local base = {
		v70,
		v71,
		asMoveLabel(base3),
		readSlot("base4", "b4", "base", 4)
	}
	local awaken1 = c.awaken1

	if awaken1 == nil then
		awaken1 = c.a1
	end

	if awaken1 == nil and typeof(c.awaken) == "table" then
		awaken1 = c.awaken[1]
	end

	local v73 = asMoveLabel(awaken1)
	local awaken2 = c.awaken2

	if awaken2 == nil then
		awaken2 = c.a2
	end

	if awaken2 == nil and typeof(c.awaken) == "table" then
		awaken2 = c.awaken[2]
	end

	local v74 = asMoveLabel(awaken2)
	local awaken3 = c.awaken3

	if awaken3 == nil then
		awaken3 = c.a3
	end

	if awaken3 == nil and typeof(c.awaken) == "table" then
		awaken3 = c.awaken[3]
	end

	local awaken = {
		v73,
		v74,
		asMoveLabel(awaken3),
		readSlot("awaken4", "a4", "awaken", 4)
	}
	local spawnAnim = c.spawnAnim

	if spawnAnim == nil then
		spawnAnim = c.s
	end

	local awakenAnim = c.awakenAnim

	if awakenAnim == nil then
		awakenAnim = c.u
	end

	if awakenAnim == nil then
		awakenAnim = c.ultAnim
	end

	if awakenAnim == nil then
		awakenAnim = c.l
	end

	local customM1 = c.customM1

	if customM1 == nil then
		customM1 = c.m
	end

	return {
		base = base,
		awaken = awaken,
		spawnAnim = asMoveLabel(spawnAnim),
		awakenAnim = asMoveLabel(awakenAnim),
		m1Style = asMoveLabel(customM1)
	}
end

function toLegacyEntry(data)
	local entryType = normalizeEntryType(data)
	local category = typeToCategory[entryType] or "Move"
	local createdAt = tonumber(data.createdAt) or os.time()
	local uses = tonumber(data.uses) or 0
	local addedCount = tonumber(data.addedCount) or 0
	local movesFromConfig = buildMovesFromConfig(data.config)
	local sourceSubtype = tostring(data.sourceSubtype or data.sourceType or "")
	local config = decodeConfigTable(data.config)
	local thumbnailRaw = tostring(data.thumbnailRaw or data.imageId or data.ImageId or data.m or "")

	if thumbnailRaw == "" then
		thumbnailRaw = nil
	end

	local catalogueImage = normalizeCatalogueImage(data.thumbnail or thumbnailRaw)
	local mapRef = nil

	if typeof(config) == "table" then
		if typeof(config.mapRef) == "table" then
			mapRef = config.mapRef
		elseif typeof(config.map) == "table" then
			mapRef = config.map
		end
	end

	local sourceUserId = tonumber(mapRef and (mapRef.sourceUserId or mapRef.userId or mapRef.uid))
	local slot = tonumber(mapRef and (mapRef.slot or mapRef.slotNumber))
	local payloadSize = tonumber(mapRef and (mapRef.payloadSize or mapRef.bytes))
	local savedAt = tonumber(mapRef and (mapRef.savedAt or mapRef.updatedAt))
	local sourceRef = tostring(data.sourceRef or "")
	local v71 = typeof(data.permissions) ~= "table" and {} or data.permissions or {}
	local contentMeta = deriveEntryContentMeta({
		contentMeta = data and data.contentMeta,
		config = config
	})

	if not sourceUserId or sourceUserId <= 0 or not slot or slot <= 0 then
		local v73, v74 = string.match(sourceRef, "^psmap:(%d+):(%d+)$")

		if v73 and v74 then
			sourceUserId = tonumber(v73) or sourceUserId
			slot = tonumber(v74) or slot
		end
	end

	if category == "Map" and (not sourceUserId or sourceUserId <= 0) then
		sourceUserId = tonumber(data.creatorUserId) or 0
	end

	local v73 = {
		id = tostring(data.id or ""),
		type = entryType,
		category = category,
		name = tostring(data.name or "Unknown"),
		creator = tostring(data.creatorName or "User" .. tostring(data.creatorUserId or 0)),
		creatorUserId = tonumber(data.creatorUserId) or 0,
		tags = typeof(data.tags) ~= "table" and {} or data.tags or {},
		likes = tonumber(data.likes) or 0,
		dislikes = tonumber(data.dislikes) or 0,
		downloads = math.max(uses, addedCount),
		addedCount = addedCount,
		uploadedAt = toDateString(createdAt),
		uploadedTs = createdAt,
		desc = tostring(data.description or ""),
		source = sourceSubtype,
		sourceRef = sourceRef,
		sourceType = tostring(data.sourceType or ""),
		sourceSubtype = tostring(data.sourceSubtype or ""),
		moveType = category == "AwakenMove" and "Awaken" or category == "Move" and "Base" or nil,
		moves = movesFromConfig,
		config = config,
		thumbnail = catalogueImage,
		thumbnailRaw = thumbnailRaw,
		thumbnailIsDefault = data.thumbnailIsDefault == true,
		creatorVerified = data.creatorVerified == true,
		status = tostring(data.status or "active"),
		favourites = tonumber(data.favourites) or tonumber(data.favorites) or 0,
		importCode = tostring(data.importCode or ""),
		myOwned = data.myOwned == true,
		catalogueAllowEditing = v71.allowEditing ~= false,
		isMap = category == "Map",
		mapSourceUserId = math.max(0, (math.floor(tonumber(sourceUserId) or 0))),
		mapSlot = math.max(0, (math.floor(tonumber(slot) or 0))),
		mapPayloadSize = math.max(0, (math.floor(tonumber(payloadSize) or 0))),
		mapSavedAt = math.max(0, (math.floor(tonumber(savedAt) or 0))),
		contentMeta = contentMeta,
		blockCount = tonumber(contentMeta and contentMeta.blockCount) or 0,
		keyframeCount = tonumber(contentMeta and contentMeta.keyframeCount) or 0,
		partCount = tonumber(contentMeta and contentMeta.partCount) or 0,
		duration = tonumber(contentMeta and contentMeta.duration) or nil
	}
	local appearance

	if typeof(data.appearance) == "table" then
		appearance = data.appearance or nil
	end

	v73.appearance = appearance
	v73.updatedAt = tonumber(data.updatedAt) or 0
	return v73
end

function applyLegacyEntryRuntimeState(data, p)
	if typeof(p) ~= "table" then
		return p
	end

	rememberEntryById(p)
	local id = tostring(p.id or "")

	if id == "" then
		return p
	end

	local v69

	if data == nil then
		v69 = false
	else
		v69 = data.viewerStateIncluded == true
	end

	if v69 then
		local v70 = v37[id]

		if v70 and v70.exp > os.clock() then
			v17[id] = v70.value or nil
		else
			if v70 then
				v37[id] = nil
			end

			v17[id] = data and data.myFavorited == true and true or nil
		end

		addedToPS[id] = data and (data.myAdded == true or data.myOwned == true) and true or nil
		local v71 = v36[id]

		if v71 and v71.exp > os.clock() then
			v18[id] = v71.value or nil
			return p
		end

		if v71 then
			v36[id] = nil
		end

		local myVote = tonumber(data and data.myVote) or 0
		v18[id] = myVote == 1 and "up" or myVote == -1 and "down" or nil
		return p
	else
		if addedToPS[id] == true then
			p.myOwned = true
		end

		return p
	end
end

function toRuntimeLegacyEntry(p)
	return applyLegacyEntryRuntimeState(p, toLegacyEntry(p))
end

local fn6

function syncAdded(p)
	if p == true or not hasFreshListCache("added") then
		local v69 = reqAllPagedEntries("GetAdded", {}, 3)

		if v69.ok then
			addedToPS = {}
			local v70 = {}

			for _, v71 in ipairs(v69.entries or {}) do
				local v72 = toRuntimeLegacyEntry(v71)
				addedToPS[tostring(v72.id or "")] = true
				v70[#v70 + 1] = v72
			end

			local addedEntries = filterDisabledLegacyEntries(v70)
			listCacheState.addedEntries = addedEntries
			listCacheState.timestamps.added = os.clock()
			listCacheState.signatures.added = buildEntryCollectionSignature(addedEntries)
			fn6()
			return true
		else
			if #listCacheState.addedEntries == 0 then
				addedToPS = {}
			else
				fn6()
			end

			return false
		end
	else
		addedToPS = {}

		for _, addedEntry in ipairs(listCacheState.addedEntries) do
			local id = tostring(addedEntry and addedEntry.id or "")

			if id ~= "" then
				addedToPS[id] = true
			end
		end

		fn6()
		return true
	end
end

function syncServerChars(_)
	local v69 = reqAllPagedEntries("GetServerCharacters", {}, 1)

	if not v69.ok then
		return false
	end

	local v70 = {}

	for _, v71 in ipairs(v69.entries or {}) do
		local v72 = toRuntimeLegacyEntry(v71)
		v72.serverChar = true
		v70[#v70 + 1] = v72
	end

	local serverCharEntries = filterDisabledLegacyEntries(v70)
	listCacheState.serverCharEntries = serverCharEntries
	warn2("server chars fetched " .. tostring(#serverCharEntries))
	return true
end

function syncFavourites()
	local v69 = req("GetFavourites", {
		idsOnly = true
	}, 3)

	if not (v69 and v69.ok) then
		return false
	end

	v17 = {}

	for _, v70 in ipairs(v69.ids or {}) do
		local v71 = tostring(v70)

		if v71 ~= "" then
			v17[v71] = true
		end
	end

	warn2("catalogue favourites synced from local ids, count " .. tostring(#(v69.ids or {})))

	for k, v71 in pairs(v37) do
		if v71.exp > os.clock() then
			v17[k] = v71.value or nil
		else
			v37[k] = nil
		end
	end

	return true
end

function syncVotes()
	local v69 = req("GetVotes", {}, 3)

	if not (v69 and v69.ok) then
		return false
	end

	local votes = v69.votes or {}

	for k, vote in pairs(votes) do
		local v70 = tostring(k)
		local v71 = v36[v70]

		if v71 and v71.exp > os.clock() then
			continue
		end

		if v71 then
			v36[v70] = nil
		end

		local v72 = tonumber(vote) or 0
		v18[v70] = v72 == 1 and "up" or v72 == -1 and "down" or nil
	end

	return true
end

function syncMine(p)
	if p ~= true and hasFreshListCache("mine") then
		return true
	end

	local v69 = reqAllPagedEntries("GetMine", {
		includeDeleted = false,
		includeAnalytics = false
	}, 3)

	if v69.ok then
		local v70 = {}

		for _, v71 in ipairs(v69.entries or {}) do
			local v72 = toRuntimeLegacyEntry(v71)

			if v34[tostring(v72 and v72.id or v71 and v71.id or "")] then
				continue
			end

			table.insert(v70, v72)
		end

		v19 = v70
		listCacheState.timestamps.mine = os.clock()
		listCacheState.signatures.mine = buildEntryCollectionSignature(v70)
		return true
	else
		if listCacheState.timestamps.mine <= 0 then
			v19 = {}
			listCacheState.signatures.mine = ""
		end

		return false
	end
end

local v69 = 0

function syncUploadSources(p)
	local now2 = tick()

	if p ~= true and now2 - v69 < 10 and #sources > 0 then
		return true
	end

	v69 = now2
	local v70 = {}

	if p == true then
		v70.forceRefresh = true
	end

	local v71 = req("GetUploadSources", v70, 3)

	if v71.ok then
		sources = v71.sources or {}
		local v72 = {
			base1 = true,
			base2 = true,
			base3 = true,
			base4 = true,
			awaken1 = true,
			awaken2 = true,
			awaken3 = true,
			awaken4 = true
		}
		local v73 = {}

		for _, source in ipairs(sources) do
			local sourceType = tostring(source.sourceType or "")
			local v74 = lowerTrim(sourceType)
			local sourceSubtype = tostring(source.sourceSubtype or "")
			local v75 = lowerTrim(sourceSubtype)
			local v76 = lowerTrim(source.name or "")

			if not (v74 ~= "move_save" or v72[v75] ~= true and string.find(v76, " - base move ", 1, true) == nil and string.find(
				v76,
				" - awaken move ",
				1,
				true
			) == nil and string.find(v76, " - m1 style", 1, true) == nil and string.find(v76, " - spawn anim", 1, true) == nil and string.find(
				v76,
				" - awaken anim",
				1,
				true
			) == nil and string.find(v76, " - forward dash", 1, true) == nil and string.find(
				v76,
				" - wall combo",
				1,
				true
			) == nil) then
				continue
			end

			local v77 = inferTypeFromSource(source) or tostring(source.assetType or "moves")

			if v65[tostring(v77)] then
				continue
			end

			local typeLabel = RequestHelper.TYPE_TO_UPLOAD_LABEL[tostring(v77 or "")] or "Item"
			table.insert(v73, {
				sourceId = source.sourceId,
				name = source.name or "Untitled",
				tags = source.tags or {},
				info = source.info or source.sourceSubtype or sourceType or "Custom",
				assetType = v77 or "moves",
				description = source.description or "",
				sourceType = sourceType,
				sourceSubtype = sourceSubtype,
				config = source.config,
				thumbnail = normalizeCatalogueImage(source.thumbnail or source.imageId or source.ImageId or source.m),
				thumbnailRaw = tostring(source.thumbnail or source.imageId or source.ImageId or source.m or ""),
				typeLabel = typeLabel
			})
		end

		v59 = v73
		rebuildUploadSourceCaches()
		return true
	else
		if #sources == 0 and #v59 == 0 then
			uploadListState.groupedByType = {}
			uploadListState.typeList = {}
			uploadListState.activeType = nil
		end

		return false
	end
end

local flag3 = false

function syncUploadSourcesAsync(p)
	if flag3 then
		return
	end

	flag3 = true
	task.spawn(function()
		local _, _ = pcall(function()
			return syncUploadSources(p == true)
		end)
		flag3 = false

		if v7 == "UPLOAD" and type(fn3) == "function" then
			fn3(true)
		end
	end)
end

local flag4 = false

function syncMineForUploadAsync(p)
	if flag4 then
		return
	end

	flag4 = true
	task.spawn(function()
		local _, _ = pcall(function()
			return syncMine(p == true)
		end)
		flag4 = false

		if v7 == "UPLOAD" and type(fn3) == "function" then
			fn3(true)
		end
	end)
end

function formatNum(p)
	if p >= 1000000 then
		return string.format("%.1fM", p / 1000000)
	end

	if p >= 1000 then
		return string.format("%.1fk", p / 1000)
	end

	return (tostring(p))
end

function formatLeaderboardStatLabel(value)
	local v70 = lowerTrim(value)

	if v70 == "most_liked" or v70 == "most liked" or v70 == "mostlikes" then
		return "MOST LIKES"
	end

	if v70 == "most_used" or v70 == "most used" then
		return "MOST USED"
	end

	if v70 == "total_likes" or v70 == "total likes" then
		return "TOTAL LIKES"
	end

	if v70 == "downloads" then
		return "USES"
	end

	return (tostring(value or "score"):gsub("_", " "):upper())
end

function hasAnyItemsLeaderboardCache()
	for _, v70 in pairs(v43) do
		if typeof(v70) == "table" and #v70 > 0 then
			return true
		end
	end

	return v48.items > 0
end

function hasFreshLeaderboardCache(p)
	local v70 = tonumber(v48[p]) or 0
	return not (v70 <= 0) and os.clock() - v70 <= RequestHelper.LEADERBOARD_CACHE_TTL_SEC
end

function timeAgo(value)
	if typeof(value) == "number" then
		local v70 = math.floor(math.max(0, os.time() - math.floor(value)) / 86400)

		if v70 <= 0 then
			return "Today"
		end

		if v70 == 1 then
			return "Yesterday"
		end

		if v70 < 7 then
			return v70 .. "d ago"
		end

		if v70 < 30 then
			return math.floor(v70 / 7) .. "w ago"
		end

		return math.floor(v70 / 30) .. "mo ago"
	else
		local match, v70, v71 = tostring(value):match("(%d+)-(%d+)-(%d+)")

		if not match then
			return (tostring(value))
		end

		local v72 = os.time({
			year = tonumber(match),
			month = tonumber(v70),
			day = tonumber(v71),
			hour = 0
		})
		local v73 = math.floor((os.time() - v72) / 86400)

		if v73 <= 0 then
			return "Today"
		end

		if v73 == 1 then
			return "Yesterday"
		end

		if v73 < 7 then
			return v73 .. "d ago"
		end

		if v73 < 30 then
			return math.floor(v73 / 7) .. "w ago"
		end

		return math.floor(v73 / 30) .. "mo ago"
	end
end

local function formatContentMetaDuration(duration)
	local v70 = tonumber(duration)

	if not v70 or v70 <= 0 then
		return ""
	end

	local v71 = math.floor(v70 * 10 + 0.5) / 10
	local v72 = math.floor(v71 + 0.0001)

	if math.abs(v71 - v72) < 0.05 then
		return tostring(v72) .. "S"
	end

	return string.format("%.1fS", v71)
end

local function buildEntryContentMetaSummary(data)
	local v70 = deriveEntryContentMeta(data)

	if typeof(v70) ~= "table" then
		return ""
	end

	local v71 = normalizeEntryType(data) == "created_anims"
	local v72 = math.max(0, (math.floor(tonumber(v70.keyframeCount) or 0)))
	local v73 = math.max(math.floor(tonumber(v70.blockCount) or 0), (math.floor(tonumber(v70.partCount) or 0)))
	local v74 = formatContentMetaDuration(v70.duration)

	if v71 then
		if v72 > 0 and v74 ~= "" then
			return string.format("%s KEYFRAMES - %s", formatNum(v72), v74)
		end

		if v72 > 0 then
			return string.format("%s KEYFRAMES", formatNum(v72))
		end
	else
		if v73 > 0 and v74 ~= "" then
			return string.format("%s BLOCKS - %s", formatNum(v73), v74)
		end

		if v73 > 0 then
			return string.format("%s BLOCKS", formatNum(v73))
		end
	end

	if v74 == "" then
		return ""
	end

	return v74
end

function showToast(value)
	shared._catSfx(15675055424)

	if type(shared) == "table" and type(shared.repfire) == "function" then
		pcall(shared.repfire, {
			Effect = "Notification",
			Title = "NOTIFICATION",
			Text = tostring(value or "")
		})
		return
	end

	toast.Text = "[OK] " .. tostring(value or "")
	toast.Visible = true
	task.delay(2.5, function()
		toast.Visible = false
	end)
end

function trimPendingPsMutations()
	local now2 = tick()

	for k, v70 in pairs(v16) do
		if not (typeof(v70) ~= "table" or (tonumber(v70.expiresAt) or 0) <= now2) then
			continue
		end

		v16[k] = nil
	end
end

fn6 = function()
	trimPendingPsMutations()

	for k, v70 in pairs(v16) do
		if v70.added == true then
			addedToPS[k] = true
		else
			addedToPS[k] = nil
		end
	end
end

function setPendingPsMutation(value, p)
	local v70 = tostring(value or "")

	if v70 == "" then
		return
	end

	invalidateListCache("added")
	v16[v70] = {
		added = p == true,
		expiresAt = tick() + RequestHelper.PENDING_PS_MUTATION_TTL_SEC
	}

	if p == true then
		addedToPS[v70] = true
	else
		addedToPS[v70] = nil
	end
end

function clearPendingPsMutation(value)
	local v70 = tostring(value or "")

	if v70 == "" then
		return
	end

	v16[v70] = nil
end

function updateLocalEntryAddedCount(value, p)
	local v70 = tostring(value or "")

	if v70 == "" then
		return
	end

	local v71 = math.max(0, (math.floor(tonumber(p) or 0)))
	local v72 = entryById and entryById[v70]

	if typeof(v72) == "table" then
		v72.addedCount = v71

		if (tonumber(v72.downloads) or 0) < v71 then
			v72.downloads = v71
		end
	end

	if v24 and tostring(v24.id or "") == v70 then
		v24.addedCount = v71

		if (tonumber(v24.downloads) or 0) < v71 then
			v24.downloads = v71
		end
	end
end

function overlayPendingPsItems(options)
	trimPendingPsMutations()
	local v70 = {}
	local result = {}

	for _, v71 in ipairs(options or {}) do
		local v72 = tostring(not v71 and "" or v71.id or "")
		local v73 = v16[v72]

		if not (v72 ~= "" and (v73 == nil or v73.added == true)) then
			continue
		end

		v70[v72] = true
		table.insert(result, v71)
	end

	for k, v71 in pairs(v16) do
		if v71.added ~= true or v70[k] then
			continue
		end

		local v72 = entryById and entryById[k]

		if typeof(v72) ~= "table" then
			continue
		end

		v70[k] = true
		table.insert(result, v72)
	end

	return result
end

function schedulePsMutationRefresh()
	count2 += 1
	local v70 = count2
	task.spawn(function()
		task.wait(0.75)

		if v70 ~= count2 then
			return
		end

		if v7 == "ADDED_TO_PS" then
			refreshAddedToPS()
		elseif v7 == "BROWSE" then
			refreshBrowse(true)
		end

		updateTabCounts()
		fn5()
	end)
end

function refreshAddedTabImmediatelyIfVisible()
	if v7 ~= "ADDED_TO_PS" then
		return
	end

	listCacheState.lastRendered.added = nil
	task.defer(function()
		if v7 == "ADDED_TO_PS" then
			refreshAddedToPS(false)
		end
	end)
end

function warnMissingUploadSaleField(_) end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEffectiveUploadAllowEditing()
	return v27.allowEditing == true
end

function ensureUploadSaleUi()
	if v27.panel and v27.panel.Parent then
		return true
	end

	if not uploadConfirm then
		return false
	end

	local editableFrame = uploadConfirm:FindFirstChild("EditableFrame")

	if editableFrame == nil then
		warnMissingUploadSaleField("EditableFrame")
	end

	local edit = editableFrame and editableFrame:FindFirstChild("Edit") or nil
	local importCode = uploadConfirm:FindFirstChild("ImportCode", true)

	if not edit then
		warnMissingUploadSaleField("EditableFrame.Edit")
	end

	v27.panel = uploadConfirm
	v27.editToggleBtn = edit
	v27.editToggleBtnOnTextColor = edit and edit.TextColor3 or v27.editToggleBtnOnTextColor
	v27.importCodeLabel = importCode

	if uploadConfirm:GetAttribute("__CatalogueSaleBound") ~= true then
		uploadConfirm:SetAttribute("__CatalogueSaleBound", true)

		if edit and edit:IsA("GuiButton") then
			edit.MouseButton1Click:Connect(function()
				v27.allowEditing = not v27.allowEditing
				refreshUploadSaleUi()
			end)
		end
	end

	return true
end

function refreshUploadSaleUi()
	if not ensureUploadSaleUi() then
		return
	end

	local effectiveUploadAllowEditing = getEffectiveUploadAllowEditing() -- equivalent call inferred; original call site unknown

	if v27.editToggleBtn then
		v27.editToggleBtn.BackgroundColor3 = effectiveUploadAllowEditing and rgb(80, 180, 80) or rgb(198, 198, 198)
		v27.editToggleBtn.Text = effectiveUploadAllowEditing and "ON" or "OFF"
		v27.editToggleBtn.TextColor3 = effectiveUploadAllowEditing and (v27.editToggleBtnOnTextColor or rgb(
			130,
			220,
			130
		)) or v28
	end

	if v27.importCodeLabel then
		if v27.importCodeLabel:IsA("TextBox") then
			v27.importCodeLabel.ClearTextOnFocus = false
			v27.importCodeLabel.TextEditable = true
			v27.importCodeLabel.Active = true
			v27.importCodeLabel.Selectable = true

			if v27.importCodePending then
				v27.importCodeLabel.Text = ""
				v27.importCodeLabel.PlaceholderText = "reserving..."
			elseif v27.latestImportCode == "" then
				v27.importCodeLabel.Text = ""
				v27.importCodeLabel.PlaceholderText = "generated on publish"
			else
				v27.importCodeLabel.Text = tostring(v27.latestImportCode)
				v27.importCodeLabel.PlaceholderText = ""
			end
		elseif v27.importCodePending then
			v27.importCodeLabel.Text = "reserving..."
		elseif v27.latestImportCode == "" then
			v27.importCodeLabel.Text = ""
		else
			v27.importCodeLabel.Text = tostring(v27.latestImportCode)
		end
	end
end

function resetUploadSaleState()
	v27.allowEditing = true
	v27.latestImportCode = ""
	v27.importCodePending = false
	refreshUploadSaleUi()
end

function getUploadImportSourceKey(data)
	if typeof(data) ~= "table" then
		return ""
	end

	local v70 = trimString(data.sourceId or data.sourceRef)

	if v70 then
		return v70
	end

	local v71 = trimString(data.sourceType) or ""
	local v72 = trimString(data.sourceSubtype) or ""
	local v73 = trimString(data.name) or ""

	if v71 == "" and v72 == "" and v73 == "" then
		return ""
	end

	return string.lower(v71 .. "|" .. v72 .. "|" .. v73)
end

function requestUploadImportCode(p, p2)
	local uploadImportSourceKey = getUploadImportSourceKey(p)

	if uploadImportSourceKey == "" then
		v27.importCodePending = false
		v27.latestImportCode = ""
		refreshUploadSaleUi()
	else
		local latestImportCode = v27.importCodesBySourceKey[uploadImportSourceKey]

		if p2 or type(latestImportCode) ~= "string" or latestImportCode == "" then
			v27.importCodeRequestToken += 1
			local importCodeRequestToken = v27.importCodeRequestToken
			v27.importCodePending = true
			v27.latestImportCode = ""
			refreshUploadSaleUi()
			task.spawn(function()
				local success, result = pcall(function()
					return req("PrepareUploadImportCode", {
						sourceId = tostring(p.sourceId or p.sourceRef or "")
					}, 4)
				end)
				local uploadImportSourceKey2 = getUploadImportSourceKey(v26)
				local latestImportCode2 = success and typeof(result) == "table" and result.ok and trimString(result.importCode or result.entry and result.entry.importCode)

				if latestImportCode2 then
					v27.importCodesBySourceKey[uploadImportSourceKey] = latestImportCode2

					if importCodeRequestToken == v27.importCodeRequestToken and uploadImportSourceKey2 == uploadImportSourceKey then
						v27.importCodePending = false
						v27.latestImportCode = latestImportCode2
						refreshUploadSaleUi()
					end
				elseif importCodeRequestToken == v27.importCodeRequestToken and uploadImportSourceKey2 == uploadImportSourceKey then
					v27.importCodePending = false
					v27.latestImportCode = v27.importCodesBySourceKey[uploadImportSourceKey] or ""
					refreshUploadSaleUi()
				end
			end)
		else
			v27.importCodePending = false
			v27.latestImportCode = latestImportCode
			refreshUploadSaleUi()
		end
	end
end

function applyDetailRefs(data)
	detailCard = data and data.card or detailCardApi.defaultCard
	local v70

	if data then
		v70 = data.close or nil
	end

	detClose = v70
	local v71

	if data then
		v71 = data.fav or nil
	end

	detFav = v71
	local v72

	if data then
		v72 = data.addedBadge or nil
	end

	detAddedBadge = v72
	local v73

	if data then
		v73 = data.scroll or nil
	end

	detScroll = v73
	local v74

	if data then
		v74 = data.titleSec or nil
	end

	detTitleSec = v74
	local v75

	if data then
		v75 = data.typeBadge or nil
	end

	detTypeBadge = v75
	local v76

	if data then
		v76 = data.charName or nil
	end

	detCharName = v76
	local v77

	if data then
		v77 = data.subtitle or nil
	end

	detSubtitle = v77
	local v78

	if data then
		v78 = data.creatorRow or nil
	end

	detCreatorRow = v78
	local v79

	if data then
		v79 = data.creatorBtn or nil
	end

	detCreatorBtn = v79
	local v80

	if data then
		v80 = data.timeLabel or nil
	end

	detTimeLabel = v80
	local v81

	if data then
		v81 = data.robuxLabel or nil
	end

	detRobuxLabel = v81
	local v82

	if data then
		v82 = data.tagRow or nil
	end

	detTagRow = v82
	local v83

	if data then
		v83 = data.desc or nil
	end

	detDesc = v83
	local v84

	if data then
		v84 = data.stats or nil
	end

	detStats = v84
	local v85

	if data then
		v85 = data.voteRow or nil
	end

	detVoteRow = v85
	local v86

	if data then
		v86 = data.likeBtn or nil
	end

	detLikeBtn = v86
	local v87

	if data then
		v87 = data.dislikeBtn or nil
	end

	detDislikeBtn = v87
	local v88

	if data then
		v88 = data.actSec or nil
	end

	detActSec = v88
	local v89

	if data then
		v89 = data.addPSBtn or nil
	end

	detAddPSBtn = v89
	local v90

	if data then
		v90 = data.removePSBtn or nil
	end

	detRemovePSBtn = v90
	local v91

	if data then
		v91 = data.reportBtn or nil
	end

	detReportBtn = v91
	local v92

	if data then
		v92 = data.confirmReport or nil
	end

	detConfirmReport = v92
	local v93

	if data then
		v93 = data.movesSec or nil
	end

	detMovesSec = v93
	return data
end

function useDetailCardForEntry(p)
	local v70 = select(1, detailCardApi.selectRefsForEntry(p))
	applyDetailRefs(v70)
	detailCardApi.showOnly(v70)
	return v70
end

function updateDetailCreatorRowMeta(data, p)
	if detCreatorBtn and (detCreatorBtn:IsA("TextLabel") or detCreatorBtn:IsA("TextButton")) then
		local v70

		if p == true then
			v70 = detCreatorBtn.Name == "ByLabel"
		else
			v70 = false
		end

		detCreatorBtn.RichText = true
		detCreatorBtn.Text = formatCreatorLine(
			data and data.creator,
			"",
			detCreatorBtn.Name == "ByLabel",
			v70 and "#FFFFFF" or nil
		)
		applyNameStroke(detCreatorBtn, v70 and 0.6 or nil)
	end

	local text2 = trimString(data and data.uploadedAt)

	if text2 ~= "" and tonumber(text2) then
		text2 = toDateString(text2)
	end

	if text2 == "" then
		text2 = toDateString(data and (data.uploadedTs or data.uploadedAt))
	end

	if detTimeLabel then
		detTimeLabel.Text = text2
	end

	local byLabel = detActSec and detActSec:FindFirstChild("ByLabel", true)

	if byLabel and (byLabel:IsA("TextLabel") or byLabel:IsA("TextButton")) then
		local catalogueDefaultActionMetaText = byLabel:GetAttribute("CatalogueDefaultActionMetaText")

		if typeof(catalogueDefaultActionMetaText) ~= "string" then
			catalogueDefaultActionMetaText = tostring(byLabel.Text or "")
			byLabel:SetAttribute("CatalogueDefaultActionMetaText", catalogueDefaultActionMetaText)
		end

		local entryContentMetaSummary = buildEntryContentMetaSummary(data)

		if entryContentMetaSummary ~= "" and entryContentMetaSummary then
			catalogueDefaultActionMetaText = entryContentMetaSummary
		end

		byLabel.Text = catalogueDefaultActionMetaText
	end

	if detRobuxLabel and (detRobuxLabel:IsA("TextLabel") or detRobuxLabel:IsA("TextButton")) then
		detRobuxLabel.Visible = false
	end
end

function updateDetailActionTypeMeta(p)
	local type2 = detActSec and detActSec:FindFirstChild("Type", true)

	if not (type2 and (type2:IsA("TextLabel") or type2:IsA("TextButton"))) then
		return
	end

	local category = tostring(p and p.category or "Character")
	type2.Text = RequestHelper.CAT_LABELS[category] or string.upper(category)
	type2.Visible = true
	type2.TextColor3 = rgb(255, 255, 255)
	type2.BackgroundColor3 = categoryColors[category] or rgb(200, 60, 60)
end

function findDetailStatValueLabel(childName)
	if not (detStats and detStats:IsA("GuiObject")) then
		return nil
	end

	local guiObject = detStats:FindFirstChild(childName, true)

	if not guiObject then
		return nil
	end

	local value = guiObject:FindFirstChild("Value", true)

	if value and (value:IsA("TextLabel") or value:IsA("TextButton")) then
		return value
	end

	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
		return guiObject
	end

	return nil
end

function setDetailStatText(p, text2, p2)
	local detailStatValueLabel = findDetailStatValueLabel(p)

	if detailStatValueLabel then
		detailStatValueLabel.Text = text2
		return true
	end

	detailCardApi.warnMissingOnce(
		"detail_stat_" .. tostring(p2),
		string.format(
			"[GlobalCatalogue][UIWarn] detail stat label missing stat=%s activeCard=%s",
			tostring(p),
			(tostring(detailCard and detailCard.Name or "nil"))
		)
	)
	return false
end

function setMoveSlotText(instance, text2)
	local function applyMoveSlotLabel(guiObject)
		if not (guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton"))) then
			return false
		end

		local catalogueDefaultTextTransparency = guiObject:GetAttribute("CatalogueDefaultTextTransparency")

		if typeof(catalogueDefaultTextTransparency) ~= "number" then
			catalogueDefaultTextTransparency = guiObject.TextTransparency
			guiObject:SetAttribute("CatalogueDefaultTextTransparency", catalogueDefaultTextTransparency)
		end

		guiObject.Text = text2

		if trimString(text2) == "NONE" then
			guiObject.TextTransparency = math.clamp(catalogueDefaultTextTransparency - 0.2, 0, 1)
		else
			guiObject.TextTransparency = catalogueDefaultTextTransparency
		end

		return true
	end

	if not instance then
		return false
	end

	if applyMoveSlotLabel(instance) or applyMoveSlotLabel(instance:FindFirstChild("MoveLabel", true)) then
		return true
	end

	return false
end

function populateCharacterMovesSection(p)
	local detMovesSec2 = detMovesSec

	if not (detMovesSec2 and detMovesSec2:IsA("GuiObject")) then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function detailMoveText(p2)
		local v70 = trimString(asMoveLabel(p2))

		if v70 == "" or v70 == "-" then
			return "NONE"
		end

		return v70
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setNamedSlot(guiObject, childName, p2)
		if not (guiObject and guiObject:IsA("GuiObject")) then
			return false
		end

		local child = guiObject:FindFirstChild(childName)

		if not child then
			return false
		end

		local setMoveSlotText2 = setMoveSlotText
		return setMoveSlotText2(child, detailMoveText(p2))
	end

	local baseMovesHolder = detMovesSec2:FindFirstChild("BaseMovesHolder")
	local ultMovesHolder = detMovesSec2:FindFirstChild("UltMovesHolder")
	local v70 = false

	for i = 1, 4 do
		local v73 = setNamedSlot(baseMovesHolder, "BaseMove" .. i, p.moves and p.moves.base and p.moves.base[i]) -- equivalent call inferred; original call site unknown
		local v77 = setNamedSlot(ultMovesHolder, "AwkMove" .. i, p.moves and p.moves.awaken and p.moves.awaken[i]) -- equivalent call inferred; original call site unknown
		v70 = v77 or v73 or v70
	end

	local m1Style = detMovesSec2:FindFirstChild("M1Style")
	local m1Style2 = p.moves and p.moves.m1Style
	local v71 = setNamedSlot(m1Style, "BaseMove1", m1Style2) -- equivalent call inferred; original call site unknown
	local awakenAnim = detMovesSec2:FindFirstChild("AwakenAnim")
	local awakenAnim2 = p.moves and p.moves.awakenAnim
	local v73 = setNamedSlot(awakenAnim, "BaseMove1", awakenAnim2) -- equivalent call inferred; original call site unknown
	local spawnAnim = detMovesSec2:FindFirstChild("SpawnAnim")
	local spawnAnim2 = p.moves and p.moves.spawnAnim
	local v75 = setNamedSlot(spawnAnim, "BaseMove1", spawnAnim2) -- equivalent call inferred; original call site unknown

	if (v75 or v73 or v71 or v70) ~= true then
		detailCardApi.warnMissingOnce(
			"detail_moves_layout_" .. tostring(detailCard and detailCard.Name or "unknown"),
			string.format(
				"[GlobalCatalogue][UIWarn] character detail moves layout not recognized card=%s section=%s",
				tostring(detailCard and detailCard.Name or "nil"),
				(tostring(detMovesSec2:GetFullName()))
			)
		)
	end
end

applyDetailRefs(detailCardApi.defaultRefs)

function isPointInside(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return false
	end

	local absolutePosition = guiObject.AbsolutePosition
	local absoluteSize = guiObject.AbsoluteSize
	return p.X >= absolutePosition.X and p.X <= absolutePosition.X + absoluteSize.X and p.Y >= absolutePosition.Y and p.Y <= absolutePosition.Y + absoluteSize.Y
end

setmetatable({}, {
	__mode = "k"
})

function bindGuiDrag(_, _, _) end

function startPopupCooldown()
	flag = true
	task.delay(0.15, function()
		flag = false
	end)
end

function hover(p, callback, callback2)
	p.MouseEnter:Connect(function()
		callback(p)
	end)
	p.MouseLeave:Connect(function()
		callback2(p)
	end)
end

function hoverStroke(p, color, transparency, color2, transparency2)
	hover(p, function(instance)
		local uIStroke = instance:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = color
			uIStroke.Transparency = transparency
		end
	end, function(instance)
		local uIStroke = instance:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = color2
			uIStroke.Transparency = transparency2
		end
	end)
end

function rememberButtonVisual(p, guiObject)
	local v70 = p[guiObject]

	if v70 then
		return v70
	end

	local uIStroke = guiObject:FindFirstChildWhichIsA("UIStroke")
	local textColor2

	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
		textColor2 = guiObject.TextColor3 or nil
	end

	local v71 = {
		TextColor3 = textColor2,
		BackgroundColor3 = guiObject.BackgroundColor3,
		BackgroundTransparency = guiObject.BackgroundTransparency,
		StrokeColor = 0,
		StrokeTransparency = 0
	}
	local strokeColor

	if uIStroke then
		strokeColor = uIStroke.Color or nil
	end

	v71.StrokeColor = strokeColor
	v71.StrokeTransparency = uIStroke and uIStroke.Transparency or nil
	p[guiObject] = v71
	return v71
end

function restoreButtonVisual(p, instance)
	local v70 = rememberButtonVisual(p, instance)

	if v70.TextColor3 ~= nil then
		instance.TextColor3 = v70.TextColor3
	end

	instance.BackgroundColor3 = v70.BackgroundColor3
	instance.BackgroundTransparency = v70.BackgroundTransparency
	local uIStroke = instance:FindFirstChildWhichIsA("UIStroke")

	if uIStroke and v70.StrokeColor ~= nil then
		uIStroke.Color = v70.StrokeColor
		uIStroke.Transparency = v70.StrokeTransparency or uIStroke.Transparency
	end
end

function findFirstDescendantOfClass(folder, className)
	if not folder then
		return nil
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA(className) then
			return descendant
		end
	end

	return nil
end

function getVerifiedAvatarHeadshot(p)
	local v70 = tonumber(p)

	if not v70 or v70 <= 0 then
		return nil, false
	end

	local now2 = os.clock()
	sweepVerifiedAvatarThumbCache(now2)
	local v71 = v50[v70]

	if v71 and now2 < (tonumber(v71.expiresAt) or 0) then
		return v71.image, v71.ready == true
	end

	local success, userThumbnailAsync, v72 = pcall(
		Players.GetUserThumbnailAsync,
		Players,
		v70,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size180x180
	)

	if not success then
		v50[v70] = {
			image = nil,
			ready = false,
			expiresAt = now2 + RequestHelper.VERIFIED_AVATAR_CACHE_FAILURE_TTL
		}
		return nil, false
	end

	local ready

	if typeof(userThumbnailAsync) == "string" and userThumbnailAsync ~= "" then
		ready = v72 == true
	else
		ready = false
	end

	v50[v70] = {
		image = ready and userThumbnailAsync or nil,
		ready = ready,
		expiresAt = now2 + (ready and RequestHelper.VERIFIED_AVATAR_CACHE_SUCCESS_TTL or RequestHelper.VERIFIED_AVATAR_CACHE_FAILURE_TTL)
	}
	return v50[v70].image, v50[v70].ready
end

function applyVerifiedAvatar(instance, p)
	local avatar = instance:FindFirstChild("Avatar", true)

	if not avatar then
		return
	end

	local imageLabel = avatar:FindFirstChildWhichIsA("ImageLabel") or findFirstDescendantOfClass(avatar, "ImageLabel")
	local label = avatar:FindFirstChild("Label", true) or avatar:FindFirstChildWhichIsA("TextLabel") or findFirstDescendantOfClass(
		avatar,
		"TextLabel"
	)
	local verifiedAvatarHeadshot, visible = getVerifiedAvatarHeadshot(p)

	if imageLabel then
		imageLabel.Image = visible and verifiedAvatarHeadshot or ""
		imageLabel.Visible = visible
	end

	if label and (label:IsA("TextLabel") or label:IsA("ImageLabel")) then
		label.Visible = not visible
	end
end

function warnMissingLeaderboardTemplateField(_) end

function cloneLeaderboardProfileRow()
	if not (leaderboardProfileTemplate and leaderboardProfileTemplate:IsA("GuiObject")) then
		warnMissingLeaderboardTemplateField("script.LeaderboardTemplate")
		return nil
	end

	local clone = leaderboardProfileTemplate:Clone()
	clone.Visible = true
	clone.Active = true
	return clone
end

function findLeaderboardProfileField(instance, childName)
	if not instance then
		return nil
	end

	local child = instance:FindFirstChild(childName, true)

	if not child then
		warnMissingLeaderboardTemplateField(childName)
	end

	return child
end

function applyLeaderboardProfileAvatar(instance, p)
	local avatar = instance and instance:FindFirstChild("Avatar") or nil

	if not avatar then
		warnMissingLeaderboardTemplateField("Avatar")
		return
	end

	local avatar2 = avatar:FindFirstChild("Avatar")

	if avatar2 and (avatar2:IsA("ImageLabel") or avatar2:IsA("ImageButton")) then
		local verifiedAvatarHeadshot, v70 = getVerifiedAvatarHeadshot(p)
		avatar2.Image = v70 and verifiedAvatarHeadshot or ""
	else
		warnMissingLeaderboardTemplateField("Avatar.Avatar<ImageLabel>")
	end
end

function getLeaderboardUserName(p)
	local v70 = math.max(0, (math.floor(tonumber(p) or 0)))

	if v70 <= 0 then
		return nil, true
	end

	local playerByUserId = Players:GetPlayerByUserId(v70)

	if playerByUserId then
		local v71 = trimString(playerByUserId.Name)

		if v71 ~= "" then
			v51[v70] = v71
			return v71, true
		end
	end

	local v71 = v51[v70]

	if v71 == nil then
		if v52[v70] ~= true then
			v52[v70] = true
			task.spawn(function()
				local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, v70)
				v52[v70] = nil

				if not success then
					v51[v70] = ""
					return
				end

				local v72 = trimString(nameFromUserIdAsync)
				v51[v70] = (v72 == "" or not v72) and "" or v72
			end)
		end

		return nil, false
	else
		if v71 == "" or not v71 then
			v71 = nil
		end

		return v71, true
	end
end

function formatLeaderboardUserDisplayName(p, p2)
	local v70 = trimString(p)
	local selected = v70 == "" and "Unknown" or v70
	local v72 = trimString(p2)

	if v72 == "" then
		return selected
	end

	return string.format("%s (@%s)", selected, v72)
end

function resolveExactCreatorSearchUser(p)
	local v70 = trimString(p)

	if v70 == "" then
		return nil
	end

	local v71 = string.lower(v70)
	local v72 = v70 == tostring(localPlayer.UserId) or string.lower(v70) == string.lower(localPlayer.Name or "")
	local v73 = v53[v71]

	if v72 or v73 == nil then
		local userName = ""
		local userId

		if string.match(v70, "^%d+$") then
			userId = math.max(0, (math.floor(tonumber(v70) or 0)))

			if userId <= 0 then
				v53[v71] = false
				return nil
			end

			local leaderboardUserName, v76 = getLeaderboardUserName(userId)

			if v76 and trimString(leaderboardUserName) ~= "" then
				userName = trimString(leaderboardUserName)
			else
				local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, userId)

				if success then
					userName = trimString(nameFromUserIdAsync)
					v51[userId] = (userName == "" or not userName) and "" or userName
				end
			end
		else
			if string.find(v70, "%s") or not string.match(v70, "^[%w_]+$") or #v70 < RequestHelper.SEARCH_MIN_TOKEN_LENGTH then
				v53[v71] = false
				return nil
			end

			local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, v70)

			if not success then
				v53[v71] = false
				return nil
			end

			userId = math.max(0, (math.floor(tonumber(userIdFromNameAsync) or 0)))

			if userId <= 0 then
				v53[v71] = false
				return nil
			else
				v51[userId] = v70
				userName = v70
			end
		end

		local name

		if userName == "" or not userName then
			name = "User" .. tostring(userId)
		else
			name = userName
		end

		local v76 = {
			userId = userId,
			name = name,
			userName = userName,
			verified = false,
			totalUploads = 0,
			totalLikes = 0,
			totalDislikes = 0,
			totalFavorites = 0,
			totalUses = 0,
			totalAdded = 0,
			totalDownloads = 0,
			matchKind = "user_exact"
		}

		if userId == localPlayer.UserId then
			syncMine(false)
			local count3 = 0
			local total = 0
			local total2 = 0
			local total3 = 0
			local total4 = 0
			local total5 = 0

			for _, v78 in ipairs(v19 or {}) do
				count3 += 1
				total += math.max(0, (math.floor(tonumber(v78.likes) or 0)))
				total2 += math.max(0, (math.floor(tonumber(v78.dislikes) or 0)))
				total3 += math.max(0, (math.floor(tonumber(v78.favourites or v78.favorites) or 0)))
				total4 += math.max(0, (math.floor(tonumber(v78.uses) or tonumber(v78.downloads) or 0)))
				total5 += math.max(0, (math.floor(tonumber(v78.addedCount) or 0)))
			end

			v76.totalUploads = count3
			v76.totalLikes = total
			v76.totalDislikes = total2
			v76.totalFavorites = total3
			v76.totalUses = total4
			v76.totalAdded = total5
			v76.totalDownloads = math.max(total4, total5)
		end

		if not v72 then
			v53[v71] = v76
		end

		return v76
	else
		if v73 == false or not v73 then
			return nil
		end

		return v73
	end
end

function bindLeaderboardProfileName(guiObject, p, p2, p3)
	if not (guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton"))) then
		return
	end

	guiObject.RichText = false
	local v70 = trimString(p)
	local v71 = v70 == "" and "Unknown" or v70
	local leaderboardUserName, v72 = getLeaderboardUserName(p2)
	guiObject.Text = formatLeaderboardUserDisplayName(v71, leaderboardUserName)

	if v72 then
		return
	end

	local v73 = tonumber(p3) or 0
	local v74 = math.max(0, (math.floor(tonumber(p2) or 0)))
	task.spawn(function()
		for _ = 1, 40 do
			if not (v73 == v41.leaderboard and (guiObject and guiObject.Parent)) then
				break
			end

			local v75 = v51[v74]

			if v75 == nil then
				task.wait(0.05)
			else
				guiObject.Text = formatLeaderboardUserDisplayName(v71, v75)
				break
			end
		end
	end)
end

function resolveHeaderIconLabel(instance)
	if not instance then
		return nil
	end

	for _, childName in ipairs({
		"CategoryIcon",
		"HeaderIcon",
		"Icon",
		"Label"
	}) do
		local guiObject = instance:FindFirstChild(childName)

		if guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
			return guiObject
		end
	end

	for _, guiObject in ipairs(instance:GetChildren()) do
		if (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) and guiObject.Name ~= "HeaderLine" then
			return guiObject
		end
	end

	return nil
end

function applyCardHeaderMedia(instance, p, p2)
	if not instance then
		return false
	end

	local catalogueImage = normalizeCatalogueImage(p2)
	local v70 = RequestHelper.CATEGORY_DEFAULT_IMAGES[p] or RequestHelper.CATEGORY_DEFAULT_IMAGES.Move
	local visible

	if typeof(catalogueImage) == "string" then
		visible = catalogueImage ~= ""
	else
		visible = false
	end

	local realImage = instance:FindFirstChild("RealImage", true)

	if realImage and (realImage:IsA("ImageLabel") or realImage:IsA("ImageButton")) then
		realImage.BackgroundTransparency = 1
		realImage.Image = visible and catalogueImage or ""
		realImage.Visible = visible
	end

	local templateImage = instance:FindFirstChild("TemplateImage", true)
	local visible2

	if templateImage and (templateImage:IsA("ImageLabel") or templateImage:IsA("ImageButton")) then
		visible2 = not visible

		if visible2 then
			if typeof(v70) == "string" then
				visible2 = v70 ~= ""
			else
				visible2 = false
			end
		end

		templateImage.BackgroundTransparency = 1
		templateImage.Image = visible2 and v70 or ""
		templateImage.Visible = visible2
	else
		visible2 = false
	end

	local headerIconLabel = resolveHeaderIconLabel(instance)

	if headerIconLabel then
		headerIconLabel.Text = RequestHelper.CAT_ICONS[p] or RequestHelper.CAT_ICONS.Character
		headerIconLabel.Visible = not (visible or visible2)
	end

	return visible
end

function makeTagChip(parent2, text2, p, p2, value)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Tag_" .. text2
	textLabel.Text = text2
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = p and 8 or 10
	textLabel.TextColor3 = p2 and rgb(200, 60, 60) or rgb(140, 140, 140)
	textLabel.BackgroundColor3 = p2 and rgb(200, 60, 60) or rgb(255, 255, 255)
	textLabel.BackgroundTransparency = p2 and 0.88 or 0.96
	textLabel.Size = UDim2.new(0, 0, 0, p and 14 or 18)
	textLabel.AutomaticSize = Enum.AutomaticSize.X
	textLabel.BorderSizePixel = 0
	textLabel.LayoutOrder = value or 0
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 10)
	uICorner.Parent = textLabel
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = p2 and rgb(200, 60, 60) or rgb(255, 255, 255)
	uIStroke.Thickness = 1
	uIStroke.Transparency = p2 and 0.7 or 0.92
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Parent = textLabel
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 6)
	uIPadding.PaddingRight = UDim.new(0, 6)
	uIPadding.Parent = textLabel
	textLabel.Parent = parent2
	return textLabel
end

local v70 = {
	"Character",
	"Map",
	"Move",
	"AwakenMove",
	"SpawnAnim",
	"AwakenAnim",
	"M1Style",
	"WallCombo",
	"ForwardDash",
	"Effect",
	"CreatedAnim",
	"Server Characters"
}
local v71 = {
	Character = "Characters",
	Map = "Maps",
	Move = "Moves",
	SpawnAnim = "Spawn Anims",
	AwakenMove = "Awaken Moves",
	AwakenAnim = "Awaken Anims",
	M1Style = "M1 Styles",
	WallCombo = "Wall Combos",
	ForwardDash = "Forward Dashes",
	Effect = "Effects",
	CreatedAnim = "Animations"
}

function groupByCategory(list)
	local result = {}

	for _, v72 in ipairs(v70) do
		result[v72] = {}
	end

	for _, v72 in ipairs(list) do
		local v73

		if typeof(v72) == "table" then
			v73 = v65[tostring(v72.type)] == true
		else
			v73 = false
		end

		if v73 then
			continue
		end

		local v74 = v72.serverChar and "Server Characters" or v72.category or "Character"

		if not result[v74] then
			result[v74] = {}
		end

		table.insert(result[v74], v72)
	end

	return result
end

local textColor4 = rgb(125, 225, 135)
local v73 = rgb(235, 120, 120)

function panelMakeBox(parent2, name, position, size, value, value2)
	local textBox = Instance.new("TextBox")
	textBox.Name = name
	textBox.Position = position
	textBox.Size = size
	textBox.BackgroundColor3 = rgb(255, 255, 255)
	textBox.BackgroundTransparency = 0.9
	textBox.BorderSizePixel = 0
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 12
	textBox.TextColor3 = rgb(240, 240, 240)
	textBox.PlaceholderColor3 = rgb(150, 150, 150)
	textBox.PlaceholderText = value or ""
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.ClearTextOnFocus = false
	textBox.Text = value2 or ""
	textBox.Parent = parent2
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 8)
	uIPadding.PaddingRight = UDim.new(0, 8)
	uIPadding.Parent = textBox
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 5)
	uICorner.Parent = textBox
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = rgb(90, 90, 90)
	uIStroke.Thickness = 1
	uIStroke.Transparency = 0.5
	uIStroke.Parent = textBox
	return textBox
end

function panelMakeButton(parent2, name, text2, position, size, p, p2)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Position = position
	textButton.Size = size
	textButton.BackgroundColor3 = p or rgb(55, 55, 55)
	textButton.BackgroundTransparency = 0.25
	textButton.BorderSizePixel = 0
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 11
	textButton.TextColor3 = p2 or rgb(240, 240, 240)
	textButton.Text = text2
	textButton.AutoButtonColor = false
	textButton.Parent = parent2
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 5)
	uICorner.Parent = textButton
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = rgb(255, 255, 255)
	uIStroke.Thickness = 1
	uIStroke.Transparency = 0.75
	uIStroke.Parent = textButton
	return textButton
end

function panelSetStatus(value, p)
	if not v55.status then
		return
	end

	v55.status.TextColor3 = p == false and v73 or textColor4
	v55.status.Text = tostring(value or "")
end

function panelTargetUserId()
	local text2 = v55.targetUserInput and v55.targetUserInput.Text or ""
	return (math.floor(tonumber((trimString(text2))) or 0))
end

function panelResolveCreatorName()
	if v55.creatorNameInput then
		return trimString(v55.creatorNameInput.Text or "")
	end

	return ""
end

function panelWipeListingRows()
	local listScroll = v55.listScroll

	if not listScroll then
		return
	end

	for _, guiObject in ipairs(listScroll:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and (string.find(guiObject.Name, "PanelRow_", 1, true) or string.find(
			guiObject.Name,
			"PanelMapRow_",
			1,
			true
		))) then
			continue
		end

		guiObject:Destroy()
	end
end

function panelRefreshSummary()
	if not v then
		return
	end

	local summary = v55.summary

	if summary then
		summary.Text = "Loading panel summary..."
	end

	local v74 = req("AdminPanelSummary", {}, 3)

	if v74 and v74.ok and typeof(v74.counts) == "table" then
		local counts = v74.counts

		if summary then
			summary.Text = string.format(
				"Creators %s  |  Verified %s  |  Active %s  |  Taken Down %s  |  Deleted %s  |  Reports %s",
				formatNum(tonumber(counts.creators) or 0),
				formatNum(tonumber(counts.verifiedCreators) or 0),
				formatNum(tonumber(counts.activeListings) or 0),
				formatNum(tonumber(counts.takenDownListings) or 0),
				formatNum(tonumber(counts.deletedListings) or 0),
				formatNum(tonumber(counts.totalReports) or 0)
			)
		end
	else
		panelSetStatus("Panel summary failed: " .. tostring(v74 and v74.error or "unknown"), false)

		if summary then
			summary.Text = "Summary unavailable"
		end
	end
end

function panelListingAction(value, value2)
	local entryId = tostring(value or "")

	if entryId == "" then
		panelSetStatus("Missing entry id", false)
		return
	end

	local v75 = "panel-listing-" .. entryId .. "-" .. tostring(value2 or "")

	if not claimActionDebounce(v75, entryId, 0.25) then
		return
	end

	local v76 = req("AdminSetListingStatus", {
		entryId = entryId,
		status = value2
	}, 3)

	if not (v76 and v76.ok) then
		panelSetStatus("Listing update failed: " .. tostring(v76 and v76.error or "unknown"), false)
		return
	end

	panelSetStatus("Listing " .. entryId .. " -> " .. tostring(value2), true)
	panelRefreshSummary()
	panelRefreshCreatorListings()

	if v7 == "BROWSE" then
		refreshBrowseStatsOnly()
	end
end

function panelBuildListingRow(data, layoutOrder)
	local listScroll = v55.listScroll

	if not listScroll then
		return
	end

	local id = tostring(data.id or "")
	local status = tostring(data.status or "active")
	local frame = Instance.new("Frame")
	frame.Name = "PanelRow_" .. id
	frame.Size = UDim2.new(1, -6, 0, 62)
	frame.BackgroundColor3 = rgb(255, 255, 255)
	frame.BackgroundTransparency = 0.93
	frame.BorderSizePixel = 0
	frame.LayoutOrder = layoutOrder
	frame.Parent = listScroll
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 6)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = rgb(255, 255, 255)
	uIStroke.Thickness = 1
	uIStroke.Transparency = 0.85
	uIStroke.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(0, 8, 0, 4)
	textLabel.Size = UDim2.new(1, -220, 0, 20)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 12
	textLabel.TextColor3 = rgb(245, 245, 245)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = tostring(data.name or "Untitled")
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Info"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.new(0, 8, 0, 24)
	textLabel2.Size = UDim2.new(1, -220, 0, 16)
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextSize = 10
	textLabel2.TextColor3 = rgb(170, 170, 170)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Text = string.format(
		"%s | %s | reports %s | likes %s",
		tostring(data.type or "item"),
		status,
		formatNum(tonumber(data.reportCount) or 0),
		formatNum(tonumber(data.likes) or 0)
	)
	textLabel2.Parent = frame
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "EntryId"
	textLabel3.BackgroundTransparency = 1
	textLabel3.Position = UDim2.new(0, 8, 1, -18)
	textLabel3.Size = UDim2.new(1, -220, 0, 14)
	textLabel3.Font = Enum.Font.Gotham
	textLabel3.TextSize = 9
	textLabel3.TextColor3 = rgb(120, 120, 120)
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.Text = id
	textLabel3.Parent = frame
	local v74 = panelMakeButton(
		frame,
		"TakeDownBtn",
		"TAKE DOWN",
		UDim2.new(1, -210, 0, 7),
		UDim2.new(0, 64, 0, 22),
		rgb(130, 50, 50),
		rgb(255, 190, 190)
	)
	local v75 = panelMakeButton(
		frame,
		"RestoreBtn",
		"RESTORE",
		UDim2.new(1, -141, 0, 7),
		UDim2.new(0, 64, 0, 22),
		rgb(40, 110, 60),
		rgb(180, 245, 190)
	)
	local v76 = panelMakeButton(
		frame,
		"DeleteBtn",
		"DELETE",
		UDim2.new(1, -72, 0, 7),
		UDim2.new(0, 64, 0, 22),
		rgb(120, 40, 40),
		rgb(255, 170, 170)
	)
	v74.MouseButton1Click:Connect(function()
		panelListingAction(id, "taken_down")
	end)
	v75.MouseButton1Click:Connect(function()
		panelListingAction(id, "active")
	end)
	v76.MouseButton1Click:Connect(function()
		panelListingAction(id, "deleted")
	end)
end

function panelRenderListings(options)
	v55.listings = options or {}
	v55.mapSaves = {}
	v55.activeMapTargetUserId = 0
	panelWipeListingRows()
	local listScroll = v55.listScroll

	if not listScroll then
		return
	end

	if #v55.listings == 0 then
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "PanelRow_Empty"
		textLabel.Size = UDim2.new(1, -6, 0, 30)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Gotham
		textLabel.TextSize = 12
		textLabel.TextColor3 = rgb(145, 145, 145)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = "No listings found for this creator."
		textLabel.LayoutOrder = 1
		textLabel.Parent = listScroll
	else
		for i, listing in ipairs(v55.listings) do
			panelBuildListingRow(listing, i)

			if i % 12 == 0 then
				task.wait()
			end
		end
	end
end

function panelFormatSavedAt(p)
	local v74 = math.floor(tonumber(p) or 0)

	if v74 <= 0 then
		return "unknown"
	end

	local success, result = pcall(function()
		return os.date("%Y-%m-%d %H:%M", v74)
	end)

	if success and type(result) == "string" and result ~= "" then
		return result
	end

	return (tostring(v74))
end

local v74 = 0
local v75 = 0
local v76 = nil
local count3 = 0

function claimMapLoadDebounce()
	local now2 = os.clock()

	if now2 < v74 then
		return false, v74 - now2
	end

	v74 = now2 + 10
	return true, 0
end

function claimMapClearDebounce()
	local now2 = os.clock()

	if now2 < v75 then
		return false, v75 - now2
	end

	v75 = now2 + 1.5
	return true, 0
end

function parseMapRefFromEntry(data)
	if typeof(data) ~= "table" then
		return 0, 0
	end

	local mapSourceUserId = math.floor(tonumber(data.mapSourceUserId) or 0)
	local mapSlot = math.floor(tonumber(data.mapSlot) or 0)

	if (mapSourceUserId <= 0 or mapSlot <= 0) and typeof(data.config) == "table" then
		local mapRef = nil

		if typeof(data.config.mapRef) == "table" then
			mapRef = data.config.mapRef
		elseif typeof(data.config.map) == "table" then
			mapRef = data.config.map
		end

		if typeof(mapRef) == "table" then
			mapSourceUserId = math.floor(tonumber(mapRef.sourceUserId or mapRef.userId or mapRef.uid) or mapSourceUserId)
			mapSlot = math.floor(tonumber(mapRef.slot or mapRef.slotNumber) or mapSlot)
		end
	end

	if mapSourceUserId <= 0 or mapSlot <= 0 then
		local v77, v78 = string.match(tostring(data.sourceRef or ""), "^psmap:(%d+):(%d+)$")

		if v77 and v78 then
			mapSourceUserId = math.floor(tonumber(v77) or mapSourceUserId)
			mapSlot = math.floor(tonumber(v78) or mapSlot)
		end
	end

	return mapSourceUserId, mapSlot
end

function isCatalogueMapAlreadyLoaded(p, p2)
	local v77 = math.floor(tonumber(p) or 0)
	local v78 = math.floor(tonumber(p2) or 0)
	return not (v77 <= 0 or v78 <= 0) and workspace:GetAttribute("CatMapLoaded_" .. v77 .. "_" .. v78) == true
end

function fireCatalogueMapLoad(sourceUserId, p2, value)
	if not catGiveCanGiveToOthers() then
		showToast("ONLY SERVER OWNER CAN LOAD MAPS")
		return false, "not-owner"
	end

	local commRemote = getCommRemote(4)

	if not commRemote then
		showToast("Load map failed: communicate remote missing")
		return false, "communicate-remote-missing"
	end

	commRemote:FireServer({
		Goal = "PS Build",
		Todo = "Load " .. tostring(p2),
		SourceUserId = sourceUserId,
		Source = value or "GlobalCatalogue",
		Catalogue = true
	})
	showToast(string.format("Loading map slot %d from user %d", p2, sourceUserId))
	return true, nil
end

function queueCatalogueMapLoad(sourceUserId, slot, value, p3)
	count3 += 1
	local v77 = count3
	v76 = {
		sourceUserId = sourceUserId,
		slot = slot,
		sourceLabel = value or "GlobalCatalogue"
	}
	local v78 = math.max(0.05, tonumber(p3) or 0.05)
	showToast(string.format("Map load queued (%.1fs)", v78))
	local attemptQueuedLoad

	attemptQueuedLoad = function()
		if v77 ~= count3 then
			return
		end

		local v79 = v76

		if not v79 then
			return
		end

		local v80, v81 = claimMapLoadDebounce()

		if not v80 then
			task.delay(math.max(0.05, v81) + 0.05, attemptQueuedLoad)
			return
		end

		v76 = nil
		fireCatalogueMapLoad(v79.sourceUserId, v79.slot, v79.sourceLabel)
	end

	task.delay(v78 + 0.05, attemptQueuedLoad)
	return true, "load-queued"
end

function requestCatalogueMapLoad(p, p2, p3)
	local _ = typeof(p3) == "table" and p3
	local v77, v78 = parseMapRefFromEntry(p)

	if v77 <= 0 or v78 <= 0 then
		showToast("Load map failed: missing source map reference")
		return false, "missing-map-ref"
	end

	if isCatalogueMapAlreadyLoaded(v77, v78) then
		showToast("Refused, this map is already loaded")
		return false, "already-loaded"
	end

	if claimMapLoadDebounce() then
		return fireCatalogueMapLoad(v77, v78, p2)
	end

	showToast("A different map is loading, wait until it is done to load this one")
	return false, "map-loading"
end

function requestCatalogueMapCleanup(value, p)
	local v77 = typeof(p) == "table" and p or {}
	count3 += 1
	v76 = nil

	if v77.skipDebounce ~= true and not claimMapClearDebounce() then
		return false, "cleanup-cooldown"
	end

	local commRemote = getCommRemote(4)

	if not commRemote then
		return false, "communicate-remote-missing"
	end

	commRemote:FireServer({
		Goal = "PS Build",
		Todo = "Clear Loaded",
		Source = value or "GlobalCatalogue",
		Catalogue = true
	})
	return true, nil
end

local v77 = {
	state = {},
	token = {},
	anim = 0,
	dots = 0
}

function catMapKeyFromEntry(p)
	local v78, v79 = parseMapRefFromEntry(p)

	if v78 <= 0 or v79 <= 0 then
		return nil
	end

	return v78 .. ":" .. v79
end

function catMapDots()
	return string.rep(".", v77.dots % 3 + 1)
end

function catMapButtonTextByKey(value, p)
	local v78 = value and v77.state[value]

	if v78 == "waiting" then
		return "WAITING" .. catMapDots()
	elseif v78 == "loading" then
		return "LOADING" .. catMapDots()
	elseif v78 == "removing" then
		return "REMOVING" .. catMapDots()
	end

	local v79 = false

	if value then
		local v80, v81 = string.match(value, "^(%d+):(%d+)$")

		if v80 then
			v79 = isCatalogueMapAlreadyLoaded(tonumber(v80), (tonumber(v81)))
		end
	end

	if p == "detail" then
		if v79 then
			return "REMOVE MAP"
		end

		return "LOAD MAP"
	elseif v79 then
		return "REMOVE"
	else
		return "LOAD"
	end
end

function catMapButtonColor(value)
	local v78 = value and v77.state[value]

	if v78 == "waiting" or v78 == "loading" or v78 == "removing" then
		return Color3.fromRGB(120, 120, 120)
	end

	local v79 = false

	if value then
		local v80, v81 = string.match(value, "^(%d+):(%d+)$")

		if v80 then
			v79 = isCatalogueMapAlreadyLoaded(tonumber(v80), (tonumber(v81)))
		end
	end

	if v79 then
		return Color3.fromRGB(168, 62, 62)
	end

	return Color3.fromRGB(78, 151, 81)
end

function applyCatMapAddedRows(p)
	if not addedScroll then
		return
	end

	for _, child in ipairs(addedScroll:GetChildren()) do
		local catMapKeyStr = child:GetAttribute("CatMapKeyStr")

		if not (catMapKeyStr and (p == nil or catMapKeyStr == p)) then
			continue
		end

		local botRow = child:FindFirstChild("BotRow")
		local removeBtn = botRow and botRow:FindFirstChild("RemoveBtn")

		if not (removeBtn and removeBtn:IsA("TextButton")) then
			continue
		end

		removeBtn.Text = catMapButtonTextByKey(catMapKeyStr, "added")
		removeBtn.BackgroundColor3 = catMapButtonColor(catMapKeyStr)
	end
end

function applyCatMapDetailButton()
	if not v24 or not charDetailOverlay or not charDetailOverlay.Visible or v24.category ~= "Map" then
		return
	end

	if not (detAddPSBtn and (detAddPSBtn:IsA("TextButton") or detAddPSBtn:IsA("TextLabel"))) then
		return
	end

	local v78 = catMapKeyFromEntry(v24)
	local v79 = v78 and v77.state[v78]

	if v79 ~= "waiting" and v79 ~= "loading" and v79 ~= "removing" then
		updateDetailPS()
		return
	end

	detAddPSBtn.Text = catMapButtonTextByKey(v78, "detail")
	detAddPSBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
end

function refreshCatMapButtons(p)
	applyCatMapDetailButton()
	applyCatMapAddedRows(p)
end

function startCatMapAnim()
	if v77.anim > 0 then
		return
	end

	v77.anim += 1
	local anim = v77.anim
	task.spawn(function()
		while v77.anim == anim do
			local v79 = false

			for _ in pairs(v77.state) do
				v79 = true
				break
			end

			if not v79 then
				break
			end

			v77.dots += 1
			refreshCatMapButtons(nil)
			task.wait(0.4)
		end

		if v77.anim == anim then
			v77.anim = 0
		end
	end)
end

function setCatMapOpState(p, p2)
	if not p then
		return
	end

	v77.state[p] = p2
	v77.token[p] = (v77.token[p] or 0) + 1
	local v78 = v77.token[p]
	local v79 = p2 == "waiting" and 12 or 360
	task.delay(v79, function()
		if v77.token[p] == v78 and v77.state[p] == p2 then
			v77.state[p] = nil
			refreshCatMapButtons(p)
		end
	end)
	startCatMapAnim()
	refreshCatMapButtons(p)
end

function clearCatMapOpState(p)
	if not p then
		return
	end

	v77.token[p] = (v77.token[p] or 0) + 1
	v77.state[p] = nil
	refreshCatMapButtons(p)
end

function requestCatalogueMapRemove(p, value)
	local sourceUserId, slot = parseMapRefFromEntry(p)

	if sourceUserId <= 0 or slot <= 0 then
		showToast("Remove map failed: missing source map reference")
		return false, "missing-map-ref"
	end

	local commRemote = getCommRemote(4)

	if commRemote then
		commRemote:FireServer({
			Goal = "PS Build",
			Todo = "Clear Map",
			SourceUserId = sourceUserId,
			Slot = slot,
			Source = value or "GlobalCatalogue",
			Catalogue = true
		})
		return true, nil
	end

	showToast("Remove map failed: communicate remote missing")
	return false, "communicate-remote-missing"
end

function panelRequestLoadMapSlot(p, p2)
	local sourceUserId = math.floor(tonumber(p) or 0)
	local v79 = math.floor(tonumber(p2) or 0)

	if sourceUserId <= 0 or v79 <= 0 then
		panelSetStatus("Load failed: invalid map target/slot", false)
		return
	end

	if not claimActionDebounce("panel-map-load", tostring(sourceUserId) .. ":" .. tostring(v79), 0.35) then
		return
	end

	if isCatalogueMapAlreadyLoaded(sourceUserId, v79) then
		panelSetStatus("Refused, this map is already loaded", false)
		return
	end

	local commRemote = getCommRemote(4)

	if not commRemote then
		panelSetStatus("Load failed: communicate remote missing", false)
		return
	end

	panelSetStatus("Loading slot " .. tostring(v79) .. " from user " .. tostring(sourceUserId) .. "...", true)
	commRemote:FireServer({
		Goal = "PS Build",
		Todo = "Load " .. tostring(v79),
		SourceUserId = sourceUserId,
		Source = "GlobalCataloguePanel",
		Catalogue = true
	})
end

function panelBuildMapRow(data, layoutOrder, p)
	local listScroll = v55.listScroll

	if not listScroll then
		return
	end

	local v78

	if data then
		v78 = data.sourceUserId or data.userId or p
	else
		v78 = p
	end

	local v79 = math.floor(tonumber(v78) or 0)

	if v79 <= 0 then
		v79 = math.floor(tonumber(p) or 0)
	end

	local v80 = math.max(1, (math.floor(tonumber(data and data.slot) or 1)))
	local v81 = trimString((tostring(not data and "" or data.name or "")))

	if v81 == "" then
		v81 = "Slot " .. tostring(v80)
	end

	local v82 = trimString((tostring(not data and "" or data.codec or "")))
	local v83 = v82 == "" and "legacy" or v82
	local frame = Instance.new("Frame")
	frame.Name = "PanelMapRow_" .. tostring(v80)
	frame.Size = UDim2.new(1, -6, 0, 62)
	frame.BackgroundColor3 = rgb(255, 255, 255)
	frame.BackgroundTransparency = 0.93
	frame.BorderSizePixel = 0
	frame.LayoutOrder = layoutOrder
	frame.Parent = listScroll
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 6)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = rgb(255, 255, 255)
	uIStroke.Thickness = 1
	uIStroke.Transparency = 0.85
	uIStroke.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.new(0, 8, 0, 4)
	textLabel.Size = UDim2.new(1, -110, 0, 20)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 12
	textLabel.TextColor3 = rgb(245, 245, 245)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Text = string.format("SLOT %d | %s", v80, v81)
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Info"
	textLabel2.BackgroundTransparency = 1
	textLabel2.Position = UDim2.new(0, 8, 0, 24)
	textLabel2.Size = UDim2.new(1, -110, 0, 16)
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextSize = 10
	textLabel2.TextColor3 = rgb(170, 170, 170)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Text = string.format(
		"parts %s | chunks %s | codec %s | bytes %s | saved %s",
		formatNum(tonumber(data and data.partCount) or 0),
		formatNum(tonumber(data and data.chunks) or 0),
		v83,
		formatNum(tonumber(data and data.payloadSize) or tonumber(data and data.firstChunkBytes) or 0),
		panelFormatSavedAt(data and data.savedAt)
	)
	textLabel2.Parent = frame
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Source"
	textLabel3.BackgroundTransparency = 1
	textLabel3.Position = UDim2.new(0, 8, 1, -18)
	textLabel3.Size = UDim2.new(1, -110, 0, 14)
	textLabel3.Font = Enum.Font.Gotham
	textLabel3.TextSize = 9
	textLabel3.TextColor3 = rgb(120, 120, 120)
	textLabel3.TextXAlignment = Enum.TextXAlignment.Left
	textLabel3.Text = "Source user " .. tostring(v79)
	textLabel3.Parent = frame
	panelMakeButton(
		frame,
		"LoadBtn",
		"LOAD",
		UDim2.new(1, -76, 0, 7),
		UDim2.new(0, 64, 0, 22),
		rgb(40, 105, 70),
		rgb(185, 245, 205)
	).MouseButton1Click:Connect(function()
		panelRequestLoadMapSlot(v79, v80)
	end)
end

function panelRenderMapSaves(p, p2)
	v55.listings = {}
	v55.mapSaves = typeof(p) == "table" and p or {}
	v55.activeMapTargetUserId = math.floor(tonumber(p2) or 0)
	panelWipeListingRows()
	local listScroll = v55.listScroll

	if not listScroll then
		return
	end

	if #v55.mapSaves == 0 then
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "PanelMapRow_Empty"
		textLabel.Size = UDim2.new(1, -6, 0, 30)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Gotham
		textLabel.TextSize = 12
		textLabel.TextColor3 = rgb(145, 145, 145)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = "No map saves found."
		textLabel.LayoutOrder = 1
		textLabel.Parent = listScroll
	else
		for i, mapSave in ipairs(v55.mapSaves) do
			panelBuildMapRow(mapSave, i, v55.activeMapTargetUserId)

			if i % 12 == 0 then
				task.wait()
			end
		end
	end
end

function panelLoadMapSaves(p)
	if not v then
		return
	end

	local userId = panelTargetUserId()

	if userId <= 0 then
		userId = localPlayer.UserId
	end

	local scanSlots = math.floor(tonumber(p) or 0)
	local v79 = {
		userId = userId
	}

	if scanSlots > 0 then
		v79.scanSlots = scanSlots
		panelSetStatus(string.format("Loading first %d map saves for %s...", scanSlots, (tostring(userId))), true)
	else
		panelSetStatus("Loading map saves for " .. tostring(userId) .. "...", true)
	end

	local v80 = req("AdminGetUserMapSaves", v79, 3)

	if v80 and v80.ok then
		local v81 = typeof(v80.slots) ~= "table" and {} or v80.slots or {}
		panelRenderMapSaves(v81, userId)
		local v82 = math.max(0, (math.floor(tonumber(v80.readErrors) or 0)))
		local v83 = math.max(0, (math.floor(tonumber(v80.scannedSlots) or 0)))
		local v84 = math.max(0, (math.floor(tonumber(v80.saveSlots) or 0)))
		local v85 = math.max(0, (math.floor(tonumber(v80.slot1PrimaryBytes) or 0)))
		local v86 = math.max(0, (math.floor(tonumber(v80.slot1AltBytes) or 0)))

		if #v81 == 0 and v82 > 0 then
			panelSetStatus(
				string.format(
					"No maps found for %s (scan errors: %d, scanned %d, declared %d, slot1 primary %dB, alt %dB). Check server warns.",
					tostring(userId),
					v82,
					v83,
					v84,
					v85,
					v86
				),
				false
			)
		else
			panelSetStatus(
				string.format(
					"Loaded %d map save(s) for %s (scanned %d, declared %d, errors %d, slot1 primary %dB, alt %dB).",
					#v81,
					tostring(userId),
					v83,
					v84,
					v82,
					v85,
					v86
				),
				true
			)
		end
	else
		panelRenderMapSaves({}, userId)
		panelSetStatus("Load maps failed: " .. describeCatalogueError(v80 and v80.error or "unknown"), false)
	end
end

function panelRefreshCreatorListings()
	if not v then
		return
	end

	local name = panelTargetUserId()

	if name <= 0 then
		panelSetStatus("Enter a valid creator UserId", false)
		panelRenderListings({})
		v55.activeCreatorUserId = 0
	else
		v55.activeCreatorUserId = name
		panelSetStatus("Loading listings for " .. tostring(name) .. "...", true)
		local v78 = req("AdminGetCreatorListings", {
			creatorUserId = name,
			creatorName = panelResolveCreatorName(),
			includeDeleted = v55.includeDeleted == true
		}, 3)

		if v78 and v78.ok then
			if v55.creatorNameInput and v78.creator and v78.creator.name and trimString(v55.creatorNameInput.Text or "") == "" then
				v55.creatorNameInput.Text = tostring(v78.creator.name)
			end

			panelRenderListings(v78.entries or {})
			local panelSetStatus2 = panelSetStatus
			local v80 = tostring(#(v78.entries or {}))

			if v78.creator then
				name = v78.creator.name or name
			end

			panelSetStatus2("Loaded " .. v80 .. " listings for " .. tostring(name), true)
		else
			panelRenderListings({})
			panelSetStatus("Load failed: " .. tostring(v78 and v78.error or "unknown"), false)
		end
	end
end

function panelRestoreCatalogueAccess()
	local userId = panelTargetUserId()

	if userId <= 0 then
		panelSetStatus("Enter a valid target UserId", false)
		return
	end

	local v79 = req("AdminRestoreCatalogueAccess", {
		userId = userId
	}, 3)

	if v79 and v79.ok then
		panelSetStatus("Catalogue access restored for " .. tostring(userId), true)
	else
		panelSetStatus("Restore access failed: " .. tostring(v79 and v79.error or "unknown"), false)
	end
end

function panelSetCreatorVerified(p)
	local name = panelTargetUserId()

	if name <= 0 then
		panelSetStatus("Enter a valid creator UserId", false)
		return
	end

	local v78 = req("AdminSetCreatorVerified", {
		creatorUserId = name,
		creatorName = panelResolveCreatorName(),
		verified = p == true
	}, 3)

	if not (v78 and v78.ok) then
		panelSetStatus("Verify update failed: " .. tostring(v78 and v78.error or "unknown"), false)
		return
	end

	local panelSetStatus2 = panelSetStatus

	if v78.creator then
		name = v78.creator.name or name
	end

	panelSetStatus2(tostring(name) .. (p == true and " marked verified" or " unverified"), true)
	panelRefreshSummary()
end

function panelBanAction(p)
	local userId = panelTargetUserId()

	if userId <= 0 then
		panelSetStatus("Enter a valid target UserId", false)
		return
	end

	local v80 = {
		userId = userId
	}

	if p then
		local v81 = trimString(v55.reasonInput and v55.reasonInput.Text or "")
		local v82 = v81 == "" and "Banned by moderation panel" or v81
		v80.duration = -1
		v80.displayReason = v82
		v80.privateReason = v82
		v80.applyToUniverse = true
	end

	local v81 = req(p and "AdminBanUser" or "AdminUnbanUser", v80, 3)

	if v81 and v81.ok then
		panelSetStatus((p and "Banned " or "Unbanned ") .. tostring(userId), true)
	else
		panelSetStatus((p and "Ban" or "Unban") .. " failed: " .. tostring(v81 and v81.error or "unknown"), false)
	end
end

function panelBulkListingAction(status)
	if not v then
		return
	end

	if type(v55.listings) == "table" and #v55.listings ~= 0 then
		task.spawn(function()
			local count4 = 0
			local count5 = 0

			for _, listing in ipairs(v55.listings) do
				local id = tostring(listing and listing.id or "")

				if id ~= "" then
					local v78 = req("AdminSetListingStatus", {
						entryId = id,
						status = status
					}, 2)

					if v78 and v78.ok then
						count4 += 1
					else
						count5 += 1
					end
				end

				task.wait(0.2)
			end

			panelSetStatus(
				"Bulk " .. tostring(status) .. " done. Updated " .. tostring(count4) .. ", failed " .. tostring(count5),
				count5 == 0
			)
			panelRefreshSummary()
			panelRefreshCreatorListings()
		end)
	else
		panelSetStatus("No listings loaded for bulk action", false)
	end
end

function ensurePanelUi()
	if not v then
		return
	end

	local frame = tabs.PANEL and tabs.PANEL.frame

	if not frame or v55.root and v55.root.Parent == frame then
		return
	end

	frame.BackgroundTransparency = 1
	local frame2 = Instance.new("Frame")
	frame2.Name = "PanelRoot"
	frame2.Size = UDim2.new(1, 0, 1, 0)
	frame2.BackgroundTransparency = 1
	frame2.Parent = frame
	v55.root = frame2
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Summary"
	textLabel.Position = UDim2.new(0, 8, 0, 6)
	textLabel.Size = UDim2.new(1, -16, 0, 20)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 12
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextColor3 = rgb(210, 220, 230)
	textLabel.Text = "Loading panel summary..."
	textLabel.Parent = frame2
	v55.summary = textLabel
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Status"
	textLabel2.Position = UDim2.new(0, 8, 0, 26)
	textLabel2.Size = UDim2.new(1, -16, 0, 18)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextSize = 11
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.TextColor3 = textColor4
	textLabel2.Text = "Ready."
	textLabel2.Parent = frame2
	v55.status = textLabel2
	v55.targetUserInput = panelMakeBox(
		frame2,
		"TargetUserId",
		UDim2.new(0, 8, 0, 50),
		UDim2.new(0, 180, 0, 26),
		"Creator/UserId...",
		""
	)
	v55.creatorNameInput = panelMakeBox(
		frame2,
		"CreatorName",
		UDim2.new(0, 194, 0, 50),
		UDim2.new(0, 180, 0, 26),
		"Creator name (optional)",
		""
	)
	v55.reasonInput = panelMakeBox(
		frame2,
		"ReasonInput",
		UDim2.new(0, 380, 0, 50),
		UDim2.new(1, -388, 0, 26),
		"Ban reason...",
		""
	)
	local v78 = panelMakeButton(
		frame2,
		"LoadListingsBtn",
		"LOAD LISTINGS",
		UDim2.new(0, 8, 0, 84),
		UDim2.new(0, 110, 0, 24),
		rgb(48, 95, 140),
		rgb(180, 220, 255)
	)
	local v79 = panelMakeButton(
		frame2,
		"VerifyBtn",
		"VERIFY",
		UDim2.new(0, 124, 0, 84),
		UDim2.new(0, 74, 0, 24),
		rgb(45, 120, 65),
		rgb(180, 245, 185)
	)
	local v80 = panelMakeButton(
		frame2,
		"UnverifyBtn",
		"UNVERIFY",
		UDim2.new(0, 204, 0, 84),
		UDim2.new(0, 88, 0, 24),
		rgb(110, 85, 45),
		rgb(245, 220, 170)
	)
	local v81 = panelMakeButton(
		frame2,
		"BanBtn",
		"BAN",
		UDim2.new(0, 298, 0, 84),
		UDim2.new(0, 60, 0, 24),
		rgb(130, 50, 50),
		rgb(255, 190, 190)
	)
	local v82 = panelMakeButton(
		frame2,
		"UnbanBtn",
		"UNBAN",
		UDim2.new(0, 364, 0, 84),
		UDim2.new(0, 70, 0, 24),
		rgb(55, 110, 65),
		rgb(185, 245, 185)
	)
	v55.includeDeletedBtn = panelMakeButton(
		frame2,
		"IncludeDeletedBtn",
		"INCLUDE DELETED: OFF",
		UDim2.new(0, 440, 0, 84),
		UDim2.new(0, 160, 0, 24),
		rgb(60, 60, 60),
		rgb(220, 220, 220)
	)
	local v83 = panelMakeButton(
		frame2,
		"TakeDownAllBtn",
		"TAKE DOWN ALL",
		UDim2.new(0, 8, 0, 114),
		UDim2.new(0, 122, 0, 24),
		rgb(125, 55, 55),
		rgb(255, 190, 190)
	)
	local v84 = panelMakeButton(
		frame2,
		"RestoreAllBtn",
		"RESTORE ALL",
		UDim2.new(0, 136, 0, 114),
		UDim2.new(0, 102, 0, 24),
		rgb(45, 110, 65),
		rgb(190, 245, 190)
	)
	local v85 = panelMakeButton(
		frame2,
		"RefreshSummaryBtn",
		"REFRESH SUMMARY",
		UDim2.new(0, 244, 0, 114),
		UDim2.new(0, 122, 0, 24),
		rgb(55, 75, 115),
		rgb(190, 215, 255)
	)
	local v86 = panelMakeButton(
		frame2,
		"LoadMapsBtn",
		"LOAD MAPS",
		UDim2.new(0, 372, 0, 114),
		UDim2.new(0, 102, 0, 24),
		rgb(52, 112, 86),
		rgb(190, 245, 210)
	)
	panelMakeButton(
		frame2,
		"RestoreCatAccessBtn",
		"RESTORE CAT ACCESS",
		UDim2.new(0, 8, 0, 144),
		UDim2.new(0, 160, 0, 24),
		rgb(75, 55, 120),
		rgb(210, 185, 255)
	).MouseButton1Click:Connect(function()
		panelRestoreCatalogueAccess()
	end)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "PanelListingsScroll"
	scrollingFrame.Position = UDim2.new(0, 8, 0, 176)
	scrollingFrame.Size = UDim2.new(1, -16, 1, -184)
	scrollingFrame.BackgroundColor3 = rgb(255, 255, 255)
	scrollingFrame.BackgroundTransparency = 0.95
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.Parent = frame2
	v55.listScroll = scrollingFrame
	local uIListLayout10 = Instance.new("UIListLayout")
	uIListLayout10.Padding = UDim.new(0, 4)
	uIListLayout10.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout10.Parent = scrollingFrame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingLeft = UDim.new(0, 3)
	uIPadding.PaddingRight = UDim.new(0, 3)
	uIPadding.PaddingTop = UDim.new(0, 3)
	uIPadding.PaddingBottom = UDim.new(0, 3)
	uIPadding.Parent = scrollingFrame
	v78.MouseButton1Click:Connect(function()
		panelRefreshCreatorListings()
	end)
	v79.MouseButton1Click:Connect(function()
		panelSetCreatorVerified(true)
	end)
	v80.MouseButton1Click:Connect(function()
		panelSetCreatorVerified(false)
	end)
	v81.MouseButton1Click:Connect(function()
		panelBanAction(true)
	end)
	v82.MouseButton1Click:Connect(function()
		panelBanAction(false)
	end)
	v55.includeDeletedBtn.MouseButton1Click:Connect(function()
		v55.includeDeleted = not v55.includeDeleted
		v55.includeDeletedBtn.Text = v55.includeDeleted and "INCLUDE DELETED: ON" or "INCLUDE DELETED: OFF"
		v55.includeDeletedBtn.BackgroundTransparency = v55.includeDeleted and 0.05 or 0.25
		v55.includeDeletedBtn.BackgroundColor3 = v55.includeDeleted and rgb(70, 105, 75) or rgb(60, 60, 60)

		if v55.activeCreatorUserId > 0 then
			panelRefreshCreatorListings()
		end
	end)
	v83.MouseButton1Click:Connect(function()
		panelBulkListingAction("taken_down")
	end)
	v84.MouseButton1Click:Connect(function()
		panelBulkListingAction("active")
	end)
	v85.MouseButton1Click:Connect(function()
		panelRefreshSummary()
	end)
	v86.MouseButton1Click:Connect(function()
		panelLoadMapSaves()
	end)
end

function switchTab(p, p2)
	for k in pairs(v41) do
		v41[k] += 1
	end

	if fn4 then
		fn4()
	end

	if charDetailOverlay.Visible then
		closeDetail()
	end

	v7 = p
	local v78

	if typeof(p2) == "table" then
		v78 = p2.skipRefresh == true
	else
		v78 = false
	end

	for k, v79 in pairs(tabs) do
		local visible = k == p
		local btn = v79.btn
		btn.TextColor3 = visible and rgb(255, 255, 255) or rgb(120, 120, 120)
		btn.BackgroundTransparency = visible and 0.88 or 1
		local indicator = btn:FindFirstChild("Indicator")

		if indicator then
			indicator.BackgroundTransparency = visible and 0 or 1
		end

		local v81 = btn:FindFirstChildWhichIsA("UIStroke")

		if not v81 then
			v81 = Instance.new("UIStroke")
			v81.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			v81.Color = rgb(0, 0, 0)
			v81.Thickness = 1
			v81.Parent = btn
		end

		v81.Transparency = visible and 0.8 or 1

		if v79.frame then
			v79.frame.Visible = visible
		end
	end

	if v78 then
		return
	end

	if p == "BROWSE" then
		refreshBrowse()
	elseif p == "LEADERBOARD" then
		switchLbSub(v25)
	elseif p == "VERIFIED" then
		setBrowseLoading(false)
		refreshVerified()
	elseif p == "ADDED_TO_PS" then
		refreshAddedToPS()
	elseif p == "UPLOAD" then
		setBrowseLoading(false)
		uploadSelect.Visible = true
		uploadConfirm.Visible = false
		v26 = nil
		fn3(true)
		syncUploadSourcesAsync(true)
		syncMineForUploadAsync()
	elseif p == "MY_UPLOADS" then
		setBrowseLoading(false)
		refreshMyUploads()
	elseif p == "PANEL" then
		setBrowseLoading(false)
		ensurePanelUi()
		panelRefreshSummary()
	end
end

for _, v78 in ipairs(refreshBtn) do
	local v79 = v78
	tabs[v78].btn.MouseButton1Click:Connect(function()
		switchTab(v79)
	end)
end

PAGE_NUM_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function updatePageButtons()
	local v78 = math.max(1, page - 2)
	local v79 = math.max(1, math.min(v12, v78 + 4) - 4)

	for i = 1, 5 do
		local child = pageInner:FindFirstChild("PgNum" .. i)

		if not child then
			continue
		end

		local v80 = v79 + (i - 1)

		if v80 <= v12 then
			child.Visible = true
			child.Text = tostring(v80)
			child:SetAttribute("PageNum", v80)
			local v81 = v80 == page
			local backgroundColor2 = v81 and rgb(255, 255, 255) or rgb(148, 148, 148)
			TweenService:Create(child, PAGE_NUM_TWEEN, {
				BackgroundColor3 = backgroundColor2,
				BackgroundTransparency = v81 and 0.5 or 0.75
			}):Play()
		else
			child.Visible = false
		end
	end

	pgFirst.Visible = v12 > 5
	pgPrev.Visible = page > 1
	pgNext.Visible = page < v12
	pgLast.Visible = v12 > 5
	local pgDots = pageInner:FindFirstChild("PgDots")

	if pgDots then
		pgDots.Visible = v12 > 5
	end

	pgJumpInput.Visible = v12 > 5
	pageInfoLabel.Text = "Page " .. page .. " of " .. v12
end

function goToPage(value)
	local now2 = os.clock()

	if now2 < v13 then
		return
	end

	v13 = now2 + 0.55
	page = math.clamp(value, 1, v12)
	cardGrid.CanvasPosition = Vector2.new(0, 0)
	v41.browse += 1

	for _, guiObject in ipairs(cardGrid:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and (guiObject.Name:find("Card_") or guiObject.Name:find("CreatorCard_"))) then
			continue
		end

		guiObject:Destroy()
	end

	v14 = {}
	noResults.Visible = false
	cardGrid.Visible = true
	resultsCount.Text = "Loading..."
	refreshBrowse()
	updatePageButtons()
end

pgFirst.MouseButton1Click:Connect(function()
	goToPage(1)
end)
pgPrev.MouseButton1Click:Connect(function()
	goToPage(page - 1)
end)
pgNext.MouseButton1Click:Connect(function()
	goToPage(page + 1)
end)
pgLast.MouseButton1Click:Connect(function()
	goToPage(v12)
end)

for i = 1, 5 do
	local child = pageInner:FindFirstChild("PgNum" .. i)

	if not child then
		continue
	end

	local v78 = child
	child.MouseButton1Click:Connect(function()
		local pageNum = v78:GetAttribute("PageNum")

		if pageNum then
			goToPage(pageNum)
		end
	end)
end

pgJumpInput.FocusLost:Connect(function(p)
	if p then
		local text2 = tonumber(pgJumpInput.Text)

		if text2 then
			goToPage((math.floor(text2)))
		end

		pgJumpInput.Text = ""
	end
end)

function resolveCardStatLabel(instance, p)
	if not instance then
		return nil
	end

	local guiObject = nil

	for _, childName in ipairs(({
		likes = { "likes", "like" },
		dislikes = { "dislikes", "dislike" },
		favourites = {
			"favourites",
			"favorites",
			"favourite",
			"favorite"
		},
		downloads = { "downloads", "download" }
	})[p] or { p }) do
		guiObject = instance:FindFirstChild(childName)

		if guiObject then
			break
		end
	end

	if not guiObject then
		return nil
	end

	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
		return guiObject
	end

	return guiObject:FindFirstChildWhichIsA("TextLabel") or guiObject:FindFirstChildWhichIsA("TextButton")
end

function setCardStatNumber(p, p2)
	if p then
		p.Text = formatNum((math.max(0, (math.floor(tonumber(p2) or 0)))))
	end
end

function applyBrowseCardState(instance, data)
	if not (instance and data) then
		return
	end

	local cardInfo = instance:FindFirstChild("CardInfo")

	if cardInfo and cardInfo:IsA("GuiObject") then
		local favourites = tonumber(data.favourites) or tonumber(data.favorites) or 0
		setCardStatNumber(resolveCardStatLabel(cardInfo, "likes"), data.likes)
		setCardStatNumber(resolveCardStatLabel(cardInfo, "dislikes"), data.dislikes)
		setCardStatNumber(resolveCardStatLabel(cardInfo, "favourites"), favourites)
		setCardStatNumber(resolveCardStatLabel(cardInfo, "downloads"), data.downloads)
	end

	local favBtn = instance:FindFirstChild("FavBtn")

	if favBtn and favBtn:IsA("TextButton") then
		applyFavouriteVisual(favBtn, v17[data.id] == true)
	end
end

function applyEntryAppearance(instance, data)
	if not instance or typeof(data) ~= "table" then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toColor(list)
		if typeof(list) == "table" then
			return rgb(tonumber(list[1]) or 0, tonumber(list[2]) or 0, tonumber(list[3]) or 0)
		end

		return nil
	end

	local mode = tostring(data.mode or "gradient")
	local v78 = math.clamp(tonumber(data.gi) or 1, 0, 1)
	local v79 = math.clamp(tonumber(data.vi) or 0, 0, 1)
	local cardHeader = instance:FindFirstChild("CardHeader")
	local uIGradient = cardHeader and cardHeader:FindFirstChildWhichIsA("UIGradient")

	if uIGradient then
		if mode == "off" then
			uIGradient.Enabled = false
		else
			uIGradient.Enabled = true

			if typeof(data.g) == "table" and #data.g > 0 then
				local colorSequenceKeypoints = {}

				for _, v80 in ipairs(data.g) do
					local color = toColor(v80.c) -- equivalent call inferred; original call site unknown

					if color then
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(math.clamp(tonumber(v80.t) or 0, 0, 1), color)
						)
					end
				end

				if mode == "solid" and colorSequenceKeypoints[1] then
					uIGradient.Color = ColorSequence.new(colorSequenceKeypoints[1].Value)
				elseif #colorSequenceKeypoints >= 2 then
					pcall(function()
						uIGradient.Color = ColorSequence.new(colorSequenceKeypoints)
					end)
				elseif colorSequenceKeypoints[1] then
					uIGradient.Color = ColorSequence.new(colorSequenceKeypoints[1].Value)
				end
			end

			uIGradient.Transparency = NumberSequence.new(1 - v78)
		end
	end

	local vignette = instance:FindFirstChild("Vignette")

	if vignette then
		vignette.ZIndex = 2
		local v80 = vignette:IsA("ImageLabel") or vignette:IsA("ImageButton")
		local v81 = toColor(data.vc) -- equivalent call inferred; original call site unknown

		if v81 then
			if v80 then
				vignette.ImageColor3 = v81
			else
				vignette.BackgroundColor3 = v81
			end
		end

		if v80 then
			vignette.ImageTransparency = 1 - v79
		else
			vignette.BackgroundTransparency = 1 - v79
		end
	end
end

function buildCard(data, layoutOrder, options)
	local v78 = options or {}
	local clone = (v78.template or cardTemplate):Clone()
	clone.Name = "Card_" .. data.id
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	clone.Active = true
	local cardInfo = clone:FindFirstChild("CardInfo")

	if not cardInfo then
		clone.Parent = v78.parent or cardGrid
		return clone
	end

	local charName = cardInfo:FindFirstChild("CharName")

	if charName and (charName:IsA("TextLabel") or charName:IsA("TextButton")) then
		charName.Text = data.name
	end

	local subtitleLabel = cardInfo:FindFirstChild("SubtitleLabel")

	if subtitleLabel and (subtitleLabel:IsA("TextLabel") or subtitleLabel:IsA("TextButton")) then
		subtitleLabel.Visible = false
	end

	local robuxText = cardInfo:FindFirstChild("RobuxText")

	if robuxText and robuxText:IsA("GuiObject") then
		robuxText.Visible = false
	end

	local category = data.category or "Character"
	local typeBadge = clone:FindFirstChild("TypeBadge")

	if typeBadge and (typeBadge:IsA("TextLabel") or typeBadge:IsA("TextButton")) then
		if category == "Character" then
			typeBadge.Text = ""
			typeBadge.Visible = false
		else
			typeBadge.Text = tostring(RequestHelper.CAT_LABELS[category] or "")
			typeBadge.TextColor3 = rgb(255, 255, 255)
			typeBadge.BackgroundColor3 = categoryColors[category] or rgb(200, 60, 60)
			typeBadge.Visible = true
		end
	end

	local cardHeader = clone:FindFirstChild("CardHeader")

	if cardHeader and cardHeader:IsA("GuiObject") then
		cardHeader.BackgroundColor3 = rgb(255, 255, 255)
		cardHeader.BackgroundTransparency = 0
	end

	local v79

	if data.thumbnailIsDefault ~= true then
		v79 = data.thumbnail or data.thumbnailRaw or data.imageId
	end

	applyCardHeaderMedia(cardHeader, category, v79)
	local creator = tostring(data.creator or "Unknown")
	local text2 = timeAgo(data.uploadedTs or data.uploadedAt)
	local creatorLine = cardInfo:FindFirstChild("CreatorLine")

	if creatorLine and (creatorLine:IsA("TextLabel") or creatorLine:IsA("TextButton")) then
		creatorLine.RichText = true
		creatorLine.Text = "by <b>" .. escapeRichText(creator) .. "</b>"
	end

	local days = cardInfo:FindFirstChild("Days")

	if days and (days:IsA("TextLabel") or days:IsA("TextButton")) then
		days.Text = text2
		days.Visible = true
	end

	local favBtn = clone:FindFirstChild("FavBtn")
	applyBrowseCardState(clone, data)
	applyEntryAppearance(clone, data.appearance)
	hoverStroke(clone, rgb(200, 60, 60), 0.8, rgb(255, 255, 255), 0.94)
	local blockOpenRegions = v78.blockOpenRegions
	local onOpen = v78.onOpen
	clone.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local vector = Vector2.new(input.Position.X, input.Position.Y)

			if favBtn and isPointInside(favBtn, vector) then
				return
			end

			if blockOpenRegions then
				for _, childName in ipairs(blockOpenRegions) do
					local guiObject = clone:FindFirstChild(childName, true)

					if guiObject and guiObject:IsA("GuiObject") and isPointInside(guiObject, vector) then
						return
					end
				end
			end

			if onOpen then
				onOpen(data)
			else
				openDetail(data)
			end
		end
	end)

	if favBtn and favBtn:IsA("TextButton") then
		favBtn.MouseButton1Click:Connect(function()
			toggleFavourite(data.id, {
				skipRefresh = true
			})
		end)
	end

	clone.Parent = v78.parent or cardGrid
	return clone
end

local function buildCreatorSearchSubtext(data, clone, p)
	local v78 = math.max(0, (math.floor(tonumber(data and data.userId) or 0)))

	if v78 <= 0 then
		return "Tap to open profile"
	end

	local v79 = trimString((tostring(data and data.userName or "")))

	if v79 ~= "" then
		return "@" .. v79 .. "  |  ID " .. tostring(v78)
	end

	local leaderboardUserName, v80 = getLeaderboardUserName(v78)

	if v80 and trimString(leaderboardUserName) ~= "" then
		return "@" .. trimString(leaderboardUserName) .. "  |  ID " .. tostring(v78)
	end

	if clone and p then
		task.spawn(function()
			local v81 = tonumber(p) or 0

			for _ = 1, 30 do
				if not (v81 == v41.browse and (clone and clone.Parent)) then
					break
				end

				local v82 = v51[v78]

				if v82 == nil or trimString(v82) == "" then
					task.wait(0.05)
				else
					local cardInfo = clone:FindFirstChild("CardInfo")
					local creatorLine = cardInfo and cardInfo:FindFirstChild("CreatorLine")

					if creatorLine and (creatorLine:IsA("TextLabel") or creatorLine:IsA("TextButton")) then
						creatorLine.Text = "@" .. trimString(v82) .. "  |  ID " .. tostring(v78)
					end

					break
				end
			end
		end)
	end

	return "User ID " .. tostring(v78)
end

function buildCreatorSearchCard(data, layoutOrder, p)
	local v78 = math.max(0, (math.floor(tonumber(data and data.userId) or 0)))

	if v78 <= 0 then
		return nil
	end

	local clone = (userTemplate or cardTemplate):Clone()
	clone.Name = "CreatorCard_" .. tostring(v78)
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	clone.Active = true
	local cardInfo = clone:WaitForChild("CardInfo")
	local charName = cardInfo:WaitForChild("CharName")
	charName.Text = trimString((tostring(data.name or "User" .. tostring(v78))))
	local subtitleLabel = cardInfo:FindFirstChild("SubtitleLabel")

	if subtitleLabel and (subtitleLabel:IsA("TextLabel") or subtitleLabel:IsA("TextButton")) then
		local verified = data.verified == true
		local v79 = (tonumber(data.totalUploads) or 0) > 0
		subtitleLabel.Visible = true
		subtitleLabel.RichText = false
		subtitleLabel.Text = v79 and (verified and "Verified creator profile" or "Creator profile") or "User profile"
		subtitleLabel.TextColor3 = verified and rgb(255, 206, 84) or rgb(170, 170, 170)
	end

	local robuxText = cardInfo:FindFirstChild("RobuxText")

	if robuxText and robuxText:IsA("GuiObject") then
		robuxText.Visible = false
	end

	local typeBadge = clone:FindFirstChild("TypeBadge")
	local v79 = (tonumber(data.totalUploads) or 0) > 0

	if typeBadge and (typeBadge:IsA("TextLabel") or typeBadge:IsA("TextButton")) then
		typeBadge.Text = not v79 and "USER" or data.verified == true and "VERIFIED CREATOR" or "CREATOR"
		typeBadge.TextColor3 = rgb(255, 255, 255)
		typeBadge.BackgroundColor3 = data.verified == true and rgb(198, 150, 45) or rgb(70, 110, 170)
		typeBadge.Visible = true
	end

	local cardHeader = clone:WaitForChild("CardHeader")
	cardHeader.BackgroundColor3 = rgb(255, 255, 255)
	cardHeader.BackgroundTransparency = 0
	local verifiedAvatarHeadshot, v80 = getVerifiedAvatarHeadshot(v78)
	applyCardHeaderMedia(cardHeader, "Character", v80 and verifiedAvatarHeadshot or "")
	local creatorLine = cardInfo:WaitForChild("CreatorLine")
	creatorLine.RichText = false
	creatorLine.Text = buildCreatorSearchSubtext(data, clone, p)
	local days = cardInfo:FindFirstChild("Days")

	if days and (days:IsA("TextLabel") or days:IsA("TextButton")) then
		days.Text = formatNum(tonumber(data.totalUploads) or 0) .. " uploads"
		days.Visible = true
	end

	local cardStatLabel = resolveCardStatLabel(cardInfo, "likes")
	local cardStatLabel2 = resolveCardStatLabel(cardInfo, "dislikes")
	local cardStatLabel3 = resolveCardStatLabel(cardInfo, "favourites")
	local cardStatLabel4 = resolveCardStatLabel(cardInfo, "downloads")
	setCardStatNumber(cardStatLabel, data.totalLikes)
	setCardStatNumber(cardStatLabel2, data.totalDislikes)

	if cardStatLabel3 then
		local totalFavorites = tonumber(data.totalFavorites) or tonumber(data.totalAdded) or 0
		setCardStatNumber(cardStatLabel3, totalFavorites)
	end

	if cardStatLabel4 then
		local totalDownloads = tonumber(data.totalDownloads) or math.max(
			tonumber(data.totalUses) or 0,
			tonumber(data.totalAdded) or 0
		)
		setCardStatNumber(cardStatLabel4, totalDownloads)
	end

	local favBtn = clone:FindFirstChild("FavBtn")

	if favBtn and favBtn:IsA("GuiButton") then
		favBtn.Visible = false
		favBtn.Active = false
	end

	hoverStroke(clone, data.verified == true and rgb(255, 206, 84) or rgb(70, 110, 170), 0.8, rgb(255, 255, 255), 0.94)
	clone.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			openCreatorProfile(v78, data.name)
		end
	end)
	clone.Parent = cardGrid
	return clone
end

function refreshBrowseCards(p)
	task.spawn(function()
		local WAIT_INTERVAL = 0.02
		local v78 = p or v41.browse
		local guiObjects = {}

		for _, guiObject in ipairs(cardGrid:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and (guiObject.Name:find("Card_") or guiObject.Name:find("CreatorCard_"))) then
				continue
			end

			guiObjects[#guiObjects + 1] = guiObject
		end

		for i, v79 in ipairs(guiObjects) do
			if v78 ~= v41.browse then
				return
			end

			v79:Destroy()

			if i % 25 == 0 then
				task.wait(WAIT_INTERVAL)
			end
		end

		local count4 = 0

		for _, v79 in ipairs(creators) do
			if v78 ~= v41.browse then
				return
			end

			count4 += 1
			buildCreatorSearchCard(v79, count4, v78)

			if count4 % 6 == 0 then
				task.wait(WAIT_INTERVAL)
			end
		end

		for _, v79 in ipairs(v14) do
			if v78 ~= v41.browse then
				break
			end

			count4 += 1
			buildCard(v79, count4)

			if count4 % 10 == 0 then
				task.wait(WAIT_INTERVAL)
			end
		end
	end)
end

local function effectiveBrowseSearchText(value)
	for k in string.lower((tostring(value or ""))):gsub("[^a-z0-9 ]", ""):gmatch("%S+") do
		if #k >= RequestHelper.SEARCH_MIN_TOKEN_LENGTH then
			return (tostring(value or ""))
		end
	end

	return ""
end

local loading = mainPanel:FindFirstChild("loading")
local textLabel = loading and loading:FindFirstChildOfClass("TextLabel")
local guiObjects = {}

if loading then
	local pASSframe = loading:FindFirstChild("PASSframe")

	if pASSframe and pASSframe:IsA("GuiObject") then
		pASSframe.Visible = false
	end

	for _, guiObject in ipairs(loading:GetChildren()) do
		if not ((guiObject:IsA("Frame") or guiObject:IsA("ImageLabel")) and guiObject ~= textLabel and guiObject.Name ~= "PASSframe") then
			continue
		end

		table.insert(guiObjects, guiObject)
	end

	table.sort(guiObjects, function(a, b)
		return tostring(a.Name) < tostring(b.Name)
	end)
end

local v78 = {
	color = Color3.fromRGB(82, 137, 255),
	growth = 1.25,
	steptime = 0.35,
	tweentime = 0.15,
	fadein = 0.18,
	fadeout = 0.12,
	sfxdedup = 0.18,
	targetbg = 0,
	targett = not textLabel and 0 or textLabel.TextTransparency or 0,
	sfx = { "rbxassetid://97631984908199", "rbxassetid://108687700865434", "rbxassetid://76172048519874" }
}
local v79 = {
	size = {},
	color = {},
	pos = {},
	transp = {}
}

for _, v80 in ipairs(guiObjects) do
	v79.size[v80] = v80.Size
	v79.color[v80] = v80.BackgroundColor3
	v79.pos[v80] = v80.Position
	v79.transp[v80] = v80.BackgroundTransparency
end

if loading then
	loading.Visible = false
end

local v80 = {
	fades = {},
	dots = false,
	squares = false,
	gen = 0,
	lastSfx = 0,
	token = 0,
	shown = false,
	label = "LOADING"
}

local function cancelfades()
	for _, fade in ipairs(v80.fades) do
		fade:Cancel()
	end

	v80.fades = {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function runt(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	table.insert(v80.fades, tween)
	return tween
end

local function setsq(data, p)
	local v81 = v79.size[data] or data.Size
	local uDim = v79.pos[data] or data.Position
	local color = p and v78.color or v79.color[data] or data.BackgroundColor3
	local uDim2

	if p then
		local growth = v78.growth
		uDim2 = UDim2.new(v81.X.Scale * growth, v81.X.Offset * growth, v81.Y.Scale * growth, v81.Y.Offset * growth)
		local v82 = v81.X.Scale * (growth - 1)
		local v83 = v81.X.Offset * (growth - 1)
		local v84 = v81.Y.Scale * (growth - 1)
		local v85 = v81.Y.Offset * (growth - 1)
		local X = data.AnchorPoint.X
		local Y = data.AnchorPoint.Y
		uDim = UDim2.new(
			uDim.X.Scale + -(v82 / 2) * (1 - 2 * X),
			uDim.X.Offset + -(v83 / 2) * (1 - 2 * X),
			uDim.Y.Scale + -(v84 / 2) * (1 - 2 * Y),
			uDim.Y.Offset + -(v85 / 2) * (1 - 2 * Y)
		)
	else
		uDim2 = v81
	end

	TweenService:Create(data, TweenInfo.new(v78.tweentime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = color,
		Size = uDim2,
		Position = uDim
	}):Play()
end

function setBrowseLoading(p, p2)
	if not loading then
		return
	end

	if p then
		if v80.shown then
			return
		end

		v80.token += 1
		v80.shown = true
		loading.Active = true
		cardGrid.Visible = false
		noResults.Visible = false
		pageBar.Visible = false
		cancelfades()
		loading.Visible = true

		if p2 then
			loading.BackgroundTransparency = v78.targetbg

			if textLabel then
				textLabel.TextTransparency = v78.targett
			end

			for _, v82 in ipairs(guiObjects) do
				v82.BackgroundTransparency = v79.transp[v82] or 0
			end
		else
			loading.BackgroundTransparency = 1

			if textLabel then
				textLabel.TextTransparency = 1
			end

			for _, v82 in ipairs(guiObjects) do
				v82.BackgroundTransparency = 1
			end

			local tweenInfo = TweenInfo.new(v78.fadein, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			runt(loading, tweenInfo, {
				BackgroundTransparency = v78.targetbg
			}) -- equivalent call inferred; original call site unknown

			if textLabel then
				local tween = TweenService:Create(textLabel, tweenInfo, {
					TextTransparency = v78.targett
				})
				tween:Play()
				table.insert(v80.fades, tween)
			end

			for _, v84 in ipairs(guiObjects) do
				local tween = TweenService:Create(v84, tweenInfo, {
					BackgroundTransparency = v79.transp[v84] or 0
				})
				tween:Play()
				table.insert(v80.fades, tween)
			end
		end

		if #guiObjects > 0 and not v80.squares then
			v80.squares = true
			v80.gen += 1
			local gen = v80.gen
			task.spawn(function()
				local v83 = 1
				local v84 = true

				while v80.squares and v80.gen == gen do
					for i, v85 in ipairs(guiObjects) do
						setsq(v85, i == v83)
					end

					if not v84 and shared and typeof(shared.sfx) == "function" then
						local now2 = tick()

						if now2 - v80.lastSfx > v78.sfxdedup then
							v80.lastSfx = now2
							local soundId = v78.sfx[(v83 - 1) % #v78.sfx + 1]
							pcall(function()
								shared.sfx({
									SoundId = soundId,
									Parent = workspace,
									Volume = 0.35
								}):Play()
							end)
						end
					end

					v83 = v83 % #guiObjects + 1
					task.wait(v78.steptime)
					v84 = false
				end
			end)
		end

		if textLabel and not v80.dots then
			v80.dots = true
			task.spawn(function()
				local v82 = 0

				while v80.dots do
					if textLabel.Parent then
						textLabel.Text = v80.label .. string.rep(".", v82)
					end

					v82 = (v82 + 1) % 4
					task.wait(0.3)
				end
			end)
		end
	else
		if not v80.shown then
			return
		end

		v80.shown = false
		loading.Active = false
		v80.token += 1
		local token = v80.token
		v80.dots = false
		v80.squares = false
		v80.gen += 1
		cancelfades()
		local tweenInfo = TweenInfo.new(v78.fadeout, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		runt(loading, tweenInfo, {
			BackgroundTransparency = 1
		}) -- equivalent call inferred; original call site unknown

		if textLabel then
			local tween = TweenService:Create(textLabel, tweenInfo, {
				TextTransparency = 1
			})
			tween:Play()
			table.insert(v80.fades, tween)
		end

		for _, v83 in ipairs(guiObjects) do
			local tween = TweenService:Create(v83, tweenInfo, {
				BackgroundTransparency = 1
			})
			tween:Play()
			table.insert(v80.fades, tween)
		end

		task.delay(v78.fadeout, function()
			if token ~= v80.token then
				return
			end

			loading.Visible = false

			for _, v83 in ipairs(guiObjects) do
				v83.Size = v79.size[v83] or v83.Size
				v83.BackgroundColor3 = v79.color[v83] or v83.BackgroundColor3
				v83.Position = v79.pos[v83] or v83.Position
			end
		end)
	end
end

function pinBrowseEntry(entry)
	if typeof(entry) ~= "table" then
		return
	end

	local id = tostring(entry.id or "")

	if id == "" then
		return
	end

	for i = #v35, 1, -1 do
		if tostring(v35[i].entry.id or "") == id then
			table.remove(v35, i)
		end
	end

	table.insert(v35, 1, {
		entry = entry,
		expiresAt = os.clock() + 30
	})

	while #v35 > 8 do
		table.remove(v35)
	end
end

function refreshBrowse(p)
	fn("WSG dasfgasopfj9a0fsu098safuasf8asf098asf098as98fas09fas80f9as809fa8s9f098")
	v41.browse += 1
	local browse = v41.browse

	if not p then
		setBrowseLoading(true)
	end

	local v82 = trimString(searchInput.Text)
	local search = effectiveBrowseSearchText(v82)
	creators = {}
	local flag5 = false

	if search ~= "" then
		local v84 = req("SearchCreators", {
			search = search,
			limit = 6
		}, 4)

		if browse ~= v41.browse then
			return
		end

		if v84 and v84.ok and typeof(v84.creators) == "table" then
			creators = v84.creators
		end
	end

	if v82 ~= "" then
		local exactCreatorSearchUser = resolveExactCreatorSearchUser(v82)

		if exactCreatorSearchUser then
			local v84 = false

			for _, creator in ipairs(creators) do
				if tonumber(creator.userId) ~= tonumber(exactCreatorSearchUser.userId) then
					continue
				end

				v84 = true

				if trimString((tostring(creator.userName or ""))) == "" and trimString((tostring(exactCreatorSearchUser.userName or ""))) ~= "" then
					creator.userName = exactCreatorSearchUser.userName
				end

				if tonumber(exactCreatorSearchUser.userId) ~= localPlayer.UserId then
					break
				end

				creator.totalUploads = exactCreatorSearchUser.totalUploads
				creator.totalLikes = exactCreatorSearchUser.totalLikes
				creator.totalDislikes = exactCreatorSearchUser.totalDislikes
				creator.totalFavorites = exactCreatorSearchUser.totalFavorites
				creator.totalUses = exactCreatorSearchUser.totalUses
				creator.totalAdded = exactCreatorSearchUser.totalAdded
				creator.totalDownloads = exactCreatorSearchUser.totalDownloads
				creator.matchKind = exactCreatorSearchUser.matchKind or creator.matchKind
				break
			end

			if not v84 then
				table.insert(creators, 1, exactCreatorSearchUser)
			end
		end
	end

	local v84

	if v8 == "added" or v8 == "favourites" then
		local v85 = req(v8 == "added" and "GetAdded" or "GetFavourites", {
			page = page,
			limit = RequestHelper.ITEMS_PER_PAGE,
			search = search,
			assetType = v64[v9] or "all",
			tags = tags
		}, 4)

		if browse ~= v41.browse then
			return
		end

		if v85.ok then
			v14 = {}

			for _, v86 in ipairs(v85.entries or {}) do
				table.insert(v14, toRuntimeLegacyEntry(v86))
			end

			v12 = math.max(1, tonumber(v85.totalPages) or 1)

			if v12 < page then
				page = v12
				return refreshBrowse(p)
			else
				v84 = {
					total = tonumber(v85.total) or #v14
				}
				flag5 = true
			end
		else
			v14 = {}
			v12 = 1
			v84 = {
				total = 0
			}
		end
	else
		v84 = req("BrowseQuery", {
			page = page,
			limit = RequestHelper.ITEMS_PER_PAGE,
			search = search,
			sortBy = RequestHelper.SORT_TO_INDEX[v8] or "most_liked",
			assetType = v64[v9] or "all",
			tags = tags
		}, 4)

		if browse ~= v41.browse then
			return
		end

		if v84.ok then
			v14 = {}

			for _, v85 in ipairs(v84.entries or {}) do
				table.insert(v14, toRuntimeLegacyEntry(v85))
			end

			v12 = math.max(1, tonumber(v84.totalPages) or 1)

			if v12 < page then
				page = v12
				return refreshBrowse(p)
			else
				flag5 = true
			end
		else
			v14 = {}
			v12 = 1
		end
	end

	if v8 == "favourites" and page == 1 then
		local v85 = v64[v9] or "all"
		local v86 = string.lower(search or "")
		local v87 = {}

		for _, v88 in ipairs(v14) do
			v87[tostring(v88.id or "")] = true
		end

		for k, v88 in pairs(v17) do
			local v89 = tostring(k)

			if v88 ~= true or v87[v89] then
				continue
			end

			local v90 = entryById[v89]

			if typeof(v90) ~= "table" then
				continue
			end

			local v91 = v85 == "all" or v64[tostring(v90.category or "")] == v85 or tostring(v90.type or "") == v85
			local v92 = v86 == "" or string.find(string.lower((tostring(v90.name or ""))), v86, 1, true) ~= nil

			if not (v91 and v92) then
				continue
			end

			table.insert(v14, 1, v90)
			v87[v89] = true
		end
	end

	v14 = filterDisabledLegacyEntries(v14)

	if next(v34) ~= nil then
		for i = #v14, 1, -1 do
			if v34[tostring(v14[i].id)] then
				table.remove(v14, i)
			end
		end
	end

	if search == "" and page == 1 and v8 ~= "added" and v8 ~= "favourites" and #v35 > 0 then
		local now2 = os.clock()
		local v85 = v64[v9] or "all"
		local v86 = {}

		for _, v87 in ipairs(v14) do
			v86[tostring(v87.id)] = true
		end

		for i = #v35, 1, -1 do
			local v87 = v35[i]
			local id = tostring(v87.entry.id or "")

			if (tonumber(v87.expiresAt) or 0) <= now2 or v86[id] or v34[id] then
				table.remove(v35, i)
			end
		end

		local v87 = {}

		for _, v88 in ipairs(v35) do
			local entry = v88.entry
			local type2 = tostring(entry.type or "")

			if not (v85 == "all" or type2 == v85) or v86[tostring(entry.id)] then
				continue
			end

			v87[#v87 + 1] = toRuntimeLegacyEntry(entry)
			v86[tostring(entry.id)] = true
		end

		for i = #v87, 1, -1 do
			table.insert(v14, 1, v87[i])
		end
	end

	page = math.clamp(page, 1, v12)

	if flag5 then
		now = os.clock()
	end

	local v85

	if v9 == "ALL" then
		v85 = "item"
	elseif v9 == "Character" then
		v85 = "character"
	elseif v9 == "Map" then
		v85 = "map"
	elseif v9 == "Move" then
		v85 = "move"
	elseif v9 == "CreatedAnim" or v9 == "Animations" then
		v85 = "animation"
	elseif v9 == "M1Style" then
		v85 = "M1 style"
	elseif v9 == "WallCombo" then
		v85 = "wall combo"
	elseif v9 == "ForwardDash" then
		v85 = "dash"
	else
		v85 = "anim"
	end

	local total = v84 and tonumber(v84.total) or #v14
	local count4 = #creators
	resultsCount.Text = formatNum(total) .. " " .. v85 .. (total == 1 and "" or "s") .. " found"

	if count4 > 0 then
		resultsCount.Text = resultsCount.Text .. "  |  " .. formatNum(count4) .. " creator" .. (count4 == 1 and "" or "s")
	end

	local noResults2 = noResults
	noResults2.Visible = #v14 == 0 and count4 == 0
	cardGrid.Visible = #v14 > 0 or count4 > 0
	pageBar.Visible = #v14 > 0
	local browseStructureSignature = buildBrowseStructureSignature(v12, page, total, creators, v14)

	if browseStructureSignature == v46 then
		for _, v87 in ipairs(v14) do
			local guiObject = cardGrid:FindFirstChild("Card_" .. tostring(v87.id))

			if guiObject and guiObject:IsA("GuiObject") then
				applyBrowseCardState(guiObject, v87)
			end
		end
	else
		v46 = browseStructureSignature
		refreshBrowseCards(browse)
	end

	updatePageButtons()
	fn5()
	local text2 = formatNum(tonumber(total) or 0) .. " ITEMS"

	if count4 > 0 then
		text2 ..= " | " .. formatNum(count4) .. " CREATORS"
	end

	countBadge.Text = text2
	countBadge.Visible = true

	if v7 == "BROWSE" then
		setBrowseLoading(false)
	end
end

function applyBrowseStatsSnapshot(options)
	local v81 = {}

	for _, v82 in ipairs(options or {}) do
		local v83 = toRuntimeLegacyEntry(v82)

		if v83 and v83.id then
			v81[v83.id] = v83
		end
	end

	local flag5 = false

	for _, v82 in ipairs(v14) do
		local v83 = v81[v82.id]

		if not v83 then
			continue
		end

		local v84 = v18[v82.id] ~= nil
		local v85 = v17[v82.id] == true

		for k, v86 in pairs(v83) do
			if v84 then
				if not (k ~= "likes" and k ~= "dislikes") then
					continue
				end
			end

			if v85 then
				if not (k ~= "favourites" and k ~= "favorites") then
					continue
				end
			end

			v82[k] = v86
		end

		flag5 = true
		local guiObject = cardGrid:FindFirstChild("Card_" .. tostring(v82.id))

		if guiObject and guiObject:IsA("GuiObject") then
			applyBrowseCardState(guiObject, v82)
		end
	end

	if flag5 then
		fn5()
	end

	return flag5
end

function refreshBrowseStatsOnly()
	if #v14 == 0 or (v8 == "added" or v8 == "favourites") then
		return
	end

	local now2 = os.clock()

	if v47 <= now2 and os.clock() - now >= RequestHelper.BROWSE_BACKGROUND_FULL_REFRESH_SEC then
		refreshBrowse(true)
	end
end

function resolveSortId(instance)
	local sortId = instance:GetAttribute("SortId")

	if typeof(sortId) == "string" and trimString(sortId) ~= "" then
		return trimString(sortId)
	end

	local v81 = trimString(instance.Name)

	if v81 == "" then
		return nil
	end

	return string.lower(v81)
end

function ensureClickOverlay(parent2)
	local __ClickOverlay = parent2:FindFirstChild("__ClickOverlay")

	if __ClickOverlay and __ClickOverlay:IsA("GuiButton") then
		return __ClickOverlay
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "__ClickOverlay"
	textButton.BackgroundTransparency = 1
	textButton.BorderSizePixel = 0
	textButton.Text = ""
	textButton.AutoButtonColor = false
	textButton.Active = true
	textButton.Size = UDim2.fromScale(1, 1)
	textButton.ZIndex = (parent2.ZIndex or 1) + 10
	textButton.Parent = parent2
	return textButton
end

SORT_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function rememberSortIdleBg(instance)
	if instance:GetAttribute("__SortIdleStored") ~= true then
		instance:SetAttribute("__SortIdleStored", true)
		instance:SetAttribute("__SortIdleBg", instance.BackgroundColor3)
		instance:SetAttribute("__SortIdleBgT", instance.BackgroundTransparency)
	end
end

function updateSortPillsVisuals()
	for _, guiObject in ipairs(sortRow:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local sortId = resolveSortId(guiObject)

		if sortId == nil then
			continue
		end

		rememberSortIdleBg(guiObject)
		local v81 = v8 == sortId
		guiObject:SetAttribute("Selected", v81)
		local backgroundColor2 = v81 and backgroundColor or guiObject:GetAttribute("__SortIdleBg") or guiObject.BackgroundColor3
		local backgroundTransparency = v81 and 0.2 or guiObject:GetAttribute("__SortIdleBgT") or guiObject.BackgroundTransparency
		TweenService:Create(guiObject, SORT_TWEEN, {
			BackgroundColor3 = backgroundColor2,
			BackgroundTransparency = backgroundTransparency
		}):Play()
	end
end

function setupBrowseSortControls()
	for _, guiObject in ipairs(sortRow:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local sortId = resolveSortId(guiObject)

		if not (sortId ~= nil and guiObject:GetAttribute("__SortBound") ~= true) then
			continue
		end

		guiObject:SetAttribute("__SortBound", true)
		guiObject.Active = true

		if guiObject:IsA("TextButton") or guiObject:IsA("ImageButton") then
			guiObject.AutoButtonColor = false
		end

		rememberSortIdleBg(guiObject)
		local v81 = sortId

		local function onMouseButton1Click()
			if v8 == v81 then
				v8 = nil
			else
				v8 = v81
			end

			updateSortPillsVisuals()
			page = 1
			refreshBrowse()
		end

		if not guiObject:IsA("GuiButton") then
			guiObject = ensureClickOverlay(guiObject)
		end

		guiObject.MouseButton1Click:Connect(onMouseButton1Click)
	end

	updateSortPillsVisuals()
end

setupBrowseSortControls()

function canonicalCategoryId(p)
	local v81 = trimString(p)

	if string.sub(v81, 1, 4) == "Cat_" or string.sub(v81, 1, 4) == "cat_" then
		v81 = trimString((string.sub(v81, 5)))
	end

	if v81 == "" then
		return nil
	elseif v81 == "ALL" then
		return "ALL"
	end

	if v64[v81] then
		local v82 = v64[v81]

		if v82 == "all" then
			return "ALL"
		end

		return typeToCategory[v82] or v81
	else
		local v82 = string.upper(v81)

		if v64[v82] then
			local v83 = v64[v82]

			if v83 == "all" then
				return "ALL"
			end

			return typeToCategory[v83] or v81
		else
			local v83 = v82:gsub("[%s_%-%/]+", "")

			if v83 == "ALL" then
				return "ALL"
			end

			if v83 == "CHARACTER" or v83 == "CHARACTERS" then
				return "Character"
			end

			if v83 == "MAP" or v83 == "MAPS" then
				return "Map"
			end

			if v83 == "MOVE" or v83 == "MOVES" then
				return "Move"
			end

			if v83 == "AWAKENMOVE" or v83 == "AWAKENMOVES" then
				return "AwakenMove"
			end

			if v83 == "SPAWNANIM" or v83 == "SPAWNANIMS" or v83 == "SPAWNANIMATION" or v83 == "SPAWNANIMATIONS" then
				return "SpawnAnim"
			end

			if v83 == "AWAKENANIM" or v83 == "AWAKENANIMS" or v83 == "AWAKENANIMATION" or v83 == "AWAKENANIMATIONS" then
				return "AwakenAnim"
			end

			if v83 == "M1STYLE" or v83 == "M1STYLES" then
				return "M1Style"
			end

			if v83 == "WALLCOMBO" or v83 == "WALLCOMBOS" then
				return "WallCombo"
			end

			if v83 == "FORWARDDASH" or v83 == "FORWARDDASHES" then
				return "ForwardDash"
			end

			if v83 == "EFFECT" or v83 == "EFFECTS" then
				return "Effect"
			end

			if v83 == "CREATEDANIM" or v83 == "CREATEDANIMS" or v83 == "ANIMATION" or v83 == "ANIMATIONS" then
				return "CreatedAnim"
			end

			return nil
		end
	end
end

function inferCategoryIdFromButton(p)
	if not p then
		return nil
	end

	local v81 = string.lower((p.Name or "") .. " " .. tostring(p.Text or ""))

	if string.match(v81, "%f[%a]all%f[%A]") ~= nil then
		return "ALL"
	end

	if string.find(v81, "character", 1, true) then
		return "Character"
	end

	if string.find(v81, "map", 1, true) then
		return "Map"
	end

	if string.find(v81, "awaken move", 1, true) then
		return "AwakenMove"
	end

	if string.find(v81, "spawn", 1, true) and string.find(v81, "anim", 1, true) then
		return "SpawnAnim"
	end

	if string.find(v81, "awaken", 1, true) and string.find(v81, "anim", 1, true) then
		return "AwakenAnim"
	end

	if string.find(v81, "m1", 1, true) and string.find(v81, "style", 1, true) then
		return "M1Style"
	end

	if string.find(v81, "wall", 1, true) and string.find(v81, "combo", 1, true) then
		return "WallCombo"
	end

	if string.find(v81, "forward", 1, true) and string.find(v81, "dash", 1, true) or string.find(v81, "dash", 1, true) then
		return "ForwardDash"
	end

	if string.find(v81, "effect", 1, true) then
		return "Effect"
	end

	if string.find(v81, "created", 1, true) and string.find(v81, "anim", 1, true) then
		return "CreatedAnim"
	end

	if string.find(v81, "animation", 1, true) or string.find(v81, "anim", 1, true) then
		return "CreatedAnim"
	end

	if string.find(v81, "move", 1, true) then
		return "Move"
	end

	return nil
end

function resolveCategoryIdForButton(instance)
	local catId = instance and instance:GetAttribute("CatId")
	local v81 = canonicalCategoryId(catId)
	local v82 = inferCategoryIdFromButton(instance)

	if v82 then
		if v81 ~= v82 and instance then
			instance:SetAttribute("CatId", v82)
		end

		return v82
	else
		if not v81 then
			return nil
		end

		if instance and catId ~= v81 then
			instance:SetAttribute("CatId", v81)
		end

		return v81
	end
end

v9 = canonicalCategoryId(v9) or "ALL"
v9 = v66[v9] and "ALL" or v9

function updateCatBar()
	for _, button in ipairs(catRow:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local categoryIdForButton = resolveCategoryIdForButton(button)

		if categoryIdForButton == nil then
			continue
		end

		rememberButtonVisual(object2, button)
		restoreButtonVisual(object2, button)

		if categoryIdForButton ~= v9 then
			continue
		end

		button.TextColor3 = textColor
		button.BackgroundColor3 = backgroundColor
		button.BackgroundTransparency = 0.2
		local uIStroke = button:FindFirstChildWhichIsA("UIStroke")

		if not uIStroke then
			continue
		end

		uIStroke.Color = color3
		uIStroke.Transparency = 0.2
	end
end

local function setupBrowseCategoryAndTagControls()
	for _, button in ipairs(catRow:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local categoryIdForButton = resolveCategoryIdForButton(button)

		if categoryIdForButton == nil then
			continue
		end

		if v66[categoryIdForButton] then
			button:Destroy()
		else
			button.AutoButtonColor = false
			rememberButtonVisual(object2, button)
			local v81 = button
			local v82 = categoryIdForButton
			button.MouseButton1Click:Connect(function()
				v9 = resolveCategoryIdForButton(v81) or v82
				page = 1
				updateCatBar()
				refreshBrowse()
			end)
		end
	end

	for _, button in ipairs(tagPickerScroll:GetChildren()) do
		if button:IsA("TextButton") and button:GetAttribute("TagName") then
			button.MouseButton1Click:Connect(function() end)
		end
	end

	tagPickerSearch:GetPropertyChangedSignal("Text"):Connect(function()
		local text2 = tagPickerSearch.Text:lower()

		for _, button in ipairs(tagPickerScroll:GetChildren()) do
			if button:IsA("TextButton") and button:GetAttribute("TagName") then
				button.Visible = text2 == "" or button:GetAttribute("TagName"):lower():find(text2, 1, true) ~= nil
			end
		end
	end)
	tagPickerOverlay.Active = true
	tagPickerOverlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local vector = Vector2.new(input.Position.X, input.Position.Y)

			if not isPointInside(tagPickerCard, vector) then
				tagPickerOverlay.Visible = false
			end
		end
	end)
	clearAllBtn.MouseButton1Click:Connect(function()
		searchInput.Text = ""
		tags = {}
		v9 = "ALL"
		v8 = nil
		page = 1
		updateCatBar()
		updateSortPillsVisuals()
		refreshBrowse()
	end)
	local count4 = 0
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		count4 += 1
		local v81 = count4
		task.delay(1, function()
			if v81 ~= count4 then
				return
			end

			page = 1
			refreshBrowse()
		end)
	end)
end

setupBrowseCategoryAndTagControls()

function toggleFavourite(p, _)
	if not claimActionDebounce("fav", p, 0.2) then
		return false
	end

	local v81 = entryById[p]
	local v82 = v17[p] ~= true
	v17[p] = v82 or nil

	if v81 then
		v81.favourites = math.max(0, (tonumber(v81.favourites) or 0) + (v82 and 1 or -1))
	end

	v37[p] = {
		value = v82,
		exp = os.clock() + 120
	}
	local guiObject = cardGrid:FindFirstChild("Card_" .. tostring(p))

	if guiObject and guiObject:IsA("GuiObject") and v81 then
		applyBrowseCardState(guiObject, v81)
	end

	fn5()
	local catalogueVoteBuffer = ReplicatedStorage:FindFirstChild("CatalogueVoteBuffer")

	if catalogueVoteBuffer then
		catalogueVoteBuffer:FireServer("fav", p, v82)
	end

	return true
end

function handleVote(p, p2)
	local v81 = p2 == "up" and "like" or "dislike"

	if not claimActionDebounce(v81, p, 0.2) then
		return false
	end

	local v82 = entryById[p]
	local v83 = v18[p]
	local v84 = p2 == "up" and "up" or "down"

	if v83 == v84 then
		v84 = nil
	end

	v18[p] = v84

	if v82 then
		if v83 == "up" then
			v82.likes = math.max(0, (tonumber(v82.likes) or 0) - 1)
		elseif v83 == "down" then
			v82.dislikes = math.max(0, (tonumber(v82.dislikes) or 0) - 1)
		end

		if v84 == "up" then
			v82.likes = (tonumber(v82.likes) or 0) + 1
		elseif v84 == "down" then
			v82.dislikes = (tonumber(v82.dislikes) or 0) + 1
		end
	end

	v36[p] = {
		value = v84 or false,
		exp = os.clock() + 120
	}
	local guiObject = cardGrid:FindFirstChild("Card_" .. tostring(p))

	if guiObject and guiObject:IsA("GuiObject") and v82 then
		applyBrowseCardState(guiObject, v82)
	end

	fn5()
	local v85 = v84 == "up" and 1 or v84 == "down" and -1 or 0
	local catalogueVoteBuffer = ReplicatedStorage:FindFirstChild("CatalogueVoteBuffer")

	if catalogueVoteBuffer then
		catalogueVoteBuffer:FireServer("vote", p, v85)
	end

	return true
end

function updateDetailFav()
	if not v24 then
		return
	end

	local v81 = v17[v24.id] == true
	applyFavouriteVisual(detFav, v81)
end

function updateDetailVotes()
	if not v24 then
		return
	end

	local v81 = v18[v24.id]
	applyVoteVisual(detLikeBtn, detDislikeBtn, v81)
end

function isCharDetailInSelection(p)
	if not p or p.category ~= "Character" then
		return false
	end

	local importFingerprint = requestApi.buildImportFingerprint(p.config, {
		buildImportCompactConfig = buildImportCompactConfig
	})

	if importFingerprint == "" then
		return false
	end

	local v81 = requestApi.buildLocalCharacterSelectionMap({
		player = localPlayer,
		listCacheState = listCacheState
	}, {
		buildImportCompactConfig = buildImportCompactConfig,
		trimString = trimString
	})[importFingerprint]
	return v81 ~= nil and v81.added == true
end

function updateDetailPS()
	if not v24 then
		return
	end

	if not (detAddPSBtn and detAddPSBtn:IsA("GuiButton") and detRemovePSBtn and detRemovePSBtn:IsA("GuiObject")) then
		detailCardApi.warnMissingOnce(
			"detail_action_buttons_missing_" .. tostring(detailCard and detailCard.Name or "unknown"),
			string.format(
				"[GlobalCatalogue][UIWarn] detail action buttons missing on active card=%s",
				(tostring(detailCard and detailCard:GetFullName() or "nil"))
			)
		)
		return
	end

	local visible = addedToPS[v24.id] == true
	local v82 = v24.category == "Map"
	local theaterBtn = detailCard and detailCard:FindFirstChild("TheaterBtn", true)

	if theaterBtn and theaterBtn:IsA("GuiObject") then
		theaterBtn.Visible = false
		theaterBtn.Active = false

		if theaterBtn:IsA("GuiButton") then
			theaterBtn.AutoButtonColor = false
		end
	end

	if detAddedBadge then
		detAddedBadge.Visible = visible
	end

	detAddPSBtn.Active = true
	detAddPSBtn.AutoButtonColor = true
	detAddPSBtn.Text = RequestHelper.CAT_ADD_TEXT[v24.category or "Character"] or "ADD TO PS"

	if detAddPSBtn:GetAttribute("CatAddBaseColor") == nil then
		detAddPSBtn:SetAttribute("CatAddBaseColor", detAddPSBtn.BackgroundColor3)
	end

	if v82 then
		local v83 = catMapKeyFromEntry(v24)
		local v84 = v83 and v77.state[v83]
		local catalogueMapAlreadyLoaded = isCatalogueMapAlreadyLoaded(parseMapRefFromEntry(v24))
		detAddPSBtn.Visible = true

		if detAddPSBtn:IsA("TextButton") or detAddPSBtn:IsA("TextLabel") then
			detAddPSBtn.Text = catMapButtonTextByKey(v83, "detail")
		end

		if v84 == "waiting" or v84 == "loading" or v84 == "removing" then
			detAddPSBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
		elseif catalogueMapAlreadyLoaded then
			detAddPSBtn.BackgroundColor3 = Color3.fromRGB(168, 62, 62)
		else
			detAddPSBtn.BackgroundColor3 = detAddPSBtn:GetAttribute("CatAddBaseColor")
		end

		detRemovePSBtn.Visible = visible

		if visible and (detRemovePSBtn:IsA("TextButton") or detRemovePSBtn:IsA("TextLabel")) and detRemovePSBtn.Text ~= "SURE?" then
			detRemovePSBtn.Text = "DELETE"
		end
	else
		detAddPSBtn.BackgroundColor3 = detAddPSBtn:GetAttribute("CatAddBaseColor")

		if v24.category == "Character" then
			if visible then
				requestApi.endCharAddPending(v24.id)
				detAddPSBtn:SetAttribute("AddingGen", (detAddPSBtn:GetAttribute("AddingGen") or 0) + 1)
				detAddPSBtn.Visible = false
				detRemovePSBtn.Visible = true

				if detRemovePSBtn:IsA("TextButton") or detRemovePSBtn:IsA("TextLabel") then
					detRemovePSBtn.Text = "DELETE"
				end
			elseif requestApi.isCharAddPending(v24.id) then
				detRemovePSBtn.Visible = false
				detAddPSBtn.Visible = true
				detAddPSBtn.Active = false
				detAddPSBtn.AutoButtonColor = false
				local v83 = (detAddPSBtn:GetAttribute("AddingGen") or 0) + 1
				detAddPSBtn:SetAttribute("AddingGen", v83)
				detAddPSBtn.Text = "ADDING"
				task.spawn(function()
					local v84 = 0

					while detAddPSBtn:GetAttribute("AddingGen") == v83 and v24 and detAddPSBtn.Parent and requestApi.isCharAddPending(v24.id) do
						detAddPSBtn.Text = "ADDING" .. string.rep(".", v84)
						v84 = (v84 + 1) % 4
						task.wait(0.35)
					end
				end)
			else
				detAddPSBtn:SetAttribute("AddingGen", (detAddPSBtn:GetAttribute("AddingGen") or 0) + 1)
				detAddPSBtn.Visible = true
				detRemovePSBtn.Visible = false
			end
		else
			if detRemovePSBtn:IsA("TextButton") or detRemovePSBtn:IsA("TextLabel") then
				detRemovePSBtn.Text = "REMOVE"
			end

			detAddPSBtn.Visible = not visible
			detRemovePSBtn.Visible = visible
		end
	end
end

local function onLoadedCatalogueMapChanged()
	if v24 and charDetailOverlay.Visible and v24.category == "Map" then
		updateDetailPS()
	end

	for k, v81 in pairs(v77.state) do
		local v82, v83 = string.match(k, "^(%d+):(%d+)$")

		if not v82 then
			continue
		end

		local catalogueMapAlreadyLoaded = isCatalogueMapAlreadyLoaded(tonumber(v82), (tonumber(v83)))

		if v81 == "loading" and catalogueMapAlreadyLoaded or v81 == "removing" and not catalogueMapAlreadyLoaded then
			clearCatMapOpState(k)
		end
	end

	refreshAddedTabImmediatelyIfVisible()
end

workspace:GetAttributeChangedSignal("GlobalCatalogueLoadedMapSlot"):Connect(onLoadedCatalogueMapChanged)
workspace:GetAttributeChangedSignal("GlobalCatalogueLoadedMapSourceUserId"):Connect(onLoadedCatalogueMapChanged)
workspace.AttributeChanged:Connect(function(value)
	if string.sub(value, 1, 12) == "CatMapLoaded" then
		onLoadedCatalogueMapChanged()
	end
end)
refreshBtn = ReplicatedStorage:WaitForChild("CatalogueMapLifecycle", 10)

if refreshBtn then
	refreshBtn.OnClientEvent:Connect(function(p, p2, p3)
		local v81 = tostring(p2) .. ":" .. tostring(p3)
		warn2("map lifecycle " .. tostring(p) .. " " .. v81)

		if p == "loading" then
			setCatMapOpState(v81, "loading")
		elseif p == "removing" then
			setCatMapOpState(v81, "removing")
		elseif p == "loaded" or p == "removed" then
			clearCatMapOpState(v81)

			if v24 and charDetailOverlay.Visible and v24.category == "Map" then
				updateDetailPS()
			end

			refreshAddedTabImmediatelyIfVisible()
		end
	end)
end

function updateDetailStatValues(data)
	if not data then
		return
	end

	setDetailStatText("LikesStat", emojiThumbsUp() .. " " .. formatNum(data.likes or 0), "likes")
	setDetailStatText("DislikesStat", emojiThumbsDown() .. " " .. formatNum(data.dislikes or 0), "dislikes")
	setDetailStatText("DownloadsStat", utf8.char(11015) .. " " .. formatNum(data.downloads or 0), "downloads")
end

fn5 = function()
	if not (v24 and charDetailOverlay.Visible) then
		return
	end

	local v81 = entryById[v24.id]

	if not v81 then
		return
	end

	v24 = v81
	useDetailCardForEntry(v24)
	updateDetailCreatorRowMeta(v24, detailCardApi.isCharacterEntry(v24))
	updateDetailActionTypeMeta(v24)
	updateDetailStatValues(v24)
	updateDetailFav()
	updateDetailVotes()
	updateDetailPS()
end

function setDetailCloseButtonsBackMode(p)
	for _, v81 in ipairs({
		detailCardApi and detailCardApi.defaultRefs or nil,
		detailCardApi and detailCardApi.characterRefs or nil
	}) do
		local close = v81 and v81.close

		if not (close and (close:IsA("TextButton") or close:IsA("TextLabel"))) then
			continue
		end

		local catalogueOriginalCloseText = close:GetAttribute("CatalogueOriginalCloseText")

		if typeof(catalogueOriginalCloseText) ~= "string" or catalogueOriginalCloseText == "" then
			catalogueOriginalCloseText = tostring(close.Text or "CLOSE")
			close:SetAttribute("CatalogueOriginalCloseText", catalogueOriginalCloseText)
		end

		close.Text = p and "BACK" or catalogueOriginalCloseText
	end
end

function syncDetailOverlayTakeoverLayout()
	if not (charDetailOverlay and charDetailOverlay:IsA("GuiObject")) then
		return
	end

	charDetailOverlay.BackgroundColor3 = rgb(18, 18, 18)
	charDetailOverlay.BackgroundTransparency = 0.08
	charDetailOverlay.BorderSizePixel = 0
	charDetailOverlay.ClipsDescendants = true
	charDetailOverlay.ZIndex = math.max(charDetailOverlay.ZIndex, 25)
end

function syncCreatorOverlayTakeoverLayout()
	if not (creatorProfileOverlay and creatorProfileOverlay:IsA("GuiObject")) then
		return
	end

	creatorProfileOverlay.BackgroundColor3 = rgb(18, 18, 18)
	creatorProfileOverlay.BackgroundTransparency = 0.08
	creatorProfileOverlay.BorderSizePixel = 0
	creatorProfileOverlay.ClipsDescendants = true
	creatorProfileOverlay.ZIndex = math.max(creatorProfileOverlay.ZIndex, 25)

	if creatorCard and creatorCard:IsA("GuiObject") then
		creatorCard.Visible = creatorProfileOverlay.Visible
	end
end

function applyDetailTakeoverVisibility(p)
	local visible = p == true
	syncDetailOverlayTakeoverLayout()

	for k, v82 in pairs(tabs) do
		if v82.frame then
			v82.frame.Visible = not visible and k == v7
		end
	end

	charDetailOverlay.Visible = visible
	setDetailCloseButtonsBackMode(visible)
end

function openDetail(data)
	if flag then
		return
	end

	v24 = data
	applyDetailTakeoverVisibility(true)
	useDetailCardForEntry(data)
	applyEntryAppearance(detailCard, data.appearance)
	local category = data.category or "Character"
	local characterEntry = detailCardApi.isCharacterEntry(data)

	if characterEntry then
		if detTypeBadge then
			detTypeBadge.Visible = false
		end

		if detSubtitle then
			detSubtitle.Visible = false
		end
	else
		if detTypeBadge then
			detTypeBadge.Text = RequestHelper.CAT_LABELS[category] or ""
			detTypeBadge.Visible = true
			detTypeBadge.TextColor3 = rgb(255, 255, 255)
			detTypeBadge.BackgroundColor3 = categoryColors[category] or rgb(200, 60, 60)
		end

		local text2 = not data.source and "" or "from " .. data.source

		if data.moveType then
			text2 = data.moveType .. (text2 == "" and "" or " | " .. text2 or "")
		end

		if text2 == "" or not detSubtitle then
			if detSubtitle then
				detSubtitle.Visible = false
			end
		else
			detSubtitle.Text = text2
			detSubtitle.Visible = true
		end
	end

	local uIStroke = detailCard and detailCard:FindFirstChildWhichIsA("UIStroke")

	if uIStroke then
		uIStroke.Color = categoryColors[category] or rgb(200, 60, 60)
	end

	if detCharName then
		detCharName.Text = data.name
	end

	updateDetailCreatorRowMeta(data, characterEntry)
	updateDetailActionTypeMeta(data)

	if detTagRow then
		for _, label in ipairs(detTagRow:GetChildren()) do
			if label:IsA("TextLabel") then
				label:Destroy()
			end
		end

		for i, tag in ipairs(data.tags) do
			makeTagChip(detTagRow, tag, false, true, i)
		end
	end

	if detDesc then
		detDesc.Text = "\"" .. (data.desc or "") .. "\""
	end

	updateDetailStatValues(data)
	local detMovesSec2 = detMovesSec

	if detMovesSec2 then
		detMovesSec2.Visible = characterEntry
	end

	if characterEntry then
		populateCharacterMovesSection(data)
	end

	if detReportBtn then
		detReportBtn.Visible = true
	end

	if detConfirmReport then
		detConfirmReport.Visible = false
	end

	if category == "Map" and detRemovePSBtn and (detRemovePSBtn:IsA("TextButton") or detRemovePSBtn:IsA("TextLabel")) then
		detRemovePSBtn.Text = "DELETE"
	end

	updateDetailFav()
	updateDetailVotes()
	updateDetailPS()
	updateDetailReportButton()
end

function closeDetail(p)
	applyDetailTakeoverVisibility(false)
	detailCardApi.hideAll()
	v24 = nil

	if detailReturnApi.restoreCreatorProfile(openCreatorProfile) then
		return
	end

	if p ~= true then
		startPopupCooldown()
	end
end

local v81 = {}

function updateDetailReportButton()
	if not (detReportBtn and (detReportBtn:IsA("TextButton") or detReportBtn:IsA("TextLabel"))) then
		return
	end

	if v24 and v38[tostring(v24.id or "")] then
		detReportBtn.Text = "REPORTED"
		detReportBtn.TextColor3 = rgb(255, 70, 70)
	else
		detReportBtn.Text = "REPORT"
		detReportBtn.TextColor3 = rgb(255, 255, 255)
	end
end

function submitSelectedDetailReport()
	if v24 then
		local id = tostring(v24.id or "")
		local v82 = req("Report", {
			entryId = v24.id,
			reason = "Reported from global catalogue UI"
		}, 3)

		if v82.ok then
			v39 = os.clock() + 5

			if v82.adminAction then
				showToast("All of this user's listings removed & catalogue access revoked")
				closeDetail(true)

				if v7 == "BROWSE" then
					refreshBrowse(true)
				end
			else
				v38[id] = true
				showToast("Report submitted. Thanks for keeping TSB clean!")
				updateDetailReportButton()
			end
		elseif v82.error == "report-too-fast" then
			local v83 = math.max(1, (math.ceil(tonumber(v82.retryAfter) or 4)))
			v39 = os.clock() + v83
			showToast("REPORT COOLDOWN (" .. tostring(v83) .. "S)")
		else
			showToast("Report failed")
		end
	end

	if detConfirmReport then
		detConfirmReport.Visible = false
	end

	if detReportBtn then
		detReportBtn.Visible = true
	end
end

function bindDetailCardSignals(data)
	if not data or not data.card or v81[data.card] == true then
		return
	end

	v81[data.card] = true

	if data.close and data.close:IsA("GuiButton") then
		data.close.MouseButton1Click:Connect(closeDetail)
	else
		detailCardApi.warnMissingOnce(
			"detail_close_btn_missing_" .. tostring(data.key),
			string.format(
				"[GlobalCatalogue][UIWarn] CloseBtn missing or not clickable on %s",
				(tostring(data.card:GetFullName()))
			)
		)
	end

	if data.fav and data.fav:IsA("GuiButton") then
		data.fav.MouseButton1Click:Connect(function()
			if v24 then
				toggleFavourite(v24.id)
			end
		end)
	end

	if data.likeBtn and data.likeBtn:IsA("GuiButton") then
		data.likeBtn.MouseButton1Click:Connect(function()
			if v24 and handleVote(v24.id, "up") then
				local v82 = entryById[v24.id]

				if v82 then
					v24.likes = v82.likes
					v24.dislikes = v82.dislikes
					updateDetailStatValues(v24)
				end

				updateDetailVotes()
			end
		end)
	end

	if data.dislikeBtn and data.dislikeBtn:IsA("GuiButton") then
		data.dislikeBtn.MouseButton1Click:Connect(function()
			if v24 and handleVote(v24.id, "down") then
				local v82 = entryById[v24.id]

				if v82 then
					v24.likes = v82.likes
					v24.dislikes = v82.dislikes
					updateDetailStatValues(v24)
				end

				updateDetailVotes()
			end
		end)
	end

	if data.addPSBtn and data.addPSBtn:IsA("GuiButton") then
		data.addPSBtn.MouseButton1Click:Connect(function()
			if v24 then
				if v24.category == "Map" then
					local v82 = catMapKeyFromEntry(v24)

					if v82 and v77.state[v82] then
						return
					end

					if isCatalogueMapAlreadyLoaded(parseMapRefFromEntry(v24)) then
						if requestCatalogueMapRemove(v24, "GlobalCatalogueDetailMapToggle") then
							setCatMapOpState(v82, "waiting")
							warn2("map remove requested " .. tostring(v82))
						end
					else
						local id = v24.id

						if requestCatalogueMapLoad(v24, "GlobalCatalogueDetail") then
							setCatMapOpState(v82, "waiting")
							warn2("map load requested " .. tostring(v82))
							task.spawn(function()
								local v84 = req("AddToPS", {
									entryId = id
								}, 3)

								if v84 and v84.ok then
									addedToPS[id] = true
									local v85 = entryById[id]

									if v85 then
										v85.addedCount = tonumber(v84.addedCount) or v85.addedCount
										v85.downloads = math.max(v85.downloads or 0, v85.addedCount or 0)
									end

									updateTabCounts()

									if v24 and v24.id == id and charDetailOverlay.Visible then
										updateDetailPS()
									end

									refreshAddedTabImmediatelyIfVisible()
								end
							end)
						end
					end
				elseif v24.category == "Character" and localPlayer:GetAttribute("CustomCharacterImporting") == true then
					showToast("PLEASE WAIT FOR THE OTHER CHARACTER TO BE ADDED")
				else
					requestApi.performDetailPsToggle(v24, true, {
						addedToPS = addedToPS,
						addInFlight = addInFlight,
						getLiveDetail = function(value, p)
							if v24 and tostring(v24.id or "") == tostring(value or "") then
								return v24
							end

							if typeof(entryById) == "table" and typeof(entryById[tostring(value or "")]) == "table" then
								return entryById[tostring(value or "")]
							end

							return p
						end,
						showToast = showToast,
						entryById = entryById,
						updateLocalEntryAddedCount = updateLocalEntryAddedCount,
						setPendingPsMutation = setPendingPsMutation,
						clearPendingPsMutation = clearPendingPsMutation,
						updateDetailPS = updateDetailPS,
						updateTabCounts = updateTabCounts,
						requestCatalogueMapLoad = requestCatalogueMapLoad,
						requestCatalogueMapCleanup = requestCatalogueMapCleanup,
						refreshAddedTabImmediatelyIfVisible = refreshAddedTabImmediatelyIfVisible,
						schedulePsMutationRefresh = schedulePsMutationRefresh,
						player = localPlayer,
						listCacheState = listCacheState,
						fireCustomCharacterAction = fireCustomCharacterAction,
						getCommRemote = getCommRemote,
						buildImportCompactConfig = buildImportCompactConfig,
						trimString = trimString,
						req = req
					})
				end
			end
		end)
	end

	if data.removePSBtn and data.removePSBtn:IsA("GuiButton") then
		local count4 = 0
		data.removePSBtn.MouseButton1Click:Connect(function()
			if v24 then
				if v24.category == "Map" then
					local removePSBtn = data.removePSBtn

					if removePSBtn:IsA("TextButton") and removePSBtn.Text ~= "SURE?" then
						count4 += 1
						local v82 = count4
						removePSBtn.Text = "SURE?"
						task.delay(1, function()
							if count4 == v82 and removePSBtn and removePSBtn.Parent then
								removePSBtn.Text = "DELETE"
							end
						end)
						return
					else
						count4 += 1

						if removePSBtn:IsA("TextButton") then
							removePSBtn.Text = "DELETE"
						end
					end
				end

				local id = tostring(v24 and v24.id or "")
				requestApi.performDetailPsToggle(v24, false, {
					addedToPS = addedToPS,
					addInFlight = addInFlight,
					getLiveDetail = function(value, p)
						if v24 and tostring(v24.id or "") == tostring(value or "") then
							return v24
						end

						if typeof(entryById) == "table" and typeof(entryById[tostring(value or "")]) == "table" then
							return entryById[tostring(value or "")]
						end

						return p
					end,
					showToast = showToast,
					entryById = entryById,
					updateLocalEntryAddedCount = updateLocalEntryAddedCount,
					setPendingPsMutation = setPendingPsMutation,
					clearPendingPsMutation = clearPendingPsMutation,
					updateDetailPS = updateDetailPS,
					updateTabCounts = updateTabCounts,
					requestCatalogueMapLoad = requestCatalogueMapLoad,
					requestCatalogueMapCleanup = requestCatalogueMapCleanup,
					refreshAddedTabImmediatelyIfVisible = refreshAddedTabImmediatelyIfVisible,
					schedulePsMutationRefresh = schedulePsMutationRefresh,
					player = localPlayer,
					listCacheState = listCacheState,
					fireCustomCharacterAction = fireCustomCharacterAction,
					getCommRemote = getCommRemote,
					buildImportCompactConfig = buildImportCompactConfig,
					trimString = trimString,
					req = req
				})

				if id ~= "" and addedToPS[id] ~= true then
					local child = addedScroll and addedScroll:FindFirstChild("Added_" .. id)

					if child then
						child:Destroy()
					end

					updateTabCounts()
				end
			end
		end)
	end

	if data.reportBtn and data.reportBtn:IsA("GuiButton") then
		local reportBtn = data.reportBtn

		if data.confirmReport and data.confirmReport:IsA("GuiObject") then
			data.confirmReport.Visible = false
		end

		if v2 then
			reportBtn.BackgroundColor3 = rgb(255, 93, 96)
		end

		local text2 = reportBtn.Text
		local textColor3 = reportBtn.TextColor3
		local count4 = 0
		reportBtn.MouseButton1Click:Connect(function()
			local id = v24 and tostring(v24.id or "") or ""

			if id ~= "" and v38[id] then
				showToast("ALREADY REPORTED")
				return
			end

			local v82 = v39 - os.clock()

			if v82 > 0 then
				showToast("REPORT COOLDOWN (" .. tostring((math.ceil(v82))) .. "S)")
			elseif reportBtn.Text == "SURE?" then
				count4 += 1
				reportBtn.Text = text2
				reportBtn.TextColor3 = textColor3
				submitSelectedDetailReport()
			else
				count4 += 1
				local v83 = count4
				reportBtn.Text = "SURE?"
				reportBtn.TextColor3 = rgb(255, 60, 60)

				if v2 then
					showToast("ARE YOU SURE? EVERY UPLOAD FROM THIS USER WILL BE REMOVED, CATALOGUE ACCESS WILL BE REVOKED - THIS REPORT IS LOGGED")
				end

				task.delay(2, function()
					if count4 ~= v83 then
						return
					end

					if reportBtn and reportBtn.Parent then
						reportBtn.Text = text2
						reportBtn.TextColor3 = textColor3
					end
				end)
			end
		end)
	end

	if data.creatorBtn and data.creatorBtn:IsA("GuiButton") then
		data.creatorBtn.MouseButton1Click:Connect(function()
			if v24 then
				local creatorUserId = v24.creatorUserId
				local creator = v24.creator
				openCreatorProfile(creatorUserId, creator, {
					bypassCooldown = true
				})
			end
		end)
	elseif data.creatorBtn then
		detailCardApi.warnMissingOnce(
			"detail_creator_trigger_non_button_" .. tostring(data.key),
			string.format(
				"[GlobalCatalogue][UIWarn] creator trigger is not clickable on %s",
				(tostring(data.card:GetFullName()))
			)
		)
	end
end

bindDetailCardSignals(detailCardApi.defaultRefs)
bindDetailCardSignals(detailCardApi.characterRefs)
bindGuiDrag(mainPanel, header, { closeBtn, refresh })
header = bindGuiDrag
refreshBtn = detailCardApi.defaultCard
lbSubBar = detailCardApi.defaultRefs and detailCardApi.defaultRefs.headerFrame
local close

if detailCardApi.defaultRefs then
	close = detailCardApi.defaultRefs.close or nil
end

local v83

if detailCardApi.defaultRefs then
	v83 = detailCardApi.defaultRefs.fav or nil
end

local v82 = { close, v83 }
header(refreshBtn, lbSubBar, v82)
header = bindGuiDrag
refreshBtn = detailCardApi.characterCard
lbSubBar = detailCardApi.characterRefs and detailCardApi.characterRefs.headerFrame
v82 = {}

if detailCardApi.characterRefs then
	close = detailCardApi.characterRefs.close or nil
else
	close = nil
end

v82[1], v82[2] = close, detailCardApi.characterRefs and detailCardApi.characterRefs.fav or nil
header(refreshBtn, lbSubBar, v82)
charDetailOverlay.Active = true
syncDetailOverlayTakeoverLayout()
contentArea:GetPropertyChangedSignal("Position"):Connect(syncDetailOverlayTakeoverLayout)
charDetailOverlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local vector = Vector2.new(input.Position.X, input.Position.Y)

		if not (detailCard and isPointInside(detailCard, vector)) then
			closeDetail()
		end
	end
end)
creatorProfileItems = {}
creatorProfileUserId = 0
creatorProfileName = ""
creatorActiveCategory = "all"
creatorSearchTerm = ""
creatorProfileHelper = RequestHelper.newCreatorProfileApi({
	warnFn = fn,
	req = req,
	showToast = showToast,
	setLoading = function(p)
		setBrowseLoading(p)
	end,
	tabs = tabs,
	creatorOverlay = creatorProfileOverlay,
	detailOverlay = charDetailOverlay,
	getActiveTab = function()
		return v7
	end,
	isPopupCooldown = function()
		return flag == true
	end,
	closeDetail = closeDetail,
	openDetail = openDetail,
	startPopupCooldown = startPopupCooldown,
	syncOverlayLayout = syncCreatorOverlayTakeoverLayout,
	setCloseButtonsBackMode = setDetailCloseButtonsBackMode,
	getVerifiedAvatarHeadshot = getVerifiedAvatarHeadshot,
	applyNameStroke = applyNameStroke,
	toRuntimeLegacyEntry = toRuntimeLegacyEntry,
	typeToCategory = typeToCategory,
	renderItems = function(p, value, options)
		creatorProfileUserId = math.max(0, (math.floor(tonumber(p) or 0)))
		creatorProfileName = tostring(value or "")
		creatorProfileItems = options or {}
		setCreatorExtraData(creatorProfileUserId)
		renderCreatorProfileItems()
	end,
	refs = {
		card = creatorCard,
		nameLabel = crNameLabel,
		snapshotImage = crSnapshotImage,
		likesLabel = crLikesLabel,
		downloadsLabel = crDownloadsLabel,
		favouritesLabel = crFavouritesLabel,
		creationsLabel = crCreationsLabel,
		charScroll = crCharScroll
	}
})

function closeCreatorProfile(p)
	detailReturnApi.clear()
	creatorProfileHelper.close(p)
end

function openCreatorProfile(p, p2, p3)
	detailReturnApi.clear()
	creatorProfileHelper.open(p, p2, p3)
end

CREATOR_CAT_IDS = {
	all = true,
	chars = true,
	maps = true,
	moves = true,
	nims = true
}

function creatorItemMatchesCat(p, p2)
	if p2 == "all" then
		return true
	end

	local category = p.category or "Character"

	if p2 == "chars" then
		return category == "Character"
	elseif p2 == "maps" then
		return category == "Map"
	elseif p2 == "nims" then
		return category == "CreatedAnim"
	end

	return category ~= "Character" and category ~= "Map" and category ~= "CreatedAnim"
end

function updateCreatorCatVisuals()
	if not (crCatRow and crCatRow:IsA("GuiObject")) then
		return
	end

	for _, guiObject in ipairs(crCatRow:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v84 = string.lower(trimString(guiObject.Name))

		if not CREATOR_CAT_IDS[v84] then
			continue
		end

		rememberSortIdleBg(guiObject)
		local v85 = creatorActiveCategory == v84
		guiObject:SetAttribute("Selected", v85)
		local backgroundColor2 = v85 and backgroundColor or guiObject:GetAttribute("__SortIdleBg") or guiObject.BackgroundColor3
		local backgroundTransparency = v85 and 0.2 or guiObject:GetAttribute("__SortIdleBgT") or guiObject.BackgroundTransparency
		TweenService:Create(guiObject, SORT_TWEEN, {
			BackgroundColor3 = backgroundColor2,
			BackgroundTransparency = backgroundTransparency
		}):Play()
	end
end

function setCreatorExtraData(p)
	if not (crExtraData and (crExtraData:IsA("TextLabel") or crExtraData:IsA("TextButton"))) then
		return
	end

	local v84 = math.max(0, (math.floor(tonumber(p) or 0)))

	if v84 <= 0 then
		crExtraData.Text = ""
		return
	end

	local leaderboardUserName, v85 = getLeaderboardUserName(v84)

	if v85 and trimString(leaderboardUserName) ~= "" then
		crExtraData.Text = "@" .. trimString(leaderboardUserName)
		return
	end

	crExtraData.Text = "@..."
	task.spawn(function()
		for _ = 1, 40 do
			if creatorProfileUserId ~= v84 then
				break
			end

			local v86 = v51[v84]

			if v86 == nil or trimString(v86) == "" then
				task.wait(0.05)
			else
				if crExtraData and crExtraData.Parent then
					crExtraData.Text = "@" .. trimString(v86)
				end

				break
			end
		end
	end)
end

function renderCreatorProfileItems()
	local crCharScroll2 = crCharScroll

	if not (crCharScroll2 and crCharScroll2:IsA("GuiObject")) then
		return
	end

	for _, guiObject in ipairs(crCharScroll2:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		if not (guiObject.Name:find("Card_") or guiObject.Name:find("CrItem_") or guiObject.Name:find("CrCatHdr_")) then
			continue
		end

		guiObject:Destroy()
	end

	local v84 = lowerTrim(creatorSearchTerm)

	local function onOpen(p)
		detailReturnApi.rememberCreatorProfile(creatorProfileUserId, creatorProfileName)
		creatorProfileHelper.close(true)
		openDetail(p)
	end

	local count4 = 0

	for _, v85 in ipairs(creatorProfileItems) do
		if not creatorItemMatchesCat(v85, creatorActiveCategory) then
			continue
		end

		local v86 = v84 == ""

		if not v86 then
			local v87 = lowerTrim(tostring(v85.name or "") .. " " .. tostring(v85.creator or "") .. " " .. tostring(v85.category or ""))
			v86 = string.find(v87, v84, 1, true) ~= nil
		end

		if not v86 then
			continue
		end

		count4 += 1
		buildCard(v85, count4, {
			template = creatorCardTemplate,
			parent = crCharScroll2,
			onOpen = onOpen
		})
	end
end

function setupCreatorProfileControls()
	if crCatRow and crCatRow:IsA("GuiObject") then
		for _, guiObject in ipairs(crCatRow:GetChildren()) do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local v84 = string.lower(trimString(guiObject.Name))

			if not (CREATOR_CAT_IDS[v84] and guiObject:GetAttribute("__CrCatBound") ~= true) then
				continue
			end

			guiObject:SetAttribute("__CrCatBound", true)
			guiObject.Active = true

			if guiObject:IsA("TextButton") or guiObject:IsA("ImageButton") then
				guiObject.AutoButtonColor = false
			end

			rememberSortIdleBg(guiObject)
			local v85 = v84

			local function onMouseButton1Click()
				if creatorActiveCategory == v85 then
					return
				end

				creatorActiveCategory = v85
				updateCreatorCatVisuals()
				renderCreatorProfileItems()
			end

			if not guiObject:IsA("GuiButton") then
				guiObject = ensureClickOverlay(guiObject)
			end

			guiObject.MouseButton1Click:Connect(onMouseButton1Click)
		end
	end

	if crSearchBox and crSearchBox:IsA("TextBox") then
		crSearchBox.ClearTextOnFocus = false
		creatorSearchTerm = trimString(crSearchBox.Text or "")
		local count4 = 0
		crSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local v84 = trimString(crSearchBox.Text or "")

			if v84 == creatorSearchTerm then
				return
			end

			creatorSearchTerm = v84
			count4 += 1
			local v85 = count4
			task.delay(0.12, function()
				if v85 ~= count4 then
					return
				end

				renderCreatorProfileItems()
			end)
		end)
	end

	updateCreatorCatVisuals()
end

setupCreatorProfileControls()
crClose.MouseButton1Click:Connect(function()
	closeCreatorProfile(false)
end)
creatorProfileOverlay.Active = true
creatorProfileOverlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local vector = Vector2.new(input.Position.X, input.Position.Y)

		if not isPointInside(creatorCard, vector) then
			closeCreatorProfile(false)
		end
	end
end)
syncCreatorOverlayTakeoverLayout()
contentArea:GetPropertyChangedSignal("Position"):Connect(syncCreatorOverlayTakeoverLayout)

function setLeaderboardSubButtonState(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	guiObject.BackgroundTransparency = p and 0.88 or 1

	if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
		guiObject.TextColor3 = p and rgb(255, 200, 60) or rgb(120, 120, 120)
	end

	local indicator = guiObject:FindFirstChild("Indicator")

	if indicator then
		indicator.BackgroundTransparency = p and 0 or 1
	end
end

function connectLeaderboardSubButton(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	guiObject.Active = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handlePress()
		switchLbSub(p)
	end

	if guiObject:IsA("GuiButton") then
		guiObject.MouseButton1Click:Connect(handlePress)
	else
		guiObject.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				handlePress() -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

function switchLbSub(p)
	v25 = p
	setLeaderboardSubButtonState(lbSub_TOP_CREATORS, p == "TOP_CREATORS")
	setLeaderboardSubButtonState(lbSub_TOP_CHARS, p == "ALL_ITEMS")
	local v84 = p == "ALL_ITEMS" and "items" or "creators"
	local v85

	if v84 == "items" then
		v85 = hasAnyItemsLeaderboardCache()
	else
		v85 = v48.creators > 0
	end

	if v85 then
		refreshLeaderboard(true)
		setBrowseLoading(false)
	end

	local freshLeaderboardCache = hasFreshLeaderboardCache(v84)

	if not (v85 and freshLeaderboardCache) then
		if not v85 then
			setBrowseLoading(true)
		end

		task.spawn(function()
			refreshLeaderboard(false)

			if v7 == "LEADERBOARD" then
				setBrowseLoading(false)
			end
		end)
	end
end

function setupLeaderboardSubTabs()
	if lbSub_TOP_CREATORS:IsA("TextLabel") or lbSub_TOP_CREATORS:IsA("TextButton") then
		lbSub_TOP_CREATORS.Text = "CREATORS"
	end

	if lbSub_TOP_CHARS:IsA("TextLabel") or lbSub_TOP_CHARS:IsA("TextButton") then
		lbSub_TOP_CHARS.Text = "ITEMS"
	end

	lbSub_TOP_CREATORS.Visible = true
	lbSub_TOP_CHARS.Visible = true
	connectLeaderboardSubButton(lbSub_TOP_CREATORS, "TOP_CREATORS")
	connectLeaderboardSubButton(lbSub_TOP_CHARS, "ALL_ITEMS")

	if v25 ~= "TOP_CREATORS" and v25 ~= "ALL_ITEMS" then
		v25 = "TOP_CREATORS"
	end

	setLeaderboardSubButtonState(lbSub_TOP_CREATORS, v25 == "TOP_CREATORS")
	setLeaderboardSubButtonState(lbSub_TOP_CHARS, v25 == "ALL_ITEMS")
end

function clearLeaderboardRows()
	for _, guiObject in ipairs(lbScroll:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		if not (guiObject.Name:find("Lb_") or guiObject.Name:find("Meta_") or guiObject.Name:find("LbSection_") or guiObject.Name:find("LbItem_") or guiObject.Name:find("LbSectionHeader_") or guiObject.Name == "Lb_Empty") then
			continue
		end

		guiObject:Destroy()
	end
end

function buildCreatorLeaderboardSignature(options)
	local v84 = { "creators", (tostring(#(options or {}))) }

	for i, v85 in ipairs(options or {}) do
		v84[#v84 + 1] = tostring(i)
		v84[#v84 + 1] = tostring(v85.userId or "")
		v84[#v84 + 1] = tostring(v85.name or "")
		v84[#v84 + 1] = tostring(v85.stat or 0)
		v84[#v84 + 1] = tostring(v85.uploads or 0)
		v84[#v84 + 1] = tostring(v85.statLabel or "")
		v84[#v84 + 1] = tostring(v85.subInfo or "")
	end

	return table.concat(v84, "|")
end

function buildItemsLeaderboardSignature(list, p)
	local v84 = { "items" }

	for _, v85 in ipairs(list) do
		local v86 = p[v85.type] or {}
		v84[#v84 + 1] = v85.type
		v84[#v84 + 1] = tostring(#v86)

		for i, v87 in ipairs(v86) do
			local v88 = typeof(v87.entry) ~= "table" and "" or tostring(v87.entry.id or "")
			v84[#v84 + 1] = tostring(i)
			v84[#v84 + 1] = v88
			v84[#v84 + 1] = tostring(v87.stat or 0)
		end
	end

	return table.concat(v84, "|")
end

function hasVisibleLeaderboardRows()
	for _, guiObject in ipairs(lbScroll:GetChildren()) do
		if guiObject:IsA("GuiObject") and (guiObject.Name:find("Lb_") or guiObject.Name:find("LbItem_") or guiObject.Name:find("LbSection_")) then
			return true
		end
	end

	return false
end

LEADERBOARD_GRADIENT_RANK2 = rgb(127, 211, 236)
LEADERBOARD_GRADIENT_RANK3 = rgb(236, 145, 65)

function applyLeaderboardRowGradient(instance, p)
	if p <= 1 then
		return
	end

	local uIGradient = instance:FindFirstChildWhichIsA("UIGradient", true)

	if not uIGradient then
		return
	end

	local LEADERBOARD_GRADIENT_RANK22

	if p == 2 then
		LEADERBOARD_GRADIENT_RANK22 = LEADERBOARD_GRADIENT_RANK2
	elseif p == 3 then
		LEADERBOARD_GRADIENT_RANK22 = LEADERBOARD_GRADIENT_RANK3
	else
		local random = Random.new(p)
		LEADERBOARD_GRADIENT_RANK22 = Color3.fromHSV(
			random:NextNumber(0, 1),
			random:NextNumber(0.32, 0.5),
			random:NextNumber(0.82, 0.92)
		)
	end

	local keypoints = uIGradient.Color.Keypoints
	local value = keypoints[1] and keypoints[1].Value or rgb(255, 255, 255)
	uIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, value),
		ColorSequenceKeypoint.new(1, LEADERBOARD_GRADIENT_RANK22)
	})
end

function refreshLeaderboard(p)
	v41.leaderboard += 1
	local leaderboard = v41.leaderboard
	local v85 = p == true

	local function drawCreatorRows(options, layoutOrder, leaderboard2)
		for i, v86 in ipairs(options or {}) do
			if leaderboard2 ~= v41.leaderboard then
				return layoutOrder
			end

			local leaderboardProfileRow = cloneLeaderboardProfileRow()

			if not leaderboardProfileRow then
				return layoutOrder
			end

			leaderboardProfileRow.Name = "Lb_" .. tostring(layoutOrder)
			leaderboardProfileRow.LayoutOrder = layoutOrder
			layoutOrder += 1
			applyLeaderboardRowGradient(leaderboardProfileRow, tonumber(v86.rank) or i)
			local leaderboardProfileField = findLeaderboardProfileField(leaderboardProfileRow, "Rank")

			if leaderboardProfileField and (leaderboardProfileField:IsA("TextLabel") or leaderboardProfileField:IsA("TextButton")) then
				leaderboardProfileField.Text = "#" .. tostring(v86.rank or i)
				leaderboardProfileField.TextColor3 = v4[i] or rgb(180, 180, 180)
			end

			local leaderboardProfileField2 = findLeaderboardProfileField(leaderboardProfileRow, "StatValue")

			if leaderboardProfileField2 and (leaderboardProfileField2:IsA("TextLabel") or leaderboardProfileField2:IsA("TextButton")) then
				leaderboardProfileField2.Text = formatNum(tonumber(v86.stat) or 0)
			end

			local leaderboardProfileField3 = findLeaderboardProfileField(leaderboardProfileRow, "StatLabel")

			if leaderboardProfileField3 and (leaderboardProfileField3:IsA("TextLabel") or leaderboardProfileField3:IsA("TextButton")) then
				leaderboardProfileField3.Text = formatLeaderboardStatLabel(v86.statLabel or "most_liked")
			end

			local name = tostring(v86.name or "Unknown")
			local leaderboardProfileField4 = findLeaderboardProfileField(leaderboardProfileRow, "EntryName")

			if leaderboardProfileField4 and (leaderboardProfileField4:IsA("TextLabel") or leaderboardProfileField4:IsA("TextButton")) then
				bindLeaderboardProfileName(leaderboardProfileField4, name, v86.userId, leaderboard2)
			end

			local verifiedBadge = leaderboardProfileRow:FindFirstChild("VerifiedBadge", true)

			if verifiedBadge and verifiedBadge:IsA("GuiObject") then
				verifiedBadge.Visible = false
			end

			local verifiedLabel = leaderboardProfileRow:FindFirstChild("VerifiedLabel", true)

			if verifiedLabel and verifiedLabel:IsA("GuiObject") then
				verifiedLabel.Visible = false
			end

			local text2 = trimString(v86.subInfo) or tostring(v86.uploads or 0) .. " uploads"
			local leaderboardProfileField5 = findLeaderboardProfileField(leaderboardProfileRow, "SubInfo")

			if leaderboardProfileField5 and (leaderboardProfileField5:IsA("TextLabel") or leaderboardProfileField5:IsA("TextButton")) then
				leaderboardProfileField5.Text = text2
				leaderboardProfileField5.Visible = true
			end

			applyLeaderboardProfileAvatar(leaderboardProfileRow, v86.userId)
			local v88 = v86
			leaderboardProfileRow.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					openCreatorProfile(tonumber(v88.userId), name)
				end
			end)
			hoverStroke(leaderboardProfileRow, rgb(255, 200, 60), 0.8, rgb(255, 255, 255), 0.94)
			leaderboardProfileRow.Parent = lbScroll

			if i % 10 == 0 then
				task.wait(0.02)
			end
		end

		return layoutOrder
	end

	local function drawItemsSectionButtons(list, layoutOrder)
		for _, v86 in ipairs(list) do
			local type2 = v86.type
			local v87 = v43[type2] or {}
			local v88 = v49.activeItemsSectionType == type2
			local clone = extratemplate:Clone()
			clone.Name = "LbSection_" .. tostring(type2)
			clone.Visible = true
			clone.LayoutOrder = layoutOrder
			clone.AutoButtonColor = false
			clone.BackgroundTransparency = v88 and 0.5 or 0.75
			clone.TextColor3 = v88 and rgb(255, 255, 255) or rgb(185, 185, 185)
			clone.Text = tostring(v86.label) .. " (" .. tostring(#v87) .. ")"
			clone.Activated:Connect(function()
				if not (claimActionDebounce("lb_section", type2, 0.14) and v49.activeItemsSectionType ~= type2) then
					return
				end

				v49.activeItemsSectionType = type2
				refreshLeaderboard(true)
			end)
			clone.Parent = lbScroll
			layoutOrder += 1
		end

		return layoutOrder
	end

	local function drawItemRows(options, layoutOrder, activeItemsSectionType, leaderboard2)
		local v86 = typeToCategory[tostring(activeItemsSectionType or "")] or "Move"
		local v87 = categoryColors[v86] or rgb(255, 200, 90)
		local v88 = math.min(#(options or {}), v49.itemsRenderLimit)

		for i = 1, v88 do
			if leaderboard2 ~= v41.leaderboard then
				return layoutOrder
			end

			local option = options[i]

			if not (lbItemTemplate and lbItemTemplate:IsA("GuiObject")) then
				return layoutOrder
			end

			local clone = lbItemTemplate:Clone()
			clone.Visible = true
			clone.Active = true
			clone.Name = "LbItem_" .. tostring(activeItemsSectionType) .. "_" .. tostring(layoutOrder)
			clone.LayoutOrder = layoutOrder
			layoutOrder += 1
			applyLeaderboardRowGradient(clone, tonumber(option.rank) or i)
			local rank = clone:FindFirstChild("Rank", true)

			if rank and (rank:IsA("TextLabel") or rank:IsA("TextButton")) then
				rank.Text = "#" .. tostring(option.rank or i)
				rank.TextColor3 = v4[i] or rgb(180, 180, 180)
			end

			local statValue = clone:FindFirstChild("StatValue", true)

			if statValue and (statValue:IsA("TextLabel") or statValue:IsA("TextButton")) then
				statValue.Text = formatNum(tonumber(option.stat) or 0)
			end

			local statLabel = clone:FindFirstChild("StatLabel", true)

			if statLabel and (statLabel:IsA("TextLabel") or statLabel:IsA("TextButton")) then
				statLabel.Text = formatLeaderboardStatLabel(option.statLabel or "most_liked")
			end

			local v89 = option.entry and toRuntimeLegacyEntry(option.entry) or nil

			if v89 then
				local entryName = clone:FindFirstChild("EntryName", true)

				if entryName and (entryName:IsA("TextLabel") or entryName:IsA("TextButton")) then
					entryName.Text = v89.name
				end

				local subInfo = clone:FindFirstChild("SubInfo", true)

				if subInfo and (subInfo:IsA("TextLabel") or subInfo:IsA("TextButton")) then
					subInfo.RichText = true
					subInfo.Text = formatCreatorLine(v89.creator, "")
				end

				local avatar = clone:FindFirstChild("Avatar")
				local avatar2 = avatar and avatar:FindFirstChild("Avatar") or nil

				if avatar2 and (avatar2:IsA("ImageLabel") or avatar2:IsA("ImageButton")) then
					local v90 = v89.thumbnailIsDefault == true and "" or normalizeCatalogueImage(v89.thumbnail or v89.thumbnailRaw or v89.imageId)
					local image = RequestHelper.CATEGORY_DEFAULT_IMAGES[v86] or RequestHelper.CATEGORY_DEFAULT_IMAGES.Move or ""

					if v90 ~= "" and v90 then
						image = v90
					end

					avatar2.Image = image
					avatar2.Visible = image ~= ""
				end

				local v90 = v89
				clone.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						openDetail(v90)
					end
				end)
			end

			hoverStroke(clone, v87, 0.8, rgb(255, 255, 255), 0.94)
			clone.Parent = lbScroll

			if i % 10 == 0 then
				task.wait(0.02)
			end
		end

		if not (v88 < #options) then
			return layoutOrder
		end

		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Lb_Trimmed_" .. tostring(activeItemsSectionType)
		textLabel2.LayoutOrder = layoutOrder
		textLabel2.Size = UDim2.new(1, -6, 0, 20)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.TextSize = 11
		textLabel2.TextColor3 = rgb(130, 130, 130)
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.Text = "Showing top " .. tostring(v88) .. " entries."
		textLabel2.Parent = lbScroll
		layoutOrder += 1
		return layoutOrder
	end

	local v86 = {
		{
			type = "characters",
			label = "CHARACTERS"
		},
		{
			type = "maps",
			label = "MAPS"
		},
		{
			type = "moves",
			label = "MOVES"
		}
	}

	if v25 == "ALL_ITEMS" then
		if not v85 then
			local now2 = os.clock()
			local v87 = req("LeaderboardQuery", {
				category = "characters",
				index = "most_liked",
				assetType = "all",
				groupByType = true,
				limitPerType = v49.itemsLimitPerType
			}, 4)

			if leaderboard ~= v41.leaderboard then
				return
			end

			local v88

			if v87.ok and v87.grouped == true and typeof(v87.sections) == "table" then
				v88 = true

				for _, v89 in ipairs(v86) do
					v43[v89.type] = v87.sections[v89.type] or {}
				end
			else
				v88 = false
			end

			if not v88 then
				for _, v89 in ipairs(v86) do
					local v90 = req("LeaderboardQuery", {
						category = "characters",
						index = "most_liked",
						assetType = v89.type,
						limit = v49.itemsLimitPerType
					}, 4)

					if leaderboard ~= v41.leaderboard then
						return
					end

					if v90.ok then
						v43[v89.type] = v90.rows or {}
					else
						v43[v89.type] = v43[v89.type] or {}
					end
				end
			end

			v48.items = now2

			if v7 == "LEADERBOARD" then
				setBrowseLoading(false)
			end
		end

		if not (v49.activeItemsSectionType and v43[v49.activeItemsSectionType]) then
			for _, v87 in ipairs(v86) do
				if not (#(v43[v87.type] or {}) > 0) then
					continue
				end

				v49.activeItemsSectionType = v87.type
				break
			end

			if not v49.activeItemsSectionType then
				v49.activeItemsSectionType = v86[1].type
			end
		end

		local itemsLeaderboardSignature = buildItemsLeaderboardSignature(v86, v43)

		if v44.ALL_ITEMS == itemsLeaderboardSignature and v45 == "ALL_ITEMS" and v49.lastRenderedItemsSectionType == v49.activeItemsSectionType and hasVisibleLeaderboardRows() then
			return
		end

		v44.ALL_ITEMS = itemsLeaderboardSignature
		v45 = "ALL_ITEMS"
		v49.lastRenderedItemsSectionType = v49.activeItemsSectionType
		clearLeaderboardRows()
		local v87 = drawItemsSectionButtons(v86, 1)
		local v88 = v43[v49.activeItemsSectionType] or {}
		local layoutOrder = drawItemRows(v88, v87, v49.activeItemsSectionType, leaderboard)

		if #v88 == 0 then
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Lb_Empty_ActiveSection"
			textLabel2.LayoutOrder = layoutOrder
			textLabel2.Size = UDim2.new(1, -6, 0, 20)
			textLabel2.BackgroundTransparency = 1
			textLabel2.Font = Enum.Font.Gotham
			textLabel2.TextSize = 11
			textLabel2.TextColor3 = rgb(130, 130, 130)
			textLabel2.TextXAlignment = Enum.TextXAlignment.Left
			textLabel2.Text = "No entries yet."
			textLabel2.Parent = lbScroll
		end
	else
		if not v85 then
			local v87 = req("LeaderboardQuery", {
				category = "creators",
				index = "most_liked",
				assetType = "all",
				limit = v49.creatorsLimit
			}, 4)

			if leaderboard ~= v41.leaderboard then
				return
			end

			if not v87.ok then
				showToast("Leaderboard failed")
				return
			end

			rows = v87.rows or {}
			v48.creators = os.clock()

			if v7 == "LEADERBOARD" then
				setBrowseLoading(false)
			end
		end

		local v87 = rows or {}
		local creatorLeaderboardSignature = buildCreatorLeaderboardSignature(v87)

		if not v85 and v44.TOP_CREATORS == creatorLeaderboardSignature and v45 == "TOP_CREATORS" and hasVisibleLeaderboardRows() then
			return
		end

		v44.TOP_CREATORS = creatorLeaderboardSignature
		v45 = "TOP_CREATORS"
		clearLeaderboardRows()
		local layoutOrder = drawCreatorRows(v87, 1, leaderboard)

		if #v87 == 0 then
			local textLabel2 = Instance.new("TextLabel")
			textLabel2.Name = "Lb_Empty_Creators"
			textLabel2.LayoutOrder = layoutOrder
			textLabel2.Size = UDim2.new(1, -6, 0, 24)
			textLabel2.BackgroundTransparency = 1
			textLabel2.Font = Enum.Font.Gotham
			textLabel2.TextSize = 12
			textLabel2.TextColor3 = rgb(130, 130, 130)
			textLabel2.TextXAlignment = Enum.TextXAlignment.Left
			textLabel2.Text = "No creators found."
			textLabel2.Parent = lbScroll
		end
	end
end

function refreshVerified(p)
	v41.verified += 1
	local verified = v41.verified
	local verifiedRows = listCacheState.verifiedRows

	if p == true or not hasFreshListCache("verified") or #verifiedRows == 0 then
		local v85 = req("VerifiedQuery", {
			limit = v49.verifiedLimit,
			index = "most_liked",
			assetType = "all"
		}, 4)

		if verified ~= v41.verified then
			return
		end

		if v85.ok then
			verifiedRows = v85.creators or {}
			listCacheState.verifiedRows = verifiedRows
			listCacheState.timestamps.verified = os.clock()
			listCacheState.signatures.verified = buildCreatorCollectionSignature(verifiedRows)
		elseif #verifiedRows == 0 then
			showToast("Verified load failed")
			return
		end
	end

	if p ~= true and listCacheState.lastRendered.verified == listCacheState.signatures.verified and hasVisibleNamedRows(
		verifiedScroll,
		{ "VCard_" }
	) then
		return
	end

	listCacheState.lastRendered.verified = listCacheState.signatures.verified

	for _, guiObject in ipairs(verifiedScroll:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Name:find("VCard_") then
			guiObject:Destroy()
		end
	end

	for i, v85 in ipairs(verifiedRows or {}) do
		if verified ~= v41.verified then
			break
		end

		local clone = verifiedTemplate:Clone()
		clone.Name = "VCard_" .. tostring(v85.userId or i)
		clone.Visible = true
		clone.LayoutOrder = i
		clone.Active = true
		local entryName = clone:FindFirstChild("EntryName", true)

		if entryName then
			entryName.Text = tostring(v85.name or "Unknown")
		end

		local items = clone:FindFirstChild("items", true)

		if items then
			items.Text = formatNum(tonumber(v85.uploads) or 0)
		end

		local likes = clone:FindFirstChild("likes", true)

		if likes then
			likes.Text = formatNum(tonumber(v85.totalLikes) or tonumber(v85.stat) or 0)
		end

		applyVerifiedAvatar(clone, v85.userId)
		hoverStroke(clone, rgb(100, 180, 255), 0.6, rgb(100, 180, 255), 0.85)
		local name = tostring(v85.name or "Unknown")
		local v86 = tonumber(v85.userId)
		clone.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				openCreatorProfile(v86, name)
			end
		end)
		clone.Parent = verifiedScroll

		if i % 10 == 0 then
			task.wait(0.02)
		end
	end
end

function setAddedTitleCount(p)
	if not addedTitle then
		return
	end

	if text == nil then
		text = tostring(addedTitle.Text or "ITEMS (0)")
	end

	local v84 = tostring(text or "")
	local v85 = "(" .. tostring((math.max(0, (math.floor(tonumber(p) or 0))))) .. ")"

	if string.find(v84, "%b()") then
		addedTitle.Text = string.gsub(v84, "%b()", v85, 1)
	else
		addedTitle.Text = v84 .. " " .. v85
	end
end

function buildAddedViewSignature(p)
	local v84 = { buildEntryCollectionSignature(p), "search=" .. tostring(lowerTrim(v20)) }

	for _, v85 in ipairs(v70) do
		v84[#v84 + 1] = tostring(v85) .. ":" .. tostring(v21[v85] ~= false)
	end

	return table.concat(v84, "|")
end

function matchesAddedSearch(data, p)
	local v84 = lowerTrim(p)

	if v84 == "" then
		return true
	end

	if typeof(data) ~= "table" then
		return false
	end

	local v85 = {
		data.name,
		data.creator,
		data.category,
		data.type,
		data.importCode,
		data.desc
	}

	for _, v86 in ipairs(data.tags or {}) do
		v85[#v85 + 1] = v86
	end

	local v86 = lowerTrim(table.concat(v85, " "))
	return string.find(v86, v84, 1, true) ~= nil
end

catGive = {
	entry = nil,
	isMove = false,
	selected = {}
}

function catGiveCanGiveToOthers()
	if not localPlayer then
		return false
	end

	if game.PrivateServerOwnerId ~= 0 then
		return localPlayer.UserId == game.PrivateServerOwnerId
	end

	local vIPServer = workspace:GetAttribute("VIPServer")

	if vIPServer and tonumber(vIPServer) == localPlayer.UserId then
		return true
	end

	local customServerOwnerId = workspace:GetAttribute("CustomServerOwnerId")

	if customServerOwnerId and tonumber(customServerOwnerId) == localPlayer.UserId then
		return true
	end

	return false
end

function catGiveRefreshRows()
	local giveMenuOverlay = mainPanel:FindFirstChild("GiveMenuOverlay")

	if not (giveMenuOverlay and giveMenuOverlay.Visible) then
		return
	end

	local giveMenuPopup = giveMenuOverlay:FindFirstChild("GiveMenuPopup")
	local scrollingFrame = giveMenuPopup and giveMenuPopup:FindFirstChildOfClass("ScrollingFrame")
	local realentry = script:FindFirstChild("realentry")

	if not (scrollingFrame and realentry) then
		return
	end

	local v84 = {}
	local v85 = {}

	for _, v86 in ipairs(Players:GetPlayers()) do
		if not (v86 ~= localPlayer or catGive.isMove) then
			continue
		end

		table.insert(v84, v86)
		v85[v86.UserId] = true
	end

	table.sort(v84, function(a, b)
		return a == localPlayer or b ~= localPlayer and string.lower(a.Name) < string.lower(b.Name)
	end)

	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if string.sub(child.Name, 1, 6) ~= "Entry_" then
			continue
		end

		local targetUserId = tonumber(child:GetAttribute("TargetUserId"))

		if targetUserId and v85[targetUserId] then
			continue
		end

		if targetUserId then
			catGive.selected[targetUserId] = nil
		end

		child:Destroy()
	end

	for k in pairs(catGive.selected) do
		if not v85[k] then
			catGive.selected[k] = nil
		end
	end

	for _, v86 in ipairs(v84) do
		if scrollingFrame:FindFirstChild("Entry_" .. tostring(v86.UserId)) then
			continue
		end

		local clone = realentry:Clone()
		clone.Name = "Entry_" .. tostring(v86.UserId)
		clone:SetAttribute("TargetUserId", v86.UserId)
		clone.Visible = true
		clone.BackgroundTransparency = 0.9
		local avatar = clone:FindFirstChild("Avatar")

		if avatar and avatar:IsA("ImageLabel") then
			avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(v86.UserId) .. "&w=420&h=420"
			avatar.ImageColor3 = Color3.new(0.2, 0.2, 0.2)
		end

		local textLabel2 = clone:FindFirstChild("TextLabel")

		if textLabel2 and textLabel2:IsA("TextLabel") then
			textLabel2.Text = v86 == localPlayer and v86.DisplayName .. " (You)" or v86.DisplayName
			local textLabel3 = textLabel2:FindFirstChild("TextLabel")

			if textLabel3 and textLabel3:IsA("TextLabel") then
				textLabel3.Text = string.format("(@%s)", v86.Name)
			end
		end

		if clone:IsA("GuiButton") then
			local v87 = v86
			local v88 = clone
			clone.MouseButton1Click:Connect(function()
				local userId = v87.UserId

				if catGive.selected[userId] then
					catGive.selected[userId] = nil
					v88.BackgroundTransparency = 0.9
				else
					catGive.selected[userId] = true
					v88.BackgroundTransparency = 0.4
				end
			end)
		end

		clone.Parent = scrollingFrame
	end
end

function catGiveOpen(entry)
	if not (catGiveCanGiveToOthers() and entry) then
		return
	end

	catGive.entry = entry
	catGive.isMove = entry.category == "Move"
	catGive.selected = {}
	local giveMenuOverlay = mainPanel:FindFirstChild("GiveMenuOverlay")

	if not giveMenuOverlay then
		return
	end

	local title = giveMenuOverlay:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = "GIVE: " .. tostring(entry.name or "")
	end

	giveMenuOverlay.Visible = true
	catGiveRefreshRows()
	warn2("give menu opened " .. tostring(entry.name) .. " isMove=" .. tostring(catGive.isMove))
end

function catGiveDo(p)
	local entry = catGive.entry

	if not (entry and catGiveCanGiveToOthers()) then
		return
	end

	local commRemote = getCommRemote(4)

	if not commRemote then
		return
	end

	local targetUserIds = {}

	if not p then
		for k in pairs(catGive.selected) do
			targetUserIds[#targetUserIds + 1] = k
		end

		if #targetUserIds == 0 then
			return
		end
	end

	if catGive.isMove then
		if p then
			commRemote:FireServer({
				Goal = "Custom Character",
				Action = "GiveSkillToAllPS",
				SkillName = entry.name,
				CatalogueEntryId = entry.id
			})
		else
			local targetUserIds2 = {}
			local flag5 = false

			for _, v86 in ipairs(targetUserIds) do
				if v86 == localPlayer.UserId then
					flag5 = true
				else
					targetUserIds2[#targetUserIds2 + 1] = v86
				end
			end

			if flag5 then
				commRemote:FireServer({
					Goal = "Custom Character",
					Action = "GiveSkillToSelf",
					SkillName = entry.name,
					CatalogueEntryId = entry.id
				})
			end

			if #targetUserIds2 > 0 then
				commRemote:FireServer({
					Goal = "Custom Character",
					Action = "GiveSkillToPlayer",
					SkillName = entry.name,
					CatalogueEntryId = entry.id,
					TargetUserIds = targetUserIds2
				})
			end
		end
	elseif p then
		commRemote:FireServer({
			Goal = "Custom Character",
			Action = "GiveCatalogueCharToAllPS",
			CatalogueEntryId = entry.id,
			CatalogueSourceUpdatedAt = tonumber(entry.updatedAt)
		})
	else
		commRemote:FireServer({
			Goal = "Custom Character",
			Action = "GiveCatalogueCharToPlayer",
			CatalogueEntryId = entry.id,
			CatalogueSourceUpdatedAt = tonumber(entry.updatedAt),
			TargetUserIds = targetUserIds
		})
	end

	warn2("give fired all=" .. tostring(p) .. " entry=" .. tostring(entry.id))
	local giveMenuOverlay = mainPanel:FindFirstChild("GiveMenuOverlay")

	if giveMenuOverlay then
		giveMenuOverlay.Visible = false
	end
end

function catGiveInit()
	if catGive.__inited then
		return
	end

	local giveMenuOverlay = mainPanel:FindFirstChild("GiveMenuOverlay")

	if not giveMenuOverlay then
		return
	end

	catGive.__inited = true
	local giveMenuPopup = giveMenuOverlay:FindFirstChild("GiveMenuPopup")
	local give = giveMenuPopup and giveMenuPopup:FindFirstChild("Give")
	local giveAll = giveMenuPopup and giveMenuPopup:FindFirstChild("GiveAll")
	local close2 = giveMenuPopup and giveMenuPopup:FindFirstChild("Close")
	local closeBg = giveMenuOverlay:FindFirstChild("CloseBg")

	if give then
		give.MouseButton1Click:Connect(function()
			catGiveDo(false)
		end)
	end

	if giveAll then
		giveAll.MouseButton1Click:Connect(function()
			catGiveDo(true)
		end)
	end

	if close2 then
		close2.MouseButton1Click:Connect(function()
			giveMenuOverlay.Visible = false
		end)
	end

	if closeBg then
		closeBg.MouseButton1Click:Connect(function()
			giveMenuOverlay.Visible = false
		end)
	end

	Players.PlayerAdded:Connect(function()
		catGiveRefreshRows()
	end)
	Players.PlayerRemoving:Connect(function()
		task.defer(catGiveRefreshRows)
	end)
end

catGiveInit()

function refreshAddedToPS(p)
	local v84

	if v7 == "ADDED_TO_PS" then
		v84 = not hasVisibleNamedRows(addedScroll, { "Added_", "AddCat_" })
	else
		v84 = false
	end

	if v84 then
		setBrowseLoading(true)
	end

	refreshAddedToPSImpl(p)

	if v7 == "ADDED_TO_PS" then
		setBrowseLoading(false)
	end
end

function refreshAddedToPSImpl(p)
	if addedImportApi then
		addedImportApi.ensureUi()
	end

	v41.added += 1
	local added = v41.added
	local v85 = syncAdded(p == true)

	if added ~= v41.added then
		return
	end

	syncServerChars(p == true)

	if added ~= v41.added then
		return
	end

	local v86 = overlayPendingPsItems(listCacheState.addedEntries)
	addedToPS = {}

	for _, v87 in ipairs(v86) do
		addedToPS[v87.id] = true
	end

	fn6()
	setAddedTitleCount(#v86)
	local serverCharEntries = listCacheState.serverCharEntries or {}

	if v85 or #v86 ~= 0 or #serverCharEntries ~= 0 then
		local v87 = {}

		for _, v88 in ipairs(v86) do
			if matchesAddedSearch(v88, v20) then
				v87[#v87 + 1] = v88
			end
		end

		for _, serverCharEntry in ipairs(serverCharEntries) do
			if matchesAddedSearch(serverCharEntry, v20) then
				v87[#v87 + 1] = serverCharEntry
			end
		end

		local v88 = {}

		for _, v89 in ipairs(v86) do
			v88[#v88 + 1] = v89
		end

		for _, serverCharEntry in ipairs(serverCharEntries) do
			v88[#v88 + 1] = serverCharEntry
		end

		local addedViewSignature = buildAddedViewSignature(v88)
		addedEmpty.Visible = #v87 == 0

		if p ~= true and listCacheState.lastRendered.added == addedViewSignature and hasVisibleNamedRows(
			addedScroll,
			{ "Added_", "AddCat_" }
		) then
			return
		end

		listCacheState.lastRendered.added = addedViewSignature

		for _, guiObject in ipairs(addedScroll:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and (guiObject.Name:find("Added_") or guiObject.Name:find("AddCat_"))) then
				continue
			end

			guiObject:Destroy()
		end

		local localCharacterSelectionMap = requestApi.buildLocalCharacterSelectionMap({
			player = localPlayer,
			listCacheState = listCacheState
		}, {
			buildImportCompactConfig = buildImportCompactConfig,
			trimString = trimString
		})
		local v89 = groupByCategory(v87)
		local layoutOrder = 1

		for _, v91 in ipairs(v70) do
			local v92 = v89[v91]

			if not (v92 and #v92 > 0) then
				continue
			end

			local clone = templateadd2:Clone()
			clone.Name = "AddCat_" .. v91
			clone.Visible = true
			clone.LayoutOrder = layoutOrder
			layoutOrder += 1
			clone.Active = true
			local catIcon = clone:FindFirstChild("CatIcon", true)

			if catIcon and (catIcon:IsA("TextLabel") or catIcon:IsA("TextButton")) then
				catIcon.Text = RequestHelper.CAT_ICONS[v91] or RequestHelper.CAT_ICONS.Character
				catIcon.TextColor3 = categoryColors[v91] or rgb(200, 60, 60)
			end

			local catLabel = clone:FindFirstChild("CatLabel", true)

			if not catLabel then
				for _, guiObject in ipairs(clone:GetDescendants()) do
					if not (guiObject ~= catIcon and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton"))) then
						continue
					end

					catLabel = guiObject
					break
				end
			end

			if catLabel and (catLabel:IsA("TextLabel") or catLabel:IsA("TextButton")) then
				catLabel.Text = string.upper(v71[v91] or v91) .. " (" .. #v92 .. ")"
			end

			local v93 = v91
			clone.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or not claimActionDebounce(
					"added_cat",
					v93,
					0.12
				) then
					return
				end

				v21[v93] = v21[v93] == false
				refreshAddedToPS(false)
			end)
			clone.Parent = addedScroll
			local v94 = v21[v91] ~= false
			table.sort(v92, function(a, b)
				return a.likes > b.likes
			end)

			if not v94 then
				continue
			end

			for _, v95 in ipairs(v92) do
				local clone2 = addedtemplate:Clone()
				clone2.Name = (v95.serverChar and "Added_sc_" or "Added_") .. v95.id
				clone2.Visible = true
				clone2.LayoutOrder = layoutOrder
				layoutOrder += 1
				local importFingerprint = requestApi.buildImportFingerprint(v95 and v95.config, {
					buildImportCompactConfig = buildImportCompactConfig
				})
				local topRow = clone2:WaitForChild("TopRow")
				topRow.Active = true
				local charName = topRow:WaitForChild("CharName")
				charName.Text = v95.name
				local creatorInfo = topRow:WaitForChild("CreatorInfo")
				creatorInfo.RichText = true
				creatorInfo.Text = formatCreatorLine(v95.creator, timeAgo(v95.uploadedTs or v95.uploadedAt))
				local tagRow = topRow:FindFirstChild("TagRow")

				if tagRow and tagRow:IsA("GuiObject") then
					for _, label in ipairs(tagRow:GetChildren()) do
						if label:IsA("TextLabel") then
							label:Destroy()
						end
					end

					tagRow.Visible = false
				end

				local favStar = topRow:FindFirstChild("FavStar")

				if favStar then
					favStar.Visible = false
				end

				local avatar = topRow:FindFirstChild("Avatar")

				if avatar then
					local imageLabel = avatar:FindFirstChild("ImageLabel") or avatar:FindFirstChildWhichIsA("ImageLabel")

					if imageLabel and (imageLabel:IsA("ImageLabel") or imageLabel:IsA("ImageButton")) then
						local v96 = RequestHelper.CATEGORY_DEFAULT_IMAGES[v91] or RequestHelper.CATEGORY_DEFAULT_IMAGES.Character or ""

						if v95.thumbnailIsDefault ~= true then
							local catalogueImage = normalizeCatalogueImage(v95.thumbnail or v95.thumbnailRaw or v95.imageId)

							if typeof(catalogueImage) == "string" and catalogueImage ~= "" then
								v96 = catalogueImage
							end
						end

						imageLabel.Image = tostring(v96 or "")
						imageLabel.Visible = tostring(v96 or "") ~= ""
					end

					local textLabel2 = avatar:FindFirstChildWhichIsA("TextLabel")

					if textLabel2 then
						textLabel2.Visible = false
					end
				end

				local botRow = clone2:WaitForChild("BotRow")
				local likeBtn = botRow:WaitForChild("LikeBtn")
				local dislikeBtn = botRow:WaitForChild("DislikeBtn")
				local favBtn = botRow:WaitForChild("FavBtn")
				local removeBtn = botRow:WaitForChild("RemoveBtn")
				local addBtn = botRow:WaitForChild("AddBtn")
				local deleteBtn = botRow:WaitForChild("DeleteBtn")
				local giveBtn = botRow:FindFirstChild("GiveBtn")
				-- equivalent calls inferred from this helper; original call sites unknown
				local v98 = v95

				local function syncAddedActionVisuals()
					applyVoteVisual(likeBtn, dislikeBtn, v18[v98.id])
					applyFavouriteVisual(favBtn, v17[v98.id] == true)
				end

				local count4 = 0
				-- equivalent calls inferred from this helper; original call sites unknown
				local button = deleteBtn

				local function resetDeleteButton()
					count4 += 1

					if button and button:IsA("TextButton") then
						button.Text = "DELETE"
					end
				end

				local v101 = v95
				local button2 = removeBtn
				local v103 = v95
				local guiObject = deleteBtn

				local function syncAddedSelectionButtons()
					local v106 = importFingerprint ~= "" and localCharacterSelectionMap[importFingerprint] or nil
					local v107 = v101.category == "Character"
					local v108 = v106 and v106.added == true

					if addBtn then
						addBtn.Visible = v107 and not v108
					end

					if button2 then
						if v101.category == "Map" then
							local v109 = catMapKeyFromEntry(v101)
							clone2:SetAttribute("CatMapKeyStr", v109)
							button2.Visible = true

							if button2:IsA("TextButton") then
								button2.Text = catMapButtonTextByKey(v109, "added")
							end

							button2.BackgroundColor3 = catMapButtonColor(v109)
						else
							button2.Visible = v107 and v108
						end
					end

					if guiObject and guiObject:IsA("GuiObject") then
						guiObject.Visible = v101.serverChar ~= true
						resetDeleteButton() -- equivalent call inferred; original call site unknown
					end

					if giveBtn then
						giveBtn.Visible = catGiveCanGiveToOthers() and (v101.category == "Character" or v101.category == "Move")
					end
				end

				syncAddedActionVisuals() -- equivalent call inferred; original call site unknown
				syncAddedSelectionButtons()
				local uIStroke = clone2:FindFirstChildWhichIsA("UIStroke")

				if uIStroke then
					uIStroke.Color = categoryColors[v91] or rgb(255, 255, 255)
					uIStroke.Transparency = 0.92
				end

				local v106 = v95
				topRow.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						openDetail(v106)
					end
				end)
				local v107 = v95
				local v108 = likeBtn
				local v109 = dislikeBtn
				local v110 = favBtn
				likeBtn.MouseButton1Click:Connect(function()
					if handleVote(v107.id, "up") then
						syncAddedActionVisuals() -- equivalent call inferred; original call site unknown
					end
				end)
				local v111 = v95
				local v112 = likeBtn
				local v113 = dislikeBtn
				local v114 = favBtn
				dislikeBtn.MouseButton1Click:Connect(function()
					if handleVote(v111.id, "down") then
						syncAddedActionVisuals() -- equivalent call inferred; original call site unknown
					end
				end)
				local v115 = v95
				local v116 = likeBtn
				local v117 = dislikeBtn
				local v118 = favBtn
				favBtn.MouseButton1Click:Connect(function()
					if toggleFavourite(v115.id, {
						skipRefresh = true
					}) then
						syncAddedActionVisuals() -- equivalent call inferred; original call site unknown
					end
				end)

				if giveBtn then
					local v119 = v95
					giveBtn.MouseButton1Click:Connect(function()
						if not catGiveCanGiveToOthers() or v119.category ~= "Character" and v119.category ~= "Move" then
							return
						end

						catGiveOpen(v119)
					end)
				end

				local v119 = v95
				local v120 = importFingerprint
				local syncAddedSelectionButtons2 = syncAddedSelectionButtons
				addBtn.MouseButton1Click:Connect(function()
					if v119.serverChar == true then
						if localPlayer:GetAttribute("CustomCharacterImporting") == true then
							showToast("PLEASE WAIT FOR THE OTHER CHARACTER TO BE ADDED")
							return
						end

						if not claimActionDebounce("addedCharToggle", v119.id, 2) then
							showToast("CLICKING TOO FAST")
							return
						end

						local importCharacterIntoCreator, v121 = requestApi.importCharacterIntoCreator({
							id = v119.id,
							name = v119.name,
							updatedAt = v119.updatedAt
						}, {
							autoAddToSelection = true,
							suppressNotification = true
						}, {
							getCommRemote = getCommRemote,
							trimString = trimString
						})
						warn2("server char use requested " .. tostring(v119.id) .. " ok " .. tostring(importCharacterIntoCreator))

						if not importCharacterIntoCreator then
							showToast("Add failed: " .. tostring(v121 or "import-failed"))
							return
						end

						local v123 = v120 ~= "" and localCharacterSelectionMap[v120] or {
							found = false,
							added = false,
							importedIds = {}
						}
						v123.found = true
						v123.added = true

						if v120 ~= "" then
							localCharacterSelectionMap[v120] = v123
						end

						syncAddedSelectionButtons2()
						showToast("\"" .. tostring(v119.name or "Character") .. "\" added to character selection")
					else
						if v119.category == "Map" then
							requestCatalogueMapLoad(v119, "GlobalCatalogueAddedTab")
							return
						end

						if localPlayer:GetAttribute("CustomCharacterImporting") == true then
							showToast("PLEASE WAIT FOR THE OTHER CHARACTER TO BE ADDED")
							return
						end

						if not claimActionDebounce("addedCharToggle", v119.id, 2) then
							showToast("CLICKING TOO FAST")
							return
						end

						local v121 = v120 ~= "" and localCharacterSelectionMap[v120] or {
							found = false,
							added = false,
							importedIds = {}
						}

						if v121.added == true then
							return
						end

						local count5 = 0

						if typeof(v119.moveBuffersB64) == "table" then
							for k in pairs(v119.moveBuffersB64) do
								count5 += 1
							end
						end

						fn(string.format(
							"[CHARFIX][catBtn] charRef.id=%s name=%s creatorUserId=%s configType=%s bundleEntries=%d",
							tostring(v119.id),
							tostring(v119.name),
							tostring(v119.creatorUserId),
							typeof(v119.config),
							count5
						))
						local ensureCharacterInSelection = requestApi.ensureCharacterInSelection
						local v122 = {
							type = "characters",
							sourceType = "custom_character",
							name = v119.name,
							config = v119.config,
							creatorUserId = tonumber(v119.creatorUserId) or 0,
							moveBuffersB64 = 0,
							updatedAt = 0
						}
						local moveBuffersB

						if typeof(v119.moveBuffersB64) == "table" then
							moveBuffersB = v119.moveBuffersB64 or nil
						end

						v122.moveBuffersB64 = moveBuffersB
						v122.updatedAt = tonumber(v119.updatedAt) or 0
						local characterInSelection, v124, v125 = ensureCharacterInSelection(v122, {
							player = localPlayer,
							listCacheState = listCacheState
						}, {
							fireCustomCharacterAction = fireCustomCharacterAction,
							getCommRemote = getCommRemote,
							buildImportCompactConfig = buildImportCompactConfig,
							trimString = trimString
						})

						if not characterInSelection then
							showToast("Add failed: " .. tostring(v124 or "import-failed"))
							return
						end

						v121.found = true
						v121.added = true

						if v125 and v125.id ~= "" and requestApi.isLocalImportedCharacter(v125) then
							v121.importedIds = { (tostring(v125.id)) }
						end

						if v120 ~= "" then
							localCharacterSelectionMap[v120] = v121
						end

						syncAddedSelectionButtons2()

						if v124 == "import-pending" then
							showToast("\"" .. tostring(v119.name or "Character") .. "\" import queued")
						else
							showToast("\"" .. tostring(v119.name or "Character") .. "\" added to character selection")
						end
					end
				end)
				local v121 = v95
				local v122 = importFingerprint
				local syncAddedSelectionButtons3 = syncAddedSelectionButtons
				removeBtn.MouseButton1Click:Connect(function()
					if v121.category == "Map" then
						if not claimActionDebounce("addedMapToggle", v121.id, 1) then
							showToast("CLICKING TOO FAST")
							return
						end

						local v123 = catMapKeyFromEntry(v121)

						if v123 and v77.state[v123] then
							return
						end

						if isCatalogueMapAlreadyLoaded(parseMapRefFromEntry(v121)) then
							if requestCatalogueMapRemove(v121, "GlobalCatalogueAddedTabMapToggle") then
								setCatMapOpState(v123, "waiting")
								warn2("map remove requested " .. tostring(v123))
							end
						elseif requestCatalogueMapLoad(v121, "GlobalCatalogueAddedTab") then
							setCatMapOpState(v123, "waiting")
							warn2("map load requested " .. tostring(v123))
						end
					else
						if not claimActionDebounce("addedCharToggle", v121.id, 2) then
							showToast("CLICKING TOO FAST")
							return
						end

						local v123 = v122 ~= "" and localCharacterSelectionMap[v122] or {
							found = false,
							added = false,
							importedIds = {}
						}

						if v123.added ~= true then
							return
						end

						if requestApi.removeCharacterFromSelection({
							name = v121.name,
							config = v121.config
						}, {
							player = localPlayer,
							listCacheState = listCacheState
						}, {
							fireCustomCharacterAction = fireCustomCharacterAction,
							buildImportCompactConfig = buildImportCompactConfig,
							trimString = trimString
						}) then
							v123.added = false

							if v122 ~= "" then
								localCharacterSelectionMap[v122] = v123
							end

							syncAddedSelectionButtons3()
							showToast("\"" .. tostring(v121.name or "Character") .. "\" removed from character selection")
						else
							v123.added = false

							if v122 ~= "" then
								localCharacterSelectionMap[v122] = v123
							end

							syncAddedSelectionButtons3()
							showToast("Remove failed")
						end
					end
				end)
				local v124 = v95
				local v125 = clone2
				local v126 = importFingerprint
				deleteBtn.MouseButton1Click:Connect(function()
					if deleteBtn.Visible ~= true then
						return
					end

					if deleteBtn.Text == "SURE?" then
						count4 += 1

						if (v32.__removechar or 0) > os.clock() then
							showToast("Deleting too fast - on cooldown")
							return
						end

						v32.__removechar = os.clock() + 2

						if addInFlight[v124.id] then
							return
						end

						addInFlight[v124.id] = true
						local v127 = addedToPS[v124.id] == true
						local parent2 = v125.Parent
						setPendingPsMutation(v124.id, false)
						v125.Parent = nil
						updateTabCounts()

						if req("RemoveFromPS", {
							entryId = v124.id
						}, 3).ok then
							if v124.category == "Character" then
								requestApi.removeImportedCharacterFromSelection({
									name = v124.name,
									config = v124.config
								}, {
									player = localPlayer,
									listCacheState = listCacheState
								}, {
									fireCustomCharacterAction = fireCustomCharacterAction,
									buildImportCompactConfig = buildImportCompactConfig,
									trimString = trimString
								})
							elseif v124.category == "Map" then
								requestCatalogueMapRemove(v124, "GlobalCatalogueAddedTabRemove")
							end

							local v128 = v126 ~= "" and localCharacterSelectionMap[v126] or {
								found = false,
								added = false,
								importedIds = {}
							}
							v128.found = false
							v128.added = false
							v128.importedIds = {}

							if v126 ~= "" then
								localCharacterSelectionMap[v126] = v128
							end

							showToast("\"" .. tostring(v124.name or "Character") .. "\" removed")
							refreshAddedTabImmediatelyIfVisible()
							notifyCharCreatorCatalogueRefresh(true)
							addInFlight[v124.id] = nil
							schedulePsMutationRefresh()
						else
							deleteBtn.Text = "DELETE"
							clearPendingPsMutation(v124.id)

							if v127 then
								addedToPS[v124.id] = true
							else
								addedToPS[v124.id] = nil
							end

							v125.Parent = parent2
							updateTabCounts()
							showToast("Delete failed")
							addInFlight[v124.id] = nil
						end
					else
						count4 += 1
						local v127 = count4
						deleteBtn.Text = "SURE?"
						task.delay(2, function()
							if count4 ~= v127 then
								return
							end

							if deleteBtn and deleteBtn.Parent then
								deleteBtn.Text = "DELETE"
							end
						end)
					end
				end)
				clone2.Parent = addedScroll
			end
		end
	else
		addedEmpty.Visible = true

		if p == true or not hasVisibleNamedRows(addedScroll, { "Added_", "AddCat_" }) then
			for _, guiObject in ipairs(addedScroll:GetChildren()) do
				if not (guiObject:IsA("GuiObject") and (guiObject.Name:find("Added_") or guiObject.Name:find("AddCat_"))) then
					continue
				end

				guiObject:Destroy()
			end
		end
	end
end

if searchbox and searchbox:IsA("TextBox") then
	searchbox.ClearTextOnFocus = false
	v20 = trimString(searchbox.Text or "")
	searchbox:GetPropertyChangedSignal("Text"):Connect(function()
		local v84 = trimString(searchbox.Text or "")

		if v84 == v20 then
			return
		end

		v20 = v84
		listCacheState.lastRendered.added = nil

		if v7 == "ADDED_TO_PS" then
			refreshAddedToPS(false)
		end
	end)
end

function refreshUploadPreviewCard(p)
	RequestHelper.refreshUploadPreviewCard(p, {
		uploadPreviewCard = uploadPreviewCard,
		inferTypeFromSource = inferTypeFromSource,
		typeToCategory = typeToCategory,
		categoryDefaultImages = RequestHelper.CATEGORY_DEFAULT_IMAGES,
		categoryColors = categoryColors,
		categoryLabels = RequestHelper.CAT_LABELS,
		resolveUploadThumbnail = resolveUploadThumbnail,
		normalizeCatalogueImage = normalizeCatalogueImage,
		rgb = rgb,
		playerName = localPlayer.Name,
		escapeRichText = escapeRichText,
		findStatsOverlayNode = findStatsOverlayNode,
		setStatTextPreservePrefix = setStatTextPreservePrefix,
		emojiThumbsUp = emojiThumbsUp,
		emojiThumbsDown = emojiThumbsDown,
		emojiStar = emojiStar,
		applyFavouriteVisual = applyFavouriteVisual,
		printFn = fn2
	})
end

function bindUploadImageInputPreview()
	RequestHelper.bindUploadImageInputPreview({
		uploadListState = uploadListState,
		findUploadImageInput = findUploadImageInput,
		normalizeCatalogueImage = normalizeCatalogueImage,
		isUploadConfirmVisible = function()
			return uploadConfirm and uploadConfirm.Visible == true
		end,
		getSelectedUploadSource = function()
			return v26
		end,
		refreshUploadPreviewCard = refreshUploadPreviewCard,
		warnFn = fn,
		printFn = fn2
	})
end

function uploadTypeOrderIndex(p)
	for i, v84 in ipairs(RequestHelper.UPLOAD_TYPE_ORDER) do
		if v84 == p then
			return i
		end
	end

	return #RequestHelper.UPLOAD_TYPE_ORDER + 1
end

function rebuildUploadSourceCaches()
	local groupedByType = {}

	for _, v85 in ipairs(v59 or {}) do
		local v86 = tostring(not v85 and "moves" or v85.assetType or "moves")
		groupedByType[v86] = groupedByType[v86] or {}
		table.insert(groupedByType[v86], v85)
	end

	local typeList = {}

	for k in pairs(groupedByType) do
		table.sort(groupedByType[k], function(a, b)
			return string.lower((tostring(a.name or ""))) < string.lower((tostring(b.name or "")))
		end)
		table.insert(typeList, k)
	end

	table.sort(typeList, function(a, b)
		local v86 = uploadTypeOrderIndex(a)
		local v87 = uploadTypeOrderIndex(b)

		if v86 == v87 then
			return tostring(RequestHelper.TYPE_TO_UPLOAD_LABEL[a] or a) < tostring(RequestHelper.TYPE_TO_UPLOAD_LABEL[b] or b)
		end

		return v86 < v87
	end)
	uploadListState.groupedByType = groupedByType
	uploadListState.typeList = typeList

	if uploadListState.activeType and not groupedByType[uploadListState.activeType] then
		uploadListState.activeType = nil
	end
end

function openCharacterCreatorFromCatalogue()
	mainPanel.Visible = false

	if typeof(shared) == "table" and type(shared.creatorgc) == "function" and pcall(shared.creatorgc) then
		return true
	end

	if type(_G.OpenCharacterCreator) == "function" and pcall(_G.OpenCharacterCreator) then
		return true
	end

	if type(_G.OpenCharCreator) == "function" and pcall(_G.OpenCharCreator) then
		return true
	end

	if type(_G.ToggleCharCreator) == "function" and pcall(_G.ToggleCharCreator, true) then
		return true
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return false
	end

	for _, childName in ipairs({ "CharacterCreationGui", "CharacterCreatorGui", "CharCreatorGui" }) do
		local screenGui = playerGui:FindFirstChild(childName)

		if not (screenGui and screenGui:IsA("ScreenGui")) then
			continue
		end

		screenGui.Enabled = true
		return true
	end

	for _, label in ipairs(playerGui:GetDescendants()) do
		if not (label:IsA("TextLabel") and string.upper((tostring(label.Text or ""))) == "CHARACTER CREATOR") then
			continue
		end

		local screenGui = label:FindFirstAncestorWhichIsA("ScreenGui")

		if not screenGui then
			continue
		end

		screenGui.Enabled = true
		return true
	end

	return false
end

function bindCreateMoreUploadButton()
	if v62 and v62.Parent then
		return
	end

	for _, guiObject in ipairs(uploadSelect:GetDescendants()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = string.lower(guiObject.Name or "")
		local v84 = string.find(name, "create", 1, true) and string.find(name, "more", 1, true)
		local text2 = ""

		if guiObject:IsA("TextButton") then
			text2 = guiObject.Text or ""
		else
			local textLabel2 = guiObject:FindFirstChildWhichIsA("TextLabel")

			if textLabel2 and textLabel2.Text ~= "" then
				text2 = textLabel2.Text
			else
				for _, label in ipairs(guiObject:GetDescendants()) do
					if not (label:IsA("TextLabel") and label.Text ~= "") then
						continue
					end

					text2 = label.Text
					break
				end
			end
		end

		local v85 = string.lower(text2)
		local v86 = string.find(v85, "create more", 1, true) and string.find(v85, "character", 1, true)

		if not (v84 or v86) then
			continue
		end

		local v87

		if guiObject:IsA("GuiButton") then
			v87 = guiObject
		else
			v87 = guiObject:FindFirstChildWhichIsA("GuiButton")

			if not v87 and guiObject:IsA("GuiObject") then
				v87 = guiObject:FindFirstChild("CreateMoreOverlayBtn")

				if not v87 then
					v87 = Instance.new("TextButton")
					v87.Name = "CreateMoreOverlayBtn"
					v87.BackgroundTransparency = 1
					v87.BorderSizePixel = 0
					v87.Text = ""
					v87.Size = UDim2.fromScale(1, 1)
					v87.ZIndex = (guiObject.ZIndex or 1) + 2
					v87.Parent = guiObject
				end
			end
		end

		if not v87 then
			continue
		end

		v62 = v87

		if v87:GetAttribute("__CatalogueBound") == true then
			break
		end

		v87:SetAttribute("__CatalogueBound", true)
		v87.Activated:Connect(function()
			if not openCharacterCreatorFromCatalogue() then
				mainPanel.Visible = true
				showToast("Could not open character creator")
			end
		end)
		break
	end
end

function createUploadCategoryHeader(activeType, p, _)
	local button = uploadCharScroll:FindFirstChild("UpCat_" .. tostring(activeType))

	if not (button and button:IsA("TextButton")) then
		return
	end

	local v84 = uploadListState.activeType == activeType
	button.Visible = true
	button.Text = string.upper(RequestHelper.TYPE_TO_UPLOAD_LABEL[activeType] or "Item") .. " (" .. tostring(p) .. ")"
	button.BackgroundTransparency = v84 and 0.5 or 0.75
	button.AutoButtonColor = false
	button.TextColor3 = v84 and rgb(255, 255, 255) or rgb(185, 185, 185)

	if button:GetAttribute("__CatalogueBound") ~= true then
		button:SetAttribute("__CatalogueBound", true)
		button.Activated:Connect(function()
			if not claimActionDebounce("upload_section", activeType, 0.12) then
				return
			end

			if uploadListState.activeType == activeType then
				uploadListState.activeType = nil
			else
				uploadListState.activeType = activeType
			end

			task.spawn(function()
				fn3(true)
			end)
		end)
	end
end

fn3 = function(p)
	if p == true then
		if #uploadListState.typeList == 0 and #v59 > 0 then
			rebuildUploadSourceCaches()
		end
	else
		syncUploadSources()
	end

	bindCreateMoreUploadButton()
	confirmWarn.Visible = false

	if confirmPublishBtn then
		confirmPublishBtn.Visible = false
	end

	if cancelPublishBtn then
		cancelPublishBtn.Visible = false
	end

	for _, guiObject in ipairs(uploadCharScroll:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Name:find("UpCat_") then
			guiObject.Visible = false
		elseif guiObject:IsA("GuiObject") and guiObject.Name:find("UpEmpty_") then
			guiObject:Destroy()
		end
	end

	local dropdownHolder2 = uploadCharScroll:FindFirstChild("DropdownHolder")

	if dropdownHolder2 then
		for _, guiObject in ipairs(dropdownHolder2:GetChildren()) do
			if guiObject:IsA("GuiObject") and guiObject.Name:find("UpItem_") then
				guiObject:Destroy()
			end
		end
	end

	if #v59 == 0 then
		if dropdownHolder2 then
			dropdownHolder2.Visible = false
		end

		fn("nothing is ivsible?")
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "UpEmpty_Message"
		textLabel2.LayoutOrder = 1
		textLabel2.Size = UDim2.new(1, -8, 0, 28)
		textLabel2.BackgroundTransparency = 1
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.TextSize = 12
		textLabel2.TextColor3 = rgb(130, 130, 130)
		textLabel2.Text = "No uploadable sources found. Save a character/move or a build-mode map first."
		textLabel2.Parent = uploadCharScroll
	else
		if #uploadListState.typeList == 0 then
			rebuildUploadSourceCaches()
		end

		for _, v84 in ipairs(uploadListState.typeList) do
			local v85 = uploadListState.groupedByType[v84] or {}
			createUploadCategoryHeader(v84, #v85, 0)
		end

		local child = uploadCharScroll:FindFirstChild("UpCat_" .. tostring(uploadListState.activeType))

		for _, guiObject in ipairs(uploadCharScroll:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and guiObject.Name:find("UpCat_")) then
				continue
			end

			local imageLabel = guiObject:FindFirstChildWhichIsA("ImageLabel")

			if not imageLabel then
				continue
			end

			local size = imageLabel.Size
			imageLabel.Rotation = guiObject == child and -90 or -180
			imageLabel.Size = size
		end

		local dropdownholdertemplate = script:FindFirstChild("dropdownholdertemplate")

		if dropdownHolder2 and dropdownholdertemplate and (child or v61 ~= "") then
			dropdownHolder2.LayoutOrder = child and child.LayoutOrder + 1 or 9999
			dropdownHolder2.Visible = true
			local v84

			if v61 == "" then
				v84 = uploadListState.groupedByType[uploadListState.activeType] or {}
			else
				local v85 = string.lower(v61)
				v84 = {}

				for _, v86 in ipairs(uploadListState.typeList) do
					for _, v87 in ipairs(uploadListState.groupedByType[v86] or {}) do
						if not string.find(string.lower((tostring(v87.name or ""))), v85, 1, true) then
							continue
						end

						table.insert(v84, v87)
					end
				end
			end

			for _, v85 in ipairs(v84) do
				local clone = dropdownholdertemplate:Clone()
				clone.Name = "UpItem_" .. tostring(v85.sourceId or v85.name or "")
				clone.Visible = true
				clone.Active = true
				local name = clone:FindFirstChild("name")

				if name and (name:IsA("TextLabel") or name:IsA("TextButton")) then
					name.Text = tostring(v85.name or "Untitled")
				end

				local amt = clone:FindFirstChild("amt")

				if amt and (amt:IsA("TextLabel") or amt:IsA("TextButton")) then
					amt.Text = tostring(typeToCategory[tostring(v85.assetType or "")] or v85.typeLabel or "Item")
				end

				local v86 = typeToCategory[tostring(v85.assetType or "")] or "Move"
				local icon = clone:FindFirstChild("icon")

				if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
					local catalogueImage = normalizeCatalogueImage(v85.thumbnail or v85.thumbnailRaw or v85.imageId)
					icon.Image = v86 == "Character" and typeof(catalogueImage) == "string" and catalogueImage ~= "" and catalogueImage or RequestHelper.CATEGORY_DEFAULT_IMAGES[v86] or RequestHelper.CATEGORY_DEFAULT_IMAGES.Move or ""
				end

				local textButton = clone:FindFirstChild("TextButton")

				if textButton and textButton:IsA("TextButton") then
					local v87 = v85
					textButton.MouseButton1Click:Connect(function()
						v26 = v87
						uploadSelect.Visible = false
						uploadConfirm.Visible = true
						descInput.Text = ""
						local uploadImageInput2 = findUploadImageInput()

						if uploadImageInput2 then
							uploadImageInput2.Text = tostring(v87.thumbnailRaw or v87.thumbnail or "")
						end

						resetUploadSaleState()
						bindUploadImageInputPreview()
						refreshUploadPreviewCard(v87)
						publishBtn.Visible = true
						confirmWarn.Visible = false

						if confirmPublishBtn then
							confirmPublishBtn.Visible = false
						end

						if cancelPublishBtn then
							cancelPublishBtn.Visible = false
						end
					end)
				end

				clone.Parent = dropdownHolder2
			end
		elseif dropdownHolder2 then
			dropdownHolder2.Visible = false
		end
	end
end

if searchbox2 and searchbox2:IsA("TextBox") then
	searchbox2.ClearTextOnFocus = false
	searchbox2.PlaceholderText = "Search..."
	v61 = trimString(searchbox2.Text or "")
	local count4 = 0
	searchbox2:GetPropertyChangedSignal("Text"):Connect(function()
		local v84 = trimString(searchbox2.Text or "")

		if v84 == v61 then
			return
		end

		v61 = v84
		count4 += 1
		local v85 = count4
		task.delay(0.1, function()
			if v85 ~= count4 then
				return
			end

			fn3(true)
		end)
	end)
end

backBtn.MouseButton1Click:Connect(function()
	if fn4 then
		fn4()
	end

	uploadConfirm.Visible = false
	uploadSelect.Visible = true
	v26 = nil
	local uploadImageInput2 = findUploadImageInput()

	if uploadImageInput2 then
		uploadImageInput2.Text = ""
	end

	resetUploadSaleState()
	refreshUploadPreviewCard(nil)
end)
APPEARANCE_TWEEN = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
uploadAppearance = {
	bgColor = nil,
	mode = "gradient",
	gradientIntensity = 1,
	vignetteIntensity = 0.5,
	vignetteColor = rgb(73, 104, 206),
	selectedBgSwatch = nil
}

function resolveClickTarget(button)
	if button:IsA("GuiButton") then
		return button
	end

	local click = button:FindFirstChild("Click")

	if click and click:IsA("GuiButton") then
		return click
	end

	return ensureClickOverlay(button)
end

function buildUploadAppearancePayload()
	local function encColor(data)
		if typeof(data) == "Color3" then
			return { math.floor(data.R * 255 + 0.5), math.floor(data.G * 255 + 0.5), (math.floor(data.B * 255 + 0.5)) }
		end

		return nil
	end

	local v84 = {
		mode = tostring(uploadAppearance.mode or "gradient"),
		gi = math.clamp(tonumber(uploadAppearance.gradientIntensity) or 1, 0, 1),
		vi = math.clamp(tonumber(uploadAppearance.vignetteIntensity) or 0, 0, 1)
	}
	local vc = encColor(uploadAppearance.vignetteColor)

	if vc then
		v84.vc = vc
	end

	if typeof(uploadAppearance.headerGradientColor) ~= "ColorSequence" then
		return v84
	end

	local v86 = {}

	for _, keypoint in ipairs(uploadAppearance.headerGradientColor.Keypoints) do
		local v87 = encColor(keypoint.Value)

		if v87 then
			table.insert(v86, {
				t = keypoint.Time,
				c = v87
			})
		end
	end

	if #v86 > 0 then
		v84.g = v86
	end

	return v84
end

function applyCardAppearance()
	if not (uploadPreviewCard and uploadPreviewCard.Parent) then
		return
	end

	local v84 = math.clamp(uploadAppearance.gradientIntensity, 0, 1)
	local v85 = math.clamp(uploadAppearance.vignetteIntensity, 0, 1)
	local cardHeader = uploadPreviewCard:FindFirstChild("CardHeader")
	local uIGradient = cardHeader and cardHeader:FindFirstChildWhichIsA("UIGradient")

	if uIGradient then
		if uploadAppearance.mode == "off" then
			uIGradient.Enabled = false
		else
			uIGradient.Enabled = true
			local headerGradientColor = uploadAppearance.headerGradientColor

			if headerGradientColor then
				if uploadAppearance.mode == "solid" then
					local keypoints = headerGradientColor.Keypoints
					uIGradient.Color = ColorSequence.new(keypoints[1] and keypoints[1].Value or rgb(255, 255, 255))
				else
					uIGradient.Color = headerGradientColor
				end
			elseif uploadAppearance.mode == "solid" then
				local keypoints = uIGradient.Color.Keypoints
				uIGradient.Color = ColorSequence.new(keypoints[1] and keypoints[1].Value or rgb(255, 255, 255))
			end

			uIGradient.Transparency = NumberSequence.new(1 - v84)
		end
	end

	local vignette = uploadPreviewCard:FindFirstChild("Vignette")

	if vignette then
		vignette.ZIndex = 2
		local v86 = vignette:IsA("ImageLabel") or vignette:IsA("ImageButton")

		if uploadAppearance.vignetteColor then
			if v86 then
				vignette.ImageColor3 = uploadAppearance.vignetteColor
			else
				vignette.BackgroundColor3 = uploadAppearance.vignetteColor
			end
		end

		if v86 then
			vignette.ImageTransparency = 1 - v85
		else
			vignette.BackgroundTransparency = 1 - v85
		end
	end
end

local v84 = nil

local function applyPickedColor(color)
	if v84 == "vignette" then
		uploadAppearance.vignetteColor = color
		applyCardAppearance()
	elseif v84 == "background" then
		local cardHeader = uploadPreviewCard and uploadPreviewCard:FindFirstChild("CardHeader")

		if cardHeader and not cardHeader:FindFirstChildWhichIsA("UIGradient") then
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Parent = cardHeader
		end

		uploadAppearance.headerGradientColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, rgb(0, 0, 0))
		})
		applyCardAppearance()
	end
end

local colorFrame = uploadConfirm and uploadConfirm:FindFirstChild("ColorFrame")

if colorFrame then
	colorFrame:GetAttributeChangedSignal("Color"):Connect(function()
		if not v84 then
			return
		end

		local color = colorFrame:GetAttribute("Color")

		if typeof(color) == "Color3" then
			applyPickedColor(color)
		end
	end)
	colorFrame:GetAttributeChangedSignal("Committed"):Connect(function()
		if v84 ~= "background" then
			return
		end

		local cardHeader = uploadPreviewCard and uploadPreviewCard:FindFirstChild("CardHeader")
		local uIGradient = cardHeader and cardHeader:FindFirstChildWhichIsA("UIGradient")
		local appearanceSection = uploadConfirm and uploadConfirm:FindFirstChild("AppearanceSection")
		local background = appearanceSection and appearanceSection:FindFirstChild("Background")
		local swatches = background and background:FindFirstChild("Swatches")
		local swatch_Custom = swatches and swatches:FindFirstChild("Swatch_Custom")

		if uIGradient and swatch_Custom then
			local uIGradient2 = swatch_Custom:FindFirstChildWhichIsA("UIGradient")

			if uIGradient2 then
				uIGradient2:Destroy()
			end

			local clone = uIGradient:Clone()
			clone.Parent = swatch_Custom
		end
	end)
end

fn4 = function()
	local colorFrame2 = uploadConfirm and uploadConfirm:FindFirstChild("ColorFrame")

	if colorFrame2 then
		colorFrame2.Visible = false
	end

	if mainPanel then
		mainPanel.ClipsDescendants = true
	end

	v84 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openCustomColorPicker(p)
	if v84 == p then
		fn4()
		return
	end

	local colorFrame2 = uploadConfirm and uploadConfirm:FindFirstChild("ColorFrame")

	if not colorFrame2 then
		return
	end

	v84 = p

	if mainPanel then
		mainPanel.ClipsDescendants = false
	end

	local localScript = colorFrame2:FindFirstChildWhichIsA("LocalScript")

	if localScript then
		localScript.Disabled = false
	end

	colorFrame2.Visible = true
end

function setupAppearanceSection()
	local appearanceSection = uploadConfirm:FindFirstChild("AppearanceSection")

	if not (appearanceSection and appearanceSection:IsA("GuiObject")) then
		return
	end

	local function fn7()
		local cardHeader = uploadPreviewCard and uploadPreviewCard:FindFirstChild("CardHeader")
		local bgGradientSource = uploadAppearance.bgGradientSource

		if not (cardHeader and bgGradientSource and bgGradientSource.Parent) then
			return
		end

		local uIGradient = cardHeader:FindFirstChildWhichIsA("UIGradient")

		if uIGradient then
			uIGradient:Destroy()
		end

		local clone = bgGradientSource:Clone()
		clone.Parent = cardHeader
		uploadAppearance.headerGradientColor = clone.Color
	end

	local swatches = appearanceSection:FindFirstChild("Background") and appearanceSection.Background:FindFirstChild("Swatches")

	if swatches then
		local function fn8(selectedBgSwatch)
			if uploadAppearance.selectedBgSwatch == selectedBgSwatch then
				return
			end

			local selectedBgSwatch2 = uploadAppearance.selectedBgSwatch
			local uIStroke = selectedBgSwatch2 and selectedBgSwatch2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, APPEARANCE_TWEEN, {
					Transparency = 0.9
				}):Play()
			end

			uploadAppearance.selectedBgSwatch = selectedBgSwatch
			local uIStroke2 = selectedBgSwatch:FindFirstChildWhichIsA("UIStroke")

			if uIStroke2 then
				TweenService:Create(uIStroke2, APPEARANCE_TWEEN, {
					Transparency = 0
				}):Play()
			end

			uploadAppearance.bgGradientSource = selectedBgSwatch:FindFirstChildWhichIsA("UIGradient")
			fn7()
			applyCardAppearance()
		end

		for _, guiObject in ipairs(swatches:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and guiObject.Name:find("Swatch") == 1) then
				continue
			end

			local selectedBgSwatch = guiObject
			resolveClickTarget(guiObject).MouseButton1Click:Connect(function()
				fn8(selectedBgSwatch)

				if selectedBgSwatch.Name ~= "Swatch_Custom" then
					fn4()
					return
				end

				openCustomColorPicker("background") -- equivalent call inferred; original call site unknown
			end)

			if guiObject.Name == "Swatch_1" then
				uploadAppearance.selectedBgSwatch = guiObject
				uploadAppearance.bgGradientSource = guiObject:FindFirstChildWhichIsA("UIGradient")
				local uIStroke = guiObject:FindFirstChildWhichIsA("UIStroke")

				if uIStroke then
					uIStroke.Transparency = 0
				end
			else
				local uIStroke = guiObject:FindFirstChildWhichIsA("UIStroke")

				if uIStroke then
					uIStroke.Transparency = 0.9
				end
			end
		end

		fn7()
	end

	local background = appearanceSection:FindFirstChild("Background")
	local modeToggles = background and background:FindFirstChild("Header") and background.Header:FindFirstChild("ModeToggles")

	if modeToggles then
		local guiObjectsByChildName = {}

		for _, childName in ipairs({ "gradient", "off", "solid" }) do
			local guiObject = modeToggles:FindFirstChild(childName)

			if guiObject and guiObject:IsA("GuiObject") then
				guiObjectsByChildName[childName] = guiObject
			end
		end

		local backgroundColor3 = rgb(0, 0, 0)
		local backgroundTransparency = 1

		for _, v86 in ipairs({ "off", "solid" }) do
			local v87 = guiObjectsByChildName[v86]

			if not v87 then
				continue
			end

			backgroundColor3 = v87.BackgroundColor3
			backgroundTransparency = v87.BackgroundTransparency
			break
		end

		local function fn8()
			for k, v86 in pairs(guiObjectsByChildName) do
				if uploadAppearance.mode == k then
					TweenService:Create(v86, APPEARANCE_TWEEN, {
						BackgroundColor3 = rgb(255, 255, 255),
						BackgroundTransparency = 0.45
					}):Play()
				else
					TweenService:Create(v86, APPEARANCE_TWEEN, {
						BackgroundColor3 = backgroundColor3,
						BackgroundTransparency = backgroundTransparency
					}):Play()
				end
			end
		end

		for k, v86 in pairs(guiObjectsByChildName) do
			local mode = k
			resolveClickTarget(v86).MouseButton1Click:Connect(function()
				uploadAppearance.mode = mode
				fn8()
				applyCardAppearance()
			end)
		end

		fn8()
	end

	local function fn8(guiObject, p, fn9)
		if not (guiObject and guiObject:IsA("GuiObject")) then
			return
		end

		local slider = guiObject:FindFirstChild("Slider")

		if not (slider and slider:IsA("GuiObject")) then
			return
		end

		local fill = slider:FindFirstChild("Fill")
		local knob = slider:FindFirstChild("Knob")
		local value = guiObject:FindFirstChild("Header") and guiObject.Header:FindFirstChild("Value")

		local function fn10(value2)
			local v85 = math.clamp(value2, 0, 1)

			if fill then
				fill.Size = UDim2.new(v85, 0, fill.Size.Y.Scale, fill.Size.Y.Offset)
			end

			if knob then
				knob.Position = UDim2.new(v85, 0, knob.Position.Y.Scale, knob.Position.Y.Offset)
			end

			if value and (value:IsA("TextLabel") or value:IsA("TextButton")) then
				value.Text = tostring((math.floor(v85 * 100 + 0.5))) .. "%"
			end

			fn9(v85)
			applyCardAppearance()
		end

		local v85 = false
		local v86 = knob or slider
		v86.Active = true
		slider.Active = true
		v86.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v85 = true
				local X = input.Position.X
				local X2 = slider.AbsolutePosition.X
				local v87 = math.max(1, slider.AbsoluteSize.X)
				fn10((X - X2) / v87)
			end
		end)
		slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v85 = true
				local X = input.Position.X
				local X2 = slider.AbsolutePosition.X
				local v87 = math.max(1, slider.AbsoluteSize.X)
				fn10((X - X2) / v87)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if v85 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local X = input.Position.X
				local X2 = slider.AbsolutePosition.X
				local v87 = math.max(1, slider.AbsoluteSize.X)
				fn10((X - X2) / v87)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v85 = false
			end
		end)
		fn10(p)
	end

	fn8(appearanceSection:FindFirstChild("Vignette"), uploadAppearance.gradientIntensity, function(gradientIntensity)
		uploadAppearance.gradientIntensity = gradientIntensity
	end)
	local highlight = appearanceSection:FindFirstChild("Highlight")
	fn8(
		highlight and highlight:FindFirstChild("Vignette"),
		uploadAppearance.vignetteIntensity,
		function(vignetteIntensity)
			uploadAppearance.vignetteIntensity = vignetteIntensity
		end
	)
	local vignetteColor = appearanceSection:FindFirstChild("VignetteColor")
	local swatches2 = vignetteColor and vignetteColor:FindFirstChild("Swatches")

	if swatches2 then
		local function fn9(selectedVignetteSwatch)
			if uploadAppearance.selectedVignetteSwatch == selectedVignetteSwatch then
				return
			end

			local selectedVignetteSwatch2 = uploadAppearance.selectedVignetteSwatch
			local uIStroke = selectedVignetteSwatch2 and selectedVignetteSwatch2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				TweenService:Create(uIStroke, APPEARANCE_TWEEN, {
					Transparency = 0.9
				}):Play()
			end

			uploadAppearance.selectedVignetteSwatch = selectedVignetteSwatch
			local uIStroke2 = selectedVignetteSwatch:FindFirstChildWhichIsA("UIStroke")

			if uIStroke2 then
				TweenService:Create(uIStroke2, APPEARANCE_TWEEN, {
					Transparency = 0
				}):Play()
			end

			uploadAppearance.vignetteColor = selectedVignetteSwatch.BackgroundColor3
			applyCardAppearance()
		end

		local flag5 = true

		for _, guiObject in ipairs(swatches2:GetChildren()) do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local selectedVignetteSwatch = guiObject
			resolveClickTarget(guiObject).MouseButton1Click:Connect(function()
				fn9(selectedVignetteSwatch)

				if selectedVignetteSwatch.Name ~= "Swatch_Custom" then
					fn4()
					return
				end

				openCustomColorPicker("vignette") -- equivalent call inferred; original call site unknown
			end)
			local uIStroke = guiObject:FindFirstChildWhichIsA("UIStroke")

			if flag5 then
				uploadAppearance.selectedVignetteSwatch = guiObject

				if uIStroke then
					uIStroke.Transparency = 0
				end

				flag5 = false
			elseif uIStroke then
				uIStroke.Transparency = 0.9
			end
		end
	end

	local editableFrame = uploadConfirm:FindFirstChild("EditableFrame")

	if editableFrame and editableFrame:IsA("GuiObject") and editableFrame:GetAttribute("__EditableBound") ~= true then
		editableFrame:SetAttribute("__EditableBound", true)
		local toggle = editableFrame:FindFirstChild("Toggle")
		local knob = toggle and toggle:FindFirstChild("Knob", true) or editableFrame:FindFirstChild("Knob", true)
		local uDim, uDim2

		if knob and knob:IsA("GuiObject") then
			uDim = UDim2.new(0, 0, knob.Position.Y.Scale, knob.Position.Y.Offset)
			uDim2 = UDim2.new(0.5, 0, knob.Position.Y.Scale, knob.Position.Y.Offset)
		else
			uDim = nil
			uDim2 = nil
		end

		local function fn9()
			local effectiveUploadAllowEditing = getEffectiveUploadAllowEditing() -- equivalent call inferred; original call site unknown
			editableFrame:SetAttribute("On", effectiveUploadAllowEditing)

			if toggle and toggle:IsA("GuiObject") then
				TweenService:Create(toggle, APPEARANCE_TWEEN, {
					BackgroundColor3 = effectiveUploadAllowEditing and rgb(80, 180, 80) or rgb(198, 198, 198)
				}):Play()
			end

			if knob and uDim and uDim2 then
				TweenService:Create(knob, APPEARANCE_TWEEN, {
					Position = effectiveUploadAllowEditing and uDim2 or uDim
				}):Play()
			end
		end

		resolveClickTarget(editableFrame).MouseButton1Click:Connect(function()
			v27.allowEditing = not v27.allowEditing
			fn9()
			refreshUploadSaleUi()
		end)
		fn9()
	end

	applyCardAppearance()
end

setupAppearanceSection()

function setPublishButtonBusy(p)
	if not publishBtn then
		return
	end

	if v27.publishBtnIdleText == nil then
		v27.publishBtnIdleText = tostring(publishBtn.Text or "PUBLISH")
	end

	if v27.publishBtnIdleAutoButtonColor == nil then
		v27.publishBtnIdleAutoButtonColor = publishBtn.AutoButtonColor
	end

	local v85 = p == true and "uploading" or p

	if type(v85) == "string" and v85 ~= "" then
		flag2 = true
		count += 1
		local v86 = count
		local v87 = string.lower(v85) == "verifying" and "VERIFYING" or "UPLOADING"
		publishBtn.Active = false
		publishBtn.AutoButtonColor = false
		publishBtn.Text = v87 .. ".."
		task.spawn(function()
			local v88 = 2

			while flag2 and v86 == count do
				publishBtn.Text = v87 .. string.rep(".", v88)
				local v89 = v88 + 1
				v88 = v89 > 3 and 1 or v89
				task.wait(0.32)
			end
		end)
	else
		flag2 = false
		count += 1
		publishBtn.Active = true
		publishBtn.AutoButtonColor = v27.publishBtnIdleAutoButtonColor == true
		publishBtn.Text = v27.publishBtnIdleText or "PUBLISH"
	end
end

publishBtn.MouseButton1Click:Connect(function()
	if flag2 then
		return
	end

	if fn4 then
		fn4()
	end

	local source = v26

	if not source then
		return
	end

	local sourceId = tostring(source.sourceId or "")

	if sourceId ~= "" then
		for _, v86 in ipairs(v19 or {}) do
			if tostring(v86 and v86.sourceRef or "") ~= sourceId then
				continue
			end

			showToast("Already uploaded. Use My Uploads -> Update.")
			return
		end
	end

	if v27.importCodePending then
		showToast("Import code is still preparing")
		return
	end

	if not claimActionDebounce("upload_publish", tostring(source.sourceId or source.name or "unknown"), 0.6) then
		return
	end

	if not catGiveCanGiveToOthers() then
		showToast("YOU CANNOT UPLOAD ITEMS IN OTHER PEOPLES SERVERS")
		return
	end

	local assetType = tostring(source.assetType or "moves")
	local v86 = inferTypeFromSource({
		sourceType = source.sourceType,
		sourceSubtype = source.sourceSubtype,
		name = source.name,
		assetType = assetType,
		config = source.config
	})

	if v86 and v86 ~= "" then
		assetType = v86
	end

	local v87 = {
		source = source,
		sourceId = source.sourceId,
		assetType = assetType,
		name = source.name,
		description = descInput.Text,
		tags = source.tags or {},
		allowEditing = v27.allowEditing == true,
		appearance = buildUploadAppearancePayload()
	}

	if v27.latestImportCode ~= "" then
		v87.importCode = v27.latestImportCode
	end

	local uploadThumbnail = resolveUploadThumbnail(source, true)

	if uploadThumbnail then
		v87.thumbnail = uploadThumbnail
	end

	local config = source.config

	if assetType == "created_anims" and type(config) == "table" then
		if config.importedFromRoblox == true or type(config.runtimeAnimationId) == "string" and config.runtimeAnimationId ~= "" then
			showToast("Animations loaded from Roblox cannot be uploaded")
			return
		end

		local keyframeCount = math.floor(tonumber(config.keyframeCount) or 0)

		if keyframeCount < 30 then
			showToast("Animation needs at least 30 keyframes to upload (has " .. tostring(keyframeCount) .. ")")
			return
		end

		if type(config.poseData) == "string" and config.poseData ~= "" then
			local success, result = pcall(HttpService.JSONDecode, HttpService, config.poseData)

			if success and type(result) == "table" then
				local v88 = {}
				local v89 = {}

				for _, v90 in ipairs(result) do
					if type(v90) ~= "table" then
						continue
					end

					local targetName = tostring(v90.TargetName or "")

					if not (targetName ~= "" and targetName ~= "Camera") then
						continue
					end

					v88[targetName] = true
					local rotation = v90.Rotation

					if type(rotation) ~= "table" then
						continue
					end

					if not (math.abs(tonumber(rotation[1]) or 0) > 1 or math.abs(tonumber(rotation[2]) or 0) > 1 or math.abs(tonumber(rotation[3]) or 0) > 1) then
						continue
					end

					v89[targetName] = true
				end

				local count4 = 0

				for _ in pairs(v88) do
					count4 += 1
				end

				local count5 = 0

				for _ in pairs(v89) do
					count5 += 1
				end

				if count4 < 4 then
					showToast("Animation must use at least 4 different joints (has " .. tostring(count4) .. ")")
					return
				end

				if count5 < 2 then
					showToast("Animation must have rotation on at least 2 joints")
					return
				end
			end
		end
	end

	setPublishButtonBusy("verifying")
	task.wait(0.14)
	setPublishButtonBusy("uploading")
	task.wait(0.06)
	local success, result = pcall(function()
		return req("UploadFromSource", v87, 4)
	end)
	setPublishButtonBusy(false)

	if not success then
		showToast("Publish failed: internal")
		return
	end

	if not result.ok then
		if result.error == "character-min-moves" then
			showToast("CUSTOM CHARACTERS NEED MINIMUM 3 MOVES, UPLOAD YOUR MOVES INDIVIDUALLY")
			return
		end

		if result.error == "not-server-owner" then
			showToast("YOU CANNOT UPLOAD ITEMS IN OTHER PEOPLES SERVERS")
			return
		end

		if result.error == "inappropriate-description" then
			showToast("INAPPROPRIATE DESCRIPTION, REMOVE IT OR CHANGE IT")
			return
		end

		if result.error == "account-too-young" then
			showToast("YOUR ACCOUNT IS TOO YOUNG (<2 MONTHS)")
			return
		end

		if result.error == "not-enough-kills" then
			showToast("YOU NEED MORE TOTAL KILLS (<200)")
			return
		end

		if result.error == "stats-unavailable" then
			showToast("Couldn't verify your stats — try again in a moment")
			return
		end

		if result.error == "similarity-hard-block" then
			local matchScore = tostring((math.floor(tonumber(result.matchScore) or 0)))
			local matchName = tostring(result.matchName or "another listing")
			showToast("Too similar to \"" .. matchName .. "\" (" .. matchScore .. "%) — upload blocked")
			return
		elseif result.error == "similarity-warning" then
			local matchScore = tostring((math.floor(tonumber(result.matchScore) or 0)))
			local matchName = tostring(result.matchName or "an existing listing")
			local similarityAckToken = result.similarityAckToken

			if type(similarityAckToken) ~= "string" or similarityAckToken == "" then
				showToast("Publish failed: similarity check error")
				return
			end

			v87.similarityAckToken = similarityAckToken
			showToast("Similar to \"" .. matchName .. "\" (" .. matchScore .. "%) — re-submitting with acknowledgement")
			task.wait(0.12)
			local success2
			success2, result = pcall(function()
				return req("UploadFromSource", v87, 4)
			end)
			v87.similarityAckToken = nil
			setPublishButtonBusy(false)

			if not success2 then
				showToast("Publish failed: internal")
				return
			end

			if not result.ok then
				showToast("Publish failed: " .. describeCatalogueError(result.error))
				return
			end
		else
			if type(result.errorDetail) == "string" and result.errorDetail ~= "" then
			end

			showToast("Publish failed: " .. describeCatalogueError(result.error))
			return
		end
	end

	local uploadImportSourceKey = getUploadImportSourceKey(source)
	v27.latestImportCode = tostring(not result.entry and "" or result.entry.importCode or "")

	if uploadImportSourceKey ~= "" and v27.latestImportCode ~= "" then
		v27.importCodesBySourceKey[uploadImportSourceKey] = v27.latestImportCode
	end

	refreshUploadSaleUi()

	if v27.latestImportCode == "" then
		showToast("\"" .. tostring(source.name or "Item") .. "\" published to the catalogue!")
	else
		showToast("\"" .. tostring(source.name or "Item") .. "\" published! Import code: " .. v27.latestImportCode)
	end

	uploadConfirm.Visible = false
	uploadSelect.Visible = true
	v26 = nil
	resetUploadSaleState()
	local uploadImageInput2 = findUploadImageInput()

	if uploadImageInput2 then
		uploadImageInput2.Text = ""
	end

	refreshUploadPreviewCard(nil)

	if typeof(result.entry) == "table" then
		pinBrowseEntry(result.entry)
	end

	page = 1
	switchTab("BROWSE")
	task.spawn(function()
		invalidateListCache("mine")
		invalidateListCache("added")
		invalidateListCache("verified")
		syncMine(true)
		syncAdded(true)
		refreshMyUploads(true)
		refreshAddedToPS(true)
		updateTabCounts()
	end)
end)

if confirmPublishBtn and confirmPublishBtn:IsA("GuiButton") then
	confirmPublishBtn.MouseButton1Click:Connect(function() end)
end

if cancelPublishBtn and cancelPublishBtn:IsA("GuiButton") then
	cancelPublishBtn.MouseButton1Click:Connect(function()
		confirmWarn.Visible = false

		if confirmPublishBtn then
			confirmPublishBtn.Visible = false
		end

		cancelPublishBtn.Visible = false
	end)
end

function refreshMyUploads(p)
	v41.mine += 1
	local mine = v41.mine
	syncMine(p == true)

	if mine ~= v41.mine then
		return
	end

	myUploadsTitle.Text = "YOUR PUBLISHED ITEMS (" .. #v19 .. ")"
	local entryCollectionSignature = buildEntryCollectionSignature(v19)

	if p ~= true and listCacheState.lastRendered.mine == entryCollectionSignature and hasVisibleNamedRows(
		myUploadsScroll,
		{ "MyUp_" }
	) then
		return
	end

	listCacheState.lastRendered.mine = entryCollectionSignature

	for _, guiObject in ipairs(myUploadsScroll:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject.Name:find("MyUp_") then
			guiObject:Destroy()
		end
	end

	local myuploadscardtemplate = script:FindFirstChild("myuploadscardtemplate")

	if not myuploadscardtemplate then
		return
	end

	for i, v86 in ipairs(v19) do
		local card = buildCard(v86, i, {
			template = myuploadscardtemplate,
			parent = myUploadsScroll,
			onOpen = openDetail,
			blockOpenRegions = { "updatebtn", "deletebtn", "ImportCode" }
		})
		card.Name = "MyUp_" .. v86.id
		local cardInfo = card:WaitForChild("CardInfo")
		local importCode = cardInfo:FindFirstChild("ImportCode")

		if importCode and (importCode:IsA("TextLabel") or importCode:IsA("TextButton") or importCode:IsA("TextBox")) then
			local importCode2 = tostring(v86.importCode or "")
			importCode.Text = importCode2

			if importCode:IsA("TextBox") then
				importCode.PlaceholderText = ""
				importCode.ClearTextOnFocus = false
				importCode.TextEditable = true
				importCode.Active = true
				importCode.Selectable = true
				local v87 = importCode
				local text2 = importCode2
				importCode.FocusLost:Connect(function()
					if v87.Text ~= text2 then
						v87.Text = text2
					end
				end)
			end
		end

		local updatebtn = cardInfo:FindFirstChild("updatebtn")

		if updatebtn and updatebtn:IsA("TextButton") then
			local count4 = 0
			updatebtn.Text = "UPDATE"
			local v87 = updatebtn
			local v88 = v86
			updatebtn.MouseButton1Click:Connect(function()
				if string.sub(v87.Text, 1, 8) == "UPDATING" then
					return
				end

				local id = tostring(v88.id or v88.sourceRef or "")

				if id == "" then
					showToast("Update unavailable: missing listing id")
					return
				end

				if v30[id] then
					return
				end

				local now2 = os.clock()
				local v89 = v33[id] or 0

				if now2 < v89 then
					showToast("Update again in " .. tostring((math.ceil(v89 - now2))) .. "s")
					return
				end

				local sourceRef = tostring(v88.sourceRef or "")

				if sourceRef == "" then
					showToast("Update unavailable: listing is not source-linked")
					return
				end

				v30[id] = true
				v33[id] = now2 + 25
				count4 += 1
				local v90 = count4
				task.spawn(function()
					local v91 = 0

					while v30[id] and count4 == v90 and v87 and v87.Parent do
						v87.Text = "UPDATING" .. string.rep(".", v91)
						v91 = (v91 + 1) % 4
						task.wait(0.3)
					end
				end)
				syncUploadSources(true)
				local source2 = nil

				for i2, source in ipairs(sources) do
					if tostring(source.sourceId or "") ~= sourceRef then
						continue
					end

					source2 = source
					break
				end

				if source2 then
					local v93 = {
						source = source2,
						sourceId = sourceRef,
						name = tostring(source2.name or v88.name or "Untitled"),
						description = tostring(source2.description or v88.desc or ""),
						tags = source2.tags or v88.tags or { "Imported" },
						assetType = source2.assetType or v88.type or "moves"
					}
					local uploadThumbnail = resolveUploadThumbnail(source2, false)

					if uploadThumbnail then
						v93.thumbnail = uploadThumbnail
					end

					local v94 = req("UploadFromSource", v93, 4)
					v30[id] = nil
					count4 += 1

					if v87 and v87.Parent then
						v87.Text = "UPDATE"
					end

					if v94.ok then
						showToast("Listing updated from source")
						invalidateListCache("mine")
						invalidateListCache("verified")
						syncMine(true)
						refreshMyUploads(true)
						refreshBrowse(true)
						refreshAddedToPS(true)
						refreshLeaderboard()
						updateTabCounts()
					elseif v94.error == "update-cooldown" then
						local retryAfter = math.ceil(tonumber(v94.retryAfter) or 20)
						v33[id] = os.clock() + retryAfter
						showToast("Update again in " .. tostring(retryAfter) .. "s")
					else
						v33[id] = nil
						showToast("Update failed: " .. describeCatalogueError(v94.error))
					end
				else
					v30[id] = nil
					count4 += 1
					v33[id] = nil

					if v87 and v87.Parent then
						v87.Text = "UPDATE"
					end

					showToast("Update failed: source not found")
				end
			end)
		end

		local deletebtn = cardInfo:FindFirstChild("deletebtn")

		if not (deletebtn and deletebtn:IsA("TextButton")) then
			continue
		end

		local count4 = 0
		deletebtn.Text = "DELETE"
		local v87 = deletebtn
		local v88 = v86
		local v89 = card
		deletebtn.MouseButton1Click:Connect(function()
			if string.sub(v87.Text, 1, 8) == "DELETING" then
				return
			end

			if v87.Text == "SURE?" then
				count4 += 1
				local id = tostring(v88.id)

				if v31[id] then
					return
				end

				local now2 = os.clock()

				if now2 < (v32[id] or 0) then
					return
				end

				v31[id] = true
				v32[id] = now2 + 2
				local v90 = count4
				task.spawn(function()
					local v91 = 0

					while count4 == v90 and v87 and v87.Parent do
						v87.Text = "DELETING" .. string.rep(".", v91)
						v91 = (v91 + 1) % 4
						task.wait(0.3)
					end
				end)
				local v91 = req("DeleteListing", {
					entryId = v88.id
				}, 3)
				v31[id] = nil
				count4 += 1

				if v91.ok then
					v34[tostring(v88.id)] = true

					if v89 and v89.Parent then
						v89:Destroy()
					end

					showToast("Listing removed")
					invalidateListCache("mine")
					invalidateListCache("verified")
					syncMine(true)
					refreshMyUploads(true)
					refreshBrowse(true)
					updateTabCounts()
				elseif v91.error == "has-sales" then
					v87.Text = "DELETE"
					showToast("Can't delete — listing has been sold")
				else
					v87.Text = "DELETE"
					showToast("Delete failed")
				end
			else
				count4 += 1
				local v90 = count4
				v87.Text = "SURE?"
				task.delay(2, function()
					if count4 ~= v90 then
						return
					end

					if v87 and v87.Parent then
						v87.Text = "DELETE"
					end
				end)
			end
		end)
	end
end

function updateTabCounts()
	local count4 = 0

	for _ in pairs(addedToPS) do
		count4 += 1
	end

	tabs.ADDED_TO_PS.btn:FindFirstChild("AddedCount")
end

local flag5 = false

function primeCatalogueDataIfNeeded()
	if flag5 then
		return
	end

	flag5 = true
	task.spawn(function()
		syncMine()
		updateTabCounts()
	end)
	task.spawn(function()
		syncAdded()
		updateTabCounts()
	end)
	task.spawn(function()
		syncFavourites()
		updateTabCounts()
	end)
	task.spawn(function()
		syncVotes()
	end)
	task.spawn(function()
		syncUploadSources()
		updateTabCounts()
	end)
end

function refreshActiveTabOnly(p)
	if not mainPanel.Visible then
		return
	end

	if v7 == "BROWSE" then
		refreshBrowse()
	elseif v7 == "LEADERBOARD" then
		task.spawn(function()
			refreshLeaderboard(false)
		end)
	elseif v7 == "VERIFIED" then
		refreshVerified(p == true)
	elseif v7 == "ADDED_TO_PS" then
		refreshAddedToPS(p == true)
	elseif v7 == "UPLOAD" then
		fn3(true)
		syncUploadSourcesAsync(p == true)
		syncMineForUploadAsync(p == true)
	elseif v7 == "MY_UPLOADS" then
		refreshMyUploads(p == true)
	elseif v7 == "PANEL" then
		ensurePanelUi()
		panelRefreshSummary()

		if v55.activeCreatorUserId > 0 then
			panelRefreshCreatorListings()
		end
	else
		refreshBrowse()
	end

	updateTabCounts()
end

function openCatalogue()
	if game.PrivateServerOwnerId == 0 and workspace:GetAttribute("CustomServerOwnerId") == nil and workspace:GetAttribute("VIPServer") == nil then
		return
	end

	local vIPServer = workspace:GetAttribute("VIPServer")
	local customServerOwnerId = workspace:GetAttribute("CustomServerOwnerId")
	local v85

	if localPlayer.UserId == vIPServer or localPlayer.UserId == customServerOwnerId then
		v85 = true
	else
		local RunService = game:GetService("RunService")
		v85 = RunService:IsStudio()
	end

	local catalogueAccess = workspace:GetAttribute("CatalogueAccess") or 1

	if not v85 and catalogueAccess ~= 2 or mainPanel.Visible then
		return
	end

	mainPanel.Visible = true
	_G.__TSB_GLOBAL_CATALOGUE_UI_OPEN = true
	local v86 = not flag5

	if v7 == "BROWSE" then
		setBrowseLoading(true, true)
	end

	primeCatalogueDataIfNeeded()
	refreshActiveTabOnly(v86)
	v41.openLoop += 1
	local openLoop = v41.openLoop
	task.spawn(function()
		while v41.openLoop == openLoop do
			local v88 = v7 == "LEADERBOARD" and 25 or (v7 == "UPLOAD" or v7 == "MY_UPLOADS") and 18 or 14
			task.wait(v88)

			if v41.openLoop ~= openLoop then
				break
			end

			if not mainPanel.Visible then
				continue
			end

			if v7 == "BROWSE" then
				refreshBrowseStatsOnly()
			elseif v7 == "LEADERBOARD" then
				local v89 = v25 == "ALL_ITEMS" and "items" or "creators"

				if not hasFreshLeaderboardCache(v89) then
					switchLbSub(v25)
				end
			elseif v7 == "VERIFIED" then
				refreshVerified()
			elseif v7 == "PANEL" then
				panelRefreshSummary()
			end
		end
	end)
end

function closeCatalogue()
	_G.__TSB_GLOBAL_CATALOGUE_UI_OPEN = false
	mainPanel.Visible = false

	for k in pairs(v41) do
		v41[k] += 1
	end

	setBrowseLoading(false)
	local success, cataloguePreviewHelper = pcall(require, script:FindFirstChild("CataloguePreviewHelper"))

	if success and type(cataloguePreviewHelper) == "table" and type(cataloguePreviewHelper.clear) == "function" then
		pcall(cataloguePreviewHelper.clear)
	end

	detailReturnApi.clear()

	if charDetailOverlay.Visible then
		closeDetail()
	end

	if creatorProfileOverlay.Visible then
		closeCreatorProfile(true)
	end
end

closeBtn.MouseButton1Click:Connect(closeCatalogue)
refresh.MouseButton1Click:Connect(function()
	requestApi.setForceFresh(4)
	v47 = os.clock() + 35
	refreshActiveTabOnly(true)
	showToast("Refreshed")
end)
mainPanel.Visible = false
_G.__TSB_GLOBAL_CATALOGUE_UI_OPEN = false
setupLeaderboardSubTabs()
updateCatBar()
switchTab("BROWSE", {
	skipRefresh = true
})
refreshUploadPreviewCard(nil)
workspace:GetAttributeChangedSignal("CatalogueAccess"):Connect(function()
	if not mainPanel.Visible then
		return
	end

	local vIPServer = workspace:GetAttribute("VIPServer")
	local customServerOwnerId = workspace:GetAttribute("CustomServerOwnerId")
	local v85

	if localPlayer.UserId == vIPServer or localPlayer.UserId == customServerOwnerId then
		v85 = true
	else
		local RunService = game:GetService("RunService")
		v85 = RunService:IsStudio()
	end

	if not v85 and workspace:GetAttribute("CatalogueAccess") ~= 2 then
		closeCatalogue()
	end
end)
localPlayer:GetAttributeChangedSignal("CustomCharacters"):Connect(function()
	if v7 == "ADDED_TO_PS" then
		refreshAddedToPS()
	end
end)

if receiver and receiver:IsA("RemoteEvent") then
	receiver.OnClientEvent:Connect(function(p)
		if p == "OpenGlobalCatalogue" then
			openCatalogue()
		elseif p == "CloseGlobalCatalogue" then
			closeCatalogue()
		end
	end)
end

script.Destroying:Connect(function()
	if _G.__TSB_GLOBAL_CATALOGUE_BIND_SCRIPT == script then
		_G.__TSB_GLOBAL_CATALOGUE_BIND_SCRIPT = nil
		_G.__TSB_GLOBAL_CATALOGUE_BIND_ACTIVE = false
		_G.__TSB_GLOBAL_CATALOGUE_UI_OPEN = false
		_G.OpenGlobalCatalogue = nil
		_G.CloseGlobalCatalogue = nil
	end
end)

function _G.OpenGlobalCatalogue()
	openCatalogue()
end

function _G.CloseGlobalCatalogue()
	closeCatalogue()
end

local Info = require(game.ReplicatedStorage:WaitForChild("Info"))

function shared.cataloguegui(p, p2)
	if not mainPanel then
		return
	end

	if p2 then
		return mainPanel.Visible
	end

	if p == nil then
		p = not mainPanel.Visible
	end

	if not p then
		closeCatalogue()
		return
	end

	Info.hideGUI(parent)
	openCatalogue()
end

function _G.OpenGlobalCatalogueWithSearch(value)
	openCatalogue()
	switchTab("BROWSE")

	if searchInput then
		searchInput.Text = tostring(value or "")
	end
end

if tostring(localPlayer) == "YungCrepetics" then
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or UserInputService:GetFocusedTextBox() then
			return
		end

		if input.KeyCode == Enum.KeyCode.P then
			if mainPanel.Visible then
				closeCatalogue()
			else
				openCatalogue()
			end
		end
	end)
end