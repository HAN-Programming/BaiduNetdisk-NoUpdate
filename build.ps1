param(
    [Parameter(Mandatory=$true)][string]$CompilerRoot
)
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$compilerRootPath = [IO.Path]::GetFullPath($CompilerRoot)
$clang = Join-Path $compilerRootPath 'bin\i686-w64-mingw32-clang.exe'
$windres = Join-Path $compilerRootPath 'bin\i686-w64-mingw32-windres.exe'
foreach ($tool in @($clang,$windres)) {
    if (!(Test-Path -LiteralPath $tool -PathType Leaf)) { throw "Missing compiler tool: $tool" }
}
$build = Join-Path $repo 'build'
$dist = Join-Path $repo 'dist'
$runtime = Join-Path $dist 'App\.portable\runtime'
$oldTemp = $env:TEMP
$oldTmp = $env:TMP
New-Item -ItemType Directory -Path $build,$runtime,(Join-Path $build 'tmp') -Force | Out-Null
try {
    # Only the build process environment changes. No user/machine setting is written.
    $env:TEMP = Join-Path $build 'tmp'
    $env:TMP = $env:TEMP
    Push-Location $repo
    try {
        $flags = @('-O2','-DNDEBUG','-Wall','-Wextra','-Wno-unused-function','-static','-s',
            "-ffile-prefix-map=$repo=.","-fdebug-prefix-map=$repo=.")
        $sources = @('src\guard.c','third_party\minhook\src\buffer.c',
            'third_party\minhook\src\hook.c','third_party\minhook\src\trampoline.c',
            'third_party\minhook\src\hde\hde32.c')
        & $clang @flags -Wno-unused-parameter -shared -I third_party\minhook\include @sources -ladvapi32 -lws2_32 -o (Join-Path $runtime 'bdpguard32.dll')
        if ($LASTEXITCODE -ne 0) { throw 'Guard build failed' }
        & $windres -I src src\launcher.rc -o (Join-Path $build 'launcher-resource.o')
        if ($LASTEXITCODE -ne 0) { throw 'Resource build failed' }
        & $clang @flags -Wno-missing-field-initializers -municode -mwindows src\launcher.c (Join-Path $build 'launcher-resource.o') -luser32 -o (Join-Path $dist '百度网盘便携启动.exe')
        if ($LASTEXITCODE -ne 0) { throw 'Launcher build failed' }
        Copy-Item -LiteralPath (Join-Path $repo 'third_party\minhook\LICENSE.txt') -Destination (Join-Path $runtime 'LICENSE-MINHOOK.txt')
        Copy-Item -LiteralPath (Join-Path $repo 'LICENSE') -Destination (Join-Path $runtime 'LICENSE-LAUNCHER.txt')
        Copy-Item -LiteralPath (Join-Path $repo 'portable.ini') -Destination (Join-Path $dist 'App\portable.ini')
        New-Item -ItemType Directory -Path (Join-Path $dist 'Downloads') -Force | Out-Null
    } finally { Pop-Location }
} finally {
    $env:TEMP = $oldTemp
    $env:TMP = $oldTmp
}
Write-Output 'Built launcher layer under dist. Original client files are not included.'
