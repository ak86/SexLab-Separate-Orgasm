@ECHO OFF
SET ThisScriptsDirectory=%~dp0
SET PSSctiptName=Deploy.ps1
SET PowerShellScriptPath=%ThisScriptsDirectory%%PSSctiptName%
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'";