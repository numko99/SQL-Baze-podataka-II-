/*
1.	Kroz SQL kod,naparaviti bazu podataka koja nosi ime vaseg broja dosijea sa default postavkama
*/
CREATE DATABASE zadatak_2018_prvi

/*
2.	Unutar svoje baze kreirati tabele sa sljedecom strukutrom
Autori
-	AutorID 11 UNICODE karaltera i primarni kljuc
-	Prezime 25 UNICODE karaktera (obavezan unos)
-	Ime 25 UNICODE karaktera (obavezan unos)
-	Telefon 20 UNICODE karaktera DEFAULT je NULL
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
*/

CREATE TABLE Autori
(
	AutorID NVARCHAR(11) CONSTRAINT PK_AutorID PRIMARY KEY,
	Prezime NVARCHAR(25) NOT NULL,
	Ime NVARCHAR(25) NOT NULL,
	Telfon NVARCHAR(20) DEFAULT NULL,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)

/*
Izdavaci 
-	IzdavacID 4 UNICODE karaktera i primarni kljuc
-	Naziv 100 UNICODE karaktera(obavezan unos),jedinstvena vrijednost
-	Biljeske 1000 UNICODE karaktera DEFAULT tekst je Lorem ipsum
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
*/
CREATE TABLE Izdavaci
(
	IzdavacID NVARCHAR(4) CONSTRAINT PK_IzdavacID PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL UNIQUE,
	Biljeske NVARCHAR(1000) DEFAULT 'Lorem ipsum',
	 DatumKreiranjaZapisa DATE DEFAULT GETDATE() NOT NULL,
     DatumModifikovanjaZapisa DATE DEFAULT NULL 

)
/*
Naslovi
-	NaslovID 6 UNICODE karaktera i primarni kljuc
-	IzdavacID ,spoljni kljuc prema tabeli Izdavaci
-	Naslov 100 UNICODE karaktera (obavezan unos)
-	Cijena monetarni tip
-	DatumIzdavanja datumska vraijabla (obavezan unos) DEFAULT datum unosa zapisa
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
*/
CREATE TABLE Naslovi 
(
NaslovID NVARCHAR(6) CONSTRAINT PK_NaslovID PRIMARY KEY,
IzdavacID NVARCHAR(4)CONSTRAINT FK_Izdavac FOREIGN KEY (IzdavacID) REFERENCES Izdavaci(IzdavacID),
Naslov NVARCHAR(100) NOT NULL,
Cijena MONEY NOT NULL,
DatumIzdavanja DATE NOT NULL DEFAULT GETDATE(),
DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
DatumModifikovanjaZapisa DATE DEFAULT NULL
)
alter table Naslovi
ADD  Cijena MONEY


/*
NasloviAutori
-	AutorID ,spoljni kljuc prema tabeli Autori
-	NaslovID ,spoljni kljuc prema tabeli Naslovi
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
*/

CREATE TABLE NasloviAutori
(
	AutorID NVARCHAR(11) CONSTRAINT FK_Autor FOREIGN KEY REFERENCES Autori(AutorID),
	NaslovID NVARCHAR(6) CONSTRAINT FK_NaslovID FOREIGN KEY REFERENCES Naslovi(NaslovID),
	CONSTRAINT PK_AUTOR_NASLOV PRIMARY KEY(AutorID,NaslovID),
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)

/*
2b. Generisati testne podatke i obavezno testirati da li su podaci u tabeli za svaki korak posebno:
-	Iz baze podataka pubs tabela authors,  putem podupita u tabelu Autori importovati sve slucajno sortirane zapise.
Vodite racuna da mapirate odgovarajuce kolone.
-	Iz baze podataka pubs i tabela publishers i pub_info , a putem podupita u tabelu Izdavaci importovati
sve slucajno sortirane zapise.Kolonu pr_info mapirati kao biljeske i iste skratiti na 100 karaktera.
Vodte racuna da mapirate odgovarajuce kolone
-	Iz baze podataka pubs tabela titles ,a putem podupita u tablu Naslovi importovati sve zapise.
Vodite racuna da mapirate odgvarajuce kolone
-	Iz baze podataka pubs tabela titleauthor, a putem podupita u tabelu NasloviAutori importovati zapise.
Vodite racuna da mapirate odgovrajuce koloone
*/
select * from pubs.dbo.authors
INSERT INTO Autori (AutorID,Prezime,Ime,Telfon)
SELECT A.au_id,A.au_lname,A.au_fname,A.phone FROM pubs.dbo.authors AS A
ORDER BY NEWID()

