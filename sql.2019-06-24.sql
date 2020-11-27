----------------------------------------------------------------1.
/*
Koristeći isključivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
*/
CREATE DATABASE prvi_zadatak2019
ON PRIMARY
(
	NAME ='prvi_zadatak2019.mdf',
	FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\prvi_zadatak2019.mdf',
	SIZE=8MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=10%
)
LOG ON
(
NAME ='prvi_zadatak2019_log.ldf',
	FILENAME='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\prvi_zadatak2019_log.ldf',
	SIZE=8MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=10%
)
USE prvi_zadatak2019
/*
Unutar svoje baze podataka kreirati tabele sa sljedećom struktorom:
--NARUDZBA
a) Narudzba
NarudzbaID, primarni ključ
Kupac, 40 UNICODE karaktera
PunaAdresa, 80 UNICODE karaktera
DatumNarudzbe, datumska varijabla, definirati kao datum
Prevoz, novčana varijabla
Uposlenik, 40 UNICODE karaktera
GradUposlenika, 30 UNICODE karaktera
DatumZaposlenja, datumska varijabla, definirati kao datum
BrGodStaza, cjelobrojna varijabla
*/
CREATE TABLE Narudzba
(	
	NarudzbaID INT CONSTRAINT PK_Narudza PRIMARY KEY,
	Kupac NVARCHAR(40),
	PunaAdresa NVARCHAR(80),
	DatumNarudzbe DATE,
	Prevoz MONEY,
	Uposlenik NVARCHAR(40), 
	GradUposlenika NVARCHAR(30),
	DatumZaposlenja DATE,
	BrGodStaza INT

)

--PROIZVOD
/*
b) Proizvod
ProizvodID, cjelobrojna varijabla, primarni ključ
NazivProizvoda, 40 UNICODE karaktera
NazivDobavljaca, 40 UNICODE karaktera
StanjeNaSklad, cjelobrojna varijabla
NarucenaKol, cjelobrojna varijabla
*/

CREATE TABLE Proizvod
(
	ProizvodID INT CONSTRAINT PK_ProizvodID PRIMARY KEY,
	NazivProizvoda NVARCHAR(40),
	NazivDobavljaca NVARCHAR(40),
	StanjeNaSkladistu INT,
	NarucenaKolicina INT

)
--DETALJINARUDZBE
/*
c) DetaljiNarudzbe
NarudzbaID, cjelobrojna varijabla, obavezan unos
ProizvodID, cjelobrojna varijabla, obavezan unos
CijenaProizvoda, novčana varijabla
Kolicina, cjelobrojna varijabla, obavezan unos
Popust, varijabla za realne vrijednosti
Napomena: Na jednoj narudžbi se nalazi jedan ili više proizvoda.
*/

CREATE TABLE DetaljiNarudzbe
(
	NarudzbaID INT NOT NULL CONSTRAINT FK_NarudzbaID FOREIGN KEY REFERENCES Narudzba(NarudzbaID),
	 ProizvodID INT NOT NULL CONSTRAINT FK_ProizvodID FOREIGN KEY REFERENCES Proizvod(ProizvodID),
	 CONSTRAINT PK_NarudzbaIDProizvodID PRIMARY KEY(NarudzbaID,ProizvodID),
	CijenaProizvoda MONEY,
	Kolicina INT NOT NULL,
	Popust DECIMAL(18,2)
)

----------------------------------------------------------------2.
--2a) narudzbe
/*
Koristeći bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedećem pravilu:
OrderID -> ProizvodID
ComapnyName -> Kupac
PunaAdresa - spojeno adresa, poštanski broj i grad, pri čemu će se između riječi staviti srednja crta sa razmakom prije i poslije nje
OrderDate -> DatumNarudzbe
Freight -> Prevoz
Uposlenik - spojeno prezime i ime sa razmakom između njih
City -> Grad iz kojeg je uposlenik
HireDate -> DatumZaposlenja
BrGodStaza - broj godina od datum zaposlenja
*/
INSERT INTO Narudzba(NarudzbaID,Kupac,PunaAdresa,DatumNarudzbe,Prevoz,Uposlenik,GradUposlenika,DatumZaposlenja,BrGodStaza)
SELECT O.OrderID,C.CompanyName,C.Address+' - '+' '+C.City+' - '+C.PostalCode,O.OrderDate,O.Freight,E.FirstName+' ' +E.LastName,E.City,E.HireDate,YEAR(GETDATE())-YEAR(E.HireDate)
		FROM NORTHWND.dbo.Orders AS O 
		INNER JOIN NORTHWND.dbo.Customers AS C ON C.CustomerID=O.CustomerID
		INNER JOIN NORTHWND.dbo.Employees AS E ON E.EmployeeID=O.EmployeeID

		SELECT * FROM Narudzba
		DELETE FROM Narudzba
