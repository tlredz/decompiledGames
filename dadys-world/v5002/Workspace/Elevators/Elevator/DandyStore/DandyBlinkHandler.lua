game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local dandyShop = script.Parent:WaitForChild("DandyShop")
dandyShop:WaitForChild("Config")
local headPart = dandyShop:WaitForChild("HeadPart")
local info = Workspace:WaitForChild("Info")
local noBuy = info:WaitForChild("DandyTracker"):WaitForChild("NoBuy")
local dandyStoreOpen = info:WaitForChild("DandyStoreOpen")
local v = 4
local v2 = 0
local v3 = 1
local normal = ""
local blink = ""
local v4 = {
	Stage1 = {
		Normal = "rbxassetid://104553710025363",
		Blink = "rbxassetid://81122020123978",
		Happy = "rbxassetid://121849818818365"
	},
	Stage2 = {
		Normal = "rbxassetid://114877934529176",
		Blink = "rbxassetid://100411793831395",
		Worried = "rbxassetid://16883352062"
	},
	Stage3 = {
		Normal = "rbxassetid://127475509382530",
		Blink = "rbxassetid://93431163867879"
	},
	Reset = "rbxassetid://90479718244700"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateStage()
	local value = noBuy.Value

	if value == 0 then
		v3 = 1
		normal = v4.Stage1.Normal
		blink = v4.Stage1.Blink
	elseif value == 1 then
		v3 = 2
		normal = v4.Stage2.Normal
		blink = v4.Stage2.Blink
	else
		v3 = 3
		normal = v4.Stage3.Normal
		blink = v4.Stage3.Blink
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHeadTexture()
	if headPart.Value and headPart.Value:IsA("MeshPart") then
		return headPart.Value
	end

	if dandyShop:FindFirstChild("Head") then
		return dandyShop.Head
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTexture(textureID)
	local headTexture = getHeadTexture() -- equivalent call inferred; original call site unknown

	if headTexture then
		headTexture.TextureID = textureID
	end
end

local function performBlink()
	if not dandyStoreOpen.Value then
		return
	end

	local headTexture = getHeadTexture() -- equivalent call inferred; original call site unknown

	if not headTexture then
		return
	end

	local textureID = headTexture.TextureID

	if textureID == v4.Stage1.Happy or textureID == v4.Stage2.Worried or textureID == v4.Reset then
		return
	end

	setTexture(blink) -- equivalent call inferred; original call site unknown
	task.wait(0.2)

	if dandyStoreOpen.Value then
		local headTexture2 = getHeadTexture() -- equivalent call inferred; original call site unknown

		if headTexture2 and headTexture2.TextureID == blink then
			setTexture(normal) -- equivalent call inferred; original call site unknown
		end
	end
end

updateStage() -- equivalent call inferred; original call site unknown
noBuy.Changed:Connect(updateStage)
task.spawn(function()
	while true do
		if dandyStoreOpen.Value then
			local now = tick()
			local v5 = now - v2

			if v <= v5 then
				v2 = now
				performBlink()
				v = math.random(3, 6)
			end
		end

		task.wait(0.5)
	end
end)