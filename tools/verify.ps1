param(
    [string]$GodotExecutable = 'D:\Godot\Godot_v4.7.2-stable_win64_console.exe',
    [string]$PythonExecutable = 'python',
    [switch]$FullSizeMatrix,
    [switch]$RecordMovie
)

$ErrorActionPreference = 'Stop'
$taskProject = Split-Path -Parent $PSScriptRoot
$taskEvidence = Join-Path $taskProject 'build\visual-overhaul-evidence'
$taskLogs = Join-Path $taskEvidence 'logs'
New-Item -ItemType Directory -Force $taskLogs | Out-Null
New-Item -ItemType File -Force (Join-Path $taskProject 'build\.gdignore') | Out-Null
$env:APPDATA = Join-Path $taskProject 'build\verification-appdata'
New-Item -ItemType Directory -Force $env:APPDATA | Out-Null
$taskResults = [Collections.Generic.List[object]]::new()

function Invoke-GodotStage {
    param([string]$Stage, [string[]]$Arguments, [string]$ExpectedError = '')
    $taskStarted = Get-Date
    $taskLog = Join-Path $taskLogs ($Stage + '.log')
    # Native stderr is retained. Expected negative tests remain visible in the log.
    $taskOutput = & $GodotExecutable @Arguments 2>&1 | ForEach-Object { "$_" }
    $taskExit = $LASTEXITCODE
    $taskOutput | Set-Content -Encoding utf8 $taskLog
    $taskErrors = @($taskOutput | Where-Object { $_ -match 'SCRIPT ERROR:|^ERROR:|^WARNING:' })
    $taskUnexpected = @($taskErrors | Where-Object { $ExpectedError -eq '' -or $_ -notmatch $ExpectedError })
    $taskPassed = $taskExit -eq 0 -and $taskUnexpected.Count -eq 0
    $taskResults.Add([pscustomobject]@{ stage=$Stage; exit_code=$taskExit; passed=$taskPassed; seconds=((Get-Date)-$taskStarted).TotalSeconds; log=$taskLog; expected_error_count=($taskErrors.Count-$taskUnexpected.Count) })
    $taskResults | ConvertTo-Json -Depth 6 | Set-Content -Encoding utf8 (Join-Path $taskEvidence 'verification-summary.json')
    Write-Host "$Stage : $(if ($taskPassed) {'PASS'} else {'FAIL'})"
    $taskOutput | Where-Object { $_ -match 'TEST_RESULT|PRESENTATION|CONTROLLER_RESULT|RESPONSIVE_RESULT|PROFILE_RESULT|RECORDING_RESULT|UI_SMOKE:' } | Write-Host
    if (-not $taskPassed) { throw "Stage $Stage failed; inspect $taskLog" }
}

Push-Location $taskProject
try {
    Invoke-GodotStage 'engine-version' @('--version')
    Invoke-GodotStage 'editor-import' @('--headless','--path',$taskProject,'--editor','--import','--quit')
    Invoke-GodotStage 'domain-tests' @('--headless','--path',$taskProject,'--script','tests/run.gd') '^ERROR: Could not create directory:.*test-saves-.*slot_b.json/child'
    Invoke-GodotStage 'presentation-tests' @('--headless','--path',$taskProject,'--script','tests/presentation.gd') '^ERROR: Could not create directory:.*(presentation|visual|blocked)'
    Invoke-GodotStage 'controller-tests' @('--path',$taskProject,'--resolution','360x640','--script','tests/controller.gd','--','--startup-smoke') '^ERROR: Could not create directory:.*blocked'
    Invoke-GodotStage 'startup-headless' @('--headless','--path',$taskProject,'--quit-after','120','--','--startup-smoke')
    $taskSizes = if ($FullSizeMatrix) { @('320x568','360x640','393x852','412x915','720x1280','1080x1920','360x480') } else { @('360x640','393x852') }
    foreach ($taskSize in $taskSizes) {
        Invoke-GodotStage ('render-' + $taskSize) @('--path',$taskProject,'--resolution',$taskSize,'--','--ui-smoke',('--capture-size=' + $taskSize)) '^ERROR: Could not create directory:.*blocked-save/child'
    }
    if (Test-Path 'tests/responsive.gd') {
        Invoke-GodotStage 'responsive-tests' @('--path',$taskProject,'--resolution','360x640','--script','tests/responsive.gd','--','--startup-smoke')
    }
    Invoke-GodotStage 'desktop-profile' @('--path',$taskProject,'--resolution','360x640','--script','tests/recording.gd','--','--startup-smoke','--profile-only')
    if ($RecordMovie) {
        Invoke-GodotStage 'movie' @('--path',$taskProject,'--resolution','360x640','--write-movie',(Join-Path $taskEvidence 'lantern-lot-demo.avi'),'--fixed-fps','30','--script','tests/recording.gd','--','--startup-smoke')
    }
    & $PythonExecutable 'art/validate_assets.py' 2>&1 | Tee-Object (Join-Path $taskLogs 'asset-gate.log')
    if ($LASTEXITCODE -ne 0) { throw 'Asset manifest validation failed.' }
    & $PythonExecutable 'tools/verify_pixels.py' 2>&1 | Tee-Object (Join-Path $taskLogs 'pixel-scale.log')
    if ($LASTEXITCODE -ne 0) { throw 'Rendered physical pixel magnification failed.' }
    Write-Host "Evidence: $taskEvidence. Review PNGs and the movie directly; automation alone does not establish art or device acceptance."
} finally {
    Pop-Location
}
