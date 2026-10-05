local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VisibleBounds = require(ReplicatedStorage.Shared.Utils.VisibleBounds)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local cash = ReplicatedStorage.Assets.Extra.Cash
assert(cash:IsA("BillboardGui"), "Assets.Extra.Cash must be a BillboardGui")

-- equivalent calls inferred from this helper; original call sites unknown
local function playOnce(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
end

local function scaleBillboardSize(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBillboardScale(vector: Vector3)
	local v = math.min(vector.X / 2, vector.Y / 5.72646427154541, vector.Z / 5.299603462219238)

	if v <= 0 then
		return 0.9
	end

	return (math.clamp(v, 0.9, 5))
end

local function fadeTextLabel(descendant, text: string, p, p2)
	descendant.Text = text
	descendant.TextTransparency = 1
	playOnce(descendant, p, {
		TextTransparency = 0
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.8499999999999999, function()
		if descendant.Parent then
			playOnce(descendant, p2, {
				TextTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function fadeTextButton(descendant, text: string, p, p2)
	descendant.Text = text
	descendant.TextTransparency = 1
	playOnce(descendant, p, {
		TextTransparency = 0
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.8499999999999999, function()
		if descendant.Parent then
			playOnce(descendant, p2, {
				TextTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function fadeTextBox(descendant, text: string, p, p2)
	descendant.Text = text
	descendant.TextTransparency = 1
	playOnce(descendant, p, {
		TextTransparency = 0
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.8499999999999999, function()
		if descendant.Parent then
			playOnce(descendant, p2, {
				TextTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function fadeImageObject(descendant, p, p2)
	descendant.ImageTransparency = 1
	playOnce(descendant, p, {
		ImageTransparency = 0
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.8499999999999999, function()
		if descendant.Parent then
			playOnce(descendant, p2, {
				ImageTransparency = 1
			}) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function fadePopupDescendants(folder, text: string, tweenInfo, tweenInfo2)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("TextLabel") then
			fadeTextLabel(descendant, text, tweenInfo, tweenInfo2)
		elseif descendant:IsA("TextButton") then
			fadeTextButton(descendant, text, tweenInfo, tweenInfo2)
		elseif descendant:IsA("TextBox") then
			fadeTextBox(descendant, text, tweenInfo, tweenInfo2)
		elseif descendant:IsA("UIStroke") then
			descendant.Transparency = 1
			playOnce(descendant, tweenInfo, {
				Transparency = 0
			}) -- equivalent call inferred; original call site unknown
			local v = descendant
			task.delay(0.8499999999999999, function()
				if v.Parent then
					playOnce(v, tweenInfo2, {
						Transparency = 1
					}) -- equivalent call inferred; original call site unknown
				end
			end)
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			fadeImageObject(descendant, tweenInfo, tweenInfo2)
		end
	end
end

local function showAtCFrame(worldCFrame: CFrame, p: number, p2, p3: number, p4: number)
	local attachment = Instance.new("Attachment")
	attachment.Name = "SyncedIncomeCashAttachment"
	attachment.WorldCFrame = worldCFrame
	attachment.Parent = workspace.Terrain
	local clone = cash:Clone()
	clone.Name = "SyncedIncomeCash"
	clone.Adornee = attachment
	clone.Parent = attachment
	clone.AlwaysOnTop = not p2 or p2.alwaysOnTop == nil or p2.alwaysOnTop
	local size = clone.Size
	clone.Size = UDim2.new(size.X.Scale * p4, size.X.Offset * p4, size.Y.Scale * p4, size.Y.Offset * p4)
	fadePopupDescendants(
		clone,
		`+${Simple.FormatCompact((math.round(p)))}`,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	)
	playOnce(attachment, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		WorldPosition = worldCFrame.Position + Vector3.new(0, p3, 0)
	}) -- equivalent call inferred; original call site unknown
	Debris:AddItem(clone, 1.4)
	Debris:AddItem(attachment, 1.4)
end

return {
	Show = function(p, p2: number, p3)
		local v, v2 = VisibleBounds(p)
		local worldCFrame = v - Vector3.new(0, v2.Y / 1.5, 0)
		local v4 = assert(workspace.CurrentCamera, "Active asset income popup requires Workspace.CurrentCamera")
		local maxDistance = cash.MaxDistance

		if maxDistance > 0 and maxDistance < (v4.CFrame.Position - worldCFrame.Position).Magnitude then
			return
		end

		showAtCFrame(worldCFrame, p2, p3, v2.Y - v2.Y * 0.25, getBillboardScale(v2))
	end
}