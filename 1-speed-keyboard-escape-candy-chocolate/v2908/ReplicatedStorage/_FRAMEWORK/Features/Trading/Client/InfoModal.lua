local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local ClientState = require(ReplicatedStorage.ClientState)
local UiHelpers = require(script.Parent.UiHelpers)
require(script.Parent.Parent.Types)
local v = nil
local v2 = {}
local defaultCallback = nil
local flag = false
local InfoModal = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getModal()
	return UiHelpers.findTaggedInPlayerGui("TradingInfoModal")
end

local function clearButtons(buttons)
	for _, button in ipairs(buttons:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end
end

local v3 = {
	OnClose = function(_)
		if flag then
			return
		end

		local v4 = defaultCallback
		defaultCallback = nil

		if v4 then
			v4()
		end
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

function InfoModal.open(data)
	local modal = getModal() -- equivalent call inferred; original call site unknown

	if not modal then
		warn("[TradingInfoModal] Modal not found")
		return
	end

	wireModal(modal) -- equivalent call inferred; original call site unknown
	modal.Title.Text = data.title or ""
	modal.Desc.TextLabel.Text = data.description or ""
	local buttons = modal.Buttons
	clearButtons(buttons)
	defaultCallback = data.defaultCallback
	local buttons2 = data.buttons or {
		{
			text = "Ok",
			style = "Neutral"
		}
	}

	for _, button in ipairs(buttons2) do
		local modalButton = UiHelpers.createModalButton(UiHelpers.styleToTemplate(button.style), button.text, buttons)

		if not modalButton then
			continue
		end

		local v4 = button
		modalButton.MouseButton1Down:Connect(function()
			flag = true
			defaultCallback = nil

			if ClientState.ActiveModal == modal then
				ClientState:CloseCurrentModal()
			end

			flag = false

			if v4.callback then
				v4.callback()
			end
		end)
	end

	if ClientState.ActiveModal ~= modal then
		ClientState:ToggleModal(modal, v3)
	end
end

function InfoModal.bind(p)
	v = p

	for _, v4 in ipairs(CollectionService:GetTagged("TradingInfoModal")) do
		local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

		if not (playerGui and v4:IsDescendantOf(playerGui)) then
			continue
		end

		wireModal(v4) -- equivalent call inferred; original call site unknown
	end

	CollectionService:GetInstanceAddedSignal("TradingInfoModal"):Connect(function(instance)
		local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")

		if playerGui and instance:IsDescendantOf(playerGui) then
			wireModal(instance) -- equivalent call inferred; original call site unknown
		end
	end)
	v.showInfo:connect(function(data)
		InfoModal.open({
			title = data.title,
			description = data.description,
			buttons = {
				{
					text = data.confirmText or "Ok",
					style = data.buttonStyle or "Neutral"
				}
			}
		})
	end)
end

return InfoModal