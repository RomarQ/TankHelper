TankHelperMenu = {}

TankHelper.buildMenu = function()
	local LAM = LibStub('LibAddonMenu-2.0')
    local settings = ZO_DeepTableCopy(TankHelper.savedVariables, settings)

    local selectedEffectToRemove

    -- Wraps text with a color.
    local function Colorize(text, color)
        -- Default to addon's .color.
        if not color then color = TankHelper.color end

        text = "|c" .. color .. text .. "|c"
    end

    -- Settings menu.
    local panelData = {
        type = "panel",
        name = TankHelper.menuName,
        displayName = Colorize(TankHelper.menuName),
        author = Colorize(TankHelper.author, "AAF0BB"),
        version = Colorize(TankHelper.version, "AA00FF"),
        slashCommand = "/TankHelper",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(TankHelper.menuName, panelData)

    local optionsTable = {
        {
            type = "header",
            name = "Show the timer of an effect applied on Main boss",
            width = "full",
        },
        {
            type = "checkbox",
            name = 'Track Effect on Reticle',
            getFunc = function() return settings.trackEffectOnReticle end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackEffectOnReticle = value
                SH_Reticle:SetHidden(true)
            end,
            width = "half",
        },
        {
            type = "editbox",
            name = 'Effect Name (e.g. |cf4a442Line-Breaker|r)',
            tooltip = "Effect to track on reticle",
            getFunc = function() return TankHelper.savedVariables.trackedEffect.name end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackedEffect.name = value
                -- Get which effect user wants to track on reticle
                TankHelper.TrackedEffect = { name = value }
                SH_Reticle:SetHidden(true)
            end,
            width = "half",
        },
        {
            type = "header",
            name = "Track effect Uptimes",
            width = "full",
        },
        {
            type = "checkbox",
            name = 'Track Effect uptimes',
            getFunc = function() return TankHelper.savedVariables.trackEffects end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackEffects = value
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = 'Add an Effect to be tracked',
            getFunc = function() return '' end,
            setFunc = function(value)
                if string.len(value) > 0 then
                    local len = #settings.trackedEffects
                    for i=1, len do
                        if settings.trackedEffects[i] == value then
                            return
                        end
                    end
                    table.insert(settings.trackedEffects, len, value)
                end
            end,
        },
        {
            type = 'dropdown',
            name = 'Effects Being tracked',
            choices = settings.trackedEffects,
            getFunc = function() return '' end,
            setFunc = function(value)

                if SELECT_TO_REMOVE == value then return end

                selectedEffectToRemove = value

            end,
            warning = 'Need to reload UI to update the effect list'
        },
        {
            type = 'button',
            name = 'Remove effect',
            func = function()
               
                if selectedEffectToRemove == nil then return end
                
                for i=1, #settings.trackedEffects do
                    if settings.trackedEffects[i] == selectedEffectToRemove then
                        table.remove(settings.trackedEffects, i)
                        selectedEffectToRemove = nil
                        return
                    end
                end 
            end,
        },
        {
            type = "header",
            name = "Select which Synergies you want to track",
            width = "full",
        },
        {
            type = "texture",
            image = "esoui/art/icons/ability_undaunted_004.dds",
            imageWidth = 64,	--max of 250 for half width, 510 for full
            imageHeight = 64,	--max of 100
            tooltip = "Spear Shards / Necrotic Orb CD",
            width = "half",
        },
        {
            type = "checkbox",
            getFunc = function() return TankHelper.savedVariables.trackOrbsSpears end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackOrbsSpears = value
                TankHelper.loadUI() 
            end,
            width = "half",
            warning = "Will need to reload the UI.",
        },
        {
            type = "texture",
            image = "esoui/art/icons/ability_templar_purifying_ritual.dds",
            imageWidth = 64,	--max of 250 for half width, 510 for full
            imageHeight = 64,	--max of 100
            tooltip = "Purify",
            width = "half",
        },
        {
            type = "checkbox",
            getFunc = function() return TankHelper.savedVariables.trackPurify end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackPurify = value
                TankHelper.loadUI() 
            end,
            width = "half",
            warning = "Will need to reload the UI.",
        },
        {
            type = "texture",
            image = "esoui/art/icons/ability_sorcerer_liquid_lightning.dds",
            imageWidth = 64,	--max of 250 for half width, 510 for full
            imageHeight = 64,	--max of 100
            tooltip = "Liquid Lightning",
            width = "half",
        },
        {
            type = "checkbox",
            getFunc = function() return TankHelper.savedVariables.trackLiquid end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackLiquid = value
                TankHelper.loadUI() 
            end,
            width = "half",
            warning = "Will need to reload the UI.",
        },
        {
            type = "texture",
            image = "esoui/art/icons/ability_warden_007_b.dds",
            imageWidth = 64,	--max of 250 for half width, 510 for full
            imageHeight = 64,	--max of 100
            tooltip = "The Harvest",
            width = "half",
        },
        {
            type = "checkbox",
            getFunc = function() return TankHelper.savedVariables.trackHarvest end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackHarvest = value
                TankHelper.loadUI() 
            end,
            width = "half",
            warning = "Will need to reload the UI.",
        },
        {
            type = "texture",
            image = "esoui/art/icons/ability_undaunted_001_a.dds",
            imageWidth = 64,	--max of 250 for half width, 510 for full
            imageHeight = 64,	--max of 100
            tooltip = "Blood Altar",
            width = "half",
        },
        {
            type = "checkbox",
            getFunc = function() return TankHelper.savedVariables.trackBloodAltar end,
            setFunc = function(value) 
                TankHelper.savedVariables.trackBloodAltar = value
                TankHelper.loadUI() 
            end,
            width = "half",
            warning = "Will need to reload the UI.",
        },
        {
            type = "header",
            name = "Positioning"
        },
        {
            type = "checkbox",
            name = "UI Locked",
            tooltip = "Allows to reposition the frame",
            getFunc = function() return false end,
            setFunc = function(value)
                if value then
                    TankHelper.unlockUI()
                else
                    TankHelper.lockUI()
                end
            end
        },
    }

    LAM:RegisterOptionControls(TankHelper.menuName, optionsTable)

end