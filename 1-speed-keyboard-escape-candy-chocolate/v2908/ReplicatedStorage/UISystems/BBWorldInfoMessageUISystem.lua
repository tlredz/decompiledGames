local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local AutoOpenModalConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("AutoOpenModalConfig"))
local AutoOpenModalSystem = require(script.Parent:WaitForChild("AutoOpenModalSystem"))
local BBWorldInfoMessageUISystem = {}
local bBWorldInfo = AutoOpenModalConfig.Ids.BBWorldInfo
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v = {}

local function wireOkButton(p)
	if not v[p] then
		v[p] = true
		p.Visible = false
		p.OkButton.MouseButton1Down:Connect(function()
			if ClientState.ActiveModal == p then
				ClientState:CloseCurrentModal()
			end
		end)
	end
end

function BBWorldInfoMessageUISystem:Init()
	for _, v2 in ipairs(CollectionService:GetTagged("BBWorldInfoMessage")) do
		if not v2:IsDescendantOf(playerGui) or v[v2] then
			continue
		end

		v[v2] = true
		v2.Visible = false
		local v3 = v2
		v2.OkButton.MouseButton1Down:Connect(function()
			if ClientState.ActiveModal == v3 then
				ClientState:CloseCurrentModal()
			end
		end)
	end

	CollectionService:GetInstanceAddedSignal("BBWorldInfoMessage"):Connect(function(instance)
		if instance:IsDescendantOf(playerGui) and not v[instance] then
			v[instance] = true
			instance.Visible = false
			instance.OkButton.MouseButton1Down:Connect(function()
				if ClientState.ActiveModal == instance then
					ClientState:CloseCurrentModal()
				end
			end)
		end
	end)
	AutoOpenModalSystem.Bind(bBWorldInfo, BBWorldInfoMessageUISystem)
end

BBWorldInfoMessageUISystem:Init()
return BBWorldInfoMessageUISystem