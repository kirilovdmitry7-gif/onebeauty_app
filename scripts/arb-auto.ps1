param(
  [string]$ApiBase = "http://127.0.0.1:8788",
  [string[]]$Locales = @("ru","es"),
  [switch]$CopyEmpty
)

# go to repo root (script is in /scripts)
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

# build args for dart
$dartArgs = @("run","tool/translate_arb_ai.dart","--locales=$($Locales -join ',')")
if ($CopyEmpty) {
  $dartArgs += "--copy-empty"
} else {
  $dartArgs += "--api-base=$ApiBase"
}

Write-Host ">>> dart $($dartArgs -join ' ')"
& dart @dartArgs
if ($LASTEXITCODE -ne 0) { throw "translate_arb_ai failed ($LASTEXITCODE)" }

Write-Host ">>> flutter gen-l10n"
& flutter "gen-l10n"
if ($LASTEXITCODE -ne 0) { throw "flutter gen-l10n failed ($LASTEXITCODE)" }

Write-Host "Done."
