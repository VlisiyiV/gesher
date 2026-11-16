$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
. (Join-Path $repoRoot 'tools/package/gesher-ui.ps1')
$cases = @{
    'he-IL-u-ca-hebrew,en-US' = 'he'
    ' HE_il , en-US' = 'he'
    'de-DE,iw-IL,en-US' = 'he'
    'en-GB,he-IL' = 'en'
    'ar-SA,fr-FR' = 'en'
    'hebrew,xx' = 'en'
    'zh-CN,en-US' = 'zh'
    ' ZH_hans_cn ' = 'zh'
    'ja-JP,zh-TW' = 'zh'
    'zhx,en-US' = 'en'
    '' = 'en'
}
foreach ($case in $cases.GetEnumerator()) {
    if ((Get-GesherUiLanguage $case.Key) -ne $case.Value) { throw "Language selection: $($case.Key)" }
}
$detected = [Gesher.UiLanguages]::Read()
if ([string]::IsNullOrWhiteSpace($detected)) { throw 'UiLanguages::Read returned empty' }
$script:GesherUiLanguage = 'he'
$path = 'C:\שלום\{1}.apk'
if ((Get-GesherText 'microg_missing' @($path)) -ne "קובץ ההרחבה אינו קיים: $path") { throw 'Literal placeholder in path changed' }
if ((Get-GesherText 'starting') -ne 'מפעיל…') { throw 'Hebrew string missing' }
$script:GesherUiLanguage = 'en'
if ((Get-GesherText 'starting') -ne 'Starting…') { throw 'English string missing' }
$script:GesherUiLanguage = 'zh'
if ((Get-GesherText 'microg_missing' @($path)) -ne "附加组件文件不存在：$path") { throw 'Literal placeholder in path changed (zh)' }
if ((Get-GesherText 'starting') -ne '正在启动…') { throw 'Chinese string missing' }
if ((Get-GesherText 'cp_install_failed' @('base.apk')) -ne '安装 base.apk 失败。') { throw 'Chinese install failure text missing' }
foreach ($file in 'gesher-ui.ps1', 'gesher-app.ps1', 'gesher-app-microg.ps1', 'gesher-control-panel.ps1', 'gesher-update.ps1') {
    $tokens = $null; $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $repoRoot "tools/package/$file"), [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count) { throw ($parseErrors | Out-String) }
}
'PASS: PowerShell UI translations, language selection, literal paths and entry point syntax'
