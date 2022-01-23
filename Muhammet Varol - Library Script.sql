
Use master;
GO

CREATE DATABASE MuhammetVarolLibrarySystem;
GO

USE MuhammetVarolLibrarySystem
GO

CREATE TABLE ContactPersons(
		ContactPersonID int PRIMARY KEY,
		FirstName varchar(255) not null,
		LastName  varchar(255) not null
);

CREATE TABLE Publisher ( 
		PublisherID		int		PRIMARY KEY ,
		PublisherName   varchar(255) not null,
		Adress			varchar(255) not null,
		PhoneNumber		char(13) not null,
		ContactPersonID int		REFERENCES ContactPersons(ContactPersonID),


		----Check Phone Number Format ----
		Constraint [CHK_PhoneNumberPublisher] check (PhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
		--I want to add Unique PhoneNumber--
		constraint [UIX_PublisherPhone] unique (PhoneNumber)

) ;
GO
	


CREATE TABLE Book (
		  ISBN			int PRIMARY KEY ,
		  Title			Varchar(255) Not null ,
		  Cost		    money			Not null,
		  PublisherID	int			REFERENCES  Publisher(PublisherID)
);
GO


CREATE  TABLE Author ( 
		AuthorID int PRIMARY KEY ,
		Lname	 varchar(255) not null,
		Fname    varchar(255) not null,


);
GO


CREATE TABLE Author_Book ( 
		ISBN int references Book(ISBN),
		AuthorID int references Author(AuthorID),
		PRIMARY KEY CLUSTERED ( ISBN, AuthorID )

) ;
GO


CREATE TABLE Categories ( 
		CategoryID		int		PRIMARY KEY ,
		CategoryName	Varchar(255) not null

) ; 
GO


CREATE TABLE Book_Category ( 
		ISBN	int references Book(ISBN),
		CategoryID int references Categories(CategoryID),
		BookDescription varchar(255),
		PRIMARY KEY CLUSTERED ( ISBN, CategoryID )
) ;
GO

Create TABLE Branch(
		BranchID	 int PRIMARY KEY ,
		BranchName	 varchar(255) not null,
		BranchAdress varchar(255) not null,
		PhoneNumber  char(13)  not null,
		FaxNumber	 char(13)  not null,
		----Check Phone Number Format and FaxNumberFormat ----
		Constraint [CHK_PhoneNumberBranch] check (PhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
		Constraint [CHK_FaxNumberBranch] check (FaxNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
				--I want to add Unique PhoneNumber--
		constraint [UIX_BranchPhone] unique (PhoneNumber)

);
GO



CREATE TABLE Conditions( 
		ConditionID int PRIMARY KEY ,
		Description Varchar(50) not null,
		Constraint [CHK_ConditionDesc] check (upper(Description) in ( 'NEW', 'EXCELLENT', 'GOOD', 'WORN', 'POOR'))
	
);
GO

CREATE TABLE BookCopy (  
		CopyID		int	 PRIMARY KEY ,
		BranchID	int references Branch(BranchID),
		ConditionID int references Conditions(ConditionID),
		BookStatus		varchar(50) not null,
		ISBN		int references Book(ISBN), 
		---Book Status----
		constraint [CHK_BookStatus] check (upper(BookStatus) in ('BORROWED','AVAILABLE ','NOT BORROWED'))

		);
GO

CREATE TABLE JobType(
		JobID int PRIMARY KEY ,
		Description varchar(255) not null
);
GO

CREATE TABLE Employee(
		EmployeeID		int PRIMARY KEY ,
		JobID	int references JobType(JobID),
		Fname			varchar(255) not null,
		Lname			varchar(255) not null,
		Adress			varchar(45)  not null,
		PhoneNumber		char(13)	 not null,
		BirthDate		date	     not null,
		HireDate		date		 not null,
		BranchID		int			 references Branch(BranchID),
			----Check Phone Number Format ----
			
		Constraint [CHK_PhoneNumberEmployee] check (PhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
				----Check Age----
		Constraint [CHK_Age]		check  (datediff(year, BirthDate, getdate()) > 18 ),
					---CheckHireDate----
		Constraint [CHK_HireDate] check (HireDate <= getdate()) ,
						--I want to add Unique PhoneNumber--
		constraint [UIX_EmployeePhone] unique (PhoneNumber)


); 
GO

CREATE TABLE HourlyWage (  ---I put JobID too because for example if I would like to update all data analysts wage, it will be easier to update---
						  --And I put EmpID because maybe I would like to increase specific employee's wage---				  
		PaymentID		int IDENTITY(1,2) PRIMARY KEY,
		EmployeeID		int references Employee(EmployeeID),
		JobID			int references JobType(JobID),
		PerHourRate		decimal not null,
		VacationStart	Date,
		VacationEnd		Date,
		WorkedHour		decimal not null,
		WeeklyPayment	as PerHourRate*WorkedHour,
		-----Vacation has to be minumum 2 weeks----
		Constraint [CHK_VacationTimeHourlyWage] check (datediff(week, VacationStart, VacationEnd) >= 2 ),
		Constraint [CHK_HourlyVacation]  check (VacationEnd > VacationStart),
		-------d.	Pay rate for hourly workers must be at least 15.00..-------
		Constraint [CHK_PerHourRate] check (PerHourRate >= 15.00 )
		);

		--I put auto identity for payments So, I will know Odd numbers HourlyWage payments, Even numbers YearlyWage payments.---

GO




CREATE TABLE YearlyWage (  
		PaymentID		int  IDENTITY(2,2) PRIMARY KEY,
		EmployeeID		int references Employee(EmployeeID),
		JobID			int references JobType(JobID),
		YearWage		money,
		MonthlyPayment	as YearWage/12,
		VacationStart	Date,
		VacationEnd		Date,	
		
			Constraint [CHK_YearVacation]  check (VacationEnd > VacationStart),
		-----Vacation has to be minumum 2 weeks----
		constraint [CHK_VacationTimeYearlyWage] check (datediff(week, VacationStart, VacationEnd) >= 2 ),
		----a.Librarians earn between 20000 and 70000 per year
		
		constraint [CHK_LibrariansWage] check (  (JobID=1 and YearWage > 20000 and YearWage < 70000 ) or
		(JobID=2 and YearWage > 20000 and YearWage < 70000 ) )

		

		);
GO
	


CREATE TABLE Librarian (
		HeadLibrarian int references Employee(EmployeeID),
		EarnedDegree varchar(255) not null,
		SchoolName varchar(255)  not null,
		BranchID int references Branch(BranchID),

		Constraint [UIX_BranchID] unique (BranchID),
		Constraint [CHK_EarnedDegree] check (EarnedDegree = 'Library Science')
);
GO
  ---1,10,17 Head Librarians
			

CREATE TABLE Parent(
		ParentID	int	PRIMARY KEY ,
		FirstName	varchar(255) not null,
		LastName	varchar(255) not null,
		Adress		varchar(255) not null,
		PhoneNumber	char(13)	not null,
		---CheckPhoneNum---
		constraint [CHK_PhoneNumberParent] check (PhoneNumber Like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
						--I want to add Unique PhoneNumber--
		constraint [UIX_ParentPhone] unique (PhoneNumber)

);           
GO

CREATE TABLE LibraryCard (
		CardID		int	 PRIMARY KEY , 
		FirstName	varchar(255) not null,
		LastName	varchar(255) not null,
		Adress		varchar(255) not null,
		PhoneNumber	 char(13)	not null,
		BirthDate		date not null,
		CardIssuedDate	date not null,
		ExpiredDate		as dateadd(year,10,CardIssuedDate),
		Balance	 int not null,
		ParentID int references Parent(ParentID),
		
		----If CardHolder < 18 years old check ParentID is not null else ParentID NUll----
		Constraint [CHK_BirthDateCard] check ( datediff(year, BirthDate, getdate()) < 18 And ParentID IS NOT NULL OR 
		(datediff(year, BirthDate, getdate()) > 18) And ParentID IS NULL),

		Constraint [CHK_PhoneNumberCard] check  (PhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
						--I want to add Unique PhoneNumber--
		constraint [UIX_LibraryCardPhone] unique (PhoneNumber),

		----c.	A Borrower must be at least 10 years old to have a card issued in his name---
		Constraint [CHK_BirthDateCard10] check ( datediff (year, BirthDate, getdate()) > 10 ) ,
		---b.	A Borrower can’t accrue more than 10 dollars balance on any card.---
		Constraint [CHK_Balance] check (Balance < 10 )

);

GO


CREATE TABLE TRACK (
		TrackID int IDENTITY(1,1) PRIMARY KEY,
		CopyID	int References BookCopy(CopyID),
		CardID  int References LibraryCard(CardID),
		BorrowDate	date not null,
		DueDate		as dateadd(week, 2, Borrowdate),
		ReturnedDate date,
		LateFee		money, 
		
		Constraint [CHK_TrackDate] check ( datediff(day, BorrowDate, ReturnedDate ) > 0 ),
		Constraint [CHK_TrackDateToday] check ( ReturnedDate < getdate() )
);
GO 
	



USE MuhammetVarolLibrarySystem
GO

---a.	A librarian can’t be hired before he has earned a MS in Library Science degree.

Create procedure [dbo].[usp_InsertHeadLibrarian]
		@HeadLibrarian int, @EarnedDegree varchar(255), @SchoolName  Varchar(255), 
			@BranchID int  
			as 
    begin

	SET NOCOUNT ON;

	If ( @EarnedDegree = 'Library Science')
		insert into Librarian
		( HeadLibrarian, EarnedDegree, SchoolName, BranchID)
		Values
		 (@HeadLibrarian, @EarnedDegree, @SchoolName, @BranchID)
		 else
		 begin;
		 throw 50001, 'A librarian can’t be hired before he has earned a MS in Library Science degree.',1
		 end

	end
	GO
	-----b.	A new card can’t be issued for someone who owes money on an existing card

	Create procedure [dbo].[Usp_NewCard]
	@CardID int, @newCardID int
as
begin
		--Find out if cardholders owes money
   declare @currBalance money
   select @CurrBalance = Balance
   from Librarycard
   where CardID = @CardID

	if (@currBalance > 0)
	begin ;
		

		throw 50001, 'Can not get new card because Card has balance on it', 1
	end
	else 

	begin
			update LibraryCard
			set CardID = @newCardID
			where CardID = @CardID

	end

end
GO
---c.	A new card can’t be issued for someone who has a card that hasn’t yet expired

CREATE procedure [dbo].[Usp_NewCardExperied]
	@CardID int, @newCardID int
as

begin
   -- find out if experied

   declare @currExpiredDate date 
   select @currExpiredDate = ExpiredDate
   from Librarycard
   where CardID = @CardID

	
	if (@currExpiredDate > getdate())
	begin ;
		throw 50001, 'Cant get new card because card hasnt expired yet', 1
	end
	else 

	begin
			
			update LibraryCard
			set CardID = @newCardID
			where CardID = @CardID

	end

end
GO

----d.	Workers who log hours can’t log more than 40 hours per week


		CREATE PROCEDURE [dbo].[usp_LogHour]
		@EmployeeID int, @JobID int, @PerHourRate decimal, @VacationStart date, @VacationEnd date,
		@WorkedHour decimal
		as
	begin
				if (@workedhour < 40 )
				insert into HourlyWage (EmployeeID, JobID, PerHourRate, VacationStart, VacationEnd, WorkedHour)
				Values
				(@EmployeeID, @JobID, @PerHourRate, @VacationStart, @VacationEnd, @WorkedHour)
		else
		begin;

		throw 50001, 'Employee Can not work more than 40 hours', 1

		end
	end
	GO
---e.	A borrower can’t use a card to borrow books, if he owes more than 10 dollars on that card

Create procedure [dbo].[usp_BoorrowerBook]  --trackid auto identity  
 @CopyID int, @CardID int, @BorrowDate date, @ReturnedDate date, @LateFee money, 
 @Balance int
			as
begin
			declare @currBalance money
			select @CurrBalance = Balance
			from Librarycard
			where CardID = @CardID

	if (@currBalance > 10)
	begin ;
		throw 50001, 'Can not get new Book because borrower owes more than 10 dollars', 1
	end
	else 

	begin
			insert into Track (CopyID, CardID, BorrowDate, ReturnedDate, LateFee)
			values (@CopyID, @CardID, @BorrowDate, @ReturnedDate, @LateFee)
	End
END
GO


-----f.	Each time a book is returned, check if overdue and add charge to balance on card or customer record

----05 each day for juvenile books and .10 per day for adult books and 0.15 rest of the categories
----So Professor I guess I try so hard in here, so let me explain what I try to do it;
----I think when Library get book return, they will check trackid, and borrowdate, and they will just enter returned date, when returned date entered
---database will check if datediff more than 0 days it will overdue (latefee) charge, and if book that returned Juvenile category 0.05 if Adult 0.10 if 
---neither Juenile or Adult it will chare 0.15, if returned date <0 no latefee. I know it should be simple, when you check it out Could you mail me correct Procedure please.
----THANK YOU SO MUCH !!

Create Procedure usp_BookReturned
        @ReturdenDate date, @Latefee money, @TrackID int
		as
		begin
		
		declare @currTrackID int
		declare @borrowDate date
		declare @returneddate date
		select @currTrackID = TrackID,
		@borrowDate = BorrowDate,
		@returneddate = ReturnedDate 
		from Track
		if ( DATEDIFF ( day, @borrowdate, @returneddate ) > 0 )
		begin
		insert into TRACK (Latefee)
		Values ( (select DATEDIFF ( day, borrowdate, returneddate ) from  Track 
		inner join BookCopy
		on Track.CopyID=BookCopy.CopyID
		inner join Book_category 
		on BookCopy.ISBN = Book_category.ISBN
		inner join Categories 
		on Book_Category.CategoryID = Categories.CategoryID 
		where CategoryName = 'Adult') * 0.10 )
		if ( DATEDIFF ( day, @borrowdate, @returneddate ) > 0 )
		begin
		insert into TRACK (Latefee)
		Values ( (select DATEDIFF ( day, borrowdate, returneddate ) from  Track 
		inner join BookCopy
		on Track.CopyID=BookCopy.CopyID
		inner join Book_category 
		on BookCopy.ISBN = Book_category.ISBN
		inner join Categories 
		on Book_Category.CategoryID = Categories.CategoryID 
		where CategoryName = 'Juvenile') * 0.05 )
		end
				if ( DATEDIFF ( day, @borrowdate, @returneddate ) > 0 )
		begin
		insert into TRACK (Latefee)
		Values ( (select DATEDIFF ( day, borrowdate, returneddate ) from  Track 
		inner join BookCopy
		on Track.CopyID=BookCopy.CopyID
		inner join Book_category 
		on BookCopy.ISBN = Book_category.ISBN
		inner join Categories 
		on Book_Category.CategoryID = Categories.CategoryID 
		where CategoryName <> 'Juvenile' or CategoryName <> 'Adult') * 0.15 )
		end
		END
		else 
		begin
				insert into Track (latefee)
		Values (0)
		End
		End
		GO








-----g.	Each time a book is borrowed, check that it can be borrowed. Obviously, this would only happen if physical inventory and system inventory don’t match.


Create procedure usp_BookAvailableCheck
		@TrackID int, @CopyID int, @CardID int, @BorrowDate date
				as
				
			begin
				declare @CurrBookStatus varchar(255)
				select @CurrBookStatus = BookStatus from BookCopy where CopyID = @CopyID

				if( @CurrBookStatus = 'AVAILABLE' )
				begin
					insert into TRACK (TRACKID, CopyID, CardID, BorrowDate)
					Values (@TrackID, @CopyID, @CardID, @BorrowDate)
				End
				Else
				begin;

				throw 50001, 'Book can not borrow because it is already borrowed', 1

				end
			end
			GO
	
	
		INSERT INTO ContactPersons VALUES(1, 'Rosa', 'Caballero');
		INSERT INTO ContactPersons VALUES(2, 'Fay ', 'Rosenfeld');
		INSERT INTO ContactPersons VALUES(3, 'Matthew ', 'Knutzen');
		INSERT INTO ContactPersons VALUES(4, 'Jacqueline ', 'Davis');
		INSERT INTO ContactPersons VALUES(5, 'Vanessa ', 'Spray');
		INSERT INTO Publisher VALUES (1, 'Ten Speed Press', 'California', '646-726-4545', 1 );
		INSERT INTO Publisher VALUES (2, 'Vintage Books,', 'New York',    '646-726-3045', 2 );
		INSERT INTO Publisher VALUES (3, 'Verso Books',  'London',        '646-725-2245', 3 );
		INSERT INTO Publisher VALUES (4, 'Houghton Mifflin', 'Boston',    '347-896-8989', 4);
		INSERT INTO Book VALUES(1, 'Aloha kitchen : recipes from Hawai', 30, 1);
		INSERT INTO Book VALUES(2, 'Being Wagner : the story of the most provocative composer who ever lived ', 15, 1);
		INSERT INTO Book VALUES(3, 'Capital city : gentrification and the real estate state', 12, 1);
		INSERT INTO Book VALUES(4, 'Hostile environment : How Immigrants Became Scapegoats', 25, 2);
		INSERT INTO Book VALUES(5, 'Why you should be a trade unionist', 30, 2);
		INSERT INTO Book VALUES(6, 'We fight fascists : The 43 Group and Their Forgotten Battle for Post-war Britain', 22, 2);
		INSERT INTO Book VALUES(7, 'The morals of the market : Human Rights and the Rise of Neoliberalism ', 25, 3);
		INSERT INTO Book VALUES(8, 'Dapper Dan : made in Harlem : a memoir ', 33, 3);
		INSERT INTO Book VALUES(9, 'Do not skip out on me : a novel', 40, 3);
		INSERT INTO Book VALUES(10, 'The Lord of the Rings', 100, 4);
		INSERT INTO Book VALUES(11, 'The Silmarillion', 150, 4);
		INSERT INTO Book VALUES(12, 'les miserables',200,1);

		INSERT INTO Author VALUES (1, 'Kysar', 'Alana');
		INSERT INTO Author VALUES (2, 'Callow', 'Simon');
		INSERT INTO Author VALUES (3, 'Stein', 'Samuel');
		INSERT INTO Author VALUES (4, 'Day', 'Daniel');
		INSERT INTO Author VALUES (5, 'Tolkien', 'J. R. R.');

		INSERT INTO Author_Book VALUES(1, 1);
		INSERT INTO Author_Book VALUES(2, 1);
		INSERT INTO Author_Book VALUES(3, 1);
		INSERT INTO Author_Book VALUES(4, 2);
		INSERT INTO Author_Book VALUES(5, 2);
		INSERT INTO Author_Book VALUES(6, 3);
		INSERT INTO Author_Book VALUES(7, 4);
		INSERT INTO Author_Book VALUES(8, 4);
		INSERT INTO Author_Book VALUES(9, 3);
		INSERT INTO Author_Book VALUES(9, 4);
		INSERT INTO Author_Book VALUES(10, 5);
		INSERT INTO Author_Book VALUES(11, 5);
		INSERT INTO Author_Book VALUES(12, 5);

		INSERT INTO Categories VALUES(1,'Mystery');
		INSERT INTO Categories VALUES(2,'Bio');
		INSERT INTO Categories VALUES(3, 'Historical Fiction');
		INSERT INTO Categories VALUES(4, 'Juvenile');
		INSERT INTO Categories VALUES(5, 'Adult');
		INSERT INTO Categories VALUES(6, 'Si-Fi');
		INSERT INTO Categories VALUES(7, 'Fiction');
		INSERT INTO Categories VALUES(8, 'Reference');

		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (1, 1);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (2, 2);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (3, 2);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (4, 5);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (5, 5);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (5, 6);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (6, 6);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (7, 6);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (8, 8);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (9, 8);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (10, 6);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (10, 7);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (11, 6);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (11, 7);
		INSERT INTO Book_Category(ISBN,CategoryID) VALUES (12, 7);

		
		INSERT INTO Branch VALUES (1, 'New York Public Library - South Beach Branch', 'Staten Island', '718-816-5834', '718-816-5835');
		INSERT INTO Branch VALUES (2, 'Battery Park City Library', 'New York', '212-790-3499', '212-790-3599');
		INSERT INTO Branch VALUES (3, 'Seward Park Library', 'New York', '212-477-6770', '212-477-6771');

	    INSERT INTO Conditions VALUES(1, 'NEW');
		INSERT INTO Conditions VALUES(2, 'EXCELLENT');
		INSERT INTO Conditions VALUES(3, 'GOOD');
		INSERT INTO Conditions VALUES(4, 'WORN');
		INSERT INTO Conditions VALUES(5, 'POOR');


		

		INSERT INTO BookCopy VALUES (1, 1, 1, 'AVAILABLE',  1);
		INSERT INTO BookCopy VALUES (2, 1, 1, 'AVAILABLE',  1);
		INSERT INTO BookCopy VALUES (3, 1, 3, 'BORROWED',   1);
		INSERT INTO BookCopy VALUES (4, 1, 2, 'AVAILABLE',  3);
	    INSERT INTO BookCopy VALUES (5, 1, 1, 'AVAILABLE',  4);
		INSERT INTO BookCopy VALUES (6, 1, 1, 'AVAILABLE',  5);
		INSERT INTO BookCopy VALUES (7, 1, 3, 'BORROWED',   6);
		INSERT INTO BookCopy VALUES (8, 1, 2, 'AVAILABLE',  7);
		INSERT INTO BookCopy VALUES (9, 2, 1, 'BORROWED',   1);
		INSERT INTO BookCopy VALUES (10, 2, 1, 'AVAILABLE', 1);
		INSERT INTO BookCopy VALUES (11, 2, 3, 'BORROWED',  8);
		INSERT INTO BookCopy VALUES (12, 2, 2, 'AVAILABLE', 9);
		INSERT INTO BookCopy VALUES (13, 3, 1, 'AVAILABLE', 9);
		INSERT INTO BookCopy VALUES (14, 3, 1, 'AVAILABLE', 10);
		INSERT INTO BookCopy VALUES (15, 3, 3, 'BORROWED',  11);
		INSERT INTO BookCopy VALUES (16, 3, 2, 'AVAILABLE', 11);
		INSERT INTO BookCopy VALUES (17, 3, 1, 'AVAILABLE', 11);
		INSERT INTO BookCopy VALUES (18, 3, 1, 'AVAILABLE', 10);
		INSERT INTO BookCopy VALUES (19, 2, 3, 'BORROWED',  2);
		INSERT INTO BookCopy VALUES (20, 2, 2, 'AVAILABLE', 3);
		INSERT INTO BookCopy VALUES (21, 2, 2, 'BORROWED',  3);
		INSERT INTO BookCopy VALUES (22, 2, 2, 'BORROWED',  3);
		INSERT INTO BookCopy VALUES (23, 2, 2, 'AVAILABLE', 2);
		INSERT INTO BookCopy VALUES (24, 2, 2, 'BORROWED',  9);
		INSERT INTO BookCopy VALUES (25, 2, 2, 'BORROWED',  8);
		INSERT INTO BookCopy VALUES (26, 3, 2, 'AVAILABLE', 1);
		INSERT INTO BookCopy VALUES (27, 3, 2, 'BORROWED',  5);
		INSERT INTO BookCopy VALUES (28, 3, 2, 'BORROWED',  6);
		INSERT INTO BookCopy VALUES (29, 3, 2, 'BORROWED',  7);
		INSERT INTO BookCopy VALUES (30, 2, 2, 'AVAILABLE', 9);
		INSERT INTO BookCopy VALUES (31, 2, 2, 'AVAILABLE', 2);
		INSERT INTO BookCopy VALUES (32, 2, 2, 'BORROWED',  9);
		INSERT INTO BookCopy VALUES (33, 2, 2, 'BORROWED',  8);
		INSERT INTO BookCopy VALUES (34, 3, 2, 'AVAILABLE', 1);
		INSERT INTO BookCopy VALUES (35, 3, 2, 'BORROWED',  5);
		INSERT INTO BookCopy VALUES (36, 3, 2, 'BORROWED',  6);
		INSERT INTO BookCopy VALUES (37, 3, 2, 'BORROWED',  7);
		INSERT INTO BookCopy VALUES (38, 2, 2, 'AVAILABLE', 9);
		INSERT INTO BookCopy VALUES (39, 1, 1, 'AVAILABLE', 12);


		INSERT INTO JobType VALUES (1, 'HeadLibrarian');
		INSERT INTO JobType VALUES (2, 'Librarian');
		INSERT INTO JobType VALUES (3, 'Network Administrator');
		INSERT INTO JobType VALUES (4, 'Computer Programmer');
		INSERT INTO JobType VALUES (5, 'IT Manager');
		INSERT INTO JobType VALUES (6, 'Floor Manager');
		INSERT INTO JobType VALUES (7, 'Custodian');
		INSERT INTO JobType VALUES (8, 'Accountant');
		INSERT INTO JobType VALUES (9, 'Data Analyst');

		

		INSERT INTO Employee VALUES (1,  1, 'Jason',     'Baumann',    'Staten Island',   '917-659-8989',  '10-11-1970',  '09-16-2000', 1);
		INSERT INTO Employee VALUES (2,  2, 'Cheryl',    'Beredo',     'New York' ,       '317-659-8871',  '09-12-1990',  '10-10-2003', 1);
		INSERT INTO Employee VALUES (3,  3, 'Charles',   'Carter',     'Staten Island',   '646-789-1646',  '01-10-1995',  '05-11-2019', 1);
		INSERT INTO Employee VALUES (4,  4, 'Kate',      'Cordes',     'New Jersey',      '718-371-8979',  '06-06-1998',  '04-19-2018', 1);
		INSERT INTO Employee VALUES (5,  5, 'Paloma',    'Celis',      'New York',        '347-693-5544',  '01-01-1992',  '01-01-2017', 1);
		INSERT INTO Employee VALUES (6,  6, 'Madeleine', 'Cohen',      'New Jersey',      '646-896-9975',  '01-01-1996',  '06-06-2014', 1);
		INSERT INTO Employee VALUES (7,  7, 'Elizabeth', 'Cronin',     'New York',        '646-889-1456',  '01-01-1987',  '05-05-2010', 1);
		INSERT INTO Employee VALUES (8,  8, 'Elizabeth', 'Denlinger',  'New York',        '917-965-9963',  '05-12-1990',  '01-01-2020', 1);
		INSERT INTO Employee VALUES (9,  9, 'Rhonda',    'Evans',      'New Jersey',      '646-596-9978',  '06-22-1980',  '05-22-2006', 1);
		INSERT INTO Employee VALUES (10, 1, 'Rebecca',   'Federman',   'Staten Island',   '646-985-7789',  '06-25-1985',  '01-01-2015', 2);
		INSERT INTO Employee VALUES (11, 2, 'Ian',       'Fowler',     'Staten Island',   '347-986-9633',  '01-06-1999',  '01-01-2020', 2);
		INSERT INTO Employee VALUES (12, 3, 'Jonathan',  'Hiam',       'New York',        '646-987-8524',  '01-01-1989',  '01-01-2013', 2);
		INSERT INTO Employee VALUES (13, 4, 'Patrick',   'Hoffman',    'New York',        '349-697-6614',  '01-01-1988',  '01-01-2013', 2); 
		INSERT INTO Employee VALUES (14, 5, 'Bogdan',    'Horbal',     'New York',        '646-987-3259',  '01-01-1982',  '01-01-2015', 2);
		INSERT INTO Employee VALUES (15, 6, 'Michael',   'Inman',      'New York',        '648-986-9636',  '01-01-1980',  '01-01-2019', 2);
		INSERT INTO Employee VALUES (16, 7, 'Tanisha',   'Jones',      'Staten Island',   '646-647-7878',  '01-01-1983',  '01-01-2010', 2);
		INSERT INTO Employee VALUES (17, 1, 'Kathleen',  'Kalmes',     'Staten Island',   '347-896-9636',  '01-01-1986',  '01-01-2011', 3);
		INSERT INTO Employee VALUES (18, 2, 'Shannon',   'Keller',     'Staten Island',   '347-898-5636',  '01-01-1989',  '01-01-2012', 3);
		INSERT INTO Employee VALUES (19, 3, 'Matt',      'Knutzen',    'Staten Island',   '646-759-9637',  '01-01-1989',  '01-01-2015', 3);
		INSERT INTO Employee VALUES (20, 4, 'Betty',     'Lacy',       'Staten Island',   '929-987-5628',  '01-01-1989',  '01-01-2016', 3);
		INSERT INTO Employee VALUES (21, 5, 'Maira' ,    'Liriano',    'Staten Island',   '929-654-3131',  '01-01-1984',  '01-01-2014', 3);
		INSERT INTO Employee VALUES (22, 6, 'Tammi' ,    'Lawson',     'Staten Island',   '929-741-7845',  '01-01-1989',  '01-01-2012', 3);
		INSERT INTO Employee VALUES (23, 7, 'Shola' ,    'Lynch',      'Staten Island',   '929-766-9885',  '01-01-1970',  '01-01-2010', 3);


		INSERT INTO LibraryCard (CardID, Firstname, LastName, Adress,PhoneNumber, BirthDate,CardIssuedDate, Balance)
		VALUES (1, 'Ozgur', 'Varol', 'NY', '646-726-7414', '10-11-1992', '01-01-2015', 0);
		INSERT INTO LibraryCard (CardID, Firstname, LastName, Adress,PhoneNumber, BirthDate,CardIssuedDate, Balance)
		VALUES (2,  'Radamel', 'Falcao', 'NJ', '347-896-9696', '01-01-1980', '02-02-2015', 0);
		INSERT INTO LibraryCard (CardID, Firstname, LastName, Adress,PhoneNumber, BirthDate,CardIssuedDate, Balance)
		VALUES (3, 'Jonathan',  'Ramo',  'NY',  '646-789-9741',  '01-03-1990', '01-01-2015', 0);
		INSERT INTO LibraryCard (CardID, Firstname, LastName, Adress,PhoneNumber, BirthDate,CardIssuedDate, Balance)
		VALUES (4, 'Muhammet', 'Gates', 'NY', '646-896-9898', '10-11-1992', '11-01-2016', 0);
		INSERT INTO LibraryCard (CardID, Firstname, LastName, Adress,PhoneNumber, BirthDate,CardIssuedDate, Balance)
		Values (5, 'Steve', 'Jobs',  'NY', '347-654-0109', '05-16-1975',   '01-01-2014', 0);
		INSERT INTO LibraryCard (CardID, Firstname, LastName, Adress,PhoneNumber, BirthDate,CardIssuedDate, Balance)
		Values (6, 'Rachel', 'Green',  'NY', '346-554-0007', '05-16-1979',   '01-01-2019', 0);
		INSERT INTO LibraryCard (CardID, Firstname, LastName, Adress,PhoneNumber, BirthDate,CardIssuedDate, Balance)
		Values (7, 'Joey', 'Tribianni',  'NY', '917-254-0089', '05-16-1975',   '01-01-2008', 0);
			

	    INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(9, 7,   '10-01-2007', '10-11-2007');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(3, 1, '05-11-2020', '05-12-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(7, 1, '04-10-2020', '04-14-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(9,  1, '04-13-2020', '04-20-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(11, 1, '04-20-2020', '04-28-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(15, 1, '02-01-2020', '02-10-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(19, 1, '03-01-2020',  '03-10-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(21, 2, '01-04-2020',  '01-15-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(22, 2, '07-15-2019',  '07-25-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(24, 2, '08-10-2019',  '08-16-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(25, 2, '08-20-2019',  '08-29-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(27, 2, '09-21-2019',  '09-29-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(28, 2, '09-01-2019',  '09-11-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(29, 3,  '10-15-2019', '10-25-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(32, 3,  '10-20-2019', '10-29-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(33, 3,  '11-15-2019',  '11-25-2019'); 
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(35, 3,   '12-25-2019', '12-30-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(36, 4,   '10-10-2019', '10-18-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(37, 4,   '10-06-2019', '10-16-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(36, 5,   '11-10-2019', '11-20-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate, ReturnedDate)
		Values(37, 5,   '10-28-2019', '11-09-2019');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(3, 1, '05-12-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(3, 2, '05-12-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(22, 2, '05-07-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(24, 2, '05-08-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(25, 2, '05-9-2020' );
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(27, 2, '05-10-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(28, 2, '05-09-2020');
		INSERT INTO TRACK(CopyID, CardID, BorrowDate)
		Values(29, 3,  '05-10-2020');

		INSERT INTO Librarian VALUES (1,  'Library Science', 'Brooklyn College',       1);
		INSERT INTO Librarian VALUES (10, 'Library Science', 'New York City College',  2);
		INSERT INTO Librarian VALUES (17, 'Library Science', 'Long Island University', 3);

	    INSERT INTO Parent VALUES (1, 'Bill', 'Gates', 'NY', '646-789-6958');
        INSERT INTO Parent VALUES (2, 'John', 'Smith', 'NJ', '648-896-0077');


		INSERT INTO HourlyWage(EmployeeID, JobID, PerHourRate, WorkedHour) VALUES (2,9,50.00, 30);
		INSERT INTO YearlyWage(EmployeeID,JobID,YearWage) VALUES (1,1,60000);


			--jobid = 2 Librarian
		INSERT INTO YearlyWage(EmployeeID,JobID,YearWage) VALUES (2,  2, 41000 );
		INSERT INTO YearlyWage(EmployeeID,JobID,YearWage) VALUES (11, 2, 34750);
		INSERT INTO YearlyWage(EmployeeID,JobID,YearWage) VALUES (18, 2, 22000);




select * from Author
select * from Author_Book
select * from Book
select * from BookCopy
Select * from Branch
Select * from Categories
select * from Conditions
select * from ContactPersons
select * from Employee
select * from JobType
select * from Librarian
select * from LibraryCard
select * from Parent
select * from Publisher
select * from Book_Category
select * from TRACK
select * from HourlyWage
select * from YearlyWage