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