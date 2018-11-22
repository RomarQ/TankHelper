--[[
    Dear Player,

    When I wrote this code, only god and 
    I knew how it worked.

    Now, only god knows it!

    Therefore, if you are trying to optimize
    this code and it fails (most surely),
    please increase this counter as a warning
    for the next person:

    total_hours_wasted_here = 20
]] 

TankHelper = {
    name            = "TankHelper",
    version         = "1.0",
    author          = "RoMarQ",
    color           = "7c10b2",                 -- Used in menu titles
    menuName        = "Tank Helper",

    --
    DEBUFF_UPDATE_RATE = 100, -- ms
    --

    -- Default settings.
    defaultSettings = {
        trackOrbsSpears         = true,
        trackPurify             = true,
        trackLiquid             = true,
        trackBloodAltar         = true,
        trackHarvest            = true,

        trackEffectOnReticle    = false,
        trackEffects            = false,

        frameTop = 100,
        frameLeft = 100,

        trackedEffect = { name = 'Line-Breaker' },

        trackedEffects = {'Line-Breaker' , 'Crusher', 'Engulfing Flames', 'Off Balance', 'Minor Vulnerability', 'Minor Maim', 'Minor Vitality'},
    },

    --
    inCombat            = false,
    synergiesActive     = 0,
    --
}

local Synergies = {}
local SynergyTypes = {}

local CombatLogs = {}
local currentCombatLogIndex = nil
local CombatLog = {}
CombatLog.targets = {}

local TrackedEffects = {}

--/script id=43769 StartChatInput('['..id..']=true,--'..GetAbilityName(id))

local clipboardWindow = WINDOW_MANAGER:CreateTopLevelWindow("ClipboardWindowAlkosh")
clipboardWindow:SetMouseEnabled(false)
clipboardWindow:SetDimensions(50, 50)
clipboardWindow:SetTopmost(true)

local clipboard = WINDOW_MANAGER:CreateControl(nil, clipboardWindow, CT_TEXTURE)
clipboard:SetPixelRoundingEnabled(false)
clipboard:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 0, 0)
clipboard:SetDimensions(50, 50)
clipboard:SetColor(1, 0, 1)
clipboard:SetHidden(true)


TankHelper.loadData = function()

    SynergyTypes['OrbsSpears'] = {
        control='OrbsSpears',
        name="Spear Shards / Necrotic Orb CD",
        icon="esoui/art/icons/ability_undaunted_004.dds",
        enabled=TankHelper.savedVariables.trackOrbsSpears,
        timer=0,
    }
    SynergyTypes['Purify'] = {
        control='Purify',
        icon="esoui/art/icons/ability_templar_purifying_ritual.dds",
        enabled=TankHelper.savedVariables.trackPurify,
        timer=0,
    }
    SynergyTypes['Liquid'] = {
        control='Liquid',
        name="Conduit Synergy Cooldown",
        icon="esoui/art/icons/ability_sorcerer_liquid_lightning.dds",
        enabled=TankHelper.savedVariables.trackLiquid,
        timer=0,
    }
    SynergyTypes['Harvest'] = {
        control='Harvest',
        icon="esoui/art/icons/ability_warden_007_b.dds",
        enabled=TankHelper.savedVariables.trackHarvest,
        timer=0,
    }
    SynergyTypes['BloodAltar'] = {
        control='BloodAltar',
        icon="esoui/art/icons/ability_undaunted_001_a.dds",
        enabled=TankHelper.savedVariables.trackBloodAltar,
        timer=0,
    }
    
    Synergies[63512] = { active=false,  type=SynergyTypes['OrbsSpears'] }
    Synergies[48052] = { active=false,  type=SynergyTypes['OrbsSpears'] }
    Synergies[85432] = { active=false,  type=SynergyTypes['OrbsSpears'] }
    Synergies[85434] = { active=false,  type=SynergyTypes['OrbsSpears'] }
    Synergies[95924] = { active=false,  type=SynergyTypes['OrbsSpears'] }
    
    Synergies[22270] = { active=false,  type=SynergyTypes['Purify']     }
    Synergies[43769] = { active=false,  type=SynergyTypes['Liquid']     }
    Synergies[85572] = { active=false,  type=SynergyTypes['Harvest']    }

    Synergies[39521] = { active=false,  type=SynergyTypes['BloodAltar'] }
    Synergies[41969] = { active=false,  type=SynergyTypes['BloodAltar'] }
    
