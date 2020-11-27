/*1.Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea sa default postavkama*/
	 CREATE DATABASE zadatak_2018Drugi
	 use zadatak_2018Drugi 
	 go
/*2.
Unutar svoje baze podataka kreirati tabele sa sljedećem strukturom:
Autori
- AutorID, 11 UNICODE karaktera i primarni ključ
- Prezime, 25 UNICODE karaktera (obavezan unos)
- Ime, 25 UNICODE karaktera (obavezan unos)
- ZipKod, 5 UNICODE karaktera, DEFAULT je NULL
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/

/*
Izdavaci
- IzdavacID, 4 UNICODE karaktera i primarni ključ
- Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
- Biljeske, 1000 UNICODE karaktera, DEFAULT tekst je Lorem ipsum
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/

/*
Naslovi
- NaslovID, 6 UNICODE karaktera i primarni ključ
- IzdavacID, spoljni ključ prema tabeli „Izdavaci“
- Naslov, 100 UNICODE karaktera (obavezan unos)
- Cijena, monetarni tip podatka
- Biljeske, 200 UNICODE karaktera, DEFAULT tekst je The quick brown fox jumps over the lazy dog
- DatumIzdavanja, datum izdanja naslova (obavezan unos) DEFAULT je datum unosa zapisa
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/

/*
NasloviAutori (Više autora može raditi na istoj knjizi)
- AutorID, spoljni ključ prema tabeli „Autori“
- NaslovID, spoljni ključ prema tabeli „Naslovi“
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/
CREATE TABLE Autori
(
	AutorID NVARCHAR(11) CONSTRAINT PK_Autor PRIMARY KEY,
	Prezime NVARCHAR(25) NOT NULL,
	Ime NVARCHAR(25) NOT NULL,
	ZipKod NVARCHAR(5) DEFAULT NULL,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)

CREATE TABLE Izdavaci
(
	IzdavacID NVARCHAR(4) CONSTRAINT PK_IzdavacID PRIMARY KEY,
	Naziv NVARCHAR(100) NOT NULL UNIQUE,
	Biljeske NVARCHAR(1000) NOT NULL DEFAULT 'Lorem ipsum',
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)


CREATE TABLE Naslovi
(
	NaslovID NVARCHAR(6) CONSTRAINT PK_NaslovID PRIMARY KEY,
	IzdavacID NVARCHAR(4) CONSTRAINT FK_IzdavacID FOREIGN KEY REFERENCES Izdavaci(IzdavacID),
	Naslov NVARCHAR(100) NOT NULL UNIQUE,
	Cijena MONEY,
	Biljeske NVARCHAR(200) NOT NULL DEFAULT 'The quick brown fox jumps over the lazy dog',
	DatumIzdavanja DATE NOT NULL DEFAULT GETDATE(),
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)


CREATE TABLE NasloviAutori
(
	AutorID NVARCHAR(11) CONSTRAINT FK_AutorID FOREIGN KEY REFERENCES Autori(AutorID),
	NaslovID NVARCHAR(6) CONSTRAINT FK_NaslovID FOREIGN KEY REFERENCES Naslovi(NaslovID),
	CONSTRAINT PK_NaslovID_AutorID PRIMARY KEY(AutorID,NaslovID),
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)


/*2b
Generisati testne podatake i obavezno testirati da li su podaci u tabelema za svaki korak zasebno :
- Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Autori“ importovati sve slučajno sortirane
zapise. Vodite računa da mapirate odgovarajuće kolone.
- Iz baze podataka pubs i tabela („publishers“ i pub_info“), a putem podupita u tabelu „Izdavaci“ importovati sve
slučajno sortirane zapise. Kolonu pr_info mapirati kao bilješke i iste skratiti na 100 karaktera. Vodite računa da
mapirate odgovarajuće kolone i tipove podataka.
- Iz baze podataka pubs tabela „titles“, a putem podupita u tabelu „Naslovi“ importovati one naslove koji imaju
bilješke. Vodite računa da mapirate odgovarajuće kolone.
- Iz baze podataka pubs tabela „titleauthor“, a putem podupita u tabelu „NasloviAutori“ zapise. Vodite računa da
mapirate odgovarajuće kolone.
*/
select * from Autori
INSERT INTO Autori (AutorID,Prezime,Ime,ZipKod)
SELECT au_id,au_lname,au_fname,zip FROM pubs.dbo.authors
ORDER BY NEWID()
select * from Izdavaci

INSERT INTO Izdavaci (IzdavacID,Naziv,Biljeske)
SELECT p.pub_id,p.pub_name,CAST(PUB.pr_info AS nvarchar(100)) FROM pubs.dbo.publishers as p INNER JOIN pubs.dbo.pub_info AS PUB ON p.pub_id=PUB.pub_id

