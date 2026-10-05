local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseViewCameraCategoryButton"
})
local HouseViewCamera = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseViewCamera)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local bounce = Enum.EasingStyle.Bounce

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.houseViewCamera = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"HouseViewCamera",
		HouseViewCamera
	)

	if not self.houseViewCamera then
		return
	end

	local backgroundCover = self.Instance:FindFirstChild("BackgroundCover") or self.Instance:FindFirstChild("backgroundCover") or self.Instance.Parent
	local name = self.Instance.Parent and self.Instance.Parent.Name or self.Instance.Name

	if not backgroundCover then
		return
	end

	local size = backgroundCover.Size
	local uIScale = backgroundCover:FindFirstChildOfClass("UIScale")
	local scale = not uIScale and 1 or uIScale.Scale or 1
	local tweenInfo = TweenInfo.new(0.5, bounce, Enum.EasingDirection.Out)

	if not uIScale then
		backgroundCover.AnchorPoint = Vector2.new(0.5, 0.5)
		local uDim = UDim2.new(size.X.Scale / 2, size.X.Offset / 2, size.Y.Scale / 2, size.Y.Offset / 2)
		backgroundCover.Position += uDim
	end

	local function getHighlightSize()
		return UDim2.new(size.X.Scale * 1.25, size.X.Offset * 1.25, size.Y.Scale * 1.25, size.Y.Offset * 1.25)
	end

	local function updateHighlight()
		if self.houseViewCamera:GetCurrentIndexCategory() == name then
			if uIScale then
				TweenService:Create(uIScale, tweenInfo, {
					Scale = scale * 1.25
				}):Play()
			else
				TweenService:Create(backgroundCover, tweenInfo, {
					Size = UDim2.new(
						size.X.Scale * 1.25,
						size.X.Offset * 1.25,
						size.Y.Scale * 1.25,
						size.Y.Offset * 1.25
					)
				}):Play()
			end

			local greenCheckMark = self.Instance.Parent:FindFirstChild("GreenCheckMark")

			if greenCheckMark then
				greenCheckMark.Visible = true
			end
		else
			if uIScale then
				TweenService:Create(uIScale, tweenInfo, {
					Scale = scale
				}):Play()
			else
				TweenService:Create(backgroundCover, tweenInfo, {
					Size = size
				}):Play()
			end

			local greenCheckMark = self.Instance.Parent:FindFirstChild("GreenCheckMark")

			if greenCheckMark then
				greenCheckMark.Visible = false
			end
		end
	end

	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		self.houseViewCamera:SetLastCategoryButtonClicked(name)
		self.houseViewCamera:JumpToCategory(name)
	end))
	self._Janitor:Add(self.houseViewCamera.OnCameraIndexChanged:Connect(function()
		updateHighlight()
	end))
	updateHighlight()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v