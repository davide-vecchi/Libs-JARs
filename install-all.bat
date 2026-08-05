@ECHO OFF
REM ============================================================================
REM install-all.bat
REM
REM Launcher for install-all.ps1
REM
REM Usage: Double-click this file, or run from Command Prompt.
REM ============================================================================

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-all.ps1"
PAUSE
