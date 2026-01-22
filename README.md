# EV Charge App — Udhëzues në shqip

Aplikacion Flutter për gjetjen e stacioneve të karikimit, kontrollin e përputhshmërisë me makinën dhe menaxhimin e sesioneve të karikimit.

## Çfarë bën aplikacioni

- Kërkim i saktë sipas kodit të stacionit (EV0XX) dhe listim sipas emrit/adresës.
- Navigim: butoni Back nga faqja e Stacionit të kthehet te faqja kryesore (Home).
- Portofoli: bllokon nisjen e karikimit nëse balanca është < 500 ALL dhe shfaq mesazh shpjegues.
- Buxhet i sesionit: karikimi ndalet automatikisht kur buxheti mbaron; ruhet arsyeja dhe shfaqet mesazh.
- Harta: ngjyra e markuesve sipas statusit dhe përputhshmërisë me makinën:
	- E kuqe: jo i disponueshëm.
	- E gjelbër: i disponueshëm dhe i përshtatshëm (direkt ose përmes adapterit).
	- E blu: i disponueshëm, por i papërshtatshëm për makinën.
- Profil i përdoruesit: "Preferred Connector" (CCS2, CCS1, GBT, Type 2, Type 1, Tesla/NACS, CHAdeMO) dhe "Adapter" me zgjedhje nga kombinime të shumta.
- Përputhshmëria llogaritet duke marrë parasysh connector-in e preferuar dhe adapterin e zgjedhur (p.sh., CCS2↔GBT, Tesla↔CCS2, Tesla↔CCS1, CCS1↔CHAdeMO, Type1↔Type2, CHAdeMO↔CCS2).
- Detaje të sesionit: kosto, kWh të konsumuar, CO₂ i kursyer, ruajtje në histori dhe mesazhe të qarta.

## Si funksionon përputhshmëria në hartë

- Kontrollohet fillimisht përputhshmëria direkte me "Preferred Connector".
- Nëse nuk ka përputhje direkte, përdoret adapteri i zgjedhur për të gjetur lidhje alternative.
- Markuesi bëhet i gjelbër nëse stacioni është i përdorshëm (direkt ose përmes adapterit), përndryshe blu.

## Përdorimi

1. Hap aplikacionin dhe plotëso profilin: targë, "Preferred Connector" dhe (opsional) "Adapter".
2. Përdor kërkimin me kodin EV0XX ose filtro sipas connector-it.
3. Zgjidh stacionin, kontrollo çmimin/kWh, përputhshmërinë, dhe nis karikimin.
4. Vendos buxhet për sesionin; karikimi ndalet automatikisht kur buxheti mbaron.

## Legjenda e ngjyrave në hartë

- E kuqe: stacion i padisponueshëm.
- E gjelbër: stacion i disponueshëm dhe i përshtatshëm për makinën tënde.
- E blu: stacion i disponueshëm, por jo i përshtatshëm (pa adapter të duhur).

## Kufizime të karikimit

- Balanca minimale e portofolit: 500 ALL për të nisur një sesion.
- Karikimi ndalet automatikisht kur buxheti i vendosur shteron; shfaqet arsyeja dhe sesioni ruhet në histori.

## Instalimi dhe nisja

```bash
flutter pub get
flutter run
```

Për iOS: nëse ka problem me nënshkrimin (CodeSign), hap `ios/Runner.xcworkspace` në Xcode, aktivizo "Automatically manage signing" te target-i Runner dhe zgjidh team-in.

## Teknologjitë

- Flutter/Dart
- flutter_map, geolocator, latlong2
- shared_preferences për ruajtje lokale

## Troubleshooting

- Analyzer: u konfiguruan disa paralajmërime të deprecimeve dhe stileve që të mos bllokojnë `flutter analyze`. Migrimi i plotë do të kryhet gradualisht.
- Nëse shihni ekran të kuq në profil, sigurohu që dropdown-et të kenë vlera të vlefshme (p.sh., adapteri pa vlerë ruhet si string bosh, jo `null`).

## Kontributet dhe ide të ardhshme

- Migrimi nga `withOpacity` në `withValues(alpha: ...)` në UI.
- Zëvendësimi i `WillPopScope` me `PopScope` për back predictiv.
- Shtim testesh unitare për llogaritje kostoje dhe përputhshmërie.
# EVCharge — Përmbledhje dhe Udhëzime

