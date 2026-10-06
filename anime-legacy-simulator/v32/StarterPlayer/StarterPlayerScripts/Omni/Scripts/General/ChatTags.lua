local module = require("@game/ReplicatedStorage/Omni")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
local flag = false
local chatWindowConfiguration = module.Services.TextChatService.ChatWindowConfiguration
local v6 = utf8.char(57344)
local v7 = {}
local count = 0
local v8 = {}
local v9 = {}
local flag2 = false
local ChatTags = {}

local function RefreshPlayer(instance)
	local decodeSelection = module.Shared.ChatTags.DecodeSelection(instance:GetAttribute(module.Shared.ChatTags.SelectionAttribute))
	v3[instance.UserId] = module.Shared.ChatTags.Build(
		instance:GetAttribute("ChatRank"),
		instance:GetAttribute("VIP") == true,
		v4[instance.UserId],
		decodeSelection,
		instance.UserId
	)
end

local function RefreshLeaderboards()
	table.clear(v4)
	local v10 = {}

	for _, v11 in module.Services.Players:GetPlayers() do
		v10[v11.UserId] = v11
	end

	for k, v11 in v5.Data or {} do
		local v12 = module.Shared.Leaderboards.List[k]

		if not (v12 and typeof(v11) == "table") then
			continue
		end

		for k2, v13 in v11 do
			if not (v12.Categories[k2] and typeof(v13) == "table") then
				continue
			end

			for k3, v14 in v13 do
				if not (typeof(v14) == "table" and v10[v14.UserId]) then
					continue
				end

				local v15 = v4[v14.UserId]

				if not v15 then
					v15 = {}
					v4[v14.UserId] = v15
				end

				table.insert(v15, {
					Name = k,
					Category = k2,
					Rank = k3
				})
			end
		end
	end

	for _, v11 in v10 do
		RefreshPlayer(v11)
	end
end

local function RemovePlayer(p)
	for _, connection in v2[p] or {} do
		connection:Disconnect()
	end

	v2[p] = nil
	v3[p.UserId] = nil
	v4[p.UserId] = nil
end

local function IsVerified(p: number)
	if v9[p] ~= nil then
		return v9[p]
	end

	local success, result = pcall(function()
		return module.Services.UserService:GetUserInfosByUserIdsAsync({ p })
	end)

	if success and typeof(result) == "table" and result[1] then
		v9[p] = result[1].HasVerifiedBadge == true
		return v9[p]
	end

	local playerByUserId = module.Services.Players:GetPlayerByUserId(p)
	return playerByUserId ~= nil and playerByUserId.HasVerifiedBadge == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlainLength(value: string)
	local v10 = string.gsub(value, "<[^>]*>", "")
	return utf8.len(v10) or #v10
end

