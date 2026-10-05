local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local v = Component.new({
	Tag = "CurrentlyWearingScroller"
})
require(ReplicatedStorage.Modules.Client.Util.Platform)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local wearing = {}
local assets = {}
local v2 = {
	[8] = true,
	[41] = true,
	[42] = true,
	[43] = true,
	[44] = true,
	[45] = true,
	[46] = true,
	[47] = true,
	[65] = true,
	[79] = true,
	[64] = true,
	[66] = true,
	[67] = true,
	[68] = true,
	[69] = true,
	[70] = true,
	[71] = true,
	[72] = true,
	[11] = true,
	[12] = true,
	[13] = true
}
local v3 = {
	[27] = true,
	[28] = true,
	[29] = true,
	[30] = true,
	[31] = true,
	[2] = true,
	[78] = true,
	[48] = true,
	[50] = true,
	[51] = true,
	[52] = true,
	[53] = true,
	[54] = true,
	[55] = true
}
local v4 = {
	[27] = true,
	[28] = true,
	[29] = true,
	[30] = true,
	[31] = true
}
local v5 = {
	[27] = 1,
	[28] = 2,
	[29] = 3,
	[30] = 4,
	[31] = 5
}
local v6 = {
	[48] = true,
	[50] = true,
	[51] = true,
	[52] = true,
	[53] = true,
	[54] = true,
	[55] = true
}
local v7 = {
	[48] = "Climb Animation",
	[50] = "Fall Animation",
	[51] = "Idle Animation",
	[52] = "Jump Animation",
	[53] = "Run Animation",
	[54] = "Swim Animation",
	[55] = "Walk Animation"
}
local v8 = {
	Enum.AssetType.Hat.Value,
	Enum.AssetType.TShirtAccessory.Value,
	Enum.AssetType.PantsAccessory.Value,
	Enum.AssetType.LeftShoeAccessory.Value,
	Enum.AssetType.RightShoeAccessory.Value,
	Enum.AssetType.DressSkirtAccessory.Value,
	Enum.AssetType.SweaterAccessory.Value,
	Enum.AssetType.BackAccessory.Value,
	Enum.AssetType.WaistAccessory.Value,
	Enum.AssetType.JacketAccessory.Value,
	Enum.AssetType.ShirtAccessory.Value,
	Enum.AssetType.ShortsAccessory.Value,
	Enum.AssetType.EarAccessory.Value,
	Enum.AssetType.EyeAccessory.Value,
	Enum.AssetType.EyebrowAccessory.Value,
	Enum.AssetType.EyelashAccessory.Value,
	Enum.AssetType.FrontAccessory.Value,
	Enum.AssetType.ShoulderAccessory.Value,
	Enum.AssetType.NeckAccessory.Value
}

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function isAnimationAsset(p: number)
	return v6[p] == true
end

local function isBodyPartAsset(p: number)
	return v4[p] == true
end

function v:SortWearingWithAnimationsLast(options)
	if not options or #options == 0 then
		return options or {}
	end

	local options2 = {}
	local options3 = {}
	local result = {}

	for _, option in options do
		local id = option.assetType.id

		if v6[id] == true then
			table.insert(options2, option)
		elseif v4[id] == true then
			table.insert(options3, option)
		else
			table.insert(result, option)
		end
	end

	table.sort(options3, function(a, b)
		return (v5[a.assetType.id] or 0) < (v5[b.assetType.id] or 0)
	end)

	for _, v9 in options3 do
		table.insert(result, v9)
	end

	for _, v9 in options2 do
		table.insert(result, v9)
	end

	return result
end

function v:GetWearing(items)
	if not items then
		return
	end

	local isAvatarEditorReworkEnabled = self._isAvatarEditorReworkEnabled == true
	local v9 = {}

	for _, item in items do
		local id = item.assetType.id

		if v2[id] or v3[id] and isAvatarEditorReworkEnabled then
			table.insert(v9, item)
		end
	end

	return self:SortWearingWithAnimationsLast(v9)
end

function v:ShouldShowReorderButton()
	if not ABTest.GetExperimentVariable("avatar-editor-improvements", "has-new-content"):expect() then
		return false
	end

	local count = 0

	for _, v9 in wearing do
		if not table.find(v8, v9.assetType.id) then
			continue
		end

		count += 1

		if count > 1 then
			return true
		end
	end

	return false
end

