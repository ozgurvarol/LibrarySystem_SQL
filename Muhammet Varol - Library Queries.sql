USE MuhammetVarolLibrarySystem
GO


-----i.	For which category(ies) does the library not currently have any books in stock?

select * from Categories
select * from Book_Category

select CategoryID, CategoryName from Categories where
not exists ( select CategoryID from Book_Category where Categories.CategoryID=Book_Category.CategoryID)

------ii.	For each quarter of the current year, for each branch list the total amount of books that have been borrowed in that quarter. 
----The first quarter is months Jan, Feb, Mar. 
----The second quarter is months Apr , May , June etc. 
---List the amounts for each of these quarters, on the same row.


With Q1 as (select  BranchID, Count(TrackID) as Q1 from Track inner join BookCopy on BookCopy.CopyID = Track.CopyID where month(BorrowDate) in ( '01', '02', '03') group by BranchID ),
	 Q2 as (select  BranchID, Count(TrackID) as Q2 from Track inner join BookCopy on BookCopy.CopyID = Track.CopyID where month(BorrowDate) in ( '04', '05', '06') group by BranchID ),
	 Q3 as (select  BranchID, Count(TrackID) as Q3 from Track inner join BookCopy on BookCopy.CopyID = Track.CopyID where month(BorrowDate) in ( '07', '08', '09') group by BranchID ),
	 Q4 as (select  BranchID, Count(TrackID) as Q4 from Track inner join BookCopy on BookCopy.CopyID = Track.CopyID where month(BorrowDate) in ( '10', '11', '12') group by BranchID )

select Branch.BranchID, Q1, Q2, Q3, Q4 from Branch 
left join Q1 on Branch.BranchID = Q1.BranchID
left join Q2 on Branch.BranchID = Q2.branchID
left join Q3 on Branch.BranchID = Q3.BranchID
left join Q4 on Branch.BranchID = Q4.branchID


-----iii.	Which librarian has the highest salary at the current time?


-----We know that jobID = 1 Head Librarian JobID = 2 Librarian so

select Employee.EmployeeID, fname, lname from Employee inner join YearlyWage on Employee.EmployeeID=YearlyWage.EmployeeID
where YearlyWage.JobID = 1 or YearlyWage.JobID = 2
Group by Employee.EmployeeID, fname, lname
having Max(yearwage)=
(select max(YearWage) as HighestSalary from YearlyWage )

---iv.	For each employee, list his/her name and the name of the branch for which he/she is currently working.

select * from Employee
select * from Branch

select Fname + ' ' + Lname, BranchName 
from Employee 
inner join Branch
on Employee.BranchID=Branch.BranchID

-----v.For each book, list the title and publisher of the book and the number of copies currently stocked for this title in each branch, 
---regardless of whether or not it is currently on loan.

select * from Book
select * from Publisher
select * from BookCopy
Select * from Branch

Select Branch.BranchID, Book.Title, Publisher.PublisherName, Count(BookCopy.CopyID) as QtyOfBook
from Book
inner join Publisher
on Publisher.PublisherID = Book.PublisherID
inner join BookCopy
on BookCopy.ISBN = Book. ISBN
inner join Branch
on Branch.BranchID = BookCopy.BranchID
group by Branch.BranchID, Book.Title, Publisher.PublisherName


------vi.	For each branch, list the branch name and the names of the types of employees currently employed by the branch

select * from Branch
select * from Employee
select * from JobType

select BranchName, Description
From Branch
inner join Employee
on Branch.BranchID = Employee.BranchID
inner join JobType
on Employee.JobID = Jobtype.JobID


----vii. For each card, list the name of the borrower and the name of the books he currently has borrowed on the card, that have not yet been returned

select * from LibraryCard
select * from TRACK
select * from BookCopy
select * from Book

select distinct FirstName+' '+Lastname, Book.Title 
from LibraryCard
inner join TRACK
on LibraryCard.CardID = Track.CardID
inner join BookCopy
on BookCopy.CopyID =Track.CopyID
inner join Book
on Book.ISBN = BookCopy.ISBN
where ReturnedDate is null

----viii.	For each card, list the name of the borrower and the name of the books that were borrowed on this card (even if they were already returned)


select distinct FirstName+' '+Lastname, Book.Title 
from LibraryCard
inner join TRACK
on LibraryCard.CardID = Track.CardID
inner join BookCopy
on BookCopy.CopyID =Track.CopyID
inner join Book
on Book.ISBN = BookCopy.ISBN

--------ix.	For a specific card, list which other cards borrowed ALL the same books as were borrowed using this card.

---I choose card 4


select * from BookCopy
select * from TRACK


select CardID, ISBN from BookCopy B1 inner join Track T1 on B1.CopyID = T1.CopyID where B1.BookStatus = 'BORROWED'
and not exists (
select CardID
from TRACK T2
inner join
BookCopy B2
on T2.CopyID=B2.CopyID
where CardID = 4
and not exists 
(select CardID from Track T3 where T3.CopyID=T1.CopyID and  T3.CardID=T2.CardID) )


------x.	List the name of the employee that has been working for the library the longest amount of time

select  * from Employee

select EmployeeID, Fname, Lname  from Employee
where datediff(year, hiredate, getdate())=
(
select max(LongestEmployee) from 
(
Select EmployeeID, datediff(year, hiredate, getdate()) as LongestEmployee from Employee ) as Em )

