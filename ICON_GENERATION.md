# Генерация иконок приложения

Этот проект содержит скрипты для автоматической генерации иконок приложения из исходного файла для всех поддерживаемых платформ.

## Доступные скрипты

### 1. `generate_icons.sh` (оригинальный)
- Использует команду `convert` (устаревшая)
- Работает, но выводит предупреждения

### 2. `generate_icons_v2.sh` (рекомендуемый)
- Использует современную команду `magick`
- Без предупреждений
- Более быстрая работа

## Использование

```bash
# Сделать скрипт исполняемым (если еще не сделано)
chmod +x generate_icons_v2.sh

# Запустить генерацию иконок
./generate_icons_v2.sh /path/to/your/icon.png

# Пример с вашей иконкой
./generate_icons_v2.sh /home/kit/WORK/2basketball/public/logo_red.png
```

## Что генерируется

### Android (5 иконок)
- `mipmap-mdpi/ic_launcher.png` - 48x48px
- `mipmap-hdpi/ic_launcher.png` - 72x72px
- `mipmap-xhdpi/ic_launcher.png` - 96x96px
- `mipmap-xxhdpi/ic_launcher.png` - 144x144px
- `mipmap-xxxhdpi/ic_launcher.png` - 192x192px

### iOS (15 иконок)
- `Icon-App-20x20@1x.png` - 20x20px
- `Icon-App-20x20@2x.png` - 40x40px
- `Icon-App-20x20@3x.png` - 60x60px
- `Icon-App-29x29@1x.png` - 29x29px
- `Icon-App-29x29@2x.png` - 58x58px
- `Icon-App-29x29@3x.png` - 87x87px
- `Icon-App-40x40@1x.png` - 40x40px
- `Icon-App-40x40@2x.png` - 80x80px
- `Icon-App-40x40@3x.png` - 120x120px
- `Icon-App-60x60@2x.png` - 120x120px
- `Icon-App-60x60@3x.png` - 180x180px
- `Icon-App-76x76@1x.png` - 76x76px
- `Icon-App-76x76@2x.png` - 152x152px
- `Icon-App-83.5x83.5@2x.png` - 167x167px
- `Icon-App-1024x1024@1x.png` - 1024x1024px

### Web (5 иконок)
- `Icon-192.png` - 192x192px
- `Icon-512.png` - 512x512px
- `Icon-maskable-192.png` - 192x192px (маскируемая)
- `Icon-maskable-512.png` - 512x512px (маскируемая)
- `favicon.png` - 32x32px

## Требования

- ImageMagick должен быть установлен
- Проверить установку: `which magick` или `which convert`

## Сборка приложения

После генерации иконок можно собрать приложение:

```bash
# Очистить кэш
flutter clean

# Собрать для Android
flutter build apk

# Собрать для iOS (только на macOS)
flutter build ios

# Собрать для Web
flutter build web
```

## Рекомендации по иконкам

1. **Исходный файл** должен быть квадратным (например, 1024x1024px)
2. **Формат** - PNG с прозрачностью или без (в зависимости от дизайна)
3. **Качество** - высокое разрешение для лучшего результата при масштабировании
4. **Дизайн** - простой и узнаваемый, так как иконки будут маленькими

## Устранение проблем

### Ошибка "command not found: magick"
```bash
# Установить ImageMagick
sudo pacman -S imagemagick  # Arch Linux
sudo apt install imagemagick  # Ubuntu/Debian
brew install imagemagick  # macOS
```

### Ошибка "command not found: convert"
```bash
# Использовать magick вместо convert
./generate_icons_v2.sh /path/to/icon.png
```

### Иконки не отображаются после сборки
1. Убедитесь, что файлы созданы в правильных папках
2. Выполните `flutter clean` перед сборкой
3. Проверьте права доступа к файлам

