SELECT *
FROM NashvilleHousing

--1.Standardize Date Format. 
SELECT SaleDate, Convert(Date,SaleDate)				--Here we first explored what the current datatype looking in contrast with what we wanted it to look like DATETIME vs DATE
FROM	NashvilleHousing

ALTER TABLE NashvilleHousing						--Because CONVERT(Date,[]) was not working, we instead added a new column to our table that would hold our date data in the correct datatype
ADD	SaleDateConverted Date;

UPDATE	NashvilleHousing							--We then proceeded to insert the sales data into the newly created column with the desired datatype 
SET	SaleDateConverted = SaleDate

SELECT SaleDateConverted, Convert(Date,SaleDate)	--We then proceed to check the datatype between out newly created column and the converted data                                                                             
FROM	NashvilleHousing


--2.Populate Property Address Data in columns that have identical Parcel Id's
SELECT *
FROM	NashvilleHousing
ORDER BY ParcelID

UPDATE NashvilleHousing		--this was the method I used but you can see that its not very efficient. I would need to write this piece of code for every parcelID
SET		PropertyAddress = '410  ROSEHILL CT, GOODLETTSVILLE'
WHERE	ParcelID = '025 07 0 031.00'

SELECT a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

/*First, to investigate our data, we did a self join with our Nashville Housing data. This would allows us to look at how the data was in relationship to itself.
We proceeded to join the parcel id of the table to itsself with the key factor being the table would also show us where all the nulls were. We had to make sure that the 
we were gona get back wasn't going to be any duplicates of the same [UNIQUE ID}. After filtering those with the WHERE clause, we were able to see how many nulls remained 
within our table. The next thing we need is a NULL test. 

"The ISNULL", takes 2 arguments. The first one asks what value do you want to replace, and the second one asks what value do you want to replace it with. This test was 
necessary for our code becuase we will be implementing it within our update statement. SQL will then know that if it finds a row with a NULL value in the specified column, 
that it should replace it with the specified values from the specified column with the matching ParcelID. 
*/

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL


SELECT *
FROM NashvilleHousing
ORDER BY [UniqueID ]


--3.Breaking out address into individual columns (Address, City, State)
SELECT	PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) Address			--Address
FROM	NashvilleHousing

SELECT	PropertyAddress, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) City	--City
FROM	NashvilleHousing

ALTER TABLE NashvilleHousing						--Now, we'll need to create a new column for our newly created address and city data. We can drop the original columns later.
ADD	PropertySplitAddress NVARCHAR(255)
UPDATE	NashvilleHousing
SET	PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

SELECT PropertyAddress, PropertySplitAddress
FROM	NashvilleHousing

ALTER TABLE NashvilleHousing						--This column is for our city data 
ADD	PropertySplitCity NVARCHAR(255)
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress))

SELECT PropertySplitAddress,PropertySplitCity
FROM	NashvilleHousing

--We can similarly seperate the content within a column using PARSENAME. This function allows us to split data delimited by a period(.) within the same column. 
SELECT OwnerAddress
FROM	NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	   PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	   PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashvilleHousing


--NOW, we have to create three seperate columns to house our newly transformed data and then update these columns with the query above.
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing							
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);



--4. Change Y and N to Yes and NO in "Sold as Vacant" field.
SELECT	DISTINCT(Soldasvacant), COUNT(SoldAsVacant)
FROM	NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

																	--The Case statement is a logical equivalent to the IF function. We are essentially telling SQL intelligence
SELECT SoldAsVacant,												--find where in the data the SoldVacant is 'Y' or 'N' and replace them with "Yes" or "No" by using the "THEN" expression. 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing												--Once we have written a query that returns our desired output, then we can update the table and data
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


--5. Remove Duplicates/ *Not standard practice to delete data thats in your database.

--created a CTE so as to be able to utilize the WHERE clause with our ROW_Number and Partition Function. 
WITH	CTE_RemoveDupes               --Named our CTE and the proper syntax 
AS		(
	SELECT	*,
			ROW_NUMBER() OVER(PARTITION BY ParcelID ORDER BY [UniqueID]) RowNumber
	FROM	NashvilleHousing  
		)

DELETE 
FROM	CTE_RemoveDupes
WHERE RowNumber > 1


--6. Delete Unused cloumns. You would never do this for raw data that you import so this can be done for views or temptables that you create.
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate


--7.
SELECT UNIQUE (OwnerName), OwnerName
FROM NashvilleHousing
WHERE OwnerName LIKE 'a%'

SUBSTRING()