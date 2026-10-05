local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local InfoModalUISystem = {}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {}
local v2 = nil

local function getModal()
	for _, guiObject in ipairs(CollectionService:GetTagged("InfoModal")) do
		if guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui) then
			return guiObject
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wireModal(modal)
	if not v[modal] then
		v[modal] = true
		modal.Visible = false
		modal.Container.Buttons.OkButton.MouseButton1Down:Connect(function()
			if ClientState.ActiveModal == modal then
				ClientState:CloseCurrentModal()
			end
		end)
	end
end

local size = nil

function InfoModalUISystem.Open(_, text: string, text2: string, udim: UDim2?, callback)
	local modal = getModal()

	if not modal then
		warn("[InfoModalUISystem] Modal tag 'InfoModal' not found in PlayerGui")
		return
	end

	wireModal(modal) -- equivalent call inferred; original call site unknown

	if not size then
		size = modal.Container.Size
	end

	modal.Container.Size = udim or size
	modal.Container.Title.Text = text
	local desc = modal.Container.Desc.Desc
	desc.RichText = true
	desc.Text = text2
	v2 = callback

	if ClientState.ActiveModal ~= modal then
		ClientState:ToggleModal(modal, InfoModalUISystem)
	end
end

function InfoModalUISystem.OnClose(_)
	local v3 = v2
	v2 = nil

	if v3 then
		v3()
	end
end

function InfoModalUISystem:Init()
	for _, v3 in ipairs(CollectionService:GetTagged("InfoModal")) do
		if not v3:IsDescendantOf(playerGui) or v[v3] then
			continue
		end

		v[v3] = true
		v3.Visible = false
		local v4 = v3
		v3.Container.Buttons.OkButton.MouseButton1Down:Connect(function()
			if ClientState.ActiveModal == v4 then
				ClientState:CloseCurrentModal()
			end
		end)
	end

	CollectionService:GetInstanceAddedSignal("InfoModal"):Connect(function(instance)
		if instance:IsDescendantOf(playerGui) and not v[instance] then
			v[instance] = true
			instance.Visible = false
			instance.Container.Buttons.OkButton.MouseButton1Down:Connect(function()
				if ClientState.ActiveModal == instance then
					ClientState:CloseCurrentModal()
				end
			end)
		end
	end)
end

InfoModalUISystem:Init()
return InfoModalUISystem