function v:BuildReorderingScroller(items)
	self.reorderButton:AddTag("Checked")
	self.reorderFrameToItemMap = {}
	self.tempServerSidedAccessoryStorage = {}

	if Platform.IsMobile() then
		self.reorderTemplateItem.Size = self.reorderingScroller:GetAttribute("ItemSize_Mobile")
	else
		self.reorderTemplateItem.Size = self.reorderingScroller:GetAttribute("ItemSize_NonMobile")
	end

	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local humanoidDescription = humanoid and humanoid:FindFirstChild("HumanoidDescription")
	local count = 0
	local v9 = nil

	local function UpdateItemArrowUIs(instance)
		local dragContainer = instance:WaitForChild("DragContainer")

		if v9 == instance then
			dragContainer.MoveLeft.Visible = true
			dragContainer.MoveRight.Visible = true

			if instance.LayoutOrder == 1 then
				dragContainer.MoveLeft.Visible = false
			elseif instance.LayoutOrder == count then
				dragContainer.MoveRight.Visible = false
			end
		else
			dragContainer.MoveLeft.Visible = false
			dragContainer.MoveRight.Visible = false
		end
	end

	for _, item in items do
		if not (item.id ~= "0" and table.find(v8, item.assetType.id)) then
			continue
		end

		count += 1
		local layoutOrder2 = count
		local clone = self.reorderTemplateItem:Clone()
		local dragContainer = clone:WaitForChild("DragContainer")
		local uIDragDetector = dragContainer:WaitForChild("UIDragDetector")
		clone.LayoutOrder = layoutOrder2
		clone.Name = tostring(layoutOrder2)
		self.reorderFrameToItemMap[clone] = item
		dragContainer.ItemFrame.Footer.Ordering.Text = tostring(layoutOrder2)
		dragContainer.ItemFrame.ItemImage.Image = `rbxthumb://type=Asset&id={item.id}&w=150&h=150`
		clone.Parent = self.reorderingScroller
		TweenService:Create(dragContainer.ItemFrame, TweenInfo.new(0.01), {
			BackgroundColor3 = Color3.new(0.75, 0.75, 0.75),
			Size = UDim2.new(0.65, 0, 0.65, 0)
		}):Play()
		local dragContainer2 = clone:WaitForChild("DragContainer")

		if v9 == clone then
			dragContainer2.MoveLeft.Visible = true
			dragContainer2.MoveRight.Visible = true

			if clone.LayoutOrder == 1 then
				dragContainer2.MoveLeft.Visible = false
			elseif clone.LayoutOrder == count then
				dragContainer2.MoveRight.Visible = false
			end
		else
			dragContainer2.MoveLeft.Visible = false
			dragContainer2.MoveRight.Visible = false
		end

		dragContainer.MoveLeft.Size = UDim2.new(0, 0, 0, 0)
		dragContainer.MoveRight.Size = UDim2.new(0, 0, 0, 0)
		local flag = false

		local function ReapplyAccessoriesFromHumDesc()
			if not (character and humanoid and humanoidDescription) then
				error("No character, humanoid, or humanoid description found in ReapplyAccessoriesFromHumDesc")
			end

			humanoidDescription:SetAccessories(humanoidDescription:GetAccessories(true), true)
			flag = false
			local humanoidModelFromDescription = Players:CreateHumanoidModelFromDescription(
				humanoidDescription,
				Enum.HumanoidRigType.R15,
				Enum.AssetTypeVerification.ClientOnly
			)

			for _, accessory in humanoidModelFromDescription:GetChildren() do
				if not accessory:IsA("Accessory") then
					continue
				end

				local accessoryWeld = accessory:FindFirstChild("AccessoryWeld", true)
				accessory.Parent = nil

				if accessoryWeld and accessoryWeld.Part1 then
					local child = character:FindFirstChild(accessoryWeld.Part1.Name)

					if child then
						accessoryWeld.Part1 = child
						CollectionService:AddTag(accessory, "AVATAR_EDITOR_TEMP_GENERATED_ACCESSORY")
						local child2 = character:FindFirstChild(accessory.Name)

						if child2 and not child2:HasTag("AVATAR_EDITOR_TEMP_GENERATED_ACCESSORY") then
							self.tempServerSidedAccessoryStorage[accessory] = child2
							child2.Parent = nil
						elseif child2 and self.tempServerSidedAccessoryStorage[child2] then
							self.tempServerSidedAccessoryStorage[accessory] = self.tempServerSidedAccessoryStorage[child2]
							self.tempServerSidedAccessoryStorage[child2] = nil
							Debris:AddItem(child2, 0)
						end

						humanoid:AddAccessory(accessory)
					else
						Debris:AddItem(accessory, 0)
					end
				else
					Debris:AddItem(accessory, 0)
				end
			end

			Debris:AddItem(humanoidModelFromDescription, 0)
		end

		local v11 = 0
		local v14 = item

		local function Reorder(p: number, flag2: boolean?)
			local layoutOrder = clone.LayoutOrder
			local v15 = layoutOrder + p
			local layoutOrder3

			if v15 < 1 then
				layoutOrder3 = count
			else
				layoutOrder3 = count < v15 and 1 or v15
			end

			local child = self.reorderingScroller:FindFirstChild(layoutOrder3)
			local absolutePosition = child.DragContainer.AbsolutePosition
			local absolutePosition2 = dragContainer.AbsolutePosition
			child.LayoutOrder = layoutOrder
			clone.LayoutOrder = layoutOrder3
			child.Name = tostring(child.LayoutOrder)
			clone.Name = tostring(clone.LayoutOrder)
			dragContainer.ItemFrame.Footer.Ordering.Text = tostring(clone.LayoutOrder)
			local dragContainer = child:WaitForChild("DragContainer")
			dragContainer.ItemFrame.Footer.Ordering.Text = tostring(child.LayoutOrder)
			local dragContainer3 = child:WaitForChild("DragContainer")

			if v9 == child then
				dragContainer3.MoveLeft.Visible = true
				dragContainer3.MoveRight.Visible = true

				if child.LayoutOrder == 1 then
					dragContainer3.MoveLeft.Visible = false
				elseif child.LayoutOrder == count then
					dragContainer3.MoveRight.Visible = false
				end
			else
				dragContainer3.MoveLeft.Visible = false
				dragContainer3.MoveRight.Visible = false
			end

			local v17 = clone
			local dragContainer4 = v17:WaitForChild("DragContainer")

			if v9 == v17 then
				dragContainer4.MoveLeft.Visible = true
				dragContainer4.MoveRight.Visible = true

				if v17.LayoutOrder == 1 then
					dragContainer4.MoveLeft.Visible = false
				elseif v17.LayoutOrder == count then
					dragContainer4.MoveRight.Visible = false
				end
			else
				dragContainer4.MoveLeft.Visible = false
				dragContainer4.MoveRight.Visible = false
			end

			child.DragContainer.Position = UDim2.new(
				0,
				absolutePosition.X - child.DragContainer.AbsolutePosition.X,
				0,
				absolutePosition.Y - child.DragContainer.AbsolutePosition.Y
			)
			TweenService:Create(
				child.DragContainer,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Position = UDim2.new(0, 0, 0, 0)
				}
			):Play()
			local tween = TweenService:Create(
				child.DragContainer,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Rotation = -math.sign(-(child.DragContainer.AbsolutePosition.X - absolutePosition.X)) * 10,
					Size = UDim2.new(1.1, 0, 1.1, 0)
				}
			)
			tween.Completed:Once(function(p2)
				if p2 == Enum.PlaybackState.Completed then
					TweenService:Create(
						child.DragContainer,
						TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Rotation = 0,
							Size = UDim2.new(1, 0, 1, 0)
						}
					):Play()
				end
			end)
			tween:Play()

			if flag2 then
				dragContainer.Position = UDim2.new(
					0,
					absolutePosition2.X - dragContainer.AbsolutePosition.X,
					0,
					absolutePosition2.Y - dragContainer.AbsolutePosition.Y
				)
				TweenService:Create(
					dragContainer,
					TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0, 0, 0, 0)
					}
				):Play()
				local tween2 = TweenService:Create(
					dragContainer,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Rotation = math.sign(-(child.DragContainer.AbsolutePosition.X - absolutePosition.X)) * 10,
						Size = UDim2.new(1.1, 0, 1.1, 0)
					}
				)
				tween2.Completed:Once(function(p2)
					if p2 == Enum.PlaybackState.Completed then
						TweenService:Create(
							dragContainer,
							TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Rotation = 0,
								Size = UDim2.new(1, 0, 1, 0)
							}
						):Play()
					end
				end)
				tween2:Play()
			end

			local v18 = self.reorderFrameToItemMap[child]

			if character and humanoidDescription and v18 then
				local accessories = humanoidDescription:GetAccessories(true)
				local v19 = nil
				local v20 = nil

				for k, accessory in accessories do
					if not accessory.IsLayered then
						continue
					end

					if tostring(accessory.AssetId) == tostring(v18.id) then
						v19 = k
					elseif tostring(accessory.AssetId) == tostring(v14.id) then
						v20 = k
					end
				end

				if v19 and v20 then
					local order = accessories[v19].Order
					accessories[v19].Order = accessories[v20].Order
					accessories[v20].Order = order
					humanoidDescription:SetAccessories(accessories, true)
					flag = true
				end
			end
		end

		local v15 = clone
		local v16 = dragContainer
		self._clickJanitor:Add(dragContainer.ItemFrame.MouseEnter:Connect(function()
			if v9 ~= v15 then
				TweenService:Create(
					v16.ItemFrame,
					TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						BackgroundColor3 = Color3.new(0.8, 0.8, 0.8),
						Size = UDim2.new(0.7, 0, 0.7, 0)
					}
				):Play()
			end
		end))
		local v17 = clone
		local v18 = dragContainer
		self._clickJanitor:Add(dragContainer.ItemFrame.MouseLeave:Connect(function()
			if v9 ~= v17 then
				TweenService:Create(
					v18.ItemFrame,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						BackgroundColor3 = Color3.new(0.75, 0.75, 0.75),
						Size = UDim2.new(0.65, 0, 0.65, 0)
					}
				):Play()
			end
		end))
		local X = 0
		local X2 = 0
		local v19 = clone
		local v20 = dragContainer
		self._clickJanitor:Add(uIDragDetector.DragStart:Connect(function(p)
			if v9 and v9 ~= v19 then
				TweenService:Create(
					v9.DragContainer.ItemFrame,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						BackgroundColor3 = Color3.new(0.75, 0.75, 0.75),
						Size = UDim2.new(0.65, 0, 0.65, 0)
					}
				):Play()
				v9.DragContainer.MoveLeft.Visible = false
				v9.DragContainer.MoveRight.Visible = false
			end

			if v9 ~= v19 then
				v9 = v19
				local v21 = v19
				local dragContainer3 = v21:WaitForChild("DragContainer")

				if v9 == v21 then
					dragContainer3.MoveLeft.Visible = true
					dragContainer3.MoveRight.Visible = true

					if v21.LayoutOrder == 1 then
						dragContainer3.MoveLeft.Visible = false
					elseif v21.LayoutOrder == count then
						dragContainer3.MoveRight.Visible = false
					end
				else
					dragContainer3.MoveLeft.Visible = false
					dragContainer3.MoveRight.Visible = false
				end

				if v20.MoveLeft.Visible then
					v20.MoveLeft.Size = UDim2.new(0, 0, 0, 0)
				end

				if v20.MoveRight.Visible then
					v20.MoveRight.Size = UDim2.new(0, 0, 0, 0)
				end
			end

			TweenService:Create(v20.MoveLeft, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.2, 0, 0.2, 0),
				ImageColor3 = Color3.new(1, 1, 0.5)
			}):Play()
			TweenService:Create(v20.MoveRight, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.2, 0, 0.2, 0),
				ImageColor3 = Color3.new(1, 1, 0.5)
			}):Play()
			TweenService:Create(v20.ItemFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(0.8, 0, 0.8, 0)
			}):Play()
			X = p.X
			X2 = p.X
		end))
		local v21 = nil
		local lastTime = tick()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateMouseXVelocity(p)
			local v22 = v11
			local v23 = math.clamp((tick() - lastTime) * 16, 0, 1)
			v11 = v22 + (0 - v22) * v23
			lastTime = tick()
			v11 += (p.X - X2) / workspace.CurrentCamera.ViewportSize.X * 25
		end

		local v22 = clone
		local v23 = dragContainer
		local ReapplyAccessoriesFromHumDesc2 = ReapplyAccessoriesFromHumDesc
		self._clickJanitor:Add(uIDragDetector.DragEnd:Connect(function(p)
			UpdateMouseXVelocity(p) -- equivalent call inferred; original call site unknown

			if v9 == v22 then
				TweenService:Create(
					v23.MoveLeft,
					TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(0.25, 0, 0.25, 0),
						ImageColor3 = Color3.new(1, 1, 0)
					}
				):Play()
				TweenService:Create(
					v23.MoveRight,
					TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(0.25, 0, 0.25, 0),
						ImageColor3 = Color3.new(1, 1, 0)
					}
				):Play()
				TweenService:Create(
					v23.ItemFrame,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						BackgroundColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(0.75, 0, 0.75, 0)
					}
				):Play()
				local v25 = math.abs(uIDragDetector.DragUDim2.X.Offset) / (workspace.CurrentCamera.ViewportSize.X / 2) * 3.5
				local v26 = math.clamp(math.abs(v11) * 5, 1, 100)

				if math.sign(v11) ~= -math.sign(uIDragDetector.DragUDim2.X.Offset) then
					if v23.AbsolutePosition.X + v23.AbsoluteSize.X < self.reorderingScroller.AbsolutePosition.X + self.reorderingScroller.AbsoluteSize.X and v26 > 10 then
						local tween = TweenService:Create(
							v23,
							TweenInfo.new(
								math.clamp(0.5 / v26, 0.1, 1),
								Enum.EasingStyle.Linear,
								Enum.EasingDirection.InOut
							),
							{
								Position = UDim2.new(
									0,
									v23.Position.X.Offset + (self.reorderingScroller.AbsolutePosition.X + self.reorderingScroller.AbsoluteSize.X - v23.AbsolutePosition.X) - v23.AbsoluteSize.X,
									0,
									0
								)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v26 = 2.5
					else
						v26 = 2.5
					end
				end

				local v27 = math.clamp(1 / v26, 0.1, 1)
				v21 = TweenService:Create(v23, TweenInfo.new(v27, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, 0, 0, 0)
				})
				local v28 = v21
				task.delay(v27 * 0.3236, function()
					if v21 == v28 and v21.PlaybackState == Enum.PlaybackState.Playing then
						local child = self.reorderingScroller:FindFirstChild(v22.LayoutOrder + math.sign(-uIDragDetector.DragUDim2.X.Offset))

						if child and child:FindFirstChild("DragContainer") then
							TweenService:Create(
								child.DragContainer,
								TweenInfo.new(0.125, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									Position = UDim2.new(
										0,
										math.sign(-uIDragDetector.DragUDim2.X.Offset) * (child.AbsoluteSize.X * 0.025 * ((v26 - 0.75) * 2)),
										0,
										0
									)
								}
							):Play()
							local tween = TweenService:Create(
								child.DragContainer,
								TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
								{
									Rotation = math.sign(-uIDragDetector.DragUDim2.X.Offset) * ((v26 - 0.75) * 2),
									Size = UDim2.new((v26 - 1) * 0.025 + 1, 0, (v26 - 1) * 0.025 + 1, 0)
								}
							)
							tween.Completed:Once(function(p2)
								if p2 == Enum.PlaybackState.Completed then
									TweenService:Create(
										child.DragContainer,
										TweenInfo.new(1.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
										{
											Rotation = 0,
											Size = UDim2.new(1, 0, 1, 0),
											Position = UDim2.new(0, 0, 0, 0)
										}
									):Play()
								end
							end)
							tween:Play()
							task.wait(0.125)

							if child and child:FindFirstChild("DragContainer") then
								TweenService:Create(
									child.DragContainer,
									TweenInfo.new(1.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
									{
										Position = UDim2.new(0, 0, 0, 0)
									}
								):Play()
							end
						end
					end
				end)
				v21:Play()

				if flag then
					task.defer(ReapplyAccessoriesFromHumDesc2)
				end
			end

			v11 = 0
		end))
		local v25 = clone
		local Reorder2 = Reorder
		local v26 = dragContainer
		self._clickJanitor:Add(uIDragDetector.DragContinue:Connect(function(p)
			local absolutePosition = self.reorderingScroller.AbsolutePosition
			local absoluteSize = self.reorderingScroller.AbsoluteSize
			local v27 = p.X < absolutePosition.X + 30
			local v28 = p.X > absolutePosition.X + absoluteSize.X - 30

			if v27 then
				self.reorderingScroller.CanvasPosition = Vector2.new(
					self.reorderingScroller.CanvasPosition.X - 10,
					self.reorderingScroller.CanvasPosition.Y
				)
			elseif v28 then
				self.reorderingScroller.CanvasPosition = Vector2.new(
					self.reorderingScroller.CanvasPosition.X + 10,
					self.reorderingScroller.CanvasPosition.Y
				)
			end

			UpdateMouseXVelocity(p) -- equivalent call inferred; original call site unknown
			X2 = p.X

			if v25.LayoutOrder < count and p.X > v25.AbsolutePosition.X + v25.AbsoluteSize.X then
				Reorder2(1)
				X += v25.AbsoluteSize.X
				local tween = TweenService:Create(
					v26,
					TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0, 0, 0, 0)
					}
				)
				tween:Play()
				tween:Cancel()
				v26.Position = UDim2.new(0, p.X - X, 0, 0)
			elseif v25.LayoutOrder > 1 and p.X < v25.AbsolutePosition.X then
				Reorder2(-1)
				X -= v25.AbsoluteSize.X
				local tween = TweenService:Create(
					v26,
					TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0, 0, 0, 0)
					}
				)
				tween:Play()
				tween:Cancel()
				v26.Position = UDim2.new(0, p.X - X, 0, 0)
			elseif v21 and v21.PlaybackState == Enum.PlaybackState.Playing then
				v21:Pause()
				v21 = nil
			end

			if v26.AbsolutePosition.X + v26.AbsoluteSize.X < self.reorderingScroller.AbsolutePosition.X + self.reorderingScroller.AbsoluteSize.X then
				local tween = TweenService:Create(
					v26,
					TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0, p.X - X, 0, 0),
						Rotation = v11 * 10
					}
				)
				tween.Completed:Once(function(p2)
					if p2 == Enum.PlaybackState.Completed then
						TweenService:Create(v26, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Rotation = 0
						}):Play()
					end
				end)
				tween:Play()
			else
				TweenService:Create(v26, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, p.X - X, 0, 0)
				}):Play()
				v26.Rotation = 0
			end
		end))
		local Reorder3 = Reorder
		local ReapplyAccessoriesFromHumDesc3 = ReapplyAccessoriesFromHumDesc
		self._clickJanitor:Add(dragContainer.MoveLeft.MouseButton1Down:Connect(function()
			Reorder3(-1, true)
			task.defer(ReapplyAccessoriesFromHumDesc3)
		end))
		local Reorder4 = Reorder
		local ReapplyAccessoriesFromHumDesc4 = ReapplyAccessoriesFromHumDesc
		self._clickJanitor:Add(dragContainer.MoveRight.MouseButton1Down:Connect(function()
			Reorder4(1, true)
			task.defer(ReapplyAccessoriesFromHumDesc4)
		end))
	end

	local uIListLayout

	if self.reorderingScroller then
		uIListLayout = self.reorderingScroller:FindFirstChild("UIListLayout")
	end

	if not uIListLayout then
		return
	end

	local absoluteContentSize = uIListLayout.AbsoluteContentSize
	self.reorderingScroller.CanvasSize = UDim2.new(0, absoluteContentSize.X, 0, 0)
	self.Instance.NothingWorn.Visible = false
	self.Instance.NothingToReorder.Visible = count == 0
