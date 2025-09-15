# Icons para POS-RoR Desktop

Esta carpeta debe contener los iconos necesarios para la aplicación de escritorio:

## Archivos Requeridos

- `32x32.png` - Icono pequeño (32x32 píxeles)
- `128x128.png` - Icono mediano (128x128 píxeles)  
- `128x128@2x.png` - Icono mediano alta resolución (256x256 píxeles)
- `icon.icns` - Icono para macOS
- `icon.ico` - Icono para Windows

## Generación Automática

Puedes usar herramientas online para generar todos los tamaños desde una imagen base:

1. **Favicon.io**: https://favicon.io/favicon-converter/
2. **RealFaviconGenerator**: https://realfavicongenerator.net/
3. **IconGenerator**: https://icon.kitchen/

## Comandos útiles

```bash
# Generar desde PNG con ImageMagick
convert icon-source.png -resize 32x32 32x32.png
convert icon-source.png -resize 128x128 128x128.png  
convert icon-source.png -resize 256x256 128x128@2x.png

# Generar ICO para Windows
convert icon-source.png -resize 256x256 icon.ico

# Generar ICNS para macOS (requiere iconutil en macOS)
mkdir icon.iconset
convert icon-source.png -resize 16x16 icon.iconset/icon_16x16.png
convert icon-source.png -resize 32x32 icon.iconset/icon_16x16@2x.png
convert icon-source.png -resize 32x32 icon.iconset/icon_32x32.png
convert icon-source.png -resize 64x64 icon.iconset/icon_32x32@2x.png
convert icon-source.png -resize 128x128 icon.iconset/icon_128x128.png
convert icon-source.png -resize 256x256 icon.iconset/icon_128x128@2x.png
convert icon-source.png -resize 256x256 icon.iconset/icon_256x256.png
convert icon-source.png -resize 512x512 icon.iconset/icon_256x256@2x.png
convert icon-source.png -resize 512x512 icon.iconset/icon_512x512.png
convert icon-source.png -resize 1024x1024 icon.iconset/icon_512x512@2x.png
iconutil -c icns icon.iconset
```

## Placeholder

Mientras no tengas iconos personalizados, Tauri usará iconos por defecto.
