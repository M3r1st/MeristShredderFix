class X2Effect_ShredderFix extends X2Effect_Persistent config(ShredderFixes);

struct BonusShred
{
    var name WeaponTech;
    var int Shred;
};

var config bool                     bApplyToAnyWeaponCategory;
var config array<name>              ValidWeaponCategories;
var config array<name>              InvalidWeaponCategories;
var config bool                     bApplyToAnySlot;
var config array<EInventorySlot>    ValidInventorySlots;
var config array<BonusShred>        ShredderPerWeaponTech;

function int GetExtraShredValue(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData) 
{
    local X2Effect_ApplyWeaponDamage    DamageEffect;
    local WeaponDamageValue             DamageValue;
    local XComGameState_Item            SourceWeapon;
    local X2WeaponTemplate              WeaponTemplate;
    local int                           Index;

    if (Attacker.HasSoldierAbility('Shredder'))
    {
        DamageEffect = X2Effect_ApplyWeaponDamage(GetX2Effect(AppliedData.EffectRef));
        if (DamageEffect != none && DamageEffect.bApplyOnHit)
        {
            SourceWeapon = AbilityState.GetSourceWeapon();
            if (SourceWeapon != none)
            {
                WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
                if (WeaponTemplate != none)
                {
                    // This is a Shredder effect; apply only the tech level fix
                    if (X2Effect_Shredder(DamageEffect) != none)
                    {
                        // Check if the effect has shred
                        DamageValue = DamageEffect.GetBonusEffectDamageValue(AbilityState, Attacker, SourceWeapon, AppliedData.TargetStateObjectRef);
                        if (DamageValue.Shred > 0)
                        {
                            Index = default.ShredderPerWeaponTech.Find('WeaponTech', WeaponTemplate.WeaponTech);
                            if (Index != INDEX_NONE)
                            {
                                return default.ShredderPerWeaponTech[Index].Shred - GetShredderValue(WeaponTemplate.WeaponTech);
                            }
                        }
                    }
                    else // This is not a Shredder effect; check if the "primary Shredder" fix needs to be applied
                    {
                        // Only apply the fix if the slot and the weapon category are valid
                        if (IsValidSlot(SourceWeapon.InventorySlot) && IsValidWeaponCategory(SourceWeapon.GetWeaponCategory()))
                        {
                            Index = default.ShredderPerWeaponTech.Find('WeaponTech', WeaponTemplate.WeaponTech);
                            // If the value is configured, use it
                            if (Index != INDEX_NONE)
                            {
                                return default.ShredderPerWeaponTech[Index].Shred;
                            }
                            else // If the value is not configured, use the default Shredder value
                            {
                                return GetShredderValue(WeaponTemplate.WeaponTech);
                            }
                        }
                    }
                }
            }
        }
    }

    return 0;
}

private static function bool IsValidWeaponCategory(name WeaponTech)
{
    if (default.bApplyToAnyWeaponCategory || default.ValidWeaponCategories.Length == 0)
    {
        return default.InvalidWeaponCategories.Find(WeaponTech) == INDEX_NONE;
    }

    return default.ValidWeaponCategories.Find(WeaponTech) != INDEX_NONE;
}

private static function bool IsValidSlot(EInventorySlot Slot)
{
    return default.bApplyToAnySlot || default.ValidInventorySlots.Find(Slot) != INDEX_NONE;
}

private static function int GetShredderValue(name WeaponTech)
{
    switch (WeaponTech)
    {
        case 'magnetic':
            return class'X2Effect_Shredder'.default.MagneticShred;

        case 'beam':
            return class'X2Effect_Shredder'.default.BeamShred;

        default:
            return class'X2Effect_Shredder'.default.ConventionalShred;
    }

    return 0;
}

defaultproperties
{
    EffectName = "M31_ShredderFixed"
    DuplicateResponse = eDupe_Ignore
}