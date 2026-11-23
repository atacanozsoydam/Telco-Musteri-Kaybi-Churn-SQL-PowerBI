CREATE VIEW vw_Telco_Churn_Analizi AS
SELECT 
    -- 1. Customers (Müşteri) Tablosundan Gelenler:
    c.customerID,
    c.gender AS Cinsiyet,
    CASE WHEN c.SeniorCitizen = 1 THEN 'Yaşlı (65+)' ELSE 'Genç/Yetişkin' END AS Yas_Grubu,
    c.Partner AS Evli_Partner_Durumu,
    c.Dependents AS Bakmakla_Yukumlu_Durumu,

    -- 2. Services (Hizmetler) Tablosundan Gelenler:
    s.tenure AS Abonelik_Suresi_Ay,
    CASE 
        WHEN s.tenure <= 6 THEN '1. Yeni Müşteri (0-6 Ay)'
        WHEN s.tenure <= 12 THEN '2. Alışma Dönemi (7-12 Ay)'
        WHEN s.tenure <= 24 THEN '3. Yerleşik Müşteri (1-2 Yıl)'
        ELSE '4. Sadık Müşteri (2+ Yıl)'
    END AS Abonelik_Suresi_Grubu,
    s.PhoneService AS Telefon_Hizmeti,
    s.MultipleLines AS Coklu_Hat,
    s.InternetService AS Internet_Altyapisi,
    s.OnlineSecurity AS Online_Guvenlik,
    s.OnlineBackup AS Online_Yedekleme,
    s.DeviceProtection AS Cihaz_Koruma,
    s.TechSupport AS Teknik_Destek,
    s.StreamingTV AS TV_Paketi,
    s.StreamingMovies AS Film_Paketi,

    -- 3. Billing_Contracts (Fatura ve Sözleşme) Tablosundan Gelenler:
    b.Contract AS Sozlesme_Tipi,
    b.PaperlessBilling AS Dijital_Fatura,
    b.PaymentMethod AS Odeme_Yontemi,
    b.MonthlyCharges AS Aylik_Fatura_Dolar,
    b.TotalCharges AS Toplam_Fatura_Dolar,
    b.Churn AS Churn_Durumu,
    
    -- Power BI'da kolayca toplama/sayma yapmak için Churn = 'Yes' ise 1, 'No' ise 0 sütunu ekliyoruz:
    CASE WHEN b.Churn = 'Yes' THEN 1 ELSE 0 END AS Churn_Sayisal

FROM Customers c
INNER JOIN Services s ON c.customerID = s.customerID
INNER JOIN Billing_Contracts b ON c.customerID = b.customerID;