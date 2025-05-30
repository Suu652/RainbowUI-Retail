
local addonId, wqtInternal = ...

--world quest tracker object
local WorldQuestTracker = WorldQuestTrackerAddon
if (not WorldQuestTracker) then
	return
end

--framework
local DF = _G ["DetailsFramework"]
if (not DF) then
	print("|cFFFFAA00World Quest Tracker: framework not found, if you just installed or updated the addon, please restart your client.|r")
	return
end

--localization
local L = DF.Language.GetLanguageTable(addonId)

local HereBeDragons = LibStub("HereBeDragons-2.0")

local CONST_QUEST_LOADINGTIME = 1.333
local _
local isWorldQuest = QuestUtils_IsQuestWorldQuest
local GetQuestsForPlayerByMapID = C_TaskQuest.GetQuestsForPlayerByMapID or C_TaskQuest.GetQuestsOnMap
local IsQuestCriteriaForBounty = C_QuestLog.IsQuestCriteriaForBounty

local faction_frames = {}
local all_widgets = {}
WorldQuestTracker.WorldMapWidgets = all_widgets
local extra_widgets = {}

local forceRetryForHub = {}
local forceRetryForHubAmount = 2

local UpdateDebug = false

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--> world map widgets

--se a janela do world map esta em modo janela
WorldQuestTracker.InWindowMode = not WorldMapFrame.isMaximized
WorldQuestTracker.LastUpdate = 0
local worldFramePOIs = WorldQuestTrackerWorldMapPOI

--store the amount os quests for each faction on each map
local factionAmountForEachMap = {}

worldFramePOIs.mouseoverHighlight = worldFramePOIs:CreateTexture(nil, "background")
worldFramePOIs.mouseoverHighlight:SetTexture([[Interface\Worldmap\QuestPoiGlow]])
worldFramePOIs.mouseoverHighlight:SetSize(54, 54)
worldFramePOIs.mouseoverHighlight:SetAlpha(0.843215)
worldFramePOIs.mouseoverHighlight:SetVertexColor(1, .7, .2)
worldFramePOIs.mouseoverHighlight:SetVertexColor(unpack(WorldQuestTracker.ColorPalette.orange))
worldFramePOIs.mouseoverHighlight:SetBlendMode("ADD")

worldFramePOIs.mouseoverHighlight.OnShowAnimation = DF:CreateAnimationHub(worldFramePOIs.mouseoverHighlight)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.OnShowAnimation, "scale", 1, 0.035, .7, .7, 1.1, 1.1)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.OnShowAnimation, "alpha", 1, 0.035, 0.75, .91)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.OnShowAnimation, "scale", 2, 0.035, 1.1, 1.1, 1, 1)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.OnShowAnimation, "alpha", 2, 0.035, .91, 1)

worldFramePOIs.mouseoverHighlight.PulseAnimation = DF:CreateAnimationHub(worldFramePOIs.mouseoverHighlight)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.PulseAnimation, "scale", 1, 1, 1, 1, 1.6, 1.6)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.PulseAnimation, "alpha", 1, 1, 0.75, .91)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.PulseAnimation, "scale", 2, 1, 1, 1, .6, .6)
DF:CreateAnimation(worldFramePOIs.mouseoverHighlight.PulseAnimation, "alpha", 2, 1, 1, .845)
worldFramePOIs.mouseoverHighlight.PulseAnimation:SetLooping("REPEAT")

local do_highlight_pulse_animation = function(timerObject)
	worldFramePOIs.mouseoverHighlight.PulseAnimation:Play()
end

local do_highlight_on_quest = function(widget, scale, color)
	if (worldFramePOIs.mouseoverHighlight.StartPulseAnimation) then
		worldFramePOIs.mouseoverHighlight.StartPulseAnimation:Cancel()
	end

	local r, g, b, a = DF:ParseColors(color or "white")
	worldFramePOIs.mouseoverHighlight:SetVertexColor(r, g, b, a)

	worldFramePOIs.mouseoverHighlight:Show()
	worldFramePOIs.mouseoverHighlight:SetScale(scale)
	worldFramePOIs.mouseoverHighlight:SetParent(widget)
	worldFramePOIs.mouseoverHighlight:ClearAllPoints()
	worldFramePOIs.mouseoverHighlight:SetPoint("center", widget, "center", 0, 0)
	worldFramePOIs.mouseoverHighlight.OnShowAnimation:Play()

	worldFramePOIs.mouseoverHighlight.StartPulseAnimation = C_Timer.NewTimer(2, do_highlight_pulse_animation)
end

