local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PetRenderer = require(script.Parent:WaitForChild("PetRenderer"))
local Foods = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Foods"))
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local game2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local feedPet = game2:WaitForChild("FeedPet")
local petFed = game2:WaitForChild("PetFed")
local feed = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Prompts"):WaitForChild("Feed")
local eat = SoundService:WaitForChild("SFX"):WaitForChild("Game"):FindFirstChild("Eat")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function HeldFoodName()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool and tool:HasTag("Food") and Foods[tool.Name] then
		return tool.Name
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetPromptsEnabled(enabled)
	for _, v2 in pairs(v) do
		if v2.Parent then
			v2.Enabled = enabled
		end
	end
end

local function RefreshPrompts()
	local heldFoodName = HeldFoodName() -- equivalent call inferred; original call site unknown
	local v3 = heldFoodName and Foods[heldFoodName]
	local v4 = {}

	for _, v5 in pairs(PetRenderer.GetAll()) do
		if not (v5.OwnerUserId == localPlayer.UserId and v5.Model and v5.Model.Parent and v5.Model.PrimaryPart) then
			continue
		end

		v4[v5.PetKey] = true
		local clone = v[v5.PetKey]

		if not (clone and clone.Parent) then
			clone = feed:Clone()
			clone.Enabled = false
			clone.Parent = v5.Model.PrimaryPart
			v[v5.PetKey] = clone
			local petKey = v5.PetKey
			clone.Triggered:Connect(function()
				local heldFoodName2 = HeldFoodName() -- equivalent call inferred; original call site unknown

				if heldFoodName2 then
					feedPet:FireServer(petKey, heldFoodName2)
				end
			end)
		end

		clone.Enabled = heldFoodName ~= nil

		if v3 then
			clone.ObjectText = string.format("%s (+%s XP)", heldFoodName, String:AddComma(tonumber(v3.XP) or 0))
		end
	end

	for k, v5 in pairs(v) do
		if v4[k] then
			continue
		end

		v[k] = nil
		v5:Destroy()
	end
end

local function HookCharacter(character)
	character.ChildAdded:Connect(function()
		task.defer(RefreshPrompts)
	end)
	character.ChildRemoved:Connect(function()
		task.defer(RefreshPrompts)
	end)
	task.defer(RefreshPrompts)
end

localPlayer.CharacterAdded:Connect(HookCharacter)

if localPlayer.Character then
	HookCharacter(localPlayer.Character)
end

localPlayer.CharacterRemoving:Connect(function()
	SetPromptsEnabled(false) -- equivalent call inferred; original call site unknown
end)
task.spawn(function()
	while true do
		task.wait(0.5)
		RefreshPrompts()
	end
end)

local function PlayEatSound(model)
	if not (eat and model.PrimaryPart) then
		return
	end

	local pivot = model:GetPivot()
	local scale = model:GetScale()
	local v2

	if PetRenderer.TemplateScaleFor then
		v2 = PetRenderer.TemplateScaleFor(model.Name) or nil
	end

	local v3 = v2 and v2 > 0 and scale / v2 or 1
	local worldPosition = pivot.Position + pivot.UpVector * (4 * v3) + pivot.LookVector * (4.5 * v3)
	local attachment = Instance.new("Attachment")
	attachment.Name = "EatSound"
	attachment.Parent = model.PrimaryPart
	attachment.WorldPosition = worldPosition
	local clone = eat:Clone()
	clone.Parent = attachment
	clone:Play()
	clone.Ended:Once(function()
		attachment:Destroy()
	end)
	task.delay(math.max(clone.TimeLength, 1) + 2, function()
		if attachment.Parent then
			attachment:Destroy()
		end
	end)
end

petFed.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" or typeof(data.PetKey) ~= "string" then
		return
	end

	local owner = tonumber(data.Owner)

	if not owner then
		return
	end

	local v2 = PetRenderer.Get(owner, data.PetKey)

	if not (v2 and v2.Model and v2.Model.Parent) then
		return
	end

	local birthTime = tonumber(data.BirthTime)

	if birthTime then
		v2.BirthTime = birthTime
		local stateFrom = PetAging.StateFrom(birthTime, nil, v2)
		v2.Model:SetAttribute("Age", stateFrom)

		if tonumber(data.Weight) then
			v2.Model:SetAttribute("Weight", data.Weight)
		end
	end

	PlayEatSound(v2.Model)
end)