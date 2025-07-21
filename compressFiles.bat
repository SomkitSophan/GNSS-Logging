@echo off
setlocal enabledelayedexpansion

set "SourceFolder=C:\S4C_Computations\Bin" rem *** โฟลเดอร์ต้นทาง ***
set "TargetIndices=1" rem ลำดับที่ของไฟล์ที่ต้องการบีบอัด คั่นด้วยช่องว่าง
set "YYYY=%date:~-4%" rem อ่านค่าปีปัจจุบัน

set /a file_index = 0

REM ตรวจสอบว่าโฟลเดอร์มีอยู่จริงหรือไม่ก่อนนับไฟล์
if not exist "%SourceFolder%\%YYYY%" (
    echo Folder "%SourceFolder%\%YYYY%" does not exist.
    goto :end_script
)

REM นับจำนวนไฟล์ทั้งหมดในโฟลเดอร์ที่ระบุ
for /f %%a in ('dir "%SourceFolder%\%YYYY%\*.ubx" /b /a-d ^| find /c /v ""') do set file_count=%%a

REM ตรวจสอบเงื่อนไข
if %file_count% geq 2 (
    rem วนลูปผ่านชื่อไฟล์ในโฟลเดอร์ต้นทาง เรียงตาม dir /b
    for /f "delims=" %%F in ('dir "%SourceFolder%\%YYYY%\*.ubx" /b /a-d /o:n') do (
        set /a file_index = !file_index! + 1

        rem ตรวจสอบว่า index ปัจจุบันอยู่ใน TargetIndices หรือไม่
        rem วิธีเช็คใน Batch Script คือการดูว่าสตริง " TargetIndices " มี " index " อยู่หรือไม่
        echo Checking file #!file_index!: "%%F"
        echo !TargetIndices! | findstr /W "!file_index!" >nul

        if !errorlevel! equ 0 (
            rem ถ้า index ตรงกับที่ต้องการ
            set "FileName=%%F"
            set "SourcePath=%SourceFolder%\%YYYY%\!FileName!"

            rem ตรวจสอบว่าไฟล์ต้นฉบับมีอยู่จริงก่อนบีบอัด
            if exist "!SourcePath!" (
                echo Compressing file #!file_index!: "!FileName!"
                "C:\S4C_Computations\RTKlib\gzip.exe" -S .zip -f "!SourcePath!" rem *** รันคำสั่งบีบอัดข้อมูล ***
            ) else (
                echo Error: File #!file_index! "!FileName!" not found at "!SourcePath!"
            )
        )
    )
) else (
    echo Folder "%SourceFolder%\%YYYY%" contains %file_count% files.
)

:end_script