local loadQuestData = function()
	local worldMapID = WorldQuestTracker.GetCurrentMapAreaID()

	for mapId, configTable in pairs(WorldQuestTracker.mapTables) do
		if (configTable.show_on_map[worldMapID]) then
			local taskInfo = GetQuestsForPlayerByMapID(mapId, mapId)

			if (taskInfo and #taskInfo > 0) then
				for i, info in ipairs(taskInfo) do
					local questID = info.questID
					if (not WorldQuestTracker.HaveDataForQuest(questID) or not HaveQuestRewardData(questID)) then
						C_TaskQuest.RequestPreloadRewardData(questID)
					end
				end
			end
		end
	end
end

---@param failedToUpdateQuestList table<questid, boolean>
local waitForQuestData = function(failedToUpdateQuestList)
	local amountFailed = 0
	for questID in pairs(failedToUpdateQuestList) do
		amountFailed = amountFailed + 1
		C_TaskQuest.RequestPreloadRewardData(questID)
	end

	C_Timer.After(1, function()
		local bCanUpdateWorldQuests = false
		if (WorldQuestTracker.IsWorldQuestHub(WorldQuestTracker.GetCurrentMapAreaID())) then
			for questID in pairs(failedToUpdateQuestList) do
				if (HaveQuestRewardData(questID)) then
					failedToUpdateQuestList[questID] = nil
					bCanUpdateWorldQuests = true
				end
			end
		end

		if (bCanUpdateWorldQuests) then
			WorldQuestTracker.UpdateWorldQuestsOnWorldMap()
		end
	end)

	C_Timer.After(2, function()
		if (WorldQuestTracker.IsWorldQuestHub(WorldQuestTracker.GetCurrentMapAreaID())) then
			for questID in pairs(failedToUpdateQuestList) do
				if (HaveQuestRewardData(questID)) then
					WorldQuestTracker.UpdateWorldQuestsOnWorldMap()
					return
				end
			end
		end
	end)
end

--when a square is hover hovered in the world map, find the circular quest button in the world map and highlight it
function WorldQuestTracker.HighlightOnWorldMap(questID, scale, color)
	scale = scale or 1
	for questCounter, button in pairs(WorldQuestTracker.WorldMapSmallWidgets) do
		if (button.questID == questID) then
			--print(button.x, button.y)
			do_highlight_on_quest(button, scale, color)
		end
	end
end

function WorldQuestTracker.HighlightOnZoneMap(questID, scale, color)
	scale = scale or 1
	for questCounter, button in pairs(WorldQuestTracker.Cache_ShownWidgetsOnZoneMap) do
		if (button.questID == questID) then
			do_highlight_on_quest(button, scale, color)
		end
	end
end

function WorldQuestTracker.HideMapQuestHighlight()
	if (worldFramePOIs.mouseoverHighlight.StartPulseAnimation) then
		worldFramePOIs.mouseoverHighlight.StartPulseAnimation:Cancel()
	end
	worldFramePOIs.mouseoverHighlight.PulseAnimation:Stop()
	worldFramePOIs.mouseoverHighlight:Hide()
end

local tickSound = true --flip flop
function WorldQuestTracker.PlayTick(tickType)
	tickType = tickType or 1

	--play sound
	if (WorldQuestTracker.db.profile.sound_enabled) then
		--hovering over a quest icon in the world map
		if (tickType == 1) then
			if (tickSound) then
				PlaySoundFile("Interface\\AddOns\\WorldQuestTracker\\media\\tick1.ogg")
			else
				PlaySoundFile("Interface\\AddOns\\WorldQuestTracker\\media\\tick2.ogg")
			end

		--hovering over a faction icon
		elseif (tickType == 2) then
			if (tickSound) then
				PlaySoundFile("Interface\\AddOns\\WorldQuestTracker\\media\\tick1_heavy.ogg")
			else
				PlaySoundFile("Interface\\AddOns\\WorldQuestTracker\\media\\tick2_heavy.ogg")
			end

		--when a quest is added to the tracker
		elseif (tickType == 3) then
			if (tickSound) then
				PlaySoundFile("Interface\\AddOns\\WorldQuestTracker\\media\\quest_added_to_tracker1.mp3")
			else
				PlaySoundFile("Interface\\AddOns\\WorldQuestTracker\\media\\quest_added_to_tracker2.mp3")
			end
		end

		tickSound = not tickSound
	end
end

local onenter_scale_animation = function(self, scale)
	if (not WorldQuestTracker.db.profile.hoverover_animations) then
		return
	end

	if (self.OnLeaveAnimation:IsPlaying()) then
		self.OnLeaveAnimation:Stop()
	end

	self.OriginalScale = self:GetScale()
	self.ModifiedScale = self.OriginalScale + scale

	if (self.OnEnterAnimation.ScaleAnimation.SetScaleFrom) then
		self.OnEnterAnimation.ScaleAnimation:SetScaleFrom(self.OriginalScale, self.OriginalScale)
		self.OnEnterAnimation.ScaleAnimation:SetScaleTo(self.ModifiedScale, self.ModifiedScale)
	else
		self.OnEnterAnimation.ScaleAnimation:SetFromScale(self.OriginalScale, self.OriginalScale)
		self.OnEnterAnimation.ScaleAnimation:SetToScale(self.ModifiedScale, self.ModifiedScale)
	end
	self.OnEnterAnimation:Play()
end

local onleave_scale_animation = function(self, scale)
	if (not WorldQuestTracker.db.profile.hoverover_animations) then
		return
	end

	if (self.OnEnterAnimation:IsPlaying()) then
		self.OnEnterAnimation:Stop()
	end

	local currentScale = self.ModifiedScale
	local originalScale = self.OriginalScale

	if (self.OnLeaveAnimation.ScaleAnimation.SetScaleFrom) then
		if (not currentScale) then
			currentScale = 1
		end
		self.OnLeaveAnimation.ScaleAnimation:SetScaleFrom(currentScale, currentScale) --error bad argument #1 to 'SetScaleFrom' (Usage: self:SetScaleFrom(scale))
		self.OnLeaveAnimation.ScaleAnimation:SetScaleTo(originalScale, originalScale)
	else
		self.OnLeaveAnimation.ScaleAnimation:SetFromScale(currentScale, currentScale)
		self.OnLeaveAnimation.ScaleAnimation:SetToScale(originalScale, originalScale)
	end

	self.OnLeaveAnimation:Play()
end

--local onenter function for worldmap buttons
local questButton_OnEnter = function(self)
	if (self.questID) then
		WorldQuestTracker.CurrentHoverQuest = self.questID
		self.UpdateTooltip = TaskPOI_OnEnter -- function()end
		TaskPOI_OnEnter(self)

		--[=[
		for key, tooltip in pairs(_G) do
			if (type(tooltip) == "table" and tooltip.GetName) then
				if (tooltip.IsShown and tooltip.HookScript and not tooltip.widget and not tooltip.MyObject and not tooltip.dframework and not tooltip.WidgetType and not tooltip.dversion) then
					if (tooltip.GetObjectType) then
						local run = pcall(function()tooltip:GetObjectType()end)
						if (run and tooltip:GetObjectType() == "GameTooltip") then
							if (tooltip:IsShown()) then
								print(tooltip:GetName())

								if (tooltip:GetName() == "GameTooltipTooltip") then
									local tooltipData = tooltip:GetTooltipData()
									print(tooltipData)
									if (tooltipData) then
										for a,b in pairs(tooltipData) do
											print(a,b)
										end
									end
								end
							end
						end
					end
				end
			end
		end
		--]=]

		WorldQuestTracker.HighlightOnWorldMap(self.questID, 1.3, "orange")

		if (WorldMapFrame.mapID == WorldQuestTracker.MapData.ZoneIDs.AZEROTH) then
			local t = {self.questID, self.mapID, self.numObjectives, 1, "", self.X, self.Y}
			WorldQuestTracker.ShowWorldMapSmallIcon_Temp(t)
			self.IsShowingSmallQuestIcon = true
		end

		if (self.OnEnterAnimation) then
			onenter_scale_animation(self, self.OnEnterAnimationScaleDiff or WQT_ANIMATION_SPEED)
		end

		--play tick sound
		WorldQuestTracker.PlayTick(1)

		--highlights
		if (self.HighlightSaturated) then
			self.HighlightSaturated:SetTexture(self.texture:GetTexture())
			self.HighlightSaturated:SetTexCoord(self.texture:GetTexCoord())
		end

		self:SetBackdropColor(0, 0, 0, 0)
	end
end

local questButton_OnLeave = function(self)
	if (self.OnLeaveAnimation) then
		onleave_scale_animation(self)
	end

	TaskPOI_OnLeave(self)
	WorldQuestTracker.CurrentHoverQuest = nil
	WorldQuestTracker.HideMapQuestHighlight()

	if (self.IsShowingSmallQuestIcon) then
		if (WorldMapFrame.mapID == WorldQuestTracker.MapData.ZoneIDs.AZEROTH) then
			local map = WorldQuestTrackerDataProvider:GetMap()
			for pin in map:EnumeratePinsByTemplate("WorldQuestTrackerWorldMapPinTemplate") do
				if (pin.Child) then
					pin.Child:Hide()
				end
				map:RemovePin(pin)
			end
		end
		wipe(WorldQuestTracker.WorldMapWidgetsLazyUpdateFrame.ShownQuests)
		self.IsShowingSmallQuestIcon = nil
	end

	self:SetBackdropColor(.1, .1, .1, .6)
end

WorldQuestTracker.TaskPOI_OnEnterFunc = questButton_OnEnter
WorldQuestTracker.TaskPOI_OnLeaveFunc = questButton_OnLeave

--esconde todos os widgets do world map
function WorldQuestTracker.HideWorldQuestsOnWorldMap()
	--old squares(deprecated)
	for _, widget in ipairs(all_widgets) do
		widget:Hide()
		widget.isArtifact = nil
		widget.questID = nil
	end

	--faction lines(deprecated)
	for _, widget in ipairs(extra_widgets) do --hide lines and indicators for factions
		widget:Hide()
	end

	--world summary in the left side of the world map
	if (WorldQuestTracker.WorldSummary and WorldQuestTracker.WorldSummary.HideSummary) then
		WorldQuestTracker.WorldSummary.HideSummary()
	end
end

local worldSquareBackdrop = {edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1.8, bgFile = [[Interface\TARGETINGFRAME\UI-TargetingFrame-LevelBackground]], tile = true, tileSize = 16}

local emptyFunction = function()end

--cria uma square widget no world map ~world ~createworld ~createworldwidget
--index and name are only for the glogal name
local create_worldmap_square = function(mapName, index, parent)
	local button = CreateFrame("button", "WorldQuestTrackerWorldMapPOI" .. mapName .. "POI" .. index, parent or worldFramePOIs, "BackdropTemplate")
	button:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize, WorldQuestTracker.Constants.WorldMapSquareSize)
	button.IsWorldQuestButton = true
	button:SetFrameLevel(302)
	button:SetBackdrop(worldSquareBackdrop)
	button:SetBackdropColor(.1, .1, .1, .6)
	button.OnLegendPinMouseEnter = emptyFunction
	button.OnLegendPinMouseLeave = emptyFunction

	button:SetScript("OnEnter", questButton_OnEnter)
	button:SetScript("OnLeave", questButton_OnLeave)
	button:SetScript("OnClick", WorldQuestTracker.OnQuestButtonClick)

	button:RegisterForClicks("LeftButtonDown", "MiddleButtonDown", "RightButtonDown")

	local fadeInAnimation = button:CreateAnimationGroup()
	local step1 = fadeInAnimation:CreateAnimation("Alpha")
	step1:SetOrder(1)
	step1:SetFromAlpha(0)
	step1:SetToAlpha(1)
	step1:SetDuration(0.1)
	button.fadeInAnimation = fadeInAnimation

	local background = button:CreateTexture(nil, "background", nil, -3)
	background:SetAllPoints()

	local texture = button:CreateTexture(nil, "background", nil, -2)
	--texture:SetAllPoints()
	texture:SetPoint("topleft", 1, -1)
	texture:SetPoint("bottomright", -1, 1)

	--borders
	local commonBorder = button:CreateTexture(nil, "artwork", nil, 1)
	commonBorder:SetPoint("topleft", button, "topleft")
	commonBorder:SetTexture([[Interface\AddOns\WorldQuestTracker\media\border_whiteT]])
	commonBorder:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize, WorldQuestTracker.Constants.WorldMapSquareSize)

	local rareBorder = button:CreateTexture(nil, "artwork", nil, 1)
	rareBorder:SetPoint("topleft", button, "topleft", -1, 1)
	rareBorder:SetTexture([[Interface\AddOns\WorldQuestTracker\media\border_blueT]])
	rareBorder:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize+2, WorldQuestTracker.Constants.WorldMapSquareSize+2)

	local epicBorder = button:CreateTexture(nil, "artwork", nil, 1)
	epicBorder:SetPoint("topleft", button, "topleft", -1, 1)
	epicBorder:SetTexture([[Interface\AddOns\WorldQuestTracker\media\border_pinkT]])
	epicBorder:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize + 2, WorldQuestTracker.Constants.WorldMapSquareSize + 2)

	local invasionBorder = button:CreateTexture(nil, "artwork", nil, 1)
	invasionBorder:SetPoint("topleft", button, "topleft", -1, 1)
	invasionBorder:SetTexture([[Interface\AddOns\WorldQuestTracker\media\border_redT]])
	invasionBorder:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize + 2, WorldQuestTracker.Constants.WorldMapSquareSize + 2)
	invasionBorder:Hide()

	local trackingBorder = button:CreateTexture(nil, "artwork", nil, 1)
	trackingBorder:SetPoint("topleft", button, "topleft", -5, 5)
	trackingBorder:SetTexture([[Interface\Artifacts\Artifacts]])
	trackingBorder:SetTexCoord(491/1024, 569/1024, 76/1024, 153/1024)
	trackingBorder:SetBlendMode("ADD")
	trackingBorder:SetVertexColor(unpack(WorldQuestTracker.ColorPalette.orange))
	trackingBorder:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize+10, WorldQuestTracker.Constants.WorldMapSquareSize+10)

	local factionBorder = button:CreateTexture(nil, "artwork", nil, 1)
	factionBorder:SetPoint("center")
	factionBorder:SetTexture([[Interface\Artifacts\Artifacts]])
	factionBorder:SetTexCoord(137/1024, 195/1024, 920/1024, 978/1024)
	factionBorder:Hide()
	factionBorder:SetAlpha(1)
	factionBorder:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize+2, WorldQuestTracker.Constants.WorldMapSquareSize+2)

	local overlayBorder = button:CreateTexture(nil, "overlay", nil, 5)
	local overlayBorder2 = button:CreateTexture(nil, "overlay", nil, 6)
	overlayBorder:SetDrawLayer("overlay", 5)
	overlayBorder2:SetDrawLayer("overlay", 6)
	overlayBorder:SetTexture([[Interface\Soulbinds\SoulbindsConduitIconBorder]])
	overlayBorder2:SetTexture([[Interface\Soulbinds\SoulbindsConduitIconBorder]])
	overlayBorder:SetTexCoord(0/256, 66/256, 0, 0.5)
	overlayBorder2:SetTexCoord(67/256, 132/256, 0, 0.5)

	overlayBorder:Hide()
	overlayBorder2:Hide()
	overlayBorder:SetPoint("topleft", 0, 0)
	overlayBorder:SetPoint("bottomright", 0, 0)
	overlayBorder2:SetPoint("topleft", 0, 0)
	overlayBorder2:SetPoint("bottomright", 0, 0)

	local borderAnimation = CreateFrame("frame", "$parentBorderShineAnimation", button, "AnimatedShineTemplate")
	borderAnimation:SetFrameLevel(303)
	borderAnimation:SetPoint("topleft", 2, -2)
	borderAnimation:SetPoint("bottomright", -2, 2)
	borderAnimation:SetAlpha(.05)
	borderAnimation:Hide()
	button.borderAnimation = borderAnimation

	--create the on enter/leave scale mini animation

		--animations
		local animaSettings = {
			scaleMax = 1.1,
			speed = WQT_ANIMATION_SPEED,
		}
		do
			button.OnEnterAnimation = DF:CreateAnimationHub(button, function() end, function() end)
			local anim = WorldQuestTracker:CreateAnimation(button.OnEnterAnimation, "Scale", 1, animaSettings.speed, 1, 1, animaSettings.scaleMax, animaSettings.scaleMax, "center", 0, 0)
			anim:SetEndDelay(60) --this fixes the animation going back to 1 after it finishes
			--anim:SetSmoothing("IN_OUT")
			anim:SetSmoothing("IN") --looks like OUT smooth has some problems in the PTR
			button.OnEnterAnimation.ScaleAnimation = anim

			button.OnLeaveAnimation = DF:CreateAnimationHub(button, function() end, function() end)
			local anim = WorldQuestTracker:CreateAnimation(button.OnLeaveAnimation, "Scale", 2, animaSettings.speed, animaSettings.scaleMax, animaSettings.scaleMax, 1, 1, "center", 0, 0)
			--anim:SetSmoothing("IN_OUT")
			anim:SetSmoothing("IN")
			button.OnLeaveAnimation.ScaleAnimation = anim

			button.OnEnterAnimationScaleDiff = WQT_ANIMATION_SPEED
		end

	WorldQuestTracker.CreateStartTrackingAnimation(button, nil, 5)

	local trackingGlowInside = button:CreateTexture(nil, "overlay", nil, 1)
	trackingGlowInside:SetPoint("center", button, "center")
	trackingGlowInside:SetColorTexture(1, 1, 1, .03)
	trackingGlowInside:SetSize(WorldQuestTracker.Constants.WorldMapSquareSize * 0.8, WorldQuestTracker.Constants.WorldMapSquareSize * 0.8)
	trackingGlowInside:Hide()

	local trackingGlowBorder = button:CreateTexture(nil, "overlay", nil, 1)
	trackingGlowBorder:SetPoint("center", button, "center")
	trackingGlowBorder:SetTexture([[Interface\AddOns\WorldQuestTracker\media\glow_yellow_squareT]])
	trackingGlowBorder:SetBlendMode("ADD")
	trackingGlowBorder:SetSize(55, 55)
	trackingGlowBorder:SetAlpha(1)
	trackingGlowBorder:SetDrawLayer("BACKGROUND", -5)
	trackingGlowBorder:Hide()

	local flashTexture = button:CreateTexture(nil, "overlay")
	flashTexture:SetDrawLayer("overlay", 7)
	flashTexture:Hide()
	flashTexture:SetColorTexture(1, 1, 1)
	flashTexture:SetPoint("topleft", 1, -1)
	flashTexture:SetPoint("bottomright", -1, 1)
	button.FlashTexture = flashTexture

	button.QuickFlash = DF:CreateAnimationHub(flashTexture, function() flashTexture:Show() end, function() flashTexture:Hide() end)
	local anim = WorldQuestTracker:CreateAnimation(button.QuickFlash, "Alpha", 1, .15, 0, 1)
	anim:SetSmoothing("IN_OUT")
	local anim = WorldQuestTracker:CreateAnimation(button.QuickFlash, "Alpha", 2, .15, 1, 0)
	anim:SetSmoothing("IN_OUT")

	button.LoopFlash = DF:CreateAnimationHub(flashTexture, function() flashTexture:Show() end, function() flashTexture:Hide() end)
	local anim = WorldQuestTracker:CreateAnimation(button.LoopFlash, "Alpha", 1, .35, 0, .5)
	anim:SetSmoothing("IN_OUT")
	local anim = WorldQuestTracker:CreateAnimation(button.LoopFlash, "Alpha", 2, .35, .5, 0)
	anim:SetSmoothing("IN_OUT")
	button.LoopFlash:SetLooping("REPEAT")

	local smallFlashOnTrack = button:CreateTexture(nil, "overlay", nil, 7)
	smallFlashOnTrack:Hide()
	smallFlashOnTrack:SetColorTexture(1, 1, 1)
	smallFlashOnTrack:SetAllPoints()

	local onFlashTrackAnimation = DF:CreateAnimationHub(smallFlashOnTrack, nil, function(self) self:GetParent():Hide() end)
	onFlashTrackAnimation.FlashTexture = smallFlashOnTrack
	WorldQuestTracker:CreateAnimation(onFlashTrackAnimation, "Alpha", 1, .15, 0, 1)
	WorldQuestTracker:CreateAnimation(onFlashTrackAnimation, "Alpha", 2, .15, 1, 0)

	local onStartTrackAnimation = DF:CreateAnimationHub(trackingGlowBorder, WorldQuestTracker.OnStartClickAnimation)
	onStartTrackAnimation.OnFlashTrackAnimation = onFlashTrackAnimation
	WorldQuestTracker:CreateAnimation(onStartTrackAnimation, "Scale", 1, .1, .9, .9, 1.1, 1.1)
	WorldQuestTracker:CreateAnimation(onStartTrackAnimation, "Scale", 2, .1, 1.2, 1.2, 1, 1)

	local onEndTrackAnimation = DF:CreateAnimationHub(trackingGlowBorder, WorldQuestTracker.OnStartClickAnimation, WorldQuestTracker.OnEndClickAnimation)
	WorldQuestTracker:CreateAnimation(onEndTrackAnimation, "Scale", 1, .5, 1, 1, .6, .6)
	button.onStartTrackAnimation = onStartTrackAnimation
	button.onEndTrackAnimation = onEndTrackAnimation

	local onShowAnimation = DF:CreateAnimationHub(button) --, WorldQuestTracker.OnStartClickAnimation, WorldQuestTracker.OnEndClickAnimation
	WorldQuestTracker:CreateAnimation(onShowAnimation, "Scale", 1, .1, 1, 1, 1.2, 1.2)
	WorldQuestTracker:CreateAnimation(onShowAnimation, "Scale", 2, .1, 1.1, 1.1, 1, 1)
	WorldQuestTracker:CreateAnimation(onShowAnimation, "Alpha", 1, .1, 0, .5)
	WorldQuestTracker:CreateAnimation(onShowAnimation, "Alpha", 2, .1, .5, 1)
	button.OnShowAnimation = onShowAnimation

	local criteriaFrame = CreateFrame("frame", nil, button, "BackdropTemplate")
	local criteriaIndicator = criteriaFrame:CreateTexture(nil, "OVERLAY", nil, 2)
	criteriaIndicator:SetPoint("topleft", button, "topleft", 1, -1)
	criteriaIndicator:SetSize(28*.32, 34*.32) --original sizes: 23 37
	criteriaIndicator:SetAlpha(.933)
	criteriaIndicator:SetTexture(WorldQuestTracker.MapData.GeneralIcons.CRITERIA.icon)
	criteriaIndicator:SetTexCoord(unpack(WorldQuestTracker.MapData.GeneralIcons.CRITERIA.coords))
	criteriaIndicator:Hide()

	criteriaFrame.Texture = criteriaIndicator
	local criteriaIndicatorGlow = criteriaFrame:CreateTexture(nil, "OVERLAY", nil, 1)
	criteriaIndicatorGlow:SetPoint("center", criteriaIndicator, "center")
	criteriaIndicatorGlow:SetSize(16, 16)
	criteriaIndicatorGlow:SetTexture([[Interface\AddOns\WorldQuestTracker\media\criteriaIndicatorGlowT]])
	criteriaIndicatorGlow:SetTexCoord(0, 1, 0, 1)
	criteriaIndicatorGlow:SetVertexColor(1, .8, 0, 0)
	criteriaIndicatorGlow:Hide()
	criteriaFrame.Glow = criteriaIndicatorGlow

	local criteriaAnimation = DF:CreateAnimationHub(criteriaFrame)
	DF:CreateAnimation(criteriaAnimation, "Scale", 1, .15, 1, 1, 1.1, 1.1)
	DF:CreateAnimation(criteriaAnimation, "Scale", 2, .15, 1.2, 1.2, 1, 1)
	button.CriteriaAnimation = criteriaAnimation

	local criteriaHighlight = button:CreateTexture(nil, "highlight")
	criteriaHighlight:SetPoint("center", criteriaIndicator, "center")
	criteriaHighlight:SetSize(28*.32, 36*.32)
	criteriaHighlight:SetAlpha(.8)
	criteriaHighlight:SetTexture(WorldQuestTracker.MapData.GeneralIcons.CRITERIA.icon)
	criteriaHighlight:SetTexCoord(unpack(WorldQuestTracker.MapData.GeneralIcons.CRITERIA.coords))

	commonBorder:Hide()
	rareBorder:Hide()
	epicBorder:Hide()
	trackingBorder:Hide()

	--blip do tempo restante
	button.timeBlipRed = button:CreateTexture(nil, "OVERLAY")
	button.timeBlipRed:SetPoint("bottomright", button, "bottomright", 4, -4)
	button.timeBlipRed:SetSize(WorldQuestTracker.Constants.TimeBlipSize, WorldQuestTracker.Constants.TimeBlipSize)
	button.timeBlipRed:SetTexture([[Interface\COMMON\Indicator-Red]])
	button.timeBlipRed:SetVertexColor(1, 1, 1)
	button.timeBlipRed:SetAlpha(1)

	button.timeBlipOrange = button:CreateTexture(nil, "OVERLAY")
	button.timeBlipOrange:SetPoint("bottomright", button, "bottomright", 4, -4)
	button.timeBlipOrange:SetSize(WorldQuestTracker.Constants.TimeBlipSize, WorldQuestTracker.Constants.TimeBlipSize)
	button.timeBlipOrange:SetTexture([[Interface\COMMON\Indicator-Yellow]])
	button.timeBlipOrange:SetVertexColor(1, .7, 0)
	button.timeBlipOrange:SetAlpha(.95)

	button.timeBlipYellow = button:CreateTexture(nil, "OVERLAY")
	button.timeBlipYellow:SetPoint("bottomright", button, "bottomright", 4, -4)
	button.timeBlipYellow:SetSize(WorldQuestTracker.Constants.TimeBlipSize, WorldQuestTracker.Constants.TimeBlipSize)
	button.timeBlipYellow:SetTexture([[Interface\COMMON\Indicator-Yellow]])
	button.timeBlipYellow:SetVertexColor(1, 1, 1)
	button.timeBlipYellow:SetAlpha(.9)

	button.timeBlipGreen = button:CreateTexture(nil, "OVERLAY")
	button.timeBlipGreen:SetPoint("bottomright", button, "bottomright", 4, -4)
	button.timeBlipGreen:SetSize(WorldQuestTracker.Constants.TimeBlipSize, WorldQuestTracker.Constants.TimeBlipSize)
	button.timeBlipGreen:SetTexture([[Interface\COMMON\Indicator-Green]])
	button.timeBlipGreen:SetVertexColor(1, 1, 1)
	button.timeBlipGreen:SetAlpha(.6)

	button.questTypeBlip = button:CreateTexture(nil, "OVERLAY")
	button.questTypeBlip:SetPoint("topright", button, "topright", 2, 4)
	button.questTypeBlip:SetSize(12, 12)
	button.questTypeBlip:SetDrawLayer("overlay", 7)

	local amountText = button:CreateFontString(nil, "overlay", "GameFontNormal", 1)
	amountText:SetPoint("bottom", button, "bottom", 1, -10)
	DF:SetFontSize(amountText, 9)

	local timeLeftText = button:CreateFontString(nil, "overlay", "GameFontNormal", 1)
	timeLeftText:SetPoint("bottom", button, "bottom", 0, 1)
	timeLeftText:SetJustifyH("center")
	DF:SetFontOutline(timeLeftText, true)
	DF:SetFontSize(timeLeftText, 9)
	DF:SetFontColor(timeLeftText, {1, 1, 0})
	--
	local timeLeftBackground = button:CreateTexture(nil, "background", nil, 0)
	timeLeftBackground:SetPoint("center", timeLeftText, "center")
	timeLeftBackground:SetTexture([[Interface\AddOns\WorldQuestTracker\media\background_blackgradientT]])
	timeLeftBackground:SetSize(32, 10)
	timeLeftBackground:SetAlpha(.60)
	timeLeftBackground:SetAlpha(0)

	local amountBackground = button:CreateTexture(nil, "overlay", nil, 0)
	amountBackground:SetPoint("center", amountText, "center")
	amountBackground:SetTexture([[Interface\AddOns\WorldQuestTracker\media\background_blackgradientT]])
	amountBackground:SetSize(32, 12)
	amountBackground:SetAlpha(.9)

	local highlight = button:CreateTexture(nil, "highlight")
	highlight:SetPoint("topleft", 2, -2)
	highlight:SetPoint("bottomright", -2, 2)
	highlight:SetAlpha(.2)
	highlight:SetTexture([[Interface\AddOns\WorldQuestTracker\media\square_highlight]])

	local highlight_saturate = button:CreateTexture(nil, "highlight")
	highlight_saturate:SetPoint("topleft")
	highlight_saturate:SetPoint("bottomright")
	highlight_saturate:SetAlpha(.45)
	highlight_saturate:SetBlendMode("ADD")
	button.HighlightSaturated = highlight_saturate

	local new = button:CreateTexture(nil, "overlay")
	new:SetPoint("bottom", button, "bottom", 0, -3)
	new:SetSize(64*.45, 32*.45)
	new:SetAlpha(.4)
	new:SetTexture([[Interface\AddOns\WorldQuestTracker\media\new]])
	new:SetTexCoord(0, 1, 0, .5)
	button.newIndicator = new

	local newFlashTexture = button:CreateTexture(nil, "overlay")
	newFlashTexture:SetPoint("bottom", new, "bottom")
	newFlashTexture:SetSize(64*.45, 32*.45)
	newFlashTexture:SetTexture([[Interface\AddOns\WorldQuestTracker\media\new]])
	newFlashTexture:SetTexCoord(0, 1, 0, .5)
	newFlashTexture:Hide()

	local newFlash = newFlashTexture:CreateAnimationGroup()
	newFlash.In = newFlash:CreateAnimation("Alpha")
	newFlash.In:SetOrder(1)
	newFlash.In:SetFromAlpha(0)
	newFlash.In:SetToAlpha(1)
	newFlash.In:SetDuration(.3)
	newFlash.On = newFlash:CreateAnimation("Alpha")
	newFlash.On:SetOrder(2)
	newFlash.On:SetFromAlpha(1)
	newFlash.On:SetToAlpha(1)
	newFlash.On:SetDuration(2)
	newFlash.Out = newFlash:CreateAnimation("Alpha")
	newFlash.Out:SetOrder(3)
	newFlash.Out:SetFromAlpha(1)
	newFlash.Out:SetToAlpha(0)
	newFlash.Out:SetDuration(2)
	newFlash:SetScript("OnPlay", function()
		newFlashTexture:Show()
	end)
	newFlash:SetScript("OnFinished", function()
		newFlashTexture:Hide()
		button.newIndicator:Hide()
	end)
	button.newFlash = newFlash

	--shadow:SetDrawLayer("BACKGROUND", -6)
	trackingGlowBorder:SetDrawLayer("BACKGROUND", -5)
	background:SetDrawLayer("background", -3)
	texture:SetDrawLayer("background", 2)

	commonBorder:SetDrawLayer("border", 1)
	rareBorder:SetDrawLayer("border", 1)
	epicBorder:SetDrawLayer("border", 1)
	trackingBorder:SetDrawLayer("border", 2)
	amountBackground:SetDrawLayer("overlay", 0)
	amountText:SetDrawLayer("overlay", 1)
	criteriaIndicatorGlow:SetDrawLayer("OVERLAY", 1)
	criteriaIndicator:SetDrawLayer("OVERLAY", 2)
	newFlashTexture:SetDrawLayer("OVERLAY", 7)
	new:SetDrawLayer("OVERLAY", 6)
	trackingGlowInside:SetDrawLayer("OVERLAY", 7)
	factionBorder:SetDrawLayer("OVERLAY", 6)

	button.timeBlipRed:SetDrawLayer("overlay", 2)
	button.timeBlipOrange:SetDrawLayer("overlay", 2)
	button.timeBlipYellow:SetDrawLayer("overlay", 2)
	button.timeBlipGreen:SetDrawLayer("overlay", 2)

	highlight:SetDrawLayer("highlight", 1)
	criteriaHighlight:SetDrawLayer("highlight", 2)

	button.background = background
	button.texture = texture
	button.commonBorder = commonBorder
	button.rareBorder = rareBorder
	button.epicBorder = epicBorder
	button.invasionBorder = invasionBorder
	button.trackingBorder = trackingBorder
	button.trackingGlowBorder = trackingGlowBorder
	button.factionBorder = factionBorder
	button.overlayBorder = overlayBorder
	button.overlayBorder2 = overlayBorder2

	button.trackingGlowInside = trackingGlowInside

	button.timeLeftText = timeLeftText
	button.timeLeftBackground = timeLeftBackground
	button.amountText = amountText
	button.amountBackground = amountBackground
	button.criteriaIndicator = criteriaIndicator
	button.criteriaHighlight = criteriaHighlight
	button.criteriaIndicatorGlow = criteriaIndicatorGlow
	button.isWorldMapWidget = true

	return button
