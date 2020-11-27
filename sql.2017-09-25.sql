/*
1.	Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea, 
a zatim u svojoj bazi podataka kreirati tabele sa sljedećom strukturom:
a)	Klijenti
i.	Ime, polje za unos 50 karaktera (obavezan unos)
ii.	Prezime, polje za unos 50 karaktera (obavezan unos)
iii.	Drzava, polje za unos 50 karaktera (obavezan unos)
iv.	Grad, polje za  unos 50 karaktera (obavezan unos)
v.	Email, polje za unos 50 karaktera (obavezan unos)
vi.	Telefon, polje za unos 50 karaktera (obavezan unos)
*/

/*
b)	Izleti
i.	Sifra, polje za unos 10 karaktera (obavezan unos)
ii.	Naziv, polje za unos 100 karaktera (obavezan unos)
iii.	DatumPolaska, polje za unos datuma (obavezan unos)
iv.	DatumPovratka, polje za unos datuma (obavezan unos)
v.	Cijena, polje za unos decimalnog broja (obavezan unos)
vi.	Opis, polje za unos dužeg teksta (nije obavezan unos)
*/

/*
c)	Prijave
i.	Datum, polje za unos datuma i vremena (obavezan unos)
ii.	BrojOdraslih polje za unos cijelog broja (obavezan unos)
iii.	BrojDjece polje za unos cijelog broja (obavezan unos)
Napomena: Na izlet se može prijaviti više klijenata, dok svaki klijent može prijaviti više izleta. 
Prilikom prijave klijent je obavezan unijeti broj odraslih i broj djece koji putuju u sklopu izleta.
*/

CREATE DATABASE zadatak2017_treci
use zadatak2017_treci
GO

CREATE TABLE Klijenti
(
	KlijentID INT NOT NULL CONSTRAINT PK_KlijentID PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(50) NOT NULL,
	Prezime NVARCHAR(50) NOT NULL,
	Drzava NVARCHAR(50) NOT NULL,
	Grad NVARCHAR(50) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	Telefon NVARCHAR(50) NOT NULL
)

CREATE TABLE Izleti
(
	IzletID INT NOT NULL CONSTRAINT PK_IzletID PRIMARY KEY IDENTITY(1,1),
	Sifra NVARCHAR(10) NOT NULL,
	Naziv NVARCHAR(100) NOT NULL,
	DatumPolaska DATE NOT NULL,
	DatumPovratka DATE NOT NULL,
	Cijena DECIMAL(18,2),
	Opis TEXT

)

CREATE TABLE Prijave
(
	PrijaveID INT NOT NULL CONSTRAINT PK_PrijaveID PRIMARY KEY IDENTITY(1,1),
	KlijentID INT NOT NULL CONSTRAINT FK_KlijentPrijave FOREIGN KEY(KlijentID) REFERENCES Klijenti(KlijentID),
	IzletID INT NOT NULL CONSTRAINT FK_IzletIDPrijave FOREIGN KEY (IzletID) REFERENCES Izleti(IzletID),
	Datum DATETIME NOT NULL,
	BrojOdraslih int NOT NULL,
	BrojDjece INT NOT NULL
)

/*
2.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljede�e podatke:
a)	U tabelu Klijenti prebaciti sve uposlenike koji su radili u odjelu prodaje (Sales) 
i.	FirstName -> Ime
ii.	LastName -> Prezime
iii.	CountryRegion (Name) -> Drzava
iv.	Addresss (City) -> Grad
v.	EmailAddress (EmailAddress)  -> Email (Izme�u imena i prezime staviti ta�ku)
vi.	PersonPhone (PhoneNumber) -> Telefon
b)	U tabelu Izleti dodati 3 izleta (proizvoljno)	
*/

