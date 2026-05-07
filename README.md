# Telco Project (i2i Systems Internship Task)

Bu repo; Oracle (Docker) üzerinde telecom verisini ayağa kaldırıp, CSV import ettikten sonra istenen SQL sorgularını çalıştırarak çıktıları üretmek için hazırlanmıştır.

## Project Structure

- `docker-compose.yml`: Oracle Free (Oracle XE uyumlu) konteyneri
- `scripts/TABLE_CREATION_SCRIPTS.sql`: tablo + index + constraint scriptleri
- `scripts/SOLUTIONS.sql`: tüm soru çözümleri (her soru için 3+ cümle açıklama içerir)
- `CUSTOMERS.csv`, `TARIFFS.csv`, `MONTHLY_STATS.csv`: verilen dataset
- `outputs/output-*.csv`: her sorunun sorgu çıktısı (export)

## Run Oracle with Docker

Oracle’ı başlatın:

```bash
docker compose up -d
```

Container adı: `i2i-telco-db`  
Port: `1521`

Not: İlk açılışta Oracle’ın ayağa kalkması birkaç dakika sürebilir.

## Connection Info (DBeaver)

DBeaver’da **Oracle** driver ile aşağıdaki şekilde bağlanabilirsiniz:

- **Host**: `localhost`
- **Port**: `1521`
- **Database / Service name**: `FREEPDB1` (bazı kurulumlarda `FREE` olarak da görünebilir)
- **Username**: `SYSTEM`
- **Password**: `i2i`

Bu projede tablolar `FREEPDB1` üzerinde ve `SYSTEM` schema altında oluşturulacak şekilde tasarlanmıştır.

## Table Creation (Auto Seed)

`docker-compose.yml` içindeki volume mount sayesinde `./scripts` dizini konteynerde `/container-entrypoint-initdb.d` altına bağlanır.
Bu nedenle Oracle ilk initialize olurken `scripts/TABLE_CREATION_SCRIPTS.sql` otomatik çalışır ve tablolar oluşur.

Eğer otomatik çalışmadıysa, DBeaver (veya SQL*Plus) üzerinden `scripts/TABLE_CREATION_SCRIPTS.sql` dosyasını manuel çalıştırabilirsiniz.

## Bonus: Docker Compose & Reproducibility

Bu repo bonus maddelerinin şu kısımlarını karşılar:

- **Docker Compose ile tek komutla DB**: `docker-compose.yml` ile Oracle konteyneri ayağa kalkar.
- **Automated Database Seeding (table creation)**: `./scripts` dizini `/container-entrypoint-initdb.d` altına mount edildiği için konteyner ilk initialize olurken SQL scriptleri otomatik çalışabilir.

Önemli notlar:

- Bu “init script” mekanizması genelde **sadece ilk initialize** sırasında çalışır. Container’ı stop/start yapmak aynı init adımını tekrar tetiklemeyebilir.
- CSV import işlemi bu repoda **manuel** (DBeaver ile) yapılacak şekilde bırakıldı; istenirse ayrıca otomatik seed kapsamına alınabilir.

### (Önerilen) Reproduce Adımları

1. Oracle’ı başlat:

```bash
docker compose up -d
```

2. Oracle’ın ayağa kalkmasını bekle (ilk açılış birkaç dakika sürebilir).
3. DBeaver’dan bağlan:
   - Host `localhost`, Port `1521`, Service `FREEPDB1`, User `SYSTEM`, Password `i2i`
4. Tabloların oluştuğunu kontrol et (ör. `CUSTOMERS`, `TARIFFS`, `MONTHLY_STATS` listelenmeli).
5. CSV import et.
6. `scripts/SOLUTIONS.sql` çalıştır, sonuçları `outputs/` altına export et.

### Screenshots

Bu repoda ekran görüntüleri `images/` altında tutulmuştur.

**1) Docker Compose ile Oracle’ı ayağa kaldırma:**

![docker-compose up -d](/images/01-docker-compose-up.png)

**2) DBeaver bağlantı testi (Oracle):**

![dbeaver connection test](/images/02-dbeaver-connection-test.png)

**3) Tabloların oluştuğunu doğrulama:**

![tables created](/images/03-tables-created.png)

**4) `SOLUTIONS.sql` çalıştırma ve sonuç görüntüleme:**

![run solutions](/images/04-run-solutions.png)

**5) CSV import (örnek: TARIFFS.csv):**

![csv import confirm](/images/05-csv-import.png)

**6) Query sonucu export (CSV):**

![export to csv](/images/06-export-csv.png)

## CSV Import (DBeaver)

CSV import için DBeaver’da:

- `CUSTOMERS.csv` → `CUSTOMERS`
- `TARIFFS.csv` → `TARIFFS`
- `MONTHLY_STATS.csv` → `MONTHLY_STATS`

İpucu: DBeaver “Import Data” akışında **Header** seçeneğinin açık olduğundan ve tarih alanlarının doğru parse edildiğinden emin olun.

## Run Queries (Solutions)

Tüm çözümler `scripts/SOLUTIONS.sql` içindedir. DBeaver’da dosyayı açıp çalıştırarak her soru için sonuç setlerini alabilirsiniz.

## Outputs Mapping

Bu repodaki export dosyaları aşağıdaki sorulara karşılık gelir:

- `outputs/output-1.1.csv` → 1.1
- `outputs/output-1.2.csv` → 1.2
- `outputs/output-2.1.csv` → 2.1
- `outputs/output-3.1.csv` → 3.1
- `outputs/output-3.2.csv` → 3.2
- `outputs/output-4.1.csv` → 4.1
- `outputs/output-4.2.csv` → 4.2
- `outputs/output-5.1.csv` → 5.1
- `outputs/output-5.2.csv` → 5.2
- `outputs/output-6.1.csv` → 6.1
- `outputs/output-6.2.csv` → 6.2

## Notes / Submission Checklist

- `scripts/TABLE_CREATION_SCRIPTS.sql` içinde tablo tanımları + indexler mevcut.
- `scripts/SOLUTIONS.sql` içinde tüm soruların sorguları ve her biri için 3+ cümle açıklama mevcut.
- `outputs/` altında her sorunun sorgu çıktısı CSV olarak export edildi.

## Repo Hygiene

macOS tarafından oluşturulan `.DS_Store` dosyaları proje çalışması için gerekli değil. Bu repoda `.gitignore` ile dışarıda bırakıldı; istersen tamamen silebilirsin.
