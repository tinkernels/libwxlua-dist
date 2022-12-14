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

set TK_Wx_Dist=wxWidgets-dist-win32
rmdir /q /s "%TK_Wx_Dist%"
move "build-wxWidgets\x86" "%TK_Wx_Dist%"
pushd "%TK_Wx_Dist%"
    %_PSC% "Get-ChildItem -Name -Depth 0 -Exclude lib,include | Remove-Item -Recurse -Force"
popd

set TK_Wx_Dist=wxWidgets-dist-winx64
rmdir /q /s "%TK_Wx_Dist%"
move "build-wxWidgets\x64" "%TK_Wx_Dist%"
pushd "%TK_Wx_Dist%"
    %_PSC% "Get-ChildItem -Name -Depth 0 -Exclude lib,include | Remove-Item -Recurse -Force"
popd

@REM cd /d "%~dp0build-wxlua"
@REM %_PSC% "Get-ChildItem -Path '%~dp0build-wxlua' -File -Recurse -Exclude *.h,*.dll,*.lib,*.exp | Remove-Item -Force"
@REM %_PSC% "$f=[IO.File]::ReadAllText('%_batp%') -split ':embeded_ps1\:.*'; iex($f[1]); _func -Directory '%~dp0build-wxlua'"

goto __END

:embeded_ps1:
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
:embeded_ps1:

:__END