Ky projekt është një aplikacion demonstrues për menaxhimin e karikimit të automjeteve elektrike (EV). Më poshtë po jap një përmbledhje të detajuar të asaj që kam ndërtuar në skedarin kryesor `lib/main.dart`. Dokumenti përfshin gjithashtu udhëzime të shkurtra për të drejtuar aplikacionin.

## Përmbledhje e `lib/main.dart`

Unë kam zhvilluar logjikën kryesore dhe UI-në e aplikacionit në `lib/main.dart`. Këtu përmend në mënyrë të përmbledhur çfarë kam bërë:

- Kam krijuar modelin e përdoruesit (`UserProfile`) dhe kam vendosur ruajtjen lokale të të dhënave me `SharedPreferences` për të ruajtur regjistrimet, balansin e wallet-it dhe historinë e karikimeve.
- Kam implementuar funksionin e regjistrimit dhe ruajtjes së profileve të përdoruesve, si dhe karikimin e saldo-it (top-up) përmes një dialogu me fushat e kartës (numri i kartës, data e skadencës, CVV, emri i kartës).
- Kam shtuar listën e stacioneve të karikimit (tani 10 stacione në qytete të ndryshme) dhe kam vendosur çmime të ndryshme për kWh (p.sh. 30 ALL, 40 ALL, 50 ALL). Çmimi tregohet drejtpërdrejt në kartelën e çdo stacioni duke marrë vlerën nga connector-i i parë.
- Kam krijuar rrjedhën e një sesioni karikimi: kur përdoruesi starton karikimin, krijohet një `ChargingSession` që përmban connector-in, stacionin, përqindjen e baterisë (tani fillon në një vlerë rastësore midis 20% dhe 60% për realizëm), fuqinë aktuale dhe kWh të konsumuar gjatë sesionit.
- Gjatë dhe pas karikimit: llogaritet kostoja totale, ruhet history në `userChargingHistory`, përditësohet wallet-i i përdoruesit, dhe shfaqet një dialog i bukur "Charging Complete" me përmbledhje, CO₂ të kursyer dhe efekt konfeti.
- Kam shtuar një sistem gamifikimi: Eco Points (pikë ekologjike), tiers (Bronze, Silver, Gold, Platinum) dhe një grup achievements (p.sh. First Charge, Eco Warrior, Frequent Charger, City Explorer, etj.). Pas çdo karikimi llogariten pikët dhe achievements unlock-ohen automatikisht sipas kushteve.
- Kam implementuar një leaderboard që rendit përdoruesit sipas Eco Points dhe tregon tier-in dhe CO₂ të kursyer të secilit.
- Në faqen e profilit kam aktivizuar dialogët Settings, About dhe Add Vehicle; karika e shtimit të makinave është e implementuar në UI (persistenca e plotë e shumë makinave mund të përmirësohet më tej).
- Kam bërë përmirësime në UI/UX (kartela të dizajnuara, ngjyra, ikonografi) dhe kam vendosur emrin e aplikacionit në "EVCharge" si dhe kam shtuar ikonat në `assets/icon`.

Shënime të tjera të rëndësishme:
- Ruajtja e të dhënave dhe historisë bëhet me `SharedPreferences` në format JSON (serializim me `toJson`/`fromJson`).
- Nëse hasni probleme gjatë ekzekutimit në iOS (p.sh. gabim CodeSign), hapni `ios/Runner.xcworkspace` në Xcode, zgjidhni target-in `Runner` > **Signing & Capabilities**, aktivizoni "Automatically manage signing" dhe zgjidhni team-in tuaj Apple.

## Si ta nisë aplikacionin lokal

1. Sigurohu që ke Flutter të instaluar dhe varësitë:

```bash
flutter pub get
```

2. Për Android / simulator të përgjithshëm:

```bash
flutter run
```

3. Për iOS, nëse shfaqet gabim CodeSign, shiko shënimin e mësipërm dhe rregullo nënshkrimin në Xcode, pastaj rindërto.

## Ku të kërkoni funksione të veçanta
- Logjika e përdoruesit dhe ruajtjes: `UserProfile`, `saveUserProfiles()` dhe `loadUserProfiles()` në `lib/main.dart`.
- Stacionet dhe connectorët: lista `stations` në `lib/main.dart` (përfshin emra, adresa, city, distance, connectors, pricePerKwh).
- Sesioni i karikimit: `ChargingSession` class dhe faqja `ChargingPage` (UI dhe metodat `_stopCharging`, etj.).
- Gamifikimi: modelet `Achievement`, funksionet për t'u unlock-uar dhe leaderboard.