INSERT INTO Naslovi(NaslovID,IzdavacID,Naslov,Cijena,Biljeske,DatumIzdavanja)
select t.title_id,t.pub_id,t.title,t.price,t.notes,t.pubdate from pubs.dbo.titles as t
where t.notes is not null
select * from Naslovi

insert into NasloviAutori(NaslovID,AutorID)
SELECT title_id,au_id FROM pubs.dbo.titleauthor
/*2c
Kreiranje nove tabele, importovanje podataka i modifikovanje postojeće tabele:
Gradovi
- GradID, automatski generator vrijednosti koji generiše neparne brojeve, primarni ključ
- Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
- Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Gradovi“ importovati nazive gradove bez
duplikata.
- Modifikovati tabelu Autori i dodati spoljni ključ prema tabeli Gradovi:
*/

CREATE TABLE Grad
(
	GradID INT NOT NULL CONSTRAINT PK_GradID PRIMARY KEY IDENTITY(1,2),
	Naziv NVARCHAR(100) NOT NULL UNIQUE,
	DatumKreiranjaZapisa DATE NOT NULL DEFAULT GETDATE(),
	DatumModifikovanjaZapisa DATE DEFAULT NULL
)
INSERT INTO Grad (Naziv)
SELECT distinct city from pubs.dbo.authors

SELECT * FROM Grad

ALTER TABLE Autori
ADD GradID INT  CONSTRAINT FK_GradID FOREIGN KEY REFERENCES Grad(GradID)

/*2d
Kreirati dvije uskladištene proceduru koja će modifikovati podataka u tabeli Autori:
- Prvih pet autora iz tabele postaviti da su iz grada: Salt Lake City
- Ostalim autorima podesiti grad na: Oakland
Vodite računa da se u tabeli modifikuju sve potrebne kolone i obavezno testirati da li su podaci u tabeli za svaku proceduru
posebno.
*/
 CREATE PROCEDURE procedura_dodavanje_gradova5
 as
 BEGIN
	UPDATE Autori
	SET GradID=(SELECT GradID FROM Grad WHERE Naziv LIKE 'Salt Lake City')
	WHERE AutorID IN (SELECT TOP 5 AutorID FROM Autori)
 END
 EXEC procedura_dodavanje_gradova5

 CREATE PROCEDURE procedura_dodavanje_gradova_Ostali
 as
 BEGIN
	UPDATE Autori
	SET GradID=(SELECT GradID FROM Grad WHERE Naziv LIKE 'Oakland')
	WHERE AutorID NOT IN (SELECT TOP 5 AutorID FROM Autori)
 END

 EXEC procedura_dodavanje_gradova_Ostali
 SELECT * FROM Autori

/*3.
Kreirati pogled sa sljedećom definicijom: Prezime i ime autora (spojeno), grad, naslov, cijena, bilješke o naslovu i naziv
izdavača, ali samo za one autore čije knjige imaju određenu cijenu i gdje je cijena veća od 5. Također, naziv izdavača u sredini
imena ne smije imati slovo „&“ i da su iz autori grada Salt Lake City 
*/
CREATE VIEW viewPregled
as
SELECT A.Prezime+' '+A.Ime AS ImePrezime ,G.Naziv AS Grad, N.Naslov,N.Cijena,N.Biljeske,I.Naziv AS Izdavac
FROM Autori AS A 
INNER JOIN Grad AS G ON  G.GradID=A.GradID
INNER JOIN NasloviAutori AS NA ON NA.AutorID=A.AutorID
INNER JOIN Naslovi AS N ON NA.NaslovID=N.NaslovID
INNER JOIN Izdavaci AS I ON I.IzdavacID=N.IzdavacID
WHERE (N.Cijena IS NOT NULL AND N.Cijena>5) AND (I.Naziv NOT LIKE '%&%') AND (A.GradID IN (SELECT GradID FROM Grad WHERE Naziv LIKE 'Salt Lake City' ))

select * from viewPregled

/*4.
Modifikovati tabelu Autori i dodati jednu kolonu:
- Email, polje za unos 100 UNICODE karaktera, DEFAULT je NULL
*/
ALTER TABLE Autori
add Email NVARCHAR(100) DEFAULT NULL

/*5.
Kreirati dvije uskladištene proceduru koje će modifikovati podatke u tabelu Autori i svim autorima generisati novu email
adresu:
- Prva procedura: u formatu: Ime.Prezime@fit.ba svim autorima iz grada Salt Lake City
- Druga procedura: u formatu: Prezime.Ime@fit.ba svim autorima iz grada Oakland
*/

