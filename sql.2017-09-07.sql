/*1.
Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea, 
a zatim u svojoj bazi podataka kreirati
tabele sa sljedećom strukturom:
a) Klijenti
i. Ime, polje za unos 50 karaktera (obavezan unos)
ii. Prezime, polje za unos 50 karaktera (obavezan unos)
iii. Grad, polje za unos 50 karaktera (obavezan unos)
iv. Email, polje za unos 50 karaktera (obavezan unos)
v. Telefon, polje za unos 50 karaktera (obavezan unos)
b) Racuni
i. DatumOtvaranja, polje za unos datuma (obavezan unos)
ii. TipRacuna, polje za unos 50 karaktera (obavezan unos)
iii. BrojRacuna, polje za unos 16 karaktera (obavezan unos)
iv. Stanje, polje za unos decimalnog broja (obavezan unos)
c) Transakcije
i. Datum, polje za unos datuma i vremena (obavezan unos)
ii. Primatelj polje za unos 50 karaktera - (obavezan unos)
iii. BrojRacunaPrimatelja, polje za unos 16 karaktera (obavezan unos)
iv. MjestoPrimatelja, polje za unos 50 karaktera (obavezan unos)
v. AdresaPrimatelja, polje za unos 50 karaktera (nije obavezan unos)
vi. Svrha, polje za unos 200 karaktera (nije obavezan unos)
vii. Iznos, polje za unos decimalnog broja (obavezan unos)
Napomena: Klijent može imati više otvorenih računa, dok se svaki račun veže isključivo za jednog klijenta. Sa
računa klijenta se provode transakcije, dok se svaka pojedina�na transakcija provodi sa jednog računa
*/
CREATE DATABASE zadatak_2017_drugi
use zadatak_2017_drugi
go

CREATE TABLE Klijenti
(
	KlijentID INT NOT NULL CONSTRAINT PK_KlijentID PRIMARY KEY IDENTITY(1,1),
	Ime NVARCHAR(50) NOT NULL,
	Prezime NVARCHAR(50) NOT NULL,
	Grad NVARCHAR(50) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	Telefon NVARCHAR(50) NOT NULL,
)
CREATE TABLE Racuni
(
	RacunID INT NOT NULL CONSTRAINT PK_RacunID PRIMARY KEY IDENTITY(1,1),
	KlijentID INT NOT NULL CONSTRAINT FK_KlijentID_Racun FOREIGN KEY (KlijentID) REFERENCES Klijenti(KlijentID),
	DatumOtvaranja DATETIME NOT NULL,
	TipRacuna NVARCHAR(50) NOT NULL,
	BrojRacuna NVARCHAR(16) NOT NULL,
	Stanje DECIMAL(18,2) NOT NULL

)
CREATE TABLE Transakcija
(
TransakcijaID INT NOT NULL CONSTRAINT PK_TRANSAKCIJAid PRIMARY KEY IDENTITY(1,1),
RacunID INT NOT NULL CONSTRAINT FK_Racuni_Transakcija FOREIGN KEY (RacunID) REFERENCES Racuni(RacunID),
Datum DATETIME NOT NULL,
Primatelj NVARCHAR(50) NOT NULL,
BrojRacunaPrimatelja NVARCHAR(16) NOT NULL,
MjestoPrimatelja NVARCHAR(50) NOT NULL,
AdresaPrimatelja NVARCHAR(50),
Svrha NVARCHAR(200),
Iznos DECIMAL(18,2) NOT NULL
)
/*2.Nad poljem Email u tabeli Klijenti, te BrojRacuna u tabeli Racuni kreirati unique index.*/

CREATE UNIQUE NONCLUSTERED INDEX ix_email_KLIJENT
ON Klijenti(Email)

CREATE UNIQUE NONCLUSTERED INDEX ix_brojRacuna_RACUNI
ON Racuni(BrojRacuna)
/*3.Kreirati uskladištenu proceduru za unos novog računa. Obavezno provjeriti ispravnost kreirane procedure.*/

ALTER PROCEDURE procedura_unos_racuna
(
@KlijentID INT,@Datum DATETIME,@TipRacuna NVARCHAR(50),@BrojRacuna NVARCHAR(16),@Stanje DECIMAL(18,2)
)
AS 
BEGIN
INSERT INTO Racuni
VALUES(@KlijentID,@Datum,@TipRacuna,@BrojRacuna,@Stanje)
END
INSERT INTO Klijenti
VALUES('Admir','Numanovic','Mostar','admir_numanovic@hotmail.com','062-745-148')
DECLARE @VARIJABLA DATETIME;
SET @VARIJABLA=GETDATE();
EXEC procedura_unos_racuna 1,@VARIJABLA,'Studentski','1231231231231233',1000
SELECT * FROM Racuni

