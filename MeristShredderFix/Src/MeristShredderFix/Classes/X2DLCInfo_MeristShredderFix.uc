class X2DLCInfo_MeristShredderFix extends X2DownloadableContentInfo;

var config(ShredderFixes) bool bRemoveWeaponFixesEffect;
var config(ShredderFixes) bool bRemoveLWEffect;

static event OnPostTemplatesCreated()
{
    local X2AbilityTemplateManager  AbilityManager;
    local X2AbilityTemplate         AbilityTemplate;
    local X2Effect_Persistent       PersistentEffect;
    local int                       Index;

    AbilityManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
    AbilityTemplate = AbilityManager.FindAbilityTemplate('Shredder');
    if (AbilityTemplate != none)
    {
        for (Index = AbilityTemplate.AbilityTargetEffects.Length - 1; Index >= 0; Index--)
        {
            if (default.bRemoveLWEffect && AbilityTemplate.AbilityTargetEffects[Index].IsA('X2Effect_PassiveShredder_LW')
                || default.bRemoveWeaponFixesEffect && AbilityTemplate.AbilityTargetEffects[Index].IsA('X2Effect_PrimaryShredder'))
            {
                AbilityTemplate.AbilityTargetEffects.Remove(Index, 1);
            }
        }

        PersistentEffect = new class'X2Effect_ShredderFix';
        PersistentEffect.BuildPersistentEffect(1, true, false);
        AbilityTemplate.AddTargetEffect(PersistentEffect);
    }
}