end

function WorldQuestTracker.CreateWorldMapWidget(mapName, index, parent)
	local newWidget = create_worldmap_square(mapName, index, parent)
	return newWidget
end

WorldQuestTracker.QUEST_POI_FRAME_WIDTH = 1
WorldQuestTracker.QUEST_POI_FRAME_HEIGHT = 1

--> anchor for world quests hub, this is only shown on world maps
function WorldQuestTracker.UpdateAllWorldMapAnchors(worldMapID)
	for mapId, configTable in pairs(WorldQuestTracker.mapTables) do
		if (configTable.show_on_map == worldMapID) then
			local x, y = configTable.Anchor_X, configTable.Anchor_Y
			WorldQuestTracker.UpdateWorldMapAnchors(x, y, configTable.MapAnchor)

			local mapInfo = C_Map.GetMapInfo(mapId)
			local mapName = mapInfo and mapInfo.name or "wrong map id"

			configTable.MapAnchor.Title:SetText(mapName)

			configTable.MapAnchor.Title:ClearAllPoints()
			configTable.MapAnchor.Title:Show()
			if (configTable.GrowRight) then
				configTable.MapAnchor.Title:SetPoint("bottomleft", configTable.MapAnchor, "topleft", 0, 0)
				configTable.MapAnchor.Title:SetJustifyH("left")
			else
				configTable.MapAnchor.Title:SetPoint("bottomright", configTable.MapAnchor, "topright", 0, 0)
				configTable.MapAnchor.Title:SetJustifyH("right")
			end

			configTable.MapAnchor:Show()
			configTable.factionFrame:Show()
		else
			configTable.MapAnchor:Hide()
			configTable.factionFrame:Hide()
		end
	end
