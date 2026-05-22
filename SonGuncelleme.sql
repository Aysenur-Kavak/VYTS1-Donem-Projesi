CREATE DATABASE YemekSiparisDB;
GO
USE YemekSiparisDB;
GO
CREATE TABLE Musteriler (
    MusteriID INT IDENTITY(1,1) NOT NULL,
    Ad VARCHAR(50) NOT NULL,
    Soyad VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Telefon VARCHAR(15) NOT NULL,
    SifreHash VARCHAR(256) NOT NULL,
    IsVerifiedNeedOwner BIT NOT NULL CONSTRAINT DF_Musteriler_IsVerifiedNeedOwner DEFAULT (0), 
    KayitTarihi DATETIME NOT NULL CONSTRAINT DF_Musteriler_KayitTarihi DEFAULT (GETDATE()),    
    IsActive BIT NOT NULL CONSTRAINT DF_Musteriler_IsActive DEFAULT (1),                    
    CONSTRAINT PK_Musteriler PRIMARY KEY CLUSTERED (MusteriID),
    CONSTRAINT UQ_Musteriler_Email UNIQUE (Email)
);
GO

CREATE TABLE Restoranlar (
    RestoranID INT IDENTITY(1,1) NOT NULL,
    RestoranAdi VARCHAR(100) NOT NULL,
    Telefon VARCHAR(15) NOT NULL,
    Adres VARCHAR(250) NOT NULL,
    VergiNo VARCHAR(11) NULL, 
    IsActive BIT NOT NULL CONSTRAINT DF_Restoranlar_IsActive DEFAULT (1), 
    KayitTarihi DATETIME NOT NULL CONSTRAINT DF_Restoranlar_KayitTarihi DEFAULT (GETDATE()),

    CONSTRAINT PK_Restoranlar PRIMARY KEY CLUSTERED (RestoranID)
);

ALTER TABLE Restoranlar 
ADD RestoranPuani DECIMAL(3,2) NULL CONSTRAINT DF_Restoranlar_Puan DEFAULT (5.00);
GO


ALTER TABLE Restoranlar 
ADD CONSTRAINT CK_Restoranlar_RestoranPuani CHECK (RestoranPuani BETWEEN 1.00 AND 5.00);
GO
GO

CREATE TABLE Kuryeler (
    KuryeID INT IDENTITY(1,1) NOT NULL,
    Ad VARCHAR(50) NOT NULL,
    Soyad VARCHAR(50) NOT NULL,
    Telefon VARCHAR(15) NOT NULL,
    PlakaNo VARCHAR(20) NOT NULL, 
    AktifMi BIT NOT NULL CONSTRAINT DF_Kuryer_AktifMi DEFAULT (1), 
    IsActive BIT NOT NULL CONSTRAINT DF_Kuryer_IsActive DEFAULT (1), 
    KayitTarihi DATETIME NOT NULL CONSTRAINT DF_Kuryer_KayitTarihi DEFAULT (GETDATE()),

    CONSTRAINT PK_Kuryeler PRIMARY KEY CLUSTERED (KuryeID),
    CONSTRAINT UQ_Kuryeler_Telefon UNIQUE (Telefon)
);
GO

CREATE TABLE Urunler (
    UrunID INT IDENTITY(1,1) NOT NULL,
    RestoranID INT NOT NULL, 
    UrunAdi VARCHAR(100) NOT NULL,
    Fiyat DECIMAL(18,2) NOT NULL, 
    Kategori VARCHAR(50) NOT NULL,  
    IsActive BIT NOT NULL CONSTRAINT DF_Urunler_IsActive DEFAULT (1), 
    KayitTarihi DATETIME NOT NULL CONSTRAINT DF_Urunler_KayitTarihi DEFAULT (GETDATE()),

    CONSTRAINT PK_Urunler PRIMARY KEY CLUSTERED (UrunID),

    CONSTRAINT FK_Urunler_Restoranlar FOREIGN KEY (RestoranID) 
        REFERENCES Restoranlar (RestoranID)
);
GO


CREATE TABLE Siparisler (
    SiparisID INT IDENTITY(1,1) NOT NULL,
    MusteriID INT NOT NULL,     
    RestoranID INT NOT NULL,    
    KuryeID INT NULL,           
    SiparisTarihi DATETIME NOT NULL CONSTRAINT DF_Siparisler_SiparisTarihi DEFAULT (GETDATE()),
    ToplamTutar DECIMAL(18,2) NOT NULL,
    SiparisDurumu VARCHAR(20) NOT NULL CONSTRAINT DF_Siparisler_SiparisDurumu DEFAULT ('Alindi'), 
    IsAskidaSiparis BIT NOT NULL CONSTRAINT DF_Siparisler_IsAskidaSiparis DEFAULT (0), 
    IsActive BIT NOT NULL CONSTRAINT DF_Siparisler_IsActive DEFAULT (1), 

    CONSTRAINT PK_Siparisler PRIMARY KEY CLUSTERED (SiparisID),

    
    CONSTRAINT FK_Siparisler_Musteriler FOREIGN KEY (MusteriID) 
        REFERENCES Musteriler (MusteriID),
        
    CONSTRAINT FK_Siparisler_Restoranlar FOREIGN KEY (RestoranID) 
        REFERENCES Restoranlar (RestoranID),
        
    CONSTRAINT FK_Siparisler_Kuryer FOREIGN KEY (KuryeID) 
        REFERENCES Kuryeler (KuryeID)
);


ALTER TABLE Siparisler 
ADD CONSTRAINT CK_Siparisler_ToplamTutar CHECK (ToplamTutar >= 0);
GO
GO


CREATE TABLE SiparisDetaylari (
    SiparisDetayID INT IDENTITY(1,1) NOT NULL,
    SiparisID INT NOT NULL,         
    UrunID INT NOT NULL,            
    Adet INT NOT NULL CONSTRAINT DF_SiparisDetaylari_Adet DEFAULT (1),
    BirimFiyat DECIMAL(18,2) NOT NULL, 
    SatirToplam AS (Adet * BirimFiyat),

    
    CONSTRAINT PK_SiparisDetaylari PRIMARY KEY CLUSTERED (SiparisDetayID),


    CONSTRAINT FK_SiparisDetaylari_Siparisler FOREIGN KEY (SiparisID) 
        REFERENCES Siparisler (SiparisID),
        
    CONSTRAINT FK_SiparisDetaylari_Urunler FOREIGN KEY (UrunID) 
        REFERENCES Urunler (UrunID),

   
    CONSTRAINT CK_SiparisDetaylari_Adet CHECK (Adet > 0) 
);
GO


