-- Çiftlik Yönetim Veritabanı Oluşturma
CREATE DATABASE IF NOT EXISTS CiftlikYonetim;
USE CiftlikYonetim;

-- Kullanıcılar Tablosu
CREATE TABLE IF NOT EXISTS Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    fullName VARCHAR(100),
    isActive BIT DEFAULT 1,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Hayvan Kategorileri
CREATE TABLE IF NOT EXISTS Kategori (
    id INT AUTO_INCREMENT PRIMARY KEY,
    adi VARCHAR(100) NOT NULL,
    ustKategoriId INT NULL,
    aciklama VARCHAR(255),
    isActive BIT DEFAULT 1,
    FOREIGN KEY (ustKategoriId) REFERENCES Kategori(id)
);

-- Cihazlar Tablosu
CREATE TABLE IF NOT EXISTS Cihaz (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cihazAdi VARCHAR(100) NOT NULL,
    macAdresi VARCHAR(50),
    imeiNo VARCHAR(50),
    isActive BIT DEFAULT 1,
    userId INT,
    FOREIGN KEY (userId) REFERENCES Users(id)
);

-- Hayvanlar Tablosu
CREATE TABLE IF NOT EXISTS Hayvan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rfidKodu VARCHAR(50) NOT NULL,
    kupeIsmi VARCHAR(100) NOT NULL,
    cinsiyet VARCHAR(10),
    agirlik VARCHAR(20),
    kategoriId INT,
    userId INT,
    requestId VARCHAR(100),
    aktif BIT DEFAULT 1,
    sonGuncelleme DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    dogumTarihi DATE,
    anaRfid VARCHAR(50),
    babaRfid VARCHAR(50),
    FOREIGN KEY (kategoriId) REFERENCES Kategori(id),
    FOREIGN KEY (userId) REFERENCES Users(id),
    INDEX idx_rfid (rfidKodu)
);

-- Küpe Hayvan İlişkisi
CREATE TABLE IF NOT EXISTS KupeHayvan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hayvanId INT NOT NULL,
    kupeId VARCHAR(50) NOT NULL,
    requestId VARCHAR(100),
    tarih DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hayvanId) REFERENCES Hayvan(id)
);

-- Ölçüm Tipleri
CREATE TABLE IF NOT EXISTS OlcumTipi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tip VARCHAR(50) NOT NULL,
    aciklama VARCHAR(255)
);

-- Mobil Ölçüm Tablosu
CREATE TABLE IF NOT EXISTS MobilOlcum (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Rfid VARCHAR(50) NOT NULL,
    Weight FLOAT NOT NULL,
    CihazId INT,
    AmacId INT,
    Amac VARCHAR(100),
    HayvanId INT,
    Tarih DATETIME DEFAULT CURRENT_TIMESTAMP,
    OlcumTipi INT DEFAULT 0, -- 0: Normal, 1: SuttenKesim, 2: YeniDogmus
    FOREIGN KEY (CihazId) REFERENCES Cihaz(id),
    FOREIGN KEY (HayvanId) REFERENCES Hayvan(id),
    INDEX idx_rfid_olcum (Rfid),
    INDEX idx_hayvan_id (HayvanId),
    INDEX idx_tarih (Tarih)
);

-- Ağırlık Hayvan İlişkisi
CREATE TABLE IF NOT EXISTS AgirlikHayvan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hayvanId INT NOT NULL,
    agirlikId VARCHAR(20),
    requestId VARCHAR(100),
    tarih DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hayvanId) REFERENCES Hayvan(id)
);

-- Soy Ağacı Tablosu
CREATE TABLE IF NOT EXISTS SoyAgaci (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hayvanId INT NOT NULL,
    anaId INT,
    babaId INT,
    FOREIGN KEY (hayvanId) REFERENCES Hayvan(id),
    FOREIGN KEY (anaId) REFERENCES Hayvan(id),
    FOREIGN KEY (babaId) REFERENCES Hayvan(id)
);

-- Başlangıç Verileri
INSERT INTO OlcumTipi (tip, aciklama) VALUES 
('Normal', 'Normal ağırlık ölçümü'),
('SuttenKesim', 'Sütten kesim ağırlık ölçümü'),
('YeniDogmus', 'Yeni doğmuş ağırlık ölçümü');

INSERT INTO Users (username, password, email, fullName) VALUES
('admin', '$2a$12$7xWRLM1aZlXBzjfGZRvi3.4.ULgJWU8FuvullfTOTVFGDHQFl8Ldu', 'admin@ciftlik.com', 'Sistem Yöneticisi');

INSERT INTO Kategori (adi, aciklama) VALUES
('Büyükbaş', 'İnek, Boğa, Düve vb.'),
('Küçükbaş', 'Koyun, Keçi vb.'); 