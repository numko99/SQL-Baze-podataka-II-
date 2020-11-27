/*
1.	Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. 
Fajlove baze podataka smjestiti na sljedeće lokacije:
a)	Data fajl: D:\BP2\Data
b)	Log fajl: D:\BP2\Log
*/

CREATE DATABASE zadatak_prvi_2017
ON PRIMARY
(	
NAME='zadatak_prvi_2017',
FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\zadatak_prvi_2017.mdf'
)
LOG ON 
(
NAME='zadatak_prvi_2017_log',
FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\zadatak_prvi_2017_log.ldf'
)

/*
2.	U svojoj bazi podataka kreirati tabele sa sljedećom strukturom:
a)	Proizvodi
i.	ProizvodID, cjelobrojna vrijednost i primarni ključ
ii.	Sifra, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
iii.	Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
iv.	Kategorija, polje za unos 50 UNICODE karaktera (obavezan unos)
v.	Cijena, polje za unos decimalnog broja (obavezan unos)

b)	Narudzbe
i.	NarudzbaID, cjelobrojna vrijednost i primarni ključ,
ii.	BrojNarudzbe, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
iii.	Datum, polje za unos datuma (obavezan unos),
iv.	Ukupno, polje za unos decimalnog broja (obavezan unos)
c)	StavkeNarudzbe
i.	ProizvodID, cjelobrojna vrijednost i dio primarnog ključa,
ii.	NarudzbaID, cjelobrojna vrijednost i dio primarnog ključa,
iii.	Kolicina, cjelobrojna vrijednost (obavezan unos)
iv.	Cijena, polje za unos decimalnog broja (obavezan unos)
v.	Popust, polje za unos decimalnog broja (obavezan unos)
*/


CREATE TABLE PROIZVODI
(
ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY,
Sifra NVARCHAR(25) NOT NULL UNIQUE NONCLUSTERED,
Naziv NVARCHAR(50) NOT NULL,
Kategorija NVARCHAR(50) NOT NULL,
Cijena DECIMAL(18,2) NOT NULL
)

CREATE TABLE NARUDZBE
(
NarudzbaID INT NOT NULL CONSTRAINT PK_NarudzbaID PRIMARY KEY,
BrojNarudzbe NVARCHAR(25) NOT NULL UNIQUE NONCLUSTERED,
Datum DATETIME NOT NULL,
Ukupno DECIMAL NOT NULL
)

CREATE TABLE STAVKE_NARUDZBE
(
ProizvodID INT NOT NULL CONSTRAINT FK_STAVKE_NARUDZBE_ProizvodID  FOREIGN KEY(ProizvodID) REFERENCES PROIZVODI(ProizvodID),
NarudzbaID INT NOT NULL CONSTRAINT FK_STAVKE_NARUDZBE_NarudzbaID  FOREIGN KEY(NarudzbaID) REFERENCES NARUDZBE(NarudzbaID),
CONSTRAINT PK_STAVKE_NARUDZBE PRIMARY KEY(ProizvodID,NarudzbaID),
Kolicina INT NOT NULL,
Cijena DECIMAL(18,2) NOT NULL,
Popust DECIMAL(18,2) NOT NULL,
Iznos DECIMAL(18,2) NOT NULL
)