CREATE TABLE AskidaBagislar (
    BagisID INT IDENTITY(1,1) NOT NULL,
    BagisciMusteriID INT NOT NULL,  
    IsAnonymous BIT NOT NULL CONSTRAINT DF_AskidaBagislar_IsAnonymous DEFAULT (0), 
    BagisTipi VARCHAR(10) NOT NULL, 
    UrunID INT NULL,               
    Miktar DECIMAL(18,2) NOT NULL,  
    KalanMiktar DECIMAL(18,2) NOT NULL, 
    BagisTarihi DATETIME NOT NULL CONSTRAINT DF_AskidaBagislar_BagisTarihi DEFAULT (GETDATE()),
    IsActive BIT NOT NULL CONSTRAINT DF_AskidaBagislar_IsActive DEFAULT (1), 

  
    CONSTRAINT PK_AskidaBagislar PRIMARY KEY CLUSTERED (BagisID),

    
    CONSTRAINT FK_AskidaBagislar_Musteriler FOREIGN KEY (BagisciMusteriID) 
        REFERENCES Musteriler (MusteriID),
        
    CONSTRAINT FK_AskidaBagislar_Urunler FOREIGN KEY (UrunID) 
        REFERENCES Urunler (UrunID),

   
    CONSTRAINT CK_AskidaBagislar_BagisTipi CHECK (BagisTipi IN ('BAKIYE', 'URUN')),
    CONSTRAINT CK_AskidaBagislar_Miktar CHECK (Miktar > 0),
    CONSTRAINT CK_AskidaBagislar_KalanMiktar CHECK (KalanMiktar >= 0)
);
GO


CREATE TABLE AskidaTuketimler (
    TuketimID INT IDENTITY(1,1) NOT NULL,
    SiparisID INT NOT NULL,        
    BagisID INT NOT NULL,           
    TuketilenMiktar DECIMAL(18,2) NOT NULL, 
    TuketimTarihi DATETIME NOT NULL CONSTRAINT DF_AskidaTuketimler_TuketimTarihi DEFAULT (GETDATE()),

   
    CONSTRAINT PK_AskidaTuketimler PRIMARY KEY CLUSTERED (TuketimID),

  
    CONSTRAINT FK_AskidaTuketimler_Siparisler FOREIGN KEY (SiparisID) 
        REFERENCES Siparisler (SiparisID),
        
    CONSTRAINT FK_AskidaTuketimler_AskidaBagislar FOREIGN KEY (BagisID) 
        REFERENCES AskidaBagislar (BagisID),

 
    CONSTRAINT CK_AskidaTuketimler_TuketilenMiktar CHECK (TuketilenMiktar > 0)
);
GO

USE YemekSiparisDB;
GO

ALTER TABLE Musteriler
ADD CONSTRAINT UQ_Musteriler_Telefon UNIQUE (Telefon);
GO


ALTER TABLE Restoranlar
ADD CONSTRAINT UQ_Restoranlar_Telefon UNIQUE (Telefon);
GO


ALTER TABLE Urunler
ADD CONSTRAINT CK_Urunler_Fiyat CHECK (Fiyat > 0);
GO


ALTER TABLE SiparisDetaylari
ADD CONSTRAINT CK_SiparisDetaylari_BirimFiyat CHECK (BirimFiyat > 0);
GO

PRINT 'Restoranlar tablosuna veriler ekleniyor...';

INSERT INTO Restoranlar (RestoranAdi, Telefon, Adres, VergiNo, RestoranPuani, IsActive)
VALUES 
('Gaziantep Hanýmeli Ev Yemekleri', '03422301122', 'Deðirmiçem Mh. Özgürlük Cd. No:45, Þehitkamil/Gaziantep', '1234567890', 4.80, 1),
('Kalyon Kebap & Baklava', '03423214455', 'Fatih Mh. Ali Fuat Cebesoy Blv. No:12, Þehitkamil/Gaziantep', '9876543210', 4.95, 1),
('Þato Pizza & Makarna', '03423607788', 'Üniversite Bulvarý, Yeditepe Mh. No:88, Þahinbey/Gaziantep', '4561237890', 4.20, 1),
('Antep Sofrasý Lahmacun Salonu', '03422203344', 'Karagöz Mh. Sadýk Dai Cd. No:5, Þahinbey/Gaziantep', '7894561230', 4.65, 1),
('Burgers & More', '03423399911', 'Emek Mh. Ýbrahimli Blv. No:102, Þehitkamil/Gaziantep', '3216540987', 4.50, 1);
GO

SELECT * FROM Restoranlar;
GO


PRINT 'Kuryeler tablosuna veriler ekleniyor...';

INSERT INTO Kuryeler (Ad, Soyad, Telefon, PlakaNo, AktifMi, IsActive)
VALUES 
('Ahmet', 'Yýlmaz', '05321112233', '27 ABC 123', 1, 1),
('Mehmet', 'Kaya', '05332223344', '27 DEF 456', 1, 1),
('Can', 'Demir', '05343334455', '27 GHI 789', 1, 1),
('Mustafa', 'Yýldýz', '05354445566', '27 JKL 012', 0, 1),
('Ali', 'Þahin', '05365556677', '27 MNO 345', 1, 1);
GO

SELECT * FROM Kuryeler;
GO


DELETE FROM Urunler;

DBCC CHECKIDENT ('Urunler', RESEED, 0); 
GO

PRINT 'Urunler tablosuna 80 adet güncel veri ekleniyor...';


INSERT INTO Urunler (RestoranID, UrunAdi, Fiyat, Kategori, IsActive) VALUES
(1, 'Süzme Mercimek Çorbasý', 70.00, 'Çorba', 1),
(1, 'Beyran Çorbasý', 160.00, 'Çorba', 1),
(1, 'Yuvalama Çorbasý', 180.00, 'Çorba', 1),
(1, 'Gaziantep Usulü Kuru Dolma', 180.00, 'Ev Yemeði', 1),
(1, 'Ýçli Köfte (Adet)', 60.00, 'Baþlangýç', 1),
(1, 'Ekþili Ufak Köfte', 220.00, 'Ev Yemeði', 1),
(1, 'Ali Nazik Kebabý', 320.00, 'Ana Yemek', 1),
(1, 'Zeytinyaðlý Yaprak Sarmasý', 140.00, 'Ev Yemeði', 1),
(1, 'Fýrýn Sütlaç', 90.00, 'Tatlý', 1),
(1, 'Yayýk Ayraný', 35.00, 'Ýçecek', 1),
(1, 'Þalgam Suyu (Acýlý)', 35.00, 'Ýçecek', 1),
(1, 'Þalgam Suyu (Sade)', 35.00, 'Ýçecek', 1),
(1, 'Meyve Suyu (Karýþýk)', 40.00, 'Ýçecek', 1),
(1, 'Cevizli Ev Baklavasý', 170.00, 'Tatlý', 1),
(1, 'Bamya Yemeði', 190.00, 'Ev Yemeði', 0), 
(1, 'Yoðurtlu Patates Kebabý', 240.00, 'Ana Yemek', 0); 


