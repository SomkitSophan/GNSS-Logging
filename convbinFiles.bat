@echo off
setlocal enabledelayedexpansion

set "SourceFolder=C:\S4C_Computations\Bin" rem โฟลเดอร์ต้นทาง
set "DestinationFolder=C:\S4C_Computations\Results" rem โฟลเดอร์ปลายทาง
set "TargetIndices=1" rem ลำดับที่ของไฟล์ที่ดำเนินการ คั่นด้วยช่องว่าง

rem สร้างโฟลเดอร์ปลายทางหากยังไม่มี
if not exist "%DestinationFolder%" mkdir "%DestinationFolder%"

set /a file_index = 0

REM ตรวจสอบว่าโฟลเดอร์มีอยู่จริงหรือไม่ก่อนนับไฟล์
if not exist "%SourceFolder%" (
    echo Folder "%SourceFolder%" does not exist.
    goto :end_script
)

REM นับจำนวนไฟล์ทั้งหมดในโฟลเดอร์ที่ระบุ
for /f %%a in ('dir "%SourceFolder%\*.ubx" /b /a-d ^| find /c /v ""') do set file_count=%%a

REM ตรวจสอบเงื่อนไข
if %file_count% geq 2 (
    rem วนลูปผ่านชื่อไฟล์ในโฟลเดอร์ต้นทาง เรียงตาม dir /b
    for /f "delims=" %%F in ('dir "%SourceFolder%\*.ubx" /b /a-d /o:n') do (
        set /a file_index = !file_index! + 1

        rem ตรวจสอบว่า index ปัจจุบันอยู่ใน TargetIndices หรือไม่
        rem วิธีเช็คใน Batch Script คือการดูว่าสตริง " TargetIndices " มี " index " อยู่หรือไม่
        echo Checking file #!file_index!: "%%F"
        echo !TargetIndices! | findstr /W "!file_index!" >nul

        if !errorlevel! equ 0 (
            rem ถ้า index ตรงกับที่ต้องการ
            set "FileName=%%F"
            set "SourcePath=%SourceFolder%\!FileName!"
            set "DestinationPath=%DestinationFolder%" rem ย้ายโดยใช้ชื่อเดิม

            rem ตรวจสอบว่าไฟล์ต้นฉบับมีอยู่จริงก่อนแปลง
            if exist "!SourcePath!" (
                echo Converting file #!file_index!: "!FileName!" to "%DestinationFolder%"
                rem *** รันคำสั่งแปลง Bin เป็น RINEX ***
                C:\S4C_Computations\RTKlib\convbin.exe "!SourcePath!" -ti 1 -tt 0 -od -os -oi -ot -ol -scan -halfc -r ubx -ro -TADJ=1.0 -d "!DestinationPath!" -o SN560_last15min.o -n SN560_last15min.n -s SN560_last15min.s
                echo Deleted file: "!SourcePath!"
                del "!SourcePath!"  rem ลบไฟล์ Bin
                python C:\S4C_Computations\Pycharm\S4computing_rt15min.py   rem *** รันคำสั่งคำนวณค่า S4C ***
            ) else (
                echo Error: File #!file_index! "!FileName!" not found at "!SourcePath!"
            )
        )
    )
) else (
    echo Folder "%SourceFolder%" contains %file_count% files.
)

:end_script