end

function v:BeginLayeredClothingReordering()
	self.reordering = true
	self:CleanupNormalScroller()
	self.scroller.Visible = false
	self:BuildReorderingScroller(wearing)
	self.reorderingScroller.Visible = true
end

function v:SubmitLayeredClothingReordering()
	local idsByLayoutOrder = {}

	for k, v9 in self.reorderFrameToItemMap do
		idsByLayoutOrder[k.LayoutOrder] = v9.id
	end

	local v9 = {}

	for k, v10 in assets do
		v9[v10.id] = k
	end

	table.sort(assets, function(a, b)
		local index = table.find(idsByLayoutOrder, a.id)
		local index2 = table.find(idsByLayoutOrder, b.id)

		if index and not index2 then
			return true
		end

		if index or not index2 then
			if index and index2 then
				return index < index2
			end

			return v9[a.id] < v9[b.id]
		else
			return false
		end
	end)
	local v10 = {}

	for _, v11 in assets do
		table.insert(v10, v9[v11.id])
	end

	for k, v11 in v10 do
		if k ~= v11 then
			break
		end
	end

	WearingController.ReorderWearingAssets(v10)
end

function v:EndLayeredClothingReordering(flag: boolean)
	self.reordering = false

	if flag then
		self:SubmitLayeredClothingReordering()
	end

	self:CleanupReorderingScroller()
	self.reorderingScroller.Visible = false
	self:BuildNormalScroller(wearing)
	self.scroller.Visible = true
