USE portfolio_project;

SELECT * 
FROM portfolio_project.dbo.NashvilleHousing;

-------- Standardize Date Format-------------------

SELECT saledate, CONVERT(date, SaleDate)
FROM portfolio_project.dbo.NashvilleHousing;


--New 'SaleDateConverted' column added & filled with converted SaleDate column values

ALTER TABLE NashvilleHousing	
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);



--------- Populate Property Address data---------------

--Check for Null values in PropertyAddress

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;


--Self Join the table

SELECT t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, ISNULL(t1.PropertyAddress, t2.PropertyAddress)	--ISNULL checks  with 1st for null, fills with 2nd)
FROM NashvilleHousing AS t1
JOIN NashvilleHousing AS t2
	ON t1.ParcelID = t2.ParcelID		--when ParcelID is same. But UniqueID is diff so we don't get the same row. 
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL;


--Update table to. After running this query run previous query if blank then ALL GOOD

UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM NashvilleHousing AS t1
JOIN NashvilleHousing AS t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL;



----------Breaking out Addrress into diff cols (Address, City, State)-----------

SELECT PropertyAddress
FROM portfolio_project.dbo.NashvilleHousing;


--Will show the position of the char/delimeter
--For Ref |		SUBSTRING(string, start, length)	|	CHARINDEX(substring, string, start)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress)) AS Address, CHARINDEX( ',' , PropertyAddress) AS Char_Pos
FROM portfolio_project.dbo.NashvilleHousing;


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress) - 1) AS Address , 
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) AS ADDRESS
FROM portfolio_project.dbo.NashvilleHousing;


--To separate values into two cols we need to add tow cols


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(100);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' , PropertyAddress) - 1);



ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(100);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress));



---------------Now for OwnerAddress-------------------------
--For Ref |		SUBSTRING(string, start, length)	|	CHARINDEX(substring, string, start)	| PARSENAME (object_name, object_piece )


SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3) ,
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2) ,
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
FROM NashvilleHousing;


--Update table--


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(100);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3);



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(100);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2);



ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(100);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1);




-------------Change Y and N to Yes and No in "Sold as Vacant" field----------------

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END;


----Check---


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant;



-------------Get rid of duplicates---------------

WITH RowNumCTE AS (

SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY 
	ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY 
	UniqueID
	) AS row_num

FROM NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1;


-----Check

WITH RowNumCTE AS (

SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY 
	ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY 
	UniqueID
	) AS row_num

FROM NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;


-------------------Delete all the extra cols------------

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;