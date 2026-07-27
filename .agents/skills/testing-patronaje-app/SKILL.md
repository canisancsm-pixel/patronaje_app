---
name: testing-patronaje-app
description: Cómo ejecutar y probar end-to-end la app Flutter patronaje_app en Linux (desktop), incluyendo el flujo Medidas → PDF → Historial y las trampas de rutas hardcodeadas de Windows.
---

# Probar patronaje_app en Linux

## Entorno

- Flutter NO está en el PATH: `export PATH=$PATH:/home/ubuntu/flutter/bin`.
- La funcionalidad de PDF/historial usa `dart:io` (`File`), así que **web no sirve**. Usar
  **Linux desktop**.
- Toolchain necesaria (si falla `apt-get install` con 404, ejecutar primero `sudo apt-get update`):
  ```bash
  sudo apt-get update -qq
  sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  export PATH=$PATH:/home/ubuntu/flutter/bin
  flutter config --enable-linux-desktop
  flutter build linux --debug     # o --release
  ```
- Arrancar el binario eligiendo el CWD (importante, ver rutas más abajo) y en el display real
  (`:0`, no `:1`):
  ```bash
  mkdir -p /home/ubuntu/patronaje_run && cd /home/ubuntu/patronaje_run
  DISPLAY=:0 /home/ubuntu/repos/patronaje_app/build/linux/x64/debug/bundle/patronaje_app &
  wmctrl -r patronaje_app -b add,maximized_vert,maximized_horz
  ```
- Preferir **build release** para grabar: en debug el banner rojo "DEBUG" tapa los `actions` del
  AppBar situados en la esquina superior derecha (p. ej. el icono refresh del historial). El botón
  sigue siendo clicable, pero no se ve en el video.

## Rutas de salida (trampa importante)

`HistorialService.carpetaPatrones` está hardcodeada como
`C:/flutter_projects/patronaje_app/patrones_PDF`. En Linux eso es una ruta **relativa al CWD** del
proceso, así que los archivos aparecen en:

```
$CWD/C:/flutter_projects/patronaje_app/patrones_PDF/{Patron_<Prenda>_Escala_1_1.pdf,historial.json}
```

Por eso conviene arrancar la app desde un directorio limpio y dedicado. Si en el futuro se migra a
`path_provider`, buscar en `~/.local/share/<app>/`. El `filePath` guardado en `historial.json`
hereda esa ruta relativa, por lo que "Abrir PDF" (`open_filex`) puede lanzar el visor con una ruta
no resoluble (Chrome muestra página en blanco) sin devolver error: eso es limitación de plataforma,
no necesariamente un fallo del cambio bajo prueba.

## Flujo UI end-to-end

1. Pantalla inicial "Medidas": el formulario tiene 27 campos. Forma rápida de rellenarlo: clic en
   "Contorno de cuello" y luego alternar `type` + `Tab` (los `FocusNode` están en el mismo orden
   visual). Todos los valores deben ser numéricos > 0 o "Continuar" muestra snackbar rojo.
2. Al final del formulario: "Continuar" (gris), "Guardar medidas" (azul), "Cargar medidas" (verde),
   "Historial de patrones" (morado).
3. "Continuar" → "Elegir Prenda" → tocar p. ej. "Blusa" → "Generar Patrón" (el patrón ya se dibuja;
   hay botones "Calcular patrón" y "Exportar PDF" al fondo, hay que hacer scroll) →
   "Exportar PDF" → "Generar PDF" → snackbar verde "El PDF ha sido generado correctamente.".
4. Volver con la flecha del AppBar hasta "Medidas" y abrir "Historial de patrones".

## Verificaciones útiles

- Comprobar el PDF con `head -c 8 archivo.pdf` (`%PDF-1.5`) y abrirlo en Chrome con
  `file:///.../Patron_Blusa_Escala_1_1.pdf` para ver que el cuadro "Medidas utilizadas" contiene los
  valores introducidos.
- Probar el refresh del historial de forma adversarial: con la pantalla abierta, añadir un registro
  al `historial.json` por shell; la lista no debe cambiar hasta pulsar el icono refresh.
- Nota: `ExportarPDFScreen` no pasa `variante` al `PDFEngine`, así que el subtítulo del historial
  puede salir como "Blusa ·" con la variante vacía. Puede seguir siendo así en el futuro.
- El nombre del PDF depende solo de la prenda, así que regenerar la misma prenda sobrescribe el
  archivo y añade otro registro al historial.

## Devin Secrets Needed

Ninguno.