--proizvod
/*
Koristeći bazu Northwind iz tabela Products i Suppliers putem podupita importovati podatke po sljedećem pravilu:
ProductID -> ProizvodID
ProductName -> NazivProizvoda 
CompanyName -> NazivDobavljaca 
UnitsInStock -> StanjeNaSklad 
UnitsOnOrder -> NarucenaKol 
*/
	INSERT INTO Proizvod(ProizvodID,NazivProizvoda,NazivDobavljaca,StanjeNaSkladistu,NarucenaKolicina)
	SELECT  P.ProductID,P.ProductName,S.CompanyName,P.UnitsInStock,P.UnitsOnOrder 
	FROM NORTHWND.dbo.Products as P INNER JOIN NORTHWND.dbo.Suppliers as S ON P.SupplierID=S.SupplierID
	
--RJ: 78

--detaljinarudzbe
/*
Koristeći bazu Northwind iz tabele Order Details importovati podatke po sljedećem pravilu:
OrderID -> NarudzbaID
ProductID -> ProizvodID
CijenaProizvoda - manja zaokružena vrijednost kolone UnitPrice, npr. UnitPrice = 3,60 CijenaProizvoda = 3,00
*/
INSERT INTO DetaljiNarudzbe
select DISTINCT OrderID,ProductID,FLOOR(UnitPrice),Quantity,D.Discount from NORTHWND.dbo.[Order Details] AS D

----------------------------------------------------------------3.
--3a
/*
U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. Postaviti uslov da podatak mora biti dužine tačno 15 karaktera.
*/
ALTER TABLE Narudzba
ADD SifraUposlenik NVARCHAR(30) CONSTRAINT CK_Sifra_Uposlenika CHECK(Len(SifraUposlenik)=15)


--3b
/*
Kolonu SifraUposlenika popuniti na način da se obrne string koji se dobije spajanjem grada uposlenika i prvih 10 karaktera datuma zaposlenja pri 
čemu se između grada i 10 karaktera nalazi jedno prazno mjesto. Provjeriti da li je izvršena izmjena.
*/

UPDATE Narudzba
SET SifraUposlenik=LEFT(REVERSE(GradUposlenika+' '+LEFT(DatumZaposlenja,10)),15)
SELECT * FROM Narudzba

--3c
/*
U tabeli Narudzba u koloni SifraUposlenika izvršiti zamjenu svih zapisa kojima grad uposlenika završava slovom "d" tako da se umjesto toga ubaci 
slučajno generisani string dužine 20 karaktera. Provjeriti da li je izvršena zamjena.
*/
ALTER TABLE Narudzba
DROP CONSTRAINT CK_Sifra_Uposlenika
UPDATE Narudzba
SET SifraUposlenik=LEFT(NEWID(),20)
WHERE RIGHT(GradUposlenika,1) LIKE 'd'
----------------------------------------------------------------4.
/*
Koristeći svoju bazu iz tabela Narudzba i DetaljiNarudzbe kreirati pogled koji će imati sljedeću strukturu: Uposlenik, SifraUposlenika, 
ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je dužina sifre uposlenika 20 karaktera, te da je ukupan broj proizvoda veći od 2. 
Provjeriti sadržaj pogleda, pri čemu se treba izvršiti sortiranje po ukupnom broju proizvoda u opadajućem redoslijedu.*/

CREATE VIEW pogled_Uposlenik_sifra
as
SELECT TOP 200 N.Uposlenik,N.SifraUposlenik,COUNT(P.NazivProizvoda) AS ProdatiProizvodi
		FROM Narudzba AS N 
		INNER JOIN DetaljiNarudzbe AS DN ON DN.NarudzbaID=N.NarudzbaID
		INNER JOIN Proizvod AS P ON P.ProizvodID=DN.ProizvodID
		WHERE LEN(N.SifraUposlenik)=20 
		GROUP BY N.Uposlenik,N.SifraUposlenik
		HAVING COUNT(P.NazivProizvoda)>2
		ORDER BY ProdatiProizvodi desc
		
		SELECT * FROM pogled_Uposlenik_sifra
----------------------------------------------------------------5. 
/*
Koristeći vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom će se dužina podatka u koloni SifraUposlenika 
smanjiti sa 20 na 4 slučajno generisana karaktera. Pokrenuti proceduru. */

CREATE PROCEDURE procedura_kraca_sifra
as
BEGIN
UPDATE Narudzba
SET SifraUposlenik=LEFT(NEWID(),4)
WHERE LEN(SifraUposlenik)=20
END
EXEC procedura_kraca_sifra
SELECT * FROM Narudzba
----------------------------------------------------------------6.
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: NazivProizvoda, 
Ukupno - ukupnu sumu prodaje proizvoda uz uzimanje u obzir i popusta. 
Suma mora biti zakružena na dvije decimale. U pogled uvrstiti one proizvode koji su naručeni, uz uslov da je suma veća od 10000. 
Provjeriti sadržaj pogleda pri čemu ispis treba sortirati u opadajućem redoslijedu po vrijednosti sume.
*/
CREATE VIEW pogled_ukupna_suma
as
SELECT  TOP 100 P.NazivProizvoda,ROUND(SUM(Kolicina*CijenaProizvoda*(1-Popust)),2) as Ukupno FROM Proizvod AS P
		INNER JOIN DetaljiNarudzbe AS DN ON DN.ProizvodID=P.ProizvodID
		GROUP BY P.NazivProizvoda
		HAVING SUM(Kolicina*CijenaProizvoda*(1-Popust))>1000
		ORDER BY SUM(Kolicina*CijenaProizvoda*(1-Popust))

		select * from pogled_ukupna_suma

----------------------------------------------------------------7.
--7a
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: Kupac, NazivProizvoda, 
suma po cijeni proizvoda pri čemu će se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda veća od srednje vrijednosti 
cijene proizvoda. Provjeriti sadržaj pogleda pri čemu izlaz treba sortirati u rastućem redoslijedu izračunatoj sumi.
*/
	CREATE VIEW cijenaNaziv
	as
	select Kupac,NazivProizvoda,SUM(DN.CijenaProizvoda) as SumaCijena from Narudzba AS N 
				INNER JOIN DetaljiNarudzbe AS DN ON N.NarudzbaID=DN.NarudzbaID
				INNER JOIN Proizvod AS P ON P.ProizvodID=DN.ProizvodID
				GROUP BY Kupac,NazivProizvoda
				HAVING SUM(DN.CijenaProizvoda)>(SELECT AVG(CijenaProizvoda) FROM DetaljiNarudzbe)

				SELECT * FROM cijenaNaziv
/*
Koristeći vlastitu bazu podataka kreirati proceduru kojom će se, koristeći prethodno kreirani pogled, definirati parametri: kupac,
NazivProizvoda i SumaPoCijeni. Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara
(možemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume bude veća od srednje vrijednosti suma koje
su smještene u pogled. Sortirati po sumi cijene. Procedura se treba izvršiti ako se unese vrijednost za bilo koji parametar.
Nakon kreiranja pokrenuti proceduru za sljedeće vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Côte de Blaye
*/

CREATE PROCEDURE procedura_pogled 
(
	@SumaPoCijeni INT=NULL,
	@Kupas NVARCHAR(30)=NULL,
	@NazivProizvoda NVARCHAR(30)=NULL
)
AS
BEGIN
	SELECT * FROM cijenaNaziv
	WHERE (SumaCijena>(SELECT AVG(SumaCijena) from cijenaNaziv)) 
			AND
			(Kupac LIKE @Kupas or @Kupas IS NULL)
			AND
			(NazivProizvoda LIKE @NazivProizvoda OR @NazivProizvoda IS NULL)
			AND
			( @SumaPoCijeni LIKE SumaCijena
			 OR @SumaPoCijeni IS NULL)
			
END
DROP PROCEDURE procedura_pogled
EXEC procedura_pogled @Kupas='Hanari Carnes'
----------------------------------------------------------------8.
/*
a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. Uključiti i kolone StanjeNaSklad i NarucenaKol. 
Napisati proizvoljni upit nad tabelom Proizvod koji u potpunosti koristi prednosti kreiranog indeksa.*/

create NONCLUSTERED INDEX ix_nezznaziv
ON Proizvod(NazivDobavljaca)
INCLUDE (StanjeNaSkladistu,NarucenaKolicina)

select NazivDobavljaca,StanjeNaSkladistu,NarucenaKolicina
from Proizvod
where StanjeNaSkladistu>5

/*b) Uraditi disable indeksa iz prethodnog koraka.*/

alter index ix_nezznaziv
ON Proizvod
DISABLE;
----------------------------------------------------------------9.
/*Napraviti backup baze podataka na default lokaciju servera.*/

BACKUP DATABASE prvi_zadatak2019
TO DISK='prvi_zadatak2019.bak'

----------------------------------------------------------------10.
/*Kreirati proceduru kojom će se u jednom pokretanju izvršiti brisanje svih pogleda i procedura koji su kreirani u Vašoj bazi.*/

DROP VIEW pogled_ukupna_suma