
--Se realiza el reemplazo en la columna actual_departure por la fecha  de scheduled_departure cuando el 
--estado es 'on time'

UPDATE flights
SET actual_departure = scheduled_departure
WHERE status = 'on time';

--Se realiza el reemplazo en la columna actual_arrival por la fecha  de scheduled_arrival cuando el 
--estado es 'on time'

UPDATE flights
SET actual_arrival = scheduled_arrival
WHERE status = 'on time';


--se cambia el valor '\N' por NULL en las columnas actual_arrival actual_arrival para no generar conflicto 
--con estos datos nulos
UPDATE flights
SET actual_departure = NULL
WHERE actual_departure = '\N';

UPDATE flights
SET actual_arrival = NULL
WHERE actual_arrival = '\N';

--para lograr el cambio de tipo de fecha en algunas columnas de las tablas flights y bookings se elimina
--el caractere +3

UPDATE flights
SET scheduled_departure = LEFT(scheduled_departure, LEN(scheduled_departure) - 3)
WHERE scheduled_departure LIKE '%+03';

UPDATE flights
SET scheduled_arrival = LEFT(scheduled_arrival, LEN(scheduled_arrival) - 3)
WHERE scheduled_arrival LIKE '%+03';

UPDATE flights
SET actual_departure = LEFT(actual_departure, LEN(actual_departure) - 3)
WHERE actual_departure LIKE '%+03';

UPDATE flights
SET actual_arrival = LEFT(actual_arrival, LEN(actual_arrival) - 3)
WHERE actual_arrival LIKE '%+03';

UPDATE bookings
SET book_date = LEFT(book_date, LEN(book_date) - 3)
WHERE book_date LIKE '%+03';