SELECT CAST(GETDATE() AS NVARCHAR(40)) AS A
SELECT CAST('Jun 21 2020 2:36AM' AS DATETIME)
SELECT GETDATE() AS B

CREATE TYPE ADMIR
FROM NVARCHAR(30) NOT NULL;
GO


/*4.
 Iz baze podataka Northwind u svoju bazu podataka prebaciti sljede�e podatke:
a) U tabelu Klijenti prebaciti sve kupce koji su obavljali narud�be u 1996. godini
i. ContactName (do razmaka) -> Ime
ii. ContactName (poslije razmaka) -> Prezime
iii. City -> Grad
iv. ContactName@northwind.ba -> Email (Izme�u imena i prezime staviti ta�ku)
v. Phone -> Telefon
b) Koriste�i prethodno kreiranu proceduru u tabelu Racuni dodati 10 računa za razli�ite kupce
(proizvoljno). Odre�enim kupcima pridru�iti vi�e računa.
c) Za svaki prethodno dodani račun u tabelu Transakcije dodati po 10 transakcija. Podatke za tabelu
Transakcije preuzeti RANDOM iz Northwind baze podataka i to po�tuju�i sljede�a pravila:
i. OrderDate (Orders) -> Datum
ii. ShipName (Orders) - > Primatelj
iii. OrderID + '00000123456' (Orders) -> BrojRacunaPrimatelja
iv. ShipCity (Orders) -> MjestoPrimatelja,
v. ShipAddress (Orders) -> AdresaPrimatelja,
vi. NULL -> Svrha,
vii. Ukupan iznos narud�be (Order Details) -> Iznos
Napomena (c): ID računa ru�no izmijeniti u podupitu prilikom inserta podataka
*/




INSERT INTO Klijenti (Ime,Prezime,Grad,Email,Telefon)
SELECT SUBSTRING(C.ContactName,0,CHARINDEX(' ',C.ContactName)) as Ime,SUBSTRING(C.ContactName,CHARINDEX(' ',C.ContactName)+1,30) as Prezime,
C.City,SUBSTRING(C.ContactName,0,CHARINDEX(' ',C.ContactName))+'.'+SUBSTRING(C.ContactName,CHARINDEX(' ',C.ContactName)+1,30)+'@northwind.ba',C.Phone
FROM NORTHWND.dbo.Customers AS C

select * from Klijenti
--> b
DECLARE @VARIJABLA DATETIME;
SET @VARIJABLA=GETDATE();
EXEC procedura_unos_racuna 2,@VARIJABLA,'TIP1','1231231231231321',50
EXEC procedura_unos_racuna 3,@VARIJABLA,'TIP2','1231231231231320',100
EXEC procedura_unos_racuna 4,@VARIJABLA,'TIP1','1231231231231323',150
EXEC procedura_unos_racuna 5,@VARIJABLA,'TIP2','1231231231231324',500
EXEC procedura_unos_racuna 6,@VARIJABLA,'TIP1','1231231231231327',600
EXEC procedura_unos_racuna 7,@VARIJABLA,'TIP2','1231231231231351',1250
EXEC procedura_unos_racuna 8,@VARIJABLA,'TIP1','1231231231231352',5000
EXEC procedura_unos_racuna 6,@VARIJABLA,'TIP2','1231231231231353',1250
EXEC procedura_unos_racuna 2,@VARIJABLA,'TIP1','1231231231231361',700
EXEC procedura_unos_racuna 2,@VARIJABLA,'TIP1','1231231231231391',700
SELECT * FROM Racuni

-->C
	DECLARE @TEMP INT;
SET @TEMP=1;
WHILE (@TEMP)<20

BEGIN
INSERT INTO Transakcija
SELECT  TOP 10 
	@TEMP,
	O.OrderDate,O.ShipName,O.OrderID+'0000123456',O.ShipCity,O.ShipAddress,NULL,SUM(OD.Quantity)*OD.UnitPrice 
	FROM NORTHWND.dbo.Orders as O INNER JOIN NORTHWND.dbo.[Order Details] AS OD ON O.OrderID=OD.OrderID
	WHERE @TEMP=(SELECT RacunID FROM Racuni WHERE RacunID=@TEMP AND RacunID IS NOT NULL)
	GROUP BY O.OrderDate,O.ShipName,O.OrderID+'0000123456',O.ShipCity,O.ShipAddress,OD.UnitPrice
	ORDER BY NEWID()
	SET @TEMP=@TEMP+1
END
SELECT * FROM Transakcija


