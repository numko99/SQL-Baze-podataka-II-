/*
1. Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. U postupku kreiranja u
obzir uzeti samo DEFAULT postavke.
Unutar svoje baze podataka kreirati tabelu sa sljedećom strukturom:
a) Proizvodi:
I. ProizvodID, automatski generatpr vrijednosti i primarni ključ
II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
IV. Cijena, polje za unos decimalnog broja (obavezan unos)
b) Skladista
I. SkladisteID, automatski generator vrijednosti i primarni ključ
II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)
c) SkladisteProizvodi
I) Stanje, polje za unos decimalnih brojeva (obavezan unos)
Napomena: Na jednom skladištu može biti uskladišteno više proizvoda, dok isti proizvod može biti
uskladišten na više različitih skladišta. Onemogućiti da se isti proizvod na skladištu može pojaviti više
puta
*/
CREATE DATABASE IB180063 

USE IB180063
GO

CREATE TABLE Proizvodi
(
	ProizvodID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Sifra NVARCHAR(10) NOT NULL UNIQUE NONCLUSTERED,
	Naziv NVARCHAR(50) NOT NULL,
	Cijena DECIMAL NOT NULL
)
ALTER TABLE Proizvodi
ALTER COLUMN Cijena Decimal(18,2) NOT NULL


CREATE TABLE Skladista
(
	SkladisteID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Naziv NVARCHAR(50) NOT NULL,
	Oznaka NVARCHAR(10) NOT NULL UNIQUE NONCLUSTERED,
	Lokacija NVARCHAR(50) NOT NULL,
)

CREATE TABLE SkladisteProizvodi
(
	SkladisteID INT NOT NULL FOREIGN KEY(SkladisteID) REFERENCES Skladista(SkladisteID),
	ProizvodID INT NOT NULL FOREIGN KEY(ProizvodID) REFERENCES Proizvodi(ProizvodID),
	Stanje Decimal(18,2) NOT NULL,
	PRIMARY KEY(SkladisteID,ProizvodID)

)

/*
2. Popunjavanje tabela podacima
a) Putem INSERT komande u tabelu Skladista dodati minimalno 3 skladišta.
b) Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
10 najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljedeće kolone:
I. Broj proizvoda (ProductNumber) - > Sifra,
II. Naziv bicikla (Name) -> Naziv,
III. Cijena po komadu (ListPrice) -> Cijena,
c) Putem INSERT i SELECT komandi u tabelu SkladisteProizvodi za sva dodana skladista
importovati sve proizvode tako da stanje bude 100
*/

	INSERT INTO Skladista (Naziv,Oznaka,Lokacija) VALUES ('Skladiste1','abc123','Ulica Ivana Krndelja Mostar');
	INSERT INTO Skladista  VALUES ('Skladiste2','cde657','Ulica Marsala Tita Mostar');
	INSERT INTO Skladista  VALUES ('Skladiste3','efg789','Ulica Alije Izetbegovica Sarajevo');

	SELECT * FROM Skladista

	INSERT INTO Proizvodi (Naziv,Sifra,Cijena)
	SELECT TOP 10 P.Name,P.ProductNumber,P.ListPrice FROM AdventureWorks2014.Production.Product as P
											INNER JOIN AdventureWorks2014.Production.ProductSubcategory as PS
											ON P.ProductSubcategoryID=PS.ProductCategoryID
											INNER JOIN AdventureWorks2014.Production.ProductCategory AS PC
											ON PC.ProductCategoryID = PS.ProductCategoryID
											INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail AS SOD
											ON SOD.ProductID=P.ProductID
	WHERE PC.Name Like'%Bikes%'
	GROUP BY P.Name,P.ProductNumber,P.ListPrice
	ORDER BY SUM(SOD.OrderQty) DESC

	SELECT * FROM Proizvodi

	
INSERT INTO SkladisteProizvodi (ProizvodID,SkladisteID,Stanje)
SELECT ProizvodID ,(SELECT SkladisteID FROM Skladista where SkladisteID=1),100
from Proizvodi
union
SELECT ProizvodID ,(SELECT SkladisteID FROM Skladista where SkladisteID=2),100
from Proizvodi
union
SELECT ProizvodID ,(SELECT SkladisteID FROM Skladista where SkladisteID=3),100
from Proizvodi
select * from SkladisteProizvodi

/*3.
Kreirati uskladištenu proceduru koja će vršiti povečanje stanja skladišta za određeni proizvod na
odabranom skladištu. Provjeriti ispravnost procedure.
*/
CREATE PROCEDURE procedura_povecavanje_skladista
(
	@SkladisteID int,
	@ProizvodID	 int,
	@Povecavanje int
)
AS  
UPDATE [SkladisteProizvodi]
SET Stanje +=@Povecavanje
WHERE SkladisteID=@SkladisteID and ProizvodID=@ProizvodID

exec procedura_povecavanje_skladista 1,2,5


/*4.
 Kreiranje indeksa u bazi podataka nad tabelama
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Također,
potrebno je uključiti kolonu Cijena
b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks iz
prethodnog koraka
c) Uradite disable indeksa iz koraka a)
*/

