local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local ClientState = require(ReplicatedStorage.ClientState)
local UiHelpers = require(script.Parent.UiHelpers)
local v = nil
local v2 = {}
local userId = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getModal()
	return UiHelpers.findTaggedInPlayerGui("TradingRequestModal")
end

local function clearButtons(buttons)
	for _, button in ipairs(buttons:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function respond(p: string)
	local v3 = userId
	userId = nil

	if v3 and v then
		v.respondRequest:fire(v3, p)
	end
end

local v3 = {
	OnClose = function(_)
		if flag then
			return
		end

		respond("Decline") -- equivalent call inferred; original call site unknown
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function wireModal(p)
	if v2[p] then
		return
	end

	v2[p] = true
	p.Visible = false
end

local function openForSender(data)
	local modal = getModal() -- equivalent call inferred; original call site unknown

	if not modal then
		warn("[TradingRequestModal] Modal not found")
		return
	end

	wireModal(modal) -- equivalent call inferred; original call site unknown
	userId = data.userId
	UiHelpers.fillAvatarFrame(modal.AvatarFrame, data.userId, data.displayName or data.name)
	local buttons = modal.Buttons
	clearButtons(buttons)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function closeAndRespond(p: string)
		flag = true
		respond(p) -- equivalent call inferred; original call site unknown

		if ClientState.ActiveModal == modal then
			ClientState:CloseCurrentModal()
		end

		flag = false
	end

	local modalButton = UiHelpers.createModalButton("NeutralButton", "Decline", buttons)
	local modalButton2 = UiHelpers.createModalButton("NegativeButton", "Block", buttons)
	local modalButton3 = UiHelpers.createModalButton("PositiveButton", "Accept", buttons)

	if not (modalButton and modalButton2 and modalButton3) then
		return
	end

	modalButton.LayoutOrder = 1
	modalButton2.LayoutOrder = 2
	modalButton3.LayoutOrder = 3
	modalButton.MouseButton1Down:Connect(function()
		closeAndRespond("Decline") -- equivalent call inferred; original call site unknown
	end)
	modalButton2.MouseButton1Down:Connect(function()
		closeAndRespond("Block") -- equivalent call inferred; original call site unknown
	end)
	modalButton3.MouseButton1Down:Connect(function()
		closeAndRespond("Accept") -- equivalent call inferred; original call site unknown
	end)

	if ClientState.ActiveModal ~= modal then
		ClientState:ToggleModal(modal, v3)
	end
end

return {
	bind = function(p)
		v = p

		for _, v4 in ipairs(CollectionService:GetTagged("TradingRequestModal")) do
			local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

			if not (playerGui and v4:IsDescendantOf(playerGui)) then
				continue
			end

			wireModal(v4) -- equivalent call inferred; original call site unknown
		end

		CollectionService:GetInstanceAddedSignal("TradingRequestModal"):Connect(function(instance)
			local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

			if playerGui and instance:IsDescendantOf(playerGui) then
				wireModal(instance) -- equivalent call inferred; original call site unknown
			end
		end)
		v.tradeRequest:connect(function(p2)
			openForSender(p2)
		end)
	end
}