end

--[[
local names = {}
names['Conduit Synergy Cooldown'] = true
names['Harvest'] = true
names['Purify'] = true
names['Spear Shards / Necrotic Orb CD'] = true
names['Sanguine Altar'] = true
names['Overflowing Altar'] = true
]]


local WM = WINDOW_MANAGER

TankHelper.unlockUI = function()
    TankHelperTLW:SetHidden(false)
end

TankHelper.lockUI = function()
    TankHelperTLW:SetHidden(true)
end

TankHelper.loadUI = function()

    TankHelper.loadData()

    TankHelperTLW:ClearAnchors()
    TankHelperTLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TankHelper.savedVariables.frameLeft, TankHelper.savedVariables.frameTop)

    local parentControl = nil

    for t in pairs(SynergyTypes) do
        if (SynergyTypes[t].enabled == true) then

            local control = WM:GetControlByName("SH_" .. SynergyTypes[t].control)
            if not control then
                control = WM:CreateControl("SH_" .. SynergyTypes[t].control, TankHelperTLW, CT_CONTROL)
            end
            
            control:SetHidden(false)
            control:SetDimensions(64, 64)

            if(parentControl == nil) then
                control:SetAnchor(TOPLEFT)
            else
                control:SetAnchor(TOPLEFT, parentControl, TOPRIGHT, 2, 0)
            end
            
            local controlLabel = WM:GetControlByName("SH_" .. SynergyTypes[t].control .. "_Timer")
            if not controlLabel then
                controlLabel = WM:CreateControl("SH_" .. SynergyTypes[t].control .. "_Timer", control, CT_LABEL)
            end
            
            controlLabel:ClearAnchors()
            controlLabel:SetAnchor(TOPLEFT, iconAnchor, TOPLEFT, 2,2)
            controlLabel:SetAnchor(BOTTOMRIGHT, iconAnchor, BOTTOMRIGHT, -2,-2)
            controlLabel:SetVerticalAlignment(1)
            controlLabel:SetHorizontalAlignment(1)
            controlLabel:SetColor(0.66, 0.09, 0.09, 1)
            controlLabel:SetFont("$(BOLD_FONT)|$(KB_48)|thick-outline")
            controlLabel:SetHidden(false)

            local controlIcon = WM:GetControlByName("SH_" .. SynergyTypes[t].control .. "_Icon")
            if not controlIcon then
                controlIcon = WM:CreateControl("SH_" .. SynergyTypes[t].control .. "_Icon", control, CT_TEXTURE)
            end

            controlIcon:SetAnchorFill()
            controlIcon:SetTexture(SynergyTypes[t].icon)
            controlIcon:SetHidden(false)
            
            parentControl = control
        else

            local control = WM:GetControlByName("SH_" .. SynergyTypes[t].control)
            if control then
                control:SetHidden(true)
            end

            local controlLabel = WM:GetControlByName("SH_" .. SynergyTypes[t].control .. "_Timer")
            if controlLabel then
                controlLabel:SetHidden(true)
            end

            local controlIcon = WM:GetControlByName("SH_" .. SynergyTypes[t].control .. "_Icon")
            if controlIcon then
                controlIcon:SetHidden(true)
            end

        end
    end
end

TankHelper.LoadEffectMetricsComponent = function ()
    -- Get which effects user want to track
    TrackedEffects  = TankHelper.savedVariables.trackedEffects
    -- Get which effect user wants to track on reticle
    TankHelper.TrackedEffect = { name = TankHelper.savedVariables.trackedEffect.name }
    -- Creates all UI and User Interaction for Effect Metrics Module
    TankHelper.InitializeEffectMetricsFrame()
    TankHelper.TargetsList = TankHelper.GetTargetsList()
    TankHelper.EffectsList = TankHelper.GetEffectsList()
end

TankHelper.OnFrameMoveStop = function()
    TankHelper.savedVariables.frameLeft  = TankHelperTLW:GetLeft()
    TankHelper.savedVariables.frameTop   = TankHelperTLW:GetTop()