CREATE PROCEDURE mail
as
BEGIN
	UPDATE Autori
	SET Email=Ime+'.'+Prezime+'@fit.ba'
	where GradID = (SELECT GradID FROM Grad WHERE Naziv LIKE 'Salt Lake City' )

END
EXEC mail

CREATE PROCEDURE mail2
as
BEGIN
	UPDATE Autori
	SET Email=Prezime+'.'+Ime+'@fit.ba'
	where GradID = (SELECT GradID FROM Grad WHERE Naziv LIKE 'Oakland' )

END
EXEC mail2
SELECT * FROM Autori

/*6.
z baze podataka AdventureWorks2014 u lokalnu, privremenu, tabelu u vašu bazi podataka importovati zapise o osobama, a
putem podupita. Lista kolona je: Title, LastName, FirstName, EmailAddress, PhoneNumber i CardNumber. Kreirate
dvije dodatne kolone: UserName koja se sastoji od spojenog imena i prezimena (tačka se nalazi između) i kolonu Password
za lozinku sa malim slovima dugačku 24 karaktera. Lozinka se generiše putem SQL funkciju za slučajne i jedinstvene ID
vrijednosti. Iz lozinke trebaju biti uklonjene sve crtice „-“ i zamijenjene brojem „7“. Uslovi su da podaci uključuju osobe koje
imaju i nemaju kreditnu karticu, a NULL vrijednost u koloni Titula zamjeniti sa podatkom 'N/A'. Sortirati prema prezimenu i
imenu istovremeno. Testirati da li je tabela sa podacima kreirana.
*/

CREATE TABLE #temp
(
	Title NVARCHAR(30), 
	LastName NVARCHAR(30), 
	FirstName NVARCHAR(30),
	EmailAddress NVARCHAR(60), 
	PhoneNumber NVARCHAR(30),
	CardNumber NVARCHAR(60),
	UserName NVARCHAR(30),
	Pasword NVARCHAR(30)
	
)
DROP TABLE #temp
INSERT INTO #temp 
SELECT ISNULL(P.Title,'N/A'),P.LastName,P.FirstName,EA.EmailAddress,PP.PhoneNumber,CC.CardNumber,P.FirstName+'.'+P.LastName,REPLACE(LOWER(LEFT(NEWID(),24)),'-',7)
		FROM AdventureWorks2014.Person.Person as P
		INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA ON P.BusinessEntityID=EA.BusinessEntityID
		INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP ON PP.BusinessEntityID=P.BusinessEntityID
		INNER JOIN AdventureWorks2014.Sales.PersonCreditCard AS PCC ON PCC.BusinessEntityID=P.BusinessEntityID
		INNER JOIN AdventureWorks2014.Sales.CreditCard  AS CC ON CC.CreditCardID=PCC.CreditCardID
		ORDER BY P.FirstName,P.LastName

/*7.
Kreirati indeks koji će nad privremenom tabelom iz prethodnog koraka, primarno, maksimalno ubrzati upite koje koriste
kolone LastName i FirstName, a sekundarno nad kolonam UserName. Napisati testni upit.
*/
CREATE NONCLUSTERED INDEX ix_ime
ON #temp(LastName,FirstName)
INCLUDE (UserName)

SELECT LastName,FirstName FROM #temp WHERE UserName LIKE '%.%'
/*8.
Kreirati uskladištenu proceduru koja briše sve zapise iz privremene tabele koji imaju kreditnu karticu Obavezno testirati
funkcionalnost procedure.
*/
create procedure brisi
as
BEGIN
	DELETE FROM #temp
	where CardNumber IS NULL
END
EXEC brisi


/*9. Kreirati backup vaše baze na default lokaciju servera i nakon toga obrisati privremenu tabelu*/
BACKUP DATABASE zadatak_2018Drugi
TO DISK = 'zadatak_2018Drugi.bak' 
drop table #temp
/*10a Kreirati proceduru koja briše sve zapise iz svih tabela unutar jednog izvršenja. Testirati da li su podaci obrisani*/

create procedure brisanjeSvega
as
BEGIN
DELETE FROM NasloviAutori
DELETE FROM Autori
DELETE FROM Naslovi
DELETE FROM Grad
DELETE FROM Izdavaci
END
EXEC brisanjeSvega

/*10b Uraditi restore rezervene kopije baze podataka i provjeriti da li su svi podaci u izvornom obliku*/

RESTORE DATABASE zadatak_2018Drugi
FROM DISK='zadatak_2018Drugi.bak' 
WITH REPLACE
SELECT * FROM NasloviAutori