end

function WorldQuestTracker.UpdateWorldMapAnchors(x, y, frame)
	WorldQuestTrackerAddon.DataProvider:GetMap():SetPinPosition(frame.AnchorFrame or frame, x, y)
end

local re_InitializeWorldWidgets = function()
	WorldQuestTracker.InitializeWorldWidgets()
end

local lazyCreateWorldWidget = function(tickerObject)
	local i = #WorldQuestTracker.WorldSummaryQuestsSquares + 1
	local summarySquare = create_worldmap_square("WorldQuestTrackerWorldSummarySquare", i, WorldQuestTracker.WorldSummary)
	table.insert(all_widgets, summarySquare)
	summarySquare:Hide()
	table.insert(WorldQuestTracker.WorldSummaryQuestsSquares, summarySquare)

	if (i == 120) then
		tickerObject:Cancel()
		WorldQuestTracker.WorldWidgetsCreationTask = nil
	end
end

function WorldQuestTracker.InitializeWorldWidgets()
	if (WorldQuestTracker.WorldMapFrameSummarySquareReference) then
		return
	end

	if (not WorldQuestTracker.DataProvider) then
		WorldQuestTrackerAddon.CatchMapProvider(true)

		if (not WorldQuestTracker.DataProvider) then
			C_Timer.After(.5, re_InitializeWorldWidgets)
		end
	end

	--schedule cleanup: anchors isn't used anymore in the new anchoring system
	for mapId, configTable in pairs(WorldQuestTracker.mapTables) do
		local anchor = CreateFrame("button", nil, worldFramePOIs, "BackdropTemplate")
		anchor:SetSize(1, 1)

		local anchorFrame = CreateFrame("button", nil, worldFramePOIs, WorldQuestTracker.DataProvider:GetPinTemplate())
		anchorFrame.dataProvider = WorldQuestTracker.DataProvider
		anchorFrame.worldQuest = true
		anchorFrame.owningMap = WorldQuestTracker.DataProvider:GetMap()
		anchorFrame.questID = 1
		anchorFrame.numObjectives = 1

		anchor:SetPoint("center", anchorFrame, "center", 0, 0)
		anchor.AnchorFrame = anchorFrame

		local x, y = configTable.Anchor_X, configTable.Anchor_Y
		configTable.MapAnchor = anchor

		WorldQuestTracker.UpdateWorldMapAnchors(x, y, anchor)

		local anchorText = anchor:CreateFontString(nil, "artwork", "GameFontNormal")
		anchorText:SetPoint("bottomleft", anchor, "topleft", 0, 0)
		anchor.Title = anchorText

		local factionFrame = CreateFrame("button", "WorldQuestTrackerFactionFrame" .. mapId, worldFramePOIs, "BackdropTemplate")
		table.insert(faction_frames, factionFrame)
		factionFrame:SetSize(20, 20)
		configTable.factionFrame = factionFrame

		table.insert(all_widgets, factionFrame)
		table.insert(all_widgets, anchorText)
	end

	WorldQuestTracker.WorldSummaryQuestsSquares = {}

	--cria algums widgets usados no mapa da zona
	for i = 1, 12 do
		local zoneWidget = WorldQuestTracker.GetOrCreateZoneWidget(i)
		zoneWidget:Hide()
	end

	--cria o primeiro widget no sum�rio e depois cria os demais lentamente
	local i = 1
	local button = create_worldmap_square("WorldQuestTrackerWorldSummarySquare", i, WorldQuestTracker.WorldSummary)
	table.insert(all_widgets, button)
	button:Hide()
	table.insert(WorldQuestTracker.WorldSummaryQuestsSquares, button)
	WorldQuestTracker.WorldMapFrameSummarySquareReference = WorldQuestTracker.WorldSummaryQuestsSquares[1]

	WorldQuestTracker.WorldWidgetsCreationTask = C_Timer.NewTicker(.03, lazyCreateWorldWidget)
end

--agenda uma atualiza��o nos widgets do world map caso os dados das quests estejam indispon�veis
local do_worldmap_update = function(newTimer)
	if (WorldQuestTracker.IsWorldQuestHub(WorldQuestTracker.GetCurrentMapAreaID())) then
		WorldQuestTracker.UpdateWorldQuestsOnWorldMap(true, false, false, false, newTimer.QuestList) --no cache true
	else
		if (WorldQuestTracker.ScheduledWorldUpdate and not WorldQuestTracker.ScheduledWorldUpdate._cancelled) then
			WorldQuestTracker.ScheduledWorldUpdate:Cancel()
		end
	end
end

---@alias questid number

---@param seconds number
---@param questList table<questid, boolean>
function WorldQuestTracker.ScheduleWorldMapUpdate(seconds, questList)
	if (time() > WorldQuestTracker.MapChangedTime + 5) then
		if (WorldQuestTracker.IsPlayingLoadAnimation()) then
			WorldQuestTracker.StopLoadingAnimation()
		end
		return
	end

	if (WorldQuestTracker.ScheduledWorldUpdate and not WorldQuestTracker.ScheduledWorldUpdate._cancelled) then
		WorldQuestTracker.ScheduledWorldUpdate:Cancel()
	end

	WorldQuestTracker.ScheduledWorldUpdate = C_Timer.NewTimer(seconds or 1, do_worldmap_update)
	WorldQuestTracker.ScheduledWorldUpdate.QuestList = nil --questList
end

--each 60 seconds the client dumps quest reward data received from the server
C_Timer.NewTicker(60, function()
	wipe(WorldQuestTracker.HasQuestData)
end)

--wipe retry cache each 10 minutes
C_Timer.NewTicker(600, function()
	wipe(forceRetryForHub)
end)

function WorldQuestTracker.GetWorldWidgetForQuest(questID)
	for i = 1, #all_widgets do
		local widget = all_widgets [i]
		if (widget:IsShown() and widget.questID == questID) then
			return widget
		end
	end
end

