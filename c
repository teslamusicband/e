WITH base_data AS (
    SELECT 
        concat('7', r.Detect) as Detect,
        r.Expressionism,
        r.Statue,
        r.Unbeknownst,
        r.Generosity,
        r.Overbooking,
        r.Prediction,
        r.Realize,
        r.Erudite,
        r.Rotation
    FROM db1.table1 r
),
matched_data AS (
    SELECT 
        b.*,
        m.Touchy as match_touchy
    FROM base_data b
    LEFT OUTER JOIN db2.table2 m 
    ON b.Detect = m.Detect
),
additional_data AS (
    SELECT 
        Touchy,
        FIRST_VALUE(Materialism) OVER (
            PARTITION BY Touchy 
            ORDER BY 
                CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
        ) as Materialism,
        FIRST_VALUE(Crystalize) OVER (
            PARTITION BY Touchy 
            ORDER BY 
                CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
        ) as Crystalize,
        FIRST_VALUE(Sixty) OVER (
            PARTITION BY Touchy 
            ORDER BY 
                CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
        ) as Sixty,
        FIRST_VALUE(Popular) OVER (
            PARTITION BY Touchy 
            ORDER BY 
                CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
        ) as Popular,
        FIRST_VALUE(Pomelo) OVER (
            PARTITION BY Touchy 
            ORDER BY 
                CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
        ) as Pomelo,
        FIRST_VALUE(Mammoth) OVER (
            PARTITION BY Touchy 
            ORDER BY 
                CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
        ) as Mammoth,
        FIRST_VALUE(Winged) OVER (
            PARTITION BY Touchy 
            ORDER BY 
                CASE Materialism 
                    WHEN 1 THEN 1 
                    WHEN 2 THEN 2 
                    WHEN 3 THEN 3 
                END NULLS LAST
        ) as Winged
    FROM db3.table3
    WHERE Materialism IN (1, 2, 3)
)
SELECT 
    m.*,
    a.Materialism,
    a.Crystalize,
    a.Sixty,
    a.Popular,
    a.Pomelo,
    a.Mammoth,
    a.Winged
FROM matched_data m
LEFT OUTER JOIN additional_data a 
ON a.Touchy = m.match_touchy