INSERT INTO Izdavaci (IzdavacID,Naziv,Biljeske)
SELECT P.pub_id,P.pub_name,SUBSTRING(PUB.pr_info,0,100) FROM pubs.dbo.publishers AS P INNER JOIN pubs.dbo.pub_info AS PUB ON P.pub_id=PUB.pub_id
ORDER BY NEWID()

INSERT INTO Naslovi (NaslovID,IzdavacID,Naslov,Cijena,DatumIzdavanja)
SELECT title_id,pub_id,title,price,pubdate FROM pubs.dbo.titles
SELECT * FROM Naslovi

INSERT INTO NasloviAutori (AutorID,NaslovID)
SELECT au_id,title_id FROM pubs.dbo.titleauthor
/*
2c. Kreiranje nove tabele,importovanje podataka i modifikovanje postojece tabele:
     Gradovi
-	GradID ,automatski generator vrijednosti cija je pocetna vrijednost je 5 i uvrcava se za 5,primarni kljuc
-	Naziv 100 UNICODE karaktera (obavezan unos),jedinstvena vrijednost
-	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
-	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
-	Iz baze podataka pubs tebela authors a putem podupita u tablelu Gradovi imprtovati nazive gradova bez duplikata
-	Modifikovati tabelu Autori i dodati spoljni kljuc prema tabeli Gradovi
*/

CREATE TABLE Gradovi
(
	GradID INT NOT NULL CONSTRAINT PK_GRADID PRIMARY KEY IDENTITY(5,5),
	Naziv NVARCHAR(100) NOT NULL UNIQUE,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL,
)
INSERT INTO Gradovi(Naziv)
SELECT DISTINCT city FROM pubs.dbo.authors

ALTER TABLE Autori
add Grad INT FOREIGN KEY REFERENCES Gradovi(GradID)
/*
2d. Kreirati dvije uskladistene procedure koja ce modifikovati podatke u tabelu Autori
-	Prvih deset autora iz tabele postaviti da su iz grada : San Francisco
-	Ostalim autorima podesiti grad na : Berkeley
*/

CREATE PROCEDURE procedura_postavljanja_grada
as
BEGIN
UPDATE Autori
SET Grad=(SELECT GradID FROM Gradovi WHERE Naziv LIKE 'San Francisco')
WHERE AutorID IN (SELECT TOP 10 AutorID FROM Autori)
END

EXEC procedura_postavljanja_grada

CREATE PROCEDURE procedura_postavljanja_grada2
as
BEGIN
UPDATE Autori
SET Grad=(SELECT GradID FROM Gradovi WHERE Naziv LIKE 'Berkeley')
WHERE AutorID NOT IN (SELECT TOP 10 AutorID FROM Autori)
END
EXEC procedura_postavljanja_grada2
SELECT * FROM Autori


/*
3.	Kreirati pogled sa seljdeceom definicijom: Prezime i ime autora (spojeno),grad,naslov,cijena,izdavac i
biljeske ali samo one autore cije knjige imaju odredjenu cijenu i gdje je cijena veca od 10.
Takodjer naziv izdavaca u sredini imena treba ima ti slovo & i da su iz grada San Francisco.Obavezno testirati funkcijonalnost
*/
CREATE VIEW viewSve
as
SELECT A.Ime+' '+A.Prezime AS ImePrezime,G.Naziv as Grad,N.Naslov,N.Cijena,IZ.Naziv as Izdavac,IZ.Biljeske
FROM Autori AS A 
INNER JOIN Gradovi AS G ON G.GradID=A.Grad 
INNER JOIN NasloviAutori AS NA ON NA.AutorID=A.AutorID
INNER JOIN Naslovi AS N ON N.NaslovID=NA.NaslovID
INNER JOIN Izdavaci AS IZ ON IZ.IzdavacID=N.IzdavacID
WHERE (N.Cijena IS NOT NULL AND N.Cijena>10) AND (A.Grad IN (SELECT GradID FROM Gradovi WHERE Naziv LIKE 'San Francisco')) AND
 IZ.Naziv LIKE '%&%'
 SELECT * FROM viewSve
/*
4.	Modifikovati tabelu autori i dodati jednu kolonu:
-	Email,polje za unos 100 UNICODE kakraktera ,DEFAULT je NULL
*/

ALTER TABLE Autori
ADD Email NVARCHAR(100) DEFAULT NULL
/*
5.	Kreirati dvije uskladistene procedure koje ce modifikovati podatke u tabeli Autori i svim autorima generisati novu email adresu:
-	Prva procedura u formatu Ime.Prezime@fit.ba svim autorima iz grada San Francisco
-	Druga procedura u formatu Prezime.ime@fit.ba svim autorima iz grada Berkeley
*/

