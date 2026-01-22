
# EVCharge — Informacione për ikonën e aplikacionit

Ky dokument përmban udhëzime të shkurtra për ikonat që janë përdorur dhe si t'i përditësoni ato.

## Përmbledhje
- Skeda: `assets/icon`
- Ikona kryesore: `app_icon.png` (rezolucion 1024×1024)
- Shtohet gjithashtu `app_icon_foreground.png` për adaptive Android icons

## Dizajni i ikonës
- Ngjyra bazë: #2DBE6C (gradient jeshil, simbol ekologjie)
- Elementet kryesore:
  - 🚗 Makina elektrike (fokus qendror)
  - 🍃 Gjethe jeshile (simbol i qëndrueshmërisë)
  - ⚡ Korent / rrufe (tregon karikim të shpejtë)
  - 🔌 Konektori i karikimit (simbol i lidhjes)

Stili: modern, i pastër dhe i lehtë për t'u njohur në sirtarin e aplikacioneve.

## Visual Hierarchy
1. **Top**: Charging connector/plug (white with green outline)
2. **Center**: Electric vehicle with windows and wheels
3. **Bottom Left**: Green leaf with vein detail
4. **Bottom Right**: Yellow lightning bolt for charging power
# EVCharge — Informacione për ikonën e aplikacionit

Ky dokument përmban udhëzime të shkurtra për ikonat që janë përdorur dhe si t'i përditësoni ato.

## Përmbledhje
- Skeda: `assets/icon`
- Ikona kryesore: `app_icon.png` (rezolucion 1024×1024)
- Shtohet gjithashtu `app_icon_foreground.png` për adaptive Android icons

## Dizajni i ikonës
- Ngjyra bazë: #2DBE6C (gradient jeshil, simbol ekologjie)
- Elementet kryesore:
  - 🚗 Makina elektrike (fokus qendror)
  - 🍃 Gjethe jeshile (simbol i qëndrueshmërisë)
  - ⚡ Korent / rrufe (tregon karikim të shpejtë)
  - 🔌 Konektori i karikimit (simbol i lidhjes)

Stili: modern, i pastër dhe i lehtë për t'u njohur në sirtarin e aplikacioneve.

## Si të përditësoni ikonat

1. Përgatitni një imazh të ri me madhësi 1024×1024 PNG (emërtojeni `app_icon.png`).
2. Nëse përdorni adaptive Android icons, përgatitni gjithashtu `app_icon_foreground.png` (shtresa e përparme).
3. Për të gjeneruar ikonat automatikisht përdorni paketën `flutter_launcher_icons`.

Konfigurimi i shembullit në `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#2DBE6C"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

Pas vendosjes së skedarëve të rinj, ekzekutoni:

```bash
dart run flutter_launcher_icons
```

Kjo do të përditësojë automatikisht ikonat për iOS dhe Android sipas konfigurimit.

## Përmbledhje madhësish të ikonave (për referencë)

iOS (për App Store dhe shërbime të tjera):
- 1024×1024 (App Store)
- 180×180, 167×167, 152×152, 120×120, 76×76, 60×60, 40×40, 29×29, 20×20

Android (mipmap):
- xxxhdpi (192×192), xxhdpi (144×144), xhdpi (96×96), hdpi (72×72), mdpi (48×48)

Adaptive icons Android: përdorni një imazh foreground dhe një background (ose ngjyrë). Përdoreni `app_icon_foreground.png` për shtresën frontale dhe `adaptive_icon_background` në `pubspec.yaml` për sfondin.

## Tips dhe mirëpraktika
- Përdorni PNG me sfond transparent kur krijoni shtresën e përparme për adaptive icons.
- Sigurohuni që ikona të jetë qendrore dhe elementet kryesore të mos jenë tepër të afërta me skajet (padding ~ 20–30 px në secilën anë për siguri).
- Testoni ikonën në pajisje me rezolucione të ndryshme (simulator / emulator).

## Çështje të zakonshme (Troubleshooting)
- Nëse nuk shfaqet ikona e re në iOS, provoni të ekzekutoni `flutter clean` dhe të rindërtoni projektin.
- Nëse Android ende përdor ikonën e vjetër, fshini build cache dhe rindërtoni:

```bash
flutter clean
flutter pub get
flutter run
```

## Përfshirja e tipareve të aplikacionit (shpjegim i shkurtër)
Ky projekt përmban veçori si:
- Sistemi i pikëve dhe achievements (për të inkurajuar karikime më miqësore me mjedisin)
- Leaderboard (renditje përdoruesish sipas pikëve ekologjike)

Për detaje të plota rreth mënyrës se si këto veçori ruhen dhe si mund t'i testoni, shikoni `lib/main.dart` ku gjenden modelet dhe logjika kryesore.

## Kontakti
Nëse ke pyetje për ikonat ose procesin e ndërtimit, lërje mesazh tek zhvilluesi i projektit.

— EVCharge Team
