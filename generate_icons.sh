#!/bin/bash

# Скрипт для генерации иконок приложения из исходного файла
# Использование: ./generate_icons.sh /path/to/source/icon.png

if [ $# -eq 0 ]; then
    echo "Использование: $0 /path/to/source/icon.png"
    echo "Пример: $0 /home/kit/WORK/2basketball/public/logo_red.png"
    exit 1
fi

SOURCE_ICON="$1"

if [ ! -f "$SOURCE_ICON" ]; then
    echo "Ошибка: Файл $SOURCE_ICON не найден!"
    exit 1
fi

echo "Генерируем иконки из: $SOURCE_ICON"
echo "=========================================="

# Создаем папки если их нет
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset
mkdir -p web/icons

# Android иконки
echo "Генерируем Android иконки..."
convert "$SOURCE_ICON" -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
convert "$SOURCE_ICON" -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
convert "$SOURCE_ICON" -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert "$SOURCE_ICON" -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
convert "$SOURCE_ICON" -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# iOS иконки
echo "Генерируем iOS иконки..."
convert "$SOURCE_ICON" -resize 20x20 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
convert "$SOURCE_ICON" -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
convert "$SOURCE_ICON" -resize 60x60 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
convert "$SOURCE_ICON" -resize 29x29 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
convert "$SOURCE_ICON" -resize 58x58 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
convert "$SOURCE_ICON" -resize 87x87 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
convert "$SOURCE_ICON" -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
convert "$SOURCE_ICON" -resize 80x80 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
convert "$SOURCE_ICON" -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
convert "$SOURCE_ICON" -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
convert "$SOURCE_ICON" -resize 180x180 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
convert "$SOURCE_ICON" -resize 76x76 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
convert "$SOURCE_ICON" -resize 152x152 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
convert "$SOURCE_ICON" -resize 167x167 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
convert "$SOURCE_ICON" -resize 1024x1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

# Web иконки
echo "Генерируем Web иконки..."
convert "$SOURCE_ICON" -resize 192x192 web/icons/Icon-192.png
convert "$SOURCE_ICON" -resize 512x512 web/icons/Icon-512.png
convert "$SOURCE_ICON" -resize 192x192 web/icons/Icon-maskable-192.png
convert "$SOURCE_ICON" -resize 512x512 web/icons/Icon-maskable-512.png

# Web favicon
echo "Генерируем favicon..."
convert "$SOURCE_ICON" -resize 32x32 web/favicon.png

echo "=========================================="
echo "✅ Все иконки успешно сгенерированы!"
echo ""
echo "Созданные файлы:"
echo "📱 Android: 5 иконок в android/app/src/main/res/mipmap-*/"
echo "🍎 iOS: 15 иконок в ios/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "🌐 Web: 4 иконки в web/icons/ + favicon.png"
echo ""
echo "Теперь вы можете собрать приложение с новыми иконками!"

