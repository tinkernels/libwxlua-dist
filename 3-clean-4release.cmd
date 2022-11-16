@echo off
chcp 65001 >NUL 2>NUL

cd /d %~dp0

set _PWSH=powershell
where pwsh.exe 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo=
    echo found pwsh
    set _PWSH=pwsh
)
set _PSC=%_PWSH% -NoProfile -ExecutionPolicy Bypass -Command

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

for %%i in (
        build-wxWidgets\x86
        build-wxWidgets\x64
) do (
    cd "%~dp0%%i"
    %_PSC% "Get-ChildItem -Name -Depth 0 -Exclude lib,include | Remove-Item -Recurse -Force"
)

cd /d "%~dp0build-wxlua"
%_PSC% "Get-ChildItem -Path '%~dp0build-wxlua' -File -Recurse -Exclude *.h,*.dll,*.lib,*.exp | Remove-Item -Force"
%_PSC% "$f=[IO.File]::ReadAllText('%_batp%') -split ':remove_empty_dirs\:.*'; iex($f[1]); _func -Directory '%~dp0build-wxlua'"

:__end
exit

:remove_empty_dirs:
function _func {
    param (
        [string]$Directory
    )
    $action_count=0
    do {
        $action_count=0
        $all_empty_directories=Get-ChildItem -Path $Directory -Directory -Recurse | Where-Object { $_.GetFileSystemInfos().Count -eq 0 }
        foreach ($d in $all_empty_directories) {
           $fname=$d.FullName
           Remove-Item -Force $fname
           Write-Output "Removing $fname"
           $action_count++
        }
    } while ($action_count -ne 0)
}
:remove_empty_dirs:
