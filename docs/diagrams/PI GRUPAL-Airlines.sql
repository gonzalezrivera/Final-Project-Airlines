USE  airlines;
GO
EXEC sp_changedbowner 'sa'; 
GO


-- Nos aseguramos que las columnas de clave primaria no sean nulas
ALTER TABLE dbo.aircrafts_data
ALTER COLUMN aircraft_code CHAR(3) NOT NULL;

ALTER TABLE dbo.airports_data
ALTER COLUMN airport_code CHAR(3) NOT NULL;

ALTER TABLE dbo.bookings
ALTER COLUMN book_ref CHAR(50) NOT NULL;

ALTER TABLE dbo.flights
ALTER COLUMN flight_id INT NOT NULL;

ALTER TABLE dbo.flights
ALTER COLUMN departure_airport CHAR(3);

ALTER TABLE dbo.flights
ALTER COLUMN arrival_airport CHAR(3);

ALTER TABLE dbo.flights
ALTER COLUMN aircraft_code CHAR (3);

ALTER TABLE dbo.seats
ALTER COLUMN aircraft_code CHAR(3) NOT NULL;

ALTER TABLE dbo.seats
ALTER COLUMN seat_no NVARCHAR(4) NOT NULL;

ALTER TABLE dbo.tickets
ALTER COLUMN ticket_no CHAR(20) NOT NULL;

ALTER TABLE dbo.tickets
ALTER COLUMN book_ref CHAR(50);

ALTER TABLE dbo.boarding_passes
ALTER COLUMN ticket_no CHAR(13) NOT NULL;

ALTER TABLE dbo.boarding_passes
ALTER COLUMN flight_id INT NOT NULL;

ALTER TABLE dbo.ticket_flights
ALTER COLUMN ticket_no CHAR(20) NOT NULL;

ALTER TABLE dbo.ticket_flights
ALTER COLUMN flight_id INT NOT NULL;

--Definimos las PK
ALTER TABLE dbo.aircrafts_data
ADD CONSTRAINT PK_aircrafts_data PRIMARY KEY (aircraft_code);

ALTER TABLE dbo.airports_data
ADD CONSTRAINT PK_airports_data PRIMARY KEY (airport_code);

ALTER TABLE dbo.bookings
ADD CONSTRAINT PK_bookings PRIMARY KEY (book_ref);

 --Se eliminarion los duplicados de book_ref para poder establecerla como PK
DELETE FROM dbo.bookings
WHERE book_ref IN (
    SELECT book_ref
    FROM dbo.bookings
    GROUP BY book_ref
    HAVING COUNT(*) > 1
);

ALTER TABLE dbo.flights
ADD CONSTRAINT PK_flights PRIMARY KEY (flight_id);



ALTER TABLE dbo.tickets
ADD CONSTRAINT PK_tickets PRIMARY KEY (ticket_no);


-- Definimos las claves primarias compuestas
ALTER TABLE dbo.boarding_passes
ADD CONSTRAINT PK_boarding_passes PRIMARY KEY (ticket_no, flight_id);

ALTER TABLE dbo.seats
ADD CONSTRAINT PK_seats PRIMARY KEY (aircraft_code, seat_no);


ALTER TABLE dbo.ticket_flights
ADD CONSTRAINT PK_ticket_flights PRIMARY KEY (ticket_no, flight_id);

-- Definimos las FK
ALTER TABLE dbo.flights
ADD CONSTRAINT FK_flights_departure_airport
FOREIGN KEY (departure_airport) REFERENCES dbo.airports_data(airport_code);

ALTER TABLE dbo.flights
ADD CONSTRAINT FK_flights_arrival_airport
FOREIGN KEY (arrival_airport) REFERENCES dbo.airports_data(airport_code);

ALTER TABLE dbo.flights
ADD CONSTRAINT FK_flights_aircraft_code
FOREIGN KEY (aircraft_code) REFERENCES dbo.aircrafts_data(aircraft_code);

ALTER TABLE dbo.seats
ADD CONSTRAINT FK_seats_aircraft_code
FOREIGN KEY (aircraft_code) REFERENCES dbo.aircrafts_data(aircraft_code);


ALTER TABLE dbo.boarding_passes
ADD CONSTRAINT FK_boarding_passes_flight_id
FOREIGN KEY (flight_id) REFERENCES dbo.flights(flight_id);



-- Se eliminarios los ceros adicionales en dbo.tickets para que coincidan con los  de ticket_no de la tabla dbo.ticket_flights.
UPDATE dbo.tickets
SET ticket_no = SUBSTRING(ticket_no, PATINDEX('%[^0]%', ticket_no + ' '), LEN(ticket_no))
WHERE ticket_no LIKE '0%';

ALTER TABLE dbo.ticket_flights
ADD CONSTRAINT FK_ticket_flights_ticket_no
FOREIGN KEY (ticket_no) REFERENCES dbo.tickets(ticket_no);



ALTER TABLE dbo.ticket_flights
ADD CONSTRAINT FK_ticket_flights_flight_id
FOREIGN KEY (flight_id) REFERENCES dbo.flights(flight_id);



-- Incorporamos ticket_no de la tabla dbo.tickets a dbo.bookings para generar la relacion entre ambas tablas. 
ALTER TABLE dbo.bookings
ADD ticket_no CHAR(20); -- Ajusta el tipo de dato según corresponda

-- Actualizamos los datos de  dbo.bookings con ticket_id desde dbo.tickets
UPDATE b
SET b.ticket_no = t.ticket_no
FROM dbo.bookings b
INNER JOIN dbo.tickets t ON b.book_ref = t.book_ref;

-- Se establece la FK
ALTER TABLE dbo.bookings
ADD CONSTRAINT FK_bookings_tickets FOREIGN KEY (ticket_no) REFERENCES dbo.tickets(ticket_no);


