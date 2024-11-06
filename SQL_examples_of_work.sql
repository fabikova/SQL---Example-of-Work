-- 1) Vypište 10 ZIP kodu, kde se v roce 2014 prodalo v součtu nejvice kusu vyrobku

SELECT 
    TOP 10 Zip,
    SUM(Units) AS Units_total
FROM 
    Sales 
WHERE 
    DATEPART(YEAR, [Date]) = 2014
GROUP BY 
    Zip
ORDER BY
    Units_total DESC 

-- 2) Kolik je měst, jejiž název obsahuje "land"?

SELECT 
    COUNT(Distinct City)
FROM 
    Country
WHERE 
    City LIKE '%land%'

-- 3) Jaké byly celkové tržby jednotlivých státu v prosinci 2013?

SELECT
    SUM (Revenue) As State_revenue,
    State 
FROM 
    Sales s
    JOIN Country c ON s.Zip = c.Zip
WHERE 
    DATEPART(YEAR, Date) = 2013 AND
    DATEPART(MONTH, Date) = 12
GROUP BY 
    [State]
ORDER BY 
    State_revenue DESC

-- 4) Který výrobce vydelal nejvíc v kategorii MIX?

SELECT TOP 1 WITH TIES
    SUM(Revenue) As Total_revenue,
    Manufacturer
FROM 
    Sales s 
    JOIN Product p ON s.ProductID = p.ProductID
    JOIN Manufacturer m ON p.ManufacturerID = m.ManufacturerID
WHERE 
    Category = 'Mix'
GROUP BY 
    Manufacturer
ORDER BY 
    Total_revenue DESC

-- 5) Kterí výrobci nemají žádne výrobky v kategorii Youth?

SELECT 
    Manufacturer
FROM
    Manufacturer m 
    LEFT JOIN Product p ON m.ManufacturerID = p.ManufacturerID AND p.Category = N'Youth'
WHERE 
    p.ProductID IS NULL


-- Který výrobce prodává v nejméně státech?

SELECT
    Manufacturer,
    Count(DIstinct State) AS NumberofStates   -- pozor treba tu dat count a nie sum!!!, pocitam kolko je tam riadkov roznych a nie hodnotu, to by bolo sum
FROM 
    Sales s 
    JOIN Country c ON c.Zip = s.Zip
    JOIN Product p ON p.ProductID = s.ProductID
    JOIN Manufacturer m ON m.ManufacturerID = p.ManufacturerID
GROUP BY 
    Manufacturer
ORDER BY
    NumberofStates ASC

-- Views

CREATE VIEW [dbo].[FrontendView] AS
(
SELECT
    s.Date,
    s.Revenue,
    s.Units,
    p.Product,
    p.Category,
    m.Manufacturer,
    c.City,
    c.State
FROM
    Sales s
    JOIN Product p ON p.ProductID = s.ProductID
    JOIN Manufacturer m ON m.ManufacturerID = p.ManufacturerID
    JOIN Country c ON c.Zip = s.Zip
)


DECLARE @cisla TABLE ([skupina] char, [cislo] int)
INSERT INTO
    @cisla ([skupina], [cislo])
VALUES
    ('A', 4),
    ('A', 7),
    ('A', 1),
    ('A', 3),
    ('A', 8),
    ('B', 5),
    ('B', 12),
    ('C', 1)

SELECT
    * 
FROM 
    @cisla c1
    LEFT JOIN @cisla c2 ON c1.skupina = c2.skupina AND c2.cislo > c1.cislo
WHERE
    c2.cislo IS NULL


-- COMMON TABLE EXPRESSIONS:

;WITH StateTotals AS
(
    SELECT
        State,
        SUM(TotalRevenue) AS StateRevenue
    FROM
        StateManufacturerView
    GROUP BY
        State
),
ManufacturerTotals AS
(
    SELECT
        Manufacturer,
        SUM(TotalRevenue) AS ManufacturerRevenue
    FROM
        StateManufacturerView
    GROUP BY
        Manufacturer
)
SELECT
    smv.State,
    smv.Manufacturer,
    100.0 * smv.TotalRevenue / StateRevenue,
    100.0 * smv.TotalRevenue / mt.ManufacturerRevenue
FROM
    StateManufacturerView smv
    JOIN StateTotals st ON smv.State = st.State
    JOIN ManufacturerTotals mt ON mt.Manufacturer = smv.Manufacturer



-- ve kterych statech vydelali jednotlivi vyrobci nejvic?

SELECT 
    *
FROM 
    StateManufacturerView smv1
    LEFT JOIN StateManufacturerView smv2 
        ON smv1.Manufacturer = smv2.Manufacturer 
    AND smv2.TotalRevenue > smv1.TotalRevenue
WHERE 
    smv2.State IS NULL 

-- zanoreným selectom:

SELECT
	smv1.Manufacturer,
	smv1.State
FROM
	StateManufacturerView smv1
WHERE
	NOT EXISTS (
		SELECT
			*
		FROM
			StateManufacturerView smv2
		WHERE
			smv2.Manufacturer = smv1.Manufacturer AND
			smv2.TotalRevenue > smv1.TotalRevenue
	)