/*5.
 Svim računima �iji vlasnik dolazi iz Londona, a koji su otvoreni u 8. mjesecu, stanje uve�ati za 500. Grad i mjesec
se mogu proizvoljno mijenjati kako bi se rezultat komande prilagodio vlastitim podacima
*/
UPDATE Racuni
SET Stanje+=500
WHERE RacunID IN (SELECT RacunID FROM Racuni AS R INNER JOIN Klijenti AS K ON R.RacunID=K.KlijentID WHERE K.Grad='Mostar' AND MONTH(R.DatumOtvaranja)=9)
select * from Racuni AS R INNER JOIN Klijenti  AS K ON R.KlijentID=K.KlijentID 
SELECT * FROM Racuni
/*6.
Kreirati view (pogled) koji prikazuje ime i prezime (spojeno), grad, email i telefon klijenta, zatim tip računa, broj
računa i stanje, te za svaku transakciju primatelja, broj računa primatelja i iznos. Voditi računa da se u rezultat
uklju�e i klijenti koji nemaju otvoren niti jedan račun
*/
CREATE VIEW viewPregledSvega
as
SELECT K.Ime+' '+K.Prezime AS ImePrezime,K.Grad as Grad,K.Email as Email,K.Telefon as Telefon,R.TipRacuna as TipRacuna,R.BrojRacuna as BrojRacuna,R.Stanje as Stanje,T.BrojRacunaPrimatelja as BrojRacunaPrimatelja,T.Iznos as Iznos
FROM Klijenti AS K LEFT JOIN Racuni AS R ON K.KlijentID=R.RacunID LEFT JOIN Transakcija AS T ON T.RacunID=R.RacunID
select * from viewPregledSvega
SELECT * FROM Transakcija

/*7.
Kreirati uskladištenu proceduru koja će na osnovu proslijeđenog broja računa klijenta prikazati podatke o
vlasniku računa (ime i prezime, grad i telefon), broj i stanje računa te ukupan iznos transakcija provedenih sa
računa. Ukoliko se ne proslijedi broj računa, potrebno je prikazati podatke za sve račune. Sve kolone koje
prikazuju NULL vrijednost formatirati u 'N/A'. U proceduri koristiti prethodno kreirani view. Obavezno provjeriti
ispravnost kreirane procedure
*/
CREATE PROCEDURE procedura_podaci_brojRacuna
(@BrojRacuna NVARCHAR(30)=NULL)
as
BEGIN
	SELECT ImePrezime,Grad,Telefon,ISNULL(BrojRacuna,'N/A'),ISNULL(CAST(Stanje AS NVARCHAR(30)),'N/A'),ISNULL(CAST(SUM(Iznos) AS NVARCHAR(30)),'N/A' )FROM viewPregledSvega 
	WHERE (BrojRacuna = @BrojRacuna) or (@BrojRacuna IS NULL)
	GROUP BY ImePrezime,Grad,Telefon,BrojRacuna,Stanje
END
DROP PROCEDURE procedura_podaci_brojRacuna
EXEC procedura_podaci_brojRacuna '1231231231231231'

/*8.
Kreirati uskladištenu proceduru koja će na osnovu unesenog identifikatora klijenta vršiti brisanje klijenta
uključujući sve njegove račune zajedno sa transakcijama. Obavezno provjeriti ispravnost kreirane procedure
*/
CREATE PROCEDURE procedura_brisanja_podataka
(@indeks int )
as
BEGIN
DELETE FROM Transakcija WHERE RacunID IN (SELECT RacunID FROM Racuni WHERE KlijentID=@indeks)
DELETE FROM Racuni  WHERE KlijentID =@indeks 
    
DELETE FROM Klijenti WHERE KlijentID=@indeks
END
EXEC procedura_brisanja_podataka 3
SELECT * FROM Transakcija
SELECT * FROM Racuni
SELECT * FROM Klijenti
DROP PROCEDURE procedura_brisanja_podataka
/*9.
Komandu iz zadatka 5. pohraniti kao proceduru a kao parametre proceduri proslijediti naziv grada, mjesec i iznos
uvečanja računa. Obavezno provjeriti ispravnost kreirane procedure
*/
CREATE PROCEDURE procedura_komadna_zadatka5
(
	@naziv_Grada NVARCHAR(30),
	@MJESEC INT,
	@Iznos DECIMAL(18,2)

)
AS
BEGIN
UPDATE Racuni
SET Stanje+=@Iznos
WHERE RacunID IN (SELECT RacunID FROM Racuni AS R INNER JOIN Klijenti AS K ON R.RacunID=K.KlijentID WHERE K.Grad=@naziv_Grada AND MONTH(R.DatumOtvaranja)=@MJESEC)
END
SELECT * FROM Racuni
EXEC procedura_komadna_zadatka5 'Mostar',9,500


/*10. Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup*/

BACKUP DATABASE zadatak_2017_drugi
TO DISK= 'zadatak_2017_drugi.bak'

BACKUP DATABASE zadatak_2017_drugi 
TO DISK='zadatak_2017_drugi_dif.bak'
with differential
