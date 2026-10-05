local Comment = {}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("@self/Styles")
local Global = require(ReplicatedStorage.Assets.Data.Global)
local Money = require(ReplicatedStorage.Modules.Money)
Comment.Color = {
	Normal = Color3.fromRGB(255, 255, 255),
	Super = Color3.fromRGB(255, 247, 134),
	Mega = Color3.fromRGB(179, 128, 255),
	Unique = Color3.fromRGB(37, 255, 219)
}
Comment.MaxCommentsPerSpecificUser = 5
Comment.ReputationScalePastMax = 0.1
Comment.MaximumCommentLength = 500
Comment.MinimumCommentLength = 10
Comment.VerifiedMaxPinnedComments = 4
Comment.MaxPinnedComments = 2
Comment.ImageCostMultipler = 1.5
Comment.ImageReputationMultiplier = 1
Comment.PageSize = 5
Comment.TimeToBeConsideredNew = 3600
Comment.TimeUntilDeletionIsPossible = 3600
Comment.HiddenText = "[This comment has been hidden by the user]"

function Comment:GetCommentStyle(p: string)
	for _, v in next, module, nil do
		if v.Name == p then
			return v
		end
	end

	return module[1]
end

function Comment:GetCommentValue(p: string, flag: boolean?, _: number?)
	return (math.round(Comment:GetCommentStyle(p).Value * 0.5 * Global.ReputationScaling * (flag and 0.5 or 1)))
end

function Comment.GetCommentValueString(_, p: string, flag: boolean?, _: number?)
	local commentValue = Comment:GetCommentValue(p, flag)

	if flag then
		return (`-{Money(commentValue, true)}`)
	end

	return (`+{Money(commentValue, true)}`)
end

if RunService:IsClient() then
	local Client = require(ReplicatedStorage.Modules.GameConfig.Client)

	function Comment.GetCommentPrice(_, p: string)
		return Client:GetValue("CommentPrices")[p] or 999999999
	end
end

Comment.Styles = module
return Comment