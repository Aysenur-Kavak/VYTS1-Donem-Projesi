USE [YemekSiparisDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER   TRIGGER [dbo].[trg_AskidanDusmeVeStokYonetimi]
ON [dbo].[SiparisDetaylari]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SiparisID INT, @UrunID INT, @IstenenAdet DECIMAL(18,2), @IsAskida BIT;
    
    SELECT @SiparisID = i.SiparisID, @UrunID = i.UrunID, @IstenenAdet = CAST(i.Adet AS DECIMAL(18,2)) FROM inserted i;
    SELECT @IsAskida = IsAskidaSiparis FROM Siparisler WHERE SiparisID = @SiparisID;

    IF @IsAskida = 1
    BEGIN
	
        DECLARE @MusteriID INT;
        
        SELECT @MusteriID = MusteriID FROM Siparisler WHERE SiparisID = @SiparisID;

     
        IF NOT EXISTS (
            SELECT 1 
            FROM MusteriDogrulamalari 
            WHERE MusteriID = @MusteriID 
              AND OnayDurumu = 'ONAYLANDI' 
              AND GecerlilikTarihi >= GETDATE()
        )
        BEGIN
          
            UPDATE Musteriler SET IsVerifiedNeedOwner = 0 WHERE MusteriID = @MusteriID;

           
            RAISERROR('HATA: Askıda yemek siparişi verebilmeniz için sistemde aktif ve süresi dolmamış onaylı bir doğrulama belgeniz bulunmalıdır!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
      
        DECLARE @KalanHavuzStoku DECIMAL(18,2);
        
        SELECT @KalanHavuzStoku = ISNULL(SUM(KalanMiktar), 0) 
        FROM AskidaBagislar 
        WHERE UrunID = @UrunID AND IsActive = 1 AND BagisTipi = 'URUN';

        
        IF @KalanHavuzStoku < @IstenenAdet
        BEGIN
            RAISERROR('HATA: Askıda yemek havuzunda bu üründen yeterli porsiyon bulunmamaktadır! Sipariş iptal edildi.', 16, 1);
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
