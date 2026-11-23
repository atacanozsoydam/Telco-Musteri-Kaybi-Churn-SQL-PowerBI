-- Veri Temizliği Sonrası Genel Tablo Kontrolü ve Finansal Özet
SELECT 
    COUNT(*) AS Toplam_Satir,
    SUM(CASE WHEN TotalCharges IS NULL THEN 1 ELSE 0 END) AS Kalan_Null_Sayisi,
    ROUND(AVG(MonthlyCharges), 2) AS Ortalama_Aylik_Fatura_Dolar,
    ROUND(SUM(TotalCharges), 2) AS Sirketin_Toplam_Tahsilati_Dolar
FROM Billing_Contracts;



-- Soru 1 : "Şirketimizin Müşteri Kaybı (Churn) Oranı Nedir ve Her Ay Kaç Dolar Ciro Kaybediyoruz?"
-- [Yüzde kaçı gitti ve bu gidenler yüzünden her ay kasamıza girecek olan kaç para buhar oldu? ]

-- Genel Churn (Müşteri Terk) Oranı ve Kaybedilen Aylık Gelir Analizi
SELECT 
    Churn AS Musteri_Durumu,
    COUNT(customerID) AS Musteri_Sayisi,
    
    -- Toplam 7043 müşterinin yüzde kaçı bu grupta?
    ROUND(100.0 * COUNT(customerID) / 7043, 2) AS Musteri_Orani_Yuzde,
    
    -- Bu gruptaki müşterilerin ortalama aylık faturası ne kadar?
    ROUND(AVG(MonthlyCharges), 2) AS Ortalama_Aylik_Fatura,
    
    -- Bu gruptaki müşterilerin şirkete bıraktığı AYLIK TOPLAM GELİR (Ciro) ne kadar?
    ROUND(SUM(MonthlyCharges), 2) AS Aylik_Toplam_Ciro_Dolar

FROM Billing_Contracts
GROUP BY Churn;



-- Soru 2: "Müşteriler Hangi İnternet Altyapısında (Fiber vs DSL) ve Hangi Sözleşmede Bizi Terk Ediyor?
-- İnternet Altyapı Tipine (Fiber Optik, DSL, İnternet Yok) Göre Müşteri Kayıp (Churn) Oranı
-- ( Acaba Fiber internetimizde bir arıza veya aşırı fiyat sorunu mu var da müşteriler kaçıyor?)
SELECT 
    s.InternetService AS Internet_Altyapisi,
    COUNT(s.customerID) AS Toplam_Musteri,
    
    -- Sadece Churn = 'Yes' (Terk Eden) olanları sayıyoruz:
    SUM(CASE WHEN b.Churn = 'Yes' THEN 1 ELSE 0 END) AS Terk_Eden_Musteri_Sayisi,
    
    -- O internet tipindeki müşterilerin yüzde kaçı bizi terk etmiş?
    ROUND(
        100.0 * SUM(CASE WHEN b.Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(s.customerID), 
    2) AS Churn_Orani_Yuzde,
    
    -- O internet tipinin ortalama aylık faturası kaç dolar?
    ROUND(AVG(b.MonthlyCharges), 2) AS Ortalama_Aylik_Fatura

FROM Services s
INNER JOIN Billing_Contracts b ON s.customerID = b.customerID
GROUP BY s.InternetService
ORDER BY Churn_Orani_Yuzde DESC;



-- SORU 3: Sözleşme Tipine (Contract) Göre Müşteri Kayıp (Churn) ve Kaybedilen Ciro Analizi
-- ( Taahhütsüz/Aylık müşteriler mi kaçıyor, yoksa yıllık sözleşmeliler mi?)
SELECT 
    Contract AS Sozlesme_Tipi,
    COUNT(customerID) AS Toplam_Musteri,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Terk_Eden_Sayisi,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(customerID), 2) AS Churn_Orani_Yuzde,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END), 2) AS Kaybedilen_Aylik_Ciro_Dolar
FROM Billing_Contracts
GROUP BY Contract
ORDER BY Churn_Orani_Yuzde DESC;



-- SORU 4: Müşteri Yaşam Döngüsü (Tenure Segmentasyonu) Analizi - (JOIN + CASE WHEN)
-- (Neden: Müşterileri 0-72 ay diye tek tek incelemek yerine 'Yeni (0-6 Ay)', 'Gelişen (7-12 Ay)' gibi 4 gruba ayırıyoruz ki 
-- müşterinin hangi dönemde kaçtığını görelim!)
SELECT 
    CASE 
        WHEN s.tenure <= 6 THEN '1. Yeni Musteri (0-6 Ay)'
        WHEN s.tenure <= 12 THEN '2. Alisma Donemi (7-12 Ay)'
        WHEN s.tenure <= 24 THEN '3. Yerlesik Musteri (1-2 Yil)'
        ELSE '4. Sadik Musteri (2+ Yil)'
    END AS Abonelik_suresi_grubu,
    
    COUNT(s.customerID) AS Toplam_Musteri,
    SUM(CASE WHEN b.Churn = 'Yes' THEN 1 ELSE 0 END) AS Terk_Eden_Sayisi,
    ROUND(100.0 * SUM(CASE WHEN b.Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(s.customerID), 2) AS Churn_Orani_Yuzde

FROM Services s
INNER JOIN Billing_Contracts b ON s.customerID = b.customerID
GROUP BY 
    CASE 
        WHEN s.tenure <= 6 THEN '1. Yeni Musteri (0-6 Ay)'
        WHEN s.tenure <= 12 THEN '2. Alisma Donemi (7-12 Ay)'
        WHEN s.tenure <= 24 THEN '3. Yerlesik Musteri (1-2 Yil)'
        ELSE '4. Sadik Musteri (2+ Yil)'
    END
ORDER BY Abonelik_suresi_grubu;



-- SORU 5A: Teknik Destek (TechSupport) Paketi Olup Olmamasına Göre Churn Oranı
-- (İnterneti bozulduğunda teknik destek alamayan müşteriler mi şirketi terk ediyor?)
SELECT 
    s.TechSupport AS Teknik_Destek_Durumu,
    COUNT(s.customerID) AS Toplam_Musteri,
    SUM(CASE WHEN b.Churn = 'Yes' THEN 1 ELSE 0 END) AS Terk_Eden_Sayisi,
    ROUND(100.0 * SUM(CASE WHEN b.Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(s.customerID), 2) AS Churn_Orani_Yuzde
FROM Services s
INNER JOIN Billing_Contracts b ON s.customerID = b.customerID
GROUP BY s.TechSupport
ORDER BY Churn_Orani_Yuzde DESC;


-- SORU 5B: Ödeme Yöntemine (PaymentMethod) Göre Churn Oranı
-- (Otomatik ödeme talimatı verenler mi daha sadık, yoksa her ay elle (Electronic check) ödeyenler mi kaçıyor?)
SELECT 
    PaymentMethod AS Odeme_Yontemi,
    COUNT(customerID) AS Toplam_Musteri,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Terk_Eden_Sayisi,
    ROUND(100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(customerID), 2) AS Churn_Orani_Yuzde
FROM Billing_Contracts
GROUP BY PaymentMethod
ORDER BY Churn_Orani_Yuzde DESC;