@echo off
setlocal enabledelayedexpansion

:: Configuration
set "OUTPUT=ProcessHitman.exe"
set "SOURCE=hitman.cpp"
set "RESOURCE=resources.rc"
set "RESOURCE_OBJ=resources.o"

:: Compiler flags
set "CXXFLAGS=-O2 -Wall -Wextra -std=c++11"
set "LINKFLAGS=-static -static-libgcc -static-libstdc++"
set "WINFLAGS=-mwindows -municode"

:: Colors
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

:: Title
title Process Hitman Build Script

echo %BLUE%=================================%RESET%
echo %BLUE%  Process Hitman Build Script    %RESET%
echo %BLUE%=================================%RESET%
echo.

:: Check for required tools
echo %BLUE%Checking required tools...%RESET%
where g++ >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%Error: g++ not found! Please install MinGW-w64 and add it to PATH.%RESET%
    echo %YELLOW%Download MinGW-w64 from: https://winlibs.com/%RESET%
    goto :error
)

where windres >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%Error: windres not found! Please install MinGW-w64 and add it to PATH.%RESET%
    goto :error
)

:: Check if source files exist
echo %BLUE%Checking source files...%RESET%
if not exist "%SOURCE%" (
    echo %RED%Error: Source file %SOURCE% not found!%RESET%
    goto :error
)

if not exist "%RESOURCE%" (
    echo %RED%Error: Resource file %RESOURCE% not found!%RESET%
    goto :error
)

:: Clean previous build
echo %BLUE%Cleaning previous build...%RESET%
if exist "%OUTPUT%" (
    del "%OUTPUT%" 2>nul
    if exist "%OUTPUT%" (
        echo %RED%Error: Could not delete previous build!%RESET%
        goto :error
    ) else (
        echo %GREEN%Previous build cleaned successfully.%RESET%
    )
)

:: Compile resources
echo %BLUE%Compiling resources...%RESET%
windres "%RESOURCE%" -O coff -o "%RESOURCE_OBJ%"
if %ERRORLEVEL% neq 0 (
    echo %RED%Error: Failed to compile resources!%RESET%
    goto :error
)
echo %GREEN%Resources compiled successfully.%RESET%

:: Compile main program
echo %BLUE%Compiling main program...%RESET%
g++ %CXXFLAGS% %LINKFLAGS% %WINFLAGS% -o "%OUTPUT%" "%SOURCE%" "%RESOURCE_OBJ%" 
if %ERRORLEVEL% neq 0 (
    echo %RED%Error: Compilation failed!%RESET%
    goto :error
)

:: Clean up resource object file
del "%RESOURCE_OBJ%" 2>nul

:: Check if compilation was successful
if exist "%OUTPUT%" (
    echo %GREEN%Build completed successfully!%RESET%
    echo %GREEN%Output file: %OUTPUT%%RESET%
) else (
    echo %RED%Error: Output file not created!%RESET%
    goto :error
)

:: Optional: Show file size
for %%A in ("%OUTPUT%") do (
    echo %BLUE%File size: %%~zA bytes%RESET%
)

echo.
echo %BLUE%=================================%RESET%
echo %GREEN%  Build Process Complete        %RESET%
echo %BLUE%=================================%RESET%

goto :end

:error
echo.
echo %RED%=================================%RESET%
echo %RED%  Build Process Failed           %RESET%
echo %RED%=================================%RESET%
exit /b 1

:end
endlocal
pause