/*
3.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeće podatke:
a)	U tabelu Proizvodi dodati sve proizvode koji su prodavani u 2014. godini
i.	ProductNumber -> Sifra
ii.	Name -> Naziv
iii.	ProductCategory (Name) -> Kategorija
iv.	ListPrice -> Cijena
b)	U tabelu Narudzbe dodati sve narudžbe obavljene u 2014. godini
i.	SalesOrderNumber -> BrojNarudzbe
ii.	OrderDate - > Datum
iii.	TotalDue -> Ukupno
c)	U tabelu StavkeNarudzbe prebaciti sve podatke o detaljima narudžbi urađenih u 2014. godini
i.	OrderQty -> Kolicina
ii.	UnitPrice -> Cijena
iii.	UnitPriceDiscount -> Popust
iv.	LineTotal -> Iznos 
	Napomena: Zadržati identifikatore zapisa!	
*/
--> a
INSERT INTO PROIZVODI (ProizvodID,Sifra,Naziv,Kategorija,Cijena)
SELECT DISTINCT P.ProductID, P.ProductNumber,P.Name,PC.Name,P.ListPrice FROM AdventureWorks2014.Production.Product AS P INNER JOIN 
			AdventureWorks2014.Production.ProductSubcategory AS PS ON P.ProductSubcategoryID=PS.ProductSubcategoryID
			INNER JOIN AdventureWorks2014.Production.ProductCategory AS PC ON PS.ProductCategoryID=PC.ProductCategoryID
			INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
			INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
			WHERE DATEPART(YEAR,SOH.OrderDate)=2014
	SELECT * FROM PROIZVODI
--> b
INSERT INTO NARUDZBE
SELECT SOH.SalesOrderID, SOH.SalesOrderNumber,SOH.OrderDate,SOH.TotalDue  FROM AdventureWorks2014.Sales.SalesOrderHeader AS SOH
WHERE DATEPART(YEAR,SOH.OrderDate)=2014
	
--> c 
SELECT * FROM PROIZVODI
SELECT * FROM NARUDZBE
SELECT * FROM STAVKE_NARUDZBE
INSERT INTO STAVKE_NARUDZBE
SELECT ProductID,SOD.SalesOrderID,OrderQty,UnitPrice,UnitPriceDiscount,LineTotal FROM AdventureWorks2014.Sales.SalesOrderDetail AS SOD
																				INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
																				WHERE DATEPART(YEAR,SOH.OrderDate)=2014
/*
4.	U svojoj bazi podataka kreirati novu tabelu Skladista sa poljima SkladisteID i Naziv, 
a zatim je povezati sa tabelom Proizvodi u relaciji više prema više. 
Za svaki proizvod na skladištu je potrebno čuvati količinu (cjelobrojna vrijednost).
*/
CREATE TABLE SKLADISTE 
(
	SkladisteID INT NOT NULL CONSTRAINT PK_SkladisteID PRIMARY KEY IDENTITY(1,1),
	Naziv NVARCHAR(20) NOT NULL
)
CREATE TABLE SkladisteProizvod
(
	SkladisteID INT NOT NULL CONSTRAINT FK_SkladisteID FOREIGN KEY(SkladisteID) REFERENCES SKLADISTE(SkladisteID),
	ProizvodID INT NOT NULL CONSTRAINT FK_Proizvodi FOREIGN KEY(ProizvodID) REFERENCES PROIZVODI(ProizvodID),
	CONSTRAINT PK_SKLADISTE_PRIZVOD PRIMARY KEY(SkladisteID,ProizvodID),
	Kolicina INT NOT NULL
)
SELECT * FROM PROIZVODI AS P INNER JOIN SkladisteProizvod AS SP ON P.ProizvodID=SP.ProizvodID 
							INNER JOIN SKLADISTE AS S ON S.SkladisteID=SP.SkladisteID
/*
5.	U tabelu Skladista  dodati tri skladišta proizvoljno, a zatim za sve proizvode na svim skladištima postaviti količinu na 0 komada.
*/
	INSERT INTO SKLADISTE 
	VALUES ('SKLADISTE 1'),
			('SKLADISTE 2'),
			('SKLADISTE 3')
			select * from SKLADISTE
	INSERT INTO SkladisteProizvod (ProizvodID,SkladisteID,Kolicina)
	SELECT P.ProizvodID,(SELECT S.SkladisteID FROM SKLADISTE AS S WHERE S.SkladisteID=1),0 FROM PROIZVODI AS P
	union
	SELECT P.ProizvodID,(SELECT S.SkladisteID FROM SKLADISTE AS S WHERE S.SkladisteID=2),0 FROM PROIZVODI AS P
	union
	SELECT P.ProizvodID,(SELECT S.SkladisteID FROM SKLADISTE AS S WHERE S.SkladisteID=3),0 FROM PROIZVODI AS P

	select * from SkladisteProizvod
