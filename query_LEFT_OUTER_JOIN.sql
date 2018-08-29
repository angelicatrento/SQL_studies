DECLARE @testLeft TABLE (ID INT, SomeValue VARCHAR(1))
DECLARE @testRight TABLE (ID INT, SomeOtherValue VARCHAR(1))

INSERT INTO @testLeft (ID, SomeValue) VALUES (1, 'A')
INSERT INTO @testLeft (ID, SomeValue) VALUES (2, 'B')
INSERT INTO @testLeft (ID, SomeValue) VALUES (3, 'C')


INSERT INTO @testRight (ID, SomeOtherValue) VALUES (1, 'X')
INSERT INTO @testRight (ID, SomeOtherValue) VALUES (3, 'Z')

SELECT l.*
FROM 
    @testLeft l
     LEFT JOIN 
    @testRight r ON 
        l.ID = r.ID
WHERE r.ID IS NULL 