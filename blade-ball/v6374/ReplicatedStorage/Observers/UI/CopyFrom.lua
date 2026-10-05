local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
require(ReplicatedStorage.Common.ColorsUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
return Observers.observeTagNoAncestry("UI_CopyFrom", function(p)
	local parent = p.Parent
	local maid = Trove.new()
	maid:Add((Observers.observeProperty(p, "Value", function(guiObject)
		if not guiObject then
			return function() end
		end

		local maid2 = Trove.new()
		maid2:Add(Observers.observeProperty(guiObject, "Visible", function(visible)
			parent.Visible = visible
			return function() end
		end))

		if parent:IsA("GuiButton") and guiObject:IsA("GuiButton") then
			maid2:Add(Utils.GuiUtils.mirrorActivated(parent, guiObject))
		end

		if not parent:GetAttribute("IgnoreImages") then
			if (parent:IsA("ImageLabel") or parent:IsA("ImageButton")) and (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
				maid2:Add(Observers.observeProperty(guiObject, "Image", function(image)
					parent.Image = image
					return function() end
				end))
			end

			if parent:IsA("ImageButton") and guiObject:IsA("ImageButton") then
				maid2:Add(Observers.observeProperty(guiObject, "HoverImage", function(hoverImage)
					parent.HoverImage = hoverImage
					return function() end
				end))
			end
		end

		if (parent:IsA("TextLabel") or parent:IsA("TextButton")) and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
			maid2:Add(Observers.observeProperty(guiObject, "Text", function(text)
				parent.Text = text
				return function() end
			end))
		end

		return function()
			maid2:Clean()
		end
	end)))
	return function()
		maid:Destroy()
	end
end)