CREATE NONCLUSTERED INDEX ix_Sifra_Naziv
ON Proizvodi (Sifra,Naziv)
INCLUDE (Cijena)

SELECT Sifra,Naziv
from Proizvodi
where Cijena>2000

ALTER INDEX ix_Sifra_Naziv ON Proizvodi
Disable;
/*
5. Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje sifru, naziv i cijenu proizvoda,
oznaku, naziv i lokaciju skladišta, te stanje na skladištu.
*/
CREATE VIEW view_Skladista_Proizvodi
AS
SELECT P.Sifra AS SifraProizvda,P.Naziv as NazivProizvoda,P.Cijena as CijenaProizvoda,S.Oznaka as OznakaSkladista,S.Naziv as NazivSkladista,S.Lokacija as LokacijaSkladista,SP.Stanje as Stanje
		FROM Skladista AS S INNER JOIN SkladisteProizvodi AS SP ON S.SkladisteID=SP.SkladisteID
							 INNER JOIN Proizvodi AS P ON SP.ProizvodID=P.ProizvodID
select * from view_Skladista_Proizvodi
/*6.
 Kreirati uskladištenu proceduru koja će na osnovu unesene šifre proizvoda prikazati ukupno stanje
zaliha na svim skladištima. U rezultatu prikazati sifru, naziv i cijenu proizvoda te ukupno stanje zaliha.
U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane procedure.
*/
	CREATE PROCEDURE procedura_Sifra_Zalihe
	(
		@sifra nvarchar(30)
	)
	as
	select SifraProizvda,NazivProizvoda,CijenaProizvoda,Stanje from view_Skladista_Proizvodi 
	where SifraProizvda=@sifra

	exec procedura_Sifra_Zalihe 'BK-M68B-38'
/*7.
. Kreirati uskladištenu proceduru koja će vršiti upis novih proizvoda, te kao stanje zaliha za uneseni
proizvod postaviti na 0 za sva skladišta. Provjeriti ispravnost kreirane procedure.
*/
	CREATE PROCEDURE procedura_upis_proizvoda
	(
	@sifra nvarchar(30),
	@naziv nvarchar(30),
	@cijena Decimal(18,2)
	)
	as
	BEGIN
	Insert INTO Proizvodi
	values (@sifra,@naziv,@cijena)

	INSERT INTO SkladisteProizvodi
	SELECT SkladisteID, (SELECT ProizvodID FROM Proizvodi where (Sifra = @sifra) AND (Naziv =@naziv) AND (Cijena=@cijena)),0
	FROM Skladista
	END	
	exec procedura_upis_proizvoda 'hop123','novo biciklo',18
	select * from Proizvodi
	select * from SkladisteProizvodi
/*8.
 Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda vršiti brisanje proizvoda
uključuju�i stanje na svim skladištima. Provjeriti ispravnost procedure.
*/
	CREATE PROCEDURE prcedura_brisanje_prozivoda
	(@sifra nvarchar(30))
	as
	BEGIN
	DELETE FROM SkladisteProizvodi WHERE ProizvodID IN (SELECT ProizvodID FROM Proizvodi WHERE Sifra=@sifra)
	DELETE FROM Proizvodi WHERE Sifra=@sifra
	
	END
	SELECT * FROM Proizvodi WHERE Sifra='hop123'
	SELECT * FROM SkladisteProizvodi WHERE ProizvodID=15

	EXEC prcedura_brisanje_prozivoda 'hop123'
/*9.
 Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda, oznaku skladišta ili lokaciju
skladišta vršiti pretragu prethodno kreiranim view-om (zadatak 5). Procedura obavezno treba da
vraća rezultate bez obrzira da li su vrijednosti parametara postavljene. Testirati ispravnost procedure
u sljedećim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra šifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra šifra proizvoda i oznaka skladišta, a lokacija
nije
d) Postavljene su vrijednosti parametara šifre proizvoda i lokacije, a oznaka skladišta
nije
e) Postavljene su vrijednosti sva tri parametra
*/
CREATE PROCEDURE procedura_sifra_oznaka_lokacija
(
	@sifra nvarchar(30) = null,
	@oznaka nvarchar(30)=null,
	@lokacija nvarchar(30) = null
)
as
SELECT * FROM view_Skladista_Proizvodi
		where (SifraProizvda=@sifra or @sifra IS NULL) 
				AND (OznakaSkladista=@oznaka OR @oznaka IS NULL) 
				AND (LokacijaSkladista = @lokacija OR @lokacija IS NULL)
exec procedura_sifra_oznaka_lokacija 
exec procedura_sifra_oznaka_lokacija 'BK-M68B-38'
exec procedura_sifra_oznaka_lokacija 'BK-M68B-38','abc123'
exec procedura_sifra_oznaka_lokacija @sifra='BK-M68B-38',@lokacija='Ulica Ivana Krndelja Mostar'
exec procedura_sifra_oznaka_lokacija 'BK-M68B-38','abc123','Ulica Ivana Krndelja Mostar'
/*10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:*/

BACKUP DATABASE IB180063 TO
DISK='IB180063.bak'

BACKUP DATABASE IB180063 TO
DISK='IB180063_diff.bak'
WITH DIFFERENTIAL
select * from Skladista