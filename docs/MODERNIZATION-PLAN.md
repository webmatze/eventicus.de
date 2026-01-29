# Eventicus.de Modernisierungsplan

**Erstellt:** 2026-01-29
**Status:** Entwurf
**Ziel:** Rails 8 + Hotwire + Tailwind

---

## 📊 Bestandsaufnahme

### Aktueller Stand
| Aspekt | Version/Status |
|--------|----------------|
| Rails | 2.3.17 (2013) |
| Ruby | benötigt 1.9.x |
| Views | 64 `.rhtml` Dateien |
| CSS | Custom CSS (~25KB) |
| JS | Prototype.js (Rails 2 Standard) |
| DB | SQLite mit Bestandsdaten |
| Auth | Custom (SHA1 Passwort-Hashing) |

### Datenmodell
```
User (Login, Avatar, Timezone)
  ├── has_many :events
  ├── has_many :attendees → attended_events
  ├── has_one :avatar
  └── has_many :blogs

Event (Title, Description, Dates, Popularity)
  ├── belongs_to :user
  ├── belongs_to :location
  ├── belongs_to :category
  ├── has_many :attendees → attending_users
  └── acts_as_commentable

Location (Name, Address, Geocoding)
  ├── belongs_to :metro
  └── has_many :events

Metro (City/Region)
  └── has_many :locations

Category
  └── has_many :events

Blog
  ├── belongs_to :user
  └── acts_as_commentable
```

### Features
- ✅ Event-Listing mit Filter (Ort, Kategorie, Zeitraum)
- ✅ Event-Teilnahme (Attendees)
- ✅ Kommentare (Events + Blog)
- ✅ User-Profile mit Avatars
- ✅ Blog-System
- ✅ RSS-Feeds
- ✅ iCal-Export
- ✅ Friendly URLs (Slugs)
- ✅ Geocoding für Locations
- ⚠️ Flickr-Integration (veraltet)
- ⚠️ Facebook-Connect (veraltet)

---

## 🎯 Strategie: Neuaufbau statt stufenweises Upgrade

### Warum Neuaufbau?

**Gegen stufenweises Upgrade (2.3 → 3 → 4 → 5 → 6 → 7 → 8):**
- 6+ Major-Versionen = hunderte Breaking Changes
- Viele Gems existieren nicht mehr oder sind inkompatibel
- Prototype.js → jQuery → Stimulus/Turbo Migrationspfad ist komplex
- `.rhtml` → `.erb` → moderne View-Patterns
- Zeitaufwand: geschätzt 40-60 Stunden für alle Upgrades

**Für Neuaufbau:**
- Saubere Rails 8 Architektur von Anfang an
- Moderne Defaults (Hotwire, Solid Queue, etc.)
- Nur relevante Features übernehmen
- Datenmigration ist überschaubar (8 Tabellen)
- Zeitaufwand: geschätzt 20-30 Stunden

---

## 📋 Phasenplan

### Phase 0: Vorbereitung (2-3 Stunden)
- [ ] SQLite-Datenbank sichern
- [ ] SQL-Dump der Bestandsdaten erstellen
- [ ] Screenshots der alten UI für Referenz
- [ ] Feature-Liste priorisieren (MVP vs. Nice-to-have)

### Phase 1: Neues Rails 8 Projekt (2-3 Stunden)
- [ ] `rails new eventicus --database=sqlite3 --css=tailwind --skip-jbuilder`
- [ ] Git-Repository initialisieren
- [ ] Basis-Gems hinzufügen:
  - `devise` (statt custom Auth)
  - `friendly_id`
  - `icalendar`
  - `geocoder` (statt geokit)
  - `active_storage` (statt attachment_fu)
  - `action_text` (für Rich Text)

### Phase 2: Datenmodell (4-5 Stunden)
- [ ] Models erstellen:
  ```
  User (via Devise)
  Event
  Location
  Metro (→ evtl. umbenennen zu "City")
  Category
  Post (statt Blog)
  Comment (polymorphic)
  Attendance (statt Attendee)
  ```
- [ ] Migrationen schreiben
- [ ] Validierungen + Associations
- [ ] Friendly IDs konfigurieren

### Phase 3: Datenmigration (3-4 Stunden)
- [ ] Rake-Task für Import schreiben
- [ ] User-Passwörter: Reset erzwingen (altes SHA1 ist unsicher)
- [ ] Events, Locations, Metros importieren
- [ ] Kategorien importieren
- [ ] Blog-Posts + Kommentare importieren
- [ ] Attendees/Attendances importieren
- [ ] Avatare → Active Storage migrieren

### Phase 4: Core Features (8-10 Stunden)
- [ ] **Authentication** (Devise)
  - Login/Logout/Signup
  - Passwort vergessen
  - Profil bearbeiten
  - Avatar-Upload (Active Storage)

