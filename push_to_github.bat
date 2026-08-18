@echo off
chcp 65001 > nul
echo ======================================================
echo    🚀 تجهيز ورفع تطبيق كونتنتاوي إلى GitHub السحابي
echo ======================================================
echo.
set /p REPO_URL="أدخل رابط الـ Repository بتاعك على GitHub: "

if "%REPO_URL%"=="" (
    echo [!] لم يتم إدخال رابط، تم الإلغاء.
    pause
    exit /b
)

echo.
echo [*] جاري تهيئة Git وحفظ التعديلات...
git init
git add .
git commit -m "Build Contentawy v1.0.0 Release"
git branch -M main
git remote remove origin >nul 2>&1
git remote add origin %REPO_URL%

echo.
echo [*] جاري الرفع إلى GitHub لبدء البناء السحابي التلقائي...
git push -u origin main

echo.
echo ======================================================
echo [OK] تم الرفع بنجاح! 
echo افتح صفحة الـ Repo واضغط على تبويب Actions لتنزيل ملف APK فوراً!
echo ======================================================
pause