/*
6.	Kreirati uskladištenu proceduru koja vrši izmjenu stanja skladišta (količina).
Kao parametre proceduri proslijediti identifikatore proizvoda i skladišta, te količinu.	
*/
CREATE PROCEDURE procedura_stanje_skladista
(
@proizvodID INT ,@skladisteID INT,@Kolicina INT
)
AS 
BEGIN
UPDATE SkladisteProizvod
SET Kolicina+=@Kolicina
WHERE ProizvodID=@proizvodID AND SkladisteID=@skladisteID
END
EXEC procedura_stanje_skladista 707,1,15
SELECT * FROM SkladisteProizvod

/*
7.	Nad tabelom Proizvodi kreirati non-clustered indeks nad poljima Sifra i Naziv, 
a zatim napisati proizvoljni upit koji u potpunosti iskorištava kreirani indeks. 
Upit obavezno mora sadržavati filtriranje podataka.
*/
CREATE NONCLUSTERED INDEX ix_sifra_naziv 
ON PROIZVODI(Sifra,Naziv)

SELECT Sifra,Naziv FROM PROIZVODI WHERE Sifra Like 'BK%'

/*8.	Kreirati trigger koji će spriječiti brisanje zapisa u tabeli Proizvodi.*/

	CREATE TRIGGER zabranjeno_brisanje
	on
	PROIZVODI INSTEAD OF DELETE 
	as
	BEGIN
	PRINT 'ZABRANJENO BRISANJE PODATAKA '
	ROLLBACK
	END
	DELETE FROM PROIZVODI
/*
9.	Kreirati view koji prikazuje sljedeće kolone: šifru, naziv i cijenu proizvoda, ukupnu prodanu količinu i ukupnu zaradu od prodaje.
*/

	CREATE VIEW viewUkupnaZarada
	as
	SELECT P.Sifra,P.Naziv,P.Cijena,SUM(SN.Kolicina) AS UkupnaKolicina,SUM(SN.Kolicina)*P.Cijena as UkupnaZarada FROM PROIZVODI AS P INNER JOIN STAVKE_NARUDZBE AS SN ON P.ProizvodID=SN.ProizvodID 
	GROUP BY P.Sifra,P.Naziv,P.Cijena
	SELECT * FROM viewUkupnaZarada
/*
10.	Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda prikazivati ukupnu prodanu količinu i ukupnu zaradu.
Ukoliko se ne unese šifra proizvoda procedura treba da prikaže prodaju svih proizovda. U proceduri koristiti prethodno kreirani view.	
*/

	CREATE PROCEDURE procedura_sifra_prodanaKolicina
	(
		@sifra NVARCHAR(20)=NULL
	)
	AS 
	BEGIN 
		SELECT Sifra,UkupnaKolicina,UkupnaZarada FROM viewUkupnaZarada WHERE Sifra=@sifra OR @sifra IS NULL
		
	END
	
	DROP PROCEDURE procedura_sifra_prodanaKolicina
	exec procedura_sifra_prodanaKolicina 'HL-U509-R'
	SELECT * FROM STAVKE_NARUDZBE
	SELECT * FROM PROIZVODI
	SELECT * FROM viewUkupnaZarada
/*
11.	U svojoj bazi podataka kreirati novog korisnika za login student te mu dodijeliti odgovarajuću permisiju
kako bi mogao izvršavati prethodno kreiranu proceduru.
*/
CREATE USER novi FROM LOGIN [DESKTOP-M5NQ84R\Admir]

/*12.	Napraviti full i diferencijalni backup baze podataka na lokaciji D:\BP2\Backup	 */

BACKUP DATABASE zadatak_prvi_2017 to
DISK = 'zadatak_prvi_2017.bak'

BACKUP DATABASE zadatak_prvi_2017 to
DISK = 'zadatak_prvi_2017.bak'
WITH DIFFERENTIAL