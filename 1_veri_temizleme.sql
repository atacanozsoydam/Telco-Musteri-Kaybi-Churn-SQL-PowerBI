
-- 1. Tabloya ilk bakış: İlk 15 satıra göz atalım
-- ( Sütunlarda ne tür veriler var, gözümüze çarpan garip bir şey var mı?)
SELECT TOP 15 * 
FROM raw_telco;

-- 2. Abonelik süresi (tenure) sütununda mantıksız bir sayı var mı?
-- (Sayısal sütunlarda en küçük (MIN), en büyük (MAX) ve ortalama (AVG) değere bakılır ki hatalı/uç değer varsa yakalayalım)
SELECT 
    MIN(tenure) AS En_Az_Kalan_Ay,
    MAX(tenure) AS En_Cok_Kalan_Ay,
    AVG(tenure) AS Ortalama_Kalinan_Ay
FROM raw_telco;


---------------------------------------------

-- 1. SORGUMUZ: Abonelik süresi (tenure) 0 olan müşteriler kimler ve faturalarında ne yazıyor?
-- ( En az kalan ay '0' çıktığı için bu kişilerin verisinde bir gariplik var mı diye bakıyoruz)
SELECT 
    customerID,
    tenure,
    MonthlyCharges,
    TotalCharges,
    Contract,
    Churn
FROM raw_telco
WHERE tenure = 0;

-- 2. SORGUMUZ: Ana sütunlarımızda hiç NULL (Boş) veya boşluk (' ') değer var mı?
-- (Tabloda eksik veri olan sütunları tek seferde tespit etmek için)
SELECT 
    COUNT(*) AS Toplam_Musteri,
    SUM(CASE WHEN customerID IS NULL THEN 1 ELSE 0 END) AS Bos_MusteriID,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS Bos_Cinsiyet,
    SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS Bos_Tenure,
    SUM(CASE WHEN MonthlyCharges IS NULL OR MonthlyCharges = ' ' THEN 1 ELSE 0 END) AS Bos_Aylik_Fatura,
    SUM(CASE WHEN TotalCharges IS NULL OR TotalCharges = ' ' THEN 1 ELSE 0 END) AS Bos_Toplam_Fatura,
    SUM(CASE WHEN Churn IS NULL THEN 1 ELSE 0 END) AS Bos_Churn
FROM raw_telco;




-- KONTROL 3: Metin sütunlarımızda hangi değerler var ve kaçar adet? (Yanlış yazılmış bir kelime var mı?)
SELECT Churn, COUNT(*) AS Kisi_Sayisi FROM raw_telco GROUP BY Churn;
SELECT Contract, COUNT(*) AS Kisi_Sayisi FROM raw_telco GROUP BY Contract;
SELECT InternetService, COUNT(*) AS Kisi_Sayisi FROM raw_telco GROUP BY InternetService;
SELECT PaymentMethod, COUNT(*) AS Kisi_Sayisi FROM raw_telco GROUP BY PaymentMethod;



-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


-- 1. TABLO: Müşteri Demografik Tablosu (Customers)
-- (Sadece müşterinin kişisel bilgilerini ayrı bir tabloda tutmak için)
SELECT 
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents
INTO Customers
FROM raw_telco;


-- 2. TABLO: Abonelik ve Hizmetler Tablosu (Services)
-- (Müşterinin kaç aydır bizde olduğu ve kullandığı internet/telefon paketlerini ayrı tutmak için)
SELECT 
    customerID,
    tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies
INTO Services
FROM raw_telco;


-- 3. TABLO: Sözleşme, Fatura ve Churn Tablosu (Billing_Contracts) - TEMİZLİK BURADA YAPILIYOR!
-- (Hem fatura tablosunu ayırıyoruz, hem de 11 NULL değeri 0 yapıp faturaları sayıya (FLOAT) çeviriyoruz)
SELECT 
    customerID,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    CAST(MonthlyCharges AS FLOAT) AS MonthlyCharges,
    CAST(ISNULL(TotalCharges, '0') AS FLOAT) AS TotalCharges,
    Churn
INTO Billing_Contracts
FROM raw_telco;