end

function v:ToggleLayeredClothingReordering()
	if self.reordering then
		NotificationController.NotifyEditor("3D Clothing Layering: OFF", 1.5, Color3.new(0, 0, 0))
		self:EndLayeredClothingReordering(true)
	else
		NotificationController.NotifyEditor("3D Clothing Layering: ON", 1.5, Color3.new(0, 0, 0))
		self:BeginLayeredClothingReordering()
	end
end

function v:SetupReorderLayeredClothing()
	if not self._isAvatarEditorReworkEnabled then
		return
	end

	self.reorderingScroller = self.Instance:WaitForChild("Reordering")
	self.reorderButton = self.Instance:WaitForChild("ReorderLayeredClothing")
	self.reorderTemplateItem = self.reorderingScroller:FindFirstChild("Template")
	self.reorderTemplateItem.Parent = nil
	local now = 0
	self._Janitor:Add(self.reorderButton.MouseButton1Down:Connect(function()
		if tick() - now < 0.55 then
			return
		end

		now = tick()
		self:ToggleLayeredClothingReordering()
	end))
	self.reorderButton:RemoveTag("Checked")
	self.reorderButton.Visible = self:ShouldShowReorderButton()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._clickJanitor = Janitor.new()
	self._isAvatarEditorReworkEnabled = false
	self._lastWearingUpdate = nil
	WearingController.OnWearingUpdated:Connect(function(lastWearingUpdate)
		assets = lastWearingUpdate.assets
		self._lastWearingUpdate = lastWearingUpdate
		wearing = self:GetWearing(lastWearingUpdate.assets)
		local canvasPosition

		if self.scroller then
			canvasPosition = self.scroller.CanvasPosition
		else
			canvasPosition = Vector2.new(0, 0)
		end

		self:Destroy()

		if self.reordering then
			self:EndLayeredClothingReordering(false)
		end

		self:BuildNormalScroller(wearing)

		if self.scroller then
			self.scroller.CanvasPosition = canvasPosition
		end
	end)