-- ~update
---@param widget table
---@param questData wqt_questdata
---@param bIsUsingTracker boolean?
function WorldQuestTracker.UpdateWorldWidget(widget, questData, bIsUsingTracker)
	local questID = questData.questID
	local numObjectives = questData.numObjectives
	local mapID = questData.mapID
	local isCriteria = questData.isCriteria
	local isNew = questData.isNew
	local timeLeft = questData.timeLeft
	local artifactPowerIcon = questData.rewardTexture
	local title = questData.title
	local factionID = questData.factionID
	local tagID = questData.tagID
	local worldQuestType = questData.worldQuestType
	local rarity = questData.rarity
	local isElite = questData.isElite
	local tradeskillLineIndex = questData.tradeskillLineIndex
	local allowDisplayPastCritical = false
	local gold = questData.gold
	local goldFormated = questData.goldFormated
	local rewardName = questData.rewardName
	local rewardTexture = questData.rewardTexture
	local numRewardItems = questData.numRewardItems
	local itemName = questData.itemName
	local itemTexture = questData.itemTexture
	local itemLevel = questData.itemLevel
	local quantity = questData.quantity
	local quality = questData.quality
	local isUsable = questData.isUsable
	local itemID = questData.itemID
	local isArtifact = questData.isArtifact
	local artifactPower = questData.artifactPower
	local isStackable = questData.isStackable
	local stackAmount = questData.stackAmount
	local bWarband = questData.bWarband
	local bWarbandRep = questData.bWarbandRep

	if (bIsUsingTracker == nil) then
		bIsUsingTracker = WorldQuestTracker.db.profile.use_tracker
	end

	local bCanCache = true

	local haveQuestData = HaveQuestData(questID)
	local haveQuestRewardData = HaveQuestRewardData(questID)

	if (not haveQuestData) then
		if (WorldQuestTracker.__debug) then
			WorldQuestTracker:Msg("no HaveQuestData(6) for quest", questID)
		end
	end

	if (not haveQuestRewardData) then
		if (WorldQuestTracker.__debug) then
			WorldQuestTracker:Msg("no HaveQuestRewardData(2) for quest", questID)
		end
		C_TaskQuest.RequestPreloadRewardData(questID)
		bCanCache = false
	end

	widget.questID = questID
	widget.lastQuestID = questID
	widget.worldQuest = true
	widget.numObjectives = numObjectives
	widget.mapID = mapID
	widget.Amount = 0
	widget.FactionID = factionID
	widget.Rarity = rarity
	widget.WorldQuestType = worldQuestType
	widget.IsCriteria = isCriteria
	widget.TimeLeft = timeLeft
	widget.isArtifact = false

	local bAwardReputation = C_QuestLog.DoesQuestAwardReputationWithFaction(questID or 0, factionID or 0)
	if (not bAwardReputation) then
		widget.FactionID = nil
		factionID = nil
	end

	if (isArtifact) then
		artifactPowerIcon = WorldQuestTracker.GetArtifactPowerIcon(isArtifact, true, questID)
		widget.isArtifact = isArtifact
		widget.ArtifactPowerIcon = artifactPowerIcon
	end

	widget.amountText:SetText("")
	widget.amountBackground:Hide()
	widget.timeLeftBackground:Hide()

	widget.IconTexture = nil
	widget.IconText = nil
	widget.QuestType = nil

	if (isCriteria) then
		widget.criteriaIndicator:Show()
		widget.criteriaHighlight:Show()
		widget.criteriaIndicatorGlow:Show()
	else
		widget.criteriaIndicator:Hide()
		widget.criteriaHighlight:Hide()
		widget.criteriaIndicatorGlow:Hide()
	end

	if (bWarband and WorldQuestTracker.db.profile.show_warband_rep_warning) then
		if (not bWarbandRep) then
			widget.criteriaIndicator:Show()
			widget.criteriaIndicator:SetVertexColor(DF:ParseColors(WorldQuestTracker.db.profile.show_warband_rep_warning_color))
			widget.criteriaIndicator:SetAlpha(WorldQuestTracker.db.profile.show_warband_rep_warning_alpha)
			widget.texture:SetDesaturation(WorldQuestTracker.db.profile.show_warband_rep_warning_desaturation)
			widget.criteriaIndicatorGlow:Show()
			widget.criteriaIndicatorGlow:SetAlpha(0.7)
		else
			widget.criteriaIndicator:Hide()
			widget.criteriaIndicatorGlow:Hide()
			widget.texture:SetDesaturation(0)
		end
	end

	if (isNew) then
		widget.newIndicator:Show()
		widget.newFlash:Play()
	else
		widget.newIndicator:Hide()
	end

	if (not bIsUsingTracker) then
		if (WorldQuestTracker.IsQuestOnObjectiveTracker(questID)) then
			widget.trackingGlowBorder:Show()
		else
			widget.trackingGlowBorder:Hide()
		end
	else
		if (WorldQuestTracker.IsQuestBeingTracked(questID)) then
			widget.trackingGlowBorder:Show()
			widget.trackingGlowInside:Show()
			widget:SetAlpha(1)
		else
			widget.trackingGlowBorder:Hide()
			widget.trackingGlowInside:Hide()
			widget:SetAlpha(WorldQuestTracker.db.profile.world_summary_alpha)
		end
	end

	widget.timeBlipRed:Hide()
	widget.timeBlipOrange:Hide()
	widget.timeBlipYellow:Hide()
	widget.timeBlipGreen:Hide()

	if (not WorldQuestTracker.db.profile.show_timeleft) then
		WorldQuestTracker.SetTimeBlipColor(widget, timeLeft)
	end

	if (widget.FactionPulseAnimation and widget.FactionPulseAnimation:IsPlaying()) then
		button.FactionPulseAnimation:Stop()
	end

	widget.amountBackground:SetWidth(32)

	if (worldQuestType == LE_QUEST_TAG_TYPE_PVP) then
		widget.questTypeBlip:Show()
		widget.questTypeBlip:SetTexture([[Interface\PVPFrame\Icon-Combat]])
		widget.questTypeBlip:SetTexCoord(0, 1, 0, 1)
		widget.questTypeBlip:SetAlpha(.98)

	elseif (worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE) then
		widget.questTypeBlip:Show()
		--widget.questTypeBlip:SetTexture([[Interface\MINIMAP\ObjectIconsAtlas]])
		widget.questTypeBlip:SetTexture(WorldQuestTracker.MapData.QuestTypeIcons [WQT_QUESTTYPE_PETBATTLE].icon)
		widget.questTypeBlip:SetTexCoord(unpack(WorldQuestTracker.MapData.QuestTypeIcons [WQT_QUESTTYPE_PETBATTLE].coords))
		widget.questTypeBlip:SetAlpha(.98)

	elseif (worldQuestType == LE_QUEST_TAG_TYPE_DUNGEON) then
		widget.questTypeBlip:Show()
		widget.questTypeBlip:SetTexture([[Interface\Scenarios\ScenarioIcon-Boss]])
		widget.questTypeBlip:SetTexCoord(0, 1, 0, 1)
		widget.questTypeBlip:SetAlpha(.98)

	elseif (rarity == LE_WORLD_QUEST_QUALITY_RARE and isElite) then
		--it is always adding the star of rare quests, but some rare quests aren't elite
		--now it's using the old blue border, so the blue star can be used only for rare elite quests
		widget.questTypeBlip:Show()
		widget.questTypeBlip:SetTexture([[Interface\AddOns\WorldQuestTracker\media\icon_star]])
		widget.questTypeBlip:SetTexCoord(6/32, 26/32, 5/32, 27/32)
		widget.questTypeBlip:SetAlpha(.894)

	elseif (worldQuestType == LE_QUEST_TAG_TYPE_FACTION_ASSAULT) then --LE_QUEST_TAG_TYPE_INVASION(legion)
		if (UnitFactionGroup("player") == "Alliance") then
			widget.questTypeBlip:SetTexture([[Interface\COMMON\icon-alliance]])
			widget.questTypeBlip:SetTexCoord(20/64, 46/64, 14/64, 48/64)

		elseif (UnitFactionGroup("player") == "Horde") then
			widget.questTypeBlip:SetTexture([[Interface\COMMON\icon-horde]])
			widget.questTypeBlip:SetTexCoord(17/64, 49/64, 15/64, 47/64)
		end

		widget.questTypeBlip:Show()
		widget.questTypeBlip:SetAlpha(1)
	else
		widget.questTypeBlip:Hide()
	end

	local okay, amountGold, amountAPower, amountResources = false, 0, 0, 0

	if (gold > 0) then
		local texture, coords = WorldQuestTracker.GetGoldIcon()
		widget.texture:SetTexture(texture)
		--widget.texture:SetTexture("") --debug border

		widget.amountText:SetText(goldFormated)
		widget.amountBackground:Show()

		widget.IconTexture = texture
		widget.IconText = goldFormated
		widget.QuestType = QUESTTYPE_GOLD
		widget.Amount = gold
		amountGold = gold

		if (not widget.IsZoneSummaryQuestButton) then
			DF.table.addunique(WorldQuestTracker.Cache_ShownQuestOnWorldMap[WQT_QUESTTYPE_GOLD], questID)
		end

		okay = true
	end

	if (rewardName and not okay) then
		widget.texture:SetTexture(WorldQuestTracker.MapData.ReplaceIcon[rewardTexture] or rewardTexture)

		if (numRewardItems >= 1000) then
			widget.amountText:SetText(format("%.1fK", numRewardItems/1000))
			widget.amountBackground:SetWidth(40)
		else
			widget.amountText:SetText(numRewardItems)
		end

		widget.amountBackground:Show()

		widget.IconTexture = rewardTexture
		widget.IconText = numRewardItems
		widget.Amount = numRewardItems

		if (WorldQuestTracker.MapData.ResourceIcons[rewardTexture]) then
			amountResources = numRewardItems
			widget.QuestType = QUESTTYPE_RESOURCE

			if (not widget.IsZoneSummaryQuestButton) then
				DF.table.addunique(WorldQuestTracker.Cache_ShownQuestOnWorldMap[WQT_QUESTTYPE_RESOURCE], questID)
			end
		else
			amountResources = 0
		end

		okay = true
		--print(title, rewardTexture) --show the quest name and the texture ID
	end

	if (itemName) then
		if (widget.isArtifact) then
			local artifactIcon = widget.ArtifactPowerIcon

			widget.texture:SetTexture(artifactIcon)

			if (artifactPower >= 1000) then
				if (artifactPower > 999999) then
					widget.amountText:SetText(WorldQuestTracker.ToK(artifactPower))
					local text = widget.amountText:GetText()
					text = text:gsub("%.0", "")
					widget.amountText:SetText(text)

				elseif (artifactPower > 9999) then
					widget.amountText:SetText(WorldQuestTracker.ToK(artifactPower))

				else
					widget.amountText:SetText(format("%.1fK", artifactPower/1000))
				end

				widget.amountBackground:SetWidth(36)
			else
				widget.amountText:SetText(artifactPower)
			end

			widget.amountBackground:Show()

			local artifactIcon = artifactPowerIcon
			widget.IconTexture = artifactIcon
			widget.IconText = artifactPower
			widget.QuestType = QUESTTYPE_ARTIFACTPOWER
			widget.Amount = artifactPower

			if (not widget.IsZoneSummaryQuestButton) then
				DF.table.addunique(WorldQuestTracker.Cache_ShownQuestOnWorldMap [WQT_QUESTTYPE_APOWER], questID)
			end

			amountAPower = artifactPower
		else
			if (WorldQuestTracker.IsRacingQuest(tagID)) then
				--widget.texture:SetAtlas("worldquest-icon-race")
				widget.texture:SetTexture([[Interface\AddOns\WorldQuestTracker\media\icon_racing]])
			else
				widget.texture:SetTexture(itemTexture)
			end

			local color = ""
			if (quality == 4 or quality == 3) then
				color =  WorldQuestTracker.RarityColors [quality]
			end
			widget.amountText:SetText((isStackable and quantity and quantity >= 1 and quantity or false) or(itemLevel and itemLevel > 5 and(color) .. itemLevel) or "")

			if (widget.amountText:GetText() and widget.amountText:GetText() ~= "") then
				widget.amountBackground:Show()
			else
				widget.amountBackground:Hide()
			end

			widget.IconTexture = itemTexture
			widget.IconText = widget.amountText:GetText()
			widget.QuestType = QUESTTYPE_ITEM
		end

		WorldQuestTracker.AllCharactersQuests_Add(questID, timeLeft, widget.IconTexture, widget.IconText)
		okay = true
	end

	if (okay) then
		local conduitType, borderTexture, borderColor, itemLink = WorldQuestTracker.GetConduitQuestData(questID)
		WorldQuestTracker.UpdateBorder(widget)
	else
		widget.texture:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
		widget.amountText:SetText("")
		widget.IconText = ""
	end

	return okay, amountGold, amountResources, amountAPower
end

---from the OnMapChanged when the map shown is a quest hub
function WorldQuestTracker.ShowWorldQuestPinsOnNextFrame()
	if (WorldQuestTracker.DelayedWorldQuestUpdate) then
		return
	end

	--run on next frame
	WorldQuestTracker.DelayedWorldQuestUpdate = C_Timer.NewTimer(0, function()
		WorldQuestTracker.DelayedWorldQuestUpdate = nil
		if (WorldMapFrame and WorldMapFrame:IsShown() and WorldQuestTracker.IsWorldQuestHub(WorldMapFrame.mapID)) then
			WorldQuestTracker.UpdateWorldQuestsOnWorldMap(true)
		end
	end)
end

--recursively find map hub children
--this will list all sub hubs in the parent map, e.g. showing azeroth map will track down world quests in continents and continents areas
function WorldQuestTracker.BuildMapChildrenTable(parentMap, t)
	t = t or {}
	local newChildren = {}
	for mapID, mapTable in pairs(WorldQuestTracker.mapTables) do
		if (mapTable.show_on_map[parentMap]) then
			t[mapID] = true
			newChildren[mapID] = true
		end
	end

	if (next(newChildren)) then
		for newMapChildren in pairs(newChildren) do
			WorldQuestTracker.BuildMapChildrenTable(newMapChildren, t)
		end
	end

	return t
end

WorldQuestTracker.POIPins = {}
--hide all poi pins
function WorldQuestTracker.HideAllPOIPins()
	for i = 1, #WorldQuestTracker.POIPins do
		WorldQuestTracker.POIPins[i]:Hide()
	end
end