INSERT INTO Urunler (RestoranID, UrunAdi, Fiyat, Kategori, IsActive) VALUES
(2, 'Közlenmiþ Domates Çorbasý', 75.00, 'Çorba', 1),
(2, 'Kýyma Kebabý (Sade)', 280.00, 'Kebap', 1),
(2, 'Kuþbaþý Kebap (Tike)', 340.00, 'Kebap', 1),
(2, 'Ýskender Kebap', 360.00, 'Ana Yemek', 1),
(2, 'Haþhaþ Kebabý', 310.00, 'Kebap', 1),
(2, 'Gavurdaðý Salatasý', 95.00, 'Salata', 1),
(2, 'Havuç Dilim Baklava (Porsiyon)', 180.00, 'Tatlý', 1),
(2, 'Fýstýklý Þöbiyet', 200.00, 'Tatlý', 1),
(2, 'Kutu Kola', 45.00, 'Ýçecek', 1),
(2, 'Kutu Fanta', 45.00, 'Ýçecek', 1),
(2, 'Soba Altý Lahmacun', 80.00, 'Baþlangýç', 1),
(2, 'Çoban Salatasý', 70.00, 'Salata', 1),
(2, 'Sutlu Nuriye', 150.00, 'Tatlý', 1),
(2, 'Maden Suyu', 25.00, 'Ýçecek', 1),
(2, 'Enginar Kebabý', 350.00, 'Kebap', 0),
(2, 'Kemikli Tikke Kebabý', 380.00, 'Kebap', 0); 


INSERT INTO Urunler (RestoranID, UrunAdi, Fiyat, Kategori, IsActive) VALUES
(3, 'Mantar Çorbasý', 80.00, 'Çorba', 1),
(3, 'Margherita Pizza (Orta)', 210.00, 'Pizza', 1),
(3, 'Alaturka Pizza (Büyük)', 290.00, 'Pizza', 1),
(3, 'Acýlý Tavuklu Pizza (Orta)', 240.00, 'Pizza', 1),
(3, 'Fettuccine Alfredo', 220.00, 'Makarna', 1),
(3, 'Spaghetti Bolognese', 200.00, 'Makarna', 1),
(3, 'Sezar Salatasý', 130.00, 'Salata', 1),
(3, 'Tiramisu', 110.00, 'Tatlý', 1),
(3, 'Fanta', 45.00, 'Ýçecek', 1),
(3, 'Sarýmsaklý Ekmek (3 Adet)', 65.00, 'Baþlangýç', 1),
(3, 'Dört Peynirli Pizza', 260.00, 'Pizza', 1),
(3, 'Penne Arabbiata', 190.00, 'Makarna', 1),
(3, 'Akdeniz Salatasý', 110.00, 'Salata', 1),
(3, 'San Sebastian Cheesecake', 140.00, 'Tatlý', 1),
(3, 'Vejetaryen Pizza (Küçük)', 170.00, 'Pizza', 0), 
(3, 'Linguine Gamberi (Karidesli)', 320.00, 'Makarna', 0); 


INSERT INTO Urunler (RestoranID, UrunAdi, Fiyat, Kategori, IsActive) VALUES
(4, 'Paça Çorbasý', 150.00, 'Çorba', 1),
(4, 'Antep Usulü Lahmacun', 75.00, 'Lahmacun', 1),
(4, 'Cevizli Lahmacun', 85.00, 'Lahmacun', 1),
(4, 'Kuþbaþýlý Pide', 240.00, 'Pide', 1),
(4, 'Kaþarlý Pide', 190.00, 'Pide', 1),
(4, 'Karýþýk Pide', 260.00, 'Pide', 1),
(4, 'Ezme Salata', 60.00, 'Salata', 1),
(4, 'Antep Katmeri (Porsiyon)', 220.00, 'Tatlý', 1),
(4, 'Büyük Ayran', 40.00, 'Ýçecek', 1),
(4, 'Kola Zeor', 45.00, 'Ýçecek', 1),
(4, 'Fýndýk Lahmacun (Adet)', 35.00, 'Baþlangýç', 1),
(4, 'Mevsim Salatasý', 65.00, 'Salata', 1),
(4, 'Sarma Beyti Pide', 270.00, 'Pide', 1),
(4, 'Zencefilli Gazoz', 35.00, 'Ýçecek', 1),
(4, 'Fýstýklý Künefe', 160.00, 'Tatlý', 0), 
(4, 'Kýymalý Pide (Açýk)', 210.00, 'Pide', 0); 


INSERT INTO Urunler (RestoranID, UrunAdi, Fiyat, Kategori, IsActive) VALUES
(5, 'Classic Burger Menü', 240.00, 'Burger', 1),
(5, 'Cheeseburger Menü', 260.00, 'Burger', 1),
(5, 'More Special Burger', 310.00, 'Burger', 1),
(5, 'Barbekü Soslu Tavuk Burger', 210.00, 'Burger', 1),
(5, 'Çýtýr Tavuk Sepeti (10lu)', 150.00, 'Baþlangýç', 1),
(5, 'Büyük Boy Patates Kýzartmasý', 85.00, 'Baþlangýç', 1),
(5, 'Soðan Halkasý (8li)', 60.00, 'Baþlangýç', 1),
(5, 'Magnezyum Çikolatalý Sufle', 100.00, 'Tatlý', 1),
(5, 'Fuse Tea Þeftali', 45.00, 'Ýçecek', 1),
(5, 'Sprite', 45.00, 'Ýçecek', 1),
(5, 'Texas Jalapeno Burger', 280.00, 'Burger', 1),
(5, 'Mantar Soslu Burger', 295.00, 'Burger', 1),
(5, 'Mozzarella Sticks (6lý)', 90.00, 'Baþlangýç', 1),
(5, 'Hot Dog (Sosisli)', 140.00, 'Ana Yemek', 1),
(5, 'Double Smash Burger', 340.00, 'Burger', 0), 
(5, 'Ev Yapýmý Limonata', 55.00, 'Ýçecek', 0); 
GO