------------xi.	For each book , list the title and branch that it is in, if it isn’t currently on loan---------

select * from  BookCopy
select * from Branch

select * from Book

select distinct Title, BranchName
from 
BookCopy
inner join Branch
on BookCopy.BranchID = Branch.BranchID
inner join Book
on BookCopy.ISBN = Book.ISBN
where BookStatus = 'AVAILABLE'

--------xii.	List the names of borrowers and the card id that they have if it hasn’t expired

select * from LibraryCard
select * from TRACK


select distinct Track.CardID, FirstName+' 'LastName
from LibraryCard 
inner join TRACK
on Track.CardID = LibraryCard.CardID
where ExpiredDate > GETDATE()


----------xiii.	For each branch, list how many books have been borrowed for each author , and how many books have been borrowed for each category


select * from Branch
select * from BookCopy
select * from Author_Book
select * from Author

select * from Categories
select * from Book_Category

select BranchName, CategoryName, Count(BookCopy.CopyID) QtyOfBook 
from Branch
inner join 
BookCopy
on Branch.BranchID = BookCopy.BranchID
inner join
Author_book
on Author_book.ISBN = BookCopy.ISBN
inner join 
Author
on Author.AuthorID = Author_book.AuthorID
inner join Book_Category
on BookCopy.ISBN = Book_Category.ISBN
inner join Categories
on Categories.CategoryID = Book_Category.CategoryID
where BookStatus = 'BORROWED'
group by grouping sets (BranchName, CategoryName)
order by BranchName


---------xiv.	For each author, list his name and the name of categories of books he has written

select * from author
select * from author_book
select * from Book_category
select * from Categories



select distinct Fname+' '+Lname, CategoryName
from Author
inner join 
Author_Book
on Author.AuthorID = Author_book.AuthorID
inner join
Book_Category
on Author_Book.ISBN = Book_Category.ISBN
inner join
Categories
on Book_category.CategoryID = Categories.CategoryID


-------xv.	For each employee, calculate the amount of money he should have earned based on his logged hours.
select * from HourlyWage

select employeeID, SUM(PerHourRate*WorkedHour) as WeeklyPayment from HourlyWage group by employeeID


----xvi.	List the title of books that have never been borrowed.

select * from BookCopy
select * from Book

select ISBN from BookCopy where Bookstatus = 'AVAILABLE'
and  ISBN not in
( select ISBN from BookCopy where Bookstatus = 'BORROWED')


---xvii.	For each book, list the title and day it was borrowed and day that particular book was returned, how many days (if any) it was overdue.

select * from Book
select * from BookCopy
select * from Track

select BookCopy.ISBN, Title, BorrowDate, ReturnedDate,
(select case 
when ReturnedDate > DueDate then datediff(day, ReturnedDate, DueDate) 
Else 0  
end) AS OverDueDate
From Book
inner join
BookCopy
on Book.ISBN = BookCopy.ISBN
inner join 
Track
on BookCopy.CopyID = Track.CopyID


---xviii.	For each branch, list the titles of fiction type books it currently has in stock.
select * from Categories
select * from Book_category
select * from Book
select * from bookcopy
select * from branch

select  distinct BranchName, Title
from categories 
inner join 
Book_category 
on Categories.CategoryID = Book_category.CategoryID
inner join
Book
on Book_category.ISBN = Book.ISBN
inner join 
BookCopy
on Book.ISBN = BookCopy.ISBN
inner join 
Branch
on BookCopy.BranchID = Branch.BranchID
where CategoryName = 'Fiction'

-----xix.	For each card, list the name of the cardholder, list the category of books and each book that was borrowed on this card. 
---------In the same query list to the how many books have been borrowed for each category, and how many books have been borrowed in total with this card.

select * from LibraryCard
select * From Track  
select * from BookCopy
select * from Book_Category
select * from Categories
select * from Book

select FirstName+' '+LastName, CategoryName, Title,
Count(TrackID) over  (Partition by FirstName+' '+LastName) as QtyBookCardHolder,
Count(TrackID) over (Partition by CategoryName) as QtyBookCategeroy
From LibraryCard
inner join
Track on LibraryCard.CardID  = Track.CardID
inner join 
BookCopy on Track.CopyID = BookCopy.CopyID
inner join
Book_Category on BookCopy.ISBN = Book_Category.ISBN
inner join
Categories on Book_Category.CategoryID = Categories.CategoryID
inner join
Book on Book_Category.ISBN = Book.ISBN




----xx.	List the names of borrowers who have borrowed both book A and book B (you can choose the specific book titles).

--Lets say book 1 and 3

Select * from book
select * from BookCopy
select * from Track
select * from LibraryCard

select FirstName+ ' ' + LastName
From LibraryCard
inner join TRACK
on LibraryCard.CardID = TRACK.CardID
inner join BookCopy
on TRACK.CopyID = BookCopy.CopyID
inner join Book
on BookCopy.ISBN = Book.ISBN
where Book.ISBN = 1
intersect
select FirstName+ ' ' + LastName
From LibraryCard
inner join TRACK
on LibraryCard.CardID = TRACK.CardID
inner join BookCopy
on TRACK.CopyID = BookCopy.CopyID
inner join Book
on BookCopy.ISBN = Book.ISBN
where Book.ISBN = 3