- [ ] **Events**
  - Index mit Filtern (Turbo Frames)
  - Show-Seite
  - Create/Edit (nur eingeloggte User)
  - Teilnahme (Attend/Unattend) via Turbo
  - Kommentare

- [ ] **Locations & Metros**
  - Location-Verwaltung
  - Geocoding via Geocoder gem
  - Metro/City-Auswahl

- [ ] **Blog/Posts**
  - Liste + Show
  - Create/Edit (Admin only?)
  - Kommentare

### Phase 5: Feeds & Export (2-3 Stunden)
- [ ] RSS-Feeds (xml.builder)
- [ ] iCal-Export
- [ ] Sitemap

### Phase 6: UI/UX (4-6 Stunden)
- [ ] Tailwind-basiertes Design
- [ ] Responsive Layout
- [ ] Dark Mode (optional)
- [ ] Hotwire-Interaktionen:
  - Live-Filter für Events
  - Inline-Kommentare
  - Flash-Messages

### Phase 7: Nice-to-haves (optional)
- [ ] Suche (pg_search oder Meilisearch)
- [ ] Event-Kategorien mit Icons
- [ ] Map-Integration (Leaflet/Mapbox)
- [ ] Social Sharing
- [ ] Admin-Bereich (rails_admin oder custom)
- [ ] API (für mobile App später)

### Phase 8: Deployment (2-3 Stunden)
- [ ] Kamal-Setup (wie BandStager)
- [ ] Production-Datenbank
- [ ] Domain-Setup (eventicus.de)
- [ ] SSL via Let's Encrypt

---

## 🔧 Technische Details

### Gem-Mapping (Alt → Neu)

| Rails 2.3 | Rails 8 |
|-----------|---------|
| Custom Auth (SHA1) | Devise |
| attachment_fu | Active Storage |
| acts_as_commentable | Custom polymorphic oder `commentable` gem |
| friendly_id 2.x | friendly_id 5.x |
| geokit | geocoder |
| RedCloth (Textile) | Action Text (Trix) oder Markdown |
| will_paginate (implied) | Pagy |
| Prototype.js | Stimulus + Turbo |

### Passwort-Migration

Das alte System nutzt unsicheres SHA1:
```ruby
Digest::SHA1.hexdigest("change-me--#{pass}--")
```

**Lösung:** 
1. Alle User importieren mit `password_digest = nil`
2. Beim ersten Login nach Migration: "Bitte neues Passwort setzen"
3. Oder: Massen-Email mit Reset-Links

### View-Migration

`.rhtml` Views können **nicht** 1:1 übernommen werden wegen:
- Prototype.js Helpers (`link_to_remote`, `form_remote_for`)
- Alte ERB-Syntax (`<% form_for %>` vs `<%= form_with %>`)
- Veraltete Helper

**Empfehlung:** Views komplett neu schreiben mit Tailwind-Komponenten.

---

## ⏱️ Zeitschätzung

| Phase | Stunden | Kumulativ |
|-------|---------|-----------|
| Phase 0: Vorbereitung | 2-3 | 2-3 |
| Phase 1: Neues Projekt | 2-3 | 4-6 |
| Phase 2: Datenmodell | 4-5 | 8-11 |
| Phase 3: Datenmigration | 3-4 | 11-15 |
| Phase 4: Core Features | 8-10 | 19-25 |
| Phase 5: Feeds & Export | 2-3 | 21-28 |
| Phase 6: UI/UX | 4-6 | 25-34 |
| Phase 8: Deployment | 2-3 | 27-37 |

**Geschätzt: 25-40 Stunden** (ohne Nice-to-haves)

---

## 🚀 Quick Start

Wenn du loslegen willst:

```bash
# 1. Neues Projekt erstellen
cd /home/webmatze/Workspace/github/webmatze
rails new eventicus-modern --database=sqlite3 --css=tailwind --skip-jbuilder

# 2. In das Verzeichnis wechseln
cd eventicus-modern

# 3. Basis-Gems hinzufügen (Gemfile editieren)
# devise, friendly_id, geocoder, icalendar, pagy

# 4. Alte Datenbank kopieren für Import
cp ../eventicus.de/db/development.sqlite3 db/legacy.sqlite3
```

---

## 💡 Offene Fragen

1. **Soll die Domain eventicus.de wiederverwendet werden?**
2. **Alle alten User-Accounts migrieren oder Neustart?**
3. **Blog-Feature behalten oder weglassen?**
4. **Welche Städte/Metros sind noch relevant?**
5. **Soll es mehrsprachig sein (DE/EN)?**

---

## Nächste Schritte

1. ✅ Plan reviewen
2. ⬜ Entscheidungen zu offenen Fragen treffen
3. ⬜ Phase 0 starten (Backup + Screenshots)
4. ⬜ Neues Rails 8 Projekt aufsetzen

---

*Erstellt von Kit 🦊 für Matze*
