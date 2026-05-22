# YemekSiparisDB & Askıda Yemek Platformu Veritabanı Yönetim Sistemi

Bu depo, modern bir yemek siparişi yönetim sistemine entegre edilmiş, toplumsal yardımlaşma odağı yüksek "Askıda Yemek" modelini destekleyen ilişkisel bir veritabanı tasarımı içermektedir. Proje, T-SQL (Microsoft SQL Server) kullanılarak geliştirilmiş olup; gelişmiş veritabanı nesneleri, tetikleyiciler (triggers), saklı yordamlar (stored procedures), indeksleme stratejileri ve veri tutarlılığı senaryolarını barındırmaktadır.


## Proje Öne Çıkanları (Key Features)

* **Çift Yönlü Sipariş Mimarisi:** Standart sipariş süreçlerinin yanı sıra ihtiyaç sahiplerinin yararlanabileceği tamamen entegre "Askıda Sipariş" iş mantığı.
* **Akıllı Havuz Yönetimi (FIFO):** Askıya bırakılan ürünlerin veya nakit bakiyelerin, ilk gelen ilk alır (First-In, First-Out) prensibiyle adil dağıtımı için cursor tabanlı algoritma.
* **İhtiyaç Sahibi Doğrulama Süreci:** Suistimalleri önlemek amacıyla resmi belge referans numaraları ile entegre müşteri doğrulama iş akışı (`sp_MusteriIhtiyacDurumuDogrula`).
* **Otomatik Finansal ve Operasyonel Tetikleyiciler:** Manuel müdahaleyi sıfırlayan, teslim edilen siparişlerde restoran cirolarını anlık güncelleyen ve askı havuz stokunu kontrol eden trigger yapıları.
* **Gelişmiş Performans İndeksleri:** Yoğun transaction altında sorgu performansını optimize eden Clustered ve Non-Clustered indeks stratejileri.

---

## Veritabanı Şeması ve İlişkileri

Sistem, referans bütünlüğü (Referential Integrity) ve veri tutarlılığı kurallarına tam uyumlu 10 ana tablodan oluşmaktadır.


### Tablo Yapıları ve Sorumlulukları

1.  **Musteriler:** Platformu kullanan tüm kullanıcıları (hayırseverler, standart tüketiciler ve onaylanmış ihtiyaç sahipleri) tutar. Şifre güvenliği için `SifreHash` alanına sahiptir. `Email` ve `Telefon` alanları benzersizdir (UNIQUE).
2.  **Restoranlar:** Sisteme kayıtlı işletmelerin iletişim, adres, puan, vergi numarası ve kümülatif ciro (`ToplamCiro`) bilgilerini yönetir. `Telefon` alanı benzersizdir (UNIQUE).
3.  **Kuryeler:** Teslimat operasyonlarını yürüten kuryelerin aktiflik ve plaka bilgilerini içerir. `Telefon` alanı benzersizdir (UNIQUE).
4.  **Urunler:** Restoranlara bağlı menü elemanlarını, fiyat ve kategori kırılımlarını yönetir.
5.  **Siparisler:** Siparişlerin operasyonel durumunu (`Alindi`, `Hazirlaniyor`, `Yolda`, `TeslimEdildi`, `IptalEdildi`) ve askı durumunu takip eden ana transaction tablosudur.
6.  **SiparisDetaylari:** Sipariş içerisindeki ürün porsiyonlarını ve birim fiyatları tutar. `SatirToplam` alanı hesaplanmış kolon (Computed Column: `Adet * BirimFiyat`) olarak tasarlanmıştır.
7.  **AskidaBagislar:** Hayırseverlerin sisteme bıraktığı `BAKIYE` (Nakit TL) veya `URUN` (Porsiyon bazlı) bağışların havuzdaki kalan miktarlarını yönetir. Anonymous (gizli) bağış desteği sunar.
8.  **AskidaTuketimler:** Hangi askıda siparişin, hangi bağışçının oluşturduğu havuzdan finanse edildiğini şeffaf bir şekilde eşleştiren audit tablosudur.
9.  **MusteriDogrulamalari:** İhtiyaç sahiplerinin sunduğu belgelerin onay/red süreçlerini (`BEKLEMEDE`, `ONAYLANDI`, `REDDEDILDI`) ve geçerlilik tarihlerini loglar.
10.  **SistemLoglari:** Musteriler tablosuna yeni bir kayıt eklendiğinde tetiklenen trigger yardımıyla sisteme düşen üyelik işlemlerini denetim amacıyla kaydeden log tablosudur

---

##  İş Mantığı ve Gelişmiş T-SQL Bileşenleri

### 1. Otomatik Ciro Yönetimi (`trg_SiparisCiroGuncelle`)
Bir siparişin durumu `TeslimEdildi` olarak güncellendiğinde, ilgili restoranın `ToplamCiro` alanı anlık olarak sipariş tutarı kadar artırılır. Eğer sipariş teslim edildi durumundan başka bir duruma çekilirse (veya iptal edilirse) ciro otomatik olarak düşürülür.

### 2. Akıllı Askı Havuz Tetikleyicisi (`trg_AskidanDusmeVeStokYonetimi`)
Bir ihtiyaç sahibi askıda sipariş verdiğinde bu trigger devreye girer:
* Havuzda ilgili üründen yeterli stok olup olmadığını kontrol eder, yoksa işlemi `ROLLBACK` ile iptal ederek hata fırlatır (`RAISERROR`).
* Yeterli ürün varsa, veritabanı seviyesinde bir **Cursor (İmleç)** mimarisi (`BagisCursor`) kullanarak en eski tarihli bağıştan başlayarak porsiyonları düşer, bağış durumunu günceller ve `AskidaTuketimler` tablosuna audit kaydı işler.


---

## Analitik Görünümler (Views)

* `vw_AktifRestoranMenuleri`: Yalnızca aktif olan restoranların aktif ürünlerini listeleyen tüketici dostu görünüm.
* `vw_AskidaYemekHavuzDurumu`: Anlık olarak askı havuzunda ne kadar nakit bakiye ve kaç porsiyon yemek kaldığını, ayrıca sistemden yararlanan doğrulanmış ihtiyaç sahibi sayısını gösteren yönetimsel panel görünümü.
* `vw_MusteriSiparisGecmisi`: Müşteri, kurye, restoran ve sipariş türünü bir araya getiren detaylı raporlama görünümü.

