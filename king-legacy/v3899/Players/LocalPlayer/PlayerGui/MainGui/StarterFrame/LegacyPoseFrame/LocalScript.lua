local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent

function UpdateGhostShipText()
	local ghostShipSpawnText = ReplicatedStorage:GetAttribute("GhostShipSpawnText")

	if not ghostShipSpawnText then
		return
	end

	parent.SecondSea.GSTimeLabel.Text = ghostShipSpawnText
end

function UpdateSeaMonsterText()
	if ReplicatedStorage:GetAttribute("Hydra") then
		parent.SecondSea.HDImage.Visible = true
		parent.SecondSea.SKImage.Visible = false
	else
		parent.SecondSea.HDImage.Visible = false
		parent.SecondSea.SKImage.Visible = true
	end

	local seaMonsterSpawnText = ReplicatedStorage:GetAttribute("SeaMonsterSpawnText")

	if not seaMonsterSpawnText then
		return
	end

	parent.SecondSea.SKTimeLabel.Text = seaMonsterSpawnText
end

function UpdateThirdSeaMosnterText()
	local thirdSeaMonsterSpawnText = ReplicatedStorage:GetAttribute("ThirdSeaMonsterSpawnText")

	if not thirdSeaMonsterSpawnText then
		return
	end

	parent.ThirdSea.TextLabel.Text = thirdSeaMonsterSpawnText
end

UpdateGhostShipText()
UpdateSeaMonsterText()
UpdateThirdSeaMosnterText()
ReplicatedStorage:GetAttributeChangedSignal("GhostShipSpawnText"):Connect(UpdateGhostShipText)
ReplicatedStorage:GetAttributeChangedSignal("SeaMonsterSpawnText"):Connect(UpdateSeaMonsterText)
ReplicatedStorage:GetAttributeChangedSignal("Hydra"):Connect(UpdateSeaMonsterText)
ReplicatedStorage:GetAttributeChangedSignal("ThirdSeaMonsterSpawnText"):Connect(UpdateThirdSeaMosnterText)