end

function v:FetchAvatarEditorReworkABTestAndRefresh()
	task.spawn(function()
		local v9, v10 = ABTest.GetExperimentVariables("avatar-editor-rework"):timeout(7):await()
		self._isAvatarEditorReworkEnabled = v9 and v10 and v10.categoryEnabled == true

		if self._lastWearingUpdate and self.scroller then
			wearing = self:GetWearing(self._lastWearingUpdate.assets)
			local canvasPosition = self.scroller.CanvasPosition
			self:Destroy()
			self:BuildNormalScroller(wearing)

			if self.scroller then
				self.scroller.CanvasPosition = canvasPosition
			end
		end

		self:SetupReorderLayeredClothing()
	end)
end

function v:BuildNormalScroller(items)
	if self.reorderButton then
		self.reorderButton:RemoveTag("Checked")
		self.reorderButton.Visible = self:ShouldShowReorderButton()
	end

	self:CleanupNormalScroller()

	if Platform.IsMobile() then
		self.templateItem.Size = self.scroller:GetAttribute("ItemSize_Mobile")
	else
		self.templateItem.Size = self.scroller:GetAttribute("ItemSize_NonMobile")
	end

	local count = 0
	local flag = false

	for _, item in items do
		if not (item.id ~= "0" or item.assetType.id ~= 13 and item.assetType.id ~= 18) then
			continue
		end

		count += 1
		local clone = self.templateItem:Clone()
		local id = item.assetType.id
		clone.Name = item.name or v7[id] or "Unknown"
		clone:SetAttribute("Id", item.id)
		clone.ItemFrame.ItemImage.Image = `rbxthumb://type=Asset&id={item.id}&w=150&h=150`
		clone.ItemFrame.Footer.BackgroundColor3 = Color3.fromRGB(168, 123, 17)
		local v9 = item

		local function UpdateFooterText()
			if v9.isPurchaseInfoLoading == true then
				clone.ItemFrame.Footer.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				clone.ItemFrame.Footer.PriceLabel.Text = "Loading"
			elseif v9.isForSale == false then
				clone.ItemFrame.Footer.BackgroundColor3 = Color3.new(0, 0, 0)
				clone.ItemFrame.Footer.PriceLabel.Text = "Off Sale"
			else
				if v9.price ~= nil then
					clone.ItemFrame.Footer.PriceLabel.Text = `{v9.price}`
					return
				end

				if v9.bundleId ~= nil then
					clone.ItemFrame.Footer.PriceLabel.Text = "Bundle"
					return
				end

				clone.ItemFrame.Footer.BackgroundColor3 = Color3.new(0, 0, 0)
				clone.ItemFrame.Footer.PriceLabel.Text = "Owned"
			end

			clone.ItemFrame.AutoButtonColor = false
		end

		UpdateFooterText()
		clone.Parent = self.scroller
		local v11 = clone
		local v12 = item
		self._clickJanitor:Add(clone.ItemFrame.Unequip.MouseButton1Down:Connect(function()
			if flag then
				return
			end

			flag = true
			TweenService:Create(v11.ItemFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.7, 0, 0.7, 0)
			}):Play()
			TweenService:Create(
				v11.ItemFrame,
				TweenInfo.new(0.175, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = Color3.new(1, 0.5, 0.5)
				}
			):Play()
			TweenService:Create(
				v11.ItemFrame.ItemImage,
				TweenInfo.new(0.175, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true),
				{
					ImageColor3 = Color3.new(1, 0.5, 0.5)
				}
			):Play()
			v11.ItemFrame.Footer.PriceLabel.Text = "Deleting"

			if v12.assetType.id == 11 then
				WearingController.WearShirt(v12.id)
			elseif v12.assetType.id == 12 then
				WearingController.WearPants(v12.id)
			else
				WearingController.WearAsset(v12.id, true)
			end

			flag = false
			Platform.Select(self.scroller)
		end))
		local v13 = item
		self._clickJanitor:Add(clone.ItemFrame.MouseButton1Down:Connect(function()
			if v13.isPurchaseInfoLoading ~= true and v13.isForSale ~= false and (v13.price ~= nil or v13.bundleId ~= nil) then
				if v13.bundleId == nil then
					WearingController.PromptItemPurchase(v13.id)
				else
					WearingController.PromptBundlePurchase(v13.bundleId)
				end
			end
		end))
		local v14 = clone
		self._clickJanitor:Add(clone.ItemFrame.MouseEnter:Connect(function()
			if v14.ItemFrame.Footer.PriceLabel.Text ~= "Deleting" then
				TweenService:Create(
					v14.ItemFrame,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(0.85, 0, 0.85, 0)
					}
				):Play()
			end
		end))
		local v15 = clone
		self._clickJanitor:Add(clone.ItemFrame.MouseLeave:Connect(function()
			if v15.ItemFrame.Footer.PriceLabel.Text ~= "Deleting" then
				TweenService:Create(
					v15.ItemFrame,
					TweenInfo.new(0.375, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(0.8, 0, 0.8, 0)
					}
				):Play()
			end
		end))
		local v16 = clone
		self._clickJanitor:Add(clone.ItemFrame.Unequip.MouseEnter:Connect(function()
			if v16.ItemFrame.Footer.PriceLabel.Text ~= "Deleting" then
				TweenService:Create(
					v16.ItemFrame.Unequip,
					TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(0.375, 0, 0.375, 0)
					}
				):Play()
				TweenService:Create(
					v16.ItemFrame,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						BackgroundColor3 = Color3.new(1, 0.75, 0.75)
					}
				):Play()
				TweenService:Create(
					v16.ItemFrame.ItemImage,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						ImageColor3 = Color3.new(1, 0.75, 0.75)
					}
				):Play()
				v16.ItemFrame.Footer.PriceLabel.Text = "Delete?"
			end
		end))
		local v17 = clone
		local UpdateFooterText2 = UpdateFooterText
		self._clickJanitor:Add(clone.ItemFrame.Unequip.MouseLeave:Connect(function()
			if v17.ItemFrame.Footer.PriceLabel.Text ~= "Deleting" then
				TweenService:Create(
					v17.ItemFrame.Unequip,
					TweenInfo.new(0.375, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(0.35, 0, 0.35, 0)
					}
				):Play()
				TweenService:Create(
					v17.ItemFrame,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						BackgroundColor3 = Color3.new(1, 1, 1)
					}
				):Play()
				TweenService:Create(
					v17.ItemFrame.ItemImage,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					{
						ImageColor3 = Color3.new(1, 1, 1)
					}
				):Play()
				UpdateFooterText2()
			end
		end))
	end

	local uIListLayout

	if self.scroller then
		uIListLayout = self.scroller:FindFirstChild("UIListLayout")
	end

	if not uIListLayout then
		return
	end

	local absoluteContentSize = uIListLayout.AbsoluteContentSize
	self.scroller.CanvasSize = UDim2.new(0, absoluteContentSize.X, 0, 0)
	self.Instance.NothingWorn.Visible = count == 0
end

function v:CleanupNormalScroller()
	for _, frame in self.scroller:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	self.scroller.CanvasPosition = Vector2.new(0, 0)
	self._clickJanitor:Cleanup()
end

function v:CleanupReorderingScroller()
	self.reorderFrameToItemMap = nil
	task.defer(function()
		for _, v9 in CollectionService:GetTagged("AVATAR_EDITOR_TEMP_GENERATED_ACCESSORY") do
			if self.tempServerSidedAccessoryStorage and self.tempServerSidedAccessoryStorage[v9] then
				self.tempServerSidedAccessoryStorage[v9].Parent = Players.LocalPlayer.Character
			end

			Debris:AddItem(v9, 0)
		end

		self.tempServerSidedAccessoryStorage = nil
	end)

	for _, frame in self.reorderingScroller:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	self.reorderingScroller.CanvasPosition = Vector2.new(0, 0)
	self._clickJanitor:Cleanup()
end

function v:Start()
	self.scroller = self.Instance:WaitForChild("ScrollingFrame")
	self.templateItem = self.scroller:FindFirstChild("Template")
	self.templateItem.Parent = nil
	self:BuildNormalScroller(wearing)
	self:FetchAvatarEditorReworkABTestAndRefresh()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v