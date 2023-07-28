--[[

	Title: Rankslide Service
	Version: 0.1.3

	+
	| Author: VintoKrieg
	| Date: 25/07/23
	| Description: Handles Automatic rankslides
	| Currently works with MTP rankslides and Flightsuit Rankslides - Also accomadates custom rank/insignia items.
	|
	| Requirements:
	|
	+

]]
--
local RankSlideService = {}

local RankslideRef = require(script.RankReferencesREV2)
local Groups = RankslideRef.Groups
local RankFolder = RankslideRef.RankslideStorageDirectory
RankSlideService.Events = {}
RankSlideService.PlayerRef = {}
RankSlideService.CustomRanks = {
	["VintoKrieg"] = {
		Name = "VintoKrieg",
		UserId = 326016520,
		CustomItems = {
			["EngineersBrevet"] = {
				path = RankFolder.CustomRanks:FindFirstChild("EngineersBrevet"),
				WeldParts = 
					{
						["Torso"] = {
							C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							C1 = CFrame.new(0.682846069, -0.633004904, 0.502670288, 1, 0, 0, 0, 1, 0, 0, 0, 1), 
						}
					}
			}
		}
	}
	
}

function getGroup(plr:Player)
	
	for i,v in pairs(Groups) do
		if plr:IsInGroup(v.GroupId) then
			return i,v.GroupId
		end
	end
	return nil
end


function RemoveRankSlide(pref)
	local rankslides = pref.Player.Character:GetDescendants()
	
	for _,v in pairs(rankslides) do
		if v.Name == pref.CurrentRole then
			v:Destroy()
		end
	end
end

function ApplyFlightSuitRank(pref,tape)
	local Char = pref.Player.Character
	local LeftRank = RankFolder[pref.CurrentGroup][tape]:FindFirstChild(pref.CurrentRole):Clone()
	local RightRank = RankFolder[pref.CurrentGroup][tape]:FindFirstChild(pref.CurrentRole):Clone()

	LeftRank.Parent = Char
	RightRank.Parent = Char

	local LeftWeld = Instance.new("ManualWeld")
	LeftWeld.Parent = Char:FindFirstChild("Left Arm")
	LeftWeld.Part0 = Char:FindFirstChild("Left Arm")
	LeftWeld.Part1 = LeftRank
	LeftWeld.C0 = RankslideRef.Groups[pref.CurrentGroup].Ranks[pref.CurrentRole].Uniforms["Flight Suit"].CFrameRef.LeftArm.C0
	LeftWeld.C1 = RankslideRef.Groups[pref.CurrentGroup].Ranks[pref.CurrentRole].Uniforms["Flight Suit"].CFrameRef.LeftArm.C1
	local RightWeld = Instance.new("ManualWeld")
	RightWeld.Parent = Char:FindFirstChild("Right Arm")
	RightWeld.Part0 = Char:FindFirstChild("Right Arm")
	RightWeld.Part1 = RightRank
	RightWeld.C0 = RankslideRef.Groups[pref.CurrentGroup].Ranks[pref.CurrentRole].Uniforms["Flight Suit"].CFrameRef.RightArm.C0
	RightWeld.C1 = RankslideRef.Groups[pref.CurrentGroup].Ranks[pref.CurrentRole].Uniforms["Flight Suit"].CFrameRef.RightArm.C1
end

function ApplyMTPRank(pref,tape)
	local Char = pref.Player.Character
	local Rank = RankFolder[pref.CurrentGroup][tape]:FindFirstChild(pref.CurrentRole):Clone()
	print(pref)
	Rank.Parent = Char

	local RankWeld = Instance.new("ManualWeld")
	RankWeld.Parent = Char:FindFirstChild("Torso")
	RankWeld.Part0 = Char:FindFirstChild("Torso")
	RankWeld.Part1 = Rank
	RankWeld.C0 = RankslideRef.Groups[pref.CurrentGroup].Ranks[pref.CurrentRole].Uniforms["MTP"].CFrameRef.Torso.C0
	RankWeld.C1 = RankslideRef.Groups[pref.CurrentGroup].Ranks[pref.CurrentRole].Uniforms["MTP"].CFrameRef.Torso.C1