local function MeasureRegion(text2: string, value2: string)
	local success, result = pcall(function()
		local function Width(text: string)
			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = text
			getTextBoundsParams.Font = chatWindowConfiguration.FontFace
			getTextBoundsParams.Size = chatWindowConfiguration.TextSize
			getTextBoundsParams.Width = 100000
			getTextBoundsParams.RichText = true
			return module.Services.TextService:GetTextBoundsAsync(getTextBoundsParams).X
		end

		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = value2
		getTextBoundsParams.Font = chatWindowConfiguration.FontFace
		getTextBoundsParams.Size = chatWindowConfiguration.TextSize
		getTextBoundsParams.Width = 100000
		getTextBoundsParams.RichText = true
		local X = module.Services.TextService:GetTextBoundsAsync(getTextBoundsParams).X
		local getTextBoundsParams2 = Instance.new("GetTextBoundsParams")
		getTextBoundsParams2.Text = text2
		getTextBoundsParams2.Font = chatWindowConfiguration.FontFace
		getTextBoundsParams2.Size = chatWindowConfiguration.TextSize
		getTextBoundsParams2.Width = 100000
		getTextBoundsParams2.RichText = true
		return { 0, X / module.Services.TextService:GetTextBoundsAsync(getTextBoundsParams2).X }
	end)

	if success and result[2] > 0 and result[2] <= 1 then
		return result
	end

	local plainLength = PlainLength(value2) -- equivalent call inferred; original call site unknown
	local v11 = string.gsub(text2, "<[^>]*>", "")
	return { 0, plainLength / math.max(utf8.len(v11) or #v11, 1) }
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RedrawChatOnce()
	if flag2 then
		return
	end

	flag2 = true
	task.spawn(function()
		local textStrokeTransparency = chatWindowConfiguration.TextStrokeTransparency
		local v10 = chatWindowConfiguration
		local textStrokeTransparency2

		if textStrokeTransparency + 0.001 <= 1 then
			textStrokeTransparency2 = textStrokeTransparency + 0.001
		else
			textStrokeTransparency2 = textStrokeTransparency - 0.001
		end

		v10.TextStrokeTransparency = textStrokeTransparency2
		task.wait(0.2)
		chatWindowConfiguration.TextStrokeTransparency = textStrokeTransparency
		flag2 = false
	end)
end

local function PaintUniqueTag(uIGradient, uniqueTag, p: string, prefixText: string, userId: number)
	local v10 = userId .. "|" .. p .. prefixText
	local v11 = v7[v10]

	if v11 then
		uIGradient.Color = module.Shared.ChatTags.BuildRegionSequence(uniqueTag.Colors, v11[1], v11[2])
		return
	end

	if v8[v10] then
		table.insert(v8[v10], uIGradient)
		return
	end

	v8[v10] = { uIGradient }
	task.spawn(function()
		local v12 = prefixText

		if IsVerified(userId) then
			v12 = string.sub(v12, -1) == ":" and string.sub(v12, 1, -2) .. v6 .. ":" or v12 .. v6
		end

		local measureRegion = MeasureRegion(p .. " " .. v12, module.Shared.ChatTags.FormatUniqueTag(uniqueTag.Name))

		if count >= 32 then
			table.clear(v7)
			count = 0
		end

		v7[v10] = measureRegion
		count += 1

		for _, v14 in v8[v10] or {} do
			v14.Color = module.Shared.ChatTags.BuildRegionSequence(uniqueTag.Colors, measureRegion[1], measureRegion[2])
		end

		v8[v10] = nil
		RedrawChatOnce() -- equivalent call inferred; original call site unknown
	end)
end

local function AddPlayer(object)
	RemovePlayer(object)

	if module.Shared.ChatTags.UniqueTags[object.UserId] then
		task.spawn(IsVerified, object.UserId)
	end

	v2[object] = { object:GetAttributeChangedSignal("ChatRank"):Connect(function()
			RefreshPlayer(object)
		end), object:GetAttributeChangedSignal("VIP"):Connect(function()
			RefreshPlayer(object)
		end), object:GetAttributeChangedSignal(module.Shared.ChatTags.SelectionAttribute):Connect(function()
			RefreshPlayer(object)
		end) }
	RefreshLeaderboards()
end

function ChatTags.FormatMessage(p)
	if module.Data.Settings["Chat Tags"] == false or not p.TextSource then
		return
	end

	local v10 = v3[p.TextSource.UserId]

	if not v10 or v10 == "" then
		return
	end

	local textChatMessageProperties = Instance.new("TextChatMessageProperties")
	textChatMessageProperties.PrefixText = v10 .. " " .. p.PrefixText
	return textChatMessageProperties
end

function ChatTags.FormatWindowMessage(p)
	local newMessageProperties = chatWindowConfiguration:DeriveNewMessageProperties()

	if module.Data.Settings["Chat Tags"] == false or not p.TextSource then
		return newMessageProperties
	end

	local userId = p.TextSource.UserId
	local uniqueTag = module.Shared.ChatTags.UniqueTags[userId]
	local v10 = v3[userId]

	if not uniqueTag or not v10 or v10 == "" then
		return newMessageProperties
	end

	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
	newMessageProperties.PrefixTextProperties = chatWindowConfiguration:DeriveNewMessageProperties()
	uIGradient.Parent = newMessageProperties.PrefixTextProperties
	PaintUniqueTag(uIGradient, uniqueTag, v10, p.PrefixText or "", userId)
	return newMessageProperties
end

function ChatTags.Destroy()
	flag = false
	module.Services.TextChatService.OnIncomingMessage = nil
	module.Services.TextChatService.OnChatWindowAdded = nil

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)

	for k in v2 do
		RemovePlayer(k)
	end

	table.clear(v4)
	table.clear(v3)
end

function ChatTags.Init()
	if flag then
		return
	end

	flag = true
	v5 = module.Libs.DataContainerClient.New("Leaderboards")
	v.Leaderboards = v5:OnChange({}, RefreshLeaderboards)
	v.Added = module.Services.Players.PlayerAdded:Connect(AddPlayer)
	v.Removing = module.Services.Players.PlayerRemoving:Connect(RemovePlayer)

	for _, v10 in module.Services.Players:GetPlayers() do
		AddPlayer(v10)
	end

	module.Services.TextChatService.OnIncomingMessage = ChatTags.FormatMessage
	module.Services.TextChatService.OnChatWindowAdded = ChatTags.FormatWindowMessage
end

return ChatTags