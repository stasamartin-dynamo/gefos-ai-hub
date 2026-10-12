# GEFOS AI Hub

Sdílená nástěnka AI use case pro GEFOS a.s. Kopie MAUTING Use Case Hub (stejné funkce) + záložka **V šuplíku**.

- Jeden soubor `index.html`, bez buildu. Data ve Firebase Firestore (kolekce `gefos-ai-hub`).
- PIN: `1234` (konstanta `PIN` v `index.html`).
- Barvy: proměnné `--primary`, `--brand`, `--accent` na začátku `<style>`.
- Logo: soubor `logo.png` vedle `index.html`. Když chybí, zobrazí se textové „GEFOS“.

## V šuplíku
Use case vyhodnocené jako dobré, ale odložené. Přesun: stav „V šuplíku“ (na kartě nebo ve formuláři).
U každého: proč čeká, co musí nastat, kdy se vrátit (měsíc), přínos. Po termínu se karta zvýrazní
a na nástěnce se objeví upozornění. Tlačítka: Vytáhnout (zpět do Vyhodnocujeme), Posunout, Upravit.

## 1) Logo z gefos.cz
```bash
cd gefos-ai-hub
# najdi adresu loga na webu (vypíše kandidáty)
curl -s https://www.gefos.cz | grep -oiE '(src|href)="[^"]*logo[^"]*"' | head
# stáhni ho (doplň adresu z výpisu; když je to SVG, ulož jako logo.svg a v index.html přepiš logo.png -> logo.svg)
curl -L -o logo.png "https://www.gefos.cz/CESTA/K/LOGU.png"
```

## 2) GitHub
```bash
cd gefos-ai-hub
gh repo create gefos-ai-hub --public --source=. --remote=origin --push
# bez gh: založ prázdné repo na github.com/new a pak
# git remote add origin https://github.com/<ucet>/gefos-ai-hub.git && git push -u origin main
```
## 3) Vercel
Nejjednodušší je napojit repo (každý push se pak nasadí sám):
vercel.com/new → Import `gefos-ai-hub` → Framework: **Other** → Deploy.

Nebo z terminálu:
```bash
npm i -g vercel
cd gefos-ai-hub
vercel --prod     # první spuštění se zeptá na účet a název projektu: gefos-ai-hub
```

## 4) Vlastní Firebase projekt pro GEFOS (doporučeno)
Teď appka běží na Firebase projektu MAUTING, jen v oddělené kolekci. Pro klienta je čistší vlastní projekt:
```bash
npm i -g firebase-tools
firebase login
firebase projects:create gefos-ai-hub --display-name "GEFOS AI Hub"
firebase apps:create web gefos-ai-hub-web --project gefos-ai-hub
firebase apps:sdkconfig web --project gefos-ai-hub   # vypíše config -> vlož do index.html (firebaseConfig)
```
V konzoli Firebase (console.firebase.google.com → gefos-ai-hub):
1. Build → Firestore Database → Create database (region eur3 / europe-west).
2. Build → Authentication → Get started → Sign-in method → **Anonymous** → Enable.
3. Firestore → Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /gefos-ai-hub/{doc} {
      allow read, write: if request.auth != null;
    }
  }
}
```
Pak `git commit -am "Firebase GEFOS" && git push`.

## Poznámky
- PIN je jen „zámek na dveřích“, ne zabezpečení – nedávat sem citlivá data zákazníků ani ceny.
- Ukázková data (5 use case, 1 kontakt) se vloží jen při prvním spuštění; smazat jde přímo v appce.