INSERT INTO Klijenti
SELECT P.FirstName,P.LastName,CR.Name ,A.City,P.FirstName+'.'+P.LastName+SUBSTRING(EM.EmailAddress,CHARINDEX('@',EM.EmailAddress)+1,30),PP.PhoneNumber
FROM AdventureWorks2014.Person.Person AS P 
INNER JOIN AdventureWorks2014.Person.BusinessEntityAddress AS BEA ON P.BusinessEntityID=BEA.BusinessEntityID
INNER JOIN AdventureWorks2014.Person.Address AS A ON BEA.AddressID=A.AddressID
INNER JOIN AdventureWorks2014.Person.StateProvince AS SP ON SP.StateProvinceID=A.StateProvinceID
INNER JOIN AdventureWorks2014.Person.CountryRegion AS CR ON SP.CountryRegionCode=CR.CountryRegionCode
INNER JOIN AdventureWorks2014.Person.EmailAddress AS EM ON EM.BusinessEntityID=P.BusinessEntityID 
INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP ON PP.BusinessEntityID=P.BusinessEntityID
INNER JOIN AdventureWorks2014.HumanResources.Employee AS E ON E.BusinessEntityID=P.BusinessEntityID
WHERE E.JobTitle LIKE '%Sales%'

INSERT INTO Izleti (Sifra,Naziv,DatumPolaska,DatumPovratka,Cijena)
VALUES ('ABC1231230','Lugovi','20200101','20200701',20),
		('EDF1231230','Buk','20200202','20200802',50),
		('GHK1231230','Mackovac','20200303','20200903',20)
		SELECT * FROM Izleti
/*
3.	Kreirati uskladištenu proceduru za unos nove prijave. Proceduri nije potrebno proslijediti parametar Datum.
Datum se uvijek postavlja na trenutni. Koristeći kreiranu proceduru u tabelu Prijave dodati 10 prijava.
*/

CREATE PROCEDURE procedura_unos_prijave
(
	@KlijentID INT,
	@IzletID INT,
	@BrojOdraslih INT,
	@BrojDjece INT
)
AS
BEGIN
	INSERT INTO Prijave
	VALUES(@KlijentID,@IzletID,GETDATE(),@BrojOdraslih,@BrojDjece)
END
SELECT * FROM Klijenti
SELECT * FROM Izleti
EXEC procedura_unos_prijave 18817,1,5,20
EXEC procedura_unos_prijave 18818,2,5,25
EXEC procedura_unos_prijave 18819,3,3,15
EXEC procedura_unos_prijave 18820,1,5,30
EXEC procedura_unos_prijave 18821,1,10,50
EXEC procedura_unos_prijave 18822,2,5,26
EXEC procedura_unos_prijave 18823,3,9,40
EXEC procedura_unos_prijave 18824,1,5,20
EXEC procedura_unos_prijave 18825,3,5,15
EXEC procedura_unos_prijave 18826,1,3,70

SELECT * FROM Prijave
/*
4.	Kreirati index koji će spriječiti dupliciranje polja Email u tabeli Klijenti. Obavezno testirati ispravnost kreiranog indexa.
*/
CREATE UNIQUE NONCLUSTERED INDEX ix_unique_mail
ON Klijenti(Email)
select * from Klijenti
insert into Klijenti
VALUES (' sa','sa','sa','sa','Brian.Welckeradventure-works.com','123123123')
/*
5.	Svim izletima koji imaju više od 3 prijave cijenu umanjiti za 10%.
*/
SELECT * FROM Izleti
UPDATE Izleti
SET Cijena=Cijena-(Cijena*0.1)
WHERE IzletID=
(SELECT I.IzletID FROM Prijave AS P INNER JOIN Izleti AS I ON P.IzletID=I.IzletID GROUP BY I.IzletID HAVING COUNT(P.PrijaveID)>3)

