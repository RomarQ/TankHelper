local LSCL  = LibStub("LibScroll")

local targetsList = nil
local effectsList = nil

-- This function creates a top level window to hold our scrollList
local function CreateMainWindow()
    
    -- Creating Top Level Window for Effect Metrics
    local tlw = WINDOW_MANAGER:GetControlByName("TH_EffectsMetrics")

    -- Label that displays total fight time
    tlw.fightDuration = WINDOW_MANAGER:CreateControlFromVirtual("TH_EffectsMetrics_L_TotalTime", tlw, "ZO_SelectableLabel")
    tlw.fightDuration:SetAnchor(TOPLEFT, tlw, TOPLEFT, 20, 10)
    tlw.fightDuration:SetFont('$(BOLD_FONT)|$(KB_36)|thick-outline')
    tlw.fightDuration:SetWidth(1000)
    tlw.fightDuration:SetHeight(40)
    tlw.fightDuration:SetVerticalAlignment(CENTER)
    tlw.fightDuration:SetHorizontalAlignment(CENTER)
    tlw.fightDuration:SetStyleColor(0.22, 0.02, 0.25, 1)

    -- Label that displays which target is currently selected
    tlw.selectedTarget = WINDOW_MANAGER:CreateControl("TH_EffectsMetrics_L_SelectedTarget", tlw, CT_LABEL)
    tlw.selectedTarget:SetAnchor(TOPLEFT, tlw, TOPLEFT, 20, 70)
    tlw.selectedTarget:SetFont('$(BOLD_FONT)|$(KB_24)|thick-outline')
    tlw.selectedTarget:SetWidth(400)
    tlw.selectedTarget:SetHeight(40)
    tlw.selectedTarget:SetVerticalAlignment(CENTER)
    tlw.selectedTarget:SetHorizontalAlignment(CENTER)
    tlw.selectedTarget:SetStyleColor(0.22, 0.02, 0.25, 1)
    
    tlw.next       = WINDOW_MANAGER:GetControlByName('TH_EffectsMetrics_NavigationBottom_Next')
    tlw.previous   = WINDOW_MANAGER:GetControlByName('TH_EffectsMetrics_NavigationBottom_Previous')

    tlw:SetHidden(true)
    return tlw
end
    
-- Just testing for now
local function OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    d(selectedData.effectName)
end
    
-- Sort function for effects
local function SortEffects(objA, objB)
    return objA.data.uptime > objB.data.uptime
end

-- Sort function for targets
local function SortTargets(objA, objB)
    return objA.data.targetHP > objB.data.targetHP
end

-- Row constructor for Debuffs
local function SetupEffectRow(rowControl, data, scrollList)
    --d(rowControl:GetChild(4):GetType(), rowControl:GetChild(4):GetName(), rowControl:GetNumChildren())

    rowControl:GetChild(1):SetTexture(data.icon)

    rowControl:GetChild(3):SetWidth((rowControl:GetChild(4):GetWidth()*data.uptimePercentage)/100)

    rowControl:GetChild(4):SetText('  '..data.effectName)
    
    rowControl:GetChild(5):SetText(string.format('%.1f', data.uptime)..'s')
    
    rowControl:GetChild(6):SetText(string.format('%.1f', data.uptimePercentage)..'%')

    rowControl:SetHandler("OnMouseUp", function()
        ZO_ScrollList_MouseClick(scrollList, rowControl)
    end)
end
    
-- Row constructor for TargetsList
local function SetupTargetRow(rowControl, data, scrollList)

    rowControl:GetChild(1):SetText(data.targetName)

    rowControl:GetChild(1):SetHandler("OnClicked", function()
        TankHelper.EffectsList.Window.selectedTarget:SetText(data.targetName)

        TankHelper.EffectsList:HideAllCategories()
        TankHelper.EffectsList:ShowCategory(data.categoryId)
    end)

    rowControl:SetHandler("OnMouseUp", function()
        ZO_ScrollList_MouseClick(scrollList, rowControl)
    end)
end
        


local function CreateEffectsList(mainWindow)

    -- Effects List configuration
    local EffectsData = {
        name                = "EffectsList",
        parent              = mainWindow,
        
        width               = 360,
        height              = 384,
        rowHeight           = 48,
        
        rowTemplate         = 'TH_EffectRowTemplate',

        setupCallback       = SetupEffectRow,
        selectCallback      = OnRowSelect,
        dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
        sortFunction        = SortEffects,
    }
    
    local list = LSCL:CreateScrollList(EffectsData)
    list:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 20, 320)
    
    return list
end

-- Function that creates the scrollList 
local function CreateTargetsList(mainWindow)

    -- TargetsList configuration
    local targetsData = {
        name                = "TargetsList",
        parent              = mainWindow,
        
        width               = 370,
        height              = 160,
        rowHeight           = 36,
        
        rowTemplate         = 'TH_TargetRowTemplate',

        setupCallback       = SetupTargetRow,
        selectCallback      = OnRowSelect,
        dataTypeSelectSound = SOUNDS.BOOK_CLOSE,
        sortFunction        = SortTargets,
    }
    
    local list = LSCL:CreateScrollList(targetsData)
    list:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 10, 140)
    
    return list
end
    
TankHelper.InitializeEffectMetricsFrame = function()
    -- Creates the top level window to hold Effects information
    local mainWindow = CreateMainWindow()
    -- Create the targetList
    targetsList = CreateTargetsList(mainWindow)
    -- Create the debuffList
    effectsList = CreateEffectsList(mainWindow)
end

TankHelper.GetTargetsList = function ()
    return targetsList
end

TankHelper.GetEffectsList = function ()
    return effectsList
end
    