CREATE PROCEDURE procedura_mail
as
BEGIN
UPDATE Autori
SET Email= Ime+'.'+Prezime+'@fit.ba'
where Grad in (SELECT GradID FROM Gradovi WHERE Naziv LIKE 'San Francisco')
END
exec procedura_mail

CREATE PROCEDURE procedura_mail2
as
BEGIN
UPDATE Autori
SET Email= Prezime+'.'+Ime+'@fit.ba'
where Grad in (SELECT GradID FROM Gradovi WHERE Naziv LIKE 'Berkeley')
END
exec procedura_mail2
select * from Autori
/*
6.	Iz baze podataka AdventureWorks2014 u lokalnu,privremenu,tabelu u vasu bazu podataka imoportovati zapise o osobama ,
a putem podupita. Lista kolona je Title,LastName,FirstName,
EmailAddress,PhoneNumber,CardNumber.
Kreirati dvije dodatne kolone UserName koja se sastoji od spojenog imena i prezimena(tacka izmedju) i
kolona Password za lozinku sa malim slovima dugacku 16 karaktera.Lozinka se generise putem SQL funkcije za
slucajne i jednistvene ID vrijednosti.Iz lozinke trebaju biti uklonjene sve crtice '-' i zamjenjene brojem '7'.
Uslovi su da podaci ukljucuju osobe koje imaju i nemaju kreditanu karticu, a 
NULL vrijesnot u koloni Titula treba zamjenuti sa 'N/A'.Sortirati prema prezimenu i imenu.
Testirati da li je tabela sa podacima kreirana
*/
CREATE TABLE #temp
(
	Title NVARCHAR(30),
	LastName NVARCHAR(30),
	FirstName NVARCHAR(30),
	Email NVARCHAR(60),
	PhoneNumber NVARCHAR(60),
	CardNumber NVARCHAR(60),
	UserName NVARCHAR(60),
	Pasword NVARCHAR(60)
)
select * from #temp
drop table #temp
INSERT INTO #temp (Title,LastName,FirstName,Email,PhoneNumber,CardNumber,UserName,Pasword)
select ISNULL(p.Title,'N/A'),p.LastName,p.FirstName,em.EmailAddress,ph.PhoneNumber,cc.CardNumber,p.FirstName+'.'+p.LastName as UserName, REPLACE(LEFT(NEWID(),16),'-',7) AS Lozinka
from AdventureWorks2014.Person.Person as p 
inner join AdventureWorks2014.Person.BusinessEntity as be on p.BusinessEntityID=be.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as em on em.BusinessEntityID=p.BusinessEntityID
inner join AdventureWorks2014.Person.PersonPhone as ph on ph.BusinessEntityID=p.BusinessEntityID
inner join AdventureWorks2014.Sales.PersonCreditCard as pcc on pcc.BusinessEntityID=p.BusinessEntityID
inner join AdventureWorks2014.Sales.CreditCard as cc on cc.CreditCardID=pcc.CreditCardID
ORDER BY p.FirstName,p.LastName

/*
7.	Kreirati indeks koji ce nad privremenom tabelom iz prethodnog koraka,primarno,maksimalno 
ubrzati upite koje koriste kolonu UserName,a sekundarno nad kolonama LastName i FirstName.Napisati testni upit
*/
	CREATE NONCLUSTERED INDEX ix_username
	ON #temp(UserName)
	INCLUDE(LastName,FirstName)

	select UserName from #temp 
	where LastName LIKE 'Murphy' and FirstName LIKE 'Anna'
/*
8.	Kreirati uskladistenu proceduru koja brise sve zapise iz privremen tabele koje nemaju kreditnu karticu.
Obavezno testirati funkcjionalnost
*/
CREATE PROCEDURE procedura_brisanja
as
BEGIN
DELETE from #temp where CardNumber IS NULL
END
EXEC procedura_brisanja
/*
9.	Kreirati backup vase baze na default lokaciju servera i nakon toga obrisati privremenu tabelu
*/
	BACKUP DATABASE zadatak_2018_prvi
	TO DISK ='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\zadatak_2018_prvi.bak' 
	drop table #temp
/*
10.	Kreirati proceduru koja brise sve zapise i svih tabela unutar jednog izvrsenja.Testirati da li su podaci obrisani
*/
CREATE PROCEDURE brisanje_podataka
as
begin
DELETE FROM NasloviAutori
DELETE FROM Autori
DELETE FROM Naslovi
DELETE FROM Gradovi
DELETE FROM Izdavaci
end
exec brisanje_podataka
SELECT * FROM Izdavaci