SELECT COUNT(*) AS ToplamUrunSayisi FROM Urunler;
SELECT Kategori, COUNT(*) AS KategoriBasinaUrun FROM Urunler GROUP BY Kategori;
GO


DELETE FROM Musteriler;
--
DBCC CHECKIDENT ('Musteriler', RESEED, 0); 
GO
PRINT 'Musteriler tablosuna 20 adet  veri ekleniyor...';

INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, SifreHash, IsVerifiedNeedOwner, IsActive) VALUES
('Ayþenur', 'Kavak', 'aysenur.kavak@email.com', '05051112233', 'HASH_9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 0, 1),
('Ali', 'Yýlmaz', 'ali.yilmaz@email.com', '05329998877', 'HASH_sifrehash1', 0, 1),
('Fatma', 'Kaya', 'fatma.kaya@email.com', '05448887766', 'HASH_sifrehash2', 0, 1),
('Murat', 'Çelik', 'murat.celik@email.com', '05337776655', 'HASH_sifrehash3', 0, 1),
('Zeynep', 'Demir', 'zeynep.demir@email.com', '05556665544', 'HASH_sifrehash4', 0, 1),
('Gökhan', 'Öztürk', 'gokhan.ozturk@email.com', '05425554433', 'HASH_sifrehash5', 0, 1),
('Elif', 'Aslan', 'elif.aslan@email.com', '05314443322', 'HASH_sifrehash6', 0, 1),
('Burak', 'Þahin', 'burak.sahin@email.com', '05063332211', 'HASH_sifrehash7', 0, 1),
('Merve', 'Yýldýz', 'merve.yildiz@email.com', '05522221100', 'HASH_sifrehash8', 0, 1),
('Hakan', 'Aydýn', 'hakan.aydin@email.com', '05391110099', 'HASH_sifrehash9', 0, 1),
('Selin', 'Yalçýn', 'selin.yalcin@email.com', '05430009988', 'HASH_sifrehash10', 0, 1),
('Emre', 'Kurt', 'emre.kurt@email.com', '05359993322', 'HASH_sifrehash11', 0, 1);


INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, SifreHash, IsVerifiedNeedOwner, IsActive) VALUES
('Ahmet', 'Fakir', 'ahmet.fakir@email.com', '05387771122', 'HASH_ihtiyachash1', 1, 1),
('Emine', 'Yýlmazer', 'emine.y@email.com', '05416662233', 'HASH_ihtiyachash2', 1, 1),
('Mehmet', 'Can', 'mehmet.can@email.com', '05535553344', 'HASH_ihtiyachash3', 1, 1),
('Hatice', 'Bulut', 'hatice.b@email.com', '05074444455', 'HASH_ihtiyachash4', 1, 1),
('Süleyman', 'Öz', 'suleyman.oz@email.com', '05463335566', 'HASH_ihtiyachash5', 1, 1),
('Kader', 'Güneþ', 'kader.gunes@email.com', '05342226677', 'HASH_ihtiyachash6', 1, 1);

INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, SifreHash, IsVerifiedNeedOwner, IsActive) VALUES
('Hüseyin', 'Eski', 'huseyin.eski@email.com', '05321234567', 'HASH_pasifhash1', 0, 0), 
('Demet', 'Sakin', 'demet.sakin@email.com', '05459876543', 'HASH_pasifhash2', 0, 1); 
GO


SELECT COUNT(*) AS ToplamMusteriSayisi FROM Musteriler;
SELECT IsVerifiedNeedOwner, IsActive, COUNT(*) AS MusteriDaðilimi FROM Musteriler GROUP BY IsVerifiedNeedOwner, IsActive;
GO




GO
DELETE FROM AskidaBagislar;

DBCC CHECKIDENT ('AskidaBagislar', RESEED, 0); 

PRINT 'AskidaBagislar tablosuna hayýrsever baðýþ hareketleri ekleniyor...';

INSERT INTO AskidaBagislar (BagisciMusteriID, IsAnonymous, BagisTipi, UrunID, Miktar, KalanMiktar, BagisTarihi, IsActive)
VALUES (1, 0, 'BAKIYE', NULL, 350.00, 350.00, DATEADD(day, -30, GETDATE()), 1);


INSERT INTO AskidaBagislar (BagisciMusteriID, IsAnonymous, BagisTipi, UrunID, Miktar, KalanMiktar, BagisTarihi, IsActive)
VALUES (2, 0, 'URUN', 1, 5.00, 5.00, DATEADD(day, -25, GETDATE()), 1);

INSERT INTO AskidaBagislar (BagisciMusteriID, IsAnonymous, BagisTipi, UrunID, Miktar, KalanMiktar, BagisTarihi, IsActive)
VALUES (3, 1, 'BAKIYE', NULL, 500.00, 500.00, DATEADD(day, -20, GETDATE()), 1);


INSERT INTO AskidaBagislar (BagisciMusteriID, IsAnonymous, BagisTipi, UrunID, Miktar, KalanMiktar, BagisTarihi, IsActive)
VALUES (4, 0, 'URUN', 20, 3.00, 3.00, DATEADD(day, -15, GETDATE()), 1);


INSERT INTO AskidaBagislar (BagisciMusteriID, IsAnonymous, BagisTipi, UrunID, Miktar, KalanMiktar, BagisTarihi, IsActive)
VALUES (5, 1, 'URUN', 50, 4.00, 4.00, DATEADD(day, -10, GETDATE()), 1);


INSERT INTO AskidaBagislar (BagisciMusteriID, IsAnonymous, BagisTipi, UrunID, Miktar, KalanMiktar, BagisTarihi, IsActive)
VALUES (6, 0, 'BAKIYE', NULL, 200.00, 200.00, DATEADD(day, -5, GETDATE()), 1);


INSERT INTO AskidaBagislar (BagisciMusteriID, IsAnonymous, BagisTipi, UrunID, Miktar, KalanMiktar, BagisTarihi, IsActive)
VALUES (7, 0, 'URUN', 34, 2.00, 2.00, DATEADD(day, -2, GETDATE()), 1);
GO

SELECT * FROM AskidaBagislar;
GO





DELETE FROM AskidaTuketimler;
DELETE FROM SiparisDetaylari;
DELETE FROM Siparisler;
GO


DBCC CHECKIDENT ('Siparisler', RESEED, 0);
DBCC CHECKIDENT ('SiparisDetaylari', RESEED, 0);
DBCC CHECKIDENT ('AskidaTuketimler', RESEED, 0);
GO