end


function TankHelper.SynergyTimerUpdate( ... )

    for id in pairs(Synergies) do
        if (Synergies[id].active == true) then

            local control = WM:GetControlByName("SH_" .. Synergies[id].type.control .. "_Timer")

            Synergies[id].type.timer = Synergies[id].type.timer - 1

            if(control ~= nil) then
                if(Synergies[id].type.timer > 0) then
                    control:SetText(Synergies[id].type.timer)
                else
                    Synergies[id].active = false
                    control:SetText('')

                    TankHelper.synergiesActive = TankHelper.synergiesActive - 1
                    if ( TankHelper.synergiesActive == 0 ) then
                        EVENT_MANAGER:UnregisterForUpdate("Synergy_Timer_Update")
                    end

                end
            end

        end
    end
end

TankHelper.Synergy = function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
    targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )

    if(result ~= ACTION_RESULT_EFFECT_GAINED or targetType ~= COMBAT_UNIT_TYPE_PLAYER or targetType ~= sourceType) then return end

    for id in pairs(Synergies) do
        if ( id == abilityId ) then
            TankHelper.synergiesActive = TankHelper.synergiesActive + 1
            Synergies[id].active = true
            Synergies[id].type.timer = 20

            EVENT_MANAGER:UnregisterForUpdate("Synergy_Timer_Update")
            EVENT_MANAGER:RegisterForUpdate("Synergy_Timer_Update", 1000, TankHelper.SynergyTimerUpdate )
        end
    end

end

