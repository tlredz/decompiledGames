local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")

-- equivalent calls inferred from this helper; original call sites unknown
local function currentName()
	local currentSoundtrackName = adminAbuse:GetAttribute("CurrentSoundtrackName")
	return type(currentSoundtrackName) == "string" and currentSoundtrackName or ""
end

local function refreshAll()
	local text = currentName() -- equivalent call inferred; original call site unknown

	for _, label in CollectionService:GetTagged("MusicViewer") do
		if label:IsA("TextLabel") then
			label.Text = text
		end
	end
end

CollectionService:GetInstanceAddedSignal("MusicViewer"):Connect(function(label)
	if label:IsA("TextLabel") then
		label.Text = currentName()
	end
end)
adminAbuse:GetAttributeChangedSignal("CurrentSoundtrackName"):Connect(refreshAll)
refreshAll()