PRINT 'Siparisler ve SiparisDetaylari tablolarýna 100 adet entegre sipariþ yükleniyor...';


INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis) VALUES 
(1, 1, 1, '2026-04-01 12:30:00', 300.00, 'TeslimEdildi', 0),
(1, 1, 1, '2026-04-03 18:45:00', 230.00, 'TeslimEdildi', 0),
(2, 1, 2, '2026-04-05 13:15:00', 440.00, 'TeslimEdildi', 0),
(3, 1, 3, '2026-04-07 19:20:00', 130.00, 'TeslimEdildi', 0),
(4, 1, 5, '2026-04-10 12:10:00', 500.00, 'TeslimEdildi', 0);

INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES 
(1, 1, 2, 70.00), (1, 4, 2, 60.00), 
(1, 9, 1, 40.00),
(2, 2, 1, 160.00), (2, 11, 2, 35.00),
(3, 7, 2, 140.00), (3, 2, 1, 160.00),
(4, 5, 1, 60.00), (4, 12, 2, 35.00),
(5, 7, 2, 140.00), (5, 6, 1, 220.00), (5, 13, 1, 40.00);

INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis) VALUES 
(2, 2, 2, '2026-04-12 19:00:00', 655.00, 'TeslimEdildi', 0),
(5, 2, 3, '2026-04-14 20:30:00', 370.00, 'TeslimEdildi', 0),
(6, 2, 5, '2026-04-15 13:00:00', 415.00, 'TeslimEdildi', 0),
(7, 2, 1, '2026-04-17 18:15:00', 540.00, 'TeslimEdildi', 0),
(8, 2, 2, '2026-04-19 12:45:00', 225.00, 'TeslimEdildi', 0),
(9, 2, 3, '2026-04-20 19:10:00', 745.00, 'TeslimEdildi', 0),
(10, 2, 5, '2026-04-22 13:20:00', 325.00, 'TeslimEdildi', 0),
(11, 2, 1, '2026-04-23 21:00:00', 415.00, 'TeslimEdildi', 0),
(12, 2, 2, '2026-04-25 14:30:00', 495.00, 'TeslimEdildi', 0),
(1, 2, 3, '2026-04-26 18:00:00', 585.00, 'TeslimEdildi', 0);

INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES 
(6, 18, 1, 360.00), (6, 21, 1, 180.00), (6, 22, 1, 95.00), (6, 23, 1, 20.00),
(7, 19, 1, 310.00), (7, 24, 1, 60.00),
(8, 17, 1, 340.00), (8, 22, 1, 75.00),
(9, 18, 1, 360.00), (9, 21, 1, 180.00), (9, 23, 1, 45.00), 
(10, 22, 3, 75.00),
(11, 18, 1, 360.00), (11, 21, 1, 180.00), (11, 22, 2, 95.00), (11, 23, 2, 45.00),
(12, 17, 1, 340.00), (12, 22, 1, 95.00), (12, 24, 1, 60.00),
(13, 19, 1, 310.00), (13, 22, 1, 95.00), (13, 23, 1, 45.00),
(14, 18, 1, 360.00), (14, 22, 1, 95.00), (14, 21, 1, 180.00),
(15, 18, 1, 360.00), (15, 21, 1, 180.00), (15, 23, 1, 45.00);

DELETE FROM SiparisDetaylari;

INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES 
(1, 1, 2, 70.00), (1, 4, 2, 60.00), (1, 9, 1, 40.00),
(2, 2, 1, 160.00), (2, 11, 2, 35.00),
(3, 7, 2, 140.00), (3, 2, 1, 160.00),
(4, 5, 1, 60.00), (4, 12, 2, 35.00),
(5, 7, 2, 140.00), (5, 6, 1, 220.00), (5, 13, 1, 40.00),
(6, 18, 1, 360.00), (6, 21, 1, 180.00), (6, 22, 1, 70.00), (6, 23, 1, 45.00),
(7, 19, 1, 310.00), (7, 24, 1, 60.00),
(8, 17, 1, 340.00), (8, 22, 1, 75.00),
(9, 18, 1, 360.00), (9, 21, 1, 180.00),
(10, 22, 3, 75.00),
(11, 18, 1, 360.00), (11, 21, 1, 180.00),
(12, 17, 1, 340.00), (12, 22, 1, 75.00),
(13, 19, 1, 310.00), (13, 22, 1, 75.00), (13, 23, 1, 45.00),
(14, 18, 1, 360.00), (14, 22, 1, 75.00),
(15, 18, 1, 360.00), (15, 21, 1, 180.00), (15, 23, 1, 45.00);


INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis)
SELECT 
    (ABS(CHECKSUM(NEWID())) % 12) + 1, 
    (ABS(CHECKSUM(NEWID())) % 5) + 1, 
    (ABS(CHECKSUM(NEWID())) % 3) + 1, 
    DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 45), GETDATE()), 
    250.00, 'TeslimEdildi', 0
FROM sys.all_objects WHERE object_id <= 50;

INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat)
SELECT SiparisID, 1, 2, 70.00 FROM Siparisler WHERE SiparisID > 15 AND SiparisID <= 65;

UPDATE Siparisler 
SET ToplamTutar = (SELECT SUM(SatirToplam) FROM SiparisDetaylari WHERE SiparisDetaylari.SiparisID = Siparisler.SiparisID)
WHERE SiparisID > 15 AND SiparisID <= 65;

INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis)
VALUES (13, 1, 1, '2026-05-10 13:00:00', 0.00, 'TeslimEdildi', 1);
INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES (66, 1, 2, 70.00);

UPDATE AskidaBagislar SET KalanMiktar = KalanMiktar - 2 WHERE BagisID = 2; 
INSERT INTO AskidaTuketimler (SiparisID, BagisID, TuketilenMiktar) VALUES (66, 2, 2.00); 

INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis)
VALUES (14, 2, 2, '2026-05-11 19:30:00', 0.00, 'TeslimEdildi', 1);
INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES (67, 18, 1, 360.00);

UPDATE AskidaBagislar SET KalanMiktar = KalanMiktar - 1 WHERE BagisID = 4;
INSERT INTO AskidaTuketimler (SiparisID, BagisID, TuketilenMiktar) VALUES (67, 4, 1.00);

INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis)
SELECT TOP 8 15, 4, 5, '2026-05-12 12:00:00', 0.00, 'TeslimEdildi', 1 FROM sys.all_objects;

INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat)
SELECT SiparisID, 50, 1, 75.00 FROM Siparisler WHERE SiparisID BETWEEN 68 AND 75;

UPDATE AskidaBagislar SET KalanMiktar = KalanMiktar - 0.5 WHERE BagisID = 5; 


INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis)
VALUES (16, 1, 1, '2026-05-14 14:10:00', 0.00, 'TeslimEdildi', 1);
INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES (76, 4, 2, 60.00); 

UPDATE AskidaBagislar SET KalanMiktar = KalanMiktar - 120.00 WHERE BagisID = 1; 
INSERT INTO AskidaTuketimler (SiparisID, BagisID, TuketilenMiktar) VALUES (76, 1, 120.00); 

INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis)
SELECT TOP 19
    (ABS(CHECKSUM(NEWID())) % 6) + 13, 
    3, NULL, DATEADD(day, -2, GETDATE()), 0.00, 'TeslimEdildi', 1
FROM sys.all_objects;

INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat)
SELECT SiparisID, 33, 1, 80.00 FROM Siparisler WHERE SiparisID BETWEEN 77 AND 95;

UPDATE AskidaBagislar 
SET KalanMiktar = KalanMiktar - 15.00 
WHERE BagisID = 3 AND KalanMiktar >= 15.00;
GO


INSERT INTO Siparisler (MusteriID, RestoranID, KuryeID, SiparisTarihi, ToplamTutar, SiparisDurumu, IsAskidaSiparis) VALUES 
(6, 5, 2, GETDATE(), 310.00, 'Yolda', 0),
(7, 3, NULL, GETDATE(), 290.00, 'Hazirlaniyor', 0),
(8, 4, 1, '2026-05-19 15:00:00', 150.00, 'IptalEdildi', 0), 
(9, 1, 3, GETDATE(), 160.00, 'Yolda', 0),
(10, 2, NULL, GETDATE(), 340.00, 'Hazirlaniyor', 0);

INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat) VALUES 
(96, 68, 1, 310.00),
(97, 35, 1, 290.00),
(98, 49, 1, 150.00),
(99, 2, 1, 160.00),
(100, 19, 1, 340.00);

UPDATE Siparisler SET ToplamTutar = 0 WHERE IsAskidaSiparis = 1;

PRINT 'Tebrikler! 100 adet sipariþ, detay satýrlarý  baþarýyla yüklendi.';
GO


SELECT COUNT(*) AS ToplamSiparisSayisi FROM Siparisler;
SELECT SiparisDurumu, COUNT(*) AS DurumDagilimi FROM Siparisler GROUP BY SiparisDurumu;
SELECT IsAskidaSiparis, COUNT(*) AS NormalVsAskidaSiparis FROM Siparisler GROUP BY IsAskidaSiparis;
SELECT * FROM AskidaTuketimler;
GO


USE YemekSiparisDB;
GO


IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Restoranlar') AND name = 'ToplamCiro')
BEGIN
    ALTER TABLE Restoranlar ADD ToplamCiro DECIMAL(18,2) NOT NULL CONSTRAINT DF_Restoranlar_ToplamCiro DEFAULT (0.00);
END
GO


CREATE OR ALTER VIEW vw_AktifRestoranMenuleri
AS
SELECT 
    R.RestoranID,
    R.RestoranAdi,
    U.UrunID,
    U.UrunAdi,
    U.Fiyat,
    U.Kategori
FROM Restoranlar R
INNER JOIN Urunler U ON R.RestoranID = U.RestoranID
WHERE R.IsActive = 1      
  AND U.IsActive = 1;
GO


CREATE OR ALTER VIEW vw_AskidaYemekHavuzDurumu
AS
SELECT 
    ISNULL(SUM(CASE WHEN BagisTipi = 'BAKIYE' THEN KalanMiktar ELSE 0 END), 0) AS HavuzdakiToplamNakitTL,
    ISNULL(SUM(CASE WHEN BagisTipi = 'URUN' THEN KalanMiktar ELSE 0 END), 0) AS AskidakiToplamPorsiyonAdeti,
    (SELECT COUNT(DISTINCT S.MusteriID) 
     FROM Siparisler S 
     WHERE S.IsAskidaSiparis = 1 AND S.SiparisDurumu = 'TeslimEdildi') AS YararlananBenzersizIhtiyacSahibiSayisi
FROM AskidaBagislar
WHERE IsActive = 1;
GO

CREATE OR ALTER VIEW vw_MusteriSiparisGecmisi
AS
SELECT 
    M.MusteriID,
    M.Ad + ' ' + M.Soyad AS MusteriAdSoyad,
    S.SiparisID,
    S.SiparisTarihi,
    R.RestoranAdi,
    ISNULL(K.Ad + ' ' + K.Soyad, 'Kurye Atanmadý') AS KuryeAdSoyad,
    S.ToplamTutar,
    S.SiparisDurumu,
    S.IsAskidaSiparis
FROM Musteriler M
INNER JOIN Siparisler S ON M.MusteriID = S.MusteriID
INNER JOIN Restoranlar R ON S.RestoranID = R.RestoranID
LEFT JOIN Kuryeler K ON S.KuryeID = K.KuryeID;
GO



CREATE OR ALTER TRIGGER trg_SiparisCiroGuncelle
ON Siparisler
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM inserted i INNER JOIN deleted d ON i.SiparisID = d.SiparisID 
              WHERE i.SiparisDurumu = 'TeslimEdildi' AND d.SiparisDurumu <> 'TeslimEdildi')
    BEGIN
        UPDATE Restoranlar
        SET ToplamCiro = ToplamCiro + i.ToplamTutar
        FROM Restoranlar R
        INNER JOIN inserted i ON R.RestoranID = i.RestoranID
        INNER JOIN deleted d ON i.SiparisID = d.SiparisID
        WHERE i.SiparisDurumu = 'TeslimEdildi' AND d.SiparisDurumu <> 'TeslimEdildi';
    END


    IF EXISTS(SELECT 1 FROM inserted i INNER JOIN deleted d ON i.SiparisID = d.SiparisID 
              WHERE i.SiparisDurumu <> 'TeslimEdildi' AND d.SiparisDurumu = 'TeslimEdildi')
    BEGIN
        UPDATE Restoranlar
        SET ToplamCiro = ToplamCiro - d.ToplamTutar
        FROM Restoranlar R
        INNER JOIN inserted i ON R.RestoranID = i.RestoranID
        INNER JOIN deleted d ON i.SiparisID = d.SiparisID
        WHERE i.SiparisDurumu <> 'TeslimEdildi' AND d.SiparisDurumu = 'TeslimEdildi';
    END