end

function RankSlideService:IsWearingRank(plr)
	local char = plr.Character
	if char:FindFirstChild(RankSlideService.PlayerRef[plr.Name].CurrentRole) then
		return true
	end 
	return false
end



function RankSlideService.ApplyRank(pref,tape)
	if not RankSlideService:IsWearingRank(pref.Player) then
		if tape == "Flight Suit" then
			ApplyFlightSuitRank(pref,tape)
		elseif tape == "MTP" then
			ApplyMTPRank(pref,tape)
		end
	else
		RemoveRankSlide(pref)
	end
end

function RankSlideService:UpdateRank(plr)
	local pref = RankSlideService.PlayerRef[plr.Name]
	pref.CurrentRole = pref.Player:GetRoleInGroup(pref.CurrentGroupId)
	pref.CurrentRank = pref.Player:GetRankInGroup(pref.CurrentGroupId)
end

function RankSlideService:ChangeRank(plr,role)
	local pref = RankSlideService.PlayerRef[plr.Name]
	pref.CurrentRole = role
	pref.CurrentRank = pref.Player:GetRankInGroup(pref.CurrentGroupId)
end

function NewPlayerRef(plr:Player)
	local group,id = getGroup(plr)
	local PlayerRefTemp = {
		Player = plr,
		Name = plr.Name,
		CurrentGroup = group,
		CurrentGroupId = id,
		CurrentRank = plr:GetRankInGroup(id),
		CurrentRole = "[OR-9] Warrant Officer"--plr:GetRoleInGroup(id)
	}


	--print(PlayerRefTemp)
	RankSlideService.PlayerRef[plr.Name] =  PlayerRefTemp
end

function CustomRanks(plr:Player)
	
	local CR = RankSlideService.CustomRanks[plr.Name]
	if plr.UserId ~= CR.UserId then
		warn("User "..plr.Name.." does not match the UID for this custom rank set")
		return
	end
	for i,v in pairs(CR.CustomItems) do
		for partIndex,x in pairs(v.WeldParts) do
			local Char = plr.Character
			local rank = v.path:Clone()
			
			rank.Parent = Char
			local weld = Instance.new("ManualWeld")
			weld.Parent = Char:FindFirstChild(partIndex)
			weld.Part0 = Char:FindFirstChild(partIndex)
			weld.Part1 = rank
			weld.C0 = x.C0
			weld.C1 = x.C1
		end
		
	end
end

function hasCustomRank(plr)
	
	for i,_ in pairs(RankSlideService.CustomRanks) do
		print(i.." "..plr.Name)
		if i == plr.Name then
			return true
		end
	end
	return false
end

function PA()
	for _,v:Player in pairs(game:GetService("Players"):GetPlayers()) do
		NewPlayerRef(v)
		if hasCustomRank(v) then
			if v.Character == nil then
				v.CharacterAdded:Wait()
			end
			CustomRanks(v)
		end
	end
	
	RankSlideService.Events.PlayerAddedEvent = game:GetService("Players").PlayerAdded:Connect(function(plr:Player)
		NewPlayerRef(plr)
		if hasCustomRank(plr) then
			if plr.Character == nil then
				plr.CharacterAdded:Wait()
			end
			CustomRanks(plr)
		end
	end)
end

function ProxDetect()
	RankSlideService.Events.ProximityEvent = game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt:ProximityPrompt,plr:Player)
		if prompt.Name == "RankPrompt" then
			RankSlideService.ApplyRank(RankSlideService.PlayerRef[plr.Name],prompt.ObjectText)	
		end
	end)
end

function RankSlideService:GetPlayerRef()
	return RankSlideService.PlayerRef
end

function RankSlideService:Init()
	task.spawn(PA)
	task.spawn(ProxDetect)
	return "Initialised"
end


return RankSlideService