local questLoadFailedAmount = {}
local worldQuestLockedIndex = 1
-- ~world -- ~update
function WorldQuestTracker.UpdateWorldQuestsOnWorldMap(noCache, showFade, isQuestFlaggedRecheck, forceCriteriaAnimation, questList)
	if InCombatLockdown() then
		return
	end
	if (UnitLevel("player") < 50) then --this has to be improved
		WorldQuestTracker.HideWorldQuestsOnWorldMap()

		--> show a message telling why world quests aren't shown
		if (WorldQuestTracker.db.profile and not WorldQuestTracker.db.profile.low_level_tutorial) then
			WorldQuestTracker.db.profile.low_level_tutorial = true
			WorldQuestTracker:Msg(L["World quests aren't shown because you're below level 50."]) --> localize-me
		end
		return
	end

	--print(debugstack())

	local WorldMapFrame = WorldMapFrame

	WorldQuestTrackerDataProvider:GetMap():RemoveAllPinsByTemplate("WorldQuestTrackerPOIPinTemplate")

	WorldQuestTracker.ExtraQuests = WorldQuestTracker.ExtraQuests or {}
	wipe(WorldQuestTracker.ExtraQuests)

	for poiId, poiInfo in pairs(WorldQuestTracker.db.profile.pins_discovered["worldquest-Capstone-questmarker-epic-Locked"]) do
		---@cast poiInfo wqt_poidata
		local worldMapID = WorldQuestTracker.GetCurrentMapAreaID()

		if (poiInfo.continentID == worldMapID) then
			--double check if the quest is on the map
			if (C_AreaPoiInfo.GetAreaPOIInfo(poiInfo.mapID, poiInfo.poiID)) then
				local pin = WorldQuestTrackerDataProvider:GetMap():AcquirePin("WorldQuestTrackerPOIPinTemplate")

				if (not pin.widget) then
					local button = WorldQuestTracker.CreateZoneWidget(worldQuestLockedIndex, "WorldQuestTrackerLockedQuestButton", worldFramePOIs) --, "WorldQuestTrackerPOIPinTemplate"
					button.IsWorldZoneQuestButton = true
					button:SetPoint("center", pin, "center", 0, 0)
					worldQuestLockedIndex = worldQuestLockedIndex + 1
					pin.button = button
					pin.widget = button
					pin:SetSize(20, 20)

					button:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
						if (poiInfo.tooltipSetId) then
							GameTooltip_AddWidgetSet(GameTooltip, poiInfo.tooltipSetId, 0)
						end
						GameTooltip:Show()
					end)

					button:SetScript("OnLeave", function(self)
						GameTooltip:Hide()
					end)

					button.UpdateTooltip = nil

					WorldQuestTracker.POIPins[#WorldQuestTracker.POIPins+1] = button
				end

				WorldQuestTracker.ResetWorldQuestZoneButton(pin.button)
				pin:SetPosition(poiInfo.worldX, poiInfo.worldY)
				pin.button.Texture:SetMask("")
				pin.button.Texture:SetAtlas("worldquest-Capstone-questmarker-epic-Locked")
				pin.button.Texture:SetSize(32, 32)
				pin.button.poiInfo = poiInfo
				pin.button:Show()

				WorldQuestTracker.ExtraQuests[#WorldQuestTracker.ExtraQuests+1] = {
					questID = 0,
					pin = pin,
					poiInfo = poiInfo,
					atlas = "worldquest-Capstone-questmarker-epic-Locked",
					texture = [[Interface\AddOns\WorldQuestTracker\media\chestlocked.png]] --1542857, [[Interface\ICONS\inv_misc_treasurechest04c]]
				}
			end
		end
	end

	WorldQuestTracker.RefreshStatusBarVisibility()
	WorldQuestTracker.ClearZoneSummaryButtons()

	WorldQuestTracker.LastUpdate = GetTime()
	wipe(factionAmountForEachMap)

	if (WorldQuestTracker.WorldWidgets_NeedFullRefresh) then
		WorldQuestTracker.WorldWidgets_NeedFullRefresh = nil
		noCache = true
	end

	local questsAvailable = {}
	local needAnotherUpdate = false
	local filters = WorldQuestTracker.db.profile.filters
	local timePriority = WorldQuestTracker.db.profile.sort_time_priority and WorldQuestTracker.db.profile.sort_time_priority * 60 --4 8 12 16 24
	local forceShowBrokenShore = WorldQuestTracker.db.profile.filter_force_show_brokenshore

	local sortByTimeLeft = WorldQuestTracker.db.profile.force_sort_by_timeleft
	local worldMapID = WorldQuestTracker.GetCurrentMapAreaID()
	local bountyQuestID = WorldQuestTracker.GetCurrentBountyQuest()

	--store a list of quests that failed to update on this refresh
	local failedToUpdate = {}

	local mapChildren = WorldQuestTracker.BuildMapChildrenTable(WorldMapFrame.mapID)
	local bannedQuests = WorldQuestTracker.db.profile.banned_quests
	local totalQuests = 0

	for mapId, configTable in pairs(WorldQuestTracker.mapTables) do
		--get the map name
		local mapInfo = C_Map.GetMapInfo(mapId)
		local mapName = mapInfo and mapInfo.name or "wrong map id"

		if (configTable.show_on_map[worldMapID]) then
			questsAvailable[mapId] = {}
			local taskInfo = GetQuestsForPlayerByMapID(mapId, mapId)
			local shownQuests = 0

			if (taskInfo and #taskInfo > 0) then
				for i, info in ipairs(taskInfo) do
					local questID = info.questID
					local canUpdateQuest = false

					if (not questList) then
						canUpdateQuest = true

					elseif (questList[questID]) then
						canUpdateQuest = true
					end

					if (canUpdateQuest or not WorldQuestTracker.HasQuestData[questID] or not WorldQuestTracker.WorldSummary[questID]) then
						local bIsWorldQuest = isWorldQuest(questID)
						if (bIsWorldQuest) then
							local haveQuestData = HaveQuestData(questID)
							local haveQuestRewardData = HaveQuestRewardData(questID)

							if (haveQuestData and haveQuestRewardData) then
								WorldQuestTracker.HasQuestData[questID] = true

								local bIsNotBanned = not bannedQuests[questID]
								local overridedMapId = WorldQuestTracker.MapData.OverrideMapId[mapId] or mapId
								local overridedTaskMapId = WorldQuestTracker.MapData.OverrideMapId[info.mapID] or info.mapID

								local bMapIDMatch = overridedMapId == overridedTaskMapId
								local bMapIdAzeroth = WorldMapFrame.mapID == WorldQuestTracker.MapData.ZoneIDs.AZEROTH and mapChildren[info.mapID]

								--if is showing the azeroth map, check if this map is a child of azeroth
								if (bIsNotBanned and (bMapIDMatch or bMapIdAzeroth)) then
									local title, factionID, tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, allowDisplayPastCritical, gold, goldFormated, rewardName, rewardTexture, numRewardItems, itemName, itemTexture, itemLevel, quantity, quality, isUsable, itemID, isArtifact, artifactPower, isStackable, stackAmount = WorldQuestTracker.GetOrLoadQuestData(questID, true)

									--time left
									local timeLeft = WorldQuestTracker.GetQuest_TimeLeft(questID)

									local bHasNotLoadedRewardData = (not gold or gold <= 0) and not rewardName and not itemName
									if (bHasNotLoadedRewardData) then
										C_TaskQuest.RequestPreloadRewardData(questID)
										questLoadFailedAmount[questID] = (questLoadFailedAmount[questID] or 0) + 1

										if (questLoadFailedAmount[questID] < 3) then
											needAnotherUpdate = true
											failedToUpdate[questID] = true
											if (UpdateDebug) then print("NeedUpdate 1") end
										end
									end

									local filter, order = WorldQuestTracker.GetQuestFilterTypeAndOrder(worldQuestType, gold, rewardName, itemName, isArtifact, stackAmount, numRewardItems, rewardTexture, tagID)
									order = order or 1

									if (sortByTimeLeft) then
										order = math.abs(timeLeft - 10000)

									elseif (timePriority) then --timePriority j� multiplicado por 60
										if (timeLeft < timePriority) then
											order = math.abs(timeLeft - 1000)
										end
									end

									if (filters[filter] or worldQuestType == LE_QUEST_TAG_TYPE_FACTION_ASSAULT or rarity == LE_WORLD_QUEST_QUALITY_EPIC or(forceShowBrokenShore and WorldQuestTracker.IsNewEXPZone(mapId))) then --force show broken shore questsmapId == 1021
										table.insert(questsAvailable[mapId], {questID, order, info.numObjectives, info.x, info.y, filter})
										shownQuests = shownQuests + 1
										totalQuests = totalQuests + 1

									elseif (WorldQuestTracker.db.profile.filter_always_show_faction_objectives) then
										local isCriteria = IsQuestCriteriaForBounty(questID, bountyQuestID)

										if (isCriteria) then
											table.insert(questsAvailable[mapId], {questID, order, info.numObjectives, info.x, info.y, filter})
											shownQuests = shownQuests + 1
											totalQuests = totalQuests + 1
										end
									end
								end --is world quest and the map is valid
							else --dont have quest data
								--> check if isn't a quest removed from the game before request data from server
								local title = WorldQuestTracker.GetQuest_Info(questID)
								if (title) then
									C_TaskQuest.RequestPreloadRewardData(questID)
									failedToUpdate[questID] = true
									needAnotherUpdate = true
									if (UpdateDebug) then print("NeedUpdate 2") end
								end

							end --end have quest data
						end --end isWorldQuest
					end --end can update quest
				end

				table.sort(questsAvailable[mapId], function(t1, t2) return t1[2] < t2[2] end)
			else
				if (not taskInfo) then
					needAnotherUpdate = true
					if (UpdateDebug) then print("NeedUpdate 3", mapId, taskInfo) end
				end
			end
		end --show on mapId
	end --end of pairs on mapTables

	local availableQuests = 0

	wipe(WorldQuestTracker.Cache_ShownQuestOnWorldMap)

	WorldQuestTracker.Cache_ShownQuestOnWorldMap[WQT_QUESTTYPE_GOLD] = {}
	WorldQuestTracker.Cache_ShownQuestOnWorldMap[WQT_QUESTTYPE_RESOURCE] = {}
	WorldQuestTracker.Cache_ShownQuestOnWorldMap[WQT_QUESTTYPE_APOWER] = {}

	local worldMapID = WorldQuestTracker.GetCurrentMapAreaID()

	---@type wqt_questdata[], number
	local questData_AddToWorldMap, questCounter = {}, 1

	for mapId, configTable in pairs(WorldQuestTracker.mapTables) do
		if (configTable.show_on_map[worldMapID]) then
			local taskInfo = GetQuestsForPlayerByMapID(mapId, mapId)
			local taskIconIndex = 1

			if (taskInfo and #taskInfo > 0) then
				availableQuests = availableQuests + #taskInfo

				for i, quest in ipairs(questsAvailable[mapId]) do
					local questID = quest[1]

					local bIsWorldQuest = isWorldQuest(questID)
					if (bIsWorldQuest) then
						local numObjectives = quest[3]

						--is a new quest?
						local isNew = WorldQuestTracker.SavedQuestList_IsNew(questID)

						--this runs on the same tick as the quest avaliability check, it's guarantee the client has the quest reward data
						local title, factionID, tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, allowDisplayPastCritical, gold, goldFormated, rewardName, rewardTexture, numRewardItems, itemName, itemTexture, itemLevel, quantity, quality, isUsable, itemID, isArtifact, artifactPower, isStackable, stackAmount = WorldQuestTracker.GetOrLoadQuestData(questID, true)

						--tempo restante
						local timeLeft = WorldQuestTracker.GetQuest_TimeLeft(questID)
						if (not timeLeft or timeLeft == 0) then
							timeLeft = 1
						end

						--is a bounty criteria
						local isCriteria = C_QuestLog.IsQuestCriteriaForBounty(questID, bountyQuestID)
						if (isCriteria) then
							factionAmountForEachMap[mapId] = (factionAmountForEachMap[mapId] or 0) + 1
						end

						--add to the update schedule
						---@class wqt_questdata
						---@field questID number
						---@field mapID number
						---@field numObjectives number
						---@field questCounter number
						---@field title string
						---@field x number
						---@field y number
						---@field filter number
						---@field worldQuestType number
						---@field isCriteria boolean
						---@field isNew boolean
						---@field timeLeft number
						---@field order number
						---@field rarity number
						---@field isElite boolean
						---@field tradeskillLineIndex number
						---@field factionID number
						---@field bWarband boolean?
						---@field bWarbandRep boolean?
						---@field tagID number
						---@field tagName string
						---@field gold number
						---@field goldFormated string
						---@field rewardName string
						---@field rewardTexture string
						---@field numRewardItems number
						---@field itemName string
						---@field itemTexture string
						---@field itemLevel number
						---@field quantity number
						---@field quality number
						---@field isUsable boolean
						---@field itemID number
						---@field isArtifact boolean
						---@field artifactPower number
						---@field isStackable boolean
						---@field stackAmount number
						---@field inProgress boolean
						---@field selected boolean
						---@field isSpellTarget boolean

						local bWarband, bWarbandRep = WorldQuestTracker.GetQuestWarbandInfo(questID, factionID)

						---@type wqt_questdata
						local questData = {
							questID = questID,
							mapID = mapId,
							numObjectives = numObjectives,
							questCounter = questCounter,
							title = title,
							x = quest[4],
							y = quest[5],
							filter = quest[6],
							worldQuestType = worldQuestType,
							isCriteria = isCriteria,
							isNew = isNew,
							timeLeft = timeLeft,
							order = quest[2],
							rarity = rarity,
							isElite = isElite,
							tradeskillLineIndex = tradeskillLineIndex,
							factionID = factionID,
							bWarband = bWarband,
							bWarbandRep = bWarbandRep,
							tagID = tagID,
							tagName = tagName,
							gold = gold,
							goldFormated = goldFormated,
							rewardName = rewardName,
							rewardTexture = rewardTexture,
							numRewardItems = numRewardItems,
							itemName = itemName,
							itemTexture = itemTexture,
							itemLevel = itemLevel,
							quantity = quantity,
							quality = quality,
							isUsable = isUsable,
							itemID = itemID,
							isArtifact = isArtifact,
							artifactPower = artifactPower,
							isStackable = isStackable,
							stackAmount = stackAmount,
							inProgress = false,
							selected = false,
							isSpellTarget = false,
						}

						table.insert(questData_AddToWorldMap, questData)

						questCounter = questCounter + 1
						taskIconIndex = taskIconIndex + 1
					end
				end
			else
				if (not taskInfo) then
					needAnotherUpdate = true
					if (UpdateDebug) then print("NeedUpdate 6") end
				end
			end
		end

		--quantidade de quest para a faccao
		configTable.factionFrame.amount = factionAmountForEachMap[mapId]
	end

	--force retry in case the game just opened and the server might not has sent all quests
	forceRetryForHub[WorldMapFrame.mapID] = forceRetryForHub[WorldMapFrame.mapID] or forceRetryForHubAmount

	if (forceRetryForHub[WorldMapFrame.mapID] > 0) then
		needAnotherUpdate = true
		forceRetryForHub[WorldMapFrame.mapID] = forceRetryForHub[WorldMapFrame.mapID] - 1
	end

	local bScheduledUpdate = false

	if (needAnotherUpdate) then
		if (WorldMapFrame:IsShown()) then
			if (next(failedToUpdate)) then
				waitForQuestData(failedToUpdate)
			else
				loadQuestData()
				WorldQuestTracker.ScheduleWorldMapUpdate(CONST_QUEST_LOADINGTIME, failedToUpdate)
				WorldQuestTracker.PlayLoadingAnimation()
				bScheduledUpdate = true
			end
		end
	else
		if (WorldQuestTracker.IsPlayingLoadAnimation()) then
			WorldQuestTracker.StopLoadingAnimation()
		end
	end

	--[=[
	if (showFade) then
		worldFramePOIs.fadeInAnimation:Play()

	elseif (type(showFade) ~= "boolean") then --showFade is nil only in the first update
		print("wait a minute")
		if (not bScheduledUpdate) then
			loadQuestData()
			WorldQuestTracker.ScheduleWorldMapUpdate(CONST_QUEST_LOADINGTIME, {})
			WorldQuestTracker.PlayLoadingAnimation()
			bScheduledUpdate = true
		end
	end
	--]=]

	if (availableQuests == 0 and (WorldQuestTracker.InitAt or 0) + 10 > GetTime()) then
		if (not bScheduledUpdate) then
			loadQuestData()
			WorldQuestTracker.ScheduleWorldMapUpdate(CONST_QUEST_LOADINGTIME, {})
		end
	end

	--> need update the anchors for windowed and fullscreen modes, plus need to show and hide for different worlds
	WorldQuestTracker.UpdateAllWorldMapAnchors(worldMapID)

	WorldQuestTracker.HideZoneWidgets()
	WorldQuestTracker.SavedQuestList_CleanUp()

	if (not WorldQuestTracker.db.profile.disable_world_map_widgets and WorldMapFrame.mapID ~= WorldQuestTracker.MapData.ZoneIDs.AZEROTH) then
		WorldQuestTracker.LazyUpdateWorldMapSmallIcons(questData_AddToWorldMap, questList)
	else
		local map = WorldQuestTrackerDataProvider:GetMap()
		for pin in map:EnumeratePinsByTemplate("WorldQuestTrackerWorldMapPinTemplate") do
			if (pin.Child) then
				pin.Child:Hide()
			end
			map:RemovePin(pin)
		end
	end

	--WorldQuestTracker.ExtraQuests

	WorldQuestTracker.WorldSummary.StartLazyUpdate(questData_AddToWorldMap, questList)
	WorldQuestTracker.DoAnimationsOnWorldMapWidgets = false

	---@type wqt_questdata[]
	WorldQuestTracker.QuestData_World = questData_AddToWorldMap
	---@type table<questid, wqt_questdata>
	WorldQuestTracker.QuestData_WorldHash = {}
	for _, questData in ipairs(WorldQuestTracker.QuestData_World) do
		WorldQuestTracker.QuestData_WorldHash[questData.questID] = questData
	end

	WorldQuestTracker.FinishedUpdate_World()
end

---@type wqt_questdata[]
WorldQuestTracker.QuestData_World = {}
---@type wqt_questdata[]
WorldQuestTracker.QuestData_Zone = {}

---@type table<questid, wqt_questdata>
WorldQuestTracker.QuestData_WorldHash = {}
---@type table<questid, wqt_questdata>
WorldQuestTracker.QuestData_ZoneHash = {}

function WorldQuestTracker.RemoveQuestFromCache(questID)
	WorldQuestTracker.QuestData_WorldHash[questID] = nil
	WorldQuestTracker.QuestData_ZoneHash[questID] = nil

	for i, questData in ipairs(WorldQuestTracker.QuestData_World) do
		if (questData.questID == questID) then
			table.remove(WorldQuestTracker.QuestData_World, i)
			break
		end
	end

	for i, questData in ipairs(WorldQuestTracker.QuestData_Zone) do
		if (questData.questID == questID) then
			table.remove(WorldQuestTracker.QuestData_Zone, i)
			break
		end
	end
end

---return a indexed table with all quests data for the world and zone
---@return wqt_questdata[]
---@return wqt_questdata[]
function WorldQuestTracker.GetDataForAllQuests()
	return WorldQuestTracker.QuestData_World, WorldQuestTracker.QuestData_Zone
end

---@param questID questid
---@param bCreateQuestData boolean
---@return wqt_questdata?
function WorldQuestTracker.GetQuestDataFromCache(questID, bCreateQuestData)
	local questData = WorldQuestTracker.QuestData_WorldHash[questID] or WorldQuestTracker.QuestData_ZoneHash[questID]
	if (questData) then
		return questData
	end

	if (bCreateQuestData) then
		C_TaskQuest.RequestPreloadRewardData(questID)
		local haveQuestData = HaveQuestData(questID)
		if (haveQuestData) then
			for mapId, configTable in pairs(WorldQuestTracker.mapTables) do
				local taskInfo = GetQuestsForPlayerByMapID(mapId, mapId)
				if (taskInfo and #taskInfo > 0) then
					for i, info in ipairs(taskInfo) do
						local thisTaskQuestId = info.questID
						if (thisTaskQuestId == questID) then
							local title, factionID, tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex, allowDisplayPastCritical, gold, goldFormated, rewardName, rewardTexture, numRewardItems, itemName, itemTexture, itemLevel, quantity, quality, isUsable, itemID, isArtifact, artifactPower, isStackable, stackAmount = WorldQuestTracker.GetOrLoadQuestData(questID, true)
							local timeLeft = WorldQuestTracker.GetQuest_TimeLeft(questID)
							if (not timeLeft or timeLeft == 0) then
								timeLeft = 1
							end

							---@type wqt_questdata
							local newQuestData = {
								questID = questID,
								mapID = mapId,
								numObjectives = info.numObjectives,
								questCounter = 1,
								title = title,
								x = info.x,
								y = info.y,
								filter = 1,
								worldQuestType = worldQuestType,
								isCriteria = false,
								isNew = false,
								timeLeft = timeLeft,
								order = 1,
								rarity = rarity,
								isElite = isElite,
								tradeskillLineIndex = tradeskillLineIndex,
								factionID = factionID,
								tagID = tagID,
								tagName = tagName,
								gold = gold,
								goldFormated = goldFormated,
								rewardName = rewardName,
								rewardTexture = rewardTexture,
								numRewardItems = numRewardItems,
								itemName = itemName,
								itemTexture = itemTexture,
								itemLevel = itemLevel,
								quantity = quantity,
								quality = quality,
								isUsable = isUsable,
								itemID = itemID,
								isArtifact = isArtifact,
								artifactPower = artifactPower,
								isStackable = isStackable,
								stackAmount = stackAmount,
								inProgress = false,
								selected = false,
								isSpellTarget = false,
							}

							return newQuestData
						end
					end
				end
			end
		end
	end
end

local mapRangeValues = {
	[WorldQuestTracker.MapData.ZoneIDs.AZEROTH] = {0.18, .38, 5.2, 3.3},
	[WorldQuestTracker.MapData.ZoneIDs.ZANDALAR] = {0.18, .38, 5.2, 3.3},
	[WorldQuestTracker.MapData.ZoneIDs.KULTIRAS] = {0.18, .38, 5.2, 3.3},
	[WorldQuestTracker.MapData.ZoneIDs.BROKENISLES] = {0.18/3.0, .38/3.0, 5.2/3.0, 3.3/3.0}, --0.06, 0.126, 1.733, 1.1
	[WorldQuestTracker.MapData.ZoneIDs.ARGUS] = {0.18/2.5, .38/2.5, 5.2/2.5, 3.3/2.5},
	["default"] = {0.18, .38, 5.2, 3.3},
}

hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomIn", function()
	local mapScale = WorldMapFrame.ScrollContainer:GetCanvasScale()

	local rangeValues = mapRangeValues[WorldMapFrame.mapID]
	if (not rangeValues) then
		rangeValues = mapRangeValues["default"]
	end

	local pinScale = DF:MapRangeClamped(rangeValues[1], rangeValues[2], rangeValues[3], rangeValues[4], mapScale)

	if (WorldQuestTracker.IsWorldQuestHub(WorldMapFrame.mapID)) then
		for _, widget in pairs(WorldQuestTracker.WorldMapSmallWidgets) do
			widget:SetScale(pinScale + WorldQuestTracker.db.profile.world_map_config.onmap_scale_offset)
		end
	end
end)

hooksecurefunc(WorldMapFrame.ScrollContainer, "ZoomOut", function()
	local mapScale = WorldMapFrame.ScrollContainer:GetCanvasScale()

	local rangeValues = mapRangeValues[WorldMapFrame.mapID]
	if (not rangeValues) then
		rangeValues = mapRangeValues["default"]
	end

	local pinScale = DF:MapRangeClamped(rangeValues[1], rangeValues[2], rangeValues[3], rangeValues[4], mapScale)
	if (WorldQuestTracker.IsWorldQuestHub(WorldMapFrame.mapID)) then
		for _, widget in pairs(WorldQuestTracker.WorldMapSmallWidgets) do
			widget:SetScale(pinScale + WorldQuestTracker.db.profile.world_map_config.onmap_scale_offset)
		end
	end
end)

function WorldQuestTracker.UpdateQuestOnWorldMap(questID)
	if (WorldMapFrame:IsShown() and WorldQuestTracker.IsWorldQuestHub(WorldMapFrame.mapID)) then
		--update in the world summary
		for _, summarySquare in pairs(WorldQuestTracker.WorldSummaryQuestsSquares) do
			if (summarySquare.questID == questID and summarySquare:IsShown()) then
				--quick refresh
				if (WorldQuestTracker.CheckQuestRewardDataForWidget(summarySquare)) then
					WorldQuestTracker.UpdateWorldWidget(summarySquare, summarySquare.questData)
				end
				break
			end
		end

		--update in the world map
		for _, widget in pairs(WorldQuestTracker.WorldMapSmallWidgets) do
			if (widget.questID == questID and widget:IsShown()) then
				--quick refresh
				if (WorldQuestTracker.CheckQuestRewardDataForWidget(widget)) then
					WorldQuestTracker.SetupWorldQuestButton(widget, true)
				end
				break
			end
		end
	end
end

local lazyUpdate = CreateFrame("frame")
--list of quests queued to receive an update
lazyUpdate.WidgetsToUpdate = {}
WorldQuestTracker.WorldMapWidgetsLazyUpdateFrame = lazyUpdate


--store quests that are shown in the world map with the value poiting to its widget
lazyUpdate.ShownQuests = {}

--list of all widgets created
WorldQuestTracker.WorldMapSmallWidgets = {}

--update the zone widgets in the world map
---@param questData wqt_questdata
local scheduledIconUpdate = function(questData) --~update ~iconupate
	local questID = questData.questID

	--is already showing this quest?
	if (lazyUpdate.ShownQuests[questID]) then
		return
	end

	local mapID = questData.mapID
	local numObjectives = questData.numObjectives
	local questCounter = questData.questCounter
	local questName = questData.title
	local x = questData.x
	local y = questData.y
	local isCriteria = questData.isCriteria
	local worldQuestType, rarity, isElite, tradeskillLineIndex = questData.worldQuestType, questData.rarity, questData.isElite, questData.tradeskillLineIndex

	--update the quest counter
	questCounter = WorldQuestTracker.WorldMapQuestCounter
	WorldQuestTracker.WorldMapQuestCounter = WorldQuestTracker.WorldMapQuestCounter + 1

	--get a widget button for this quest
	local button = WorldQuestTracker.WorldMapSmallWidgets[questCounter]
	if (not button) then
		button = WorldQuestTracker.CreateZoneWidget(questCounter, "WorldQuestTrackerWorldMapSmallWidget", worldFramePOIs) --, "WorldQuestTrackerWorldMapPinTemplate"
		button.IsWorldZoneQuestButton = true
		WorldQuestTracker.WorldMapSmallWidgets[questCounter] = button
	end

	--get a pin in the world map from the data provider
	local pin = WorldQuestTrackerDataProvider:GetMap():AcquirePin("WorldQuestTrackerWorldMapPinTemplate", "questPin")
	pin.Child = button
	button:ClearAllPoints()
	button:SetParent(pin)
	button:SetPoint("center")
	button:Show()

	local mapScale = WorldMapFrame.ScrollContainer:GetCanvasScale()

	local rangeValues = mapRangeValues[WorldMapFrame.mapID]
	if (not rangeValues) then
		rangeValues = mapRangeValues["default"]
	end

	local pinScale = DF:MapRangeClamped(rangeValues[1], rangeValues[2], rangeValues[3], rangeValues[4], mapScale)

	local finalScaleScalar = WorldQuestTracker.db.profile.world_map_hubscale[WorldMapFrame.mapID] or 1
	pinScale = pinScale * finalScaleScalar

	if (WorldMapFrame.mapID == WorldQuestTracker.MapData.ZoneIDs.THESHADOWLANDS) then
		pinScale = pinScale - 1
		local conduitType = WorldQuestTracker.GetConduitQuestData(questID)
		if (conduitType) then
			pinScale = pinScale - 1
		end
	end

	button:SetScale(pinScale + WorldQuestTracker.db.profile.world_map_config.onmap_scale_offset)
	button.questID = questID
	button.mapID = mapID
	button.numObjectives = numObjectives
	button.questName = questName
	button.questData = questData

	WorldQuestTracker.SetupWorldQuestButton(button, questData)

	local newX, newY = HereBeDragons:TranslateZoneCoordinates(x, y, mapID, WorldMapFrame.mapID, false)
	if (mapID == 2248 and not newX) then
		local xCoord, yCoord, instance = HereBeDragons:GetWorldCoordinatesFromZone(x, y, mapID)
		newX, newY = HereBeDragons:GetZoneCoordinatesFromWorld(xCoord, yCoord, mapID, true)
		newX = 0.51 + x * 0.42
		newY = 0.06 + y * 0.38
	end

	if (mapID == WorldQuestTracker.MapData.ZoneIDs.ZARALEK) then
		if (x and y) then --no zaralek mapID, but zaralek quests shown on worldmap
			newX = 0.75 + x * 0.25
			newY = 0.75 + y * 0.25
			--button.blackGradient:Hide()
			--button.flagText:Hide()
			--self.bgFlag:Hide()
			WorldQuestTracker.ClearZoneWidget(button)
			button.circleBorder:Show()
		end

	elseif (mapID == WorldQuestTracker.MapData.ZoneIDs.EMERALDDREAM) then
		if (x and y) then --no zaralek mapID, but zaralek quests shown on worldmap
			newX = 0.66 + x * 0.50
			newY = 0.13 + y * 0.50
			--button.blackGradient:Hide()
			--button.flagText:Hide()
			--self.bgFlag:Hide()
			WorldQuestTracker.ClearZoneWidget(button)
			button.circleBorder:Show()
			WorldQuestTracker.AddExtraMapTexture(WorldQuestTracker.MapData.ZoneIDs.DRAGONISLES, [[Interface\AddOns\WorldQuestTracker\media\maps\emerald_dream]], 0.885, 0.38, 224, 224, mapID)
		end
	end

	pin:SetPosition(newX, newY)
	pin:SetSize(22, 22)
	pin.IsInUse = true

	button:SetAlpha(WorldQuestTracker.db.profile.worldmap_widget_alpha)

	button.highlight:SetSize(30, 30)
	button.highlight:SetParent(button)
	button.highlight:ClearAllPoints()
	button.highlight:SetPoint("center", button, "center")
	button.highlight:Show()

	if (x and newX) then
		lazyUpdate.ShownQuests[questID] = button
	end
end

--this function show the small quest icon in the map when the player hover over a squere in the azeroth map
function WorldQuestTracker.ShowWorldMapSmallIcon_Temp(questTable)
	scheduledIconUpdate(questTable)
end

local lazyUpdateEnded = function()
	local total_Gold, total_Resources, total_APower = 0, 0, 0

	for _, widget in pairs(WorldQuestTracker.WorldMapSmallWidgets) do
		if (widget.Amount) then
			if (widget.QuestType == QUESTTYPE_GOLD) then
				total_Gold = total_Gold +(widget.Amount or 0)

			elseif (widget.QuestType == QUESTTYPE_RESOURCE) then
				total_Resources = total_Resources +(widget.Amount or 0)

			elseif (widget.QuestType == QUESTTYPE_ARTIFACTPOWER) then
				total_APower = total_APower +(widget.Amount or 0)
			end
		end
	end

	WorldQuestTracker.UpdateResourceIndicators(total_Gold, total_Resources, total_APower)
end

local lazyUpdateFunc = function(self, deltaTime) --~lazyupdate
	if (WorldMapFrame:IsShown() and #lazyUpdate.WidgetsToUpdate > 0 and WorldQuestTracker.IsWorldQuestHub(WorldMapFrame.mapID)) then

		--if framerate is low, update more quests at the same time
		local frameRate = GetFramerate()
		local amountToUpdate = 2 +(not WorldQuestTracker.db.profile.hoverover_animations and 5 or 0)

		if (frameRate < 20) then
			amountToUpdate = amountToUpdate + 3
		elseif (frameRate < 60) then
			amountToUpdate = amountToUpdate + 2
		else
			amountToUpdate = amountToUpdate + 1
		end

		for i = 1, amountToUpdate do
			---@type wqt_questdata
			local questData = table.remove(lazyUpdate.WidgetsToUpdate)
			if (questData) then
				scheduledIconUpdate(questData)
			else
				break
			end
		end
	else
		local map = WorldQuestTrackerDataProvider:GetMap()
		for pin in map:EnumeratePinsByTemplate("WorldQuestTrackerWorldMapPinTemplate") do
			if (not pin.IsInUse) then
				map:RemovePin(pin)
			end
		end

		for questCounter, button in pairs(WorldQuestTracker.WorldMapSmallWidgets) do
			local pin = button:GetParent()
			if (not pin or pin.Child ~= button or not pin:IsShown()) then
				button:Hide()
			end
		end

		WorldQuestTracker.UpdatingForMap = nil
		lazyUpdateEnded()
		lazyUpdate:SetScript("OnUpdate", nil)
	end
end

WorldQuestTracker.WorldMapQuestCounter = 0

--questsToUpdate is a hash table with questIDs to just update / if is nil it's a full refresh
function WorldQuestTracker.LazyUpdateWorldMapSmallIcons(addToWorldMap, questsToUpdate) --~startlazy ~update
	---@cast addToWorldMap wqt_questdata[]

	if (not WorldQuestTracker.db.profile.world_map_config.onmap_show) then
		return
	end

	if (not WorldQuestTracker.db.profile.world_map_hubenabled[WorldMapFrame.mapID]) then
		local map = WorldQuestTrackerDataProvider:GetMap()
		for pin in map:EnumeratePinsByTemplate("WorldQuestTrackerWorldMapPinTemplate") do
			pin.IsInUse = false
			pin.Child:Hide()
			map:RemovePin(pin)
		end
		return
	end

	wipe(lazyUpdate.WidgetsToUpdate)
	---@type wqt_questdata[]
	lazyUpdate.WidgetsToUpdate = DF.table.copy({}, addToWorldMap)

	--which mapID quests being update belongs to
	WorldQuestTracker.UpdatingForMap = WorldMapFrame.mapID

	--is a full refresh?
	if (not questsToUpdate) then
		WorldQuestTracker.WorldMapQuestCounter = 0
		wipe(lazyUpdate.ShownQuests)
	end

	--tag pins 'not in use'
	local removedPins = 0
	local map = WorldQuestTrackerDataProvider:GetMap()
	for pin in map:EnumeratePinsByTemplate("WorldQuestTrackerWorldMapPinTemplate") do
		--if there's a list of unique quests to update, only unitilize the pin if it's showing the quest it'll update
		if (questsToUpdate) then
			if (questsToUpdate [pin.questID]) then
				pin.IsInUse = false
				pin.Child:Hide()
				map:RemovePin(pin)
				removedPins = removedPins + 1
			end
		else
			pin.IsInUse = false
		end
	end

	lazyUpdateEnded()
	lazyUpdate:SetScript("OnUpdate", lazyUpdateFunc)
end

--on maximize
if (WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton) then
	WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton:HookScript("OnClick", function()
		WorldQuestTracker.UpdateZoneSummaryFrame()
		WorldQuestTracker.UpdateStatusBarAnchors()
	end)
end

--on minimize
if (WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton) then
	WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton:HookScript("OnClick", function()
		WorldQuestTracker.UpdateZoneSummaryFrame()
		WorldQuestTracker.UpdateStatusBarAnchors()

		if (WorldQuestTracker.MapAnchorButton) then
			WorldQuestTracker.MapAnchorButton:UpdateButton()
		end
	end)
end

--quando clicar no bot�o de por o world map em fullscreen ou window mode, reajustar a posi��o dos widgets
if (WorldMapFrameSizeDownButton) then
	WorldMapFrameSizeDownButton:HookScript("OnClick", function() --window mode
		if (WorldQuestTracker.UpdateWorldQuestsOnWorldMap) then
			if (WorldQuestTracker.IsCurrentMapQuestHub()) then
				WorldQuestTracker.UpdateWorldQuestsOnWorldMap(false, true)
				WorldQuestTracker.RefreshStatusBarVisibility()
				C_Timer.After(1, WorldQuestTracker.RefreshStatusBarVisibility)
			end
		end
	end)

elseif (MinimizeButton) then
	MinimizeButton:HookScript("OnClick", function() --window mode
		if (WorldQuestTracker.UpdateWorldQuestsOnWorldMap) then
			if (WorldQuestTracker.IsCurrentMapQuestHub()) then
				WorldQuestTracker.UpdateWorldQuestsOnWorldMap(false, true)
				WorldQuestTracker.RefreshStatusBarVisibility()
				C_Timer.After(1, WorldQuestTracker.RefreshStatusBarVisibility)
			end
		end
	end)
end

if (WorldMapFrameSizeUpButton) then
	WorldMapFrameSizeUpButton:HookScript("OnClick", function() --full screen
		if (WorldQuestTracker.UpdateWorldQuestsOnWorldMap) then
			if (WorldQuestTracker.IsCurrentMapQuestHub()) then
				WorldQuestTracker.UpdateWorldQuestsOnWorldMap(false, true)
				C_Timer.After(1, WorldQuestTracker.RefreshStatusBarVisibility)
			end
		end
	end)

elseif (MaximizeButton) then
	MaximizeButton:HookScript("OnClick", function() --full screen
		if (WorldQuestTracker.UpdateWorldQuestsOnWorldMap) then
			if (WorldQuestTracker.IsCurrentMapQuestHub()) then
				WorldQuestTracker.UpdateWorldQuestsOnWorldMap(false, true)
				C_Timer.After(1, WorldQuestTracker.RefreshStatusBarVisibility)
			end
		end
	end)
end

--atualiza a quantidade de alpha nos widgets que mostram quantas quests ha para a fac��o
--deprecated?
function WorldQuestTracker.UpdateFactionAlpha()
	for _, factionFrame in ipairs(faction_frames) do
		if (factionFrame.enabled) then
			factionFrame:SetAlpha(1)
		else
			factionFrame:SetAlpha(.65)
		end
	end
end