END;
GO



CREATE OR ALTER TRIGGER trg_AskidanDusmeVeStokYonetimi
ON SiparisDetaylari
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SiparisID INT, @UrunID INT, @IstenenAdet DECIMAL(18,2), @IsAskida BIT;
    
    SELECT @SiparisID = i.SiparisID, @UrunID = i.UrunID, @IstenenAdet = CAST(i.Adet AS DECIMAL(18,2)) FROM inserted i;
    SELECT @IsAskida = IsAskidaSiparis FROM Siparisler WHERE SiparisID = @SiparisID;

    IF @IsAskida = 1
    BEGIN
        DECLARE @KalanHavuzStoku DECIMAL(18,2);
        
        SELECT @KalanHavuzStoku = ISNULL(SUM(KalanMiktar), 0) 
        FROM AskidaBagislar 
        WHERE UrunID = @UrunID AND IsActive = 1 AND BagisTipi = 'URUN';

        
        IF @KalanHavuzStoku < @IstenenAdet
        BEGIN
            RAISERROR('HATA: Askýda yemek havuzunda bu üründen yeterli porsiyon bulunmamaktadýr! Sipariþ iptal edildi.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

      
        DECLARE @BagisID INT, @MevcutMiktar DECIMAL(18,2);
        
        DECLARE BagisCursor CURSOR FOR 
        SELECT BagisID, KalanMiktar FROM AskidaBagislar 
        WHERE UrunID = @UrunID AND IsActive = 1 AND KalanMiktar > 0 ORDER BY BagisTarihi ASC;

        OPEN BagisCursor;
        FETCH NEXT FROM BagisCursor INTO @BagisID, @MevcutMiktar;

        WHILE @IstenenAdet > 0 AND @@FETCH_STATUS = 0
        BEGIN
            IF @MevcutMiktar >= @IstenenAdet
            BEGIN
                UPDATE AskidaBagislar SET KalanMiktar = KalanMiktar - @IstenenAdet WHERE BagisID = @BagisID;
                INSERT INTO AskidaTuketimler (SiparisID, BagisID, TuketilenMiktar) VALUES (@SiparisID, @BagisID, @IstenenAdet);
                SET @IstenenAdet = 0;
            END
            ELSE
            BEGIN
                UPDATE AskidaBagislar SET KalanMiktar = 0, IsActive = 0 WHERE BagisID = @BagisID;
                INSERT INTO AskidaTuketimler (SiparisID, BagisID, TuketilenMiktar) VALUES (@SiparisID, @BagisID, @MevcutMiktar);
                SET @IstenenAdet = @IstenenAdet - @MevcutMiktar;
            END
            FETCH NEXT FROM BagisCursor INTO @BagisID, @MevcutMiktar;
        END

        CLOSE BagisCursor;
        DEALLOCATE BagisCursor;
    END
END;
GO



IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SistemLoglari')
BEGIN
    CREATE TABLE SistemLoglari (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        TabloAdi VARCHAR(50),
        IslemTipi VARCHAR(20),
        Aciklama VARCHAR(250),
        IslemTarihi DATETIME DEFAULT GETDATE()
    );
END
GO

CREATE OR ALTER TRIGGER trg_MusteriKayitLogla
ON Musteriler
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO SistemLoglari (TabloAdi, IslemTipi, Aciklama)
    SELECT 'Musteriler', 'INSERT', 'Yeni müþteri platforma kayýt oldu. Eposta: ' + i.Email
    FROM inserted i;
END;
GO



CREATE NONCLUSTERED INDEX IX_Siparisler_SiparisTarihi
ON Siparisler (SiparisTarihi);
GO

CREATE NONCLUSTERED INDEX IX_SiparisDetaylari_SiparisID_UrunID
ON SiparisDetaylari (SiparisID, UrunID);
GO


CREATE NONCLUSTERED INDEX IX_Siparisler_RestoranID_IsAskida
ON Siparisler (RestoranID, IsAskidaSiparis);


USE YemekSiparisDB;
GO



CREATE TABLE MusteriDogrulamalari (
    DogrulamaID INT IDENTITY(1,1) NOT NULL,
    MusteriID INT NOT NULL,
    BelgeTipi VARCHAR(50) NOT NULL, 
    BelgeRefNo VARCHAR(100) NULL,   
    BasvuruTarihi DATETIME NOT NULL CONSTRAINT DF_MusteriDogrulamalari_Basvuru DEFAULT (GETDATE()),
    OnayDurumu VARCHAR(20) NOT NULL CONSTRAINT DF_MusteriDogrulamalari_Durum DEFAULT ('BEKLEMEDE'),
    OnaylayanPersonelID INT NULL,   
    GecerlilikTarihi DATETIME NULL,  
    RedNedeni VARCHAR(250) NULL,    

    CONSTRAINT PK_MusteriDogrulamalari PRIMARY KEY CLUSTERED (DogrulamaID),
    CONSTRAINT FK_MusteriDogrulamalari_Musteriler FOREIGN KEY (MusteriID) REFERENCES Musteriler (MusteriID),
    CONSTRAINT CK_MusteriDogrulamalari_OnayDurumu CHECK (OnayDurumu IN ('BEKLEMEDE', 'ONAYLANDI', 'REDDEDILDI'))
);
GO 

CREATE OR ALTER PROCEDURE sp_MusteriIhtiyacDurumuDogrula
    @MusteriID INT,
    @OnayDurumu VARCHAR(20),
    @BelgeTipi VARCHAR(50),
    @BelgeRefNo VARCHAR(100) = NULL,
    @OnaylayanPersonelID INT = NULL,
    @GecerlilikSuresiAy INT = 12, 
    @RedNedeni VARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        
        IF EXISTS (SELECT 1 FROM MusteriDogrulamalari WHERE MusteriID = @MusteriID AND OnayDurumu = 'BEKLEMEDE')
        BEGIN
            UPDATE MusteriDogrulamalari
            SET OnayDurumu = @OnayDurumu,
                BelgeTipi = @BelgeTipi,
                BelgeRefNo = @BelgeRefNo,
                OnaylayanPersonelID = @OnaylayanPersonelID,
                GecerlilikTarihi = CASE WHEN @OnayDurumu = 'ONAYLANDI' THEN DATEADD(month, @GecerlilikSuresiAy, GETDATE()) ELSE NULL END,
                RedNedeni = @RedNedeni
            WHERE MusteriID = @MusteriID AND OnayDurumu = 'BEKLEMEDE';
        END
        ELSE
        BEGIN
            INSERT INTO MusteriDogrulamalari (MusteriID, BelgeTipi, BelgeRefNo, OnayDurumu, OnaylayanPersonelID, GecerlilikTarihi, RedNedeni)
            VALUES (@MusteriID, @BelgeTipi, @BelgeRefNo, @OnayDurumu, @OnaylayanPersonelID,
                    CASE WHEN @OnayDurumu = 'ONAYLANDI' THEN DATEADD(month, @GecerlilikSuresiAy, GETDATE()) ELSE NULL END, 
                    @RedNedeni);
        END

       
        IF @OnayDurumu = 'ONAYLANDI'
        BEGIN
            UPDATE Musteriler 
            SET IsVerifiedNeedOwner = 1 
            WHERE MusteriID = @MusteriID;
        END
        ELSE
        BEGIN
            UPDATE Musteriler 
            SET IsVerifiedNeedOwner = 0 
            WHERE MusteriID = @MusteriID;
        END

        COMMIT TRANSACTION;
        PRINT 'Musteri dogrulama islemi basariyla tamamlandi.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO






GO
SELECT 
    S.SiparisID,                                       -- Sipariþin sistemdeki benzersiz numarasý
    M.Ad + ' ' + M.Soyad AS MusteriAdSoyad,            -- Ýki string kolonu (birleþtirme) yaparak ad soyad oluþturuyoruz
    R.RestoranAdi,                                     -- Sipariþin hangi restorandan verildiði bilgisi
    S.SiparisTarihi,                                   -- Sipariþin veritabanýna iþlendiði anlýk zaman damgasý
    
    -- [ÝÞ MANTIÐI]: CASE-WHEN kontrolü ile sipariþin aský havuzundan mý yoksa normal mi olduðunu ayýrt ediyoruz
    CASE 
        WHEN S.IsAskidaSiparis = 1 THEN 'Askýda Yemek (Ücretsiz / Havuzdan Finanse Edilen)'
        ELSE 'Normal Sipariþ (Ödemeli Kredi/Nakit)'
    END AS SiparisTuru,
    
    S.ToplamTutar,                                     -- Sipariþin toplam fatura bedeli
    S.SiparisDurumu                                    -- Sipariþin anlýk operasyonel statüsü (Örn: TeslimEdildi, Yolda)
FROM Siparisler S
-- [REFERANS BÜTÜNLÜÐÜ]: Sipariþi veren müþterinin kimlik bilgilerini çözmek için baðlama satýrý
INNER JOIN Musteriler M ON S.MusteriID = M.MusteriID
-- [REFERANS BÜTÜNLÜÐÜ]: Sipariþi alan restoranýn kurumsal bilgilerini çözmek için baðlama satýrý
INNER JOIN Restoranlar R ON S.RestoranID = R.RestoranID
-- [PERFORMANCE]: En güncel sipariþ hareketlerini en üstte listelemek için sýralama ölçütü
ORDER BY S.SiparisTarihi DESC;



GO
SELECT 
    R.RestoranID,                                      -- Gruplanacak olan ana restoran kimliði
    R.RestoranAdi,                                     -- Performansý ölçülen restoranýn ismi
    AVG(R.RestoranPuani) AS GenelKullaniciPuani,       -- AVG: Tablodaki restoran puanlarýnýn genel ortalamasýný alýr
    COUNT(S.SiparisID) AS Son1AyToplamSiparisSayisi,   -- COUNT: Restoranýn son 1 ayda aldýðý teslim edilmiþ sipariþ adetidir
    SUM(S.ToplamTutar) AS Son1AyToplamCiro,            -- SUM: Teslim edilen sipariþlerin toplam ciro deðerini hesaplar
    
    -- Toplam ciroyu toplam sipariþ sayýsýna bölerek ortalama sepet tutarýný buluyoruz.
    -- NULLIF kullanýmý: Eðer restoranýn sipariþi 0 ise sýfýra bölünme hatasýný  engeller.
    ISNULL(SUM(S.ToplamTutar) / NULLIF(COUNT(S.SiparisID), 0), 0) AS OrtalamaSepetTutari
FROM Restoranlar R
INNER JOIN Siparisler S ON R.RestoranID = S.RestoranID
-- [WHERE FILTRESI]: Veriler henüz paketlenmeden önce sadece son 30 güne ait tamamlanmýþ sipariþleri havuzdan ayýklar
WHERE S.SiparisTarihi >= DATEADD(day, -30, GETDATE()) 
  AND S.SiparisDurumu = 'TeslimEdildi'
-- [GRUPLAMA]: Agregasyon fonksiyonlarýnýn hangi kýrýlýmda hesaplanacaðýný belirler
GROUP BY R.RestoranID, R.RestoranAdi
-- [HAVING FILTRESI]: Gruplama yapýldýktan sonra,  5 ve üzeri sipariþ alan popüler yerleri seçer
HAVING COUNT(S.SiparisID) >= 5;
GO



SELECT 
    M.MusteriID,                                       -- Potansiyel baðýþçý müþterinin ID bilgisi
    M.Ad,
    M.Soyad,
    M.Email,                                           -- Kampanya maili göndermek için iletiþim alaný
    M.Telefon
FROM Musteriler M
WHERE M.IsActive = 1                                   -- Sadece sistemde hesabý aktif olan gerçek kullanýcýlar
  AND M.IsVerifiedNeedOwner = 0                        -- Ýhtiyaç sahiplerini bu ticari listeden muaf tutuyoruz
  
  -- [EXISTS ALT SORGUSU]: Müþterinin sistemde aktif bir tüketici olduðunu, en az 1 kez ödemeli sipariþ verdiðini doðrular
  AND EXISTS (
        SELECT 1 
        FROM Siparisler S 
        WHERE S.MusteriID = M.MusteriID                -- Dýþarýdaki müþteri ID'si ile içerideki sipariþ sahibi eþleþtirilir
          AND S.IsAskidaSiparis = 0                    -- Sipariþin kendi cebinden ödediði normal bir iþlem olmasý þartý
  )
  
  -- [NOT EXISTS ALT SORGUSU]: Bu aktif müþterinin bugüne kadar baðýþ havuzuna hiçbir þekilde kayýt býrakmadýðýný garanti eder
  AND NOT EXISTS (
        SELECT 1 
        FROM AskidaBagislar AB 
        WHERE AB.BagisciMusteriID = M.MusteriID        -- Eðer bu eþleþmeden 1 satýr bile veri DÖNERSE, o müþteri ana listeden ELENÝR
  );
GO