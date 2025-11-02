-- Removes button glow effects from action bars

local function hideGlow(button)
    if not button then return end

    local rotation = button.AssistedCombatRotationFrame
    if rotation and rotation.SpellActivationAlert then
        rotation.SpellActivationAlert:Hide()
    end

    if button.overlay then
        button.overlay:Hide()
    end

    if button.SpellActivationAlert then
        button.SpellActivationAlert:Hide()
    end
end

if ActionButtonSpellAlertManager then
    hooksecurefunc(ActionButtonSpellAlertManager, "ShowAlert", function(_, button)
        hideGlow(button)
    end)
else
    hooksecurefunc("ActionButton_ShowOverlayGlow", hideGlow)
end