/*
6.	Kreirati view (pogled) koji prikazuje podatke o izletu: šifra, naziv, datum polaska, datum povratka i cijena, 
te ukupan broj prijava na izletu, 
ukupan broj putnika, ukupan broj odraslih i ukupan broj djece. Obavezno prilagoditi format datuma (dd.mm.yyyy).
*/
CREATE VIEW viewPregled
AS
SELECT I.Sifra,I.Naziv,FORMAT(I.DatumPolaska,'dd.MM.yyyy') AS DatumPolaska,FORMAT(I.DatumPovratka,'dd.MM.yyyy')as DatumPovratka,I.Cijena,COUNT(P.PrijaveID) as BrojPrijava,SUM(P.BrojOdraslih) as BrojOdraslih,SUM(P.BrojDjece) as BrojDjece
FROM Izleti AS I INNER JOIN Prijave AS P ON P.IzletID=I.IzletID
GROUP BY I.Sifra,I.Naziv,I.DatumPolaska,I.DatumPovratka,I.Cijena
SELECT * FROM viewPregled
/*
7.	Kreirati uskladištenu proceduru koja će na osnovu unesene šifre izleta prikazivati zaradu od izleta i 
to sljedeće kolone: naziv izleta, zarada od odraslih, zarada od djece, ukupna zarada. 
Popust za djecu se obračunava 50% na ukupnu cijenu za djecu. Obavezno testirati ispravnost kreirane procedure.
*/
CREATE PROCEDURE procedura_sifra_zarada
(
	@sifra NVARCHAR(30)
)
AS
BEGIN
	SELECT Naziv,Cijena*BrojOdraslih as ZaradaOdOdraslih,Cijena*BrojDjece-(Cijena*BrojDjece*0.5) as ZaradaOdDjece,
	Cijena*BrojOdraslih+Cijena*BrojDjece-(Cijena*BrojDjece*0.5) as UkupnaZarada
	FROM viewPregled 
	WHERE Sifra=@sifra
END
EXEC procedura_sifra_zarada 'EDF1231230'
select * from viewPregled
/*
8.	a) Kreirati tabelu IzletiHistorijaCijena u koju je potrebno pohraniti identifikator izleta kojem je cijena izmijenjena, 
datum izmjene cijene, staru i novu cijenu. Voditi računa o tome da se jednom izletu može više puta mijenjati
cijena te svaku izmjenu treba zapisati u ovu tabelu.
b) Kreirati trigger koji će pratiti izmjenu cijene u tabeli Izleti te za svaku izmjenu u prethodno
kreiranu tabelu pohraniti podatke izmijeni.
c) Za određeni izlet (proizvoljno) ispisati sljdedeće podatke: naziv izleta, datum polaska, datum povratka, 
trenutnu cijenu te kompletnu historiju izmjene cijena tj. datum izmjene, staru i novu cijenu.
*/

CREATE TABLE IzletiHistorijaCijena
(
	IzletiHistorijaCijenaID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IzletID INT NOT NULL FOREIGN KEY REFERENCES Izleti(IzletID),
	Datum DATETIME NOT NULL,
	StaraCijena DECIMAL(18,2),
	NovaCijena DECIMAL(18,2)
)


CREATE TRIGGER triger_izmjena_cijene
ON Izleti AFTER UPDATE 
AS
INSERT INTO IzletiHistorijaCijena
			(IzletID,Datum,StaraCijena,NovaCijena)
		SELECT d.IzletID,GETDATE(),d.Cijena,I.Cijena FROM deleted as d INNER JOIN inserted AS I on d.IzletID=I.IzletID

		select i.IzletID,i.Cijena,ihc.Datum,ihc.StaraCijena,ihc.NovaCijena from Izleti as i inner join IzletiHistorijaCijena as ihc on i.IzletID=ihc.IzletID
/*9. Obrisati sve klijente koji nisu imali niti jednu prijavu na izlet. */
	DELETE FROM Klijenti  WHERE KlijentID IN  
	(SELECT K.KlijentID FROM Klijenti AS K LEFT JOIN Prijave AS P ON P.KlijentID=K.KlijentID WHERE PrijaveID IS NULL)

	SELECT * FROM Klijenti
/*10. Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup*/

BACKUP DATABASE zadatak2017_treci
TO DISK='C:\BP2\Backup\zadatak2017_treci.bak'
BACKUP DATABASE zadatak2017_treci
TO DISK='C:\BP2\Backup\zadatak2017_treci_dif.bak'
WITH DIFFERENTIAL