local SaveCombatLog = function()

    CombatLogs[#CombatLogs+1] = ZO_DeepTableCopy(CombatLog, CombatLogs[#CombatLogs+1])
    currentCombatLogIndex = #CombatLogs

    CombatLog = {}
    CombatLog.targets = {}

end

TankHelper.ResetCombatLog = function ()
    -- Get which effect user wants to track on reticle
    TrackedEffect   = { name = TankHelper.savedVariables.trackedEffect.name }
end

local LoadEffectMetrics = function( SelectedCombatLog )

    if SelectedCombatLog == nil then
        SelectedCombatLog = CombatLog
    end

    if SelectedCombatLog.endTime == nil then return end

    local timeLapsed = 0
    local mainTarget = { targetHP=0, categoryId=0, targetName=nil }
    local TargetsData = {}
    local EffectsData = {}
    local fightTime = SelectedCombatLog.endTime

    if ( fightTime > SelectedCombatLog.timeOfLastEffect ) then
        fightTime = SelectedCombatLog.timeOfLastEffect
    end

    timeLapsed = fightTime - SelectedCombatLog.beginTime


    for target in pairs(SelectedCombatLog.targets) do

        if not IsUnitPlayer(SelectedCombatLog.targets[target].targetTag) then 

            ZO_ScrollList_AddCategory(TankHelper.EffectsList, target, nil)

            -- Select Main target to show on metrics as default
            if(SelectedCombatLog.targets[target].targetHP > mainTarget.targetHP) then
                mainTarget.categoryId = target
                mainTarget.targetHP   = SelectedCombatLog.targets[target].targetHP
                mainTarget.targetName = SelectedCombatLog.targets[target].targetName
            end

            for effect in pairs(SelectedCombatLog.targets[target].effects) do
                local uptime = 0
                local uptimePercentage = 0
                local oldEndTime = nil

                for registry in pairs(SelectedCombatLog.targets[target].effects[effect].registries) do

                    if ( SelectedCombatLog.targets[target].effects[effect].registries[registry].endTime > fightTime ) then
                        SelectedCombatLog.targets[target].effects[effect].registries[registry].endTime = fightTime
                    end

                    if (oldEndTime == nil or oldEndTime < SelectedCombatLog.targets[target].effects[effect].registries[registry].beginTime) then
                        uptime = uptime + ( SelectedCombatLog.targets[target].effects[effect].registries[registry].endTime - SelectedCombatLog.targets[target].effects[effect].registries[registry].beginTime )
                    else
                        uptime = uptime + ( SelectedCombatLog.targets[target].effects[effect].registries[registry].endTime - oldEndTime)
                    end

                    oldEndTime = SelectedCombatLog.targets[target].effects[effect].registries[registry].endTime

                end

                -- Organize effects data for each effect inside of a table
                uptimePercentage = (uptime*100)/timeLapsed

                local effectData =   {
                    effectName = SelectedCombatLog.targets[target].effects[effect].effectName,
                    uptime = uptime,
                    uptimePercentage = uptimePercentage,
                    icon = SelectedCombatLog.targets[target].effects[effect].icon,

                    categoryId = target,
                }

                table.insert(EffectsData, effectData)
            end

            -- Organize targets data for each target inside of a table
            local targetData =   {
                targetName = SelectedCombatLog.targets[target].targetName,
                targetHP   = SelectedCombatLog.targets[target].targetHP,
                targetTag  = SelectedCombatLog.targets[target].targetTag,

                categoryId = target,
            }

            table.insert(TargetsData, targetData)
        end
    end

    -- Update Effect Metrics Frame and display it
    TankHelper.TargetsList.Window:SetHidden(false)
    TankHelper.TargetsList:Update(TargetsData)
    TankHelper.EffectsList:Update(EffectsData)
    -- Always show target with more HP as default
    TankHelper.EffectsList:HideAllCategories()
    TankHelper.EffectsList:ShowCategory(mainTarget.categoryId)

    TankHelper.TargetsList.Window.fightDuration:SetText('Fight Time: '.. string.format('%.2f', SelectedCombatLog.endTime - SelectedCombatLog.beginTime))
    TankHelper.TargetsList.Window.selectedTarget:SetText(mainTarget.targetName)

    if currentCombatLogIndex > 1 then
        TankHelper.TargetsList.Window.previous:SetState(ADDON_STATE_NORMAL, false)
    else
        TankHelper.TargetsList.Window.previous:SetState(ADDON_STATE_DISABLED, true)
    end

    if currentCombatLogIndex == #CombatLogs then
        TankHelper.TargetsList.Window.next:SetState(ADDON_STATE_DISABLED, true)
    else
        TankHelper.TargetsList.Window.next:SetState(ADDON_STATE_NORMAL, false)
    end

    -- Reset Effect Metrics Data
    TankHelper.ResetCombatLog()
end

TankHelper.StartMonitoringFight = function()
    TankHelper.inCombat = true
    TankHelperTLW:SetHidden(false)
    
    if TankHelper.EffectsList then
        TankHelper.EffectsList.Window:SetHidden(true)
    end

end

TankHelper.StopMonitoringFight = function()
    TankHelperTLW:SetHidden(true)
    SH_Reticle:SetHidden(true)
    clipboard:SetHidden(true)

    SaveCombatLog()

end

local PlayerCombatState = function()
    if ( IsUnitInCombat("player") ) then
		TankHelper.StartMonitoringFight()
    else
        CombatLog.endTime = TankHelper.GetCurrentTimeInSeconds()
        TankHelper.inCombat = false
		-- Avoid false positives of combat end, often caused by combat rezzes
        zo_callLater(function() if (not IsUnitInCombat("player")) then TankHelper.StopMonitoringFight() end end, 3000)
	end
end

TankHelper.RegisterForSynergies = function()
    
    for id in pairs(Synergies) do
        EVENT_MANAGER:RegisterForEvent  ("Synergies_" .. id, EVENT_COMBAT_EVENT, TankHelper.Synergy )
        EVENT_MANAGER:AddFilterForEvent ("Synergies_" .. id, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID , id )
    end

    TankHelper.loadUI()
end


TankHelper.EffectTimer = function()

    if TankHelper.TrackedEffect.target == nil or TankHelper.TrackedEffect.effectId == nil then return end
    
    local target = TankHelper.TrackedEffect.target
    local effect = TankHelper.TrackedEffect.effectId
    local remainingTime = 0

    if target ~= nil and effect ~= nil then
        if CombatLog.targets[target] and CombatLog.targets[target].effects[effect] and CombatLog.targets[target].effects[effect].registries[CombatLog.targets[target].effects[effect].counter] then
            remainingTime = CombatLog.targets[target].effects[effect].registries[CombatLog.targets[target].effects[effect].counter].endTime - TankHelper.GetCurrentTimeInSeconds()
        end
    end
    
    if (remainingTime > 0) then  
        if (remainingTime > 3) then
            clipboard:SetHidden(true)
        end
        SH_Reticle_Label:SetText(string.format('%.1f', remainingTime))
    else
        EVENT_MANAGER:UnregisterForUpdate("EFFECT_TIMER")
        SH_Reticle_Label:SetText('')
        SH_Reticle:SetHidden(true)   
    end

end

local EffectChanged = function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, 
    statusEffectType, unitName, unitId, abilityId, sourceType)

    if endTime ~= nil and unitName ~= 'Offline' and abilityType ~= ABILITY_TYPE_REGISTERTRIGGER and (effectType==BUFF_EFFECT_TYPE_DEBUFF or effectType==BUFF_EFFECT_TYPE_BUFF)
        and sourceType ~= COMBAT_UNIT_TYPE_NONE and changeType~=EFFECT_RESULT_FADED then

        -- Just track debuffs if in combat ( Could have checked on the 'IF' before, but I want to avoid calling functions when isn't necessary )
        if not TankHelper.InCombat then if not IsUnitInCombat("player") then return end end

        if CombatLog.beginTime == nil then 
            CombatLog.beginTime = tonumber(string.format('%.3f', beginTime))
            CombatLog.endTime = tonumber(string.format('%.3f', endTime))
            CombatLog.timeOfLastEffect = tonumber(string.format('%.3f', endTime))
        end

        if CombatLog.timeOfLastEffect < endTime then CombatLog.timeOfLastEffect = tonumber(string.format('%.3f', endTime)) end

        if CombatLog.targets[unitId] == nil then
            CombatLog.targets[unitId]               = {}
            CombatLog.targets[unitId].effects       = {}
            CombatLog.targets[unitId].targetTag     = unitTag
            if(string.len(unitName) > 30) then
                CombatLog.targets[unitId].targetName = string.sub(zo_strformat(SI_UNIT_NAME, unitName), 1, 28)..'...'
            else
                CombatLog.targets[unitId].targetName = zo_strformat(SI_UNIT_NAME, unitName)
            end
            local _ , maxHP, _              = GetUnitPower(unitTag, POWERTYPE_HEALTH)
            CombatLog.targets[unitId].targetHP      = maxHP
        end

        for i in pairs(TrackedEffects) do
            if ( TrackedEffects[i] == effectName ) then

                if CombatLog.targets[unitId].effects[abilityId] == nil then
                    CombatLog.targets[unitId].effects[abilityId]                    = {}
                    CombatLog.targets[unitId].effects[abilityId].registries         = {}
                    CombatLog.targets[unitId].effects[abilityId].counter            = 0
                    CombatLog.targets[unitId].effects[abilityId].icon               = iconName
                    CombatLog.targets[unitId].effects[abilityId].effectName         = effectName
                    CombatLog.targets[unitId].effects[abilityId].abilityType        = abilityType
                    CombatLog.targets[unitId].effects[abilityId].effectType         = effectType
                    CombatLog.targets[unitId].effects[abilityId].statusEffectType   = statusEffectType
                    CombatLog.targets[unitId].effects[abilityId].effectName         = effectName
                end
                
                -- Counter tells how many times a effect was Gained, Refreshed, Updated or Transferred on a specific target
                CombatLog.targets[unitId].effects[abilityId].counter = CombatLog.targets[unitId].effects[abilityId].counter + 1
                -- Stores all important info about the effect that was applied
                CombatLog.targets[unitId].effects[abilityId].registries[CombatLog.targets[unitId].effects[abilityId].counter] = {
                    sourceType  = sourceType,
                    changeType  = changeType,
                    beginTime   = beginTime, 
                    endTime     = endTime,
                    stackCount  = stackCount,  
                }
            end
        end
        
        -- If we are tracking a effect timer on reticle
        if TankHelper.savedVariables.trackEffectOnReticle then

            if unitTag ~= 'boss1' or TankHelper.TrackedEffect.name ~= effectName then
                return
            end

            -- Get Id of the target on which we are tracking effect
            TankHelper.TrackedEffect.target     = unitId
            -- Get Id of the effect being tracked on reticle
            TankHelper.TrackedEffect.effectId = abilityId
            
            SH_Reticle:SetHidden(false)
            EVENT_MANAGER:RegisterForUpdate("EFFECT_TIMER", TankHelper.DEBUFF_UPDATE_RATE, TankHelper.EffectTimer)
        end

    end
end

------------------------------------------------------------------------------------
------------------------------------ UI SECTION ------------------------------------
------------------------------------------------------------------------------------

TankHelper.ShowMetrics = function()

    if TankHelper.EffectsList.Window:IsHidden() and not IsUnitInCombat("player") then
        if #CombatLogs > 0 then
            LoadEffectMetrics(CombatLogs[#CombatLogs])
        end
        TankHelper.EffectsList.Window:SetHidden(false)
    else
        TankHelper.EffectsList.Window:SetHidden(true)
    end

end

--
-- Navigation Menu ( NEXT , PREVIOUS , DELETE, SAVE, OPEN )
--

TankHelper.PreviousCombatLog = function ()

    if currentCombatLogIndex == nil then return end

    if CombatLogs[currentCombatLogIndex-1] ~= nil then
        currentCombatLogIndex = currentCombatLogIndex - 1
        LoadEffectMetrics(CombatLogs[currentCombatLogIndex])
    end
end

TankHelper.NextCombatLog = function ()

    if currentCombatLogIndex == nil then return end

    if CombatLogs[currentCombatLogIndex+1] ~= nil then
        currentCombatLogIndex = currentCombatLogIndex + 1
        LoadEffectMetrics(CombatLogs[currentCombatLogIndex])
    end
end

TankHelper.DeleteCombatLog = function ()

    if CombatLogs[currentCombatLogIndex] == nil then return end

    ZO_ClearTable(CombatLogs[currentCombatLogIndex])

    TankHelper.EffectsList:Clear()
    TankHelper.TargetsList:Clear()
    TankHelper.TargetsList.Window.fightDuration:SetText('')
    TankHelper.TargetsList.Window.selectedTarget:SetText('')
    
    if CombatLogs[currentCombatLogIndex+1] ~= nil then
        TankHelper:NextCombatLog()
    elseif CombatLogs[currentCombatLogIndex-1] ~= nil then
        TankHelper:PreviousCombatLog()
    end

end


------------------------------------------------------------------------------------
---------------------------------- ADDON STARTUP -----------------------------------
------------------------------------------------------------------------------------

TankHelper.Activated = function(e)

    EVENT_MANAGER:UnregisterForEvent(TankHelper.name, EVENT_PLAYER_ACTIVATED)

    EVENT_MANAGER:RegisterForEvent("EVENT_PLAYER_COMBAT_STATE"  , EVENT_PLAYER_COMBAT_STATE , PlayerCombatState     )
    EVENT_MANAGER:RegisterForEvent("EVENT_EFFECT_CHANGED"       , EVENT_EFFECT_CHANGED      , EffectChanged         )

    TankHelper.RegisterForSynergies() -- Registers for Synergies 

end
-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(TankHelper.name, EVENT_PLAYER_ACTIVATED, TankHelper.Activated)


TankHelper.OnAddOnLoaded = function(event, addonName)

    if addonName ~= TankHelper.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(TankHelper.name, EVENT_ADD_ON_LOADED)
    
    -- Getting addon variables from savedVariables file, if it doesn't exist or version is different then create a new file.
    TankHelper.savedVariables = ZO_SavedVars:New("TankHelperSavedVariables", 8, nil, TankHelper.defaultSettings)
    
    TankHelper.buildMenu()                                              -- Register addon Menu after loading.
    ZO_CreateStringId("SI_BINDING_NAME_SHOW_METRICS", "Show Metrics")   -- Create Bindings

    TankHelper.loadData()

    TankHelper.LoadEffectMetricsComponent()                             -- Start Debuff Metrics UI

    SLASH_COMMAND_AUTO_COMPLETE:InvalidateSlashCommandCache()           -- Reset autocomplete cache to update it.
end

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(TankHelper.name, EVENT_ADD_ON_LOADED, TankHelper.OnAddOnLoaded)
